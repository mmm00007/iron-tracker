import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CircularProgress from '@mui/material/CircularProgress';
import Typography from '@mui/material/Typography';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import TrendingDownIcon from '@mui/icons-material/TrendingDown';
import TrendingFlatIcon from '@mui/icons-material/TrendingFlat';
import { useWeeklySnapshot } from '@/hooks/useAnalytics';

interface DeltaBadgeProps {
  delta: number | null;
}

function DeltaBadge({ delta }: DeltaBadgeProps) {
  if (delta === null) {
    return (
      <Typography variant="caption" sx={{ color: 'text.disabled' }}>
        —
      </Typography>
    );
  }

  const isUp = delta > 0;
  const isDown = delta < 0;
  const color = isUp ? 'success.main' : isDown ? 'error.main' : 'text.secondary';
  const Icon = isUp ? TrendingUpIcon : isDown ? TrendingDownIcon : TrendingFlatIcon;

  return (
    <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.25 }}>
      <Icon sx={{ fontSize: '0.875rem', color }} />
      <Typography variant="caption" sx={{ color, fontWeight: 600 }}>
        {isUp ? '+' : ''}{delta}%
      </Typography>
    </Box>
  );
}

interface MetricCellProps {
  label: string;
  value: string | number;
  delta: number | null;
}

function MetricCell({ label, value, delta }: MetricCellProps) {
  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: 0.25,
        p: 1.5,
        borderRadius: '12px',
        backgroundColor: 'rgba(255,255,255,0.03)',
        border: '1px solid rgba(202, 196, 208, 0.08)',
      }}
    >
      <Typography variant="overline" sx={{ color: 'text.disabled', lineHeight: 1.2, fontSize: '0.6rem' }}>
        {label}
      </Typography>
      <Typography variant="h5" sx={{ fontWeight: 700, color: 'text.primary', lineHeight: 1 }}>
        {value}
      </Typography>
      <DeltaBadge delta={delta} />
    </Box>
  );
}

export function WeeklySnapshotCard() {
  const { data, isLoading, isError } = useWeeklySnapshot();

  return (
    <Card sx={{ mb: 2 }}>
      <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
        <Typography
          variant="overline"
          sx={{ color: 'text.secondary', display: 'block', mb: 1.5 }}
        >
          This Week vs Last Week
        </Typography>

        {isLoading && (
          <Box sx={{ display: 'flex', justifyContent: 'center', py: 3 }}>
            <CircularProgress size={24} />
          </Box>
        )}

        {isError && (
          <Typography variant="body2" sx={{ color: 'error.main', textAlign: 'center', py: 2 }}>
            Failed to load weekly stats
          </Typography>
        )}

        {data && (
          <Box
            sx={{
              display: 'grid',
              gridTemplateColumns: 'repeat(3, 1fr)',
              gap: 1,
            }}
          >
            <MetricCell
              label="Sets"
              value={data.thisWeek.sets}
              delta={data.deltas.sets}
            />
            <MetricCell
              label="Volume"
              value={
                data.thisWeek.volume >= 1000
                  ? `${(data.thisWeek.volume / 1000).toFixed(1)}k`
                  : Math.round(data.thisWeek.volume).toString()
              }
              delta={data.deltas.volume}
            />
            <MetricCell
              label="Days"
              value={data.thisWeek.trainingDays}
              delta={data.deltas.trainingDays}
            />
          </Box>
        )}

        {data && (
          <Typography variant="caption" sx={{ color: 'text.disabled', display: 'block', textAlign: 'center', mt: 1 }}>
            Last week: {data.lastWeek.sets} sets · {
              data.lastWeek.volume >= 1000
                ? `${(data.lastWeek.volume / 1000).toFixed(1)}k`
                : Math.round(data.lastWeek.volume)
            } vol · {data.lastWeek.trainingDays} days
          </Typography>
        )}
      </CardContent>
    </Card>
  );
}
