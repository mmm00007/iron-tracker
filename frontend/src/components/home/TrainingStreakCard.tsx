import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Skeleton from '@mui/material/Skeleton';
import Typography from '@mui/material/Typography';
import LocalFireDepartmentIcon from '@mui/icons-material/LocalFireDepartment';
import { useTrainingStreak } from '@/hooks/useAnalytics';

export function TrainingStreakCard() {
  const { data, isLoading } = useTrainingStreak();

  if (isLoading) {
    return <Skeleton variant="rounded" height={80} sx={{ borderRadius: '16px' }} />;
  }

  if (!data || (data.currentDayStreak === 0 && data.currentWeekStreak === 0)) {
    return (
      <Card>
        <CardContent sx={{ p: 2, '&:last-child': { pb: 2 }, textAlign: 'center' }}>
          <LocalFireDepartmentIcon sx={{ color: 'text.disabled', fontSize: 28, mb: 0.5 }} />
          <Typography variant="body2" sx={{ color: 'text.secondary' }}>
            Log your first workout to start a streak
          </Typography>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
          <Box
            sx={{
              width: 44,
              height: 44,
              borderRadius: '12px',
              backgroundColor: 'rgba(255, 152, 0, 0.12)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              flexShrink: 0,
            }}
          >
            <LocalFireDepartmentIcon sx={{ color: '#FF9800', fontSize: 24 }} />
          </Box>

          <Box sx={{ flex: 1, display: 'flex', gap: 3 }}>
            <Box>
              <Typography variant="h4" sx={{ fontWeight: 700, color: 'text.primary', lineHeight: 1 }}>
                {data.currentDayStreak}
              </Typography>
              <Typography variant="caption" sx={{ color: 'text.secondary' }}>
                day streak
              </Typography>
            </Box>
            <Box>
              <Typography variant="h4" sx={{ fontWeight: 700, color: 'text.primary', lineHeight: 1 }}>
                {data.currentWeekStreak}
              </Typography>
              <Typography variant="caption" sx={{ color: 'text.secondary' }}>
                week streak
              </Typography>
            </Box>
            {data.longestDayStreak > data.currentDayStreak && (
              <Box>
                <Typography variant="h4" sx={{ fontWeight: 700, color: 'text.disabled', lineHeight: 1 }}>
                  {data.longestDayStreak}
                </Typography>
                <Typography variant="caption" sx={{ color: 'text.disabled' }}>
                  best
                </Typography>
              </Box>
            )}
          </Box>
        </Box>
      </CardContent>
    </Card>
  );
}
