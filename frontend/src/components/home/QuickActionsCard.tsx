import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import FitnessCenterIcon from '@mui/icons-material/FitnessCenter';
import HistoryIcon from '@mui/icons-material/History';
import BarChartIcon from '@mui/icons-material/BarChart';
import { useNavigate } from '@tanstack/react-router';

export function QuickActionsCard() {
  const navigate = useNavigate();

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
      <Button
        variant="contained"
        startIcon={<FitnessCenterIcon />}
        onClick={() => void navigate({ to: '/log' })}
        fullWidth
        sx={{
          py: 1.5,
          fontSize: '0.9375rem',
          fontWeight: 600,
          background: 'linear-gradient(135deg, #5BEAA2, #2DBD75)',
          '&:hover': { background: 'linear-gradient(135deg, #8AF0BF, #5BEAA2)' },
        }}
      >
        Start Workout
      </Button>
      <Box sx={{ display: 'flex', gap: 1 }}>
        <Button
          variant="outlined"
          startIcon={<HistoryIcon />}
          onClick={() => void navigate({ to: '/history' })}
          sx={{ flex: 1, py: 1.25 }}
        >
          History
        </Button>
        <Button
          variant="outlined"
          startIcon={<BarChartIcon />}
          onClick={() => void navigate({ to: '/stats', search: { period: undefined } })}
          sx={{ flex: 1, py: 1.25 }}
        >
          Stats
        </Button>
      </Box>
    </Box>
  );
}
