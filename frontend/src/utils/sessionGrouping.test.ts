import { describe, it, expect } from 'vitest';
import { groupSetsIntoSessions } from './sessionGrouping';
import type { WorkoutSet } from '@/types/database';

function makeSet(overrides: Partial<WorkoutSet> & { logged_at: string; exerciseName?: string }): WorkoutSet & { exerciseName?: string } {
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

describe('groupSetsIntoSessions', () => {
  it('groups 5 sets within 60 minutes into 1 session', () => {
    const base = new Date('2025-03-20T10:00:00Z').getTime();
    const sets = [
      makeSet({ logged_at: new Date(base).toISOString() }),
      makeSet({ logged_at: new Date(base + 10 * 60_000).toISOString() }),
      makeSet({ logged_at: new Date(base + 20 * 60_000).toISOString() }),
      makeSet({ logged_at: new Date(base + 40 * 60_000).toISOString() }),
      makeSet({ logged_at: new Date(base + 60 * 60_000).toISOString() }),
    ];

    const sessions = groupSetsIntoSessions(sets);
    expect(sessions).toHaveLength(1);
    expect(sessions[0]!.totalSets).toBe(5);
  });

  it('splits sets with 2-hour gap into 2 sessions', () => {
    const base = new Date('2025-03-20T08:00:00Z').getTime();
    const morningEnd = base + 60 * 60_000; // +60 min
    const afternoonStart = morningEnd + 120 * 60_000; // +2 hours gap

    const sets = [
      makeSet({ logged_at: new Date(base).toISOString() }),
      makeSet({ logged_at: new Date(base + 15 * 60_000).toISOString() }),
      makeSet({ logged_at: new Date(morningEnd).toISOString() }),
      makeSet({ logged_at: new Date(afternoonStart).toISOString() }),
      makeSet({ logged_at: new Date(afternoonStart + 20 * 60_000).toISOString() }),
    ];

    const sessions = groupSetsIntoSessions(sets);
    expect(sessions).toHaveLength(2);
    // Newest first
    expect(sessions[0]!.totalSets).toBe(2);
    expect(sessions[1]!.totalSets).toBe(3);
  });

  it('returns empty array for empty sets', () => {
    const sessions = groupSetsIntoSessions([]);
    expect(sessions).toHaveLength(0);
  });

  it('keeps midnight-spanning sets in the same session when gap < 90 min', () => {
    // Sets at 23:45 and 00:15 = 30 minute gap, well within 90min threshold
    const sets = [
      makeSet({ logged_at: '2025-03-20T23:45:00Z' }),
      makeSet({ logged_at: '2025-03-20T23:55:00Z' }),
      makeSet({ logged_at: '2025-03-21T00:05:00Z' }),
      makeSet({ logged_at: '2025-03-21T00:15:00Z' }),
    ];

    const sessions = groupSetsIntoSessions(sets);
    expect(sessions).toHaveLength(1);
    expect(sessions[0]!.totalSets).toBe(4);
  });

  it('computes total volume correctly', () => {
    const sets = [
      makeSet({ logged_at: '2025-03-20T10:00:00Z', weight: 100, reps: 5 }),
      makeSet({ logged_at: '2025-03-20T10:05:00Z', weight: 100, reps: 5 }),
      makeSet({ logged_at: '2025-03-20T10:10:00Z', weight: 80, reps: 10 }),
    ];

    const sessions = groupSetsIntoSessions(sets);
    expect(sessions).toHaveLength(1);
    // 100*5 + 100*5 + 80*10 = 500 + 500 + 800 = 1800
    expect(sessions[0]!.totalVolume).toBe(1800);
  });

  it('aggregates exercise summaries within a session', () => {
    const sets = [
      makeSet({ logged_at: '2025-03-20T10:00:00Z', exercise_id: 'ex-1', exerciseName: 'Bench Press', weight: 100, reps: 5 }),
      makeSet({ logged_at: '2025-03-20T10:05:00Z', exercise_id: 'ex-1', exerciseName: 'Bench Press', weight: 110, reps: 3 }),
      makeSet({ logged_at: '2025-03-20T10:10:00Z', exercise_id: 'ex-2', exerciseName: 'Squat', weight: 140, reps: 5 }),
    ];

    const sessions = groupSetsIntoSessions(sets);
    expect(sessions).toHaveLength(1);
    expect(sessions[0]!.exerciseCount).toBe(2);
    expect(sessions[0]!.exercises).toHaveLength(2);

    const bench = sessions[0]!.exercises.find((e) => e.exerciseId === 'ex-1');
    expect(bench).toBeDefined();
    expect(bench!.setCount).toBe(2);
    expect(bench!.topSet.weight).toBe(110); // heaviest
  });

  it('returns sessions sorted newest first', () => {
    const sets = [
      makeSet({ logged_at: '2025-03-18T10:00:00Z' }),
      makeSet({ logged_at: '2025-03-20T10:00:00Z' }),
      makeSet({ logged_at: '2025-03-19T10:00:00Z' }),
    ];

    const sessions = groupSetsIntoSessions(sets);
    expect(sessions).toHaveLength(3); // each 24h apart > 90min gap
    expect(sessions[0]!.startedAt).toContain('2025-03-20');
    expect(sessions[1]!.startedAt).toContain('2025-03-19');
    expect(sessions[2]!.startedAt).toContain('2025-03-18');
  });

  it('handles single set as one session', () => {
    const sets = [makeSet({ logged_at: '2025-03-20T10:00:00Z' })];
    const sessions = groupSetsIntoSessions(sets);
    expect(sessions).toHaveLength(1);
    expect(sessions[0]!.totalSets).toBe(1);
  });

  it('respects custom gap parameter', () => {
    const sets = [
      makeSet({ logged_at: '2025-03-20T10:00:00Z' }),
      makeSet({ logged_at: '2025-03-20T10:40:00Z' }), // 40 min gap
    ];

    // With default 90min gap: 1 session
    expect(groupSetsIntoSessions(sets)).toHaveLength(1);

    // With 30min gap: 2 sessions (40 > 30)
    expect(groupSetsIntoSessions(sets, 30)).toHaveLength(2);
  });
});
