import { get, set, del } from 'idb-keyval';
import type { PersistedClient } from '@tanstack/react-query-persist-client';

/**
 * Async persister backed by IndexedDB via idb-keyval.
 * Used with PersistQueryClientProvider to survive page reloads offline.
 */
export const indexedDBPersister = {
  persistClient: async (client: PersistedClient): Promise<void> => {
    await set('iron-tracker-query-cache', client);
  },

  restoreClient: async (): Promise<PersistedClient | undefined> => {
    return await get<PersistedClient>('iron-tracker-query-cache');
  },

  removeClient: async (): Promise<void> => {
    await del('iron-tracker-query-cache');
  },
};
