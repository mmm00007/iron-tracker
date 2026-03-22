import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { App } from '@/App';

const rootElement = document.getElementById('root');

if (!rootElement) {
  throw new Error('Root element #root not found in document.');
}

createRoot(rootElement).render(
  <StrictMode>
    <App />
  </StrictMode>,
);

// Register service worker for offline-first caching of the app shell
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js').catch((err) => {
      console.warn('[iron-tracker] Service worker registration failed:', err);
    });
  });
}
