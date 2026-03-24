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

export function useReportSoreness() {
  const queryClient = useQueryClient();
  const user = useAuthStore((s) => s.user);

  return useMutation({
    mutationFn: async (input: {
      muscleGroupId: number;
      level: number;
      trainingDate: string;
    }) => {
      if (!user) throw new Error('Not authenticated');

      const { data, error } = await supabase
        .from('soreness_reports')
        .upsert(
          {
            user_id: user.id,
            muscle_group_id: input.muscleGroupId,
            level: input.level,
            training_date: input.trainingDate,
          },
          { onConflict: 'user_id,muscle_group_id,training_date' }
        )
        .select()
        .single();

      if (error) throw error;
      return data as SorenessReport;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ['soreness'] });
    },
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
