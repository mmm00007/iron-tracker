import { describe, it, expect, beforeEach } from 'vitest';
import { useOfflineStore } from './offlineStore';

describe('offlineStore', () => {
  beforeEach(() => {
    useOfflineStore.setState({
      pendingMutations: 0,
      lastSyncAt: null,
      isSyncing: false,
      syncError: null,
    });
  });

  describe('initial state', () => {
    it('has zero pending mutations', () => {
      expect(useOfflineStore.getState().pendingMutations).toBe(0);
    });

    it('has null lastSyncAt', () => {
      expect(useOfflineStore.getState().lastSyncAt).toBeNull();
    });

    it('is not syncing', () => {
      expect(useOfflineStore.getState().isSyncing).toBe(false);
    });

    it('has no sync error', () => {
      expect(useOfflineStore.getState().syncError).toBeNull();
    });
  });

  describe('incrementPending', () => {
    it('increments pending mutation count', () => {
      useOfflineStore.getState().incrementPending();
      expect(useOfflineStore.getState().pendingMutations).toBe(1);
    });

    it('increments multiple times', () => {
      useOfflineStore.getState().incrementPending();
      useOfflineStore.getState().incrementPending();
      useOfflineStore.getState().incrementPending();
      expect(useOfflineStore.getState().pendingMutations).toBe(3);
    });

    it('sets isSyncing to true', () => {
      useOfflineStore.getState().incrementPending();
      expect(useOfflineStore.getState().isSyncing).toBe(true);
    });

    it('clears any existing sync error', () => {
      useOfflineStore.setState({ syncError: 'Network failure' });
      useOfflineStore.getState().incrementPending();
      expect(useOfflineStore.getState().syncError).toBeNull();
    });
  });

  describe('decrementPending', () => {
    it('decrements pending mutation count', () => {
      useOfflineStore.setState({ pendingMutations: 3, isSyncing: true });
      useOfflineStore.getState().decrementPending();
      expect(useOfflineStore.getState().pendingMutations).toBe(2);
    });

    it('sets isSyncing to false when reaching zero', () => {
      useOfflineStore.setState({ pendingMutations: 1, isSyncing: true });
      useOfflineStore.getState().decrementPending();
      expect(useOfflineStore.getState().pendingMutations).toBe(0);
      expect(useOfflineStore.getState().isSyncing).toBe(false);
    });

    it('keeps isSyncing true when count is still above zero', () => {
      useOfflineStore.setState({ pendingMutations: 2, isSyncing: true });
      useOfflineStore.getState().decrementPending();
      expect(useOfflineStore.getState().pendingMutations).toBe(1);
      expect(useOfflineStore.getState().isSyncing).toBe(true);
    });

    it('does not go below zero', () => {
      useOfflineStore.setState({ pendingMutations: 0 });
      useOfflineStore.getState().decrementPending();
      expect(useOfflineStore.getState().pendingMutations).toBe(0);
    });
  });

  describe('setSyncing', () => {
    it('sets isSyncing to true', () => {
      useOfflineStore.getState().setSyncing(true);
      expect(useOfflineStore.getState().isSyncing).toBe(true);
    });

    it('sets isSyncing to false', () => {
      useOfflineStore.setState({ isSyncing: true });
      useOfflineStore.getState().setSyncing(false);
      expect(useOfflineStore.getState().isSyncing).toBe(false);
    });
  });

  describe('setSyncError', () => {
    it('sets error message', () => {
      useOfflineStore.getState().setSyncError('Connection lost');
      expect(useOfflineStore.getState().syncError).toBe('Connection lost');
    });

    it('stops syncing when error is set', () => {
      useOfflineStore.setState({ isSyncing: true });
      useOfflineStore.getState().setSyncError('Timeout');
      expect(useOfflineStore.getState().isSyncing).toBe(false);
    });

    it('clears error when null is passed', () => {
      useOfflineStore.setState({ syncError: 'Previous error' });
      useOfflineStore.getState().setSyncError(null);
      expect(useOfflineStore.getState().syncError).toBeNull();
    });
  });

  describe('setLastSync', () => {
    it('sets lastSyncAt date', () => {
      const now = new Date('2026-03-25T12:00:00Z');
      useOfflineStore.getState().setLastSync(now);
      expect(useOfflineStore.getState().lastSyncAt).toEqual(now);
    });

    it('clears sync error when last sync is set', () => {
      useOfflineStore.setState({ syncError: 'Stale error' });
      useOfflineStore.getState().setLastSync(new Date());
      expect(useOfflineStore.getState().syncError).toBeNull();
    });
  });
});
