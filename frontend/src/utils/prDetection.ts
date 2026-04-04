import type { PersonalRecord } from '@/types/database';
import { computeE1RM } from '@/utils/analytics';

// Re-export so consumers can import from here without knowing analytics.ts
export { computeE1RM };

// ─── Types ─────────────────────────────────────────────────────────────────────

export interface PRRecord {
  type: 'estimated_1rm' | 'rep_max' | 'max_weight' | 'max_volume';
  repCount?: number; // only set for rep_max type
  newValue: number;
  previousValue: number | null;
}

export interface PRCheckResult {
  isPR: boolean;
  records: PRRecord[];
}

/** Rep counts for rep_max PR tracking */
const REP_MAX_COUNTS = [1, 3, 5, 8, 10] as const;

/** Windowed rep ranges — matches exercisePRs() in analytics.ts */
const REP_WINDOWS: Record<number, [number, number]> = {
  1: [1, 1],
  3: [2, 3],
  5: [4, 5],
  8: [6, 8],
  10: [9, 12],
};

// ─── Core check ────────────────────────────────────────────────────────────────

/**
 * Check whether a newly logged set breaks any personal records.
 *
 * Comparisons are against `existingPRs` which should be pre-filtered to the
 * same (exerciseId, variantId) pair — the caller is responsible for filtering.
 *
 * @param newSet   The set that was just logged
 * @param existingPRs  Existing PersonalRecord rows for this exercise+variant
 * @returns PRCheckResult with isPR flag and detailed record breakdown
 */
export function checkForPRs(
  newSet: {
    weight: number;
    reps: number;
    exerciseId: string;
    variantId: string | null;
  },
  existingPRs: PersonalRecord[],
): PRCheckResult {
  const records: PRRecord[] = [];

  if (newSet.weight <= 0 || newSet.reps <= 0) {
    return { isPR: false, records: [] };
  }

  // ── Helper: find the best existing value for a given type + optional repCount ──
  function findExisting(
    type: PersonalRecord['record_type'],
    repCount?: number,
  ): number | null {
    const match = existingPRs.find(
      (pr) =>
        pr.record_type === type &&
        (repCount === undefined ? true : pr.rep_count === repCount),
    );
    return match ? match.value : null;
  }

  // ── 1. Estimated 1RM ──────────────────────────────────────────────────────────
  const newE1RM = computeE1RM(newSet.weight, newSet.reps);
  if (newE1RM > 0) {
    const prevE1RM = findExisting('estimated_1rm');
    if (prevE1RM === null || newE1RM > prevE1RM) {
      records.push({
        type: 'estimated_1rm',
        newValue: newE1RM,
        previousValue: prevE1RM,
      });
    }
  }

  // ── 2. Rep-max at specific rep counts ─────────────────────────────────────────
  for (const repCount of REP_MAX_COUNTS) {
    // Windowed rep ranges — a set must fall within the bucket's range.
    // E.g., 5RM bucket only accepts 4-5 rep sets. Prevents 1RM from
    // dominating all buckets. Matches exercisePRs() in analytics.ts.
    const window = REP_WINDOWS[repCount];
    if (!window) continue;
    const [minReps, maxReps] = window;
    if (newSet.reps >= minReps && newSet.reps <= maxReps) {
      const prevRepMax = findExisting('rep_max', repCount);
      if (prevRepMax === null || newSet.weight > prevRepMax) {
        records.push({
          type: 'rep_max',
          repCount,
          newValue: newSet.weight,
          previousValue: prevRepMax,
        });
      }
    }
  }

  // ── 3. Max weight (any rep count) ─────────────────────────────────────────────
  const prevMaxWeight = findExisting('max_weight');
  if (prevMaxWeight === null || newSet.weight > prevMaxWeight) {
    records.push({
      type: 'max_weight',
      newValue: newSet.weight,
      previousValue: prevMaxWeight,
    });
  }

  // ── 4. Max volume (weight × reps, single set) ─────────────────────────────────
  const newVolume = newSet.weight * newSet.reps;
  const prevMaxVolume = findExisting('max_volume');
  if (prevMaxVolume === null || newVolume > prevMaxVolume) {
    records.push({
      type: 'max_volume',
      newValue: newVolume,
      previousValue: prevMaxVolume,
    });
  }

  return {
    isPR: records.length > 0,
    records,
  };
}

// ─── Utility: build PersonalRecord rows from a PRCheckResult ──────────────────

/**
 * Convert a PRCheckResult into PersonalRecord-shaped objects ready for upsert.
 * The caller must supply ids, user_id, set_id, achieved_at, exercise_id, variant_id.
 */
export function buildPRRows(
  result: PRCheckResult,
  context: {
    userId: string;
    exerciseId: string;
    variantId: string | null;
    setId: string;
    achievedAt: string;
  },
): Omit<PersonalRecord, 'id'>[] {
  return result.records.map((rec) => ({
    user_id: context.userId,
    exercise_id: context.exerciseId,
    variant_id: context.variantId,
    record_type: rec.type,
    rep_count: rec.repCount ?? null,
    value: rec.newValue,
    set_id: context.setId,
    achieved_at: context.achievedAt,
  }));
}

// ─── Utility: filter PRs to sets for a given exercise+variant ─────────────────

/**
 * Filter a list of PersonalRecord rows to those matching an (exerciseId, variantId) pair.
 * Pass this result to checkForPRs.
 */
export function filterPRsForExercise(
  prs: PersonalRecord[],
  exerciseId: string,
  variantId: string | null,
): PersonalRecord[] {
  return prs.filter(
    (pr) =>
      pr.exercise_id === exerciseId &&
      (variantId === null ? pr.variant_id === null : pr.variant_id === variantId),
  );
}

// ─── Utility: human-readable PR label ─────────────────────────────────────────

/**
 * Returns a short human-readable label for a PR record type.
 */
export function prLabel(record: PRRecord): string {
  switch (record.type) {
    case 'estimated_1rm':
      return `New Est. 1RM — ${record.newValue.toFixed(1)}`;
    case 'rep_max':
      return `New ${record.repCount}RM — ${record.newValue}`;
    case 'max_weight':
      return `New Max Weight — ${record.newValue}`;
    case 'max_volume':
      return `New Max Volume — ${record.newValue.toFixed(1)}`;
  }
}
