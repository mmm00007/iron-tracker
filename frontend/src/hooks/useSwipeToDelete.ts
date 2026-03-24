import { useRef, useCallback } from 'react';

const SWIPE_THRESHOLD = 80;

interface SwipeHandlers {
  onPointerDown: (e: React.PointerEvent) => void;
  onPointerMove: (e: React.PointerEvent) => void;
  onPointerUp: () => void;
  style: React.CSSProperties;
}

export function useSwipeToDelete(onDelete: () => void): SwipeHandlers {
  const startX = useRef(0);
  const currentX = useRef(0);
  const swiping = useRef(false);
  const elementRef = useRef<HTMLElement | null>(null);

  const onPointerDown = useCallback((e: React.PointerEvent) => {
    startX.current = e.clientX;
    currentX.current = 0;
    swiping.current = true;
    elementRef.current = e.currentTarget as HTMLElement;
    (e.currentTarget as HTMLElement).setPointerCapture(e.pointerId);
  }, []);

  const onPointerMove = useCallback((e: React.PointerEvent) => {
    if (!swiping.current) return;
    const delta = e.clientX - startX.current;
    // Only allow left swipe
    currentX.current = Math.min(0, delta);
    if (elementRef.current) {
      elementRef.current.style.transform = `translateX(${currentX.current}px)`;
      elementRef.current.style.opacity = String(1 - Math.abs(currentX.current) / (SWIPE_THRESHOLD * 2));
    }
  }, []);

  const onPointerUp = useCallback(() => {
    swiping.current = false;
    if (Math.abs(currentX.current) > SWIPE_THRESHOLD) {
      // Trigger delete
      if (elementRef.current) {
        elementRef.current.style.transform = 'translateX(-100%)';
        elementRef.current.style.opacity = '0';
        elementRef.current.style.transition = 'transform 0.2s, opacity 0.2s';
      }
      setTimeout(onDelete, 200);
    } else {
      // Snap back
      if (elementRef.current) {
        elementRef.current.style.transform = 'translateX(0)';
        elementRef.current.style.opacity = '1';
        elementRef.current.style.transition = 'transform 0.2s, opacity 0.2s';
      }
    }
    currentX.current = 0;
  }, [onDelete]);

  return {
    onPointerDown,
    onPointerMove,
    onPointerUp,
    style: { touchAction: 'pan-y', cursor: 'grab' },
  };
}

export function triggerHaptic(duration = 50): void {
  if ('vibrate' in navigator) {
    navigator.vibrate(duration);
  }
}
