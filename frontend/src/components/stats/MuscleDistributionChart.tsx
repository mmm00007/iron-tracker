import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CircularProgress from '@mui/material/CircularProgress';
import Typography from '@mui/material/Typography';
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip } from 'recharts';
import type { MuscleDistributionEntry } from '@/hooks/useAnalytics';

// Chart colors for dark theme
const MUSCLE_COLORS = [
  '#A8C7FA', // primary blue
  '#66BB6A', // green
  '#F9A825', // amber
  '#EF5350', // red
  '#AB47BC', // purple
  '#26C6DA', // cyan
  '#FF7043', // deep orange
  '#66BB6A', // green 2
  '#42A5F5', // light blue
  '#FFA726', // orange
];

interface CustomTooltipProps {
  active?: boolean;
  payload?: Array<{ name: string; value: number; payload: MuscleDistributionEntry }>;
}

function CustomTooltip({ active, payload }: CustomTooltipProps) {
  if (!active || !payload || payload.length === 0) return null;
  const entry = payload[0]!;
  return (
    <Box
      sx={{
        backgroundColor: 'surface.containerHigh',
        border: '1px solid rgba(202, 196, 208, 0.2)',
        borderRadius: '8px',
        p: 1,
      }}
    >
      <Typography variant="body2" sx={{ color: 'text.primary', fontWeight: 600 }}>
        {entry.name}
      </Typography>
      <Typography variant="caption" sx={{ color: 'text.secondary' }}>
        {Math.round(entry.payload.volume).toLocaleString()} vol · {entry.payload.percentage}%
      </Typography>
    </Box>
  );
}

interface MuscleDistributionChartProps {
  data: MuscleDistributionEntry[];
  isLoading?: boolean;
  isError?: boolean;
}

export function MuscleDistributionChart({ data, isLoading, isError }: MuscleDistributionChartProps) {
  const totalVolume = data.reduce((sum, d) => sum + d.volume, 0);

  const chartData = data.map((d) => ({
    ...d,
    name: d.muscleName,
    value: d.volume,
  }));

  return (
    <Card sx={{ mb: 2 }}>
      <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
        <Typography variant="overline" sx={{ color: 'text.secondary', display: 'block', mb: 1.5 }}>
          Muscle Distribution
        </Typography>

        {isLoading && (
          <Box sx={{ display: 'flex', justifyContent: 'center', py: 3 }}>
            <CircularProgress size={24} />
          </Box>
        )}

        {isError && (
          <Typography variant="body2" sx={{ color: 'error.main', textAlign: 'center', py: 2 }}>
            Failed to load muscle data
          </Typography>
        )}

        {!isLoading && !isError && data.length === 0 && (
          <Box sx={{ py: 4, textAlign: 'center' }}>
            <Typography variant="body2" sx={{ color: 'text.disabled' }}>
              No training data for this period
            </Typography>
          </Box>
        )}

        {!isLoading && !isError && data.length > 0 && (
          <>
            <Box sx={{ position: 'relative', height: { xs: 220, md: 280, lg: 320 } }}>
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={chartData}
                    cx="50%"
                    cy="50%"
                    innerRadius={55}
                    outerRadius={85}
                    paddingAngle={2}
                    dataKey="value"
                    strokeWidth={0}
                  >
                    {chartData.map((_entry, index) => (
                      <Cell
                        key={`cell-${index}`}
                        fill={MUSCLE_COLORS[index % MUSCLE_COLORS.length]}
                      />
                    ))}
                  </Pie>
                  <Tooltip content={<CustomTooltip />} />
                </PieChart>
              </ResponsiveContainer>

              {/* Center label */}
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
                <Typography variant="caption" sx={{ color: 'text.disabled', display: 'block', fontSize: '0.65rem' }}>
                  TOTAL VOL
                </Typography>
                <Typography variant="h6" sx={{ fontWeight: 700, color: 'text.primary', lineHeight: 1 }}>
                  {totalVolume >= 1000
                    ? `${(totalVolume / 1000).toFixed(1)}k`
                    : Math.round(totalVolume)}
                </Typography>
              </Box>
            </Box>

            {/* Custom legend */}
            <Box sx={{ mt: 1 }}>
              {data.slice(0, 6).map((entry, index) => (
                <Box
                  key={entry.muscleGroupId}
                  sx={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    py: 0.5,
                  }}
                >
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Box
                      sx={{
                        width: 10,
                        height: 10,
                        borderRadius: '2px',
                        backgroundColor: MUSCLE_COLORS[index % MUSCLE_COLORS.length],
                        flexShrink: 0,
                      }}
                    />
                    <Typography variant="caption" sx={{ color: 'text.secondary' }}>
                      {entry.muscleName}
                    </Typography>
                  </Box>
                  <Typography variant="caption" sx={{ color: 'text.primary', fontWeight: 600 }}>
                    {entry.percentage}%
                  </Typography>
                </Box>
              ))}
              {data.length > 6 && (
                <Typography variant="caption" sx={{ color: 'text.disabled', display: 'block', mt: 0.5 }}>
                  +{data.length - 6} more muscle groups
                </Typography>
              )}
            </Box>
          </>
        )}
      </CardContent>
    </Card>
  );
}
