import Card from '@mui/material/Card';
import CardActionArea from '@mui/material/CardActionArea';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
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

  return (
    <Card
      sx={{
        width: 120,
        minWidth: 120,
        flexShrink: 0,
        borderRadius: '16px',
        backgroundColor: 'background.paper',
        border: '1px solid rgba(202, 196, 208, 0.08)',
      }}
      elevation={0}
    >
      <CardActionArea
        onClick={handleClick}
        sx={{
          height: '100%',
          p: 1.5,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'flex-start',
          justifyContent: 'space-between',
          minHeight: 80,
        }}
      >
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
            mb: 0.5,
            flex: 1,
          }}
        >
          {exercise.name}
        </Typography>

        {lastSetLabel ? (
          <Box
            sx={{
              mt: 'auto',
              width: '100%',
            }}
          >
            <Typography
              variant="caption"
              sx={{
                color: 'primary.main',
                fontWeight: 500,
                fontSize: '0.7rem',
                display: 'block',
              }}
            >
              {lastSetLabel}
            </Typography>
          </Box>
        ) : (
          <Typography
            variant="caption"
            sx={{
              color: 'text.secondary',
              fontSize: '0.7rem',
              mt: 'auto',
            }}
          >
            Never logged
          </Typography>
        )}
      </CardActionArea>
    </Card>
  );
}
