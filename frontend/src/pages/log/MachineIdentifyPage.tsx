import { useEffect, useRef, useState } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Chip from '@mui/material/Chip';
import Divider from '@mui/material/Divider';
import IconButton from '@mui/material/IconButton';
import Stack from '@mui/material/Stack';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import CameraAltIcon from '@mui/icons-material/CameraAlt';
import FitnessCenterIcon from '@mui/icons-material/FitnessCenter';
import PhotoLibraryIcon from '@mui/icons-material/PhotoLibrary';
import ReplayIcon from '@mui/icons-material/Replay';
import { VariantBottomSheet } from '@/components/variants/VariantBottomSheet';
import { useMachineIdentify } from '@/hooks/useMachineIdentify';
import type { MachineIdentificationResult } from '@/hooks/useMachineIdentify';
import type { Exercise } from '@/types/database';

// ─── Loading state ────────────────────────────────────────────────────────────

function LoadingState() {
  return (
    <Box
      sx={{
        flex: 1,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 3,
        px: 4,
      }}
    >
      <Box
        sx={{
          width: 88,
          height: 88,
          borderRadius: '50%',
          backgroundColor: 'rgba(168, 199, 250, 0.08)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          animation: 'pulse 1.4s ease-in-out infinite',
          '@keyframes pulse': {
            '0%, 100%': { opacity: 1, transform: 'scale(1)' },
            '50%': { opacity: 0.6, transform: 'scale(0.95)' },
          },
        }}
      >
        <FitnessCenterIcon sx={{ fontSize: 44, color: 'primary.main' }} />
      </Box>
      <Typography variant="h6" sx={{ color: 'text.primary', fontWeight: 600 }}>
        Identifying machine…
      </Typography>
      <Typography variant="body2" sx={{ color: 'text.secondary', textAlign: 'center' }}>
        Claude is analysing the image to identify the equipment and suggest exercises.
      </Typography>
    </Box>
  );
}

// ─── Error state ──────────────────────────────────────────────────────────────

function ErrorState({ message, onRetry }: { message: string; onRetry: () => void }) {
  return (
    <Box
      sx={{
        flex: 1,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 2,
        px: 4,
        textAlign: 'center',
      }}
    >
      <Box
        sx={{
          width: 72,
          height: 72,
          borderRadius: '50%',
          backgroundColor: 'rgba(240, 68, 56, 0.08)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <FitnessCenterIcon sx={{ fontSize: 36, color: 'error.main' }} />
      </Box>
      <Typography variant="h6" sx={{ color: 'text.primary', fontWeight: 600 }}>
        Couldn't identify machine
      </Typography>
      <Typography variant="body2" sx={{ color: 'text.secondary', maxWidth: 280 }}>
        {message}
      </Typography>
      <Button variant="contained" startIcon={<ReplayIcon />} onClick={onRetry} sx={{ mt: 1 }}>
        Try Again
      </Button>
    </Box>
  );
}

// ─── Confidence badge ─────────────────────────────────────────────────────────

function ConfidenceBadge({ confidence }: { confidence: MachineIdentificationResult['confidence'] }) {
  const colorMap = {
    high: 'success',
    medium: 'warning',
    low: 'default',
  } as const;

  return (
    <Chip
      label={`${confidence.charAt(0).toUpperCase()}${confidence.slice(1)} confidence`}
      color={colorMap[confidence]}
      size="small"
      variant="outlined"
      sx={{ alignSelf: 'flex-start' }}
    />
  );
}

// ─── Result display ───────────────────────────────────────────────────────────

interface ResultDisplayProps {
  result: MachineIdentificationResult;
  onRetry: () => void;
  onCreateVariant: () => void;
}

function ResultDisplay({ result, onRetry, onCreateVariant }: ResultDisplayProps) {
  const noMachineFound = result.exercise_names.length === 0;

  if (noMachineFound) {
    return (
      <ErrorState
        message="No gym equipment was detected in this image. Make sure the machine is clearly visible and well-lit."
        onRetry={onRetry}
      />
    );
  }

  return (
    <Box sx={{ flex: 1, overflowY: 'auto', pb: 12 }}>
      <Stack spacing={3} sx={{ px: 2, pt: 2 }}>
        {/* Confidence */}
        <ConfidenceBadge confidence={result.confidence} />

        {/* Primary exercises */}
        <Box>
          <Typography
            variant="overline"
            sx={{ color: 'text.secondary', letterSpacing: '0.08em', fontSize: '0.7rem' }}
          >
            Exercises
          </Typography>
          <Stack direction="row" flexWrap="wrap" gap={1} sx={{ mt: 0.75 }}>
            {result.exercise_names.map((name) => (
              <Chip
                key={name}
                label={name}
                color="primary"
                variant="filled"
                sx={{ fontWeight: 600 }}
              />
            ))}
          </Stack>
        </Box>

        <Divider />

        {/* Equipment info */}
        <Box>
          <Typography
            variant="overline"
            sx={{ color: 'text.secondary', letterSpacing: '0.08em', fontSize: '0.7rem' }}
          >
            Equipment
          </Typography>
          <Stack spacing={0.5} sx={{ mt: 0.75 }}>
            <Typography variant="body1" sx={{ fontWeight: 500, color: 'text.primary' }}>
              {result.equipment_type.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase())}
            </Typography>
            {result.manufacturer && (
              <Typography variant="body2" sx={{ color: 'text.secondary' }}>
                {result.manufacturer}
              </Typography>
            )}
          </Stack>
        </Box>

        <Divider />

        {/* Target muscles */}
        {(result.target_muscles.primary.length > 0 || result.target_muscles.secondary.length > 0) && (
          <Box>
            <Typography
              variant="overline"
              sx={{ color: 'text.secondary', letterSpacing: '0.08em', fontSize: '0.7rem' }}
            >
              Target Muscles
            </Typography>
            <Stack spacing={1.5} sx={{ mt: 0.75 }}>
              {result.target_muscles.primary.length > 0 && (
                <Box>
                  <Typography variant="caption" sx={{ color: 'text.secondary', display: 'block', mb: 0.5 }}>
                    Primary
                  </Typography>
                  <Stack direction="row" flexWrap="wrap" gap={0.75}>
                    {result.target_muscles.primary.map((m) => (
                      <Chip
                        key={m}
                        label={m}
                        size="small"
                        variant="outlined"
                        color="secondary"
                        sx={{ textTransform: 'capitalize' }}
                      />
                    ))}
                  </Stack>
                </Box>
              )}
              {result.target_muscles.secondary.length > 0 && (
                <Box>
                  <Typography variant="caption" sx={{ color: 'text.secondary', display: 'block', mb: 0.5 }}>
                    Secondary
                  </Typography>
                  <Stack direction="row" flexWrap="wrap" gap={0.75}>
                    {result.target_muscles.secondary.map((m) => (
                      <Chip
                        key={m}
                        label={m}
                        size="small"
                        variant="outlined"
                        sx={{ textTransform: 'capitalize' }}
                      />
                    ))}
                  </Stack>
                </Box>
              )}
            </Stack>
          </Box>
        )}

        <Divider />

        {/* Form tips */}
        {result.form_tips.length > 0 && (
          <Box>
            <Typography
              variant="overline"
              sx={{ color: 'text.secondary', letterSpacing: '0.08em', fontSize: '0.7rem' }}
            >
              Form Tips
            </Typography>
            <Stack spacing={1.5} sx={{ mt: 0.75 }}>
              {result.form_tips.map((tip, i) => (
                <Stack key={i} direction="row" spacing={1.5} alignItems="flex-start">
                  <Box
                    sx={{
                      minWidth: 24,
                      height: 24,
                      borderRadius: '50%',
                      backgroundColor: 'rgba(168, 199, 250, 0.12)',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      mt: 0.1,
                    }}
                  >
                    <Typography variant="caption" sx={{ color: 'primary.main', fontWeight: 700 }}>
                      {i + 1}
                    </Typography>
                  </Box>
                  <Typography variant="body2" sx={{ color: 'text.primary', lineHeight: 1.55 }}>
                    {tip}
                  </Typography>
                </Stack>
              ))}
            </Stack>
          </Box>
        )}
      </Stack>

      {/* Action buttons — fixed above bottom nav */}
      <Box
        sx={{
          position: 'fixed',
          bottom: 0,
          left: 0,
          right: 0,
          px: 2,
          pb: 3,
          pt: 2,
          backgroundColor: 'background.default',
          borderTop: 1,
          borderColor: 'divider',
        }}
      >
        <Stack spacing={1}>
          <Button
            variant="contained"
            fullWidth
            onClick={onCreateVariant}
            sx={{ minHeight: 48, fontWeight: 600 }}
          >
            Create Variant
          </Button>
          <Button
            variant="outlined"
            fullWidth
            startIcon={<ReplayIcon />}
            onClick={onRetry}
            sx={{ minHeight: 48 }}
          >
            Try Again
          </Button>
        </Stack>
      </Box>
    </Box>
  );
}

// ─── Pick state (initial) ─────────────────────────────────────────────────────

function PickState({ onFileSelected }: { onFileSelected: (file: File) => void }) {
  const cameraRef = useRef<HTMLInputElement>(null);
  const galleryRef = useRef<HTMLInputElement>(null);

  function handleChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (file) onFileSelected(file);
    // Reset so the same file can be selected again
    e.target.value = '';
  }

  return (
    <Box
      sx={{
        flex: 1,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 3,
        px: 4,
        textAlign: 'center',
      }}
    >
      {/* Icon */}
      <Box
        sx={{
          width: 96,
          height: 96,
          borderRadius: '50%',
          backgroundColor: 'rgba(168, 199, 250, 0.08)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <CameraAltIcon sx={{ fontSize: 48, color: 'primary.main' }} />
      </Box>

      <Box>
        <Typography variant="h6" sx={{ fontWeight: 700, color: 'text.primary', mb: 0.5 }}>
          Identify a Machine
        </Typography>
        <Typography variant="body2" sx={{ color: 'text.secondary', maxWidth: 280, lineHeight: 1.55 }}>
          Take a photo or choose one from your gallery. Claude will identify the equipment, suggest
          exercises, and give you form tips.
        </Typography>
      </Box>

      {/* Hidden inputs */}
      <input
        ref={cameraRef}
        type="file"
        accept="image/*"
        capture="environment"
        style={{ display: 'none' }}
        onChange={handleChange}
      />
      <input
        ref={galleryRef}
        type="file"
        accept="image/jpeg,image/png,image/webp"
        style={{ display: 'none' }}
        onChange={handleChange}
      />

      {/* Buttons */}
      <Stack spacing={1.5} sx={{ width: '100%', maxWidth: 320 }}>
        <Button
          variant="contained"
          fullWidth
          startIcon={<CameraAltIcon />}
          onClick={() => cameraRef.current?.click()}
          sx={{ minHeight: 52, fontWeight: 600, fontSize: '1rem' }}
        >
          Take Photo
        </Button>
        <Button
          variant="outlined"
          fullWidth
          startIcon={<PhotoLibraryIcon />}
          onClick={() => galleryRef.current?.click()}
          sx={{ minHeight: 52 }}
        >
          Choose from Gallery
        </Button>
      </Stack>
    </Box>
  );
}

// ─── Page ─────────────────────────────────────────────────────────────────────

export function MachineIdentifyPage() {
  const { mutate, isPending, error, data, reset } = useMachineIdentify();
  const queryClient = useQueryClient();

  const [sheetOpen, setSheetOpen] = useState(false);
  const [matchedExerciseId, setMatchedExerciseId] = useState<string>('');

  // When AI returns results, look up the first matched exercise name in the
  // cached exercise list and store its ID so VariantBottomSheet can use it.
  useEffect(() => {
    if (!data || data.exercise_names.length === 0) {
      setMatchedExerciseId('');
      return;
    }
    const exercises = queryClient.getQueryData<Exercise[]>(['exercises']) ?? [];
    const firstName = data.exercise_names[0].toLowerCase();
    const match = exercises.find((ex) => ex.name.toLowerCase() === firstName);
    setMatchedExerciseId(match?.id ?? '');
  }, [data, queryClient]);

  const exerciseId = matchedExerciseId;

  function handleFileSelected(file: File) {
    reset();
    mutate(file);
  }

  function handleRetry() {
    reset();
  }

  // Build prefill values from AI result for the VariantBottomSheet
  // (VariantBottomSheet reads `variant` prop for edit-mode prefill)
  const prefillVariant = data
    ? {
        id: '',
        user_id: '',
        exercise_id: exerciseId,
        gym_machine_id: null,
        name: data.exercise_names[0] ?? '',
        equipment_type: data.equipment_type,
        manufacturer: data.manufacturer,
        weight_increment: 2.5,
        weight_unit: 'kg' as const,
        seat_settings: {},
        notes: null,
        photo_url: null,
        last_used_at: null,
        created_at: new Date().toISOString(),
      }
    : null;

  const showPick = !isPending && !data && !error;
  const showResult = !isPending && !!data;
  const showError = !isPending && !!error && !data;

  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'column',
        minHeight: '100dvh',
        backgroundColor: 'background.default',
      }}
    >
      {/* App bar */}
      <AppBar
        position="sticky"
        elevation={0}
        sx={{
          backgroundColor: 'surface.container',
          borderBottom: '1px solid rgba(202, 196, 208, 0.08)',
        }}
      >
        <Toolbar sx={{ px: 1, minHeight: '56px !important' }}>
          <IconButton
            edge="start"
            aria-label="back"
            onClick={() => window.history.back()}
            sx={{ color: 'text.secondary', mr: 1 }}
          >
            <ArrowBackIcon />
          </IconButton>
          <Typography
            variant="h6"
            sx={{ flex: 1, fontWeight: 700, letterSpacing: '-0.01em', color: 'text.primary' }}
          >
            Identify Machine
          </Typography>
        </Toolbar>
      </AppBar>

      {/* Body */}
      {isPending && <LoadingState />}
      {showPick && <PickState onFileSelected={handleFileSelected} />}
      {showResult && (
        <ResultDisplay
          result={data}
          onRetry={handleRetry}
          onCreateVariant={() => setSheetOpen(true)}
        />
      )}
      {showError && (
        <ErrorState
          message={error?.message ?? 'An unexpected error occurred. Please try again.'}
          onRetry={handleRetry}
        />
      )}

      {/* Variant creation bottom sheet pre-filled with AI results */}
      {exerciseId && (
        <VariantBottomSheet
          open={sheetOpen}
          onClose={() => setSheetOpen(false)}
          exerciseId={exerciseId}
          variant={prefillVariant}
        />
      )}
    </Box>
  );
}
