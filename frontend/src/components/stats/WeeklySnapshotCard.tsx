import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CircularProgress from '@mui/material/CircularProgress';
import Typography from '@mui/material/Typography';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import TrendingDownIcon from '@mui/icons-material/TrendingDown';
import TrendingFlatIcon from '@mui/icons-material/TrendingFlat';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  ResponsiveContainer,
  Tooltip,
} from 'recharts';
import { useWeeklySnapshot } from '@/hooks/useAnalytics';
import { MiniBarChart } from '@/components/common/MiniBarChart';
import { DATA_FONT, DATA_LARGE, CHART_COLORS, CHART_AXIS_COLOR } from '@/theme';

interface DeltaBadgeProps {
  delta: number | null;
}

function DeltaBadge({ delta }: DeltaBadgeProps) {
  if (delta === null) {
    return (
      <Typography variant="caption" sx={{ color: 'text.disabled' }}>
        —
      </Typography>
    );
  }

  const isUp = delta > 0;
  const isDown = delta < 0;
  const color = isUp ? 'success.main' : isDown ? 'error.main' : 'text.secondary';
  const Icon = isUp ? TrendingUpIcon : isDown ? TrendingDownIcon : TrendingFlatIcon;

  return (
    <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.25 }}>
      <Icon sx={{ fontSize: '0.875rem', color }} />
      <Typography
        sx={{
          fontFamily: DATA_FONT,
          fontSize: '0.6875rem',
          fontWeight: 600,
          color,
        }}
      >
        {isUp ? '+' : ''}{delta}%
      </Typography>
    </Box>
  );
}

function CustomTooltip({ active, payload, label }: {
  active?: boolean;
  payload?: Array<{ value: number; dataKey: string; fill: string }>;
  label?: string;
}) {
  if (!active || !payload || payload.length === 0) return null;
  return (
    <Box
      sx={{
        backgroundColor: 'rgba(20, 24, 32, 0.95)',
        border: '1px solid rgba(160, 170, 184, 0.15)',
        borderRadius: '6px',
        px: 1.5,
        py: 0.75,
      }}
    >
      <Typography variant="caption" sx={{ color: '#A0AAB8', display: 'block', mb: 0.25 }}>
        {label}
      </Typography>
      {payload.map((p, i) => (
        <Box key={i} sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
          <Box sx={{ width: 6, height: 6, borderRadius: '1px', backgroundColor: p.fill }} />
          <Typography sx={{ fontFamily: DATA_FONT, fontSize: '0.75rem', fontWeight: 700, color: '#EAEEF4' }}>
            {p.dataKey === 'thisWeek' ? 'This week' : 'Last week'}: {
              typeof p.value === 'number' && p.value >= 1000
                ? `${(p.value / 1000).toFixed(1)}k`
                : p.value
            }
          </Typography>
        </Box>
      ))}
    </Box>
  );
}

export function WeeklySnapshotCard() {
  const { data, isLoading, isError } = useWeeklySnapshot();

  // Build comparison bar chart data
  const chartData = data
    ? [
        { metric: 'Sets', thisWeek: data.thisWeek.sets, lastWeek: data.lastWeek.sets },
        {
          metric: 'Volume',
          thisWeek: data.thisWeek.volume,
          lastWeek: data.lastWeek.volume,
        },
        { metric: 'Days', thisWeek: data.thisWeek.trainingDays, lastWeek: data.lastWeek.trainingDays },
      ]
    : [];

  return (
    <Card sx={{ mb: 2, borderTop: '2px solid', borderTopColor: 'primary.main', backgroundColor: 'surface.containerHigh', boxShadow: '0 2px 12px rgba(0,0,0,0.3)' }}>
      <CardContent>
        <Typography
          variant="overline"
          sx={{ color: 'text.secondary', display: 'block', mb: 1 }}
        >
          This Week vs Last Week
        </Typography>

        {isLoading && (
          <Box sx={{ display: 'flex', justifyContent: 'center', py: 3 }}>
            <CircularProgress size={24} />
          </Box>
        )}

        {isError && (
          <Typography variant="body2" sx={{ color: 'error.main', textAlign: 'center', py: 2 }}>
            Failed to load weekly stats
          </Typography>
        )}

        {data && (
          <>
            {/* KPI row with data font */}
            <Box
              sx={{
                display: 'grid',
                gridTemplateColumns: 'repeat(3, 1fr)',
                gap: 1,
                mb: 2,
              }}
            >
              {/* Sets */}
              <Box
                sx={{
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  gap: 0.25,
                  p: 1.5,
                  borderRadius: '12px',
                  backgroundColor: 'surface.containerHigh',
                  border: '1px solid',
                  borderColor: 'divider',
                }}
              >
                <Typography variant="overline" sx={{ color: 'text.secondary', lineHeight: 1.2, fontSize: '0.6875rem' }}>
                  Sets
                </Typography>
                <Typography
                  sx={{
                    ...DATA_LARGE,
                    color: 'text.primary',
                  }}
                >
                  {data.thisWeek.sets}
                </Typography>
                <MiniBarChart
                  data={[Math.round(data.lastWeek.sets * 0.8), data.lastWeek.sets, Math.round((data.thisWeek.sets + data.lastWeek.sets) / 2), data.thisWeek.sets]}
                  width={48}
                  height={20}
                  barWidth={3}
                  color={CHART_COLORS.primary}
                />
                <DeltaBadge delta={data.deltas.sets} />
              </Box>

              {/* Volume */}
              <Box
                sx={{
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  gap: 0.25,
                  p: 1.5,
                  borderRadius: '12px',
                  backgroundColor: 'surface.containerHigh',
                  border: '1px solid',
                  borderColor: 'divider',
                }}
              >
                <Typography variant="overline" sx={{ color: 'text.secondary', lineHeight: 1.2, fontSize: '0.6875rem' }}>
                  Volume
                </Typography>
                <Typography
                  sx={{
                    ...DATA_LARGE,
                    color: 'text.primary',
                  }}
                >
                  {data.thisWeek.volume >= 1000
                    ? `${(data.thisWeek.volume / 1000).toFixed(1)}k`
                    : Math.round(data.thisWeek.volume)}
                </Typography>
                <MiniBarChart
                  data={[Math.round(data.lastWeek.volume * 0.8), data.lastWeek.volume, Math.round((data.thisWeek.volume + data.lastWeek.volume) / 2), data.thisWeek.volume]}
                  width={48}
                  height={20}
                  barWidth={3}
                  color={CHART_COLORS.primary}
                />
                <DeltaBadge delta={data.deltas.volume} />
              </Box>

              {/* Days */}
              <Box
                sx={{
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  gap: 0.25,
                  p: 1.5,
                  borderRadius: '12px',
                  backgroundColor: 'surface.containerHigh',
                  border: '1px solid',
                  borderColor: 'divider',
                }}
              >
                <Typography variant="overline" sx={{ color: 'text.secondary', lineHeight: 1.2, fontSize: '0.6875rem' }}>
                  Days
                </Typography>
                <Typography
                  sx={{
                    ...DATA_LARGE,
                    color: 'text.primary',
                  }}
                >
                  {data.thisWeek.trainingDays}
                </Typography>
                <MiniBarChart
                  data={[Math.round(data.lastWeek.trainingDays * 0.8), data.lastWeek.trainingDays, Math.round((data.thisWeek.trainingDays + data.lastWeek.trainingDays) / 2), data.thisWeek.trainingDays]}
                  width={48}
                  height={20}
                  barWidth={3}
                  color={CHART_COLORS.secondary}
                />
                <DeltaBadge delta={data.deltas.trainingDays} />
              </Box>
            </Box>

            {/* Grouped comparison bar chart */}
            <Box sx={{ height: { xs: 100, md: 140 }, mx: -0.5 }}>
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={chartData} margin={{ top: 4, right: 8, bottom: 0, left: -16 }} barGap={2}>
                  <XAxis
                    dataKey="metric"
                    tick={{ fill: CHART_AXIS_COLOR, fontSize: 11 }}
                    axisLine={false}
                    tickLine={false}
                  />
                  <YAxis hide />
                  <Tooltip content={<CustomTooltip />} />
                  <Bar dataKey="lastWeek" fill={`${CHART_AXIS_COLOR}40`} radius={[3, 3, 0, 0]} maxBarSize={20} />
                  <Bar dataKey="thisWeek" fill={CHART_COLORS.primary} radius={[3, 3, 0, 0]} maxBarSize={20} />
                </BarChart>
              </ResponsiveContainer>
            </Box>

            {/* Legend */}
            <Box sx={{ display: 'flex', justifyContent: 'center', gap: 2, mt: 0.75 }}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                <Box sx={{ width: 8, height: 4, borderRadius: '1px', backgroundColor: `${CHART_AXIS_COLOR}40` }} />
                <Typography variant="caption" sx={{ color: 'text.disabled', fontSize: '0.6875rem' }}>
                  Last week
                </Typography>
              </Box>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                <Box sx={{ width: 8, height: 4, borderRadius: '1px', backgroundColor: CHART_COLORS.primary }} />
                <Typography variant="caption" sx={{ color: 'text.disabled', fontSize: '0.6875rem' }}>
                  This week
                </Typography>
              </Box>
            </Box>
          </>
        )}
      </CardContent>
    </Card>
  );
}
