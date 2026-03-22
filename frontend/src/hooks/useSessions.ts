import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import type { WorkoutSet } from '@/types/database';
import { groupSetsIntoSessions } from '@/utils/sessionGrouping';
import type { SessionGroup } from '@/utils/sessionGrouping';

/** How many sets to fetch per page when deriving sessions */
const SETS_PER_PAGE = 500;

interface SetWithExerciseName extends WorkoutSet {
  exerciseName?: string;
}

/**
 * Fetch sets joined with exercises and return them with exercise name attached.
 */
async function fetchSetsWithNames(
  userId: string,
  page: number,
): Promise<SetWithExerciseName[]> {
  const from = page * SETS_PER_PAGE;
  const to = from + SETS_PER_PAGE - 1;

  const { data, error } = await supabase
    .from('sets')
    .select('*, exercises(name)')
    .eq('user_id', userId)
    .order('logged_at', { ascending: false })
    .range(from, to);

  if (error) throw error;
  if (!data) return [];

  return data.map((row) => {
    // Supabase returns joined relation as nested object
    const exerciseName =
      row.exercises && typeof row.exercises === 'object' && 'name' in row.exercises
        ? (row.exercises as { name: string }).name
        : undefined;

    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { exercises: _exercises, ...setFields } = row as typeof row & { exercises: unknown };

    return {
      ...(setFields as WorkoutSet),
      exerciseName,
    };
  });
}

/**
 * Fetch all sessions (derived from sets) for the current user, paginated.
 *
 * Sessions are grouped client-side using the 90-minute inactivity gap rule.
 * Returns sessions sorted newest first.
 */
export function useSessions(page = 0) {
  return useQuery<SessionGroup[]>({
    queryKey: ['sessions', page],
    queryFn: async () => {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) return [];

      const sets = await fetchSetsWithNames(user.id, page);
      return groupSetsIntoSessions(sets);
    },
    staleTime: 60 * 1000,
  });
}

/**
 * Fetch all sets belonging to a specific session (defined by its time range).
 * Used by SessionDetailPage to show the full set list.
 */
export function useSessionSets(startedAt: string, endedAt: string) {
  return useQuery<SetWithExerciseName[]>({
    queryKey: ['session-sets', startedAt, endedAt],
    queryFn: async () => {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) return [];

      const { data, error } = await supabase
        .from('sets')
        .select('*, exercises(name)')
        .eq('user_id', user.id)
        .gte('logged_at', startedAt)
        .lte('logged_at', endedAt)
        .order('logged_at', { ascending: true });

      if (error) throw error;
      if (!data) return [];

      return data.map((row) => {
        const exerciseName =
          row.exercises && typeof row.exercises === 'object' && 'name' in row.exercises
            ? (row.exercises as { name: string }).name
            : undefined;

        // eslint-disable-next-line @typescript-eslint/no-unused-vars
        const { exercises: _exercises, ...setFields } = row as typeof row & { exercises: unknown };

        return {
          ...(setFields as WorkoutSet),
          exerciseName,
        };
      });
    },
    enabled: !!startedAt && !!endedAt,
    staleTime: 60 * 1000,
  });
}
