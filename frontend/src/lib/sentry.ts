import * as Sentry from '@sentry/react';

export function initSentry() {
  const dsn = import.meta.env.VITE_SENTRY_DSN;
  if (!dsn) return;

  Sentry.init({
    dsn,
    environment: import.meta.env.MODE,
    integrations: [
      Sentry.browserTracingIntegration(),
      Sentry.replayIntegration({
        maskAllText: false,
        blockAllMedia: false,
      }),
    ],
    // Performance: capture 20% of transactions in production
    tracesSampleRate: import.meta.env.PROD ? 0.2 : 1.0,
    // Session replay: 10% of sessions, 100% of sessions with errors
    replaysSessionSampleRate: 0.1,
    replaysOnErrorSampleRate: 1.0,
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
}

// Re-export for use in components
export { Sentry };
