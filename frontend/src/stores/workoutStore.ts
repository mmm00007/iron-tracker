import { create } from 'zustand';
import type { WorkoutSet } from '@/types/database';

type SetType = 'warmup' | 'working' | 'dropset' | 'amrap' | 'failure';

interface WorkoutState {
  // Rest timer
  restTimerEndTime: number | null;
  restTimerDuration: number; // seconds
  isRestTimerActive: boolean;

  // Current input
  currentWeight: number;
  currentReps: number;
  currentRpe: number | null;
  currentSetType: SetType;
  currentNotes: string;

  // Actions
  setWeight: (w: number) => void;
  setReps: (r: number) => void;
  setRpe: (rpe: number | null) => void;
  setSetType: (type: SetType) => void;
  setNotes: (notes: string) => void;
  startRestTimer: (duration: number) => void;
  adjustRestTimer: (seconds: number) => void;
  stopRestTimer: () => void;
  resetInput: () => void;
  prefillFromSet: (set: Pick<WorkoutSet, 'weight' | 'reps' | 'rpe'>) => void;
}

export const useWorkoutStore = create<WorkoutState>((set, get) => ({
  // Rest timer
  restTimerEndTime: null,
  restTimerDuration: 90,
  isRestTimerActive: false,

  // Current input defaults
  currentWeight: 20,
  currentReps: 8,
  currentRpe: null,
  currentSetType: 'working',
  currentNotes: '',

  setWeight: (w) => set({ currentWeight: Math.max(0, w) }),
  setReps: (r) => set({ currentReps: Math.max(0, r) }),
  setRpe: (rpe) => set({ currentRpe: rpe }),
  setSetType: (type) => set({ currentSetType: type }),
  setNotes: (notes) => set({ currentNotes: notes }),

  startRestTimer: (duration) => {
    set({
      restTimerDuration: duration,
      restTimerEndTime: Date.now() + duration * 1000,
      isRestTimerActive: true,
    });
  },

  adjustRestTimer: (seconds) => {
    const { restTimerEndTime, isRestTimerActive } = get();
    if (!isRestTimerActive || restTimerEndTime === null) return;
    const newEndTime = Math.max(Date.now() + 1000, restTimerEndTime + seconds * 1000);
    set({ restTimerEndTime: newEndTime });
  },

  stopRestTimer: () => {
    set({ restTimerEndTime: null, isRestTimerActive: false });
  },

  resetInput: () => {
    set({
      currentRpe: null,
      currentSetType: 'working',
      currentNotes: '',
    });
  },

  prefillFromSet: (s) => {
    set({
      currentWeight: s.weight,
      currentReps: s.reps,
      currentRpe: s.rpe ?? null,
    });
  },
}));
