import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import type { WorkoutSet } from '@/types/database';

type NewSet = Omit<WorkoutSet, 'id' | 'synced_at' | 'estimated_1rm' | 'tempo' | 'rir'>;

/** Query key helpers */
const todaySetsKey = (exerciseId: string) => ['sets', 'today', exerciseId];
const lastSetKey = (exerciseId: string, variantId: string | null) => [
  'sets',
  'last',
  exerciseId,
  variantId ?? 'none',
];

/**
 * Fetch all sets logged today for a given exercise.
 */
export function useTodaySets(exerciseId: string) {
  return useQuery<WorkoutSet[]>({
    queryKey: todaySetsKey(exerciseId),
    queryFn: async () => {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) return [];

      // Start of today in UTC
      const todayStart = new Date();
      todayStart.setHours(0, 0, 0, 0);

      const { data, error } = await supabase
        .from('sets')
        .select('*')
        .eq('user_id', user.id)
        .eq('exercise_id', exerciseId)
        .gte('logged_at', todayStart.toISOString())
        .order('logged_at', { ascending: false });

      if (error) throw error;
      return (data ?? []) as WorkoutSet[];
    },
    enabled: !!exerciseId,
    staleTime: 0, // Always fresh for session logging
  });
}

/**
 * Fetch the most recent set for a given exercise + optional variant (for pre-fill).
 */
export function useLastSet(exerciseId: string, variantId: string | null) {
  return useQuery<WorkoutSet | null>({
    queryKey: lastSetKey(exerciseId, variantId),
    queryFn: async () => {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) return null;

      let query = supabase
        .from('sets')
        .select('*')
        .eq('user_id', user.id)
        .eq('exercise_id', exerciseId)
        .order('logged_at', { ascending: false })
        .limit(1);

      if (variantId) {
        query = query.eq('variant_id', variantId);
      } else {
        query = query.is('variant_id', null);
      }

      const { data, error } = await query.maybeSingle();
      if (error) throw error;
      return (data as WorkoutSet) ?? null;
    },
    enabled: !!exerciseId,
    staleTime: 60 * 1000,
  });
}

/**
 * Log a new set with optimistic update.
 */
export function useLogSet() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (newSet: NewSet) => {
      const { data, error } = await supabase.from('sets').insert(newSet).select().single();
      if (error) throw error;
      return data as WorkoutSet;
    },

    onMutate: async (newSet) => {
      const key = todaySetsKey(newSet.exercise_id);
      await queryClient.cancelQueries({ queryKey: key });

      const previousSets = queryClient.getQueryData<WorkoutSet[]>(key);

      // Optimistic placeholder — real id provided after server response
      const optimisticSet: WorkoutSet = {
        ...newSet,
        id: `optimistic-${Date.now()}`,
        synced_at: null,
        estimated_1rm: null,
        tempo: null,
        rir: null,
      };

      queryClient.setQueryData<WorkoutSet[]>(key, (old) => [optimisticSet, ...(old ?? [])]);

      return { previousSets };
    },

    onError: (_err, newSet, context) => {
      if (context?.previousSets !== undefined) {
        queryClient.setQueryData(todaySetsKey(newSet.exercise_id), context.previousSets);
      }
    },

    onSettled: (_data, _err, newSet) => {
      void queryClient.invalidateQueries({ queryKey: todaySetsKey(newSet.exercise_id) });
      void queryClient.invalidateQueries({
        queryKey: lastSetKey(newSet.exercise_id, newSet.variant_id),
      });
      // Also invalidate recent exercises list
      void queryClient.invalidateQueries({ queryKey: ['exercises', 'recent'] });
    },
  });
}

/**
 * Delete a set with optimistic update.
 */
export function useDeleteSet() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ setId }: { setId: string; exerciseId: string }) => {
      const { error } = await supabase.from('sets').delete().eq('id', setId);
      if (error) throw error;
    },

    onMutate: async ({ setId, exerciseId }) => {
      const key = todaySetsKey(exerciseId);
      await queryClient.cancelQueries({ queryKey: key });

      const previousSets = queryClient.getQueryData<WorkoutSet[]>(key);

      queryClient.setQueryData<WorkoutSet[]>(key, (old) =>
        (old ?? []).filter((s) => s.id !== setId),
      );

      return { previousSets };
    },

    onError: (_err, { exerciseId }, context) => {
      if (context?.previousSets !== undefined) {
        queryClient.setQueryData(todaySetsKey(exerciseId), context.previousSets);
      }
    },

    onSettled: (_data, _err, { exerciseId }) => {
      void queryClient.invalidateQueries({ queryKey: todaySetsKey(exerciseId) });
    },
  });
}
