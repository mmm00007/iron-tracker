import { describe, it, expect } from 'vitest';
import { checkDeloadNeeded, deriveWeeklyVolumes } from './deloadDetection';
import type { WeeklyVolumeEntry } from './deloadDetection';
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

describe('checkDeloadNeeded', () => {
  it('returns no deload when training looks healthy (flat volume, normal RPE)', () => {
    const weeklyVolumes: WeeklyVolumeEntry[] = [
      { week: '2025-W10', volume: 5000 },
      { week: '2025-W11', volume: 5100 },
      { week: '2025-W12', volume: 4900 },
      { week: '2025-W13', volume: 5050 },
    ];

    const sets = [
      makeSet({ logged_at: '2025-03-03T10:00:00Z', weight: 100, reps: 8, rpe: 7 }),
      makeSet({ logged_at: '2025-03-10T10:00:00Z', weight: 100, reps: 8, rpe: 7 }),
      makeSet({ logged_at: '2025-03-17T10:00:00Z', weight: 100, reps: 8, rpe: 7.5 }),
      makeSet({ logged_at: '2025-03-24T10:00:00Z', weight: 100, reps: 8, rpe: 7 }),
    ];

    const result = checkDeloadNeeded(sets, weeklyVolumes);
    expect(result.shouldDeload).toBe(false);
  });

  it('returns no deload when insufficient data (less than 2 weeks)', () => {
    const weeklyVolumes: WeeklyVolumeEntry[] = [{ week: '2025-W12', volume: 5000 }];
    const sets = [makeSet({ logged_at: '2025-03-17T10:00:00Z' })];

    const result = checkDeloadNeeded(sets, weeklyVolumes);
    expect(result.shouldDeload).toBe(false);
    expect(result.reasoning).toContain('on track');
  });

  it('returns no deload when empty sets', () => {
    const result = checkDeloadNeeded([], []);
    expect(result.shouldDeload).toBe(false);
  });

  it('detects deload (moderate) when multiple triggers fire: high RPE + volume spike', () => {
    // Set up: 3 prior weeks of stable volume, then a spike + high RPE
    const weeklyVolumes: WeeklyVolumeEntry[] = [
      { week: '2025-W10', volume: 5000 },
      { week: '2025-W11', volume: 5100 },
      { week: '2025-W12', volume: 5000 },
      { week: '2025-W13', volume: 7000 }, // >20% above prior 3-week avg
    ];

    // Week 12 sets (penultimate): normal weight
    // Week 13 sets (latest): same or lower weight, but very high RPE
    const sets = [
      makeSet({ logged_at: '2025-03-17T10:00:00Z', weight: 100, reps: 8, rpe: 9 }),
      makeSet({ logged_at: '2025-03-17T10:30:00Z', weight: 100, reps: 8, rpe: 9.5 }),
      makeSet({ logged_at: '2025-03-24T10:00:00Z', weight: 95, reps: 8, rpe: 9 }),
      makeSet({ logged_at: '2025-03-24T10:30:00Z', weight: 95, reps: 8, rpe: 9 }),
    ];

    const result = checkDeloadNeeded(sets, weeklyVolumes);
    expect(result.shouldDeload).toBe(true);
    expect(result.severity).toBe('moderate');
  });

  it('detects aggressive deload when 3+ triggers fire', () => {
    // 5 consecutive weeks of volume increases + high RPE + declining performance + volume spike
    const weeklyVolumes: WeeklyVolumeEntry[] = [
      { week: '2025-W09', volume: 4000 },
      { week: '2025-W10', volume: 4500 },
      { week: '2025-W11', volume: 5000 },
      { week: '2025-W12', volume: 5500 },
      { week: '2025-W13', volume: 7000 }, // spike + 5th consecutive increase
    ];

    const sets = [
      // W12 sets: strong weights
      makeSet({ logged_at: '2025-03-17T10:00:00Z', weight: 120, reps: 5, rpe: 9 }),
      makeSet({ logged_at: '2025-03-17T10:30:00Z', weight: 120, reps: 5, rpe: 9.5 }),
      // W13 sets: declining weights + high RPE
      makeSet({ logged_at: '2025-03-24T10:00:00Z', weight: 110, reps: 5, rpe: 9.5 }),
      makeSet({ logged_at: '2025-03-24T10:30:00Z', weight: 105, reps: 5, rpe: 9.5 }),
    ];

    const result = checkDeloadNeeded(sets, weeklyVolumes);
    expect(result.shouldDeload).toBe(true);
    expect(result.severity).toBe('aggressive');
    expect(result.suggestion.volumeReduction).toBe(0.55);
    expect(result.suggestion.intensityReduction).toBe(0.15);
  });

  it('returns shouldDeload=false for single trigger (not enough evidence)', () => {
    // Only high RPE, no other triggers
    const weeklyVolumes: WeeklyVolumeEntry[] = [
      { week: '2025-W11', volume: 5000 },
      { week: '2025-W12', volume: 4800 },
      { week: '2025-W13', volume: 5000 },
    ];

    const sets = [
      makeSet({ logged_at: '2025-03-17T10:00:00Z', weight: 100, reps: 8, rpe: 9 }),
      makeSet({ logged_at: '2025-03-24T10:00:00Z', weight: 100, reps: 8, rpe: 9 }),
    ];

    const result = checkDeloadNeeded(sets, weeklyVolumes);
    // Single trigger => monitoring, not deload
    expect(result.shouldDeload).toBe(false);
    expect(result.reasoning).toContain('Minor fatigue signal');
  });

  it('includes reasoning in the recommendation', () => {
    const weeklyVolumes: WeeklyVolumeEntry[] = [
      { week: '2025-W10', volume: 5000 },
      { week: '2025-W11', volume: 5100 },
      { week: '2025-W12', volume: 5000 },
      { week: '2025-W13', volume: 6500 }, // volume spike
    ];

    const sets = [
      makeSet({ logged_at: '2025-03-17T10:00:00Z', weight: 120, reps: 5, rpe: 9.5 }),
      makeSet({ logged_at: '2025-03-24T10:00:00Z', weight: 110, reps: 5, rpe: 9 }),
    ];

    const result = checkDeloadNeeded(sets, weeklyVolumes);
    expect(result.reasoning.length).toBeGreaterThan(0);
  });
});

describe('deriveWeeklyVolumes', () => {
  it('computes weekly volume from raw sets', () => {
    const sets = [
      makeSet({ logged_at: '2025-03-17T10:00:00Z', weight: 100, reps: 5 }),
      makeSet({ logged_at: '2025-03-17T11:00:00Z', weight: 100, reps: 5 }),
      makeSet({ logged_at: '2025-03-24T10:00:00Z', weight: 80, reps: 10 }),
    ];

    const volumes = deriveWeeklyVolumes(sets);
    expect(volumes.length).toBeGreaterThanOrEqual(1);
    // Total across all weeks: 500 + 500 + 800 = 1800
    const totalVol = volumes.reduce((sum, v) => sum + v.volume, 0);
    expect(totalVol).toBe(1800);
  });

  it('returns empty for empty sets', () => {
    expect(deriveWeeklyVolumes([])).toHaveLength(0);
  });

  it('returns sorted by week ascending', () => {
    const sets = [
      makeSet({ logged_at: '2025-03-24T10:00:00Z', weight: 100, reps: 5 }),
      makeSet({ logged_at: '2025-03-10T10:00:00Z', weight: 100, reps: 5 }),
      makeSet({ logged_at: '2025-03-17T10:00:00Z', weight: 100, reps: 5 }),
    ];

    const volumes = deriveWeeklyVolumes(sets);
    for (let i = 1; i < volumes.length; i++) {
      expect(volumes[i]!.week > volumes[i - 1]!.week).toBe(true);
    }
  });
});
