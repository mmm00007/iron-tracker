import { useEffect, useState, type ReactNode } from 'react';
import { useNavigate, useLocation } from '@tanstack/react-router';
import { Box, CircularProgress, Snackbar, Alert } from '@mui/material';
import { useAuthStore } from '@/stores/authStore';
import { useProfile } from '@/hooks/useProfile';

// Routes accessible mid-onboarding (hoisted to module scope for referential stability)
const ONBOARDING_ALLOWED_PATHS = new Set(['/onboarding', '/log/identify']);

interface AuthGuardProps {
  children: ReactNode;
}

export function AuthGuard({ children }: AuthGuardProps) {
  const { user, loading, sessionExpired } = useAuthStore();
  const location = useLocation();
  const navigate = useNavigate();
  const { data: profile, isLoading: profileLoading } = useProfile();
  const [showExpiredToast, setShowExpiredToast] = useState(false);

  const isAuthLoading = loading || (user != null && profileLoading);

  // Redirect unauthenticated users to login — deferred to avoid render-time
  // navigation which causes TanStack Router's buildAndCommitLocation loop.
  // When the session expired unexpectedly, show a brief warning first.
  useEffect(() => {
    if (!isAuthLoading && !user) {
      if (sessionExpired) {
        setShowExpiredToast(true);
        const timer = setTimeout(() => {
          // Clear the flag so it doesn't re-trigger after the next login
          useAuthStore.setState({ sessionExpired: false });
          void navigate({ to: '/login' });
        }, 2000);
        return () => clearTimeout(timer);
      } else {
        void navigate({ to: '/login' });
      }
    }
  }, [isAuthLoading, user, sessionExpired, navigate]);

  // Redirect to onboarding if the user hasn't completed it yet.
  useEffect(() => {
    if (
      !isAuthLoading &&
      user &&
      profile &&
      !profile.onboarding_completed &&
      !ONBOARDING_ALLOWED_PATHS.has(location.pathname)
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
        <CircularProgress aria-label="Loading, please wait" />
        <Snackbar
          open={showExpiredToast}
          anchorOrigin={{ vertical: 'top', horizontal: 'center' }}
        >
          <Alert severity="warning" variant="filled" sx={{ width: '100%' }}>
            Session expired — please sign in again
          </Alert>
        </Snackbar>
      </Box>
    );
  }

  // While the onboarding redirect is pending (profile loaded but not completed),
  // keep showing the spinner so the protected page content never flashes.
  // Exception: allow /log/identify so the camera flow works during onboarding step 4.
  if (profile && !profile.onboarding_completed && !ONBOARDING_ALLOWED_PATHS.has(location.pathname)) {
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
