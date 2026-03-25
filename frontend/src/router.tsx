import { lazy, Suspense } from 'react';
import { createRootRoute, createRoute, createRouter, Outlet, useNavigate } from '@tanstack/react-router';
import { Box, Button, CircularProgress, Typography } from '@mui/material';
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
import { HomePage } from '@/pages/home/HomePage';

// Lazy-loaded pages — infrequently visited, heavy, or behind specific user flows
const MachineIdentifyPage = lazy(() => import('@/pages/log/MachineIdentifyPage').then(m => ({ default: m.MachineIdentifyPage })));
const OnboardingPage = lazy(() => import('@/pages/onboarding/OnboardingPage').then(m => ({ default: m.OnboardingPage })));
const PlansPage = lazy(() => import('@/pages/plans/PlansPage').then(m => ({ default: m.PlansPage })));
const AnalysisPage = lazy(() => import('@/pages/analysis/AnalysisPage').then(m => ({ default: m.AnalysisPage })));
const PRBoardPage = lazy(() => import('@/pages/stats/PRBoardPage').then(m => ({ default: m.PRBoardPage })));
const DiagnosticsPage = lazy(() => import('@/pages/diagnostics/DiagnosticsPage').then(m => ({ default: m.DiagnosticsPage })));
const LibraryPage = lazy(() => import('@/pages/library/LibraryPage').then(m => ({ default: m.LibraryPage })));

function LazyFallback() {
  return (
    <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '40vh' }}>
      <CircularProgress size={32} />
    </Box>
  );
}

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
      <Button variant="contained" onClick={() => navigate({ to: '/' })}>
        Go Home
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

// Home route — dashboard landing page
const homeRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/',
  component: () => (
    <Sentry.ErrorBoundary fallback={<PageErrorFallback />}>
      <HomePage />
    </Sentry.ErrorBoundary>
  ),
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
  component: () => (
    <Suspense fallback={<LazyFallback />}>
      <OnboardingPage />
    </Suspense>
  ),
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
  component: () => (
    <Suspense fallback={<LazyFallback />}>
      <MachineIdentifyPage />
    </Suspense>
  ),
});

// /log/:exerciseId/variants — variant manager
export const variantManagerRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/log/$exerciseId/variants',
  component: VariantManagerPageRoute,
});

// /library — exercise library
export const libraryRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/library',
  component: () => (
    <Sentry.ErrorBoundary fallback={<PageErrorFallback />}>
      <Suspense fallback={<LazyFallback />}>
        <LibraryPage />
      </Suspense>
    </Sentry.ErrorBoundary>
  ),
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

// /stats/prs — PR board
export const prBoardRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/stats/prs',
  component: () => (
    <Sentry.ErrorBoundary fallback={<PageErrorFallback />}>
      <Suspense fallback={<LazyFallback />}>
        <PRBoardPage />
      </Suspense>
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

// /analysis — AI training analysis
export const analysisRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/analysis',
  component: () => (
    <Sentry.ErrorBoundary fallback={<PageErrorFallback />}>
      <Suspense fallback={<LazyFallback />}>
        <AnalysisPage />
      </Suspense>
    </Sentry.ErrorBoundary>
  ),
});

// /plans — workout plans
export const plansRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/plans',
  component: () => (
    <Sentry.ErrorBoundary fallback={<PageErrorFallback />}>
      <Suspense fallback={<LazyFallback />}>
        <PlansPage />
      </Suspense>
    </Sentry.ErrorBoundary>
  ),
});

// /diagnostics — diagnostics and debug
export const diagnosticsRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/diagnostics',
  component: () => (
    <Sentry.ErrorBoundary fallback={<PageErrorFallback />}>
      <Suspense fallback={<LazyFallback />}>
        <DiagnosticsPage />
      </Suspense>
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
    protectedLayoutRoute.addChildren([
      homeRoute,
      logRoute,
      machineIdentifyRoute,
      setLoggerRoute,
      variantManagerRoute,
      libraryRoute,
      historyRoute,
      sessionDetailRoute,
      statsRoute,
      prBoardRoute,
      exerciseStatsRoute,
      analysisRoute,
      plansRoute,
      diagnosticsRoute,
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
