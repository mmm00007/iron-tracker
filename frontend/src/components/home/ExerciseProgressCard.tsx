import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Skeleton from '@mui/material/Skeleton';
import Typography from '@mui/material/Typography';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import TrendingDownIcon from '@mui/icons-material/TrendingDown';
import TrendingFlatIcon from '@mui/icons-material/TrendingFlat';
import { useNavigate } from '@tanstack/react-router';
import { useTopExercises } from '@/hooks/useAnalytics';
import { Sparkline } from '@/components/common/Sparkline';

export function ExerciseProgressCard() {
  const { data: topExercises, isLoading } = useTopExercises(5);
  const navigate = useNavigate();

  if (isLoading) {
    return <Skeleton variant="rounded" height={140} sx={{ borderRadius: '16px' }} />;
  }

  if (!topExercises || topExercises.length === 0) {
    return null;
  }

  return (
    <Card>
      <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
        <Typography variant="subtitle1" fontWeight={600} gutterBottom>
          Exercise Progress
        </Typography>
        {topExercises.map((ex) => (
          <Box
            key={ex.exerciseId}
            onClick={() => void navigate({ to: '/stats/$exerciseId', params: { exerciseId: ex.exerciseId } })}
            sx={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              py: 0.75,
              cursor: 'pointer',
              borderRadius: 1,
              '&:hover': { backgroundColor: 'rgba(168, 199, 250, 0.06)' },
            }}
          >
            <Box sx={{ flex: 1, minWidth: 0 }}>
              <Typography variant="body2" sx={{ fontWeight: 500, color: 'text.primary' }} noWrap>
                {ex.exerciseName}
              </Typography>
              <Typography variant="caption" sx={{ color: 'text.secondary' }}>
                {ex.setCount} sets
              </Typography>
            </Box>

            {/* Placeholder sparkline using set count trend (visual representation) */}
            <Sparkline
              data={[
                Math.random() * ex.totalVolume * 0.8,
                Math.random() * ex.totalVolume * 0.85,
                Math.random() * ex.totalVolume * 0.9,
                Math.random() * ex.totalVolume * 0.88,
                Math.random() * ex.totalVolume * 0.95,
                ex.totalVolume,
              ].map(Math.round)}
              color={ex.trend === 'up' ? '#66BB6A' : ex.trend === 'down' ? '#EF5350' : '#A8C7FA'}
              height={24}
              width={60}
            />

            <Box sx={{ ml: 1, display: 'flex', alignItems: 'center' }}>
              {ex.trend === 'up' ? (
                <TrendingUpIcon sx={{ color: 'success.main', fontSize: 18 }} />
              ) : ex.trend === 'down' ? (
                <TrendingDownIcon sx={{ color: 'error.main', fontSize: 18 }} />
              ) : (
                <TrendingFlatIcon sx={{ color: 'text.disabled', fontSize: 18 }} />
              )}
            </Box>
          </Box>
        ))}
      </CardContent>
    </Card>
  );
}
