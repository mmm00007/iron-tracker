import Box from '@mui/material/Box';
import CircularProgress from '@mui/material/CircularProgress';
import Typography from '@mui/material/Typography';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
  Cell,
} from 'recharts';
import type { WeeklyVolumeEntry } from '@/utils/analytics';

const VARIANT_COLORS = [
  '#A8C7FA',
  '#66BB6A',
  '#F9A825',
  '#EF5350',
  '#AB47BC',
];

function formatWeek(weekStr: string): string {
  // weekStr is YYYY-Www; convert to readable label like "Jan 6"
  const [year, week] = weekStr.split('-W');
  // Compute the Monday of that ISO week
  const jan4 = new Date(Number(year), 0, 4); // Jan 4 is always in week 1
  const jan4DayOfWeek = jan4.getDay() || 7;
  const monday = new Date(jan4);
  monday.setDate(jan4.getDate() - (jan4DayOfWeek - 1) + (Number(week) - 1) * 7);
  return monday.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
}

interface CustomTooltipProps {
  active?: boolean;
  payload?: Array<{ value: number; name: string; color: string }>;
  label?: string;
}

function CustomTooltip({ active, payload, label }: CustomTooltipProps) {
  if (!active || !payload || payload.length === 0) return null;
  const total = payload.reduce((sum, p) => sum + p.value, 0);
  return (
    <Box
      sx={{
        backgroundColor: '#2A2A3E',
        border: '1px solid rgba(202, 196, 208, 0.2)',
        borderRadius: '8px',
        p: 1.5,
      }}
    >
      <Typography variant="caption" sx={{ color: 'text.secondary', display: 'block', mb: 0.5 }}>
        {label ? formatWeek(label) : ''}
      </Typography>
      {payload.map((p, i) => (
        <Box key={i} sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
          <Box sx={{ width: 8, height: 8, borderRadius: '2px', backgroundColor: p.color }} />
          <Typography variant="caption" sx={{ color: 'text.primary' }}>
            {p.name}: {Math.round(p.value).toLocaleString()}
          </Typography>
        </Box>
      ))}
      <Typography variant="caption" sx={{ color: 'primary.main', fontWeight: 600, display: 'block', mt: 0.5 }}>
        Total: {Math.round(total).toLocaleString()}
      </Typography>
    </Box>
  );
}

interface VolumeChartProps {
  data: WeeklyVolumeEntry[];
  isLoading?: boolean;
  isError?: boolean;
  /** Map from variantId (or 'none') to display name */
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

  // Build chart data
  const chartData = data.map((entry) => {
    const row: Record<string, string | number> = { week: entry.week };
    if (isMultiVariant) {
      for (const key of variantKeys) {
        row[key] = entry.variantBreakdown[key] ?? 0;
      }
    } else {
      row['volume'] = entry.volume;
    }
    return row;
  });

  const getVariantLabel = (key: string): string => {
    if (variantNames?.has(key)) return variantNames.get(key)!;
    if (key === 'none') return 'No variant';
    return `Variant ${key.slice(0, 6)}`;
  };

  return (
    <Box sx={{ width: '100%', height: 240 }}>
      <ResponsiveContainer width="100%" height="100%">
        <BarChart data={chartData} margin={{ top: 5, right: 12, left: -10, bottom: 5 }}>
          <CartesianGrid strokeDasharray="3 3" stroke="rgba(202, 196, 208, 0.1)" vertical={false} />
          <XAxis
            dataKey="week"
            tickFormatter={formatWeek}
            tick={{ fill: '#CAC4D0', fontSize: 10 }}
            axisLine={{ stroke: 'rgba(202, 196, 208, 0.2)' }}
            tickLine={false}
            interval="preserveStartEnd"
          />
          <YAxis
            tick={{ fill: '#CAC4D0', fontSize: 10 }}
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
                  {getVariantLabel(value)}
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
                fill={VARIANT_COLORS[i % VARIANT_COLORS.length]}
                radius={i === variantKeys.length - 1 ? [3, 3, 0, 0] : [0, 0, 0, 0]}
              />
            ))
          ) : (
            <Bar dataKey="volume" name="Volume" fill="#A8C7FA" radius={[3, 3, 0, 0]}>
              {chartData.map((_entry, index) => (
                <Cell
                  key={`cell-${index}`}
                  fill={index === chartData.length - 1 ? '#5B8DEF' : '#A8C7FA'}
                />
              ))}
            </Bar>
          )}
        </BarChart>
      </ResponsiveContainer>
    </Box>
  );
}
