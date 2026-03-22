import { useWorkoutStore } from '@/stores/workoutStore';
import { RestTimerPill } from '@/components/log/RestTimerPill';

/**
 * GlobalRestTimer — renders the RestTimerPill when a rest timer is active,
 * connected to the global workoutStore. Mounted in AppLayout so it persists
 * across all screens.
 */
export function GlobalRestTimer() {
  const isActive = useWorkoutStore((s) => s.isRestTimerActive);
  const endTime = useWorkoutStore((s) => s.restTimerEndTime);
  const duration = useWorkoutStore((s) => s.restTimerDuration);
  const stopRestTimer = useWorkoutStore((s) => s.stopRestTimer);
  const adjustRestTimer = useWorkoutStore((s) => s.adjustRestTimer);

  if (!isActive || endTime === null) return null;

  return (
    <RestTimerPill
      durationSeconds={duration}
      endTime={endTime}
      onDismiss={stopRestTimer}
      onAddTime={(seconds) => adjustRestTimer(seconds)}
      onSubtractTime={(seconds) => adjustRestTimer(-seconds)}
    />
  );
}
