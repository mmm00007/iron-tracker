import { useEffect } from 'react';
import { ThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { QueryClientProvider } from '@tanstack/react-query';
import { RouterProvider } from '@tanstack/react-router';
import { theme } from '@/theme';
import { queryClient } from '@/lib/queryClient';
import { router } from '@/router';
import { useAuthStore } from '@/stores/authStore';

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
    <QueryClientProvider client={queryClient}>
      <RouterProvider router={router} />
    </QueryClientProvider>
  );
}

export function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <AppProviders />
    </ThemeProvider>
  );
}
