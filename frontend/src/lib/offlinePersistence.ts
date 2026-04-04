import { get, set, del } from 'idb-keyval';
import type { PersistedClient } from '@tanstack/react-query-persist-client';

/**
 * Async persister backed by IndexedDB via idb-keyval.
 * Used with PersistQueryClientProvider to survive page reloads offline.
 */
export const indexedDBPersister = {
  persistClient: async (client: PersistedClient): Promise<void> => {
    try {
      await set('iron-tracker-query-cache', client);
    } catch (err) {
      // Safari quota exceeded or private browsing — degrade gracefully.
      // Sentry captures console.warn via breadcrumbs.
      console.warn('[iron-tracker] Failed to persist query cache to IndexedDB:', err);
    }
  },

  restoreClient: async (): Promise<PersistedClient | undefined> => {
    try {
      return await get<PersistedClient>('iron-tracker-query-cache');
    } catch (err) {
      console.warn('[iron-tracker] Failed to restore query cache from IndexedDB:', err);
      return undefined;
    }
  },

  removeClient: async (): Promise<void> => {
    try {
      await del('iron-tracker-query-cache');
    } catch {
      // Ignore — removal failure is non-critical
    }
  },
};
