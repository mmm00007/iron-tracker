import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Skeleton from '@mui/material/Skeleton';
import Typography from '@mui/material/Typography';
import EmojiEventsIcon from '@mui/icons-material/EmojiEvents';
import { useRecentPRs } from '@/hooks/useAnalytics';
import { useProfile } from '@/hooks/useProfile';
import { formatRelativeDate } from '@/utils/formatters';
import { DATA_FONT } from '@/theme';

export function RecentPRsCard() {
  const { data: recentPRs, isLoading } = useRecentPRs();
  const { data: profile } = useProfile();
  const weightUnit = profile?.preferred_weight_unit ?? 'kg';

  if (isLoading) {
    return <Skeleton variant="rounded" height={120} sx={{ borderRadius: '16px' }} />;
  }

  if (!recentPRs || recentPRs.length === 0) {
    return null;
  }

  return (
    <Card>
      <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1.5 }}>
          <Box
            sx={{
              width: 32,
              height: 32,
              borderRadius: '8px',
              background: 'linear-gradient(135deg, rgba(255, 215, 0, 0.15), rgba(255, 152, 0, 0.10))',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              flexShrink: 0,
            }}
          >
            <EmojiEventsIcon sx={{ color: '#FFD700', fontSize: 18 }} />
          </Box>
          <Typography variant="subtitle1" fontWeight={600}>
            Recent PRs
          </Typography>
        </Box>
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
            <Box
              key={pr.id}
              sx={{
                minWidth: 130,
                flexShrink: 0,
                p: 1.5,
                borderRadius: '12px',
                background: 'linear-gradient(135deg, rgba(255, 215, 0, 0.10), rgba(255, 152, 0, 0.05))',
                border: '1px solid rgba(255, 215, 0, 0.25)',
              }}
            >
              <Typography variant="body2" fontWeight={600} noWrap sx={{ mb: 0.25 }}>
                {pr.exerciseName || 'Exercise'}
              </Typography>
              <Typography variant="caption" sx={{ color: 'text.secondary', display: 'block', mb: 0.5 }}>
                {pr.recordType.replace('_', ' ')}
              </Typography>
              <Typography
                sx={{
                  fontFamily: DATA_FONT,
                  fontSize: '1.125rem',
                  fontWeight: 800,
                  color: '#FFD700',
                  lineHeight: 1,
                  mb: 0.5,
                }}
              >
                {pr.value} {weightUnit}
              </Typography>
              <Typography variant="caption" sx={{ color: 'text.disabled', fontSize: '0.6875rem' }}>
                {formatRelativeDate(pr.achievedAt)}
              </Typography>
            </Box>
          ))}
        </Box>
      </CardContent>
    </Card>
  );
}
