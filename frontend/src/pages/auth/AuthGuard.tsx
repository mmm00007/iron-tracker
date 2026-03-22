import type { ReactNode } from 'react';
import { Navigate, useLocation } from '@tanstack/react-router';
import { Box, CircularProgress } from '@mui/material';
import { useAuthStore } from '@/stores/authStore';
import { useProfile } from '@/hooks/useProfile';

interface AuthGuardProps {
  children: ReactNode;
}

export function AuthGuard({ children }: AuthGuardProps) {
  const { user, loading } = useAuthStore();
  const location = useLocation();
  const { data: profile, isLoading: profileLoading } = useProfile();

  if (loading || (user && profileLoading)) {
    return (
      <Box
        sx={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          height: '100vh',
          backgroundColor: 'background.default',
        }}
      >
        <CircularProgress />
      </Box>
    );
  }

  if (!user) {
    return <Navigate to="/login" />;
  }

  // Redirect to onboarding if the user hasn't completed it yet,
  // unless they are already on a path that should not trigger this redirect.
  if (
    profile &&
    !profile.onboarding_completed &&
    location.pathname !== '/onboarding'
  ) {
    return <Navigate to="/onboarding" />;
  }

  return <>{children}</>;
}
