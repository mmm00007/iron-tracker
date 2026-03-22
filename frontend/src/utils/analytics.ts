import type { WorkoutSet } from '@/types/database';

// ─── 1RM formulas ──────────────────────────────────────────────────────────────

/**
 * Compute estimated 1RM using Epley formula.
 *
 * Epley is used for all rep ranges because:
 * - It's the most validated formula (Epley 1985, Mayhew et al. 1995)
 * - Brzycki diverges at high reps (approaches infinity at 37 reps)
 * - Both formulas are unreliable above ~12 reps regardless
 *
 * Note: 1RM estimates are most accurate for barbell compound lifts.
 * They are less reliable for machines, isolation, and bodyweight exercises.
 *
 * Returns 0 for invalid inputs.
 */
export function computeE1RM(weight: number, reps: number): number {
  if (weight <= 0 || reps <= 0) return 0;
  if (reps === 1) return weight;
  // Epley: weight × (1 + reps/30)
  return weight * (1 + reps / 30);
}

// ─── ISO week helpers ──────────────────────────────────────────────────────────

/**
 * Returns ISO week string "YYYY-Www" for a given date.
 */
export function isoWeek(date: Date): string {
  const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  const dayNum = d.getUTCDay() || 7; // treat Sunday as 7
  d.setUTCDate(d.getUTCDate() + 4 - dayNum);
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
  const weekNo = Math.ceil(((d.getTime() - yearStart.getTime()) / 86400000 + 1) / 7);
  return `${d.getUTCFullYear()}-W${String(weekNo).padStart(2, '0')}`;
}

/**
 * Returns the Monday of the ISO week that contains the given date.
 */
export function isoWeekStart(date: Date): Date {
  const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  const dayNum = d.getUTCDay() || 7;
  d.setUTCDate(d.getUTCDate() - (dayNum - 1));
  return d;
}

// ─── Weekly volume ─────────────────────────────────────────────────────────────

export interface WeeklyVolumeEntry {
  week: string; // "YYYY-Www"
  weekStart: string; // ISO date string of Monday
  volume: number;
  variantBreakdown: Record<string, number>; // variantId (or 'none') → volume
}

/**
 * Group sets by ISO week and sum volume (weight × reps).
 */
export function weeklyVolume(sets: WorkoutSet[]): WeeklyVolumeEntry[] {
  const map = new Map<string, WeeklyVolumeEntry>();

  for (const set of sets) {
    const date = new Date(set.logged_at);
    const week = isoWeek(date);
    const variantKey = set.variant_id ?? 'none';
    const vol = set.weight * set.reps;

    if (!map.has(week)) {
      const weekStartDate = isoWeekStart(date);
      map.set(week, {
        week,
        weekStart: weekStartDate.toISOString().slice(0, 10),
        volume: 0,
        variantBreakdown: {},
      });
    }

    const entry = map.get(week)!;
    entry.volume += vol;
    entry.variantBreakdown[variantKey] = (entry.variantBreakdown[variantKey] ?? 0) + vol;
  }

  return Array.from(map.values()).sort((a, b) => a.week.localeCompare(b.week));
}

// ─── Weekly snapshot ───────────────────────────────────────────────────────────

export interface WeekStats {
  sets: number;
  volume: number;
  trainingDays: number;
}

export interface WeeklySnapshotResult {
  thisWeek: WeekStats;
  lastWeek: WeekStats;
  deltas: {
    sets: number | null; // percentage delta, null if no baseline
    volume: number | null;
    trainingDays: number | null;
  };
}

function currentAndLastWeekBounds(): { thisStart: Date; lastStart: Date; lastEnd: Date } {
  const now = new Date();
  const thisStart = isoWeekStart(now);
  const lastStart = new Date(thisStart);
  lastStart.setUTCDate(lastStart.getUTCDate() - 7);
  const lastEnd = new Date(thisStart);
  return { thisStart, lastStart, lastEnd };
}

function pctDelta(current: number, previous: number): number | null {
  if (previous === 0) return null;
  return Math.round(((current - previous) / previous) * 100);
}

/**
 * Compute weekly snapshot comparing this week to last week.
 */
export function weeklySnapshot(sets: WorkoutSet[]): WeeklySnapshotResult {
  const { thisStart, lastStart, lastEnd } = currentAndLastWeekBounds();

  const thisWeekSets = sets.filter((s) => new Date(s.logged_at) >= thisStart);
  const lastWeekSets = sets.filter(
    (s) => new Date(s.logged_at) >= lastStart && new Date(s.logged_at) < lastEnd,
  );

  function statsFor(weekSets: WorkoutSet[]): WeekStats {
    const days = new Set(weekSets.map((s) => s.logged_at.slice(0, 10)));
    return {
      sets: weekSets.length,
      volume: weekSets.reduce((sum, s) => sum + s.weight * s.reps, 0),
      trainingDays: days.size,
    };
  }

  const thisWeek = statsFor(thisWeekSets);
  const lastWeek = statsFor(lastWeekSets);

  return {
    thisWeek,
    lastWeek,
    deltas: {
      sets: pctDelta(thisWeek.sets, lastWeek.sets),
      volume: pctDelta(thisWeek.volume, lastWeek.volume),
      trainingDays: pctDelta(thisWeek.trainingDays, lastWeek.trainingDays),
    },
  };
}

// ─── Volume by muscle ──────────────────────────────────────────────────────────

/**
 * Group volume by muscle group ID.
 * exerciseMuscles maps exerciseId → array of muscle group IDs.
 */
export function volumeByMuscle(
  sets: WorkoutSet[],
  exerciseMuscles: Map<string, number[]>,
): Map<number, number> {
  const result = new Map<number, number>();

  for (const set of sets) {
    const muscles = exerciseMuscles.get(set.exercise_id) ?? [];
    if (muscles.length === 0) continue;
    const vol = set.weight * set.reps;
    const share = vol / muscles.length; // split evenly across muscles

    for (const muscleId of muscles) {
      result.set(muscleId, (result.get(muscleId) ?? 0) + share);
    }
  }

  return result;
}

// ─── Top exercises ─────────────────────────────────────────────────────────────

export interface TopExerciseEntry {
  exerciseId: string;
  totalVolume: number;
  setCount: number;
  recentVolume: number; // volume in the most recent week
  trend: 'up' | 'down' | 'flat';
}

/**
 * Returns top exercises ranked by total volume.
 */
export function topExercises(sets: WorkoutSet[], limit = 5): TopExerciseEntry[] {
  const map = new Map<string, { total: number; count: number; byWeek: Map<string, number> }>();

  for (const set of sets) {
    const vol = set.weight * set.reps;
    const week = isoWeek(new Date(set.logged_at));

    if (!map.has(set.exercise_id)) {
      map.set(set.exercise_id, { total: 0, count: 0, byWeek: new Map() });
    }
    const entry = map.get(set.exercise_id)!;
    entry.total += vol;
    entry.count += 1;
    entry.byWeek.set(week, (entry.byWeek.get(week) ?? 0) + vol);
  }

  return Array.from(map.entries())
    .map(([exerciseId, data]) => {
      const weeks = Array.from(data.byWeek.entries()).sort((a, b) => a[0].localeCompare(b[0]));
      const recentVol = weeks.length > 0 ? (weeks[weeks.length - 1][1] ?? 0) : 0;
      const prevVol = weeks.length > 1 ? (weeks[weeks.length - 2][1] ?? 0) : 0;
      const trend: 'up' | 'down' | 'flat' =
        recentVol > prevVol * 1.05 ? 'up' : recentVol < prevVol * 0.95 ? 'down' : 'flat';

      return {
        exerciseId,
        totalVolume: data.total,
        setCount: data.count,
        recentVolume: recentVol,
        trend,
      };
    })
    .sort((a, b) => b.totalVolume - a.totalVolume)
    .slice(0, limit);
}

// ─── Training frequency (calendar data) ────────────────────────────────────────

export interface DayActivity {
  date: string; // YYYY-MM-DD
  volume: number;
  setCount: number;
}

/**
 * Returns per-day activity for the last N weeks (default 12).
 */
export function trainingFrequency(sets: WorkoutSet[], weeks = 12): DayActivity[] {
  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() - weeks * 7);

  const dayMap = new Map<string, { volume: number; setCount: number }>();

  for (const set of sets) {
    const date = new Date(set.logged_at);
    if (date < cutoff) continue;
    const key = date.toISOString().slice(0, 10);
    const entry = dayMap.get(key) ?? { volume: 0, setCount: 0 };
    entry.volume += set.weight * set.reps;
    entry.setCount += 1;
    dayMap.set(key, entry);
  }

  return Array.from(dayMap.entries())
    .map(([date, data]) => ({ date, ...data }))
    .sort((a, b) => a.date.localeCompare(b.date));
}

// ─── 1RM trend ────────────────────────────────────────────────────────────────

export interface E1RMDataPoint {
  date: string; // YYYY-MM-DD
  e1rm: number;
  weight: number;
  reps: number;
  variantId: string | null;
}

/**
 * Computes the best estimated 1RM per day for a given exercise (+ optional variant).
 */
export function e1rmTrend(
  sets: WorkoutSet[],
  exerciseId: string,
  variantId?: string | null,
): E1RMDataPoint[] {
  const filtered = sets.filter((s) => {
    if (s.exercise_id !== exerciseId) return false;
    if (variantId !== undefined && variantId !== null) return s.variant_id === variantId;
    return true;
  });

  // Best e1rm per day
  const dayMap = new Map<
    string,
    { e1rm: number; weight: number; reps: number; variantId: string | null }
  >();

  for (const set of filtered) {
    const date = new Date(set.logged_at).toISOString().slice(0, 10);
    const e1rm = computeE1RM(set.weight, set.reps);
    const existing = dayMap.get(date);
    if (!existing || e1rm > existing.e1rm) {
      dayMap.set(date, { e1rm, weight: set.weight, reps: set.reps, variantId: set.variant_id });
    }
  }

  return Array.from(dayMap.entries())
    .map(([date, data]) => ({ date, ...data }))
    .sort((a, b) => a.date.localeCompare(b.date));
}

// ─── PR table ────────────────────────────────────────────────────────────────

export interface PRRecord {
  repRange: number; // 1, 3, 5, 8, 10
  weight: number;
  e1rm: number;
  date: string;
  variantId: string | null;
}

const PR_REP_RANGES = [1, 3, 5, 8, 10];

/**
 * Returns personal records across rep ranges for a given exercise.
 */
export function exercisePRs(sets: WorkoutSet[], exerciseId: string): PRRecord[] {
  const filtered = sets.filter((s) => s.exercise_id === exerciseId);
  const records = new Map<number, PRRecord>();

  for (const set of filtered) {
    // For each rep range, check if this set qualifies (reps ≤ repRange)
    for (const repRange of PR_REP_RANGES) {
      if (set.reps > repRange) continue;
      const e1rm = computeE1RM(set.weight, set.reps);
      const existing = records.get(repRange);
      if (!existing || set.weight > existing.weight) {
        records.set(repRange, {
          repRange,
          weight: set.weight,
          e1rm,
          date: new Date(set.logged_at).toISOString().slice(0, 10),
          variantId: set.variant_id,
        });
      }
    }
  }

  return PR_REP_RANGES.map((r) => records.get(r)).filter((r): r is PRRecord => r !== undefined);
}
