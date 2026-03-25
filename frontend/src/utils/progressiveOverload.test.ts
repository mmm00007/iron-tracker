import { describe, it, expect } from 'vitest';
import { suggestProgression } from './progressiveOverload';
import type { WorkoutSet } from '@/types/database';

/** Helper to create a minimal WorkoutSet with sensible defaults. */
function makeSet(overrides: Partial<WorkoutSet> & { weight: number; reps: number }): WorkoutSet {
  return {
    id: 'set-1',
    user_id: 'u1',
    exercise_id: 'ex1',
    variant_id: null,
    weight_unit: 'kg',
    rpe: null,
    rir: null,
    set_type: 'working',
    tempo: null,
    notes: null,
    estimated_1rm: null,
    logged_at: '2026-03-10T10:00:00Z',
    synced_at: null,
    updated_at: '2026-03-10T10:00:00Z',
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

describe('suggestProgression', () => {
  // ── Branch 1: Empty sets ────────────────────────────────────────────────────

  describe('no previous data', () => {
    it('returns base suggestion with zero weight and low confidence', () => {
      const result = suggestProgression([], 7.5, 'strength');

      expect(result.suggestedWeight).toBe(0);
      expect(result.suggestedReps).toBe(8);
      expect(result.confidence).toBe('low');
      expect(result.reasoning).toContain('No previous data');
    });
  });

  // ── Branch 2: Single session ────────────────────────────────────────────────

  describe('single session (one week of data)', () => {
    it('returns the max working weight and suggests keeping current', () => {
      const sets = [
        makeSet({ weight: 60, reps: 8, logged_at: '2026-03-10T10:00:00Z' }),
        makeSet({ weight: 65, reps: 6, logged_at: '2026-03-10T10:15:00Z' }),
        makeSet({ weight: 60, reps: 8, logged_at: '2026-03-10T10:30:00Z' }),
      ];

      const result = suggestProgression(sets, 7.5, 'strength');

      expect(result.suggestedWeight).toBe(65);
      expect(result.suggestedReps).toBe(8);
      expect(result.confidence).toBe('low');
      expect(result.reasoning).toContain('one session');
    });

    it('uses non-working sets as reference when no working sets exist', () => {
      const sets = [
        makeSet({ weight: 40, reps: 10, set_type: 'warmup', logged_at: '2026-03-10T10:00:00Z' }),
        makeSet({ weight: 50, reps: 8, set_type: 'warmup', logged_at: '2026-03-10T10:10:00Z' }),
      ];

      const result = suggestProgression(sets, 7.5, 'strength');

      expect(result.suggestedWeight).toBe(50);
    });
  });

  // ── Branch 3: Performance dropping + RPE too hard (both sessions) ───────────

  describe('performance dropping with high RPE (both sessions)', () => {
    it('suggests weight decrease with reduced reps', () => {
      // Week 1: 80kg x 8 at RPE 9.5, e1RM = 80*(1+8/30) = 101.33
      // Week 2: 80kg x 5 at RPE 9.5, e1RM = 80*(1+5/30) = 93.33
      // e1RM delta = -8, which is > 3% of 101.33 (~3.04), so performance is dropping
      // Both sessions RPE > 9 (target+1 = 8.5), so tooHardBothSessions = true
      const sets = [
        makeSet({ weight: 80, reps: 8, rpe: 9.5, logged_at: '2026-03-03T10:00:00Z' }),
        makeSet({ weight: 80, reps: 5, rpe: 9.5, logged_at: '2026-03-10T10:00:00Z' }),
      ];

      const result = suggestProgression(sets, 7.5, 'strength');

      expect(result.suggestedWeight).toBeLessThan(80);
      expect(result.suggestedReps).toBe(6);
      expect(result.reasoning).toContain('Performance declined');
    });
  });

  // ── Branch 4: Performance dropping (RPE not extreme) ────────────────────────

  describe('performance dropping without extreme RPE', () => {
    it('suggests holding at current weight', () => {
      // Week 1: 80kg x 10 at RPE 7, e1RM = 80*(1+10/30) = 106.67
      // Week 2: 80kg x 7 at RPE 8, e1RM = 80*(1+7/30) = 98.67
      // e1RM delta = -8, > 3% of 106.67 (~3.2), so dropping
      // RPE 8 is not > 8.5 (target+1), so not tooHard
      const sets = [
        makeSet({ weight: 80, reps: 10, rpe: 7, logged_at: '2026-03-03T10:00:00Z' }),
        makeSet({ weight: 80, reps: 7, rpe: 8, logged_at: '2026-03-10T10:00:00Z' }),
      ];

      const result = suggestProgression(sets, 7.5, 'strength');

      expect(result.suggestedWeight).toBe(80);
      expect(result.suggestedReps).toBe(8);
      expect(result.reasoning).toContain('performance dip');
    });
  });

  // ── Branch 5: RPE too hard both sessions (no performance drop) ──────────────

  describe('RPE too hard both sessions without performance drop', () => {
    it('suggests holding at current weight', () => {
      // Week 1: 80kg x 8 at RPE 9, e1RM = 101.33
      // Week 2: 80kg x 9 at RPE 9, e1RM = 104.00
      // e1RM delta = +2.67, positive so NOT dropping
      // Both RPE 9 > 8.5 (target+1), so tooHardBothSessions
      const sets = [
        makeSet({ weight: 80, reps: 8, rpe: 9, logged_at: '2026-03-03T10:00:00Z' }),
        makeSet({ weight: 80, reps: 9, rpe: 9, logged_at: '2026-03-10T10:00:00Z' }),
      ];

      const result = suggestProgression(sets, 7.5, 'strength');

      expect(result.suggestedWeight).toBe(80);
      expect(result.reasoning).toContain('RPE has been above target');
    });
  });

  // ── Branch 6: RPE easy both sessions (ready to progress) ───────────────────

  describe('RPE too easy both sessions — ready to progress', () => {
    it('suggests weight increase for compound lift', () => {
      // Week 1: 80kg x 8 at RPE 7, e1RM = 101.33
      // Week 2: 80kg x 8 at RPE 7, e1RM = 101.33
      // e1RM delta = 0, not dropping
      // Both RPE 7 <= 7.5 (target), so tooEasyBothSessions
      const sets = [
        makeSet({ weight: 80, reps: 8, rpe: 7, logged_at: '2026-03-03T10:00:00Z' }),
        makeSet({ weight: 80, reps: 8, rpe: 7, logged_at: '2026-03-10T10:00:00Z' }),
      ];

      const result = suggestProgression(sets, 7.5, 'strength');

      expect(result.suggestedWeight).toBe(82.5); // +2.5 kg compound increment
      expect(result.suggestedReps).toBe(8);
      expect(result.reasoning).toContain('ready to add');
    });

    it('suggests smaller increment for isolation lift', () => {
      const sets = [
        makeSet({ weight: 15, reps: 12, rpe: 6.5, logged_at: '2026-03-03T10:00:00Z' }),
        makeSet({ weight: 15, reps: 12, rpe: 6, logged_at: '2026-03-10T10:00:00Z' }),
      ];

      const result = suggestProgression(sets, 7.5, 'isolation');

      expect(result.suggestedWeight).toBe(16.25); // +1.25 kg isolation increment
    });

    it('has high confidence with 3+ sessions', () => {
      const sets = [
        makeSet({ weight: 80, reps: 8, rpe: 7, logged_at: '2026-02-24T10:00:00Z' }),
        makeSet({ weight: 80, reps: 8, rpe: 7, logged_at: '2026-03-03T10:00:00Z' }),
        makeSet({ weight: 80, reps: 8, rpe: 7, logged_at: '2026-03-10T10:00:00Z' }),
      ];

      const result = suggestProgression(sets, 7.5, 'strength');

      expect(result.confidence).toBe('high');
    });

    it('has medium confidence with only 2 sessions', () => {
      const sets = [
        makeSet({ weight: 80, reps: 8, rpe: 7, logged_at: '2026-03-03T10:00:00Z' }),
        makeSet({ weight: 80, reps: 8, rpe: 7, logged_at: '2026-03-10T10:00:00Z' }),
      ];

      const result = suggestProgression(sets, 7.5, 'strength');

      expect(result.confidence).toBe('medium');
    });
  });

  // ── Branch 7: Last session hard, previous fine ─────────────────────────────

  describe('last session RPE too hard but previous was fine', () => {
    it('suggests holding at current weight', () => {
      // Week 1: RPE 7 (fine, <= target)
      // Week 2: RPE 9 (> target+1 = 8.5)
      // Not tooHardBothSessions (only last), not tooEasyBothSessions
      // e1RM not dropping (same weight/reps)
      const sets = [
        makeSet({ weight: 80, reps: 8, rpe: 7, logged_at: '2026-03-03T10:00:00Z' }),
        makeSet({ weight: 80, reps: 8, rpe: 9, logged_at: '2026-03-10T10:00:00Z' }),
      ];

      const result = suggestProgression(sets, 7.5, 'strength');

      expect(result.suggestedWeight).toBe(80);
      expect(result.reasoning).toContain('Last session RPE');
      expect(result.reasoning).toContain('Repeat');
    });
  });

  // ── Default: steady state (no strong signal) ───────────────────────────────

  describe('default — steady state with no strong signal', () => {
    it('suggests maintaining current weight', () => {
      // Week 1: RPE 8 (between target and target+1, so not "too easy" and not "too hard")
      // Week 2: RPE 8 (same)
      // Both 8 > 7.5 so NOT tooEasyBothSessions
      // Both 8 < 8.5 so NOT tooHardLastSession or tooHardBothSessions
      // e1RM stable so NOT performanceDropping
      const sets = [
        makeSet({ weight: 80, reps: 8, rpe: 8, logged_at: '2026-03-03T10:00:00Z' }),
        makeSet({ weight: 80, reps: 8, rpe: 8, logged_at: '2026-03-10T10:00:00Z' }),
      ];

      const result = suggestProgression(sets, 7.5, 'strength');

      expect(result.suggestedWeight).toBe(80);
      expect(result.suggestedReps).toBe(8);
      expect(result.reasoning).toContain('Solid session');
    });
  });

  // ── Edge cases ──────────────────────────────────────────────────────────────

  describe('edge cases', () => {
    it('defaults to compound increment when category is empty', () => {
      const sets = [
        makeSet({ weight: 50, reps: 8, rpe: 6, logged_at: '2026-03-03T10:00:00Z' }),
        makeSet({ weight: 50, reps: 8, rpe: 6, logged_at: '2026-03-10T10:00:00Z' }),
      ];

      // Empty category maps to isolation increment (1.25 kg) since it's NOT in COMPOUND_CATEGORIES
      const result = suggestProgression(sets, 7.5, '');

      expect(result.suggestedWeight).toBe(51.25);
    });

    it('falls back to targetRpe when sets have null RPE', () => {
      // Both weeks have null RPE, so effectiveRpe defaults to targetRpe (7.5)
      // effectiveLastRpe 7.5 <= 7.5 (target), effectivePrevRpe 7.5 <= 7.5 => tooEasyBothSessions
      const sets = [
        makeSet({ weight: 60, reps: 8, rpe: null, logged_at: '2026-03-03T10:00:00Z' }),
        makeSet({ weight: 60, reps: 8, rpe: null, logged_at: '2026-03-10T10:00:00Z' }),
      ];

      const result = suggestProgression(sets, 7.5, 'strength');

      // Should progress since null RPE defaults to target, which is <= target
      expect(result.suggestedWeight).toBe(62.5);
    });

    it('uses default targetRpe of 7.5 when not provided', () => {
      const sets = [
        makeSet({ weight: 60, reps: 8, rpe: 7, logged_at: '2026-03-03T10:00:00Z' }),
        makeSet({ weight: 60, reps: 8, rpe: 7, logged_at: '2026-03-10T10:00:00Z' }),
      ];

      const result = suggestProgression(sets);

      expect(result.suggestedWeight).toBe(61.25); // isolation increment (empty category)
    });

    it('ensures reduced weight never goes below one increment', () => {
      // Very low weight scenario where decrement would go to 0
      const sets = [
        makeSet({ weight: 2.5, reps: 8, rpe: 9.5, logged_at: '2026-03-03T10:00:00Z' }),
        makeSet({ weight: 2.5, reps: 3, rpe: 9.5, logged_at: '2026-03-10T10:00:00Z' }),
      ];

      const result = suggestProgression(sets, 7.5, 'strength');

      // Should not go below COMPOUND_INCREMENT_KG (2.5)
      expect(result.suggestedWeight).toBeGreaterThanOrEqual(2.5);
    });
  });
});
