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
  // Epley: weight × (1 + reps/30). Unreliable above 12 reps (Mayhew 1995)
  // — clamp to 12 to avoid nonsensical estimates from high-rep sets.
  const effectiveReps = Math.min(reps, 12);
  return weight * (1 + effectiveReps / 30);
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

export interface MuscleActivation {
  muscleGroupId: number;
  activationPercent: number | null; // null = use even split (legacy)
}

/**
 * Group volume by muscle group ID, weighted by activation percentage.
 *
 * When activation_percent is available (from exercise_muscles junction table),
 * volume is distributed proportionally. Example: a bench press set distributes
 * 60% to chest, 25% to front delts, 15% to triceps instead of 33/33/33.
 *
 * Falls back to even splitting when activation data is unavailable.
 */
export function volumeByMuscle(
  sets: WorkoutSet[],
  exerciseMuscles: Map<string, MuscleActivation[]>,
): Map<number, number> {
  const result = new Map<number, number>();

  for (const set of sets) {
    const muscles = exerciseMuscles.get(set.exercise_id) ?? [];
    if (muscles.length === 0) continue;
    const vol = set.weight * set.reps;

    // Check if we have activation data
    const hasActivation = muscles.some((m) => m.activationPercent != null);

    if (hasActivation) {
      // Weighted distribution by activation percentage
      const totalActivation = muscles.reduce(
        (sum, m) => sum + (m.activationPercent ?? 50), // default 50 for unknown
        0,
      );
      for (const muscle of muscles) {
        const weight = (muscle.activationPercent ?? 50) / totalActivation;
        result.set(
          muscle.muscleGroupId,
          (result.get(muscle.muscleGroupId) ?? 0) + vol * weight,
        );
      }
    } else {
      // Fallback: even split (legacy behavior)
      const share = vol / muscles.length;
      for (const muscle of muscles) {
        result.set(
          muscle.muscleGroupId,
          (result.get(muscle.muscleGroupId) ?? 0) + share,
        );
      }
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
      const recentVol = weeks.length > 0 ? (weeks[weeks.length - 1]?.[1] ?? 0) : 0;
      const prevVol = weeks.length > 1 ? (weeks[weeks.length - 2]?.[1] ?? 0) : 0;
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

// Each rep range bucket accepts sets within a window, preventing a 1RM from
// dominating all buckets. E.g., a 3RM bucket only accepts sets of 2-3 reps.
const PR_REP_WINDOWS: Record<number, [number, number]> = {
  1: [1, 1],
  3: [2, 3],
  5: [4, 5],
  8: [6, 8],
  10: [9, 12],
};

/**
 * Returns personal records across rep ranges for a given exercise.
 */
// ─── Training streak ─────────────────────────────────────────────────────────

export interface TrainingStreakResult {
  currentDayStreak: number;
  currentWeekStreak: number;
  lastTrainedAt: string | null;
  longestDayStreak: number;
}

/**
 * Compute training streak from sets.
 * Day streak: consecutive calendar days with at least one set.
 * Week streak: consecutive ISO weeks with at least one training day.
 */
export function computeStreak(sets: WorkoutSet[]): TrainingStreakResult {
  if (sets.length === 0) {
    return { currentDayStreak: 0, currentWeekStreak: 0, lastTrainedAt: null, longestDayStreak: 0 };
  }

  // Unique training days, sorted ascending
  const days = [...new Set(sets.map((s) => s.logged_at.slice(0, 10)))].sort();
  const today = new Date().toISOString().slice(0, 10);
  const _yd = new Date();
  _yd.setDate(_yd.getDate() - 1);
  const yesterday = _yd.toISOString().slice(0, 10);

  // Current day streak — count backwards from today or yesterday
  let dayStreak = 0;
  if (days.includes(today) || days.includes(yesterday)) {
    let cursor = days.includes(today) ? today : yesterday;
    for (let i = days.length - 1; i >= 0; i--) {
      if (days[i] === cursor) {
        dayStreak++;
        const d = new Date(cursor);
        d.setDate(d.getDate() - 1);
        cursor = d.toISOString().slice(0, 10);
      } else {
        break;
      }
    }
  }

  // Longest day streak
  let longest = 1;
  let cur = 1;
  for (let i = 1; i < days.length; i++) {
    const prev = new Date(days[i - 1]!);
    prev.setDate(prev.getDate() + 1);
    if (prev.toISOString().slice(0, 10) === days[i]) {
      cur++;
      longest = Math.max(longest, cur);
    } else {
      cur = 1;
    }
  }

  // Current week streak
  const weeks = [...new Set(sets.map((s) => isoWeek(new Date(s.logged_at))))].sort();
  const currentWeekStr = isoWeek(new Date());
  const prevWeekDate = new Date();
  prevWeekDate.setDate(prevWeekDate.getDate() - 7);
  const prevWeekStr = isoWeek(prevWeekDate);

  let weekStreak = 0;
  if (weeks.includes(currentWeekStr) || weeks.includes(prevWeekStr)) {
    // Start from the most recent active week
    let weekCursor = weeks.includes(currentWeekStr) ? currentWeekStr : prevWeekStr;
    for (let i = weeks.length - 1; i >= 0; i--) {
      if (weeks[i] === weekCursor) {
        weekStreak++;
        // Step back one week
        const parts = weekCursor.split('-W');
        const yr = Number(parts[0]);
        const wk = Number(parts[1]);
        if (wk === 1) {
          // Determine the last ISO week of the prior year using the Dec 28
          // method: Dec 28 is always in the last ISO week of its year.
          const priorYear = yr - 1;
          const dec28 = new Date(Date.UTC(priorYear, 11, 28));
          const lastWeek = Number(isoWeek(dec28).split('-W')[1]);
          weekCursor = `${priorYear}-W${String(lastWeek).padStart(2, '0')}`;
        } else {
          weekCursor = `${yr}-W${String(wk - 1).padStart(2, '0')}`;
        }
      } else if (weeks[i]! < weekCursor) {
        break;
      }
    }
  }

  return {
    currentDayStreak: dayStreak,
    currentWeekStreak: weekStreak,
    lastTrainedAt: days[days.length - 1] ?? null,
    longestDayStreak: longest,
  };
}

// ─── Training frequency per week (for bar chart) ────────────────────────────

export interface WeeklyFrequencyEntry {
  label: string; // short label like "Mar 3"
  weekStart: string; // YYYY-MM-DD
  days: number; // unique training days that week
}

/**
 * Returns training days per ISO week for the last N weeks.
 */
export function trainingFrequencyPerWeek(sets: WorkoutSet[], weeks = 8): WeeklyFrequencyEntry[] {
  const today = new Date();
  const result: WeeklyFrequencyEntry[] = [];

  for (let w = weeks - 1; w >= 0; w--) {
    const weekStart = new Date(today);
    const dayOfWeek = weekStart.getDay() || 7;
    weekStart.setDate(weekStart.getDate() - dayOfWeek + 1 - w * 7);
    const weekEnd = new Date(weekStart);
    weekEnd.setDate(weekEnd.getDate() + 7);

    const startStr = weekStart.toISOString().slice(0, 10);
    const endStr = weekEnd.toISOString().slice(0, 10);

    const daysSet = new Set<string>();
    for (const set of sets) {
      const dateStr = set.logged_at.slice(0, 10);
      if (dateStr >= startStr && dateStr < endStr) {
        daysSet.add(dateStr);
      }
    }

    const label = weekStart.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
    result.push({ label, weekStart: startStr, days: daysSet.size });
  }

  return result;
}

export function exercisePRs(sets: WorkoutSet[], exerciseId: string): PRRecord[] {
  const filtered = sets.filter((s) => s.exercise_id === exerciseId);
  const records = new Map<number, PRRecord>();

  for (const set of filtered) {
    // Each rep range bucket uses a windowed range to prevent 1RM from
    // dominating all buckets. E.g., 5RM only accepts sets of 4-5 reps.
    for (const repRange of PR_REP_RANGES) {
      const window = PR_REP_WINDOWS[repRange];
      if (!window) continue;
      const [minReps, maxReps] = window;
      if (set.reps < minReps || set.reps > maxReps) continue;
      const e1rm = computeE1RM(set.weight, set.reps);
      const existing = records.get(repRange);
      if (!existing || e1rm > existing.e1rm) {
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
