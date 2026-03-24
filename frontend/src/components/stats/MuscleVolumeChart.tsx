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

const MUSCLE_COLORS: Record<string, string> = {
  Chest: '#EF5350',
  Pectoralis: '#EF5350',
  Back: '#42A5F5',
  Latissimus: '#42A5F5',
  Shoulders: '#FFA726',
  Deltoids: '#FFA726',
  Biceps: '#66BB6A',
  Triceps: '#AB47BC',
  Quadriceps: '#26C6DA',
  Hamstrings: '#00897B',
  Glutes: '#EC407A',
  Calves: '#78909C',
  Abdominals: '#F9A825',
  Core: '#F9A825',
  Forearms: '#8D6E63',
  Trapezius: '#7E57C2',
};

const FALLBACK_COLORS = ['#90CAF9', '#A5D6A7', '#FFCC80', '#CE93D8', '#80DEEA', '#EF9A9A'];

function getColor(muscle: string, idx: number): string {
  // Try exact match first, then partial match
  if (MUSCLE_COLORS[muscle]) return MUSCLE_COLORS[muscle];
  for (const [key, color] of Object.entries(MUSCLE_COLORS)) {
    if (muscle.toLowerCase().includes(key.toLowerCase())) return color;
  }
  return FALLBACK_COLORS[idx % FALLBACK_COLORS.length]!;
}

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
        backgroundColor: 'rgba(30, 30, 30, 0.95)',
        border: '1px solid rgba(202, 196, 208, 0.2)',
        borderRadius: 1,
        p: 1.5,
        minWidth: 140,
      }}
    >
      <Typography variant="caption" sx={{ color: 'text.secondary', display: 'block', mb: 0.5 }}>
        Week of {label}
      </Typography>
      {payload.map((p) => (
        <Box key={p.dataKey} sx={{ display: 'flex', justifyContent: 'space-between', gap: 2 }}>
          <Typography variant="caption" sx={{ color: p.color }}>
            {p.name}
          </Typography>
          <Typography variant="caption" sx={{ color: 'text.primary', fontWeight: 600 }}>
            {(p.value ?? 0).toLocaleString()}
          </Typography>
        </Box>
      ))}
      <Box sx={{ borderTop: '1px solid rgba(202, 196, 208, 0.2)', mt: 0.5, pt: 0.5 }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
          <Typography variant="caption" sx={{ color: 'text.secondary' }}>
            Total
          </Typography>
          <Typography variant="caption" sx={{ color: 'text.primary', fontWeight: 700 }}>
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
    // Pivot: rows = weeks, columns = muscle groups
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
    <ResponsiveContainer width="100%" height={260}>
      <BarChart data={chartData} margin={{ top: 8, right: 8, left: -16, bottom: 0 }}>
        <XAxis
          dataKey="week"
          tick={{ fontSize: 11, fill: '#CAC4D0' }}
          axisLine={false}
          tickLine={false}
        />
        <YAxis
          tick={{ fontSize: 11, fill: '#938F99' }}
          axisLine={false}
          tickLine={false}
          tickFormatter={(v: number) => (v >= 1000 ? `${(v / 1000).toFixed(0)}k` : String(v))}
        />
        <Tooltip content={<CustomTooltip />} cursor={{ fill: 'rgba(168, 199, 250, 0.06)' }} />
        <Legend
          iconType="circle"
          iconSize={8}
          wrapperStyle={{ fontSize: '0.65rem', paddingTop: '8px' }}
        />
        {muscleGroups.map((muscle, idx) => (
          <Bar
            key={muscle}
            dataKey={muscle}
            stackId="volume"
            fill={getColor(muscle, idx)}
            radius={idx === muscleGroups.length - 1 ? [2, 2, 0, 0] : undefined}
          />
        ))}
      </BarChart>
    </ResponsiveContainer>
  );
}
