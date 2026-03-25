import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Skeleton from '@mui/material/Skeleton';
import Typography from '@mui/material/Typography';
import ShowChartIcon from '@mui/icons-material/ShowChart';
import {
  AreaChart,
  Area,
  XAxis,
  ResponsiveContainer,
  Tooltip,
  ReferenceLine,
} from 'recharts';
import { useVolumeTrendSpark } from '@/hooks/useAnalytics';
import { DATA_FONT, CHART_COLORS } from '@/theme';

function CustomTooltip({ active, payload }: { active?: boolean; payload?: Array<{ value: number }> }) {
  if (!active || !payload || payload.length === 0) return null;
  const val = payload[0]!.value;
  return (
    <Box
      sx={{
        backgroundColor: 'rgba(20, 24, 32, 0.95)',
        border: '1px solid rgba(160, 170, 184, 0.15)',
        borderRadius: '6px',
        px: 1,
        py: 0.5,
      }}
    >
      <Typography sx={{ fontFamily: DATA_FONT, fontSize: '0.75rem', fontWeight: 700, color: '#EAEEF4' }}>
        {val >= 1000 ? `${(val / 1000).toFixed(1)}k` : Math.round(val)}
      </Typography>
    </Box>
  );
}

export function VolumeTrendCard() {
  const { data, isLoading } = useVolumeTrendSpark();

  if (isLoading) {
    return <Skeleton variant="rounded" height={160} sx={{ borderRadius: '16px' }} />;
  }

  if (!data || data.length < 2) {
    return null;
  }

  const current = data[data.length - 1] ?? 0;
  const previous = data[data.length - 2] ?? 0;
  const trend = previous > 0 ? Math.round(((current - previous) / previous) * 100) : 0;

  const chartData = data.map((value, index) => ({ index, value }));
  const avgValue = data.reduce((sum, v) => sum + v, 0) / data.length;

  return (
    <Card>
      <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
        {/* Header */}
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 1 }}>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.75 }}>
            <Box
              sx={{
                width: 32,
                height: 32,
                borderRadius: '8px',
                backgroundColor: `${CHART_COLORS.primary}15`,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                flexShrink: 0,
              }}
            >
              <ShowChartIcon sx={{ fontSize: 18, color: CHART_COLORS.primary }} />
            </Box>
            <Typography variant="subtitle2" sx={{ color: 'text.secondary', fontWeight: 500 }}>
              Weekly Volume
            </Typography>
          </Box>
          {trend !== 0 && (
            <Typography
              sx={{
                fontFamily: DATA_FONT,
                fontSize: '0.75rem',
                fontWeight: 700,
                color: trend > 0 ? 'success.main' : 'error.main',
              }}
            >
              {trend > 0 ? '+' : ''}{trend}%
            </Typography>
          )}
        </Box>

        {/* Big number */}
        <Typography
          sx={{
            fontFamily: DATA_FONT,
            fontSize: '1.5rem',
            fontWeight: 800,
            color: 'text.primary',
            lineHeight: 1,
            mb: 1.5,
          }}
        >
          {current >= 1000 ? `${(current / 1000).toFixed(1)}k` : Math.round(current)}
        </Typography>

        {/* Area chart */}
        <Box sx={{ height: { xs: 80, md: 100 }, mx: -1 }}>
          <ResponsiveContainer width="100%" height="100%">
            <AreaChart data={chartData} margin={{ top: 4, right: 4, bottom: 0, left: 4 }}>
              <defs>
                <linearGradient id="volumeGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor={CHART_COLORS.primary} stopOpacity={0.4} />
                  <stop offset="100%" stopColor={CHART_COLORS.primary} stopOpacity={0.06} />
                </linearGradient>
              </defs>
              <XAxis dataKey="index" hide />
              <Tooltip content={<CustomTooltip />} />
              <ReferenceLine
                y={avgValue}
                stroke={`${CHART_COLORS.primary}40`}
                strokeDasharray="4 4"
                strokeWidth={1}
              />
              <Area
                type="monotone"
                dataKey="value"
                stroke={CHART_COLORS.primary}
                strokeWidth={2}
                fill="url(#volumeGradient)"
                dot={false}
                activeDot={{ r: 4, fill: CHART_COLORS.primary, stroke: '#0D0F12', strokeWidth: 2 }}
              />
            </AreaChart>
          </ResponsiveContainer>
        </Box>
      </CardContent>
    </Card>
  );
}
