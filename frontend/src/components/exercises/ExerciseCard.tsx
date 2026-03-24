import Card from '@mui/material/Card';
import CardActionArea from '@mui/material/CardActionArea';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import FitnessCenterIcon from '@mui/icons-material/FitnessCenter';
import { useNavigate } from '@tanstack/react-router';
import type { ExerciseWithLastSet } from '@/hooks/useExercises';

interface ExerciseCardProps {
  exercise: ExerciseWithLastSet;
}

export function ExerciseCard({ exercise }: ExerciseCardProps) {
  const navigate = useNavigate();

  const handleClick = () => {
    void navigate({ to: '/log/$exerciseId', params: { exerciseId: exercise.id } });
  };

  const lastSetLabel =
    exercise.lastWeight != null && exercise.lastReps != null
      ? `${exercise.lastWeight}${exercise.lastWeightUnit ?? 'kg'} × ${exercise.lastReps}`
      : null;

  const thumbnailUrl = exercise.image_urls?.[0];

  return (
    <Card
      sx={{
        width: 120,
        minWidth: 120,
        flexShrink: 0,
        borderRadius: '16px',
        backgroundColor: 'background.paper',
        border: '1px solid rgba(202, 196, 208, 0.08)',
        overflow: 'hidden',
      }}
      elevation={0}
    >
      <CardActionArea
        onClick={handleClick}
        sx={{
          height: '100%',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'flex-start',
          justifyContent: 'space-between',
          minHeight: 80,
        }}
      >
        {/* Thumbnail or fallback icon */}
        {thumbnailUrl ? (
          <Box
            sx={{
              width: '100%',
              height: 48,
              backgroundImage: `url(${thumbnailUrl})`,
              backgroundSize: 'cover',
              backgroundPosition: 'center',
              borderBottom: '1px solid rgba(202, 196, 208, 0.06)',
            }}
          />
        ) : (
          <Box
            sx={{
              width: '100%',
              height: 36,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              backgroundColor: 'rgba(168, 199, 250, 0.06)',
            }}
          >
            <FitnessCenterIcon sx={{ fontSize: 16, color: 'text.disabled' }} />
          </Box>
        )}

        <Box sx={{ p: 1, width: '100%', flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
          <Typography
            variant="body2"
            sx={{
              fontWeight: 500,
              color: 'text.primary',
              lineHeight: 1.3,
              display: '-webkit-box',
              WebkitLineClamp: 2,
              WebkitBoxOrient: 'vertical',
              overflow: 'hidden',
              wordBreak: 'break-word',
              fontSize: '0.8rem',
            }}
          >
            {exercise.name}
          </Typography>

          {lastSetLabel ? (
            <Typography
              variant="caption"
              sx={{ color: 'primary.main', fontWeight: 500, fontSize: '0.65rem', mt: 0.25 }}
            >
              {lastSetLabel}
            </Typography>
          ) : (
            <Typography variant="caption" sx={{ color: 'text.disabled', fontSize: '0.65rem', mt: 0.25 }}>
              Never logged
            </Typography>
          )}
        </Box>
      </CardActionArea>
    </Card>
  );
}
