import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import { Sparkline } from '@/components/common/Sparkline';
import Skeleton from '@mui/material/Skeleton';
import Typography from '@mui/material/Typography';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import TrendingDownIcon from '@mui/icons-material/TrendingDown';
import TrendingFlatIcon from '@mui/icons-material/TrendingFlat';
import FitnessCenterIcon from '@mui/icons-material/FitnessCenter';
import { useNavigate } from '@tanstack/react-router';
import { useTopExercises } from '@/hooks/useAnalytics';
import { DATA_FONT, CHART_COLORS } from '@/theme';

export function ExerciseProgressCard() {
  const { data: topExercises, isLoading } = useTopExercises(5);
  const navigate = useNavigate();

  if (isLoading) {
    return <Skeleton variant="rounded" height={220} sx={{ borderRadius: '16px' }} />;
  }

  if (!topExercises || topExercises.length === 0) {
    return null;
  }

  return (
    <Card>
      <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
          <Box
            sx={{
              width: 32,
              height: 32,
              borderRadius: '8px',
              backgroundColor: `${CHART_COLORS.secondary}15`,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              flexShrink: 0,
            }}
          >
            <FitnessCenterIcon sx={{ fontSize: 18, color: CHART_COLORS.secondary }} />
          </Box>
          <Typography variant="subtitle1" fontWeight={600}>
            Exercise Progress
          </Typography>
        </Box>
        {topExercises.map((ex, idx) => {
          const trendColor =
            ex.trend === 'up' ? CHART_COLORS.primary
              : ex.trend === 'down' ? '#EF5350'
                : '#7A8494';
          const sparkColor = CHART_COLORS.series[idx % CHART_COLORS.series.length] ?? CHART_COLORS.primary;
          const sparkData =
            ex.trend === 'up' ? [60, 100]
              : ex.trend === 'down' ? [100, 60]
                : [80, 80];

          return (
            <Box
              key={ex.exerciseId}
              onClick={() => void navigate({ to: '/stats/$exerciseId', params: { exerciseId: ex.exerciseId } })}
              sx={{
                py: 1,
                px: 0.5,
                cursor: 'pointer',
                borderRadius: '8px',
                transition: 'background-color 0.15s',
                '&:hover': { backgroundColor: 'rgba(91, 234, 162, 0.08)' },
              }}
            >
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5, mb: 0.5 }}>
                {/* Rank badge */}
                <Typography
                  sx={{
                    fontFamily: DATA_FONT,
                    fontSize: '0.6875rem',
                    fontWeight: 700,
                    color: 'text.disabled',
                    width: 20,
                    textAlign: 'center',
                    flexShrink: 0,
                  }}
                >
                  #{idx + 1}
                </Typography>

                {/* Exercise info */}
                <Box sx={{ flex: 1, minWidth: 0 }}>
                  <Typography variant="body2" sx={{ fontWeight: 500, color: 'text.primary' }} noWrap>
                    {ex.exerciseName}
                  </Typography>
                </Box>

                {/* Sparkline trend */}
                <Sparkline data={sparkData} color={sparkColor} width={48} height={20} />

                {/* Volume label + trend icon */}
                <Typography
                  sx={{
                    fontFamily: DATA_FONT,
                    fontSize: '0.6875rem',
                    color: 'text.secondary',
                    fontWeight: 600,
                    flexShrink: 0,
                  }}
                >
                  {ex.setCount}s ·{' '}
                  {ex.totalVolume >= 1000
                    ? `${(ex.totalVolume / 1000).toFixed(1)}k`
                    : Math.round(ex.totalVolume)}
                </Typography>
                <Box sx={{ flexShrink: 0 }}>
                  {ex.trend === 'up' ? (
                    <TrendingUpIcon sx={{ color: trendColor, fontSize: 18 }} />
                  ) : ex.trend === 'down' ? (
                    <TrendingDownIcon sx={{ color: trendColor, fontSize: 18 }} />
                  ) : (
                    <TrendingFlatIcon sx={{ color: trendColor, fontSize: 18 }} />
                  )}
                </Box>
              </Box>
            </Box>
          );
        })}
      </CardContent>
    </Card>
  );
}
