import { useMemo } from 'react';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  Legend,
  ResponsiveContainer,
  type TooltipProps,
} from 'recharts';
import type { WeeklyMuscleVolume } from '@/hooks/useMuscleVolume';
import { CHART_COLORS, DATA_FONT } from '@/theme';

function formatWeek(week: string): string {
  const d = new Date(week + 'T00:00:00');
  return `${d.getMonth() + 1}/${d.getDate()}`;
}

function CustomTooltip({ active, payload, label }: TooltipProps<number, string>) {
  if (!active || !payload) return null;

  const total = payload.reduce((sum, p) => sum + (p.value ?? 0), 0);

  return (
    <Box
      sx={{
        backgroundColor: 'rgba(20, 24, 32, 0.95)',
        border: '1px solid rgba(160, 170, 184, 0.12)',
        borderRadius: '8px',
        p: 1.5,
        minWidth: 140,
        backdropFilter: 'blur(8px)',
      }}
    >
      <Typography variant="caption" sx={{ color: '#A0AAB8', display: 'block', mb: 0.5 }}>
        Week of {label}
      </Typography>
      {payload.map((p) => (
        <Box key={p.dataKey} sx={{ display: 'flex', justifyContent: 'space-between', gap: 2 }}>
          <Typography variant="caption" sx={{ color: p.color }}>
            {p.name}
          </Typography>
          <Typography sx={{ fontFamily: DATA_FONT, fontSize: '0.6875rem', color: '#EAEEF4', fontWeight: 600 }}>
            {(p.value ?? 0).toLocaleString()}
          </Typography>
        </Box>
      ))}
      <Box sx={{ borderTop: '1px solid rgba(160, 170, 184, 0.12)', mt: 0.5, pt: 0.5 }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
          <Typography variant="caption" sx={{ color: '#A0AAB8' }}>
            Total
          </Typography>
          <Typography sx={{ fontFamily: DATA_FONT, fontSize: '0.6875rem', color: CHART_COLORS.primary, fontWeight: 700 }}>
            {total.toLocaleString()}
          </Typography>
        </Box>
      </Box>
    </Box>
  );
}

interface MuscleVolumeChartProps {
  data: WeeklyMuscleVolume[];
}

export function MuscleVolumeChart({ data }: MuscleVolumeChartProps) {
  const { chartData, muscleGroups } = useMemo(() => {
    const weeks = [...new Set(data.map((d) => d.week))].sort();
    const muscles = [...new Set(data.map((d) => d.muscleGroup))].sort();

    const rows = weeks.map((week) => {
      const row: Record<string, string | number> = { week: formatWeek(week) };
      for (const muscle of muscles) {
        const entry = data.find((d) => d.week === week && d.muscleGroup === muscle);
        row[muscle] = entry?.volume ?? 0;
      }
      return row;
    });

    return { chartData: rows, muscleGroups: muscles };
  }, [data]);

  if (chartData.length === 0) {
    return (
      <Typography variant="body2" color="text.secondary" sx={{ py: 2, textAlign: 'center' }}>
        No data for this period
      </Typography>
    );
  }

  return (
    <ResponsiveContainer width="100%" height={280}>
      <BarChart data={chartData} margin={{ top: 8, right: 8, left: -16, bottom: 0 }}>
        <XAxis
          dataKey="week"
          tick={{ fontSize: 10, fill: '#636D7E', fontFamily: DATA_FONT }}
          axisLine={false}
          tickLine={false}
        />
        <YAxis
          tick={{ fontSize: 10, fill: '#636D7E', fontFamily: DATA_FONT }}
          axisLine={false}
          tickLine={false}
          tickFormatter={(v: number) => (v >= 1000 ? `${(v / 1000).toFixed(0)}k` : String(v))}
        />
        <Tooltip content={<CustomTooltip />} cursor={{ fill: 'rgba(91, 234, 162, 0.04)' }} />
        <Legend
          iconType="circle"
          iconSize={8}
          wrapperStyle={{ fontSize: '0.6rem', paddingTop: '8px' }}
        />
        {muscleGroups.map((muscle, idx) => (
          <Bar
            key={muscle}
            dataKey={muscle}
            stackId="volume"
            fill={CHART_COLORS.getMuscleColor(muscle, idx)}
            radius={idx === muscleGroups.length - 1 ? [3, 3, 0, 0] : undefined}
          />
        ))}
      </BarChart>
    </ResponsiveContainer>
  );
}
