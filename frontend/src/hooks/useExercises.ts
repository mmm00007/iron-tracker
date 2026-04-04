import { useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { useAuthStore } from '@/stores/authStore';
import type { Exercise, MuscleGroup } from '@/types/database';

export interface ExerciseWithLastSet extends Exercise {
  lastWeight?: number;
  lastReps?: number;
  lastWeightUnit?: string;
  lastLoggedAt?: string;
}

export interface ExerciseMuscleEntry {
  muscle_group_id: number;
  is_primary: boolean;
  activation_percent: number | null;
}

export interface ExerciseWithMuscles extends Exercise {
  exercise_muscles: ExerciseMuscleEntry[];
}

export function useExercises() {
  return useQuery<ExerciseWithMuscles[]>({
    queryKey: ['exercises'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('exercises')
        .select('*, exercise_muscles(muscle_group_id, is_primary, activation_percent)')
        .order('name', { ascending: true });

      if (error) throw error;
      return (data ?? []) as ExerciseWithMuscles[];
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
  const queryClient = useQueryClient();

  return useQuery<ExerciseWithMuscles[]>({
    queryKey: ['exercises', 'search', query],
    queryFn: async () => {
      const trimmed = query.trim();
      if (!trimmed) return [];

      // Ensure the exercises cache is populated (fetchQuery is a no-op if fresh)
      let cached = queryClient.getQueryData<ExerciseWithMuscles[]>(['exercises']);
      if (!cached || cached.length === 0) {
        cached = await queryClient.fetchQuery({
          queryKey: ['exercises'],
          queryFn: async () => {
            const { data, error } = await supabase
              .from('exercises')
              .select('*, exercise_muscles(muscle_group_id, is_primary, activation_percent)')
              .order('name', { ascending: true });
            if (error) throw error;
            return (data ?? []) as ExerciseWithMuscles[];
          },
        });
      }

      const lower = trimmed.toLowerCase();
      const results = (cached ?? [])
        .filter((e) =>
          e.name.toLowerCase().includes(lower) ||
          e.aliases?.some((a) => a.toLowerCase().includes(lower)) ||
          e.exercise_type?.includes(lower) ||
          e.movement_pattern?.replace(/_/g, ' ').includes(lower)
        )
        .slice(0, 50);
      return results;
    },
    enabled: query.trim().length > 0,
    staleTime: Infinity, // derived from cached exercise list — no expiry needed
  });
}

export function useRecentExercises() {
  return useQuery<ExerciseWithLastSet[]>({
    queryKey: ['exercises', 'recent'],
    queryFn: async () => {
      const user = useAuthStore.getState().user;

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
          if (!lastSet) return null;
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

export interface ExerciseSubstitution {
  id: string;
  target_exercise_id: string;
  substitution_type: 'same_pattern' | 'same_muscles' | 'regression' | 'progression';
  similarity_score: number;
  progression_order: number | null;
  notes: string | null;
  target_exercise: { id: string; name: string; equipment: string | null; level: string | null };
}

export function useExerciseSubstitutions(exerciseId: string | null) {
  return useQuery<ExerciseSubstitution[]>({
    queryKey: ['exercise-substitutions', exerciseId],
    queryFn: async () => {
      if (!exerciseId) return [];
      const { data, error } = await supabase
        .from('exercise_substitutions')
        .select('id, target_exercise_id, substitution_type, similarity_score, progression_order, notes, target_exercise:exercises!target_exercise_id(id, name, equipment, level)')
        .eq('source_exercise_id', exerciseId)
        .order('substitution_type')
        .order('similarity_score', { ascending: false });
      if (error) throw error;
      return (data ?? []) as unknown as ExerciseSubstitution[];
    },
    enabled: !!exerciseId,
    staleTime: 10 * 60 * 1000,
  });
}
