import { useState } from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Chip from '@mui/material/Chip';
import Slider from '@mui/material/Slider';
import Typography from '@mui/material/Typography';
import HealingIcon from '@mui/icons-material/Healing';
import { usePendingSoreness, useReportSoreness, SORENESS_LABELS } from '@/hooks/useSoreness';
import { useMuscleGroups } from '@/hooks/useExercises';
import { formatRelativeDate } from '@/utils/formatters';

const SORENESS_COLORS = ['#66BB6A', '#8BC34A', '#FFC107', '#FF9800', '#F44336'];

export function SorenessPromptCard() {
  const { data: pendingDates } = usePendingSoreness();
  const { data: muscleGroups } = useMuscleGroups();
  const reportSoreness = useReportSoreness();
  const [selectedMuscle, setSelectedMuscle] = useState<number | null>(null);
  const [level, setLevel] = useState(1);
  const [dismissed, setDismissed] = useState<Set<string>>(new Set());

  if (!pendingDates || pendingDates.length === 0) return null;

  const activeDates = pendingDates.filter((d) => !dismissed.has(d));
  if (activeDates.length === 0) return null;

  const currentDate = activeDates[0]!;

  const handleSubmit = async () => {
    if (selectedMuscle === null) return;
    await reportSoreness.mutateAsync({
      muscleGroupId: selectedMuscle,
      level,
      trainingDate: currentDate,
    });
    setSelectedMuscle(null);
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
              How are you feeling after {formatRelativeDate(currentDate)}'s workout?
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

        {/* Muscle group selector */}
        <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5, mb: 1.5 }}>
          {(muscleGroups ?? []).slice(0, 10).map((mg) => (
            <Chip
              key={mg.id}
              label={mg.name}
              size="small"
              onClick={() => setSelectedMuscle(mg.id)}
              color={selectedMuscle === mg.id ? 'primary' : 'default'}
              variant={selectedMuscle === mg.id ? 'filled' : 'outlined'}
              sx={{ fontSize: '0.7rem', height: 24 }}
            />
          ))}
        </Box>

        {selectedMuscle !== null && (
          <Box sx={{ px: 1 }}>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
              <Typography variant="caption" sx={{ color: 'text.secondary' }}>
                Soreness Level
              </Typography>
              <Typography
                variant="caption"
                sx={{ color: SORENESS_COLORS[level], fontWeight: 600 }}
              >
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
