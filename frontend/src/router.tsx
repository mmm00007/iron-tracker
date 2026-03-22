import { createRootRoute, createRoute, createRouter, Outlet, redirect } from '@tanstack/react-router';
import { AppLayout } from '@/components/layout/AppLayout';
import { AuthGuard } from '@/pages/auth/AuthGuard';
import { LoginPage } from '@/pages/auth/LoginPage';
import { SignUpPage } from '@/pages/auth/SignUpPage';
import { ForgotPasswordPage } from '@/pages/auth/ForgotPasswordPage';
import { ProfilePage } from '@/pages/profile/ProfilePage';
import { ExerciseListPage } from '@/pages/log/ExerciseListPage';
import { SetLoggerPage } from '@/pages/log/SetLoggerPage';
import { VariantManagerPageRoute } from '@/pages/log/VariantManagerPage';

const HistoryPage = () => (
  <div style={{ padding: '16px' }}>
    <h2>Session History</h2>
    <p>Your past workout sessions will appear here.</p>
  </div>
);

const StatsPage = () => (
  <div style={{ padding: '16px' }}>
    <h2>Stats Dashboard</h2>
    <p>Progress charts and analytics will appear here.</p>
  </div>
);

// Root route — renders either auth layout or app layout via child routes
const rootRoute = createRootRoute({
  component: Outlet,
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
  component: ExerciseListPage,
});

// /log/:exerciseId — set logger
export const setLoggerRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/log/$exerciseId',
  component: SetLoggerPage,
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
  component: HistoryPage,
});

// /stats — stats dashboard
export const statsRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/stats',
  component: StatsPage,
});

// /profile — user profile
export const profileRoute = createRoute({
  getParentRoute: () => protectedLayoutRoute,
  path: '/profile',
  component: ProfilePage,
});

const routeTree = rootRoute.addChildren([
  authLayoutRoute.addChildren([loginRoute, signUpRoute, forgotPasswordRoute]),
  appLayoutRoute.addChildren([
    indexRoute,
    protectedLayoutRoute.addChildren([
      logRoute,
      setLoggerRoute,
      variantManagerRoute,
      historyRoute,
      statsRoute,
      profileRoute,
    ]),
  ]),
]);

export const router = createRouter({ routeTree });

// Register router for type safety
declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router;
  }
}
