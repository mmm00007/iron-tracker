import { useEffect, useRef, useState } from 'react';

interface OnlineStatus {
  /** True when the browser has network access right now. */
  isOnline: boolean;
  /** True once the user has been offline at least once during this session. */
  wasOffline: boolean;
}

/**
 * Tracks network connectivity using navigator.onLine and the online/offline events.
 * `wasOffline` is latched to true the first time connectivity is lost, and stays
 * true for the remainder of the session so sync-status UI can appear after reconnect.
 */
export function useOnlineStatus(): OnlineStatus {
  const [isOnline, setIsOnline] = useState<boolean>(
    typeof navigator !== 'undefined' ? navigator.onLine : true,
  );
  const wasOfflineRef = useRef<boolean>(false);
  const [wasOffline, setWasOffline] = useState<boolean>(false);

  useEffect(() => {
    const handleOnline = () => {
      setIsOnline(true);
    };

    const handleOffline = () => {
      setIsOnline(false);
      if (!wasOfflineRef.current) {
        wasOfflineRef.current = true;
        setWasOffline(true);
      }
    };

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    // Sync initial state in case it changed before mount
    setIsOnline(navigator.onLine);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  return { isOnline, wasOffline };
}
