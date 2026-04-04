import { useEffect, useMemo } from 'react';
import { ThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Typography from '@mui/material/Typography';
import { PersistQueryClientProvider } from '@tanstack/react-query-persist-client';
import { RouterProvider } from '@tanstack/react-router';
import * as Sentry from '@sentry/react';
import { createAppTheme } from '@/theme';
import { queryClient } from '@/lib/queryClient';
import { indexedDBPersister } from '@/lib/offlinePersistence';
import { router } from '@/router';
import { useAuthStore } from '@/stores/authStore';
import { useThemeMode } from '@/hooks/useThemeMode';

/** 24 hours in milliseconds — how long the persisted cache is considered valid */
const PERSIST_MAX_AGE = 1000 * 60 * 60 * 24;

function ErrorFallback() {
  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        height: '100dvh',
        gap: 2,
        px: 3,
      }}
    >
      <Typography variant="h6">Something went wrong</Typography>
      <Button variant="contained" onClick={() => window.location.reload()}>
        Reload
      </Button>
    </Box>
  );
}

function AppProviders() {
  const initialize = useAuthStore((state) => state.initialize);

  useEffect(() => {
    let cleanup: (() => void) | undefined;
    void initialize().then((fn) => {
      cleanup = fn;
    });
    return () => cleanup?.();
  }, [initialize]);

  return (
    <PersistQueryClientProvider
      client={queryClient}
      persistOptions={{
        persister: indexedDBPersister,
        maxAge: PERSIST_MAX_AGE,
        buster: '', // bump this string to invalidate the persisted cache on deploys
        dehydrateOptions: {
          shouldDehydrateQuery: (query) => {
            // Only persist essential data offline; skip large analytics payloads
            const key = query.queryKey[0];
            const persistKeys = new Set([
              'exercises', 'muscleGroups', 'profile', 'sets', 'sessions',
              'variants', 'favorites', 'featureFlags',
            ]);
            return typeof key === 'string' && persistKeys.has(key) && query.state.status === 'success';
          },
        },
      }}
      onSuccess={() => {
        if (import.meta.env.DEV) {
          console.log('[iron-tracker] Query cache restored from IndexedDB');
        }
      }}
    >
      <RouterProvider router={router} />
    </PersistQueryClientProvider>
  );
}

export function App() {
  const { mode } = useThemeMode();
  const appTheme = useMemo(() => createAppTheme(mode), [mode]);

  return (
    <Sentry.ErrorBoundary fallback={<ErrorFallback />}>
      <ThemeProvider theme={appTheme}>
        <CssBaseline />
        <AppProviders />
      </ThemeProvider>
    </Sentry.ErrorBoundary>
  );
}
