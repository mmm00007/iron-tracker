import { QueryClient } from '@tanstack/react-query';

/** 24 hours — matches PersistQueryClientProvider maxAge */
const GC_TIME_24H = 1000 * 60 * 60 * 24;

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      // Analytics data stays fresh for 5 minutes
      staleTime: 5 * 60 * 1000,
      // Retry failed requests up to 2 times
      retry: 2,
      // Keep data in cache for 24 hours so offline users can still read it
      gcTime: GC_TIME_24H,
      // Return cached data while re-fetching — never show a blank screen offline
      networkMode: 'offlineFirst',
    },
    mutations: {
      // Queue mutations when offline; retry with exponential backoff (1s, 2s, 4s)
      networkMode: 'offlineFirst',
      retry: 3,
      retryDelay: (attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30_000),
    },
  },
});
