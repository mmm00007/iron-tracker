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

interface SessionCardProps {
  session: SessionGroup;
}

export function SessionCard({ session }: SessionCardProps) {
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
            <Typography
              variant="subtitle1"
              sx={{ fontWeight: 700, color: 'text.primary', letterSpacing: '-0.01em' }}
            >
              {dateLabel}
            </Typography>

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

          {/* Footer: total volume */}
          <Divider sx={{ borderColor: 'rgba(202, 196, 208, 0.06)', mx: 2 }} />
          <Box sx={{ px: 2, py: 1.25 }}>
            <Typography variant="caption" sx={{ color: 'text.secondary' }}>
              Volume:{' '}
              <Box component="span" sx={{ color: 'primary.main', fontWeight: 600 }}>
                {formatVolume(session.totalVolume)}
              </Box>
            </Typography>
          </Box>
        </CardContent>
      </CardActionArea>
    </Card>
  );
}
