import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Skeleton from '@mui/material/Skeleton';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip } from 'recharts';
import { useMuscleDistribution } from '@/hooks/useAnalytics';
import { useNavigate } from '@tanstack/react-router';

const MUSCLE_COLORS = [
  '#A8C7FA', '#66BB6A', '#F9A825', '#EF5350', '#AB47BC',
  '#26C6DA', '#FF7043', '#66BB6A', '#42A5F5', '#FFA726',
];

export function HomeMuscleDonut() {
  const { data, isLoading } = useMuscleDistribution('month');
  const navigate = useNavigate();

  if (isLoading) {
    return <Skeleton variant="rounded" height={180} sx={{ borderRadius: '16px' }} />;
  }

  if (!data || data.length === 0) {
    return null;
  }

  const totalVolume = data.reduce((sum, d) => sum + d.volume, 0);
  const chartData = data.map((d) => ({ name: d.muscleName, value: d.volume }));

  return (
    <Card>
      <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
          <Typography variant="subtitle1" fontWeight={600}>
            Muscle Focus
          </Typography>
          <Button
            size="small"
            onClick={() => void navigate({ to: '/stats', search: { period: undefined } })}
            sx={{ fontSize: '0.75rem' }}
          >
            View Stats
          </Button>
        </Box>

        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
          {/* Compact donut */}
          <Box sx={{ position: 'relative', width: 120, height: 120, flexShrink: 0 }}>
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={chartData}
                  cx="50%"
                  cy="50%"
                  innerRadius={35}
                  outerRadius={55}
                  paddingAngle={2}
                  dataKey="value"
                  strokeWidth={0}
                >
                  {chartData.map((_entry, index) => (
                    <Cell key={`cell-${index}`} fill={MUSCLE_COLORS[index % MUSCLE_COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
            <Box
              sx={{
                position: 'absolute',
                top: '50%',
                left: '50%',
                transform: 'translate(-50%, -50%)',
                textAlign: 'center',
                pointerEvents: 'none',
              }}
            >
              <Typography variant="caption" sx={{ color: 'text.disabled', fontSize: '0.55rem' }}>
                TOTAL
              </Typography>
              <Typography variant="body2" sx={{ fontWeight: 700, color: 'text.primary', lineHeight: 1 }}>
                {totalVolume >= 1000 ? `${(totalVolume / 1000).toFixed(0)}k` : Math.round(totalVolume)}
              </Typography>
            </Box>
          </Box>

          {/* Compact legend */}
          <Box sx={{ flex: 1 }}>
            {data.slice(0, 5).map((entry, index) => (
              <Box key={entry.muscleGroupId} sx={{ display: 'flex', alignItems: 'center', gap: 0.75, py: 0.25 }}>
                <Box
                  sx={{
                    width: 8,
                    height: 8,
                    borderRadius: '2px',
                    backgroundColor: MUSCLE_COLORS[index % MUSCLE_COLORS.length],
                    flexShrink: 0,
                  }}
                />
                <Typography variant="caption" sx={{ color: 'text.secondary', flex: 1 }} noWrap>
                  {entry.muscleName}
                </Typography>
                <Typography variant="caption" sx={{ color: 'text.primary', fontWeight: 600 }}>
                  {entry.percentage}%
                </Typography>
              </Box>
            ))}
          </Box>
        </Box>
      </CardContent>
    </Card>
  );
}
