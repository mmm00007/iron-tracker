import Box from '@mui/material/Box';
import IconButton from '@mui/material/IconButton';
import Typography from '@mui/material/Typography';
import Chip from '@mui/material/Chip';
import DeleteIcon from '@mui/icons-material/Delete';
import StarIcon from '@mui/icons-material/Star';
import type { WorkoutSet } from '@/types/database';

interface SetRowProps {
  set: WorkoutSet;
  setNumber: number;
  onDelete: (setId: string) => void;
  isPR?: boolean;
}

const SET_TYPE_LABELS: Record<string, string> = {
  warmup: 'Warm-up',
  dropset: 'Drop Set',
  amrap: 'AMRAP',
  failure: 'To Failure',
};

export function SetRow({ set, setNumber, onDelete, isPR = false }: SetRowProps) {
  const showSetTypeChip = set.set_type !== 'working';

  return (
    <Box
      sx={{
        display: 'flex',
        alignItems: 'center',
        px: 2,
        py: 1.25,
        gap: 1.5,
        borderBottom: '1px solid rgba(202, 196, 208, 0.06)',
        '&:last-child': { borderBottom: 'none' },
      }}
    >
      {/* Set number badge */}
      <Box
        sx={{
          width: 28,
          height: 28,
          borderRadius: '50%',
          backgroundColor: 'rgba(168, 199, 250, 0.12)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          flexShrink: 0,
        }}
      >
        <Typography
          variant="caption"
          sx={{ color: 'primary.main', fontWeight: 600, lineHeight: 1 }}
        >
          {setNumber}
        </Typography>
      </Box>

      {/* Weight × Reps */}
      <Box sx={{ flex: 1, display: 'flex', alignItems: 'center', gap: 1, flexWrap: 'wrap' }}>
        <Typography variant="body2" sx={{ color: 'text.primary', fontWeight: 500 }}>
          {set.weight} {set.weight_unit} × {set.reps}
        </Typography>

        {/* RPE badge */}
        {set.rpe !== null && (
          <Chip
            label={`RPE ${set.rpe}`}
            size="small"
            sx={{
              height: 20,
              fontSize: '0.7rem',
              backgroundColor: 'rgba(168, 199, 250, 0.1)',
              color: 'primary.light',
              '& .MuiChip-label': { px: 0.75 },
            }}
          />
        )}

        {/* Set type chip (not shown for 'working') */}
        {showSetTypeChip && (
          <Chip
            label={SET_TYPE_LABELS[set.set_type] ?? set.set_type}
            size="small"
            sx={{
              height: 20,
              fontSize: '0.7rem',
              backgroundColor: 'rgba(249, 168, 37, 0.1)',
              color: 'warning.main',
              '& .MuiChip-label': { px: 0.75 },
            }}
          />
        )}
      </Box>

      {/* PR badge */}
      {isPR && (
        <StarIcon sx={{ fontSize: 18, color: '#FFD700', flexShrink: 0 }} aria-label="Personal Record" />
      )}

      {/* Delete button */}
      <IconButton
        size="medium"
        onClick={() => onDelete(set.id)}
        aria-label={`Delete set ${setNumber}`}
        sx={{
          color: 'text.disabled',
          flexShrink: 0,
          minWidth: 44,
          minHeight: 44,
          '&:hover': { color: 'error.main', backgroundColor: 'rgba(255, 180, 171, 0.08)' },
        }}
      >
        <DeleteIcon fontSize="small" />
      </IconButton>
    </Box>
  );
}
