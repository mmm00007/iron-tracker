import { useState, useEffect, useCallback } from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Dialog from '@mui/material/Dialog';
import DialogTitle from '@mui/material/DialogTitle';
import DialogContent from '@mui/material/DialogContent';
import DialogActions from '@mui/material/DialogActions';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import ToggleButton from '@mui/material/ToggleButton';
import ToggleButtonGroup from '@mui/material/ToggleButtonGroup';
import Typography from '@mui/material/Typography';
import CircularProgress from '@mui/material/CircularProgress';
import { supabase } from '@/lib/supabase';
import { useQuery } from '@tanstack/react-query';
import { useSorenessPrompt, useReportSoreness, SORENESS_LABELS } from '@/hooks/useSoreness';
import type { MuscleGroup } from '@/types/database';
import { BodySilhouette } from '@/components/soreness/BodySilhouette';

const SORENESS_COLORS = ['#66BB6A', '#8BC34A', '#FFC107', '#FF9800', '#F44336'];

const SKIP_STORAGE_KEY = 'soreness-prompt-skip-until';

function isSkipped(): boolean {
  const skipUntil = localStorage.getItem(SKIP_STORAGE_KEY);
  if (!skipUntil) return false;
  return new Date().getTime() < Number(skipUntil);
}

function setSkipped(): void {
  const twentyFourHoursMs = 24 * 60 * 60 * 1000;
  localStorage.setItem(
    SKIP_STORAGE_KEY,
    String(new Date().getTime() + twentyFourHoursMs),
  );
}

function useMuscleGroupsList() {
  return useQuery<MuscleGroup[]>({
    queryKey: ['muscleGroups'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('muscle_groups')
        .select('*')
        .order('name', { ascending: true });

      if (error) throw error;
      return data ?? [];
    },
    staleTime: 30 * 60 * 1000,
  });
}

export function SorenessPrompt() {
  const { data: promptData, isLoading: promptLoading } = useSorenessPrompt();
  const { data: muscleGroups, isLoading: musclesLoading } = useMuscleGroupsList();
  const reportSoreness = useReportSoreness();

  // Map of muscleGroupId -> level (0-4)
  const [ratings, setRatings] = useState<Map<number, number>>(new Map());
  const [open, setOpen] = useState(false);

  // Determine if dialog should be open
  useEffect(() => {
    if (promptLoading) return;
    if (promptData?.shouldShow && !isSkipped()) {
      setOpen(true);
    }
  }, [promptData, promptLoading]);

  const handleRatingChange = useCallback(
    (muscleGroupId: number, newLevel: number | null) => {
      setRatings((prev) => {
        const next = new Map(prev);
        if (newLevel === null) {
          next.delete(muscleGroupId);
        } else {
          next.set(muscleGroupId, newLevel);
        }
        return next;
      });
    },
    [],
  );

  const handleSkip = useCallback(() => {
    setSkipped();
    setOpen(false);
  }, []);

  const handleSave = useCallback(async () => {
    if (!promptData?.trainingDate) return;
    if (ratings.size === 0) return;

    const input = Array.from(ratings.entries()).map(([muscleGroupId, level]) => ({
      muscleGroupId,
      level,
      trainingDate: promptData.trainingDate,
    }));

    await reportSoreness.mutateAsync(input);
    setOpen(false);
    setRatings(new Map());
  }, [promptData, ratings, reportSoreness]);

  // Build a name->level map for the body silhouette
  const bodyRatings = new Map<string, number>();
  if (muscleGroups) {
    for (const [id, level] of ratings) {
      const mg = muscleGroups.find((m) => m.id === id);
      if (mg) bodyRatings.set(mg.name, level);
    }
  }

  if (!promptData?.shouldShow || isSkipped()) return null;

  return (
    <Dialog
      open={open}
      onClose={handleSkip}
      fullScreen
      PaperProps={{
        sx: {
          bgcolor: 'background.default',
        },
      }}
    >
      <DialogTitle
        sx={{
          textAlign: 'center',
          pt: 4,
          pb: 1,
        }}
      >
        <Typography variant="h5" component="span" fontWeight={700}>
          How are you feeling?
        </Typography>
        <Typography
          variant="body2"
          color="text.secondary"
          sx={{ display: 'block', mt: 0.5 }}
        >
          Rate your soreness from {promptData.trainingDate}
        </Typography>
      </DialogTitle>

      <DialogContent sx={{ px: 2, pb: 1 }}>
        {musclesLoading ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', py: 4 }}>
            <CircularProgress />
          </Box>
        ) : (
          <Stack spacing={1.5}>
            {/* Body silhouette overview */}
            <Box sx={{ display: 'flex', justifyContent: 'center', py: 1 }}>
              <BodySilhouette ratings={bodyRatings} />
            </Box>

            {/* Severity legend */}
            <Box
              sx={{
                display: 'flex',
                justifyContent: 'center',
                gap: 1.5,
                flexWrap: 'wrap',
                pb: 1,
              }}
            >
              {SORENESS_LABELS.map((label, idx) => (
                <Box key={label} sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                  <Box
                    sx={{
                      width: 10,
                      height: 10,
                      borderRadius: '50%',
                      bgcolor: SORENESS_COLORS[idx],
                    }}
                  />
                  <Typography variant="caption" color="text.secondary">
                    {label}
                  </Typography>
                </Box>
              ))}
            </Box>

            {/* Muscle group list */}
            {(muscleGroups ?? []).map((mg) => {
              const currentLevel = ratings.get(mg.id) ?? null;

              return (
                <Paper
                  key={mg.id}
                  variant="outlined"
                  sx={{
                    p: 1.5,
                    borderColor:
                      currentLevel !== null
                        ? `${SORENESS_COLORS[currentLevel]}60`
                        : 'divider',
                    transition: 'border-color 0.2s',
                  }}
                >
                  <Typography
                    variant="subtitle2"
                    fontWeight={600}
                    sx={{ mb: 0.75 }}
                  >
                    {mg.name}
                    {mg.name_latin && (
                      <Typography
                        component="span"
                        variant="caption"
                        color="text.secondary"
                        sx={{ ml: 0.75, fontStyle: 'italic' }}
                      >
                        {mg.name_latin}
                      </Typography>
                    )}
                  </Typography>

                  <ToggleButtonGroup
                    value={currentLevel}
                    exclusive
                    onChange={(_, value: number | null) =>
                      handleRatingChange(mg.id, value)
                    }
                    size="small"
                    fullWidth
                    sx={{
                      '& .MuiToggleButton-root': {
                        flex: 1,
                        py: 0.5,
                        fontSize: '0.7rem',
                        fontWeight: 500,
                        textTransform: 'none',
                        borderColor: 'divider',
                      },
                    }}
                  >
                    {SORENESS_LABELS.map((label, idx) => (
                      <ToggleButton
                        key={idx}
                        value={idx}
                        sx={{
                          '&.Mui-selected': {
                            bgcolor: `${SORENESS_COLORS[idx]}30`,
                            color: SORENESS_COLORS[idx],
                            borderColor: `${SORENESS_COLORS[idx]}80`,
                            '&:hover': {
                              bgcolor: `${SORENESS_COLORS[idx]}40`,
                            },
                          },
                        }}
                      >
                        <Box sx={{ textAlign: 'center' }}>
                          <Typography
                            variant="caption"
                            sx={{
                              display: 'block',
                              fontWeight: 700,
                              fontSize: '0.85rem',
                              lineHeight: 1,
                            }}
                          >
                            {idx}
                          </Typography>
                          <Typography
                            variant="caption"
                            sx={{
                              display: 'block',
                              fontSize: '0.55rem',
                              lineHeight: 1.2,
                              mt: 0.25,
                            }}
                          >
                            {label}
                          </Typography>
                        </Box>
                      </ToggleButton>
                    ))}
                  </ToggleButtonGroup>
                </Paper>
              );
            })}
          </Stack>
        )}
      </DialogContent>

      <DialogActions
        sx={{
          px: 2,
          pb: 3,
          pt: 1,
          gap: 1,
          borderTop: '1px solid',
          borderColor: 'divider',
        }}
      >
        <Button
          variant="text"
          onClick={handleSkip}
          sx={{ flex: 1 }}
        >
          Skip
        </Button>
        <Button
          variant="contained"
          onClick={() => void handleSave()}
          disabled={ratings.size === 0 || reportSoreness.isPending}
          sx={{ flex: 2 }}
        >
          {reportSoreness.isPending ? 'Saving...' : `Save (${ratings.size} rated)`}
        </Button>
      </DialogActions>
    </Dialog>
  );
}
