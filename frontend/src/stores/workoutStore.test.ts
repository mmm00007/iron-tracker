import { describe, it, expect, beforeEach, vi } from 'vitest';
import { useWorkoutStore } from './workoutStore';

describe('workoutStore', () => {
  beforeEach(() => {
    useWorkoutStore.setState({
      restTimerEndTime: null,
      restTimerDuration: 90,
      isRestTimerActive: false,
      currentWeight: 20,
      currentReps: 8,
      currentRpe: null,
      currentSetType: 'working',
      currentNotes: '',
      hasUserEdited: false,
    });
  });

  describe('initial state', () => {
    it('has default weight of 20', () => {
      expect(useWorkoutStore.getState().currentWeight).toBe(20);
    });

    it('has default reps of 8', () => {
      expect(useWorkoutStore.getState().currentReps).toBe(8);
    });

    it('has null RPE', () => {
      expect(useWorkoutStore.getState().currentRpe).toBeNull();
    });

    it('has working as default set type', () => {
      expect(useWorkoutStore.getState().currentSetType).toBe('working');
    });

    it('has empty notes', () => {
      expect(useWorkoutStore.getState().currentNotes).toBe('');
    });

    it('has hasUserEdited as false', () => {
      expect(useWorkoutStore.getState().hasUserEdited).toBe(false);
    });

    it('has rest timer inactive', () => {
      expect(useWorkoutStore.getState().isRestTimerActive).toBe(false);
      expect(useWorkoutStore.getState().restTimerEndTime).toBeNull();
    });

    it('has default rest timer duration of 90 seconds', () => {
      expect(useWorkoutStore.getState().restTimerDuration).toBe(90);
    });
  });

  describe('setWeight', () => {
    it('sets the current weight', () => {
      useWorkoutStore.getState().setWeight(100);
      expect(useWorkoutStore.getState().currentWeight).toBe(100);
    });

    it('clamps weight to zero for negative values', () => {
      useWorkoutStore.getState().setWeight(-5);
      expect(useWorkoutStore.getState().currentWeight).toBe(0);
    });

    it('allows zero weight', () => {
      useWorkoutStore.getState().setWeight(0);
      expect(useWorkoutStore.getState().currentWeight).toBe(0);
    });

    it('sets hasUserEdited to true', () => {
      useWorkoutStore.getState().setWeight(50);
      expect(useWorkoutStore.getState().hasUserEdited).toBe(true);
    });
  });

  describe('setReps', () => {
    it('sets the current reps', () => {
      useWorkoutStore.getState().setReps(12);
      expect(useWorkoutStore.getState().currentReps).toBe(12);
    });

    it('clamps reps to zero for negative values', () => {
      useWorkoutStore.getState().setReps(-3);
      expect(useWorkoutStore.getState().currentReps).toBe(0);
    });

    it('allows zero reps', () => {
      useWorkoutStore.getState().setReps(0);
      expect(useWorkoutStore.getState().currentReps).toBe(0);
    });

    it('sets hasUserEdited to true', () => {
      useWorkoutStore.getState().setReps(10);
      expect(useWorkoutStore.getState().hasUserEdited).toBe(true);
    });
  });

  describe('setRpe and setSetType and setNotes', () => {
    it('sets RPE value', () => {
      useWorkoutStore.getState().setRpe(8);
      expect(useWorkoutStore.getState().currentRpe).toBe(8);
    });

    it('sets RPE to null', () => {
      useWorkoutStore.setState({ currentRpe: 7 });
      useWorkoutStore.getState().setRpe(null);
      expect(useWorkoutStore.getState().currentRpe).toBeNull();
    });

    it('sets set type', () => {
      useWorkoutStore.getState().setSetType('warmup');
      expect(useWorkoutStore.getState().currentSetType).toBe('warmup');
    });

    it('sets notes', () => {
      useWorkoutStore.getState().setNotes('Felt strong today');
      expect(useWorkoutStore.getState().currentNotes).toBe('Felt strong today');
    });
  });

  describe('startRestTimer', () => {
    it('sets endTime based on duration', () => {
      const before = Date.now();
      useWorkoutStore.getState().startRestTimer(120);
      const after = Date.now();

      const state = useWorkoutStore.getState();
      expect(state.isRestTimerActive).toBe(true);
      expect(state.restTimerDuration).toBe(120);
      expect(state.restTimerEndTime).toBeGreaterThanOrEqual(before + 120 * 1000);
      expect(state.restTimerEndTime).toBeLessThanOrEqual(after + 120 * 1000);
    });

    it('sets isActive to true', () => {
      useWorkoutStore.getState().startRestTimer(60);
      expect(useWorkoutStore.getState().isRestTimerActive).toBe(true);
    });
  });

  describe('stopRestTimer', () => {
    it('clears rest timer state', () => {
      useWorkoutStore.getState().startRestTimer(90);
      useWorkoutStore.getState().stopRestTimer();

      const state = useWorkoutStore.getState();
      expect(state.restTimerEndTime).toBeNull();
      expect(state.isRestTimerActive).toBe(false);
    });
  });

  describe('adjustRestTimer', () => {
    it('adds seconds to the rest timer', () => {
      const now = Date.now();
      vi.spyOn(Date, 'now').mockReturnValue(now);

      useWorkoutStore.setState({
        restTimerEndTime: now + 60_000,
        isRestTimerActive: true,
      });

      useWorkoutStore.getState().adjustRestTimer(30);
      expect(useWorkoutStore.getState().restTimerEndTime).toBe(now + 90_000);

      vi.restoreAllMocks();
    });

    it('does nothing when timer is not active', () => {
      useWorkoutStore.setState({
        restTimerEndTime: null,
        isRestTimerActive: false,
      });

      useWorkoutStore.getState().adjustRestTimer(30);
      expect(useWorkoutStore.getState().restTimerEndTime).toBeNull();
    });

    it('does not let endTime go below now + 1 second', () => {
      const now = Date.now();
      vi.spyOn(Date, 'now').mockReturnValue(now);

      useWorkoutStore.setState({
        restTimerEndTime: now + 5_000,
        isRestTimerActive: true,
      });

      useWorkoutStore.getState().adjustRestTimer(-60);
      // Should clamp to at least now + 1000
      expect(useWorkoutStore.getState().restTimerEndTime).toBe(now + 1_000);

      vi.restoreAllMocks();
    });
  });

  describe('resetInput', () => {
    it('resets RPE, setType, and notes', () => {
      useWorkoutStore.setState({
        currentRpe: 9,
        currentSetType: 'amrap',
        currentNotes: 'Some note',
      });

      useWorkoutStore.getState().resetInput();

      const state = useWorkoutStore.getState();
      expect(state.currentRpe).toBeNull();
      expect(state.currentSetType).toBe('working');
      expect(state.currentNotes).toBe('');
    });

    it('does NOT reset weight or reps', () => {
      useWorkoutStore.setState({
        currentWeight: 100,
        currentReps: 5,
      });

      useWorkoutStore.getState().resetInput();

      const state = useWorkoutStore.getState();
      expect(state.currentWeight).toBe(100);
      expect(state.currentReps).toBe(5);
    });
  });

  describe('resetUserEdited', () => {
    it('sets hasUserEdited to false', () => {
      useWorkoutStore.setState({ hasUserEdited: true });
      useWorkoutStore.getState().resetUserEdited();
      expect(useWorkoutStore.getState().hasUserEdited).toBe(false);
    });
  });

  describe('prefillFromSet', () => {
    it('sets weight, reps, and rpe from a set', () => {
      useWorkoutStore.getState().prefillFromSet({
        weight: 80,
        reps: 5,
        rpe: 7.5,
      });

      const state = useWorkoutStore.getState();
      expect(state.currentWeight).toBe(80);
      expect(state.currentReps).toBe(5);
      expect(state.currentRpe).toBe(7.5);
    });

    it('sets rpe to null when set has undefined rpe', () => {
      useWorkoutStore.setState({ currentRpe: 8 });
      useWorkoutStore.getState().prefillFromSet({
        weight: 60,
        reps: 10,
        rpe: undefined as unknown as number | null,
      });
      expect(useWorkoutStore.getState().currentRpe).toBeNull();
    });

    it('clears hasUserEdited', () => {
      useWorkoutStore.setState({ hasUserEdited: true });
      useWorkoutStore.getState().prefillFromSet({
        weight: 60,
        reps: 10,
        rpe: null,
      });
      expect(useWorkoutStore.getState().hasUserEdited).toBe(false);
    });
  });
});
