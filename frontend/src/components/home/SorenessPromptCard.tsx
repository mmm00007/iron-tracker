import { useState } from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Chip from '@mui/material/Chip';
import Slider from '@mui/material/Slider';
import ToggleButton from '@mui/material/ToggleButton';
import ToggleButtonGroup from '@mui/material/ToggleButtonGroup';
import Typography from '@mui/material/Typography';
import HealingIcon from '@mui/icons-material/Healing';
import { usePendingSoreness, useReportSoreness, SORENESS_LABELS } from '@/hooks/useSoreness';
import { useMuscleGroups } from '@/hooks/useExercises';
import { formatRelativeDate } from '@/utils/formatters';
import { BodySilhouette } from '@/components/common/BodySilhouette';

const SORENESS_COLORS = ['#66BB6A', '#8BC34A', '#FFC107', '#FF9800', '#F44336'];

export function SorenessPromptCard() {
  const { data: pendingDates } = usePendingSoreness();
  const { data: muscleGroups } = useMuscleGroups();
  const reportSoreness = useReportSoreness();
  const [selectedMuscle, setSelectedMuscle] = useState<string | null>(null);
  const [selectedMuscleId, setSelectedMuscleId] = useState<number | null>(null);
  const [level, setLevel] = useState(1);
  const [dismissed, setDismissed] = useState<Set<string>>(new Set());
  const [bodyView, setBodyView] = useState<'front' | 'back'>('front');

  if (!pendingDates || pendingDates.length === 0) return null;

  const activeDates = pendingDates.filter((d) => !dismissed.has(d));
  if (activeDates.length === 0) return null;

  const currentDate = activeDates[0]!;

  // Map muscle name → muscle group ID from database
  const muscleNameToId = new Map<string, number>();
  for (const mg of muscleGroups ?? []) {
    muscleNameToId.set(mg.name, mg.id);
  }

  const handleMuscleClick = (muscleName: string, _muscleId: number) => {
    setSelectedMuscle(muscleName);
    // Try to find in database muscle groups
    const dbId = muscleNameToId.get(muscleName);
    setSelectedMuscleId(dbId ?? _muscleId);
  };

  const handleSubmit = async () => {
    if (selectedMuscleId === null) return;
    await reportSoreness.mutateAsync([{
      muscleGroupId: selectedMuscleId,
      level,
      trainingDate: currentDate,
    }]);
    setSelectedMuscle(null);
    setSelectedMuscleId(null);
    setLevel(1);
  };

  return (
    <Card
      sx={{
        border: '1px solid rgba(255, 152, 0, 0.2)',
        background: 'linear-gradient(135deg, rgba(255, 152, 0, 0.06) 0%, transparent 100%)',
      }}
    >
      <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <HealingIcon sx={{ fontSize: 18, color: 'warning.main' }} />
            <Typography variant="subtitle2" fontWeight={600}>
              How sore after {formatRelativeDate(currentDate)}'s workout?
            </Typography>
          </Box>
          <Button
            size="small"
            onClick={() => setDismissed((s) => new Set(s).add(currentDate))}
            sx={{ fontSize: '0.7rem', minWidth: 'auto' }}
          >
            Skip
          </Button>
        </Box>

        {/* Body silhouette with front/back toggle */}
        <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', mb: 1 }}>
          <ToggleButtonGroup
            value={bodyView}
            exclusive
            onChange={(_, v) => { if (v) setBodyView(v); }}
            size="small"
            sx={{ mb: 1 }}
          >
            <ToggleButton value="front" sx={{ px: 2, py: 0.25, fontSize: '0.7rem' }}>Front</ToggleButton>
            <ToggleButton value="back" sx={{ px: 2, py: 0.25, fontSize: '0.7rem' }}>Back</ToggleButton>
          </ToggleButtonGroup>

          <BodySilhouette
            view={bodyView}
            selectedMuscle={selectedMuscle}
            onMuscleClick={handleMuscleClick}
          />
        </Box>

        {/* Fallback chip selector for muscle groups not on silhouette */}
        <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5, mb: 1 }}>
          {(muscleGroups ?? []).slice(0, 10).map((mg) => (
            <Chip
              key={mg.id}
              label={mg.name}
              size="small"
              onClick={() => handleMuscleClick(mg.name, mg.id)}
              color={selectedMuscle === mg.name ? 'primary' : 'default'}
              variant={selectedMuscle === mg.name ? 'filled' : 'outlined'}
              sx={{ fontSize: '0.65rem', height: 22 }}
            />
          ))}
        </Box>

        {selectedMuscle !== null && (
          <Box sx={{ px: 1 }}>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
              <Typography variant="caption" sx={{ color: 'text.secondary' }}>
                {selectedMuscle} — Soreness Level
              </Typography>
              <Typography variant="caption" sx={{ color: SORENESS_COLORS[level], fontWeight: 600 }}>
                {SORENESS_LABELS[level]}
              </Typography>
            </Box>
            <Slider
              value={level}
              onChange={(_, v) => setLevel(v as number)}
              min={0}
              max={4}
              step={1}
              marks
              sx={{
                '& .MuiSlider-track': { backgroundColor: SORENESS_COLORS[level] },
                '& .MuiSlider-thumb': { backgroundColor: SORENESS_COLORS[level] },
              }}
            />
            <Button
              variant="contained"
              size="small"
              onClick={() => void handleSubmit()}
              disabled={reportSoreness.isPending}
              sx={{ mt: 1 }}
              fullWidth
            >
              Submit
            </Button>
          </Box>
        )}
      </CardContent>
    </Card>
  );
}
