import Avatar from '@mui/material/Avatar';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemAvatar from '@mui/material/ListItemAvatar';
import ListItemText from '@mui/material/ListItemText';
import FitnessCenterIcon from '@mui/icons-material/FitnessCenter';
import ChevronRightIcon from '@mui/icons-material/ChevronRight';
import { useNavigate } from '@tanstack/react-router';
import type { Exercise } from '@/types/database';

interface ExerciseListItemProps {
  exercise: Exercise;
  lastLoggedInfo?: string;
}

export function ExerciseListItem({ exercise, lastLoggedInfo }: ExerciseListItemProps) {
  const navigate = useNavigate();
  const thumbUrl = exercise.image_urls?.[0];

  const handleClick = () => {
    void navigate({ to: '/log/$exerciseId', params: { exerciseId: exercise.id } });
  };

  const secondaryText = [
    exercise.equipment,
    lastLoggedInfo,
  ].filter(Boolean).join(' · ') || 'Never logged';

  return (
    <ListItem
      disablePadding
      secondaryAction={
        <ChevronRightIcon sx={{ color: 'text.secondary', fontSize: 20 }} />
      }
    >
      <ListItemButton
        onClick={handleClick}
        sx={{
          borderRadius: '12px',
          pr: 5,
          minHeight: 48,
          '&:hover': {
            backgroundColor: 'rgba(168, 199, 250, 0.08)',
          },
          '&:active': {
            backgroundColor: 'rgba(168, 199, 250, 0.12)',
          },
        }}
      >
        <ListItemAvatar sx={{ minWidth: 48 }}>
          {thumbUrl ? (
            <Avatar
              src={thumbUrl}
              variant="rounded"
              sx={{ width: 40, height: 40 }}
              imgProps={{ loading: 'lazy' }}
            />
          ) : (
            <Avatar
              variant="rounded"
              sx={{ width: 40, height: 40, bgcolor: 'rgba(168, 199, 250, 0.08)' }}
            >
              <FitnessCenterIcon sx={{ fontSize: 20, color: 'text.disabled' }} />
            </Avatar>
          )}
        </ListItemAvatar>
        <ListItemText
          primary={exercise.name}
          secondary={secondaryText}
          primaryTypographyProps={{
            variant: 'body1',
            sx: {
              fontWeight: 400,
              color: 'text.primary',
              fontSize: '0.9375rem',
            },
          }}
          secondaryTypographyProps={{
            variant: 'caption',
            sx: {
              color: 'text.secondary',
              mt: 0.25,
            },
          }}
        />
      </ListItemButton>
    </ListItem>
  );
}
