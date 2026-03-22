import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import FitnessCenterIcon from '@mui/icons-material/FitnessCenter';
import DirectionsRunIcon from '@mui/icons-material/DirectionsRun';
import SelfImprovementIcon from '@mui/icons-material/SelfImprovement';
import SportsMartialArtsIcon from '@mui/icons-material/SportsMartialArts';
import ChevronRightIcon from '@mui/icons-material/ChevronRight';
import { useNavigate } from '@tanstack/react-router';
import type { Exercise } from '@/types/database';

interface ExerciseListItemProps {
  exercise: Exercise;
  lastLoggedInfo?: string;
}

function getEquipmentIcon(equipment: string | null) {
  if (!equipment) return <FitnessCenterIcon fontSize="small" />;

  const lowerEquipment = equipment.toLowerCase();

  if (
    lowerEquipment.includes('machine') ||
    lowerEquipment.includes('cable') ||
    lowerEquipment.includes('barbell') ||
    lowerEquipment.includes('dumbbell') ||
    lowerEquipment.includes('kettlebell')
  ) {
    return <FitnessCenterIcon fontSize="small" />;
  }

  if (lowerEquipment.includes('body') || lowerEquipment.includes('band')) {
    return <SportsMartialArtsIcon fontSize="small" />;
  }

  if (lowerEquipment.includes('cardio') || lowerEquipment.includes('run')) {
    return <DirectionsRunIcon fontSize="small" />;
  }

  if (lowerEquipment.includes('stretch') || lowerEquipment.includes('foam')) {
    return <SelfImprovementIcon fontSize="small" />;
  }

  return <FitnessCenterIcon fontSize="small" />;
}

export function ExerciseListItem({ exercise, lastLoggedInfo }: ExerciseListItemProps) {
  const navigate = useNavigate();

  const handleClick = () => {
    void navigate({ to: '/log/$exerciseId', params: { exerciseId: exercise.id } });
  };

  const secondaryText = lastLoggedInfo ?? 'Never logged';

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
          pr: 5, // space for chevron
          minHeight: 48,
          '&:hover': {
            backgroundColor: 'rgba(168, 199, 250, 0.08)',
          },
          '&:active': {
            backgroundColor: 'rgba(168, 199, 250, 0.12)',
          },
        }}
      >
        <ListItemIcon
          sx={{
            minWidth: 40,
            color: 'text.secondary',
          }}
        >
          {getEquipmentIcon(exercise.equipment)}
        </ListItemIcon>
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
