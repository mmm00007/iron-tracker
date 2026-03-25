import Box from '@mui/material/Box';
import { AreaChart, Area, ResponsiveContainer } from 'recharts';
import { CHART_COLORS } from '@/theme';

interface SparklineProps {
  data: number[];
  color?: string;
  height?: number;
  width?: number;
  filled?: boolean;
}

export function Sparkline({
  data,
  color = CHART_COLORS.primary,
  height = 32,
  width = 80,
  filled = false,
}: SparklineProps) {
  if (data.length < 2) return null;

  const chartData = data.map((value, index) => ({ index, value }));
  const gradientId = `spark-${color.replace('#', '')}`;

  return (
    <Box sx={{ width, height, flexShrink: 0 }}>
      <ResponsiveContainer width="100%" height="100%">
        <AreaChart data={chartData} margin={{ top: 2, right: 2, bottom: 2, left: 2 }}>
          {filled && (
            <defs>
              <linearGradient id={gradientId} x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor={color} stopOpacity={0.2} />
                <stop offset="100%" stopColor={color} stopOpacity={0} />
              </linearGradient>
            </defs>
          )}
          <Area
            type="monotone"
            dataKey="value"
            stroke={color}
            strokeWidth={1.5}
            fill={filled ? `url(#${gradientId})` : 'transparent'}
            dot={false}
            isAnimationActive={false}
          />
        </AreaChart>
      </ResponsiveContainer>
    </Box>
  );
}
