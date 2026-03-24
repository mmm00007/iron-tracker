import Box from '@mui/material/Box';
import CircularProgress from '@mui/material/CircularProgress';
import Typography from '@mui/material/Typography';
import { useTheme } from '@mui/material/styles';
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

// Colors for multiple variants
const VARIANT_COLORS = [
  '#A8C7FA', // primary blue
  '#66BB6A', // green
  '#F9A825', // amber
  '#EF5350', // red
  '#AB47BC', // purple
];

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
        backgroundColor: 'surface.containerHigh',
        border: '1px solid rgba(202, 196, 208, 0.2)',
        borderRadius: '8px',
        p: 1.5,
      }}
    >
      <Typography variant="caption" sx={{ color: 'text.secondary', display: 'block', mb: 0.5 }}>
        {label ? formatDate(label) : ''}
      </Typography>
      {payload.map((p, i) => (
        <Box key={i} sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
          <Box sx={{ width: 8, height: 8, borderRadius: '50%', backgroundColor: p.color }} />
          <Typography variant="caption" sx={{ color: 'text.primary' }}>
            {p.name}: {p.value.toFixed(1)} {unit}
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
  /** Map from variantId (or 'all') to display name */
  variantNames?: Map<string | null, string>;
}

export function E1RMChart({ data, isLoading, isError, variantNames }: E1RMChartProps) {
  const theme = useTheme();
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
    <Box sx={{ width: '100%', height: 240 }}>
      <ResponsiveContainer width="100%" height="100%">
        <LineChart data={chartData} margin={{ top: 5, right: 12, left: -10, bottom: 5 }}>
          <CartesianGrid strokeDasharray="3 3" stroke="rgba(202, 196, 208, 0.1)" />
          <XAxis
            dataKey="date"
            tickFormatter={formatDate}
            tick={{ fill: '#CAC4D0', fontSize: 10 }}
            axisLine={{ stroke: 'rgba(202, 196, 208, 0.2)' }}
            tickLine={false}
            interval="preserveStartEnd"
          />
          <YAxis
            tick={{ fill: '#CAC4D0', fontSize: 10 }}
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
              stroke={VARIANT_COLORS[i % VARIANT_COLORS.length]}
              strokeWidth={2}
              dot={{ r: 3, fill: VARIANT_COLORS[i % VARIANT_COLORS.length] }}
              activeDot={{ r: 5 }}
              connectNulls
            />
          ))}
          {data.length > 20 && (
            <Brush
              dataKey="date"
              height={20}
              stroke="rgba(202, 196, 208, 0.2)"
              fill={theme.palette.surface.containerHighest}
              tickFormatter={formatDate}
            />
          )}
        </LineChart>
      </ResponsiveContainer>
    </Box>
  );
}
