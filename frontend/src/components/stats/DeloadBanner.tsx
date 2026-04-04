import { useState } from 'react';
import Box from '@mui/material/Box';
import Paper from '@mui/material/Paper';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';
import IconButton from '@mui/material/IconButton';
import Collapse from '@mui/material/Collapse';
import WarningAmberIcon from '@mui/icons-material/WarningAmber';
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';
import ExpandLessIcon from '@mui/icons-material/ExpandLess';
import CloseIcon from '@mui/icons-material/Close';
import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { useAuthStore } from '@/stores/authStore';
import type { WorkoutSet } from '@/types/database';
import { checkDeloadNeeded, deriveWeeklyVolumes } from '@/utils/deloadDetection';
import type { DeloadRecommendation } from '@/utils/deloadDetection';

// ─── Severity colours ─────────────────────────────────────────────────────────

const SEVERITY_STYLES = {
  mild: {
    background: 'rgba(237, 108, 2, 0.08)',
    border: 'rgba(237, 108, 2, 0.3)',
    iconColor: '#ED6C02',
    label: 'Light Deload',
  },
  moderate: {
    background: 'rgba(237, 108, 2, 0.12)',
    border: 'rgba(237, 108, 2, 0.45)',
    iconColor: '#F57C00',
    label: 'Deload Recommended',
  },
  aggressive: {
    background: 'rgba(211, 47, 47, 0.08)',
    border: 'rgba(211, 47, 47, 0.3)',
    iconColor: '#D32F2F',
    label: 'Rest Week Recommended',
  },
} as const;

// ─── Inner banner (presentational) ───────────────────────────────────────────

interface DeloadBannerInnerProps {
  recommendation: DeloadRecommendation;
  onDismiss: () => void;
  onStartDeload: () => void;
}

function DeloadBannerInner({
  recommendation,
  onDismiss,
  onStartDeload,
}: DeloadBannerInnerProps) {
  const [expanded, setExpanded] = useState(false);
  const styles = SEVERITY_STYLES[recommendation.severity];
  const { suggestion } = recommendation;

  const volumePct = Math.round(suggestion.volumeReduction * 100);
  const intensityPct = Math.round(suggestion.intensityReduction * 100);

  return (
    <Paper
      elevation={0}
      sx={{
        mb: 2,
        backgroundColor: styles.background,
        border: `1px solid ${styles.border}`,
        borderRadius: '12px',
        overflow: 'hidden',
      }}
    >
      {/* Header row */}
      <Box sx={{ display: 'flex', alignItems: 'center', px: 2, py: 1.5, gap: 1.5 }}>
        <WarningAmberIcon sx={{ color: styles.iconColor, fontSize: 22, flexShrink: 0 }} />

        <Box sx={{ flex: 1, minWidth: 0 }}>
          <Typography
            variant="subtitle2"
            sx={{ color: styles.iconColor, fontWeight: 700, lineHeight: 1.2 }}
          >
            {styles.label}
          </Typography>
          <Typography
            variant="caption"
            sx={{
              color: 'text.secondary',
              display: 'block',
              mt: 0.25,
              overflow: 'hidden',
              textOverflow: 'ellipsis',
              whiteSpace: expanded ? 'normal' : 'nowrap',
            }}
          >
            {recommendation.reasoning}
          </Typography>
        </Box>

        <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5, flexShrink: 0 }}>
          <IconButton
            size="medium"
            onClick={() => setExpanded((e) => !e)}
            aria-label={expanded ? 'Show less' : 'Show details'}
            sx={{ color: 'text.secondary', minWidth: 44, minHeight: 44 }}
          >
            {expanded ? (
              <ExpandLessIcon fontSize="small" />
            ) : (
              <ExpandMoreIcon fontSize="small" />
            )}
          </IconButton>
          <IconButton
            size="medium"
            onClick={onDismiss}
            aria-label="Dismiss deload recommendation"
            sx={{ color: 'text.disabled', minWidth: 44, minHeight: 44 }}
          >
            <CloseIcon fontSize="small" />
          </IconButton>
        </Box>
      </Box>

      {/* Expandable detail section */}
      <Collapse in={expanded}>
        <Box
          sx={{
            px: 2,
            pb: 1.5,
            borderTop: `1px solid ${styles.border}`,
            pt: 1.25,
          }}
        >
          {/* Prescription */}
          <Typography variant="caption" sx={{ color: 'text.secondary', display: 'block', mb: 1 }}>
            Suggested prescription ({suggestion.durationWeeks} week):
          </Typography>

          <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap', mb: 1.5 }}>
            <Box
              sx={{
                px: 1.25,
                py: 0.5,
                borderRadius: '8px',
                backgroundColor: 'rgba(255,255,255,0.04)',
                border: `1px solid ${styles.border}`,
              }}
            >
              <Typography variant="caption" sx={{ color: 'text.disabled', display: 'block', fontSize: '0.6rem' }}>
                VOLUME
              </Typography>
              <Typography variant="body2" sx={{ color: 'text.primary', fontWeight: 600 }}>
                -{volumePct}%
              </Typography>
            </Box>

            {intensityPct > 0 && (
              <Box
                sx={{
                  px: 1.25,
                  py: 0.5,
                  borderRadius: '8px',
                  backgroundColor: 'rgba(255,255,255,0.04)',
                  border: `1px solid ${styles.border}`,
                }}
              >
                <Typography variant="caption" sx={{ color: 'text.disabled', display: 'block', fontSize: '0.6rem' }}>
                  INTENSITY
                </Typography>
                <Typography variant="body2" sx={{ color: 'text.primary', fontWeight: 600 }}>
                  -{intensityPct}%
                </Typography>
              </Box>
            )}

            <Box
              sx={{
                px: 1.25,
                py: 0.5,
                borderRadius: '8px',
                backgroundColor: 'rgba(255,255,255,0.04)',
                border: `1px solid ${styles.border}`,
              }}
            >
              <Typography variant="caption" sx={{ color: 'text.disabled', display: 'block', fontSize: '0.6rem' }}>
                DURATION
              </Typography>
              <Typography variant="body2" sx={{ color: 'text.primary', fontWeight: 600 }}>
                {suggestion.durationWeeks}w
              </Typography>
            </Box>
          </Box>

          {/* Actions */}
          <Box sx={{ display: 'flex', gap: 1 }}>
            <Button
              variant="outlined"
              size="medium"
              onClick={onDismiss}
              sx={{
                borderColor: 'rgba(255,255,255,0.15)',
                color: 'text.secondary',
                fontSize: '0.75rem',
                minHeight: 44,
                '&:hover': { borderColor: 'rgba(255,255,255,0.3)' },
              }}
            >
              Dismiss
            </Button>
            <Button
              variant="contained"
              size="medium"
              onClick={onStartDeload}
              sx={{
                backgroundColor: styles.iconColor,
                color: '#fff',
                fontSize: '0.75rem',
                minHeight: 44,
                '&:hover': { filter: 'brightness(0.9)' },
              }}
            >
              Start Deload
            </Button>
          </Box>
        </Box>
      </Collapse>
    </Paper>
  );
}

// ─── Connected banner (fetches data) ─────────────────────────────────────────

export interface DeloadBannerProps {
  /** Called when the user taps "Start Deload" — can open a config modal (future) */
  onStartDeload?: () => void;
}

const DELOAD_DISMISSED_KEY = 'iron-tracker:deload-dismissed';

/**
 * Self-contained deload recommendation banner for the Stats page.
 *
 * Fetches the last 6 weeks of sets, runs deload detection, and renders the
 * amber warning banner when a deload is recommended. The banner is dismissed
 * per-session via localStorage.
 *
 * Usage:
 * ```tsx
 * // At top of Stats page
 * <DeloadBanner onStartDeload={() => setDeloadModalOpen(true)} />
 * ```
 */
export function DeloadBanner({ onStartDeload }: DeloadBannerProps) {
  const [dismissed, setDismissed] = useState<boolean>(() => {
    try {
      const stored = localStorage.getItem(DELOAD_DISMISSED_KEY);
      if (!stored) return false;
      const { week } = JSON.parse(stored) as { week: string };
      const currentWeek = new Date().toISOString().slice(0, 10).substring(0, 7); // YYYY-MM
      return week === currentWeek;
    } catch {
      return false;
    }
  });

  const { data: recommendation } = useQuery<DeloadRecommendation | null>({
    queryKey: ['deloadCheck'],
    queryFn: async (): Promise<DeloadRecommendation | null> => {
      const user = useAuthStore.getState().user;
      if (!user) return null;

      const cutoff = new Date();
      cutoff.setDate(cutoff.getDate() - 42); // 6 weeks

      const { data, error } = await supabase
        .from('sets')
        .select('*')
        .eq('user_id', user.id)
        .gte('logged_at', cutoff.toISOString())
        .order('logged_at', { ascending: true });

      if (error) throw error;
      const sets = (data ?? []) as WorkoutSet[];
      if (sets.length === 0) return null;

      const weeklyVolumes = deriveWeeklyVolumes(sets);
      return checkDeloadNeeded(sets, weeklyVolumes);
    },
    staleTime: 15 * 60 * 1000, // 15 minutes
  });

  if (dismissed || !recommendation?.shouldDeload) return null;

  function handleDismiss() {
    const currentMonth = new Date().toISOString().slice(0, 7);
    try {
      localStorage.setItem(DELOAD_DISMISSED_KEY, JSON.stringify({ week: currentMonth }));
    } catch {
      // ignore
    }
    setDismissed(true);
  }

  function handleStartDeload() {
    handleDismiss();
    onStartDeload?.();
  }

  return (
    <DeloadBannerInner
      recommendation={recommendation}
      onDismiss={handleDismiss}
      onStartDeload={handleStartDeload}
    />
  );
}
