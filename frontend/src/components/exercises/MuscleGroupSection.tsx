import { memo } from 'react';
import Accordion from '@mui/material/Accordion';
import AccordionSummary from '@mui/material/AccordionSummary';
import AccordionDetails from '@mui/material/AccordionDetails';
import Box from '@mui/material/Box';
import Chip from '@mui/material/Chip';
import List from '@mui/material/List';
import Typography from '@mui/material/Typography';
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';
import { ExerciseListItem } from './ExerciseListItem';
import type { Exercise, MuscleGroup } from '@/types/database';

interface MuscleGroupSectionProps {
  muscleGroup: MuscleGroup;
  exercises: Exercise[];
}

export const MuscleGroupSection = memo(function MuscleGroupSection({ muscleGroup, exercises }: MuscleGroupSectionProps) {
  return (
    <Accordion
      defaultExpanded={false}
      disableGutters
      elevation={0}
      sx={{
        backgroundColor: 'transparent',
        backgroundImage: 'none',
        '&:before': {
          display: 'none', // Remove default MUI divider line
        },
        '&.Mui-expanded': {
          margin: 0,
        },
        borderBottom: '1px solid rgba(202, 196, 208, 0.08)',
      }}
    >
      <AccordionSummary
        expandIcon={<ExpandMoreIcon sx={{ color: 'text.secondary', fontSize: 20 }} />}
        sx={{
          px: 2,
          py: 0.5,
          minHeight: 52,
          '&.Mui-expanded': {
            minHeight: 52,
          },
          '& .MuiAccordionSummary-content': {
            my: 1,
            alignItems: 'center',
            gap: 1.5,
          },
          '&:hover': {
            backgroundColor: 'rgba(168, 199, 250, 0.04)',
          },
        }}
      >
        <Typography
          variant="subtitle2"
          sx={{
            fontWeight: 600,
            color: 'text.primary',
            flex: 1,
          }}
        >
          {muscleGroup.name}
        </Typography>
        <Chip
          label={exercises.length}
          size="small"
          sx={{
            height: 20,
            fontSize: '0.7rem',
            fontWeight: 600,
            backgroundColor: 'rgba(168, 199, 250, 0.16)',
            color: 'primary.main',
            '& .MuiChip-label': {
              px: 0.75,
            },
          }}
        />
      </AccordionSummary>

      <AccordionDetails sx={{ p: 0 }}>
        <Box sx={{ px: 1 }}>
          <List dense disablePadding>
            {exercises.map((exercise) => (
              <ExerciseListItem key={exercise.id} exercise={exercise} />
            ))}
          </List>
        </Box>
      </AccordionDetails>
    </Accordion>
  );
});
