import type { WorkoutSet } from '@/types/database';
import { isoWeek } from '@/utils/analytics';

// ─── Types ─────────────────────────────────────────────────────────────────────

export interface DeloadSuggestion {
  volumeReduction: number; // 0–1, e.g. 0.4 = reduce by 40%
  intensityReduction: number; // 0–1, e.g. 0.1 = reduce intensity by 10%
  durationWeeks: number;
}

export interface DeloadRecommendation {
  shouldDeload: boolean;
  severity: 'mild' | 'moderate' | 'aggressive';
  reasoning: string;
  suggestion: DeloadSuggestion;
}

export interface WeeklyVolumeEntry {
  week: string; // "YYYY-Www"
  volume: number;
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

/** Average RPE across sets that have an RPE value */
function avgRpe(sets: WorkoutSet[]): number | null {
  const withRpe = sets.filter((s) => s.rpe !== null);
  if (withRpe.length === 0) return null;
  return withRpe.reduce((sum, s) => sum + (s.rpe ?? 0), 0) / withRpe.length;
}

/** Group sets by ISO week, return a map week → sets sorted oldest → newest */
function groupByWeek(sets: WorkoutSet[]): Map<string, WorkoutSet[]> {
  const map = new Map<string, WorkoutSet[]>();
  for (const s of sets) {
    const week = isoWeek(new Date(s.logged_at));
    const bucket = map.get(week) ?? [];
    bucket.push(s);
    map.set(week, bucket);
  }
  return map;
}

// ─── Main function ─────────────────────────────────────────────────────────────

/**
 * Determine whether the user should deload based on recent training data.
 *
 * Error on the side of caution — false positives (unnecessary deloads) are
 * worse than false negatives for most intermediate lifters.
 *
 * @param recentSets      All sets from the last 4–6 weeks
 * @param weeklyVolumes   Pre-computed weekly volume array (oldest → newest).
 *                        Can be derived from `recentSets` but passed in to allow
 *                        the caller to normalise units if needed.
 */
export function checkDeloadNeeded(
  recentSets: WorkoutSet[],
  weeklyVolumes: WeeklyVolumeEntry[],
): DeloadRecommendation {
  const noDeload: DeloadRecommendation = {
    shouldDeload: false,
    severity: 'mild',
    reasoning: 'Training looks on track — no deload needed.',
    suggestion: {
      volumeReduction: 0.3,
      intensityReduction: 0,
      durationWeeks: 1,
    },
  };

  // Need at least 2 weeks of data to make a recommendation
  if (weeklyVolumes.length < 2 || recentSets.length === 0) {
    return noDeload;
  }

  const sortedWeeks = [...weeklyVolumes].sort((a, b) => a.week.localeCompare(b.week));
  const weekCount = sortedWeeks.length;
  const weeksByKey = groupByWeek(recentSets);

  // ── Trigger 1: 4+ consecutive weeks of increasing volume ─────────────────────
  let consecutiveIncreases = 0;
  for (let i = weekCount - 1; i >= 1; i--) {
    const curr = sortedWeeks[i]!.volume;
    const prev = sortedWeeks[i - 1]!.volume;
    if (curr > prev) {
      consecutiveIncreases++;
    } else {
      break;
    }
  }
  const continuousVolumeRamp = consecutiveIncreases >= 4;

  // ── Trigger 2: Declining e1RM over last 2 weeks ──────────────────────────────
  // Use max weight per week as a proxy for performance (simpler than e1RM here)
  const recentWeekKeys = sortedWeeks.slice(-2).map((w) => w.week);
  const [week1Key, week2Key] = recentWeekKeys;
  const week1Sets = weeksByKey.get(week1Key ?? '') ?? [];
  const week2Sets = weeksByKey.get(week2Key ?? '') ?? [];

  let decliningPerformance = false;
  if (week1Sets.length > 0 && week2Sets.length > 0) {
    const maxWeightWeek1 = Math.max(...week1Sets.map((s) => s.weight));
    const maxWeightWeek2 = Math.max(...week2Sets.map((s) => s.weight));
    // Consider decline only if it's more than 3%
    decliningPerformance = maxWeightWeek2 < maxWeightWeek1 * 0.97;
  }

  // ── Trigger 3: Average RPE > 8.5 over last 2 weeks ───────────────────────────
  const last2WeekSets = [...week1Sets, ...week2Sets];
  const recentAvgRpe = avgRpe(last2WeekSets);
  const highRpe = recentAvgRpe !== null && recentAvgRpe > 8.5;

  // ── Trigger 4: Sudden volume spike (>20% above 4-week average) ───────────────
  const last4Weeks = sortedWeeks.slice(-4);
  const last4Avg =
    last4Weeks.slice(0, -1).reduce((sum, w) => sum + w.volume, 0) /
    Math.max(last4Weeks.length - 1, 1);
  const currentVolume = last4Weeks[last4Weeks.length - 1]?.volume ?? 0;
  const volumeSpike = last4Avg > 0 && currentVolume > last4Avg * 1.2;

  // ── Severity scoring ──────────────────────────────────────────────────────────
  const triggerCount = [
    continuousVolumeRamp,
    decliningPerformance,
    highRpe,
    volumeSpike,
  ].filter(Boolean).length;

  if (triggerCount === 0) {
    return noDeload;
  }

  // Build reasoning string
  const reasons: string[] = [];
  if (continuousVolumeRamp) {
    reasons.push(`${consecutiveIncreases} consecutive weeks of volume increases`);
  }
  if (decliningPerformance) {
    reasons.push('performance declining over the last 2 weeks');
  }
  if (highRpe) {
    reasons.push(`average RPE ${recentAvgRpe!.toFixed(1)} over the last 2 weeks`);
  }
  if (volumeSpike) {
    const spikePercent = Math.round(((currentVolume - last4Avg) / last4Avg) * 100);
    reasons.push(`current week volume ${spikePercent}% above 4-week average`);
  }

  const reasoningText =
    reasons.length === 1
      ? `Deload recommended: ${reasons[0]}.`
      : `Deload recommended: ${reasons.slice(0, -1).join(', ')} and ${reasons[reasons.length - 1]}.`;

  // ── Severity + prescription ───────────────────────────────────────────────────
  if (triggerCount >= 3) {
    return {
      shouldDeload: true,
      severity: 'aggressive',
      reasoning: reasoningText,
      suggestion: {
        volumeReduction: 0.55,
        intensityReduction: 0.15,
        durationWeeks: 1,
      },
    };
  }

  if (triggerCount === 2) {
    return {
      shouldDeload: true,
      severity: 'moderate',
      reasoning: reasoningText,
      suggestion: {
        volumeReduction: 0.45,
        intensityReduction: 0.1,
        durationWeeks: 1,
      },
    };
  }

  // triggerCount === 1 — not enough evidence to recommend a deload.
  // A single trigger (e.g. one volume spike from adding a new exercise) has too
  // many false positives. Require 2+ triggers for actionable recommendation.
  return {
    shouldDeload: false,
    severity: 'mild',
    reasoning: `Minor fatigue signal detected: ${reasons[0]}. Monitoring — no deload needed yet.`,
    suggestion: {
      volumeReduction: 0,
      intensityReduction: 0,
      durationWeeks: 0,
    },
  };
}

// ─── Utility: derive weekly volumes from raw sets ─────────────────────────────

/**
 * Compute per-week volume totals from a list of sets.
 * Convenience wrapper so callers don't need to import analytics separately.
 */
export function deriveWeeklyVolumes(sets: WorkoutSet[]): WeeklyVolumeEntry[] {
  const map = new Map<string, number>();
  for (const s of sets) {
    const week = isoWeek(new Date(s.logged_at));
    map.set(week, (map.get(week) ?? 0) + s.weight * s.reps);
  }
  return Array.from(map.entries())
    .map(([week, volume]) => ({ week, volume }))
    .sort((a, b) => a.week.localeCompare(b.week));
}
