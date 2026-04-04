import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { useAuthStore } from '@/stores/authStore';
import type { WorkoutSet, Exercise } from '@/types/database';
import { suggestProgression, type ProgressionSuggestion } from '@/utils/progressiveOverload';

// ─── Constants ─────────────────────────────────────────────────────────────────

/** Number of past sessions to fetch for the progression calculation */
const SESSION_LOOKBACK = 4;

/** Approximate days to cover SESSION_LOOKBACK sessions (generous upper bound) */
const LOOKBACK_DAYS = SESSION_LOOKBACK * 7 + 7;

// ─── Helpers ──────────────────────────────────────────────────────────────────

/**
 * Identify the N most-recent distinct session dates for a set list.
 * A "session" is a calendar date (YYYY-MM-DD).
 */
function lastNSessionDates(sets: WorkoutSet[], n: number): Set<string> {
  const dates = new Set<string>();
  const sorted = [...sets].sort(
    (a, b) => new Date(b.logged_at).getTime() - new Date(a.logged_at).getTime(),
  );
  for (const s of sorted) {
    dates.add(s.logged_at.slice(0, 10));
    if (dates.size >= n) break;
  }
  return dates;
}

// ─── Hook ─────────────────────────────────────────────────────────────────────

export interface UseProgressionReturn {
  suggestion: ProgressionSuggestion | null;
  isLoading: boolean;
  isError: boolean;
}

/**
 * Fetch the last 3-4 sessions for an exercise+variant and compute a weight
 * progression suggestion using the deterministic overload engine.
 *
 * The hook is lightweight — it only queries the sets needed for the suggestion,
 * not the entire history.
 */
export function useProgression(
  exerciseId: string,
  variantId: string | null,
): UseProgressionReturn {
  const result = useQuery<ProgressionSuggestion>({
    queryKey: ['progression', exerciseId, variantId ?? 'none'],
    queryFn: async (): Promise<ProgressionSuggestion> => {
      const user = useAuthStore.getState().user;

      if (!user) {
        return suggestProgression([], 7.5, '');
      }

      // ── Fetch recent sets ───────────────────────────────────────────────────
      const cutoff = new Date();
      cutoff.setDate(cutoff.getDate() - LOOKBACK_DAYS);

      let setsQuery = supabase
        .from('sets')
        .select('*')
        .eq('user_id', user.id)
        .eq('exercise_id', exerciseId)
        .gte('logged_at', cutoff.toISOString())
        .order('logged_at', { ascending: false });

      if (variantId !== null) {
        setsQuery = setsQuery.eq('variant_id', variantId);
      } else {
        setsQuery = setsQuery.is('variant_id', null);
      }

      const { data: rawSets, error: setsError } = await setsQuery;
      if (setsError) throw setsError;

      const allSets = (rawSets ?? []) as WorkoutSet[];

      // Trim to the last SESSION_LOOKBACK distinct dates
      const sessionDates = lastNSessionDates(allSets, SESSION_LOOKBACK);
      const recentSets = allSets.filter((s) => sessionDates.has(s.logged_at.slice(0, 10)));

      // ── Fetch exercise category for increment logic ─────────────────────────
      const { data: exerciseData, error: exErr } = await supabase
        .from('exercises')
        .select('category')
        .eq('id', exerciseId)
        .maybeSingle();
      if (exErr) throw exErr;

      const category = (exerciseData as Pick<Exercise, 'category'> | null)?.category ?? '';

      return suggestProgression(recentSets, 7.5, category ?? '');
    },
    enabled: !!exerciseId,
    staleTime: 5 * 60 * 1000, // 5 minutes — doesn't change often mid-session
  });

  return {
    suggestion: result.data ?? null,
    isLoading: result.isLoading,
    isError: result.isError,
  };
}
