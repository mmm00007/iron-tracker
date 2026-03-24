import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Skeleton from '@mui/material/Skeleton';
import Stack from '@mui/material/Stack';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import EmojiEventsIcon from '@mui/icons-material/EmojiEvents';
import { useRecentPRs } from '@/hooks/useAnalytics';
import { useProfile } from '@/hooks/useProfile';
import { formatRelativeDate } from '@/utils/formatters';

export function PRBoardPage() {
  const { data: prs, isLoading } = useRecentPRs();
  const { data: profile } = useProfile();
  const unit = profile?.preferred_weight_unit ?? 'kg';

  // Group PRs by exercise
  const grouped = new Map<string, typeof prs>();
  for (const pr of prs ?? []) {
    const key = pr.exerciseName;
    if (!grouped.has(key)) grouped.set(key, []);
    grouped.get(key)!.push(pr);
  }

  return (
    <Box sx={{ pb: { xs: 10, md: 2 } }}>
      <AppBar position="static" elevation={0} color="transparent">
        <Toolbar sx={{ px: 2, minHeight: '56px !important' }}>
          <Typography variant="h6" fontWeight={700} sx={{ flexGrow: 1 }}>
            Personal Records
          </Typography>
        </Toolbar>
      </AppBar>

      {isLoading ? (
        <Box sx={{ px: 2 }}>
          <Stack spacing={2}>
            <Skeleton variant="rounded" height={100} />
            <Skeleton variant="rounded" height={100} />
          </Stack>
        </Box>
      ) : !prs || prs.length === 0 ? (
        <Box sx={{ textAlign: 'center', py: 8, px: 3 }}>
          <EmojiEventsIcon sx={{ fontSize: 64, color: 'text.disabled', mb: 2 }} />
          <Typography variant="h6" gutterBottom>No PRs yet</Typography>
          <Typography variant="body2" color="text.secondary">
            Keep training — your personal records will appear here.
          </Typography>
        </Box>
      ) : (
        <Box sx={{ px: 2, display: 'grid', gridTemplateColumns: { xs: '1fr', md: 'repeat(2, 1fr)' }, gap: 2 }}>
          {[...grouped.entries()].map(([name, exercisePrs]) => (
            <Card key={name}>
              <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
                  <EmojiEventsIcon sx={{ color: '#FFD700', fontSize: 20 }} />
                  <Typography variant="subtitle1" fontWeight={700}>{name}</Typography>
                </Box>
                {exercisePrs!.map((pr) => (
                  <Box key={pr.id} sx={{ display: 'flex', justifyContent: 'space-between', py: 0.5 }}>
                    <Typography variant="body2" sx={{ color: 'text.secondary' }}>
                      {pr.recordType.replace('_', ' ')}
                    </Typography>
                    <Box sx={{ textAlign: 'right' }}>
                      <Typography variant="body2" fontWeight={600} sx={{ color: '#FFD700' }}>
                        {pr.value} {unit}
                      </Typography>
                      <Typography variant="caption" color="text.disabled">
                        {formatRelativeDate(pr.achievedAt)}
                      </Typography>
                    </Box>
                  </Box>
                ))}
              </CardContent>
            </Card>
          ))}
        </Box>
      )}
    </Box>
  );
}
