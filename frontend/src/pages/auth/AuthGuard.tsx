import { useEffect, type ReactNode } from 'react';
import { useNavigate, useLocation } from '@tanstack/react-router';
import { Box, CircularProgress } from '@mui/material';
import { useAuthStore } from '@/stores/authStore';
import { useProfile } from '@/hooks/useProfile';

interface AuthGuardProps {
  children: ReactNode;
}

export function AuthGuard({ children }: AuthGuardProps) {
  const { user, loading } = useAuthStore();
  const location = useLocation();
  const navigate = useNavigate();
  const { data: profile, isLoading: profileLoading } = useProfile();

  const isAuthLoading = loading || (user != null && profileLoading);

  // Redirect unauthenticated users to login — deferred to avoid render-time
  // navigation which causes TanStack Router's buildAndCommitLocation loop.
  useEffect(() => {
    if (!isAuthLoading && !user) {
      void navigate({ to: '/login' });
    }
  }, [isAuthLoading, user, navigate]);

  // Redirect to onboarding if the user hasn't completed it yet.
  useEffect(() => {
    if (
      !isAuthLoading &&
      user &&
      profile &&
      !profile.onboarding_completed &&
      location.pathname !== '/onboarding'
    ) {
      void navigate({ to: '/onboarding' });
    }
  }, [isAuthLoading, user, profile, location.pathname, navigate]);

  if (isAuthLoading || !user) {
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

  // While the onboarding redirect is pending (profile loaded but not completed),
  // keep showing the spinner so the protected page content never flashes.
  if (profile && !profile.onboarding_completed) {
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

  return <>{children}</>;
}
