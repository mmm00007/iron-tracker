import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CircularProgress from '@mui/material/CircularProgress';
import Typography from '@mui/material/Typography';
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip } from 'recharts';
import type { MuscleDistributionEntry } from '@/hooks/useAnalytics';
import { CHART_COLORS, DATA_FONT } from '@/theme';

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
        backgroundColor: 'rgba(20, 24, 32, 0.95)',
        border: '1px solid rgba(160, 170, 184, 0.12)',
        borderRadius: '6px',
        px: 1.5,
        py: 0.75,
      }}
    >
      <Typography variant="body2" sx={{ color: '#EAEEF4', fontWeight: 600 }}>
        {entry.name}
      </Typography>
      <Typography sx={{ fontFamily: DATA_FONT, fontSize: '0.75rem', color: '#A0AAB8' }}>
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
          <Box
            sx={{
              display: 'flex',
              flexDirection: { xs: 'column', md: 'row' },
              alignItems: { xs: 'center', md: 'flex-start' },
              gap: 2,
            }}
          >
            {/* Donut chart */}
            <Box sx={{ position: 'relative', height: { xs: 200, md: 240, lg: 280 }, width: { xs: '100%', md: '55%' } }}>
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={chartData}
                    cx="50%"
                    cy="50%"
                    innerRadius="55%"
                    outerRadius="85%"
                    paddingAngle={2}
                    dataKey="value"
                    strokeWidth={0}
                  >
                    {chartData.map((_entry, index) => (
                      <Cell
                        key={`cell-${index}`}
                        fill={CHART_COLORS.series[index % CHART_COLORS.series.length]}
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
                <Typography variant="caption" sx={{ color: 'text.disabled', display: 'block', fontSize: '0.6rem' }}>
                  TOTAL VOL
                </Typography>
                <Typography
                  sx={{
                    fontFamily: DATA_FONT,
                    fontWeight: 800,
                    color: 'text.primary',
                    lineHeight: 1,
                    fontSize: { xs: '1.125rem', md: '1.25rem' },
                  }}
                >
                  {totalVolume >= 1000
                    ? `${(totalVolume / 1000).toFixed(1)}k`
                    : Math.round(totalVolume)}
                </Typography>
              </Box>
            </Box>

            {/* Legend */}
            <Box sx={{ flex: 1, width: '100%' }}>
              {data.slice(0, 8).map((entry, index) => (
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
                        backgroundColor: CHART_COLORS.series[index % CHART_COLORS.series.length],
                        flexShrink: 0,
                      }}
                    />
                    <Typography variant="caption" sx={{ color: 'text.secondary' }}>
                      {entry.muscleName}
                    </Typography>
                  </Box>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Typography
                      sx={{
                        fontFamily: DATA_FONT,
                        fontSize: '0.6875rem',
                        color: 'text.disabled',
                        fontWeight: 400,
                      }}
                    >
                      {Math.round(entry.volume).toLocaleString()}
                    </Typography>
                    <Typography
                      sx={{
                        fontFamily: DATA_FONT,
                        fontSize: '0.75rem',
                        color: 'text.primary',
                        fontWeight: 700,
                        minWidth: 32,
                        textAlign: 'right',
                      }}
                    >
                      {entry.percentage}%
                    </Typography>
                  </Box>
                </Box>
              ))}
              {data.length > 8 && (
                <Typography variant="caption" sx={{ color: 'text.disabled', display: 'block', mt: 0.5 }}>
                  +{data.length - 8} more muscle groups
                </Typography>
              )}
            </Box>
          </Box>
        )}
      </CardContent>
    </Card>
  );
}
