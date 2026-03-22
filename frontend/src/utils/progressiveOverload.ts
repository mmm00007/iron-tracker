import type { WorkoutSet } from '@/types/database';
import { computeE1RM, isoWeek } from '@/utils/analytics';

// ─── Types ─────────────────────────────────────────────────────────────────────

export interface ProgressionSuggestion {
  suggestedWeight: number;
  suggestedReps: number;
  reasoning: string;
  confidence: 'high' | 'medium' | 'low';
}

// ─── Constants ─────────────────────────────────────────────────────────────────

/** Weight increment per step for compound lifts (kg) */
const COMPOUND_INCREMENT_KG = 2.5;

/** Weight increment per step for isolation lifts (kg) */
const ISOLATION_INCREMENT_KG = 1.25;

/**
 * Exercises whose category maps to "compound".
 * The exercise.category field from the DB is a string like "strength", "powerlifting", etc.
 */
const COMPOUND_CATEGORIES = new Set([
  'strength',
  'powerlifting',
  'olympic weightlifting',
  'compound',
]);

// ─── Helpers ──────────────────────────────────────────────────────────────────

/** Group sets by ISO week, returning weeks sorted oldest → newest */
function groupByWeek(sets: WorkoutSet[]): WorkoutSet[][] {
  const map = new Map<string, WorkoutSet[]>();
  for (const s of sets) {
    const week = isoWeek(new Date(s.logged_at));
    const bucket = map.get(week) ?? [];
    bucket.push(s);
    map.set(week, bucket);
  }
  return Array.from(map.entries())
    .sort((a, b) => a[0].localeCompare(b[0]))
    .map(([, sets]) => sets);
}

/** Average RPE for a collection of sets (ignoring nulls) */
function avgRpe(sets: WorkoutSet[]): number | null {
  const withRpe = sets.filter((s) => s.rpe !== null);
  if (withRpe.length === 0) return null;
  return withRpe.reduce((sum, s) => sum + (s.rpe ?? 0), 0) / withRpe.length;
}

/** Best e1RM in a set of sets */
function bestE1RM(sets: WorkoutSet[]): number {
  return sets.reduce((best, s) => {
    const e = computeE1RM(s.weight, s.reps);
    return e > best ? e : best;
  }, 0);
}

/** Round a weight to the nearest increment */
function roundToIncrement(weight: number, increment: number): number {
  return Math.round(weight / increment) * increment;
}

// ─── Main function ─────────────────────────────────────────────────────────────

/**
 * Suggest next weight and rep target based on recent performance history.
 *
 * @param recentSets       Last 3-4 sessions worth of sets for this exercise+variant
 * @param targetRpe        User's target RPE (default 7-8)
 * @param exerciseCategory The exercise.category string from the DB
 */
export function suggestProgression(
  recentSets: WorkoutSet[],
  targetRpe = 7.5,
  exerciseCategory = '',
): ProgressionSuggestion {
  const isCompound = COMPOUND_CATEGORIES.has(exerciseCategory.toLowerCase());
  const increment = isCompound ? COMPOUND_INCREMENT_KG : ISOLATION_INCREMENT_KG;

  // ── Not enough data ──────────────────────────────────────────────────────────
  if (recentSets.length === 0) {
    return {
      suggestedWeight: 0,
      suggestedReps: 8,
      reasoning: 'No previous data — start with a comfortable warm-up weight.',
      confidence: 'low',
    };
  }

  const weeks = groupByWeek(recentSets);

  if (weeks.length < 2) {
    // Single session — echo back the best working weight with low confidence
    const workingSets = recentSets.filter((s) => s.set_type === 'working');
    const referenceWeight =
      workingSets.length > 0
        ? Math.max(...workingSets.map((s) => s.weight))
        : Math.max(...recentSets.map((s) => s.weight));

    return {
      suggestedWeight: referenceWeight,
      suggestedReps: 8,
      reasoning: 'Only one session recorded — keep the same weight to establish a baseline.',
      confidence: 'low',
    };
  }

  // ── Pull the two most-recent session groups ──────────────────────────────────
  // weeks is guaranteed to have length >= 2 (checked above)
  const lastSessionSets: WorkoutSet[] = weeks[weeks.length - 1] ?? [];
  const prevSessionSets: WorkoutSet[] = weeks[weeks.length - 2] ?? [];

  const workingLast = lastSessionSets.filter((s) => s.set_type === 'working');
  const workingPrev = prevSessionSets.filter((s) => s.set_type === 'working');
  const workingRef: WorkoutSet[] = workingLast.length > 0 ? workingLast : lastSessionSets;
  const workingPrevRef: WorkoutSet[] = workingPrev.length > 0 ? workingPrev : prevSessionSets;

  const lastWeight = Math.max(...workingRef.map((s) => s.weight));
  const lastRpe = avgRpe(workingRef);
  const prevRpe = avgRpe(workingPrevRef);

  const lastE1RM = bestE1RM(workingRef);
  const prevE1RM = bestE1RM(workingPrevRef);

  // ── Determine trend over last 2 sessions ─────────────────────────────────────
  const e1rmDelta = lastE1RM - prevE1RM;
  const performanceDropping = e1rmDelta < 0 && Math.abs(e1rmDelta) > prevE1RM * 0.03;

  // Effective RPE for the last session (fall back to target if null)
  const effectiveLastRpe = lastRpe ?? targetRpe;
  const effectivePrevRpe = prevRpe ?? targetRpe;

  // Was the last session too easy (RPE ≤ target) across both sessions?
  const tooEasyBothSessions =
    effectiveLastRpe <= targetRpe && effectivePrevRpe <= targetRpe && !performanceDropping;

  // Was the last session too hard (RPE > target + 1)?
  const tooHardLastSession = effectiveLastRpe > targetRpe + 1;
  const tooHardBothSessions =
    effectiveLastRpe > targetRpe + 1 && effectivePrevRpe > targetRpe + 1;

  // ── Check if we have 3+ weeks for higher confidence ──────────────────────────
  const hasThreeSessions = weeks.length >= 3;

  // ── Decision tree ─────────────────────────────────────────────────────────────

  if (performanceDropping && tooHardBothSessions) {
    // Struggling: same weight, fewer reps
    const reducedWeight = roundToIncrement(lastWeight - increment, increment);
    return {
      suggestedWeight: Math.max(reducedWeight, increment),
      suggestedReps: 6,
      reasoning: `Performance declined and RPE was high (avg ${effectiveLastRpe.toFixed(1)}). Reduce load slightly and focus on quality reps.`,
      confidence: hasThreeSessions ? 'medium' : 'low',
    };
  }

  if (performanceDropping) {
    // Performance dropped but RPE not extreme — hold weight
    return {
      suggestedWeight: lastWeight,
      suggestedReps: 8,
      reasoning: `Slight performance dip (e1RM down ${Math.abs(e1rmDelta).toFixed(1)}). Stay at current weight before progressing.`,
      confidence: hasThreeSessions ? 'medium' : 'low',
    };
  }

  if (tooHardBothSessions) {
    // RPE consistently above target for 2 sessions — hold weight
    return {
      suggestedWeight: lastWeight,
      suggestedReps: 8,
      reasoning: `RPE has been above target (${targetRpe}) for 2 sessions. Stay at ${lastWeight} kg until it feels more manageable.`,
      confidence: 'medium',
    };
  }

  if (tooEasyBothSessions) {
    // Ready to progress — increase by one increment
    const newWeight = roundToIncrement(lastWeight + increment, increment);
    return {
      suggestedWeight: newWeight,
      suggestedReps: 8,
      reasoning: `Consistently hitting target RPE (${targetRpe}) across 2 sessions — ready to add ${increment} kg.`,
      confidence: hasThreeSessions ? 'high' : 'medium',
    };
  }

  if (tooHardLastSession) {
    // Last session was hard but previous was fine — hold
    return {
      suggestedWeight: lastWeight,
      suggestedReps: 8,
      reasoning: `Last session RPE was ${effectiveLastRpe.toFixed(1)} (above target ${targetRpe}). Repeat the weight.`,
      confidence: 'medium',
    };
  }

  // Default: maintain current weight
  return {
    suggestedWeight: lastWeight,
    suggestedReps: 8,
    reasoning: `Solid session at ${lastWeight} kg. Aim to match or slightly beat last performance.`,
    confidence: hasThreeSessions ? 'medium' : 'low',
  };
}
