import Box from '@mui/material/Box';
import CircularProgress from '@mui/material/CircularProgress';
import Typography from '@mui/material/Typography';
import {
  ComposedChart,
  Bar,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
  Cell,
} from 'recharts';
import type { WeeklyVolumeEntry } from '@/utils/analytics';
import { CHART_COLORS, DATA_FONT } from '@/theme';

function formatWeek(weekStr: string): string {
  const [year, week] = weekStr.split('-W');
  const jan4 = new Date(Number(year), 0, 4);
  const jan4DayOfWeek = jan4.getDay() || 7;
  const monday = new Date(jan4);
  monday.setDate(jan4.getDate() - (jan4DayOfWeek - 1) + (Number(week) - 1) * 7);
  return monday.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
}

interface CustomTooltipProps {
  active?: boolean;
  payload?: Array<{ value: number; name: string; color: string; dataKey: string }>;
  label?: string;
}

function CustomTooltip({ active, payload, label }: CustomTooltipProps) {
  if (!active || !payload || payload.length === 0) return null;
  const barPayloads = payload.filter((p) => p.dataKey !== 'movingAvg');
  const total = barPayloads.reduce((sum, p) => sum + p.value, 0);
  return (
    <Box
      sx={{
        backgroundColor: 'rgba(20, 24, 32, 0.95)',
        border: '1px solid rgba(160, 170, 184, 0.12)',
        borderRadius: '8px',
        p: 1.5,
        backdropFilter: 'blur(8px)',
      }}
    >
      <Typography variant="caption" sx={{ color: '#A0AAB8', display: 'block', mb: 0.5 }}>
        {label ? formatWeek(label) : ''}
      </Typography>
      {barPayloads.map((p, i) => (
        <Box key={i} sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
          <Box sx={{ width: 8, height: 8, borderRadius: '2px', backgroundColor: p.color }} />
          <Typography variant="caption" sx={{ color: '#EAEEF4' }}>
            {p.name}:{' '}
          </Typography>
          <Typography
            sx={{ fontFamily: DATA_FONT, fontSize: '0.75rem', fontWeight: 700, color: '#EAEEF4' }}
          >
            {Math.round(p.value).toLocaleString()}
          </Typography>
        </Box>
      ))}
      <Typography
        sx={{
          fontFamily: DATA_FONT,
          fontSize: '0.75rem',
          fontWeight: 700,
          color: CHART_COLORS.primary,
          display: 'block',
          mt: 0.5,
          pt: 0.5,
          borderTop: '1px solid rgba(160, 170, 184, 0.12)',
        }}
      >
        Total: {Math.round(total).toLocaleString()}
      </Typography>
    </Box>
  );
}

interface VolumeChartProps {
  data: WeeklyVolumeEntry[];
  isLoading?: boolean;
  isError?: boolean;
  variantNames?: Map<string, string>;
}

export function VolumeChart({ data, isLoading, isError, variantNames }: VolumeChartProps) {
  if (isLoading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', py: 4 }}>
        <CircularProgress size={28} />
      </Box>
    );
  }

  if (isError) {
    return (
      <Typography variant="body2" sx={{ color: 'error.main', textAlign: 'center', py: 3 }}>
        Failed to load volume data
      </Typography>
    );
  }

  if (data.length === 0) {
    return (
      <Box sx={{ py: 5, textAlign: 'center' }}>
        <Typography variant="body2" sx={{ color: 'text.disabled' }}>
          No volume data yet.
        </Typography>
        <Typography variant="caption" sx={{ color: 'text.disabled' }}>
          Log sets to see weekly volume trends.
        </Typography>
      </Box>
    );
  }

  // Get unique variant keys across all weeks
  const variantKeys = [...new Set(data.flatMap((d) => Object.keys(d.variantBreakdown)))];
  const isMultiVariant = variantKeys.length > 1 || (variantKeys.length === 1 && variantKeys[0] !== 'none');

  // Build chart data with moving average
  const chartData = data.map((entry, idx) => {
    const row: Record<string, string | number> = { week: entry.week };
    if (isMultiVariant) {
      for (const key of variantKeys) {
        row[key] = entry.variantBreakdown[key] ?? 0;
      }
    } else {
      row['volume'] = entry.volume;
    }
    // 4-week simple moving average
    const windowStart = Math.max(0, idx - 3);
    const windowSlice = data.slice(windowStart, idx + 1);
    row['movingAvg'] = Math.round(windowSlice.reduce((s, e) => s + e.volume, 0) / windowSlice.length);
    return row;
  });

  const getVariantLabel = (key: string): string => {
    if (variantNames?.has(key)) return variantNames.get(key)!;
    if (key === 'none') return 'No variant';
    return `Variant ${key.slice(0, 6)}`;
  };

  return (
    <Box sx={{ width: '100%', height: { xs: 260, md: 340, lg: 420 } }}>
      <ResponsiveContainer width="100%" height="100%">
        <ComposedChart data={chartData} margin={{ top: 8, right: 12, left: -8, bottom: 5 }}>
          <CartesianGrid strokeDasharray="3 3" stroke="rgba(160, 170, 184, 0.06)" vertical={false} />
          <XAxis
            dataKey="week"
            tickFormatter={formatWeek}
            tick={{ fill: '#636D7E', fontSize: 10, fontFamily: DATA_FONT }}
            axisLine={{ stroke: 'rgba(160, 170, 184, 0.1)' }}
            tickLine={false}
            interval="preserveStartEnd"
          />
          <YAxis
            tick={{ fill: '#636D7E', fontSize: 10, fontFamily: DATA_FONT }}
            axisLine={false}
            tickLine={false}
            tickFormatter={(v) => v >= 1000 ? `${(v / 1000).toFixed(0)}k` : `${v}`}
            width={40}
          />
          <Tooltip content={<CustomTooltip />} />
          {isMultiVariant && (
            <Legend
              formatter={(value) => (
                <Typography component="span" variant="caption" sx={{ color: 'text.secondary' }}>
                  {value === 'movingAvg' ? '4-wk avg' : getVariantLabel(value)}
                </Typography>
              )}
            />
          )}
          {isMultiVariant ? (
            variantKeys.map((key, i) => (
              <Bar
                key={key}
                dataKey={key}
                name={getVariantLabel(key)}
                stackId="a"
                fill={CHART_COLORS.series[i % CHART_COLORS.series.length]}
                radius={i === variantKeys.length - 1 ? [4, 4, 0, 0] : [0, 0, 0, 0]}
              />
            ))
          ) : (
            <Bar dataKey="volume" name="Volume" fill={CHART_COLORS.primary} radius={[4, 4, 0, 0]}>
              {chartData.map((_entry, index) => (
                <Cell
                  key={`cell-${index}`}
                  fill={index === chartData.length - 1 ? CHART_COLORS.primary : `${CHART_COLORS.primary}80`}
                />
              ))}
            </Bar>
          )}
          {/* 4-week moving average trend line */}
          <Line
            type="monotone"
            dataKey="movingAvg"
            name="4-wk avg"
            stroke="#F9A825"
            strokeWidth={2}
            strokeDasharray="6 3"
            dot={false}
            activeDot={false}
          />
        </ComposedChart>
      </ResponsiveContainer>
    </Box>
  );
}
