import { createRootRoute, createRoute, createRouter, redirect } from '@tanstack/react-router';
import { AppLayout } from '@/components/layout/AppLayout';

// Placeholder page components — will be replaced by feature implementations
const LogPage = () => (
  <div style={{ padding: '16px' }}>
    <h2>Exercise Log</h2>
    <p>Select an exercise to log your sets.</p>
  </div>
);

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

const ProfilePage = () => (
  <div style={{ padding: '16px' }}>
    <h2>Profile</h2>
    <p>Account settings and preferences.</p>
  </div>
);

const SetLoggerPage = () => (
  <div style={{ padding: '16px' }}>
    <h2>Log Sets</h2>
    <p>Log your sets for this exercise.</p>
  </div>
);

// Root route with layout
const rootRoute = createRootRoute({
  component: AppLayout,
});

// Index route — redirect to /log
const indexRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/',
  beforeLoad: () => {
    throw redirect({ to: '/log' });
  },
});

// /log — exercise list
export const logRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/log',
  component: LogPage,
});

// /log/:exerciseId — set logger
export const setLoggerRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/log/$exerciseId',
  component: SetLoggerPage,
});

// /history — session timeline
export const historyRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/history',
  component: HistoryPage,
});

// /stats — stats dashboard
export const statsRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/stats',
  component: StatsPage,
});

// /profile — user profile
export const profileRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/profile',
  component: ProfilePage,
});

const routeTree = rootRoute.addChildren([
  indexRoute,
  logRoute,
  setLoggerRoute,
  historyRoute,
  statsRoute,
  profileRoute,
]);

export const router = createRouter({ routeTree });

// Register router for type safety
declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router;
  }
}
