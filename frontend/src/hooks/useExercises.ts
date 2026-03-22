import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import type { Exercise, MuscleGroup } from '@/types/database';
import { useDebounce } from './useDebounce';

export interface ExerciseWithLastSet extends Exercise {
  lastWeight?: number;
  lastReps?: number;
  lastWeightUnit?: string;
  lastLoggedAt?: string;
}

export function useExercises() {
  return useQuery<Exercise[]>({
    queryKey: ['exercises'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('exercises')
        .select('*')
        .order('name', { ascending: true });

      if (error) throw error;
      return data ?? [];
    },
    staleTime: 10 * 60 * 1000, // 10 minutes — exercise catalog changes rarely
  });
}

export function useExercisesByMuscle(muscleGroupId: number) {
  return useQuery<Exercise[]>({
    queryKey: ['exercises', 'muscle', muscleGroupId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('exercises')
        .select('*, exercise_muscles!inner(muscle_group_id)')
        .eq('exercise_muscles.muscle_group_id', muscleGroupId)
        .order('name', { ascending: true });

      if (error) throw error;
      return data ?? [];
    },
    staleTime: 10 * 60 * 1000,
  });
}

export function useExerciseSearch(query: string) {
  const debouncedQuery = useDebounce(query, 200);

  return useQuery<Exercise[]>({
    queryKey: ['exercises', 'search', debouncedQuery],
    queryFn: async () => {
      if (!debouncedQuery.trim()) return [];

      const { data, error } = await supabase
        .from('exercises')
        .select('*')
        .ilike('name', `%${debouncedQuery.trim()}%`)
        .order('name', { ascending: true })
        .limit(50);

      if (error) throw error;
      return data ?? [];
    },
    enabled: debouncedQuery.trim().length > 0,
    staleTime: 2 * 60 * 1000,
  });
}

export function useRecentExercises() {
  return useQuery<ExerciseWithLastSet[]>({
    queryKey: ['exercises', 'recent'],
    queryFn: async () => {
      const {
        data: { user },
      } = await supabase.auth.getUser();

      if (!user) return [];

      // Fetch last 8 unique exercises from sets table with their most recent set data
      const { data: sets, error } = await supabase
        .from('sets')
        .select('exercise_id, weight, weight_unit, reps, logged_at')
        .eq('user_id', user.id)
        .order('logged_at', { ascending: false })
        .limit(100);

      if (error) throw error;
      if (!sets || sets.length === 0) return [];

      // Deduplicate: keep only the first (most recent) occurrence per exercise
      const seen = new Set<string>();
      const recentExerciseIds: string[] = [];
      const lastSetByExercise: Record<
        string,
        { weight: number; reps: number; weightUnit: string; loggedAt: string }
      > = {};

      for (const set of sets) {
        if (!seen.has(set.exercise_id)) {
          seen.add(set.exercise_id);
          recentExerciseIds.push(set.exercise_id);
          lastSetByExercise[set.exercise_id] = {
            weight: set.weight,
            reps: set.reps,
            weightUnit: set.weight_unit,
            loggedAt: set.logged_at,
          };
        }
        if (recentExerciseIds.length >= 8) break;
      }

      if (recentExerciseIds.length === 0) return [];

      const { data: exercises, error: exError } = await supabase
        .from('exercises')
        .select('*')
        .in('id', recentExerciseIds);

      if (exError) throw exError;
      if (!exercises) return [];

      // Sort exercises to match the order from sets (most recent first)
      const exerciseMap = new Map(exercises.map((e) => [e.id, e]));

      return recentExerciseIds
        .map((id) => {
          const exercise = exerciseMap.get(id);
          if (!exercise) return null;
          const lastSet = lastSetByExercise[id];
          return {
            ...exercise,
            lastWeight: lastSet.weight,
            lastReps: lastSet.reps,
            lastWeightUnit: lastSet.weightUnit,
            lastLoggedAt: lastSet.loggedAt,
          } as ExerciseWithLastSet;
        })
        .filter((e): e is ExerciseWithLastSet => e !== null);
    },
    staleTime: 60 * 1000, // 1 minute — recent exercises update more often
  });
}

export function useMuscleGroups() {
  return useQuery<MuscleGroup[]>({
    queryKey: ['muscleGroups'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('muscle_groups')
        .select('*')
        .order('name', { ascending: true });

      if (error) throw error;
      return data ?? [];
    },
    staleTime: 30 * 60 * 1000, // 30 minutes — muscle groups are static
  });
}
