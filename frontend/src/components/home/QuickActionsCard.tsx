import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import FitnessCenterIcon from '@mui/icons-material/FitnessCenter';
import HistoryIcon from '@mui/icons-material/History';
import BarChartIcon from '@mui/icons-material/BarChart';
import { useNavigate } from '@tanstack/react-router';

export function QuickActionsCard() {
  const navigate = useNavigate();

  return (
    <Box sx={{ display: 'flex', gap: 1 }}>
      <Button
        variant="contained"
        startIcon={<FitnessCenterIcon />}
        onClick={() => void navigate({ to: '/log' })}
        sx={{ flex: 1 }}
      >
        Start Workout
      </Button>
      <Button
        variant="outlined"
        startIcon={<HistoryIcon />}
        onClick={() => void navigate({ to: '/history' })}
        sx={{ flex: 0 }}
      >
        History
      </Button>
      <Button
        variant="outlined"
        startIcon={<BarChartIcon />}
        onClick={() => void navigate({ to: '/stats', search: { period: undefined } })}
        sx={{ flex: 0 }}
      >
        Stats
      </Button>
    </Box>
  );
}
