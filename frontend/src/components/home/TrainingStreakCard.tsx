import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Skeleton from '@mui/material/Skeleton';
import Typography from '@mui/material/Typography';
import LocalFireDepartmentIcon from '@mui/icons-material/LocalFireDepartment';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  ResponsiveContainer,
  Cell,
  ReferenceLine,
} from 'recharts';
import { useTrainingStreak } from '@/hooks/useAnalytics';
import { useTrainingFrequencyWeekly } from '@/hooks/useAnalytics';
import { DATA_FONT, CHART_COLORS, CHART_AXIS_COLOR } from '@/theme';

export function TrainingStreakCard() {
  const { data: streakData, isLoading: streakLoading } = useTrainingStreak();
  const { data: weeklyData, isLoading: weeklyLoading } = useTrainingFrequencyWeekly();

  const isLoading = streakLoading || weeklyLoading;

  if (isLoading) {
    return <Skeleton variant="rounded" height={160} sx={{ borderRadius: '16px' }} />;
  }

  const hasStreak = streakData && (streakData.currentDayStreak > 0 || streakData.currentWeekStreak > 0);

  // Build chart data: training days per week for last 8 weeks
  const chartData = (weeklyData ?? []).slice(-8).map((w) => ({
    label: w.label,
    days: w.days,
  }));

  const avgDays = chartData.length > 0
    ? chartData.reduce((sum, d) => sum + d.days, 0) / chartData.length
    : 0;

  if (!hasStreak && chartData.length === 0) {
    return (
      <Card>
        <CardContent sx={{ p: 2, '&:last-child': { pb: 2 }, textAlign: 'center' }}>
          <LocalFireDepartmentIcon sx={{ color: 'text.disabled', fontSize: 28, mb: 0.5 }} />
          <Typography variant="body2" sx={{ color: 'text.secondary' }}>
            Log your first workout to start a streak
          </Typography>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
        {/* Header with streak badges */}
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 1.5 }}>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <Box
              sx={{
                width: 32,
                height: 32,
                borderRadius: '8px',
                background: 'linear-gradient(135deg, rgba(255, 152, 0, 0.15), rgba(255, 87, 34, 0.10))',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                flexShrink: 0,
              }}
            >
              <LocalFireDepartmentIcon sx={{ color: '#FF9800', fontSize: 20 }} />
            </Box>
            <Typography variant="subtitle2" sx={{ color: 'text.secondary', fontWeight: 500 }}>
              Training Frequency
            </Typography>
          </Box>

          {hasStreak && (
            <Box sx={{ display: 'flex', gap: 2 }}>
              <Box sx={{ textAlign: 'right' }}>
                <Typography
                  sx={{
                    fontFamily: DATA_FONT,
                    fontSize: '1.25rem',
                    fontWeight: 800,
                    color: 'text.primary',
                    lineHeight: 1,
                  }}
                >
                  {streakData!.currentDayStreak}
                </Typography>
                <Typography variant="caption" sx={{ color: 'text.disabled', fontSize: '0.6875rem' }}>
                  DAY STREAK
                </Typography>
              </Box>
              <Box sx={{ textAlign: 'right' }}>
                <Typography
                  sx={{
                    fontFamily: DATA_FONT,
                    fontSize: '1.25rem',
                    fontWeight: 800,
                    color: 'text.primary',
                    lineHeight: 1,
                  }}
                >
                  {streakData!.currentWeekStreak}
                </Typography>
                <Typography variant="caption" sx={{ color: 'text.disabled', fontSize: '0.6875rem' }}>
                  WEEK STREAK
                </Typography>
              </Box>
            </Box>
          )}
        </Box>

        {/* Training days per week bar chart */}
        {chartData.length > 0 && (
          <Box sx={{ height: 100, mx: -0.5 }}>
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={chartData} margin={{ top: 4, right: 4, bottom: 0, left: -24 }}>
                <XAxis
                  dataKey="label"
                  tick={{ fill: CHART_AXIS_COLOR, fontSize: 11 }}
                  axisLine={false}
                  tickLine={false}
                />
                <YAxis
                  domain={[0, 7]}
                  ticks={[0, 2, 4, 6]}
                  tick={{ fill: CHART_AXIS_COLOR, fontSize: 11 }}
                  axisLine={false}
                  tickLine={false}
                  width={28}
                />
                {avgDays > 0 && (
                  <ReferenceLine
                    y={Math.round(avgDays * 10) / 10}
                    stroke="#5BEAA240"
                    strokeDasharray="4 4"
                    strokeWidth={1}
                  />
                )}
                <Bar dataKey="days" radius={[3, 3, 0, 0]} maxBarSize={24}>
                  {chartData.map((_entry, index) => (
                    <Cell
                      key={index}
                      fill={
                        index === chartData.length - 1
                          ? CHART_COLORS.primary
                          : `${CHART_COLORS.primary}60`
                      }
                    />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </Box>
        )}

        {/* Average label */}
        {avgDays > 0 && (
          <Typography
            variant="caption"
            sx={{ color: 'text.disabled', display: 'block', textAlign: 'center', mt: 0.5, fontSize: '0.6875rem' }}
          >
            Avg {avgDays.toFixed(1)} days/week
          </Typography>
        )}
      </CardContent>
    </Card>
  );
}
