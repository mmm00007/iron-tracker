import Card from '@mui/material/Card';
import CardActionArea from '@mui/material/CardActionArea';
import CardContent from '@mui/material/CardContent';
import Box from '@mui/material/Box';
import Chip from '@mui/material/Chip';
import Divider from '@mui/material/Divider';
import Typography from '@mui/material/Typography';
import AccessTimeIcon from '@mui/icons-material/AccessTime';
import FitnessCenterIcon from '@mui/icons-material/FitnessCenter';
import { useNavigate } from '@tanstack/react-router';
import type { SessionGroup } from '@/utils/sessionGrouping';
import {
  formatRelativeDate,
  formatDuration,
  formatVolume,
  formatWeightReps,
} from '@/utils/formatters';
import { MiniBarChart } from '@/components/common/MiniBarChart';

const MUSCLE_CHIP_COLORS: Record<string, string> = {
  Chest: '#EF5350',
  Back: '#42A5F5',
  Shoulders: '#FFA726',
  Biceps: '#66BB6A',
  Triceps: '#AB47BC',
  Legs: '#26C6DA',
  Quadriceps: '#26C6DA',
  Hamstrings: '#00897B',
  Glutes: '#EC407A',
  Core: '#F9A825',
  Abdominals: '#F9A825',
  Calves: '#78909C',
  Forearms: '#8D6E63',
};

function getMuscleColor(category: string | undefined): string {
  if (!category) return '#A8C7FA';
  return MUSCLE_CHIP_COLORS[category] ?? '#A8C7FA';
}

interface SessionCardProps {
  session: SessionGroup;
  customName?: string;
}

export function SessionCard({ session, customName }: SessionCardProps) {
  const navigate = useNavigate();

  const handleClick = () => {
    void navigate({
      to: '/history/$sessionId',
      params: { sessionId: encodeURIComponent(session.startedAt) },
    });
  };

  const dateLabel = formatRelativeDate(session.startedAt);
  const durationLabel = formatDuration(session.startedAt, session.endedAt);

  return (
    <Card
      sx={{
        mb: 1.5,
        borderRadius: '16px',
        backgroundColor: 'surface.containerHighest',
        border: '1px solid rgba(202, 196, 208, 0.08)',
      }}
    >
      <CardActionArea onClick={handleClick} sx={{ borderRadius: '16px' }}>
        <CardContent sx={{ p: 0 }}>
          {/* Header row: date + duration badge */}
          <Box
            sx={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              px: 2,
              pt: 2,
              pb: 1,
            }}
          >
            <Box>
              {customName && (
                <Typography
                  variant="caption"
                  sx={{ color: 'primary.main', fontWeight: 600, display: 'block', lineHeight: 1.2 }}
                >
                  {customName}
                </Typography>
              )}
              <Typography
                variant="subtitle1"
                sx={{ fontWeight: 700, color: 'text.primary', letterSpacing: '-0.01em' }}
              >
                {dateLabel}
              </Typography>
            </Box>

            <Chip
              icon={<AccessTimeIcon sx={{ fontSize: '14px !important' }} />}
              label={durationLabel}
              size="small"
              sx={{
                height: 24,
                fontSize: '0.75rem',
                fontWeight: 500,
                backgroundColor: 'rgba(168, 199, 250, 0.1)',
                color: 'primary.light',
                '& .MuiChip-icon': { color: 'primary.light', ml: 0.75 },
                '& .MuiChip-label': { px: 0.75 },
              }}
            />
          </Box>

          {/* Stats row: sets + exercises */}
          <Box
            sx={{
              display: 'flex',
              gap: 2,
              px: 2,
              pb: 1.5,
            }}
          >
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
              <FitnessCenterIcon sx={{ fontSize: 14, color: 'text.secondary' }} />
              <Typography variant="caption" sx={{ color: 'text.secondary' }}>
                {session.totalSets} sets
              </Typography>
            </Box>
            <Typography variant="caption" sx={{ color: 'text.secondary' }}>
              {session.exerciseCount} {session.exerciseCount === 1 ? 'exercise' : 'exercises'}
            </Typography>
          </Box>

          {/* Muscle group chips — color-coded by exercise category */}
          {session.exercises.length > 0 && (
            <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5, px: 2, pb: 1 }}>
              {[...new Set(session.exercises.map((ex) => ex.exerciseName.split(' ')[0]))].slice(0, 5).map((tag) => (
                <Chip
                  key={tag}
                  label={tag}
                  size="small"
                  sx={{
                    height: 20,
                    fontSize: '0.6rem',
                    fontWeight: 600,
                    backgroundColor: `${getMuscleColor(tag)}20`,
                    color: getMuscleColor(tag),
                    border: `1px solid ${getMuscleColor(tag)}40`,
                  }}
                />
              ))}
            </Box>
          )}

          {/* Exercise summary list */}
          {session.exercises.length > 0 && (
            <>
              <Divider sx={{ borderColor: 'rgba(202, 196, 208, 0.06)', mx: 2 }} />
              <Box sx={{ px: 2, py: 1.25 }}>
                {session.exercises.slice(0, 4).map((ex) => (
                  <Box
                    key={ex.exerciseId}
                    sx={{
                      display: 'flex',
                      alignItems: 'baseline',
                      gap: 0.75,
                      py: 0.4,
                      flexWrap: 'wrap',
                    }}
                  >
                    <Typography
                      variant="body2"
                      sx={{ color: 'text.primary', fontWeight: 500, flexShrink: 0 }}
                    >
                      {ex.exerciseName}
                    </Typography>
                    <Typography variant="caption" sx={{ color: 'text.secondary', flexShrink: 0 }}>
                      · {ex.setCount} {ex.setCount === 1 ? 'set' : 'sets'}
                    </Typography>
                    <Typography variant="caption" sx={{ color: 'text.disabled' }}>
                      ·{' '}
                      {formatWeightReps(ex.topSet.weight, ex.topSet.reps, ex.topSet.unit)}
                    </Typography>
                  </Box>
                ))}
                {session.exercises.length > 4 && (
                  <Typography
                    variant="caption"
                    sx={{ color: 'text.disabled', display: 'block', pt: 0.25 }}
                  >
                    +{session.exercises.length - 4} more
                  </Typography>
                )}
              </Box>
            </>
          )}

          {/* Footer: total volume + mini bar chart */}
          <Divider sx={{ borderColor: 'rgba(202, 196, 208, 0.06)', mx: 2 }} />
          <Box sx={{ px: 2, py: 1.25, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <Typography variant="caption" sx={{ color: 'text.secondary' }}>
              Volume:{' '}
              <Box component="span" sx={{ color: 'primary.main', fontWeight: 600 }}>
                {formatVolume(session.totalVolume)}
              </Box>
            </Typography>
            <MiniBarChart
              data={session.exercises.slice(0, 6).map(
                (ex) => ex.topSet.weight * ex.topSet.reps * ex.setCount
              )}
              height={24}
              width={48}
            />
          </Box>
        </CardContent>
      </CardActionArea>
    </Card>
  );
}
