import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { useAuthStore } from '@/stores/authStore';

export interface WeeklyMuscleVolume {
  week: string; // ISO week start date (YYYY-MM-DD)
  muscleGroup: string;
  volume: number;
}

function getWeekStart(date: Date): string {
  const d = new Date(date);
  const day = d.getDay();
  const diff = d.getDate() - day + (day === 0 ? -6 : 1); // Monday
  d.setDate(diff);
  return d.toISOString().split('T')[0]!;
}

function getPeriodCutoff(period: string): Date {
  const now = new Date();
  if (period === 'week') now.setDate(now.getDate() - 7);
  else if (period === 'month') now.setMonth(now.getMonth() - 1);
  else if (period === '3months') now.setMonth(now.getMonth() - 3);
  else now.setFullYear(now.getFullYear() - 10); // "all"
  return now;
}

/**
 * Fetch weekly training volume grouped by muscle group.
 * Joins sets → exercise_muscles → muscle_groups to compute volume per muscle per week.
 */
export function useWeeklyMuscleVolume(period: string) {
  return useQuery<WeeklyMuscleVolume[]>({
    queryKey: ['analytics', 'muscle-volume', period],
    queryFn: async () => {
      const user = useAuthStore.getState().user;
      if (!user) return [];

      const cutoff = getPeriodCutoff(period);

      // Fetch sets with exercise_id, weight, reps, logged_at, weight_unit
      const { data: sets, error: setsError } = await supabase
        .from('sets')
        .select('exercise_id, weight, reps, logged_at, weight_unit')
        .eq('user_id', user.id)
        .gte('logged_at', cutoff.toISOString())
        .order('logged_at', { ascending: true });

      if (setsError) throw setsError;
      if (!sets || sets.length === 0) return [];

      // Get unique exercise IDs
      const exerciseIds = [...new Set(sets.map((s) => s.exercise_id))];

      // Fetch exercise-muscle mappings for these exercises
      const { data: muscles, error: muscleError } = await supabase
        .from('exercise_muscles')
        .select('exercise_id, muscle_group_id, is_primary, muscle_groups(name)')
        .in('exercise_id', exerciseIds);

      if (muscleError) throw muscleError;

      // Build lookup: exercise_id → [{muscleName, isPrimary}]
      const muscleMap = new Map<string, Array<{ name: string; isPrimary: boolean }>>();
      for (const m of muscles ?? []) {
        const name = (m.muscle_groups as unknown as { name: string })?.name;
        if (!name) continue;
        const existing = muscleMap.get(m.exercise_id) ?? [];
        existing.push({ name, isPrimary: m.is_primary });
        muscleMap.set(m.exercise_id, existing);
      }

      // Aggregate volume per week per muscle group
      // Primary muscles get 100% of volume, secondary get 50%
      const weekMuscle = new Map<string, number>(); // "week|muscle" → volume

      for (const set of sets) {
        const week = getWeekStart(new Date(set.logged_at));
        // Normalize weight to kg for consistent volume calculation
        const weightKg = set.weight_unit === 'lb' ? set.weight * 0.453592 : set.weight;
        const volume = weightKg * set.reps;
        const muscles = muscleMap.get(set.exercise_id) ?? [];

        for (const { name, isPrimary } of muscles) {
          const key = `${week}|${name}`;
          const share = isPrimary ? volume : volume * 0.5;
          weekMuscle.set(key, (weekMuscle.get(key) ?? 0) + share);
        }
      }

      // Convert to array
      const result: WeeklyMuscleVolume[] = [];
      for (const [key, vol] of weekMuscle) {
        const [week, muscle] = key.split('|') as [string, string];
        result.push({ week, muscleGroup: muscle, volume: Math.round(vol) });
      }

      // Sort by week
      result.sort((a, b) => a.week.localeCompare(b.week));
      return result;
    },
    staleTime: 5 * 60 * 1000,
  });
}
