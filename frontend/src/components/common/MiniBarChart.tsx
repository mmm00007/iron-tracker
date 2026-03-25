import Box from '@mui/material/Box';
import { CHART_COLORS } from '@/theme';

interface MiniBarChartProps {
  data: number[];
  color?: string;
  height?: number;
  width?: number;
  barWidth?: number;
}

export function MiniBarChart({
  data,
  color = CHART_COLORS.primary,
  height = 32,
  width = 60,
  barWidth = 4,
}: MiniBarChartProps) {
  if (data.length === 0) return null;

  const max = Math.max(...data, 1);

  return (
    <Box
      sx={{
        width,
        height,
        display: 'flex',
        alignItems: 'flex-end',
        gap: '2px',
        flexShrink: 0,
      }}
    >
      {data.map((value, i) => (
        <Box
          key={i}
          sx={{
            width: barWidth,
            height: Math.max(2, (value / max) * height),
            backgroundColor: i === data.length - 1 ? color : `${color}50`,
            borderRadius: '1.5px',
            transition: 'height 0.2s',
          }}
        />
      ))}
    </Box>
  );
}
