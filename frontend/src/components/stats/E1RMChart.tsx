import Box from '@mui/material/Box';
import CircularProgress from '@mui/material/CircularProgress';
import Typography from '@mui/material/Typography';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Brush,
  Legend,
} from 'recharts';
import type { E1RMDataPoint } from '@/utils/analytics';
import { useProfile } from '@/hooks/useProfile';
import { CHART_COLORS, DATA_FONT } from '@/theme';

function formatDate(dateStr: string): string {
  const d = new Date(dateStr);
  return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
}

interface CustomTooltipProps {
  active?: boolean;
  payload?: Array<{ value: number; name: string; color: string }>;
  label?: string;
  unit?: string;
}

function CustomTooltip({ active, payload, label, unit = 'kg' }: CustomTooltipProps) {
  if (!active || !payload || payload.length === 0) return null;
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
        {label ? formatDate(label) : ''}
      </Typography>
      {payload.map((p, i) => (
        <Box key={i} sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
          <Box sx={{ width: 8, height: 8, borderRadius: '50%', backgroundColor: p.color }} />
          <Typography variant="caption" sx={{ color: '#EAEEF4' }}>
            {p.name}:{' '}
          </Typography>
          <Typography
            sx={{
              fontFamily: DATA_FONT,
              fontSize: '0.75rem',
              fontWeight: 700,
              color: p.color,
            }}
          >
            {p.value.toFixed(1)} {unit}
          </Typography>
        </Box>
      ))}
    </Box>
  );
}

interface E1RMChartProps {
  data: E1RMDataPoint[];
  isLoading?: boolean;
  isError?: boolean;
  variantNames?: Map<string | null, string>;
}

export function E1RMChart({ data, isLoading, isError, variantNames }: E1RMChartProps) {
  const { data: profile } = useProfile();
  const unit = profile?.preferred_weight_unit ?? 'kg';

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
        Failed to load 1RM trend
      </Typography>
    );
  }

  if (data.length === 0) {
    return (
      <Box sx={{ py: 5, textAlign: 'center' }}>
        <Typography variant="body2" sx={{ color: 'text.disabled' }}>
          Not enough data yet.
        </Typography>
        <Typography variant="caption" sx={{ color: 'text.disabled' }}>
          Log sets to see your 1RM trend.
        </Typography>
      </Box>
    );
  }

  // Group by variant for multi-line chart
  const variantIds = [...new Set(data.map((d) => d.variantId))];
  const multiVariant = variantIds.length > 1;

  // Build chart data: one entry per date, with a field per variant
  const dateMap = new Map<string, Record<string, number | string>>();
  for (const point of data) {
    const key = point.variantId ?? 'none';
    if (!dateMap.has(point.date)) {
      dateMap.set(point.date, { date: point.date });
    }
    dateMap.get(point.date)![key] = point.e1rm;
  }
  const chartData = Array.from(dateMap.values()).sort((a, b) =>
    String(a.date).localeCompare(String(b.date)),
  );

  const getVariantName = (id: string | null): string => {
    if (variantNames) return variantNames.get(id) ?? (id ? `Variant ${id.slice(0, 6)}` : 'All');
    return id ? `Variant` : 'All';
  };

  return (
    <Box sx={{ width: '100%', height: { xs: 260, md: 340, lg: 420 } }}>
      <ResponsiveContainer width="100%" height="100%">
        <LineChart data={chartData} margin={{ top: 8, right: 12, left: -8, bottom: 5 }}>
          <defs>
            {variantIds.map((variantId, i) => {
              const color = CHART_COLORS.series[i % CHART_COLORS.series.length];
              return (
                <linearGradient
                  key={variantId ?? 'none'}
                  id={`line-gradient-${i}`}
                  x1="0"
                  y1="0"
                  x2="0"
                  y2="1"
                >
                  <stop offset="0%" stopColor={color} stopOpacity={0.2} />
                  <stop offset="100%" stopColor={color} stopOpacity={0} />
                </linearGradient>
              );
            })}
          </defs>
          <CartesianGrid strokeDasharray="3 3" stroke="rgba(160, 170, 184, 0.06)" />
          <XAxis
            dataKey="date"
            tickFormatter={formatDate}
            tick={{ fill: '#636D7E', fontSize: 10, fontFamily: DATA_FONT }}
            axisLine={{ stroke: 'rgba(160, 170, 184, 0.1)' }}
            tickLine={false}
            interval="preserveStartEnd"
          />
          <YAxis
            tick={{ fill: '#636D7E', fontSize: 10, fontFamily: DATA_FONT }}
            axisLine={false}
            tickLine={false}
            tickFormatter={(v) => `${v}`}
            width={40}
          />
          <Tooltip content={<CustomTooltip unit={unit} />} />
          {multiVariant && (
            <Legend
              formatter={(value) => (
                <Typography component="span" variant="caption" sx={{ color: 'text.secondary' }}>
                  {value}
                </Typography>
              )}
            />
          )}
          {variantIds.map((variantId, i) => (
            <Line
              key={variantId ?? 'none'}
              type="monotone"
              dataKey={variantId ?? 'none'}
              name={getVariantName(variantId)}
              stroke={CHART_COLORS.series[i % CHART_COLORS.series.length]}
              strokeWidth={2.5}
              dot={{ r: 3, fill: CHART_COLORS.series[i % CHART_COLORS.series.length], strokeWidth: 0 }}
              activeDot={{
                r: 6,
                fill: CHART_COLORS.series[i % CHART_COLORS.series.length],
                stroke: '#0D0F12',
                strokeWidth: 2,
              }}
              connectNulls
            />
          ))}
          {data.length > 20 && (
            <Brush
              dataKey="date"
              height={22}
              stroke="rgba(160, 170, 184, 0.15)"
              fill="#141820"
              tickFormatter={formatDate}
            />
          )}
        </LineChart>
      </ResponsiveContainer>
    </Box>
  );
}
