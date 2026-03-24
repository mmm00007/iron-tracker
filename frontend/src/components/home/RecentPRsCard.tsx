import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Skeleton from '@mui/material/Skeleton';
import Typography from '@mui/material/Typography';
import EmojiEventsIcon from '@mui/icons-material/EmojiEvents';
import { useRecentPRs } from '@/hooks/useAnalytics';
import { useProfile } from '@/hooks/useProfile';
import { formatRelativeDate } from '@/utils/formatters';

export function RecentPRsCard() {
  const { data: recentPRs, isLoading } = useRecentPRs();
  const { data: profile } = useProfile();
  const weightUnit = profile?.preferred_weight_unit ?? 'kg';

  if (isLoading) {
    return <Skeleton variant="rounded" height={100} sx={{ borderRadius: '16px' }} />;
  }

  if (!recentPRs || recentPRs.length === 0) {
    return null;
  }

  return (
    <Card>
      <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
        <Typography variant="subtitle1" fontWeight={600} gutterBottom>
          Recent PRs
        </Typography>
        <Box
          sx={{
            display: 'flex',
            gap: 1.5,
            overflowX: 'auto',
            pb: 0.5,
            scrollbarWidth: 'none',
            '&::-webkit-scrollbar': { display: 'none' },
          }}
        >
          {recentPRs.map((pr) => (
            <Card
              key={pr.id}
              sx={{
                minWidth: 140,
                bgcolor: 'rgba(255, 215, 0, 0.05)',
                border: '1px solid rgba(255, 215, 0, 0.2)',
                flexShrink: 0,
              }}
            >
              <CardContent sx={{ p: 1.5, '&:last-child': { pb: 1.5 } }}>
                <EmojiEventsIcon sx={{ color: '#FFD700', fontSize: 20, mb: 0.5 }} />
                <Typography variant="body2" fontWeight={600} noWrap>
                  {pr.exerciseName || 'Exercise'}
                </Typography>
                <Typography variant="caption" color="text.secondary">
                  {pr.recordType.replace('_', ' ')}
                </Typography>
                <Typography variant="body2" fontWeight={700} sx={{ color: '#FFD700' }}>
                  {pr.value} {weightUnit}
                </Typography>
                <Typography variant="caption" color="text.secondary">
                  {formatRelativeDate(pr.achievedAt)}
                </Typography>
              </CardContent>
            </Card>
          ))}
        </Box>
      </CardContent>
    </Card>
  );
}
