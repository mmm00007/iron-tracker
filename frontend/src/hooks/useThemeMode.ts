import { useCallback, useSyncExternalStore } from 'react';

type ThemeMode = 'dark' | 'light';

const STORAGE_KEY = 'iron-tracker-theme-mode';
const DEFAULT_MODE: ThemeMode = 'dark';

let listeners: Array<() => void> = [];

function getSnapshot(): ThemeMode {
  try {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (stored === 'light' || stored === 'dark') return stored;
  } catch {
    // SSR or storage unavailable
  }
  return DEFAULT_MODE;
}

function getServerSnapshot(): ThemeMode {
  return DEFAULT_MODE;
}

function subscribe(listener: () => void): () => void {
  listeners.push(listener);
  return () => {
    listeners = listeners.filter((l) => l !== listener);
  };
}

function emitChange(): void {
  for (const listener of listeners) {
    listener();
  }
}

/**
 * Reactive hook for theme mode that persists to localStorage.
 * Uses useSyncExternalStore for tear-free reads across components.
 */
export function useThemeMode() {
  const mode = useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot);

  const setMode = useCallback((newMode: ThemeMode) => {
    try {
      localStorage.setItem(STORAGE_KEY, newMode);
    } catch {
      // storage full or unavailable
    }
    emitChange();
  }, []);

  const toggle = useCallback(() => {
    setMode(getSnapshot() === 'dark' ? 'light' : 'dark');
  }, [setMode]);

  return { mode, setMode, toggle } as const;
}
