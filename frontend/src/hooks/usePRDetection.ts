import { useCallback, useState } from 'react';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { useAuthStore } from '@/stores/authStore';
import type { PersonalRecord, WorkoutSet } from '@/types/database';
import {
  checkForPRs,
  buildPRRows,
  filterPRsForExercise,
  type PRCheckResult,
} from '@/utils/prDetection';

// ─── Query key helper ─────────────────────────────────────────────────────────

const prQueryKey = (exerciseId: string, variantId: string | null) => [
  'personal_records',
  exerciseId,
  variantId ?? 'none',
];

// ─── Fetch PRs from Supabase ──────────────────────────────────────────────────

async function fetchPRs(exerciseId: string, variantId: string | null): Promise<PersonalRecord[]> {
  const user = useAuthStore.getState().user;
  if (!user) return [];

  let query = supabase
    .from('personal_records')
    .select('*')
    .eq('user_id', user.id)
    .eq('exercise_id', exerciseId);

  if (variantId !== null) {
    query = query.eq('variant_id', variantId);
  } else {
    query = query.is('variant_id', null);
  }

  const { data, error } = await query;
  if (error) throw error;
  return (data ?? []) as PersonalRecord[];
}

// ─── Save PRs to Supabase ─────────────────────────────────────────────────────

async function savePRs(
  prResult: PRCheckResult,
  context: {
    userId: string;
    exerciseId: string;
    variantId: string | null;
    setId: string;
    achievedAt: string;
  },
): Promise<void> {
  if (!prResult.isPR) return;

  const rows = buildPRRows(prResult, context);

  // Upsert: if a record of the same type + rep_count already exists, overwrite it
  // We rely on the DB unique constraint (user_id, exercise_id, variant_id, record_type, rep_count)
  const { error } = await supabase
    .from('personal_records')
    .upsert(rows, {
      onConflict: 'user_id,exercise_id,variant_id,record_type,rep_count',
      ignoreDuplicates: false,
    });

  if (error) throw error;
}

// ─── Hook ─────────────────────────────────────────────────────────────────────

export interface UsePRDetectionReturn {
  /** Call this after a set is successfully saved to check and store any PRs */
  checkAndSavePRs: (set: WorkoutSet) => Promise<PRCheckResult>;
  /** The latest PRCheckResult — populated after checkAndSavePRs runs */
  latestPRResult: PRCheckResult | null;
  /** Clear the latest result (e.g. after the celebration overlay is dismissed) */
  clearPRResult: () => void;
  /** Whether existing PRs are still loading */
  isLoadingPRs: boolean;
}

/**
 * Hook that integrates PR detection into the set-logging flow.
 *
 * Usage:
 * ```tsx
 * const { checkAndSavePRs, latestPRResult, clearPRResult } = usePRDetection(exerciseId, variantId);
 *
 * // after logging a set:
 * const result = await checkAndSavePRs(savedSet);
 * // latestPRResult is now populated and can drive the PRCelebration overlay
 * ```
 */
export function usePRDetection(
  exerciseId: string,
  variantId: string | null,
): UsePRDetectionReturn {
  const queryClient = useQueryClient();
  const [latestPRResult, setLatestPRResult] = useState<PRCheckResult | null>(null);

  // Pre-fetch existing PRs so the check is instant after a set is logged
  const { data: existingPRs = [], isLoading: isLoadingPRs } = useQuery<PersonalRecord[]>({
    queryKey: prQueryKey(exerciseId, variantId),
    queryFn: () => fetchPRs(exerciseId, variantId),
    enabled: !!exerciseId,
    staleTime: 60 * 1000, // 1 minute — PRs rarely change mid-session
  });

  const checkAndSavePRs = useCallback(
    async (set: WorkoutSet): Promise<PRCheckResult> => {
      const user = useAuthStore.getState().user;

      // Filter to the right exercise+variant (defensive, should already be filtered)
      const relevantPRs = filterPRsForExercise(existingPRs, exerciseId, variantId);

      const result = checkForPRs(
        {
          weight: set.weight,
          reps: set.reps,
          exerciseId: set.exercise_id,
          variantId: set.variant_id,
        },
        relevantPRs,
      );

      if (result.isPR && user) {
        try {
          const prRows = buildPRRows(result, {
            userId: user.id,
            exerciseId: set.exercise_id,
            variantId: set.variant_id,
            setId: set.id,
            achievedAt: set.logged_at,
          });

          await savePRs(result, {
            userId: user.id,
            exerciseId: set.exercise_id,
            variantId: set.variant_id,
            setId: set.id,
            achievedAt: set.logged_at,
          });

          // Optimistically update the local PR cache so rapid back-to-back
          // set logs see the freshly saved PR instead of a stale closure value.
          queryClient.setQueryData<PersonalRecord[]>(
            prQueryKey(exerciseId, variantId),
            (old = []) => {
              const updated = [...old];
              for (const row of prRows) {
                const idx = updated.findIndex(
                  (pr) =>
                    pr.record_type === row.record_type &&
                    pr.rep_count === row.rep_count,
                );
                if (idx >= 0) {
                  updated[idx] = { ...updated[idx]!, ...row } as PersonalRecord;
                } else {
                  updated.push(row as PersonalRecord);
                }
              }
              return updated;
            },
          );

          // Background refetch to sync with server
          void queryClient.invalidateQueries({
            queryKey: prQueryKey(exerciseId, variantId),
          });
          void queryClient.invalidateQueries({ queryKey: ['analytics', 'recentPRs'] });
        } catch (err) {
          // Non-fatal: PR detection succeeded but save failed
          console.error('[usePRDetection] Failed to save PR:', err);
        }
      }

      setLatestPRResult(result);
      return result;
    },
    [existingPRs, exerciseId, variantId, queryClient],
  );

  const clearPRResult = useCallback(() => {
    setLatestPRResult(null);
  }, []);

  return {
    checkAndSavePRs,
    latestPRResult,
    clearPRResult,
    isLoadingPRs,
  };
}
