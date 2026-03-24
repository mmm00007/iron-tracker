import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Skeleton from '@mui/material/Skeleton';
import Typography from '@mui/material/Typography';
import ShowChartIcon from '@mui/icons-material/ShowChart';
import { useVolumeTrendSpark } from '@/hooks/useAnalytics';
import { Sparkline } from '@/components/common/Sparkline';

export function VolumeTrendCard() {
  const { data, isLoading } = useVolumeTrendSpark();

  if (isLoading) {
    return <Skeleton variant="rounded" height={80} sx={{ borderRadius: '16px' }} />;
  }

  if (!data || data.length < 2) {
    return null;
  }

  const current = data[data.length - 1] ?? 0;
  const previous = data[data.length - 2] ?? 0;
  const trend = previous > 0 ? Math.round(((current - previous) / previous) * 100) : 0;

  return (
    <Card>
      <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <Box>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.75, mb: 0.5 }}>
              <ShowChartIcon sx={{ fontSize: 18, color: 'text.secondary' }} />
              <Typography variant="caption" sx={{ color: 'text.secondary' }}>
                Weekly Volume
              </Typography>
            </Box>
            <Box sx={{ display: 'flex', alignItems: 'baseline', gap: 1 }}>
              <Typography variant="h5" sx={{ fontWeight: 700, color: 'text.primary' }}>
                {current >= 1000 ? `${(current / 1000).toFixed(1)}k` : Math.round(current)}
              </Typography>
              {trend !== 0 && (
                <Typography
                  variant="caption"
                  sx={{
                    color: trend > 0 ? 'success.main' : 'error.main',
                    fontWeight: 600,
                  }}
                >
                  {trend > 0 ? '+' : ''}{trend}%
                </Typography>
              )}
            </Box>
          </Box>
          <Sparkline data={data} color="#A8C7FA" height={40} width={100} />
        </Box>
      </CardContent>
    </Card>
  );
}
