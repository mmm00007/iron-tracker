import { useState, useEffect, useCallback } from 'react';
import Box from '@mui/material/Box';
import IconButton from '@mui/material/IconButton';
import LinearProgress from '@mui/material/LinearProgress';
import Typography from '@mui/material/Typography';
import AddIcon from '@mui/icons-material/Add';
import RemoveIcon from '@mui/icons-material/Remove';

interface RestTimerPillProps {
  durationSeconds: number;
  endTime: number; // epoch ms
  onDismiss: () => void;
  onAddTime: (seconds: number) => void;
  onSubtractTime: (seconds: number) => void;
}

function formatTime(seconds: number): string {
  const s = Math.max(0, Math.floor(seconds));
  const m = Math.floor(s / 60);
  const sec = s % 60;
  return `${m}:${sec.toString().padStart(2, '0')}`;
}

export function RestTimerPill({
  durationSeconds,
  endTime,
  onDismiss,
  onAddTime,
  onSubtractTime,
}: RestTimerPillProps) {
  const [remaining, setRemaining] = useState<number>(() =>
    Math.max(0, (endTime - Date.now()) / 1000),
  );
  const [isComplete, setIsComplete] = useState(false);

  // Tick
  useEffect(() => {
    const tick = () => {
      const r = (endTime - Date.now()) / 1000;
      if (r <= 0) {
        setRemaining(0);
        setIsComplete(true);
      } else {
        setRemaining(r);
        setIsComplete(false);
      }
    };
    tick();
    const interval = setInterval(tick, 250);
    return () => clearInterval(interval);
  }, [endTime]);

  const handleDismiss = useCallback(() => onDismiss(), [onDismiss]);

  // Color: blue at full, amber at ≤30s, red-ish at complete
  const progress = durationSeconds > 0 ? (remaining / durationSeconds) * 100 : 0;
  const isWarning = remaining <= 30 && !isComplete;
  const barColor = isComplete ? '#FF6B6B' : isWarning ? '#F9A825' : '#42A5F5';
  const bgColor = isComplete
    ? 'rgba(255, 107, 107, 0.12)'
    : isWarning
      ? 'rgba(249, 168, 37, 0.12)'
      : 'rgba(66, 165, 245, 0.12)';

  return (
    <Box
      sx={{
        position: 'fixed',
        top: 64, // below app bar (56dp) + 8dp gap
        left: '50%',
        transform: 'translateX(-50%)',
        zIndex: 1200,
        display: 'flex',
        alignItems: 'center',
        gap: 1,
        px: 2,
        py: 1,
        backgroundColor: bgColor,
        border: `1px solid ${barColor}40`,
        borderRadius: '100px',
        backdropFilter: 'blur(8px)',
        boxShadow: `0 4px 16px ${barColor}30`,
        minWidth: 240,
        cursor: 'pointer',
      }}
      onClick={handleDismiss}
    >
      {/* -30s button */}
      {!isComplete && (
        <IconButton
          size="medium"
          onClick={(e) => {
            e.stopPropagation();
            onSubtractTime(30);
          }}
          sx={{ color: barColor, minWidth: 44, minHeight: 44 }}
          aria-label="Subtract 30 seconds"
        >
          <RemoveIcon />
        </IconButton>
      )}

      {/* Progress + label */}
      <Box sx={{ flex: 1 }}>
        <Box sx={{ display: 'flex', justifyContent: 'center', mb: 0.5 }}>
          <Typography
            variant="caption"
            sx={{
              color: barColor,
              fontWeight: 700,
              fontSize: '0.8rem',
              letterSpacing: '0.02em',
            }}
          >
            {isComplete ? 'Rest Complete' : formatTime(remaining)}
          </Typography>
        </Box>
        {!isComplete && (
          <LinearProgress
            variant="determinate"
            value={progress}
            sx={{
              height: 4,
              borderRadius: 2,
              backgroundColor: `${barColor}20`,
              '& .MuiLinearProgress-bar': {
                backgroundColor: barColor,
                transition: 'transform 0.25s linear',
              },
            }}
          />
        )}
      </Box>

      {/* +30s button */}
      {!isComplete && (
        <IconButton
          size="medium"
          onClick={(e) => {
            e.stopPropagation();
            onAddTime(30);
          }}
          sx={{ color: barColor, minWidth: 44, minHeight: 44 }}
          aria-label="Add 30 seconds"
        >
          <AddIcon />
        </IconButton>
      )}
    </Box>
  );
}
