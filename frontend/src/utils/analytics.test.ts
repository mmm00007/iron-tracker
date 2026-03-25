import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import {
  computeE1RM,
  isoWeek,
  isoWeekStart,
  weeklyVolume,
  weeklySnapshot,
  computeStreak,
  volumeByMuscle,
  topExercises,
  e1rmTrend,
  type MuscleActivation,
} from './analytics';
import type { WorkoutSet } from '@/types/database';

function makeSet(overrides: Partial<WorkoutSet> & { logged_at: string }): WorkoutSet {
  return {
    id: `set-${Math.random().toString(36).slice(2, 8)}`,
    user_id: 'u1',
    exercise_id: 'ex-1',
    variant_id: null,
    weight: 100,
    weight_unit: 'kg',
    reps: 8,
    rpe: null,
    rir: null,
    set_type: 'working',
    tempo: null,
    notes: null,
    estimated_1rm: null,
    synced_at: null,
    updated_at: new Date().toISOString(),
    duration_seconds: null,
    distance_meters: null,
    distance_unit: null,
    training_date: null,
    side: null,
    rest_seconds: null,
    workout_cluster_id: null,
    ...overrides,
  };
}

describe('computeE1RM', () => {
  it('computes Epley formula: weight * (1 + reps/30)', () => {
    // 100 * (1 + 5/30) = 100 * 1.1667 = 116.67
    expect(computeE1RM(100, 5)).toBeCloseTo(116.67, 1);
  });

  it('returns weight for 1 rep', () => {
    expect(computeE1RM(200, 1)).toBe(200);
  });

  it('returns 0 for invalid inputs', () => {
    expect(computeE1RM(0, 5)).toBe(0);
    expect(computeE1RM(-10, 5)).toBe(0);
    expect(computeE1RM(100, 0)).toBe(0);
    expect(computeE1RM(100, -1)).toBe(0);
  });

  it('handles high rep counts', () => {
    // 50 * (1 + 20/30) = 50 * 1.6667 = 83.33
    expect(computeE1RM(50, 20)).toBeCloseTo(83.33, 1);
  });
});

describe('isoWeek', () => {
  it('returns correct ISO week string', () => {
    // 2025-01-06 is Monday of W02
    const result = isoWeek(new Date('2025-01-06'));
    expect(result).toBe('2025-W02');
  });

  it('handles year boundaries', () => {
    // 2024-12-30 is in ISO week 1 of 2025
    const result = isoWeek(new Date('2024-12-30'));
    expect(result).toBe('2025-W01');
  });
});

describe('isoWeekStart', () => {
  it('returns Monday of the ISO week', () => {
    // Thursday 2025-03-20 should return Monday 2025-03-17
    const result = isoWeekStart(new Date('2025-03-20'));
    expect(result.toISOString().slice(0, 10)).toBe('2025-03-17');
  });

  it('returns same day when input is Monday', () => {
    const result = isoWeekStart(new Date('2025-03-17'));
    expect(result.toISOString().slice(0, 10)).toBe('2025-03-17');
  });

  it('returns previous Monday for Sunday', () => {
    // Sunday 2025-03-23 -> Monday 2025-03-17
    const result = isoWeekStart(new Date('2025-03-23'));
    expect(result.toISOString().slice(0, 10)).toBe('2025-03-17');
  });
});

describe('weeklyVolume', () => {
  it('groups sets by week and sums volume', () => {
    const sets = [
      makeSet({ logged_at: '2025-03-17T10:00:00Z', weight: 100, reps: 5 }),
      makeSet({ logged_at: '2025-03-17T11:00:00Z', weight: 100, reps: 5 }),
      makeSet({ logged_at: '2025-03-24T10:00:00Z', weight: 80, reps: 10 }),
    ];

    const result = weeklyVolume(sets);
    expect(result.length).toBeGreaterThanOrEqual(1);
    // Week of March 17: 500 + 500 = 1000
    const week1 = result.find((w) => w.week === isoWeek(new Date('2025-03-17')));
    expect(week1).toBeDefined();
    expect(week1!.volume).toBe(1000);
  });

  it('returns empty array for empty sets', () => {
    expect(weeklyVolume([])).toHaveLength(0);
  });

  it('returns sorted by week ascending', () => {
    const sets = [
      makeSet({ logged_at: '2025-03-24T10:00:00Z', weight: 100, reps: 5 }),
      makeSet({ logged_at: '2025-03-10T10:00:00Z', weight: 100, reps: 5 }),
    ];

    const result = weeklyVolume(sets);
    if (result.length > 1) {
      expect(result[0]!.week < result[1]!.week).toBe(true);
    }
  });

  it('includes variant breakdown', () => {
    const sets = [
      makeSet({ logged_at: '2025-03-17T10:00:00Z', variant_id: 'v-1', weight: 100, reps: 5 }),
      makeSet({ logged_at: '2025-03-17T11:00:00Z', variant_id: null, weight: 80, reps: 10 }),
    ];

    const result = weeklyVolume(sets);
    const week = result[0]!;
    expect(week.variantBreakdown['v-1']).toBe(500);
    expect(week.variantBreakdown['none']).toBe(800);
  });
});

describe('weeklySnapshot', () => {
  // Pin "now" to a known date so week boundaries are deterministic
  beforeEach(() => {
    // Pin to Wednesday 2025-03-19 12:00 UTC
    vi.useFakeTimers();
    vi.setSystemTime(new Date('2025-03-19T12:00:00Z'));
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('computes this-week vs last-week stats', () => {
    // This week (starts Monday 2025-03-17)
    const thisWeekSets = [
      makeSet({ logged_at: '2025-03-17T10:00:00Z', weight: 100, reps: 5 }),
      makeSet({ logged_at: '2025-03-18T10:00:00Z', weight: 100, reps: 5 }),
    ];

    // Last week (starts Monday 2025-03-10)
    const lastWeekSets = [
      makeSet({ logged_at: '2025-03-10T10:00:00Z', weight: 80, reps: 10 }),
    ];

    const result = weeklySnapshot([...thisWeekSets, ...lastWeekSets]);
    expect(result.thisWeek.sets).toBe(2);
    expect(result.thisWeek.volume).toBe(1000);
    expect(result.thisWeek.trainingDays).toBe(2);
    expect(result.lastWeek.sets).toBe(1);
    expect(result.lastWeek.volume).toBe(800);
    expect(result.lastWeek.trainingDays).toBe(1);
  });

  it('returns null deltas when last week has zero sets', () => {
    const sets = [makeSet({ logged_at: '2025-03-17T10:00:00Z', weight: 100, reps: 5 })];
    const result = weeklySnapshot(sets);
    expect(result.deltas.sets).toBeNull();
    expect(result.deltas.volume).toBeNull();
  });

  it('computes percentage deltas correctly', () => {
    const sets = [
      // This week: 4 sets, 2000 vol
      makeSet({ logged_at: '2025-03-17T10:00:00Z', weight: 100, reps: 5 }),
      makeSet({ logged_at: '2025-03-17T11:00:00Z', weight: 100, reps: 5 }),
      makeSet({ logged_at: '2025-03-18T10:00:00Z', weight: 100, reps: 5 }),
      makeSet({ logged_at: '2025-03-18T11:00:00Z', weight: 100, reps: 5 }),
      // Last week: 2 sets, 1000 vol
      makeSet({ logged_at: '2025-03-10T10:00:00Z', weight: 100, reps: 5 }),
      makeSet({ logged_at: '2025-03-10T11:00:00Z', weight: 100, reps: 5 }),
    ];

    const result = weeklySnapshot(sets);
    // sets: 4 vs 2 = +100%
    expect(result.deltas.sets).toBe(100);
    // volume: 2000 vs 1000 = +100%
    expect(result.deltas.volume).toBe(100);
  });
});

describe('computeStreak', () => {
  beforeEach(() => {
    vi.useFakeTimers();
    // Pin to 2025-03-20 (Thursday)
    vi.setSystemTime(new Date('2025-03-20T12:00:00Z'));
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('returns zero streak for empty sets', () => {
    const result = computeStreak([]);
    expect(result.currentDayStreak).toBe(0);
    expect(result.currentWeekStreak).toBe(0);
    expect(result.lastTrainedAt).toBeNull();
    expect(result.longestDayStreak).toBe(0);
  });

  it('counts consecutive day streak from today', () => {
    const sets = [
      makeSet({ logged_at: '2025-03-18T10:00:00Z' }), // Tuesday
      makeSet({ logged_at: '2025-03-19T10:00:00Z' }), // Wednesday
      makeSet({ logged_at: '2025-03-20T10:00:00Z' }), // Thursday (today)
    ];

    const result = computeStreak(sets);
    expect(result.currentDayStreak).toBe(3);
  });

  it('allows streak from yesterday if not trained today', () => {
    const sets = [
      makeSet({ logged_at: '2025-03-18T10:00:00Z' }),
      makeSet({ logged_at: '2025-03-19T10:00:00Z' }),
      // No set on 2025-03-20 (today)
    ];

    const result = computeStreak(sets);
    expect(result.currentDayStreak).toBe(2);
  });

  it('computes longest day streak', () => {
    const sets = [
      // 5-day streak earlier
      makeSet({ logged_at: '2025-03-01T10:00:00Z' }),
      makeSet({ logged_at: '2025-03-02T10:00:00Z' }),
      makeSet({ logged_at: '2025-03-03T10:00:00Z' }),
      makeSet({ logged_at: '2025-03-04T10:00:00Z' }),
      makeSet({ logged_at: '2025-03-05T10:00:00Z' }),
      // Gap
      // Current 2-day streak
      makeSet({ logged_at: '2025-03-19T10:00:00Z' }),
      makeSet({ logged_at: '2025-03-20T10:00:00Z' }),
    ];

    const result = computeStreak(sets);
    expect(result.longestDayStreak).toBe(5);
    expect(result.currentDayStreak).toBe(2);
  });

  it('tracks last trained date', () => {
    const sets = [
      makeSet({ logged_at: '2025-03-20T10:00:00Z' }),
      makeSet({ logged_at: '2025-03-18T10:00:00Z' }),
    ];

    const result = computeStreak(sets);
    expect(result.lastTrainedAt).toBe('2025-03-20');
  });

  it('computes week streak', () => {
    const sets = [
      // This week (W12, starting March 17)
      makeSet({ logged_at: '2025-03-20T10:00:00Z' }),
      // Last week (W11)
      makeSet({ logged_at: '2025-03-13T10:00:00Z' }),
      // Week before (W10)
      makeSet({ logged_at: '2025-03-06T10:00:00Z' }),
    ];

    const result = computeStreak(sets);
    expect(result.currentWeekStreak).toBeGreaterThanOrEqual(2);
  });
});

describe('volumeByMuscle', () => {
  it('splits volume evenly when no activation data', () => {
    const sets = [
      makeSet({ logged_at: '2025-03-20T10:00:00Z', exercise_id: 'bench', weight: 100, reps: 10 }),
    ];

    // bench targets 2 muscles, no activation data (legacy behavior)
    const exerciseMuscles = new Map<string, MuscleActivation[]>([
      ['bench', [
        { muscleGroupId: 1, activationPercent: null },
        { muscleGroupId: 2, activationPercent: null },
      ]],
    ]);
    const result = volumeByMuscle(sets, exerciseMuscles);

    // 100*10 = 1000 volume, split evenly = 500 each
    expect(result.get(1)).toBe(500);
    expect(result.get(2)).toBe(500);
  });

  it('weights volume by activation percentage when available', () => {
    const sets = [
      makeSet({ logged_at: '2025-03-20T10:00:00Z', exercise_id: 'bench', weight: 100, reps: 10 }),
    ];

    // bench: chest 90%, triceps 30% activation → total 120, weights: 75%/25%
    const exerciseMuscles = new Map<string, MuscleActivation[]>([
      ['bench', [
        { muscleGroupId: 1, activationPercent: 90 },
        { muscleGroupId: 2, activationPercent: 30 },
      ]],
    ]);
    const result = volumeByMuscle(sets, exerciseMuscles);

    // 1000 * (90/120) = 750, 1000 * (30/120) = 250
    expect(result.get(1)).toBe(750);
    expect(result.get(2)).toBe(250);
  });

  it('returns empty map for sets with no muscle mappings', () => {
    const sets = [makeSet({ logged_at: '2025-03-20T10:00:00Z' })];
    const result = volumeByMuscle(sets, new Map());
    expect(result.size).toBe(0);
  });
});

describe('topExercises', () => {
  it('ranks exercises by total volume', () => {
    const sets = [
      makeSet({ logged_at: '2025-03-20T10:00:00Z', exercise_id: 'bench', weight: 100, reps: 10 }),
      makeSet({ logged_at: '2025-03-20T10:05:00Z', exercise_id: 'bench', weight: 100, reps: 10 }),
      makeSet({ logged_at: '2025-03-20T10:10:00Z', exercise_id: 'squat', weight: 50, reps: 5 }),
    ];

    const result = topExercises(sets, 5);
    expect(result[0]!.exerciseId).toBe('bench');
    expect(result[0]!.totalVolume).toBe(2000);
    expect(result[1]!.exerciseId).toBe('squat');
    expect(result[1]!.totalVolume).toBe(250);
  });

  it('respects limit parameter', () => {
    const sets = [
      makeSet({ logged_at: '2025-03-20T10:00:00Z', exercise_id: 'a', weight: 100, reps: 10 }),
      makeSet({ logged_at: '2025-03-20T10:05:00Z', exercise_id: 'b', weight: 90, reps: 10 }),
      makeSet({ logged_at: '2025-03-20T10:10:00Z', exercise_id: 'c', weight: 80, reps: 10 }),
    ];

    const result = topExercises(sets, 2);
    expect(result).toHaveLength(2);
  });
});

describe('e1rmTrend', () => {
  it('returns best e1RM per day for an exercise', () => {
    const sets = [
      makeSet({ logged_at: '2025-03-20T10:00:00Z', exercise_id: 'bench', weight: 100, reps: 5 }),
      makeSet({ logged_at: '2025-03-20T10:30:00Z', exercise_id: 'bench', weight: 90, reps: 8 }),
      makeSet({ logged_at: '2025-03-21T10:00:00Z', exercise_id: 'bench', weight: 110, reps: 3 }),
    ];

    const result = e1rmTrend(sets, 'bench');
    expect(result).toHaveLength(2); // 2 distinct days
    // Sorted by date ascending
    expect(result[0]!.date).toBe('2025-03-20');
    expect(result[1]!.date).toBe('2025-03-21');
    // Each day shows the best e1RM
    expect(result[0]!.e1rm).toBeGreaterThan(0);
  });

  it('filters by exercise_id', () => {
    const sets = [
      makeSet({ logged_at: '2025-03-20T10:00:00Z', exercise_id: 'bench', weight: 100, reps: 5 }),
      makeSet({ logged_at: '2025-03-20T10:30:00Z', exercise_id: 'squat', weight: 140, reps: 5 }),
    ];

    const result = e1rmTrend(sets, 'bench');
    expect(result).toHaveLength(1);
    expect(result[0]!.e1rm).toBeCloseTo(computeE1RM(100, 5), 1);
  });
});
