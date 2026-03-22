import { create } from 'zustand';

interface OfflineState {
  /** Number of mutations that have been submitted but not yet confirmed by the server. */
  pendingMutations: number;
  /** Timestamp of the most recent successful sync (null if never synced this session). */
  lastSyncAt: Date | null;
  /** True while at least one mutation is in flight after coming back online. */
  isSyncing: boolean;
  /** Human-readable error message from the last failed sync, or null. */
  syncError: string | null;

  incrementPending: () => void;
  decrementPending: () => void;
  setSyncing: (syncing: boolean) => void;
  setSyncError: (error: string | null) => void;
  setLastSync: (date: Date) => void;
}

export const useOfflineStore = create<OfflineState>((set) => ({
  pendingMutations: 0,
  lastSyncAt: null,
  isSyncing: false,
  syncError: null,

  incrementPending: () =>
    set((state) => ({
      pendingMutations: state.pendingMutations + 1,
      isSyncing: true,
      syncError: null,
    })),

  decrementPending: () =>
    set((state) => {
      const next = Math.max(0, state.pendingMutations - 1);
      return {
        pendingMutations: next,
        isSyncing: next > 0,
      };
    }),

  setSyncing: (syncing) => set({ isSyncing: syncing }),

  setSyncError: (error) => set({ syncError: error, isSyncing: false }),

  setLastSync: (date) => set({ lastSyncAt: date, syncError: null }),
}));
