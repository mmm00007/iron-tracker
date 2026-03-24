import { useState } from 'react';
import Box from '@mui/material/Box';
import Chip from '@mui/material/Chip';
import Tooltip from '@mui/material/Tooltip';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import CircularProgress from '@mui/material/CircularProgress';
import { useProgression } from '@/hooks/useProgression';
import { useProfile } from '@/hooks/useProfile';

// ─── Types ─────────────────────────────────────────────────────────────────────

export interface ProgressionBadgeProps {
  exerciseId: string;
  variantId: string | null;
  /** Called when the user taps the badge to apply the suggestion */
  onApply: (weight: number) => void;
}

// ─── Component ────────────────────────────────────────────────────────────────

/**
 * Small badge shown below the weight input in the Set Logger.
 *
 * - Displays the suggested next weight: "Try 82.5 kg next"
 * - Tapping applies the suggested weight via `onApply`
 * - Reasoning is shown in a tooltip (hover/long-press)
 * - Muted style — should not dominate the logging UI
 *
 * Usage:
 * ```tsx
 * <ProgressionBadge
 *   exerciseId={exerciseId}
 *   variantId={variantId}
 *   onApply={(weight) => setWeightInput(weight)}
 * />
 * ```
 */
export function ProgressionBadge({ exerciseId, variantId, onApply }: ProgressionBadgeProps) {
  const { suggestion, isLoading, isError } = useProgression(exerciseId, variantId);
  const profileQuery = useProfile();
  const weightUnit = profileQuery.data?.preferred_weight_unit ?? 'kg';
  const [tooltipOpen, setTooltipOpen] = useState(false);

  if (isLoading) {
    return (
      <Box sx={{ display: 'flex', alignItems: 'center', height: 24, px: 0.5 }}>
        <CircularProgress size={14} sx={{ color: 'text.disabled' }} />
      </Box>
    );
  }

  if (isError || !suggestion || suggestion.suggestedWeight <= 0) {
    return null;
  }

  const label = `Try ${suggestion.suggestedWeight} ${weightUnit} next`;
  const confidenceOpacity =
    suggestion.confidence === 'high'
      ? 0.75
      : suggestion.confidence === 'medium'
        ? 0.65
        : 0.6;

  return (
    <Tooltip
      title={suggestion.reasoning}
      open={tooltipOpen}
      onClose={() => setTooltipOpen(false)}
      onOpen={() => setTooltipOpen(true)}
      enterTouchDelay={400} // long-press on mobile
      leaveTouchDelay={2000}
      arrow
      placement="top"
    >
      <Chip
        icon={
          <TrendingUpIcon
            sx={{ fontSize: '0.875rem !important', color: 'text.secondary' }}
          />
        }
        label={label}
        size="small"
        clickable
        onClick={() => {
          onApply(suggestion.suggestedWeight);
        }}
        aria-label={`${label}. ${suggestion.reasoning}`}
        sx={{
          height: 24,
          opacity: confidenceOpacity,
          backgroundColor: 'rgba(168, 199, 250, 0.08)',
          border: '1px solid rgba(168, 199, 250, 0.15)',
          color: 'text.secondary',
          fontSize: '0.72rem',
          cursor: 'pointer',
          transition: 'opacity 0.2s ease, background-color 0.2s ease',
          '&:hover': {
            opacity: 1,
            backgroundColor: 'rgba(168, 199, 250, 0.16)',
          },
          '& .MuiChip-icon': { ml: 0.5 },
          '& .MuiChip-label': { px: 0.75 },
        }}
      />
    </Tooltip>
  );
}
