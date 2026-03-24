import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';

interface SessionName {
  id: string;
  session_start: string;
  session_end: string;
  name: string;
}

const sessionNameKey = (sessionStart: string) => ['session-name', sessionStart];
const allSessionNamesKey = () => ['session-names'];

/**
 * Fetch the custom name for a specific session (by start time).
 */
export function useSessionName(sessionStart: string | undefined) {
  return useQuery<SessionName | null>({
    queryKey: sessionNameKey(sessionStart ?? ''),
    queryFn: async () => {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user || !sessionStart) return null;

      const { data, error } = await supabase
        .from('user_session_names')
        .select('*')
        .eq('user_id', user.id)
        .eq('session_start', sessionStart)
        .maybeSingle();

      if (error) throw error;
      return (data as SessionName) ?? null;
    },
    enabled: !!sessionStart,
    staleTime: 5 * 60 * 1000,
  });
}

/**
 * Fetch all session names for the current user (for the session list).
 * Returns a Map keyed by session_start for O(1) lookup.
 */
export function useAllSessionNames() {
  return useQuery<Map<string, string>>({
    queryKey: allSessionNamesKey(),
    queryFn: async () => {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) return new Map();

      const { data, error } = await supabase
        .from('user_session_names')
        .select('session_start, name')
        .eq('user_id', user.id);

      if (error) throw error;
      const map = new Map<string, string>();
      for (const row of data ?? []) {
        map.set(row.session_start, row.name);
      }
      return map;
    },
    staleTime: 5 * 60 * 1000,
  });
}

/**
 * Upsert a session name (create or update).
 */
export function useRenameSession() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({
      sessionStart,
      sessionEnd,
      name,
    }: {
      sessionStart: string;
      sessionEnd: string;
      name: string;
    }) => {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) throw new Error('Not authenticated');

      const { error } = await supabase.from('user_session_names').upsert(
        {
          user_id: user.id,
          session_start: sessionStart,
          session_end: sessionEnd,
          name,
        },
        { onConflict: 'user_id,session_start' },
      );

      if (error) throw error;
    },

    onSuccess: (_data, { sessionStart }) => {
      void queryClient.invalidateQueries({ queryKey: sessionNameKey(sessionStart) });
      void queryClient.invalidateQueries({ queryKey: allSessionNamesKey() });
    },
  });
}
