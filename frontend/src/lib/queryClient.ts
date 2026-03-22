import { QueryClient } from '@tanstack/react-query';

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      // Analytics data stays fresh for 5 minutes
      staleTime: 5 * 60 * 1000,
      // Retry failed requests up to 2 times
      retry: 2,
      // Keep data in cache for 10 minutes after unmount
      gcTime: 10 * 60 * 1000,
    },
    mutations: {
      retry: 1,
    },
  },
});
