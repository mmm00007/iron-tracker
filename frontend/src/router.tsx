import { createRootRoute, createRoute, createRouter, Outlet, redirect, useNavigate } from '@tanstack/react-router';
import { Box, Button, Typography } from '@mui/material';
import * as Sentry from '@sentry/react';
import { AppLayout } from '@/components/layout/AppLayout';
import { AuthGuard } from '@/pages/auth/AuthGuard';
import { LoginPage } from '@/pages/auth/LoginPage';
import { SignUpPage } from '@/pages/auth/SignUpPage';
import { ForgotPasswordPage } from '@/pages/auth/ForgotPasswordPage';
import { ProfilePage } from '@/pages/profile/ProfilePage';
import { ExerciseListPage } from '@/pages/log/ExerciseListPage';
import { SetLoggerPage } from '@/pages/log/SetLoggerPage';
import { VariantManagerPageRoute } from '@/pages/log/VariantManagerPage';
import { HistoryPage } from '@/pages/history/HistoryPage';
import { SessionDetailPage } from '@/pages/history/SessionDetailPage';
import { StatsPage } from '@/pages/stats/StatsPage';
import { ExerciseStatsPage } from '@/pages/stats/ExerciseStatsPage';
import { MachineIdentifyPage } from '@/pages/log/MachineIdentifyPage';
import { OnboardingPage } from '@/pages/onboarding/OnboardingPage';

function PageErrorFallback() {
  const navigate = useNavigate();
  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        minHeight: '50vh',
        gap: 2,
        p: 3,
      }}
    >
      <Typography variant="h6">Something went wrong on this page</Typography>
      <Button variant="contained" onClick={() => navigate({ to: -1 as never })}>
        Go back
      </Button>
    </Box>
  );
}

function NotFoundPage() {
  const navigate = useNavigate();
  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        minHeight: '100vh',
        gap: 2,
        p: 3,
      }}
    >
      <Typography variant="h5">Page not found</Typography>
      <Button variant="contained" onClick={() => navigate({ to: '/log' })}>
        Go to Log
      </Button>
    </Box>
  );
}

// Root route — renders either auth layout or app layout via child routes
const rootRoute = createRootRoute({
  component: Outlet,
  notFoundComponent: NotFoundPage,
});

// Auth layout route — renders auth pages without AppLayout nav
const authLayoutRoute = createRoute({
  getParentRoute: () => rootRoute,
  id: 'auth-layout',
  component: Outlet,
});

// App layout route — renders the main app shell with bottom nav
const appLayoutRoute = createRoute({
  getParentRoute: () => rootRoute,
  id: 'app-layout',
  component: AppLayout,
});

// Index route — redirect to /log
const indexRoute = createRoute({
  getParentRoute: () => appLayoutRoute,
  path: '/',
  beforeLoad: () => {
    throw redirect({ to: '/log' });
  },
});

// --- Auth routes ---

export const loginRoute = createRoute({
  getParentRoute: () => authLayoutRoute,
  path: '/login',
  component: LoginPage,
});

export const signUpRoute = createRoute({
  getParentRoute: () => authLayoutRoute,
  path: '/signup',
  component: SignUpPage,
});

export const forgotPasswordRoute = createRoute({
  getParentRoute: () => authLayoutRoute,
  path: '/forgot-password',
  component: ForgotPasswordPage,
});

// /onboarding — full-screen onboarding flow (no app shell/nav)
export const onboardingRoute = createRoute({
  getParentRoute: () => authLayoutRoute,
  path: '/onboarding',
  component: OnboardingPage,
});

// --- Protected app routes ---

// Wrapper component that applies AuthGuard around the Outlet
function ProtectedOutlet() {
  return (
    <AuthGuard>
      <Outlet />
    </AuthGuard>
  );
}

const protectedLayoutRoute = createRoute({
  getParentRoute: () => appLayoutRoute,
  id: 'protected',
  component: ProtectedOutlet,
});

// /log — exercise list
export const logRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/log',
  component: () => (
    <Sentry.ErrorBoundary fallback={<PageErrorFallback />}>
      <ExerciseListPage />
    </Sentry.ErrorBoundary>
  ),
});

// /log/:exerciseId — set logger
export const setLoggerRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/log/$exerciseId',
  component: () => (
    <Sentry.ErrorBoundary fallback={<PageErrorFallback />}>
      <SetLoggerPage />
    </Sentry.ErrorBoundary>
  ),
});

// /log/identify — AI machine photo identification
export const machineIdentifyRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/log/identify',
  component: MachineIdentifyPage,
});

// /log/:exerciseId/variants — variant manager
export const variantManagerRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/log/$exerciseId/variants',
  component: VariantManagerPageRoute,
});

// /history — session timeline
export const historyRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/history',
  component: () => (
    <Sentry.ErrorBoundary fallback={<PageErrorFallback />}>
      <HistoryPage />
    </Sentry.ErrorBoundary>
  ),
});

// /history/:sessionId — session detail
export const sessionDetailRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/history/$sessionId',
  component: () => (
    <Sentry.ErrorBoundary fallback={<PageErrorFallback />}>
      <SessionDetailPage />
    </Sentry.ErrorBoundary>
  ),
});

// /stats — stats dashboard
export const statsRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/stats',
  validateSearch: (search: Record<string, unknown>) => ({
    period: typeof search.period === 'string' ? search.period : undefined,
  }),
  component: () => (
    <Sentry.ErrorBoundary fallback={<PageErrorFallback />}>
      <StatsPage />
    </Sentry.ErrorBoundary>
  ),
});

// /stats/:exerciseId — exercise detail charts
export const exerciseStatsRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/stats/$exerciseId',
  component: () => (
    <Sentry.ErrorBoundary fallback={<PageErrorFallback />}>
      <ExerciseStatsPage />
    </Sentry.ErrorBoundary>
  ),
});

// /profile — user profile
export const profileRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/profile',
  component: () => (
    <Sentry.ErrorBoundary fallback={<PageErrorFallback />}>
      <ProfilePage />
    </Sentry.ErrorBoundary>
  ),
});

const routeTree = rootRoute.addChildren([
  authLayoutRoute.addChildren([loginRoute, signUpRoute, forgotPasswordRoute, onboardingRoute]),
  appLayoutRoute.addChildren([
    indexRoute,
    protectedLayoutRoute.addChildren([
      logRoute,
      machineIdentifyRoute,
      setLoggerRoute,
      variantManagerRoute,
      historyRoute,
      sessionDetailRoute,
      statsRoute,
      exerciseStatsRoute,
      profileRoute,
    ]),
  ]),
]);

export const router = createRouter({ routeTree, scrollRestoration: true });

// Register router for type safety
declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router;
  }
}
