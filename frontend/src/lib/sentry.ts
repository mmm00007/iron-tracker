import * as Sentry from '@sentry/react';

export function initSentry() {
  const dsn = import.meta.env.VITE_SENTRY_DSN;
  if (!dsn) return;

  Sentry.init({
    dsn,
    environment: import.meta.env.MODE,
    integrations: [
      Sentry.browserTracingIntegration(),
    ],
    // Performance: capture 20% of transactions in production
    tracesSampleRate: import.meta.env.PROD ? 0.2 : 1.0,
    // Session replay: 10% of sessions, 100% of sessions with errors
    replaysSessionSampleRate: 0.1,
    replaysOnErrorSampleRate: 0.5,
    // Filter out noise
    ignoreErrors: [
      'ResizeObserver loop',
      'Network request failed',
      'Load failed',
    ],
    beforeSend(event) {
      // Don't send in development
      if (import.meta.env.DEV) return null;
      return event;
    },
  });

  // Lazy-load session replay integration to reduce initial bundle (~70KB)
  Sentry.lazyLoadIntegration('replayIntegration').then((replayIntegration) => {
    Sentry.addIntegration(replayIntegration({ maskAllText: true, blockAllMedia: true }));
  });
}

// Re-export for use in components
export { Sentry };
