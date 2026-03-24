import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { useAuthStore } from '@/stores/authStore';

export interface SorenessReport {
  id: string;
  muscle_group_id: number;
  level: number; // 0-4
  training_date: string;
  reported_at: string;
}

export interface SorenessWithMuscle extends SorenessReport {
  muscleName: string;
}

const SORENESS_LABELS = ['None', 'Mild', 'Moderate', 'Severe', 'Extreme'];
export { SORENESS_LABELS };

// ---------------------------------------------------------------------------
// useSorenessPrompt — determines if the soreness prompt should show
// ---------------------------------------------------------------------------
export function useSorenessPrompt() {
  const user = useAuthStore((s) => s.user);

  return useQuery<{ shouldShow: boolean; trainingDate: string }>({
    queryKey: ['sorenessPrompt', user?.id],
    enabled: !!user,
    queryFn: async () => {
      if (!user) return { shouldShow: false, trainingDate: '' };

      const now = new Date();
      const fortyEightHoursAgo = new Date(now.getTime() - 48 * 60 * 60 * 1000);
      const twentyFourHoursAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000);

      // Query the user's most recent set's logged_at
      const { data: recentSets, error: setsError } = await supabase
        .from('sets')
        .select('logged_at')
        .eq('user_id', user.id)
        .order('logged_at', { ascending: false })
        .limit(1);

      if (setsError) throw setsError;
      if (!recentSets || recentSets.length === 0) {
        return { shouldShow: false, trainingDate: '' };
      }

      const lastLoggedAt = new Date(recentSets[0]!.logged_at);

      // Check if 24-48 hours ago
      if (lastLoggedAt < fortyEightHoursAgo || lastLoggedAt > twentyFourHoursAgo) {
        return { shouldShow: false, trainingDate: '' };
      }

      const trainingDate = recentSets[0]!.logged_at.slice(0, 10);

      // Check if soreness report already exists for that training date
      const { data: existing, error: existingError } = await supabase
        .from('soreness_reports')
        .select('id')
        .eq('user_id', user.id)
        .eq('training_date', trainingDate)
        .limit(1);

      if (existingError) throw existingError;

      if (existing && existing.length > 0) {
        return { shouldShow: false, trainingDate: '' };
      }

      return { shouldShow: true, trainingDate };
    },
    staleTime: 5 * 60 * 1000,
  });
}

// ---------------------------------------------------------------------------
// useReportSoreness — mutation to insert soreness reports (batch)
// ---------------------------------------------------------------------------
export function useReportSoreness() {
  const queryClient = useQueryClient();
  const user = useAuthStore((s) => s.user);

  return useMutation({
    mutationFn: async (
      input: { muscleGroupId: number; level: number; trainingDate: string }[],
    ) => {
      if (!user) throw new Error('Not authenticated');

      const rows = input.map((item) => ({
        user_id: user.id,
        muscle_group_id: item.muscleGroupId,
        level: item.level,
        training_date: item.trainingDate,
      }));

      const { data, error } = await supabase
        .from('soreness_reports')
        .upsert(rows, { onConflict: 'user_id,muscle_group_id,training_date' })
        .select();

      if (error) throw error;
      return (data ?? []) as SorenessReport[];
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ['soreness'] });
      void queryClient.invalidateQueries({ queryKey: ['sorenessPrompt'] });
      void queryClient.invalidateQueries({ queryKey: ['pendingSoreness'] });
    },
  });
}

// ---------------------------------------------------------------------------
// useSorenessHistory — query recent reports with muscle names
// ---------------------------------------------------------------------------
export function useSorenessHistory(period: string) {
  const user = useAuthStore((s) => s.user);

  return useQuery<
    { muscleName: string; level: number; trainingDate: string; reportedAt: string }[]
  >({
    queryKey: ['soreness', 'history', user?.id, period],
    enabled: !!user,
    queryFn: async () => {
      if (!user) return [];

      const cutoff = new Date();
      if (period === 'week') cutoff.setDate(cutoff.getDate() - 7);
      else if (period === 'month') cutoff.setMonth(cutoff.getMonth() - 1);
      else if (period === '3months') cutoff.setMonth(cutoff.getMonth() - 3);
      else cutoff.setFullYear(cutoff.getFullYear() - 10); // "all"

      const { data, error } = await supabase
        .from('soreness_reports')
        .select('*, muscle_groups(name)')
        .eq('user_id', user.id)
        .gte('training_date', cutoff.toISOString().slice(0, 10))
        .order('reported_at', { ascending: false });

      if (error) throw error;

      return (data ?? []).map((r) => ({
        muscleName:
          r.muscle_groups && typeof r.muscle_groups === 'object'
            ? (r.muscle_groups as { name: string }).name
            : `Muscle ${r.muscle_group_id}`,
        level: r.level as number,
        trainingDate: r.training_date as string,
        reportedAt: r.reported_at as string,
      }));
    },
    staleTime: 2 * 60 * 1000,
  });
}

// ---------------------------------------------------------------------------
// Legacy hooks (preserved for backward compatibility with SorenessPromptCard)
// ---------------------------------------------------------------------------

export function useSorenessReports(days = 14) {
  const user = useAuthStore((s) => s.user);
  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() - days);

  return useQuery<SorenessWithMuscle[]>({
    queryKey: ['soreness', user?.id, days],
    enabled: !!user,
    queryFn: async () => {
      if (!user) return [];

      const { data, error } = await supabase
        .from('soreness_reports')
        .select('*, muscle_groups(name)')
        .eq('user_id', user.id)
        .gte('training_date', cutoff.toISOString().slice(0, 10))
        .order('reported_at', { ascending: false });

      if (error) throw error;

      return (data ?? []).map((r) => ({
        ...r,
        muscleName:
          r.muscle_groups && typeof r.muscle_groups === 'object'
            ? (r.muscle_groups as { name: string }).name
            : `Muscle ${r.muscle_group_id}`,
      })) as SorenessWithMuscle[];
    },
    staleTime: 2 * 60 * 1000,
  });
}

export function usePendingSoreness() {
  const user = useAuthStore((s) => s.user);

  return useQuery<string[]>({
    queryKey: ['pendingSoreness', user?.id],
    enabled: !!user,
    queryFn: async () => {
      if (!user) return [];

      // Find training days from 1-3 days ago that don't have soreness reports
      const threeDaysAgo = new Date();
      threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);
      const oneDayAgo = new Date();
      oneDayAgo.setDate(oneDayAgo.getDate() - 1);

      const { data: sets } = await supabase
        .from('sets')
        .select('logged_at')
        .eq('user_id', user.id)
        .gte('logged_at', threeDaysAgo.toISOString())
        .lte('logged_at', oneDayAgo.toISOString());

      if (!sets || sets.length === 0) return [];

      const trainingDates = [...new Set(sets.map((s) => s.logged_at.slice(0, 10)))];

      // Check which dates already have soreness reports
      const { data: existing } = await supabase
        .from('soreness_reports')
        .select('training_date')
        .eq('user_id', user.id)
        .in('training_date', trainingDates);

      const reportedDates = new Set((existing ?? []).map((r) => r.training_date));
      return trainingDates.filter((d) => !reportedDates.has(d));
    },
    staleTime: 5 * 60 * 1000,
  });
}
