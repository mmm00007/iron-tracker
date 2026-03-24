// Iron Tracker Service Worker
// Cache-first for static assets, network-first for API calls.
// Vite hashes all JS/CSS filenames, so we don't need to enumerate them —
// the runtime cache fills as the app loads.

// Bump this on each deploy
const VERSION = 'v2026-03-24';
const CACHE_NAME = 'iron-tracker-' + VERSION;

// App shell — minimal set to bootstrap the SPA offline
const APP_SHELL = ['/', '/index.html'];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(APP_SHELL)),
  );
  // Activate immediately without waiting for tabs to close
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k))),
      ),
  );
  // Take control of all open clients immediately
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  const { request } = event;

  // Only handle GET requests — POST/PUT/DELETE go straight to the network
  if (request.method !== 'GET') return;

  // SPA navigation — always serve the cached app shell (index.html).
  // Client-side routes like /log/uuid don't exist on the server; the SPA
  // router handles them once index.html loads.
  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request)
        .then((response) => {
          if (response.ok) {
            const clone = response.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(request, clone));
          }
          return response;
        })
        .catch(() => caches.match('/index.html').then((r) => r || caches.match('/'))),
    );
    return;
  }

  // Network-first for Supabase API and any /api/ calls
  // Falls back to cache if the network request fails (e.g., offline)
  if (
    request.url.includes('/rest/v1/') ||
    request.url.includes('/auth/v1/') ||
    request.url.includes('/api/')
  ) {
    event.respondWith(
      fetch(request)
        .then((response) => {
          if (response.ok) {
            const clone = response.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(request, clone));
          }
          return response;
        })
        .catch(() => caches.match(request)),
    );
    return;
  }

  // Cache-first for all other requests (static assets, fonts, etc.)
  // Vite-hashed assets are immutable, so cache forever; index.html gets refreshed
  // from network and falls back to cache when offline.
  event.respondWith(
    caches.match(request).then(
      (cached) =>
        cached ||
        fetch(request).then((response) => {
          if (response.ok) {
            const clone = response.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(request, clone));
          }
          return response;
        }),
    ),
  );
});
