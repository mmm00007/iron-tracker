import { useState, useEffect, useMemo } from 'react';
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Chip from '@mui/material/Chip';
import CircularProgress from '@mui/material/CircularProgress';
import IconButton from '@mui/material/IconButton';
import Paper from '@mui/material/Paper';
import Snackbar from '@mui/material/Snackbar';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import AddIcon from '@mui/icons-material/Add';
import FitnessCenterIcon from '@mui/icons-material/FitnessCenter';
import RemoveIcon from '@mui/icons-material/Remove';
import { useParams } from '@tanstack/react-router';
import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import type { Exercise } from '@/types/database';
import { useVariants } from '@/hooks/useVariants';
import { useTodaySets, useLastSet, useLogSet, useDeleteSet } from '@/hooks/useSets';
import { useWorkoutStore } from '@/stores/workoutStore';
import { useProfile } from '@/hooks/useProfile';
import { NumpadBottomSheet } from '@/components/log/NumpadBottomSheet';
import { MetadataChips } from '@/components/log/MetadataChips';
import { SetRow } from '@/components/log/SetRow';

/** Returns rest duration in seconds based on exercise category.
 * - Heavy compound (strength / powerlifting): 180 s
 * - Moderate compound (weightlifting): 120 s
 * - Isolation / hypertrophy / everything else: 90 s
 */
function getRestDuration(category: string | null): number {
  switch (category?.toLowerCase()) {
    case 'strength':
    case 'powerlifting':
      return 180;
    case 'weightlifting':
      return 120;
    default:
      return 90;
  }
}

/** Relative time string, e.g. "3 days ago" */
function relativeTime(isoString: string): string {
  const diff = Date.now() - new Date(isoString).getTime();
  const days = Math.floor(diff / (1000 * 60 * 60 * 24));
  const hours = Math.floor(diff / (1000 * 60 * 60));
  const minutes = Math.floor(diff / (1000 * 60));
  if (days > 0) return `${days} day${days > 1 ? 's' : ''} ago`;
  if (hours > 0) return `${hours}h ago`;
  if (minutes > 0) return `${minutes}m ago`;
  return 'Just now';
}

// ─── Stepper button ────────────────────────────────────────────────────────────

interface StepperBtnProps {
  label: string;
  onClick: () => void;
  secondary?: boolean;
}

function StepperBtn({ label, onClick, secondary = false }: StepperBtnProps) {
  return (
    <Button
      variant="outlined"
      onClick={onClick}
      sx={{
        minWidth: 52,
        height: 44,
        borderRadius: '12px',
        fontSize: '0.8rem',
        fontWeight: 600,
        px: 1,
        borderColor: secondary
          ? 'rgba(202, 196, 208, 0.2)'
          : 'rgba(168, 199, 250, 0.3)',
        color: secondary ? 'text.secondary' : 'primary.main',
        '&:hover': {
          borderColor: secondary ? 'rgba(202, 196, 208, 0.4)' : 'primary.main',
          backgroundColor: secondary
            ? 'rgba(202, 196, 208, 0.06)'
            : 'rgba(168, 199, 250, 0.08)',
        },
      }}
    >
      {label}
    </Button>
  );
}

// ─── Set Logger Page ────────────────────────────────────────────────────────────

export function SetLoggerPage() {
  const { exerciseId } = useParams({ strict: false });

  const {
    currentWeight,
    currentReps,
    currentRpe,
    currentSetType,
    currentNotes,
    setWeight,
    setReps,
    startRestTimer,
    prefillFromSet,
  } = useWorkoutStore();

  // Selected variant (null = no specific variant)
  const [selectedVariantId, setSelectedVariantId] = useState<string | null>(null);

  // Bottom sheet state
  const [numpadTarget, setNumpadTarget] = useState<'weight' | 'reps' | null>(null);

  // Snackbar state
  const [snackbarOpen, setSnackbarOpen] = useState(false);
  const [lastLoggedSetId, setLastLoggedSetId] = useState<string | null>(null);

  // ── Data fetching ──────────────────────────────────────────────────────────

  const exerciseQuery = useQuery<Exercise | null>({
    queryKey: ['exercise', exerciseId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('exercises')
        .select('*')
        .eq('id', exerciseId)
        .maybeSingle();
      if (error) throw error;
      return data as Exercise | null;
    },
    enabled: !!exerciseId,
    staleTime: 10 * 60 * 1000,
  });

  const variantsQuery = useVariants(exerciseId);
  const todaySetsQuery = useTodaySets(exerciseId);
  const lastSetQuery = useLastSet(exerciseId, selectedVariantId);
  const profileQuery = useProfile();

  const logSetMutation = useLogSet();
  const deleteSetMutation = useDeleteSet();

  const exercise = exerciseQuery.data;
  const variants = variantsQuery.data ?? [];
  const todaySets = todaySetsQuery.data ?? [];
  const lastSet = lastSetQuery.data;
  const weightUnit = profileQuery.data?.preferred_weight_unit ?? 'kg';

  // ── Pre-fill from last set ────────────────────────────────────────────────

  useEffect(() => {
    if (lastSet) {
      prefillFromSet(lastSet);
    }
  }, [lastSet, prefillFromSet]);

  // Auto-select most recently used variant on load
  useEffect(() => {
    if (variants.length > 1 && selectedVariantId === null) {
      const mru = variants.find((v) => v.last_used_at !== null);
      if (mru) setSelectedVariantId(mru.id);
    }
  }, [variants, selectedVariantId]);

  // ── Recent values for numpad quick-select ─────────────────────────────────

  const recentWeights = useMemo(() => {
    const seen = new Set<number>();
    const result: number[] = [];
    for (const s of todaySets) {
      if (!seen.has(s.weight)) {
        seen.add(s.weight);
        result.push(s.weight);
      }
      if (result.length >= 4) break;
    }
    return result;
  }, [todaySets]);

  const recentReps = useMemo(() => {
    const seen = new Set<number>();
    const result: number[] = [];
    for (const s of todaySets) {
      if (!seen.has(s.reps)) {
        seen.add(s.reps);
        result.push(s.reps);
      }
      if (result.length >= 4) break;
    }
    return result;
  }, [todaySets]);

  // ── Log set handler ───────────────────────────────────────────────────────

  const handleLogSet = async () => {
    const {
      data: { user },
    } = await supabase.auth.getUser();
    if (!user) return;

    const loggedSet = await logSetMutation.mutateAsync({
      user_id: user.id,
      exercise_id: exerciseId,
      variant_id: selectedVariantId,
      weight: currentWeight,
      weight_unit: weightUnit,
      reps: currentReps,
      rpe: currentRpe,
      set_type: currentSetType,
      notes: currentNotes || null,
      logged_at: new Date().toISOString(),
    });

    setLastLoggedSetId(loggedSet.id);
    setSnackbarOpen(true);
    startRestTimer(getRestDuration(exercise?.category ?? null));
  };

  // ── Overflow menu handlers ────────────────────────────────────────────────

  // ── Numpad helpers ────────────────────────────────────────────────────────

  const numpadLabel =
    numpadTarget === 'weight'
      ? weightUnit === 'lb'
        ? 'Weight (lb)'
        : 'Weight (kg)'
      : 'Reps';

  const numpadValue = numpadTarget === 'weight' ? currentWeight : currentReps;

  const handleNumpadApply = (value: number) => {
    if (numpadTarget === 'weight') setWeight(value);
    else setReps(Math.round(value));
    setNumpadTarget(null);
  };

  // ── Render ────────────────────────────────────────────────────────────────

  const showVariants = variants.length > 1;

  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'column',
        minHeight: '100%',
        backgroundColor: 'background.default',
      }}
    >
      {/* ── Top App Bar ────────────────────────────────────────────────────── */}
      <AppBar position="sticky" elevation={0}>
        <Toolbar sx={{ px: 1, minHeight: '56px !important' }}>
          <IconButton
            onClick={() => window.history.back()}
            aria-label="Back"
            sx={{ color: 'text.primary', mr: 0.5 }}
          >
            <ArrowBackIcon />
          </IconButton>

          <Typography
            variant="h6"
            sx={{
              flex: 1,
              textAlign: 'center',
              fontWeight: 600,
              color: 'text.primary',
              overflow: 'hidden',
              textOverflow: 'ellipsis',
              whiteSpace: 'nowrap',
            }}
          >
            {exerciseQuery.isLoading ? '…' : (exercise?.name ?? 'Exercise')}
          </Typography>

        </Toolbar>
      </AppBar>

      {/* ── Main Content ────────────────────────────────────────────────────── */}
      <Box sx={{ flex: 1, px: 2, pt: 2, pb: '120px' }}>

        {/* Zone A — Variant Chips */}
        {showVariants && (
          <Box
            sx={{
              display: 'flex',
              gap: 1,
              mb: 3,
              overflowX: 'auto',
              scrollbarWidth: 'none',
              '&::-webkit-scrollbar': { display: 'none' },
              mx: -2,
              px: 2,
            }}
          >
            {variants.map((variant) => (
              <Chip
                key={variant.id}
                label={
                  variant.name.length > 20
                    ? variant.name.slice(0, 20) + '…'
                    : variant.name
                }
                onClick={() => setSelectedVariantId(variant.id)}
                variant={selectedVariantId === variant.id ? 'filled' : 'outlined'}
                sx={{
                  flexShrink: 0,
                  height: 36,
                  fontWeight: 500,
                  ...(selectedVariantId === variant.id
                    ? {
                        backgroundColor: 'primary.main',
                        color: 'primary.contrastText',
                      }
                    : {
                        borderColor: 'rgba(202, 196, 208, 0.3)',
                        color: 'text.secondary',
                      }),
                }}
              />
            ))}

          </Box>
        )}

        {/* Zone B — Input Area */}
        <Paper
          elevation={0}
          sx={{
            backgroundColor: 'rgba(255,255,255,0.03)',
            border: '1px solid rgba(202, 196, 208, 0.08)',
            borderRadius: '20px',
            p: 2.5,
            mb: 2,
          }}
        >
          {/* Last set ghost text */}
          {lastSet && (
            <Typography
              variant="caption"
              sx={{
                color: 'text.disabled',
                display: 'block',
                textAlign: 'center',
                mb: 2,
              }}
            >
              Last: {lastSet.weight} {lastSet.weight_unit} × {lastSet.reps}
              {' · '}
              {relativeTime(lastSet.logged_at)}
            </Typography>
          )}

          {/* Weight row */}
          <Box sx={{ mb: 2.5 }}>
            <Typography
              variant="overline"
              sx={{
                color: 'text.secondary',
                display: 'block',
                textAlign: 'center',
                mb: 1,
              }}
            >
              Weight
            </Typography>

            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              {/* Left steppers */}
              <Box sx={{ display: 'flex', gap: 0.5 }}>
                <StepperBtn label="-5" onClick={() => setWeight(currentWeight - 5)} secondary />
                <StepperBtn label="-2.5" onClick={() => setWeight(currentWeight - 2.5)} />
              </Box>

              {/* Weight display */}
              <Box
                onClick={() => setNumpadTarget('weight')}
                sx={{
                  flex: 1,
                  textAlign: 'center',
                  cursor: 'pointer',
                  py: 0.5,
                  borderRadius: '12px',
                  '&:hover': { backgroundColor: 'rgba(168, 199, 250, 0.06)' },
                  '&:active': { backgroundColor: 'rgba(168, 199, 250, 0.12)' },
                  userSelect: 'none',
                }}
              >
                <Typography
                  sx={{
                    fontSize: '3rem',
                    fontWeight: 700,
                    lineHeight: 1.1,
                    color: 'text.primary',
                    letterSpacing: '-0.02em',
                  }}
                >
                  {currentWeight % 1 === 0 ? currentWeight : currentWeight.toFixed(1)}
                </Typography>
                <Typography
                  variant="caption"
                  sx={{ color: 'text.secondary', fontSize: '0.8rem' }}
                >
                  {weightUnit}
                </Typography>
              </Box>

              {/* Right steppers */}
              <Box sx={{ display: 'flex', gap: 0.5 }}>
                <StepperBtn label="+2.5" onClick={() => setWeight(currentWeight + 2.5)} />
                <StepperBtn label="+5" onClick={() => setWeight(currentWeight + 5)} secondary />
              </Box>
            </Box>
          </Box>

          {/* Divider */}
          <Box
            sx={{
              height: 1,
              backgroundColor: 'rgba(202, 196, 208, 0.08)',
              mb: 2.5,
              mx: -2.5,
            }}
          />

          {/* Reps row */}
          <Box>
            <Typography
              variant="overline"
              sx={{
                color: 'text.secondary',
                display: 'block',
                textAlign: 'center',
                mb: 1,
              }}
            >
              Reps
            </Typography>

            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              {/* Left stepper */}
              <Box sx={{ display: 'flex' }}>
                <Button
                  variant="outlined"
                  onClick={() => setReps(currentReps - 1)}
                  sx={{
                    minWidth: 52,
                    height: 52,
                    borderRadius: '12px',
                    fontSize: '1.5rem',
                    borderColor: 'rgba(168, 199, 250, 0.3)',
                    color: 'primary.main',
                  }}
                >
                  <RemoveIcon />
                </Button>
              </Box>

              {/* Reps display */}
              <Box
                onClick={() => setNumpadTarget('reps')}
                sx={{
                  flex: 1,
                  textAlign: 'center',
                  cursor: 'pointer',
                  py: 0.5,
                  borderRadius: '12px',
                  '&:hover': { backgroundColor: 'rgba(168, 199, 250, 0.06)' },
                  '&:active': { backgroundColor: 'rgba(168, 199, 250, 0.12)' },
                  userSelect: 'none',
                }}
              >
                <Typography
                  sx={{
                    fontSize: '3rem',
                    fontWeight: 700,
                    lineHeight: 1.1,
                    color: 'text.primary',
                    letterSpacing: '-0.02em',
                  }}
                >
                  {currentReps}
                </Typography>
                <Typography
                  variant="caption"
                  sx={{ color: 'text.secondary', fontSize: '0.8rem' }}
                >
                  reps
                </Typography>
              </Box>

              {/* Right stepper */}
              <Box sx={{ display: 'flex' }}>
                <Button
                  variant="outlined"
                  onClick={() => setReps(currentReps + 1)}
                  sx={{
                    minWidth: 52,
                    height: 52,
                    borderRadius: '12px',
                    fontSize: '1.5rem',
                    borderColor: 'rgba(168, 199, 250, 0.3)',
                    color: 'primary.main',
                  }}
                >
                  <AddIcon />
                </Button>
              </Box>
            </Box>
          </Box>
        </Paper>

        {/* Zone C — Action Row */}
        <Box sx={{ mb: 3 }}>
          <Button
            variant="contained"
            fullWidth
            onClick={() => void handleLogSet()}
            disabled={logSetMutation.isPending}
            sx={{
              height: 56,
              fontSize: '1rem',
              fontWeight: 700,
              letterSpacing: '0.02em',
              borderRadius: '16px',
              mb: 1.5,
              backgroundColor: 'primary.main',
              color: 'primary.contrastText',
              '&:hover': { backgroundColor: 'primary.light' },
              '&:disabled': { opacity: 0.6 },
            }}
            startIcon={
              logSetMutation.isPending ? (
                <CircularProgress size={18} color="inherit" />
              ) : (
                <FitnessCenterIcon />
              )
            }
          >
            {logSetMutation.isPending ? 'Logging…' : 'Log Set'}
          </Button>

          {/* Metadata chips */}
          <MetadataChips />
        </Box>

        {/* Zone D — Session Sets */}
        <Box>
          <Typography
            variant="overline"
            sx={{
              color: 'text.secondary',
              display: 'block',
              mb: 1,
              letterSpacing: '0.08em',
            }}
          >
            Today's Sets
          </Typography>

          {todaySetsQuery.isLoading ? (
            <Box sx={{ display: 'flex', justifyContent: 'center', py: 3 }}>
              <CircularProgress size={24} />
            </Box>
          ) : todaySets.length === 0 ? (
            <Box
              sx={{
                py: 4,
                textAlign: 'center',
                border: '1px dashed rgba(202, 196, 208, 0.15)',
                borderRadius: '16px',
              }}
            >
              <FitnessCenterIcon sx={{ fontSize: 32, color: 'text.disabled', mb: 1 }} />
              <Typography variant="body2" sx={{ color: 'text.disabled' }}>
                No sets logged yet
              </Typography>
              <Typography variant="caption" sx={{ color: 'text.disabled' }}>
                Hit Log Set to get started
              </Typography>
            </Box>
          ) : (
            <Paper
              elevation={0}
              sx={{
                backgroundColor: 'rgba(255,255,255,0.03)',
                border: '1px solid rgba(202, 196, 208, 0.08)',
                borderRadius: '16px',
                overflow: 'hidden',
              }}
            >
              {todaySets.map((set, index) => (
                <SetRow
                  key={set.id}
                  set={set}
                  setNumber={todaySets.length - index}
                  onDelete={(id) =>
                    deleteSetMutation.mutate({ setId: id, exerciseId })
                  }
                />
              ))}
            </Paper>
          )}
        </Box>
      </Box>

      {/* ── Numpad Bottom Sheet ─────────────────────────────────────────────── */}
      <NumpadBottomSheet
        open={numpadTarget !== null}
        onClose={() => setNumpadTarget(null)}
        label={numpadLabel as 'Weight (kg)' | 'Weight (lb)' | 'Reps'}
        initialValue={numpadValue}
        onApply={handleNumpadApply}
        recentValues={numpadTarget === 'weight' ? recentWeights : recentReps}
        allowDecimal={numpadTarget === 'weight'}
      />

      {/* ── Set Logged Snackbar ──────────────────────────────────────────────── */}
      <Snackbar
        open={snackbarOpen}
        autoHideDuration={4000}
        onClose={(_event, reason) => {
          if (reason === 'clickaway') return;
          setSnackbarOpen(false);
        }}
        message="Set logged"
        action={
          <Button
            size="small"
            onClick={() => {
              if (lastLoggedSetId) {
                deleteSetMutation.mutate({ setId: lastLoggedSetId, exerciseId });
              }
              setSnackbarOpen(false);
            }}
            sx={{ color: 'primary.light', fontWeight: 700 }}
          >
            Undo
          </Button>
        }
        anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
        sx={{ bottom: { xs: 80 } }}
      />
    </Box>
  );
}
