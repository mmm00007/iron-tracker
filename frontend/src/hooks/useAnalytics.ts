import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import type { WorkoutSet, PersonalRecord, Exercise } from '@/types/database';
import {
  weeklySnapshot,
  trainingFrequency,
  trainingFrequencyPerWeek,
  volumeByMuscle,
  topExercises,
  e1rmTrend,
  weeklyVolume,
  exercisePRs,
  computeStreak,
} from '@/utils/analytics';
import type { TrainingStreakResult, WeeklyFrequencyEntry } from '@/utils/analytics';

type Period = 'week' | 'month' | '3months' | 'all';

// ─── Helper: fetch user sets (optionally filtered by date/exercise) ──────────
// Selects only the columns needed for analytics to reduce payload size.

const ANALYTICS_COLUMNS = 'id,user_id,exercise_id,variant_id,weight,weight_unit,reps,rpe,rir,set_type,estimated_1rm,logged_at' as const;

async function fetchUserSets(since?: Date, exerciseId?: string, limit = 2000): Promise<WorkoutSet[]> {
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return [];

  let query = supabase
    .from('sets')
    .select(ANALYTICS_COLUMNS)
    .eq('user_id', user.id)
    .order('logged_at', { ascending: false });

  if (since) {
    query = query.gte('logged_at', since.toISOString());
  }

  if (exerciseId) {
    query = query.eq('exercise_id', exerciseId);
  }

  const { data, error } = await query.limit(limit);
  if (error) throw error;
  return (data ?? []) as WorkoutSet[];
}

function periodCutoff(period: Period): Date | undefined {
  const now = new Date();
  switch (period) {
    case 'week': {
      const d = new Date(now);
      d.setDate(d.getDate() - 7);
      return d;
    }
    case 'month': {
      const d = new Date(now);
      d.setMonth(d.getMonth() - 1);
      return d;
    }
    case '3months': {
      const d = new Date(now);
      d.setMonth(d.getMonth() - 3);
      return d;
    }
    case 'all':
      return undefined;
  }
}

// ─── Weekly Snapshot ──────────────────────────────────────────────────────────

/**
 * This week vs last week comparison.
 * Fetches last 14 days of sets, computes snapshot.
 */
export function useWeeklySnapshot() {
  return useQuery({
    queryKey: ['analytics', 'weeklySnapshot'],
    queryFn: async () => {
      const cutoff = new Date();
      cutoff.setDate(cutoff.getDate() - 14);
      const sets = await fetchUserSets(cutoff);
      return weeklySnapshot(sets);
    },
    staleTime: 5 * 60 * 1000,
  });
}

// ─── Recent PRs ───────────────────────────────────────────────────────────────

export interface RecentPR {
  id: string;
  exerciseId: string;
  exerciseName: string;
  recordType: PersonalRecord['record_type'];
  repCount: number | null;
  value: number;
  achievedAt: string;
}

/**
 * Last 5 personal records with exercise names.
 */
export function useRecentPRs(period?: Period) {
  return useQuery<RecentPR[]>({
    queryKey: ['analytics', 'recentPRs', period ?? 'all'],
    queryFn: async () => {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) return [];

      const since = period ? periodCutoff(period) : undefined;

      let prQuery = supabase
        .from('personal_records')
        .select('*, exercises(name)')
        .eq('user_id', user.id)
        .order('achieved_at', { ascending: false })
        .limit(5);

      if (since) {
        prQuery = prQuery.gte('achieved_at', since.toISOString());
      }

      const { data: prs, error } = await prQuery;

      if (error) throw error;
      if (!prs) return [];

      return prs.map((pr) => ({
        id: pr.id,
        exerciseId: pr.exercise_id,
        exerciseName: (pr.exercises as { name: string } | null)?.name ?? 'Unknown',
        recordType: pr.record_type,
        repCount: pr.rep_count,
        value: pr.value,
        achievedAt: pr.achieved_at,
      }));
    },
    staleTime: 5 * 60 * 1000,
  });
}

// ─── Training Frequency ───────────────────────────────────────────────────────

/**
 * Per-day training activity for the last 12 weeks (for calendar heatmap).
 */
export function useTrainingFrequency(period?: Period) {
  return useQuery({
    queryKey: ['analytics', 'trainingFrequency', period ?? 'all'],
    queryFn: async () => {
      const since = period ? periodCutoff(period) : (() => {
        const cutoff = new Date();
        cutoff.setDate(cutoff.getDate() - 84); // 12 weeks default
        return cutoff;
      })();
      const sets = await fetchUserSets(since);
      return trainingFrequency(sets, 12);
    },
    staleTime: 5 * 60 * 1000,
  });
}

// ─── Muscle Distribution ──────────────────────────────────────────────────────

export interface MuscleDistributionEntry {
  muscleGroupId: number;
  muscleName: string;
  volume: number;
  percentage: number;
}

/**
 * Volume per muscle group for the selected period.
 */
export function useMuscleDistribution(period: Period) {
  return useQuery<MuscleDistributionEntry[]>({
    queryKey: ['analytics', 'muscleDistribution', period],
    queryFn: async () => {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) return [];

      const since = periodCutoff(period);
      const sets = await fetchUserSets(since);
      if (sets.length === 0) return [];

      // Fetch exercise-muscle mappings (including activation_percent for weighted volume)
      const exerciseIds = [...new Set(sets.map((s) => s.exercise_id))];
      const { data: muscles, error: muscleError } = await supabase
        .from('exercise_muscles')
        .select('exercise_id, muscle_group_id, activation_percent')
        .in('exercise_id', exerciseIds);

      if (muscleError) throw muscleError;

      // Fetch muscle group names
      const { data: muscleGroups, error: mgError } = await supabase
        .from('muscle_groups')
        .select('id, name');

      if (mgError) throw mgError;

      const muscleGroupMap = new Map<number, string>(
        (muscleGroups ?? []).map((mg) => [mg.id, mg.name]),
      );

      // Build exercise → muscles map with activation percentages
      const exerciseMuscles = new Map<string, { muscleGroupId: number; activationPercent: number | null }[]>();
      for (const row of muscles ?? []) {
        const existing = exerciseMuscles.get(row.exercise_id) ?? [];
        existing.push({ muscleGroupId: row.muscle_group_id, activationPercent: row.activation_percent });
        exerciseMuscles.set(row.exercise_id, existing);
      }

      const volByMuscle = volumeByMuscle(sets, exerciseMuscles);
      const totalVol = Array.from(volByMuscle.values()).reduce((sum, v) => sum + v, 0);

      if (totalVol === 0) return [];

      return Array.from(volByMuscle.entries())
        .map(([muscleGroupId, volume]) => ({
          muscleGroupId,
          muscleName: muscleGroupMap.get(muscleGroupId) ?? `Muscle ${muscleGroupId}`,
          volume,
          percentage: Math.round((volume / totalVol) * 100),
        }))
        .sort((a, b) => b.volume - a.volume);
    },
    staleTime: 5 * 60 * 1000,
  });
}

// ─── Top Exercises ────────────────────────────────────────────────────────────

export interface TopExerciseWithName {
  exerciseId: string;
  exerciseName: string;
  totalVolume: number;
  setCount: number;
  trend: 'up' | 'down' | 'flat';
}

/**
 * Top exercises by total volume, enriched with exercise names.
 */
export function useTopExercises(limit = 5, period?: Period) {
  return useQuery<TopExerciseWithName[]>({
    queryKey: ['analytics', 'topExercises', limit, period ?? 'all'],
    queryFn: async () => {
      const since = period ? periodCutoff(period) : (() => {
        const d = new Date();
        d.setMonth(d.getMonth() - 6); // 6 months default
        return d;
      })();
      const sets = await fetchUserSets(since);
      if (sets.length === 0) return [];

      const top = topExercises(sets, limit);
      const exerciseIds = top.map((t) => t.exerciseId);

      const { data: exercises, error } = await supabase
        .from('exercises')
        .select('id, name')
        .in('id', exerciseIds);

      if (error) throw error;

      const nameMap = new Map<string, string>(
        (exercises ?? []).map((e: Pick<Exercise, 'id' | 'name'>) => [e.id, e.name]),
      );

      return top.map((t) => ({
        exerciseId: t.exerciseId,
        exerciseName: nameMap.get(t.exerciseId) ?? 'Unknown',
        totalVolume: t.totalVolume,
        setCount: t.setCount,
        trend: t.trend,
      }));
    },
    staleTime: 5 * 60 * 1000,
  });
}

// ─── Volume Trend (last 8 weeks, for sparkline) ─────────────────────────────

export function useVolumeTrendSpark() {
  return useQuery<number[]>({
    queryKey: ['analytics', 'volumeTrendSpark'],
    queryFn: async () => {
      const cutoff = new Date();
      cutoff.setDate(cutoff.getDate() - 56); // 8 weeks
      const sets = await fetchUserSets(cutoff);
      const weekly = weeklyVolume(sets);
      return weekly.map((w) => w.volume);
    },
    staleTime: 5 * 60 * 1000,
  });
}

// ─── Training Streak ────────────────────────────────────────────────────────

export function useTrainingStreak() {
  return useQuery<TrainingStreakResult>({
    queryKey: ['analytics', 'trainingStreak'],
    queryFn: async () => {
      const cutoff = new Date();
      cutoff.setDate(cutoff.getDate() - 90);
      const sets = await fetchUserSets(cutoff);
      return computeStreak(sets);
    },
    staleTime: 5 * 60 * 1000,
  });
}

// ─── Training Frequency Per Week (bar chart data) ───────────────────────────

/**
 * Training days per week for the last 8 weeks (for bar chart visualization).
 */
export function useTrainingFrequencyWeekly() {
  return useQuery<WeeklyFrequencyEntry[]>({
    queryKey: ['analytics', 'trainingFrequencyWeekly'],
    queryFn: async () => {
      const cutoff = new Date();
      cutoff.setDate(cutoff.getDate() - 60); // ~8.5 weeks
      const sets = await fetchUserSets(cutoff);
      return trainingFrequencyPerWeek(sets, 8);
    },
    staleTime: 5 * 60 * 1000,
  });
}

// ─── RPE Distribution ────────────────────────────────────────────────────────

export interface RPEDistributionEntry {
  rpe: number;
  count: number;
}

/**
 * Distribution of RPE values across all working sets in the given period.
 * Returns entries for RPE 1-10.
 */
export function useRPEDistribution(period: Period) {
  return useQuery<RPEDistributionEntry[]>({
    queryKey: ['analytics', 'rpeDistribution', period],
    queryFn: async () => {
      const since = periodCutoff(period);
      const sets = await fetchUserSets(since);
      const workingSets = sets.filter(
        (s) => s.rpe !== null && s.rpe !== undefined && s.set_type !== 'warmup',
      );
      const counts = new Map<number, number>();
      for (let rpe = 1; rpe <= 10; rpe++) counts.set(rpe, 0);
      for (const s of workingSets) {
        const rpe = Math.round(s.rpe!);
        counts.set(rpe, (counts.get(rpe) ?? 0) + 1);
      }
      return Array.from(counts.entries())
        .map(([rpe, count]) => ({ rpe, count }))
        .filter((e) => e.count > 0);
    },
    staleTime: 5 * 60 * 1000,
  });
}

// ─── Muscle Balance (sets per muscle group per week) ─────────────────────────

export interface MuscleBalanceEntry {
  muscleName: string;
  sets: number;
}

/**
 * Weekly average sets per muscle group for the radar chart.
 */
export function useMuscleBalance(period: Period) {
  return useQuery<MuscleBalanceEntry[]>({
    queryKey: ['analytics', 'muscleBalance', period],
    queryFn: async () => {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) return [];

      const since = periodCutoff(period);
      const sets = await fetchUserSets(since);
      if (sets.length === 0) return [];

      // Calculate the number of weeks in the period
      const now = new Date();
      const start = since ?? new Date(Math.min(...sets.map((s) => new Date(s.logged_at).getTime())));
      const weeks = Math.max(1, Math.ceil((now.getTime() - start.getTime()) / (7 * 24 * 60 * 60 * 1000)));

      // Fetch exercise-muscle mappings
      const exerciseIds = [...new Set(sets.map((s) => s.exercise_id))];
      const { data: muscles } = await supabase
        .from('exercise_muscles')
        .select('exercise_id, muscle_group_id, is_primary')
        .in('exercise_id', exerciseIds);

      const { data: muscleGroups } = await supabase
        .from('muscle_groups')
        .select('id, name');

      const muscleGroupMap = new Map<number, string>(
        (muscleGroups ?? []).map((mg) => [mg.id, mg.name]),
      );

      // Build exercise → primary muscle groups
      const exercisePrimaryMuscles = new Map<string, number[]>();
      for (const row of muscles ?? []) {
        if (!row.is_primary) continue;
        const existing = exercisePrimaryMuscles.get(row.exercise_id) ?? [];
        existing.push(row.muscle_group_id);
        exercisePrimaryMuscles.set(row.exercise_id, existing);
      }

      // Count working sets per muscle group
      const setsByMuscle = new Map<number, number>();
      for (const s of sets) {
        if (s.set_type === 'warmup') continue;
        const primaryMuscles = exercisePrimaryMuscles.get(s.exercise_id) ?? [];
        for (const muscleId of primaryMuscles) {
          setsByMuscle.set(muscleId, (setsByMuscle.get(muscleId) ?? 0) + 1);
        }
      }

      return Array.from(setsByMuscle.entries())
        .map(([muscleId, totalSets]) => ({
          muscleName: muscleGroupMap.get(muscleId) ?? `Muscle ${muscleId}`,
          sets: Math.round(totalSets / weeks),
        }))
        .filter((e) => e.sets > 0)
        .sort((a, b) => b.sets - a.sets)
        .slice(0, 10); // Top 10 for readability on radar
    },
    staleTime: 5 * 60 * 1000,
  });
}

// ─── Exercise: 1RM Trend ──────────────────────────────────────────────────────

/**
 * Estimated 1RM trend for a specific exercise (+ optional variant).
 * Fetches up to 12 months of history.
 */
export function useE1RMTrend(exerciseId: string, variantId?: string | null) {
  return useQuery({
    queryKey: ['analytics', 'e1rmTrend', exerciseId, variantId ?? 'all'],
    queryFn: async () => {
      const since = new Date();
      since.setMonth(since.getMonth() - 12);
      const sets = await fetchUserSets(since);
      return e1rmTrend(sets, exerciseId, variantId);
    },
    enabled: !!exerciseId,
    staleTime: 5 * 60 * 1000,
  });
}

// ─── Exercise: Volume Trend ───────────────────────────────────────────────────

/**
 * Weekly volume trend for a specific exercise.
 */
export function useExerciseVolumeTrend(exerciseId: string) {
  return useQuery({
    queryKey: ['analytics', 'exerciseVolumeTrend', exerciseId],
    queryFn: async () => {
      const sets = await fetchUserSets(undefined, exerciseId, 1000);
      return weeklyVolume(sets);
    },
    enabled: !!exerciseId,
    staleTime: 5 * 60 * 1000,
  });
}

// ─── Exercise: PR Table ───────────────────────────────────────────────────────

/**
 * PR records across rep ranges for a specific exercise.
 */
export function useExercisePRs(exerciseId: string) {
  return useQuery({
    queryKey: ['analytics', 'exercisePRs', exerciseId],
    queryFn: async () => {
      const sets = await fetchUserSets(undefined, exerciseId, 1000);
      return exercisePRs(sets, exerciseId);
    },
    enabled: !!exerciseId,
    staleTime: 5 * 60 * 1000,
  });
}

// ─── Exercise: History ────────────────────────────────────────────────────────

export interface ExerciseHistorySet extends WorkoutSet {
  variantName: string | null;
}

/**
 * All sets for a specific exercise, newest first. Supports optional variant filter.
 * Data returned as pages of 50.
 */
export function useExerciseHistory(exerciseId: string, variantId?: string | null) {
  return useQuery<ExerciseHistorySet[]>({
    queryKey: ['analytics', 'exerciseHistory', exerciseId, variantId ?? 'all'],
    queryFn: async () => {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) return [];

      let query = supabase
        .from('sets')
        .select('*')
        .eq('user_id', user.id)
        .eq('exercise_id', exerciseId)
        .order('logged_at', { ascending: false })
        .limit(200);

      if (variantId !== undefined && variantId !== null) {
        query = query.eq('variant_id', variantId);
      }

      const { data: sets, error } = await query;
      if (error) throw error;
      if (!sets || sets.length === 0) return [];

      // Fetch variant names
      const variantIds = [...new Set(sets.map((s) => s.variant_id).filter(Boolean))];
      let variantNameMap = new Map<string, string>();

      if (variantIds.length > 0) {
        const { data: variants } = await supabase
          .from('equipment_variants')
          .select('id, name')
          .in('id', variantIds);

        if (variants) {
          variantNameMap = new Map(variants.map((v) => [v.id, v.name]));
        }
      }

      return (sets as WorkoutSet[]).map((s) => ({
        ...s,
        variantName: s.variant_id ? (variantNameMap.get(s.variant_id) ?? null) : null,
      }));
    },
    enabled: !!exerciseId,
    staleTime: 2 * 60 * 1000,
  });
}
