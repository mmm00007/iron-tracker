import { useEffect, useRef } from 'react';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import IconButton from '@mui/material/IconButton';
import CloseIcon from '@mui/icons-material/Close';
import EmojiEventsIcon from '@mui/icons-material/EmojiEvents';
import type { PRCheckResult } from '@/utils/prDetection';
import { prLabel } from '@/utils/prDetection';

// ─── Confetti ─────────────────────────────────────────────────────────────────

/** Simple CSS-only confetti particle */
function ConfettiParticle({ index }: { index: number }) {
  const colors = ['#FFD700', '#FF6B6B', '#4ECDC4', '#A8C7FA', '#FF9FF3', '#54A0FF'];
  const color = colors[index % colors.length];
  const left = `${(index * 13 + 5) % 100}%`;
  const animationDelay = `${(index * 0.07).toFixed(2)}s`;
  const animationDuration = `${0.8 + (index % 5) * 0.15}s`;
  const size = 6 + (index % 4) * 2;

  return (
    <Box
      sx={{
        position: 'absolute',
        top: 0,
        left,
        width: size,
        height: size,
        backgroundColor: color,
        borderRadius: index % 2 === 0 ? '50%' : '2px',
        animation: `confettiFall ${animationDuration} ease-out ${animationDelay} forwards`,
        '@keyframes confettiFall': {
          '0%': {
            transform: 'translateY(-10px) rotate(0deg)',
            opacity: 1,
          },
          '100%': {
            transform: 'translateY(80px) rotate(360deg)',
            opacity: 0,
          },
        },
        '@media (prefers-reduced-motion: reduce)': {
          animation: 'none',
          opacity: 0,
        },
      }}
    />
  );
}

// ─── Types ─────────────────────────────────────────────────────────────────────

export interface PRCelebrationProps {
  prResult: PRCheckResult;
  exerciseName: string;
  onDismiss: () => void;
}

// ─── Component ────────────────────────────────────────────────────────────────

/**
 * Full-width gold banner that slides down from the top of the screen when a new
 * PR is achieved. Auto-dismisses after 4 seconds. Includes simple CSS confetti.
 *
 * Usage:
 * ```tsx
 * {latestPRResult?.isPR && (
 *   <PRCelebration
 *     prResult={latestPRResult}
 *     exerciseName={exercise.name}
 *     onDismiss={clearPRResult}
 *   />
 * )}
 * ```
 */
export function PRCelebration({ prResult, exerciseName, onDismiss }: PRCelebrationProps) {
  const timerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  // Auto-dismiss after 4 seconds
  useEffect(() => {
    timerRef.current = setTimeout(onDismiss, 4000);
    return () => {
      if (timerRef.current !== null) {
        clearTimeout(timerRef.current);
      }
    };
  }, [onDismiss]);

  if (!prResult.isPR) return null;

  return (
    <Box
      role="status"
      aria-live="assertive"
      sx={{
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        zIndex: 2000,
        overflow: 'hidden',
        animation: 'slideDown 0.35s cubic-bezier(0.34, 1.56, 0.64, 1) forwards',
        '@keyframes slideDown': {
          '0%': { transform: 'translateY(-100%)' },
          '100%': { transform: 'translateY(0)' },
        },
        '@media (prefers-reduced-motion: reduce)': {
          animation: 'none',
          transform: 'translateY(0)',
        },
      }}
    >
      {/* Confetti layer */}
      <Box sx={{ position: 'absolute', inset: 0, pointerEvents: 'none', overflow: 'hidden' }}>
        {Array.from({ length: 20 }, (_, i) => (
          <ConfettiParticle key={i} index={i} />
        ))}
      </Box>

      {/* Banner body */}
      <Box
        sx={{
          background: 'linear-gradient(135deg, #B8860B 0%, #FFD700 50%, #FFA500 100%)',
          px: 2,
          py: 1.5,
          display: 'flex',
          alignItems: 'flex-start',
          gap: 1.5,
          boxShadow: '0 4px 24px rgba(255, 215, 0, 0.4)',
        }}
      >
        <EmojiEventsIcon
          sx={{ color: '#1a1a1a', fontSize: 32, flexShrink: 0, mt: 0.25 }}
          aria-hidden="true"
        />

        <Box sx={{ flex: 1, minWidth: 0 }}>
          <Typography
            variant="h5"
            sx={{
              color: '#1a1a1a',
              fontWeight: 900,
              lineHeight: 1.1,
              letterSpacing: '-0.5px',
              fontSize: { xs: '1.5rem', sm: '1.75rem' },
            }}
          >
            New PR!
          </Typography>

          <Typography
            variant="subtitle2"
            sx={{ color: '#2a2a2a', fontWeight: 600, mt: 0.25 }}
            noWrap
          >
            {exerciseName}
          </Typography>

          {/* Record detail lines */}
          <Box sx={{ mt: 0.5, display: 'flex', flexDirection: 'column', gap: 0.25 }}>
            {prResult.records.map((rec, idx) => (
              <Typography
                key={idx}
                variant="body2"
                sx={{ color: '#1a1a1a', fontWeight: 500, fontSize: '0.8rem' }}
              >
                {prLabel(rec)}
              </Typography>
            ))}
          </Box>
        </Box>

        <IconButton
          size="small"
          onClick={onDismiss}
          aria-label="Dismiss PR celebration"
          sx={{
            color: '#1a1a1a',
            flexShrink: 0,
            '&:hover': { backgroundColor: 'rgba(0,0,0,0.12)' },
          }}
        >
          <CloseIcon fontSize="small" />
        </IconButton>
      </Box>

      {/* Progress bar */}
      <Box
        sx={{
          height: 3,
          background: 'rgba(0,0,0,0.2)',
          '& > div': {
            height: '100%',
            background: '#1a1a1a',
            animation: 'shrink 4s linear forwards',
            '@keyframes shrink': {
              '0%': { width: '100%' },
              '100%': { width: '0%' },
            },
            '@media (prefers-reduced-motion: reduce)': {
              animation: 'none',
              width: '100%',
            },
          },
        }}
      >
        <div />
      </Box>
    </Box>
  );
}
