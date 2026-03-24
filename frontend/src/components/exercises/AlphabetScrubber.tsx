import { useCallback, useRef } from 'react';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';

const LETTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');

interface AlphabetScrubberProps {
  /** Map of letter → scroll target element ID or ref callback */
  onLetterSelect: (letter: string) => void;
  /** Letters that have at least one exercise */
  activeLetters?: Set<string>;
}

/**
 * Vertical A-Z scrubber strip for the exercise list.
 * Fixed on the right edge. Tap or drag to jump to a letter.
 */
export function AlphabetScrubber({ onLetterSelect, activeLetters }: AlphabetScrubberProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const isDragging = useRef(false);

  const getLetterFromY = useCallback(
    (clientY: number) => {
      if (!containerRef.current) return null;
      const rect = containerRef.current.getBoundingClientRect();
      const y = clientY - rect.top;
      const index = Math.floor((y / rect.height) * LETTERS.length);
      return LETTERS[Math.max(0, Math.min(LETTERS.length - 1, index))] ?? null;
    },
    [],
  );

  const handlePointerDown = useCallback(
    (e: React.PointerEvent) => {
      isDragging.current = true;
      (e.currentTarget as HTMLElement).setPointerCapture(e.pointerId);
      const letter = getLetterFromY(e.clientY);
      if (letter) onLetterSelect(letter);
    },
    [getLetterFromY, onLetterSelect],
  );

  const handlePointerMove = useCallback(
    (e: React.PointerEvent) => {
      if (!isDragging.current) return;
      const letter = getLetterFromY(e.clientY);
      if (letter) onLetterSelect(letter);
    },
    [getLetterFromY, onLetterSelect],
  );

  const handlePointerUp = useCallback(() => {
    isDragging.current = false;
  }, []);

  return (
    <Box
      ref={containerRef}
      onPointerDown={handlePointerDown}
      onPointerMove={handlePointerMove}
      onPointerUp={handlePointerUp}
      sx={{
        position: 'fixed',
        right: 2,
        top: '50%',
        transform: 'translateY(-50%)',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        zIndex: 10,
        py: 0.5,
        px: 0.25,
        borderRadius: '12px',
        backgroundColor: 'rgba(30, 30, 30, 0.6)',
        backdropFilter: 'blur(4px)',
        touchAction: 'none',
        userSelect: 'none',
        cursor: 'pointer',
      }}
      role="navigation"
      aria-label="Alphabet index"
    >
      {LETTERS.map((letter) => {
        const isActive = !activeLetters || activeLetters.has(letter);
        return (
          <Typography
            key={letter}
            variant="caption"
            onClick={() => onLetterSelect(letter)}
            sx={{
              fontSize: '0.55rem',
              lineHeight: 1.4,
              fontWeight: isActive ? 700 : 400,
              color: isActive ? 'primary.main' : 'text.disabled',
              cursor: 'pointer',
              px: 0.5,
              '&:hover': { color: 'primary.light' },
            }}
          >
            {letter}
          </Typography>
        );
      })}
    </Box>
  );
}
