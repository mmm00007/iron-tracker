import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import type { WorkoutSet } from '@/types/database';
import { useOfflineStore } from '@/stores/offlineStore';
import { useAuthStore } from '@/stores/authStore';

type NewSet = Omit<WorkoutSet, 'id' | 'synced_at' | 'estimated_1rm' | 'tempo' | 'rir' | 'updated_at' | 'duration_seconds' | 'distance_meters' | 'distance_unit' | 'training_date' | 'side' | 'rest_seconds' | 'workout_cluster_id'>;

/**
 * Compute the start of the "training day" based on the user's day_start_hour.
 * If current time is before dayStartHour, the training day started yesterday at that hour.
 * E.g. with dayStartHour=4, at 2:00 AM the training day started yesterday at 4:00 AM.
 */
function trainingDayStart(dayStartHour: number): Date {
  const now = new Date();
  const start = new Date(now);
  start.setHours(dayStartHour, 0, 0, 0);
  if (now < start) {
    // Before the boundary — training day started yesterday
    start.setDate(start.getDate() - 1);
  }
  return start;
}

/** Query key helpers */
const todaySetsKey = (exerciseId: string) => ['sets', 'today', exerciseId];
const lastSetKey = (exerciseId: string, variantId: string | null) => [
  'sets',
  'last',
  exerciseId,
  variantId ?? 'none',
];

/**
 * Fetch all sets logged in the current training day for a given exercise.
 * Uses the user's day_start_hour to define when the training day begins
 * (default 4 AM — so a 1 AM session still shows under "today").
 */
export function useTodaySets(exerciseId: string, dayStartHour = 4) {
  return useQuery<WorkoutSet[]>({
    queryKey: todaySetsKey(exerciseId),
    queryFn: async () => {
      const user = useAuthStore.getState().user;
      if (!user) return [];

      const cutoff = trainingDayStart(dayStartHour);

      const { data, error } = await supabase
        .from('sets')
        .select('*')
        .eq('user_id', user.id)
        .eq('exercise_id', exerciseId)
        .gte('logged_at', cutoff.toISOString())
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
      const user = useAuthStore.getState().user;
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
 * Runs offline-first: the optimistic update is shown immediately and the Supabase
 * insert is retried automatically once the device comes back online.
 */
export function useLogSet() {
  const queryClient = useQueryClient();
  const { incrementPending, decrementPending, setLastSync } = useOfflineStore.getState();

  return useMutation({
    // Queue the mutation while offline; retry up to 3× with exponential backoff
    networkMode: 'offlineFirst',

    mutationFn: async (newSet: NewSet) => {
      // Strip user_id — let Supabase DEFAULT auth.uid() set it server-side.
      // Defense-in-depth: prevents attribution to other users if RLS is ever misconfigured.
      const { user_id: _dropped, ...safeSet } = newSet;
      const { data, error } = await supabase.from('sets').insert(safeSet).select().single();
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
        id: crypto.randomUUID(),
        synced_at: null,
        estimated_1rm: null,
        tempo: null,
        rir: null,
        updated_at: new Date().toISOString(),
        duration_seconds: null,
        distance_meters: null,
        distance_unit: null,
        training_date: null,
        side: null,
        rest_seconds: null,
        workout_cluster_id: null,
      };

      queryClient.setQueryData<WorkoutSet[]>(key, (old) => [optimisticSet, ...(old ?? [])]);
      incrementPending();

      return { previousSets };
    },

    onError: (_err, newSet, context) => {
      if (context?.previousSets !== undefined) {
        queryClient.setQueryData(todaySetsKey(newSet.exercise_id), context.previousSets);
      }
    },

    onSuccess: () => {
      setLastSync(new Date());
    },

    onSettled: (_data, _err, newSet) => {
      // Decrement pending only in onSettled (called once per mutation lifecycle)
      // to prevent counter drift when retries trigger multiple onError + final onSuccess
      decrementPending();
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
 * Update a set's weight and/or reps with optimistic update.
 * Used for inline editing of recently logged sets.
 */
export function useUpdateSet() {
  const queryClient = useQueryClient();
  const user = useAuthStore((s) => s.user);

  return useMutation({
    mutationFn: async ({
      setId,
      updates,
    }: {
      setId: string;
      exerciseId: string;
      updates: { weight?: number; reps?: number };
    }) => {
      if (!user) throw new Error('Not authenticated');
      const { data, error } = await supabase
        .from('sets')
        .update({ ...updates, updated_at: new Date().toISOString() })
        .eq('id', setId)
        .eq('user_id', user.id)
        .select()
        .single();
      if (error) throw error;
      return data as WorkoutSet;
    },

    onMutate: async ({ setId, exerciseId, updates }) => {
      const key = todaySetsKey(exerciseId);
      await queryClient.cancelQueries({ queryKey: key });

      const previousSets = queryClient.getQueryData<WorkoutSet[]>(key);

      queryClient.setQueryData<WorkoutSet[]>(key, (old) =>
        (old ?? []).map((s) => (s.id === setId ? { ...s, ...updates } : s)),
      );

      return { previousSets };
    },

    onError: (_err, { exerciseId }, context) => {
      if (context?.previousSets !== undefined) {
        queryClient.setQueryData(todaySetsKey(exerciseId), context.previousSets);
      }
    },

    onSettled: (data, _err, { exerciseId }) => {
      // Sync conflict resolution: if server returned a different updated_at than
      // what we had, the server version wins (last-write-wins).
      if (data) {
        queryClient.setQueryData<WorkoutSet[]>(todaySetsKey(exerciseId), (old) =>
          (old ?? []).map((s) => (s.id === data.id ? data : s)),
        );
      }
      void queryClient.invalidateQueries({ queryKey: todaySetsKey(exerciseId) });
    },
  });
}

/**
 * Delete a set with optimistic update.
 */
export function useDeleteSet() {
  const queryClient = useQueryClient();
  const user = useAuthStore((s) => s.user);

  return useMutation({
    mutationFn: async ({ setId }: { setId: string; exerciseId: string }) => {
      if (!user) throw new Error('Not authenticated');
      const { error } = await supabase.from('sets').delete().eq('id', setId).eq('user_id', user.id);
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
