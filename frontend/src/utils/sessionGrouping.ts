import type { WorkoutSet } from '@/types/database';

export interface SessionExerciseSummary {
  exerciseId: string;
  exerciseName: string;
  setCount: number;
  topSet: { weight: number; reps: number; unit: string };
}

export interface SessionGroup {
  /** Stable ID derived from the first set's timestamp */
  id: string;
  startedAt: string;
  endedAt: string;
  totalSets: number;
  exerciseCount: number;
  totalVolume: number;
  exercises: SessionExerciseSummary[];
  sets: WorkoutSet[];
}

interface SetWithExerciseName extends WorkoutSet {
  exerciseName?: string;
}

const DEFAULT_GAP_MINUTES = 90;

/**
 * Groups an array of sets into workout sessions using the inactivity gap rule.
 *
 * Sets must already include an `exerciseName` field (joined from exercises table)
 * or the summary will fall back to the exercise_id.
 *
 * Returns sessions sorted newest first.
 */
export function groupSetsIntoSessions(
  sets: SetWithExerciseName[],
  gapMinutes: number = DEFAULT_GAP_MINUTES,
): SessionGroup[] {
  if (sets.length === 0) return [];

  // Sort ascending by logged_at to walk chronologically
  const sorted = [...sets].sort(
    (a, b) => new Date(a.logged_at).getTime() - new Date(b.logged_at).getTime(),
  );

  const gapMs = gapMinutes * 60 * 1000;
  const rawSessions: SetWithExerciseName[][] = [];
  let current: SetWithExerciseName[] = [sorted[0]];

  for (let i = 1; i < sorted.length; i++) {
    const prev = sorted[i - 1];
    const curr = sorted[i];
    const gap = new Date(curr.logged_at).getTime() - new Date(prev.logged_at).getTime();

    if (gap > gapMs) {
      rawSessions.push(current);
      current = [curr];
    } else {
      current.push(curr);
    }
  }
  rawSessions.push(current);

  // Build SessionGroup objects
  const sessions: SessionGroup[] = rawSessions.map((sessionSets) => {
    const startedAt = sessionSets[0].logged_at;
    const endedAt = sessionSets[sessionSets.length - 1].logged_at;

    // Per-exercise aggregation
    const exerciseMap = new Map<
      string,
      { name: string; setCount: number; topSet: { weight: number; reps: number; unit: string } }
    >();

    let totalVolume = 0;

    for (const set of sessionSets) {
      const volume = set.weight * set.reps;
      totalVolume += volume;

      const existing = exerciseMap.get(set.exercise_id);
      if (!existing) {
        exerciseMap.set(set.exercise_id, {
          name: set.exerciseName ?? set.exercise_id,
          setCount: 1,
          topSet: { weight: set.weight, reps: set.reps, unit: set.weight_unit },
        });
      } else {
        existing.setCount += 1;
        // Top set = heaviest weight; ties broken by higher reps
        const currentVolume = existing.topSet.weight * existing.topSet.reps;
        const newVolume = set.weight * set.reps;
        if (
          set.weight > existing.topSet.weight ||
          (set.weight === existing.topSet.weight && newVolume > currentVolume)
        ) {
          existing.topSet = { weight: set.weight, reps: set.reps, unit: set.weight_unit };
        }
      }
    }

    const exercises: SessionExerciseSummary[] = Array.from(exerciseMap.entries()).map(
      ([exerciseId, data]) => ({
        exerciseId,
        exerciseName: data.name,
        setCount: data.setCount,
        topSet: data.topSet,
      }),
    );

    return {
      id: startedAt,
      startedAt,
      endedAt,
      totalSets: sessionSets.length,
      exerciseCount: exerciseMap.size,
      totalVolume,
      exercises,
      sets: sessionSets,
    };
  });

  // Newest first
  return sessions.sort(
    (a, b) => new Date(b.startedAt).getTime() - new Date(a.startedAt).getTime(),
  );
}
