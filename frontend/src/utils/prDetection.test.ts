import { describe, it, expect } from 'vitest';
import { checkForPRs, buildPRRows, filterPRsForExercise, prLabel } from './prDetection';
import { computeE1RM } from '@/utils/analytics';
import type { PersonalRecord } from '@/types/database';

describe('computeE1RM (Epley formula)', () => {
  it('returns 126.67 for 100kg x 8 reps', () => {
    // Epley: 100 * (1 + 8/30) = 100 * 1.2667 = 126.67
    const result = computeE1RM(100, 8);
    expect(result).toBeCloseTo(126.67, 1);
  });

  it('returns the weight itself for 1 rep', () => {
    expect(computeE1RM(150, 1)).toBe(150);
  });

  it('returns 0 for zero weight', () => {
    expect(computeE1RM(0, 5)).toBe(0);
  });

  it('returns 0 for zero reps', () => {
    expect(computeE1RM(100, 0)).toBe(0);
  });

  it('returns 0 for negative weight', () => {
    expect(computeE1RM(-50, 5)).toBe(0);
  });

  it('returns 0 for negative reps', () => {
    expect(computeE1RM(100, -3)).toBe(0);
  });
});

describe('checkForPRs', () => {
  const baseSet = {
    weight: 120,
    reps: 5,
    exerciseId: 'ex-1',
    variantId: null,
  };

  it('detects PR when new e1RM exceeds current', () => {
    const existingPRs: PersonalRecord[] = [
      {
        id: 'pr-1',
        user_id: 'u1',
        exercise_id: 'ex-1',
        variant_id: null,
        record_type: 'estimated_1rm',
        rep_count: null,
        value: 100,
        set_id: 's1',
        achieved_at: '2025-01-01T00:00:00Z',
      },
    ];

    const result = checkForPRs(baseSet, existingPRs);
    expect(result.isPR).toBe(true);
    const e1rmRecord = result.records.find((r) => r.type === 'estimated_1rm');
    expect(e1rmRecord).toBeDefined();
    expect(e1rmRecord!.newValue).toBeGreaterThan(100);
    expect(e1rmRecord!.previousValue).toBe(100);
  });

  it('returns no e1RM PR when new e1RM is lower', () => {
    // 50kg x 5 = e1RM of 58.33, lower than existing 100
    const existingPRs: PersonalRecord[] = [
      {
        id: 'pr-1',
        user_id: 'u1',
        exercise_id: 'ex-1',
        variant_id: null,
        record_type: 'estimated_1rm',
        rep_count: null,
        value: 100,
        set_id: 's1',
        achieved_at: '2025-01-01T00:00:00Z',
      },
      {
        id: 'pr-2',
        user_id: 'u1',
        exercise_id: 'ex-1',
        variant_id: null,
        record_type: 'max_weight',
        rep_count: null,
        value: 200,
        set_id: 's1',
        achieved_at: '2025-01-01T00:00:00Z',
      },
      {
        id: 'pr-3',
        user_id: 'u1',
        exercise_id: 'ex-1',
        variant_id: null,
        record_type: 'max_volume',
        rep_count: null,
        value: 9999,
        set_id: 's1',
        achieved_at: '2025-01-01T00:00:00Z',
      },
      {
        id: 'pr-4',
        user_id: 'u1',
        exercise_id: 'ex-1',
        variant_id: null,
        record_type: 'rep_max',
        rep_count: 5,
        value: 200,
        set_id: 's1',
        achieved_at: '2025-01-01T00:00:00Z',
      },
    ];

    const result = checkForPRs({ weight: 50, reps: 5, exerciseId: 'ex-1', variantId: null }, existingPRs);
    expect(result.isPR).toBe(false);
    expect(result.records).toHaveLength(0);
  });

  it('creates PR on first set with no existing records', () => {
    const result = checkForPRs(baseSet, []);
    expect(result.isPR).toBe(true);
    // Should create e1RM, rep_max (5 reps is in REP_MAX_COUNTS), max_weight, max_volume
    expect(result.records.length).toBeGreaterThanOrEqual(3);
    // All previousValues should be null (first ever)
    result.records.forEach((rec) => {
      expect(rec.previousValue).toBeNull();
    });
  });

  it('detects rep_max PR at exact rep count', () => {
    const existingPRs: PersonalRecord[] = [
      {
        id: 'pr-1',
        user_id: 'u1',
        exercise_id: 'ex-1',
        variant_id: null,
        record_type: 'rep_max',
        rep_count: 5,
        value: 100,
        set_id: 's1',
        achieved_at: '2025-01-01T00:00:00Z',
      },
    ];

    // 120kg x 5 should beat the existing 100kg 5RM
    const result = checkForPRs(baseSet, existingPRs);
    const repMaxRecord = result.records.find((r) => r.type === 'rep_max' && r.repCount === 5);
    expect(repMaxRecord).toBeDefined();
    expect(repMaxRecord!.newValue).toBe(120);
    expect(repMaxRecord!.previousValue).toBe(100);
  });

  it('does not detect rep_max for non-matching rep count', () => {
    // 120kg x 5 should NOT produce a 3RM record
    const result = checkForPRs(baseSet, []);
    const threeRM = result.records.find((r) => r.type === 'rep_max' && r.repCount === 3);
    expect(threeRM).toBeUndefined();
  });

  it('returns isPR=false for zero weight', () => {
    const result = checkForPRs({ weight: 0, reps: 5, exerciseId: 'ex-1', variantId: null }, []);
    expect(result.isPR).toBe(false);
    expect(result.records).toHaveLength(0);
  });

  it('returns isPR=false for zero reps', () => {
    const result = checkForPRs({ weight: 100, reps: 0, exerciseId: 'ex-1', variantId: null }, []);
    expect(result.isPR).toBe(false);
    expect(result.records).toHaveLength(0);
  });

  it('detects max_weight PR', () => {
    const existingPRs: PersonalRecord[] = [
      {
        id: 'pr-1',
        user_id: 'u1',
        exercise_id: 'ex-1',
        variant_id: null,
        record_type: 'max_weight',
        rep_count: null,
        value: 100,
        set_id: 's1',
        achieved_at: '2025-01-01T00:00:00Z',
      },
    ];

    const result = checkForPRs(baseSet, existingPRs);
    const maxWeight = result.records.find((r) => r.type === 'max_weight');
    expect(maxWeight).toBeDefined();
    expect(maxWeight!.newValue).toBe(120);
    expect(maxWeight!.previousValue).toBe(100);
  });

  it('detects max_volume PR', () => {
    const existingPRs: PersonalRecord[] = [
      {
        id: 'pr-1',
        user_id: 'u1',
        exercise_id: 'ex-1',
        variant_id: null,
        record_type: 'max_volume',
        rep_count: null,
        value: 500, // existing max volume
        set_id: 's1',
        achieved_at: '2025-01-01T00:00:00Z',
      },
    ];

    // 120 * 5 = 600 > 500
    const result = checkForPRs(baseSet, existingPRs);
    const maxVol = result.records.find((r) => r.type === 'max_volume');
    expect(maxVol).toBeDefined();
    expect(maxVol!.newValue).toBe(600);
    expect(maxVol!.previousValue).toBe(500);
  });
});

describe('buildPRRows', () => {
  it('converts PRCheckResult into PersonalRecord rows', () => {
    const prResult = checkForPRs(
      { weight: 100, reps: 5, exerciseId: 'ex-1', variantId: 'v-1' },
      [],
    );

    const rows = buildPRRows(prResult, {
      userId: 'u1',
      exerciseId: 'ex-1',
      variantId: 'v-1',
      setId: 's1',
      achievedAt: '2025-03-20T10:00:00Z',
    });

    expect(rows.length).toBe(prResult.records.length);
    rows.forEach((row) => {
      expect(row.user_id).toBe('u1');
      expect(row.exercise_id).toBe('ex-1');
      expect(row.variant_id).toBe('v-1');
      expect(row.set_id).toBe('s1');
      expect(row.achieved_at).toBe('2025-03-20T10:00:00Z');
    });
  });
});

describe('filterPRsForExercise', () => {
  const prs: PersonalRecord[] = [
    {
      id: 'pr-1',
      user_id: 'u1',
      exercise_id: 'ex-1',
      variant_id: null,
      record_type: 'estimated_1rm',
      rep_count: null,
      value: 100,
      set_id: 's1',
      achieved_at: '2025-01-01T00:00:00Z',
    },
    {
      id: 'pr-2',
      user_id: 'u1',
      exercise_id: 'ex-1',
      variant_id: 'v-1',
      record_type: 'max_weight',
      rep_count: null,
      value: 120,
      set_id: 's2',
      achieved_at: '2025-01-02T00:00:00Z',
    },
    {
      id: 'pr-3',
      user_id: 'u1',
      exercise_id: 'ex-2',
      variant_id: null,
      record_type: 'estimated_1rm',
      rep_count: null,
      value: 80,
      set_id: 's3',
      achieved_at: '2025-01-03T00:00:00Z',
    },
  ];

  it('filters PRs for a specific exercise with null variant', () => {
    const result = filterPRsForExercise(prs, 'ex-1', null);
    expect(result).toHaveLength(1);
    expect(result[0]!.id).toBe('pr-1');
  });

  it('filters PRs for a specific exercise with a variant', () => {
    const result = filterPRsForExercise(prs, 'ex-1', 'v-1');
    expect(result).toHaveLength(1);
    expect(result[0]!.id).toBe('pr-2');
  });

  it('returns empty array when no match', () => {
    const result = filterPRsForExercise(prs, 'ex-99', null);
    expect(result).toHaveLength(0);
  });
});

describe('prLabel', () => {
  it('formats estimated_1rm label', () => {
    expect(prLabel({ type: 'estimated_1rm', newValue: 126.7, previousValue: 100 })).toBe(
      'New Est. 1RM — 126.7',
    );
  });

  it('formats rep_max label', () => {
    expect(prLabel({ type: 'rep_max', repCount: 5, newValue: 120, previousValue: 100 })).toBe(
      'New 5RM — 120',
    );
  });

  it('formats max_weight label', () => {
    expect(prLabel({ type: 'max_weight', newValue: 150, previousValue: null })).toBe(
      'New Max Weight — 150',
    );
  });

  it('formats max_volume label', () => {
    expect(prLabel({ type: 'max_volume', newValue: 600.0, previousValue: 500 })).toBe(
      'New Max Volume — 600.0',
    );
  });
});
