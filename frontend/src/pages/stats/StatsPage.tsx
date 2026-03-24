import AppBar from '@mui/material/AppBar';
import Toolbar from '@mui/material/Toolbar';
import {
  Box,
  Typography,
  Card,
  CardContent,
  Chip,
  Stack,
  Skeleton,
  List,
  ListItemButton,
  ListItemText,
  ListItemIcon,
  Button,
} from '@mui/material';
import { EmojiEvents, TrendingUp, TrendingDown, FitnessCenter, BarChart as BarChartIcon, AutoAwesome, MilitaryTech } from '@mui/icons-material';
import { useNavigate, useSearch } from '@tanstack/react-router';
import { statsRoute } from '@/router';
import { WeeklySnapshotCard } from '@/components/stats/WeeklySnapshotCard';
import { TrainingCalendar } from '@/components/stats/TrainingCalendar';
import { MuscleDistributionChart } from '@/components/stats/MuscleDistributionChart';
import { DeloadBanner } from '@/components/stats/DeloadBanner';
import {
  useRecentPRs,
  useTrainingFrequency,
  useMuscleDistribution,
  useTopExercises,
} from '@/hooks/useAnalytics';
import { useProfile } from '@/hooks/useProfile';
import { formatRelativeDate, formatVolume } from '@/utils/formatters';

type Period = 'week' | 'month' | '3months' | 'all';

const PERIOD_LABELS: Record<Period, string> = {
  week: 'This Week',
  month: 'This Month',
  '3months': '3 Months',
  all: 'All Time',
};

const VALID_PERIODS = new Set<Period>(['week', 'month', '3months', 'all']);

export function StatsPage() {
  const navigate = useNavigate();
  const { period: periodParam } = useSearch({ from: statsRoute.id });
  const period: Period =
    periodParam !== undefined && VALID_PERIODS.has(periodParam as Period)
      ? (periodParam as Period)
      : 'month';

  function setPeriod(p: Period) {
    navigate({ to: '/stats', search: { period: p }, replace: true });
  }

  const { data: recentPRs, isLoading: prsLoading } = useRecentPRs(period);
  const { isLoading: freqLoading } = useTrainingFrequency(period);
  const { data: muscleData, isLoading: muscleLoading } = useMuscleDistribution(period);
  const { data: topExercises, isLoading: topLoading } = useTopExercises(5, period);
  const { data: profile } = useProfile();
  const weightUnit = profile?.preferred_weight_unit ?? 'kg';

  const isAllLoading = prsLoading || freqLoading || muscleLoading || topLoading;

  return (
    <Box sx={{ pb: { xs: 10, md: 2 } }}>
      <AppBar position="static" elevation={0} color="transparent">
        <Toolbar>
          <Typography variant="h6" fontWeight={700} sx={{ flexGrow: 1 }}>
            Stats
          </Typography>
        </Toolbar>
      </AppBar>

      {/* Quick links */}
      <Box sx={{ px: 2, pb: 1, display: 'flex', gap: 1 }}>
        <Button
          variant="outlined"
          size="small"
          startIcon={<AutoAwesome />}
          onClick={() => navigate({ to: '/analysis' })}
          sx={{ borderRadius: '20px' }}
        >
          AI Analysis
        </Button>
        <Button
          variant="outlined"
          size="small"
          startIcon={<MilitaryTech />}
          onClick={() => navigate({ to: '/stats/prs' })}
          sx={{ borderRadius: '20px' }}
        >
          PR Board
        </Button>
      </Box>

      {/* Period filter chips */}
      <Stack direction="row" spacing={1} sx={{ px: 2, pb: 2, overflowX: 'auto' }}>
        {(Object.keys(PERIOD_LABELS) as Period[]).map((p) => (
          <Chip
            key={p}
            label={PERIOD_LABELS[p]}
            onClick={() => setPeriod(p)}
            color={period === p ? 'primary' : 'default'}
            variant={period === p ? 'filled' : 'outlined'}
          />
        ))}
      </Stack>

      {/* Full-page skeleton — shown until ALL queries have resolved */}
      {isAllLoading ? (
        <Box sx={{ px: 2 }}>
          <Stack spacing={2}>
            <Skeleton variant="rounded" height={120} />
            <Skeleton variant="rounded" height={160} />
            <Skeleton variant="rounded" height={200} />
            <Skeleton variant="rounded" height={240} />
            <Skeleton variant="rounded" height={200} />
          </Stack>
        </Box>
      ) : (
        /* Unified empty state — shown only when all data sources are empty */
        (!recentPRs || recentPRs.length === 0) &&
        (!topExercises || topExercises.length === 0) ? (
          <Box sx={{ textAlign: 'center', py: 8, px: 3 }}>
            <BarChartIcon sx={{ fontSize: 64, color: 'text.disabled', mb: 2 }} />
            <Typography variant="h6" gutterBottom>
              Your stats will appear here
            </Typography>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
              Log your first workout to see weekly summaries, personal records, and training trends.
            </Typography>
            <Button variant="contained" onClick={() => navigate({ to: '/log' })}>
              Start Logging
            </Button>
          </Box>
        ) : (
          <Box sx={{ px: 2 }}>
            <DeloadBanner />

            <Box
              sx={{
                display: 'grid',
                gridTemplateColumns: { xs: '1fr', md: 'repeat(2, 1fr)' },
                gap: 2,
              }}
            >
              {/* Card 1: Weekly Snapshot — full width */}
              <Box sx={{ gridColumn: { md: '1 / -1' } }}>
                <WeeklySnapshotCard />
              </Box>

              {/* Card 2: Recent PRs — full width */}
              <Card sx={{ gridColumn: { md: '1 / -1' } }}>
                <CardContent>
                  <Typography variant="subtitle1" fontWeight={600} gutterBottom>
                    Recent PRs
                  </Typography>
                  {recentPRs && recentPRs.length > 0 ? (
                    <Stack direction="row" spacing={1.5} sx={{ overflowX: 'auto', pb: 0.5 }}>
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
                            <EmojiEvents sx={{ color: '#FFD700', fontSize: 20, mb: 0.5 }} />
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
                    </Stack>
                  ) : (
                    <Typography variant="body2" color="text.secondary" sx={{ py: 2, textAlign: 'center' }}>
                      No PRs yet. Keep pushing!
                    </Typography>
                  )}
                </CardContent>
              </Card>

              {/* Card 3: Training Calendar — full width */}
              <Box sx={{ gridColumn: { md: '1 / -1' } }}>
                <TrainingCalendar />
              </Box>

              {/* Card 4: Muscle Distribution */}
              <Card>
                <CardContent>
                  <Typography variant="subtitle1" fontWeight={600} gutterBottom>
                    Muscle Distribution
                  </Typography>
                  {muscleData && muscleData.length > 0 ? (
                    <MuscleDistributionChart data={muscleData} />
                  ) : (
                    <Typography variant="body2" color="text.secondary" sx={{ py: 2, textAlign: 'center' }}>
                      No data for this period
                    </Typography>
                  )}
                </CardContent>
              </Card>

              {/* Card 5: Top Exercises */}
              <Card>
                <CardContent>
                  <Typography variant="subtitle1" fontWeight={600} gutterBottom>
                    Top Exercises
                  </Typography>
                  {topExercises && topExercises.length > 0 ? (
                    <List disablePadding>
                      {topExercises.map((ex, idx) => (
                        <ListItemButton
                          key={ex.exerciseId}
                          onClick={() =>
                            navigate({ to: '/stats/$exerciseId', params: { exerciseId: ex.exerciseId } })
                          }
                          sx={{ borderRadius: 1, mb: 0.5 }}
                        >
                          <ListItemIcon sx={{ minWidth: 36 }}>
                            <Typography variant="body2" fontWeight={700} color="primary">
                              #{idx + 1}
                            </Typography>
                          </ListItemIcon>
                          <ListItemText
                            primary={ex.exerciseName}
                            secondary={formatVolume(ex.totalVolume)}
                          />
                          {ex.trend === 'up' ? (
                            <TrendingUp sx={{ color: 'success.main', fontSize: 20 }} />
                          ) : ex.trend === 'down' ? (
                            <TrendingDown sx={{ color: 'error.main', fontSize: 20 }} />
                          ) : (
                            <FitnessCenter sx={{ color: 'text.disabled', fontSize: 20 }} />
                          )}
                        </ListItemButton>
                      ))}
                    </List>
                  ) : (
                    <Typography variant="body2" color="text.secondary" sx={{ py: 2, textAlign: 'center' }}>
                      Start logging to see your top exercises
                    </Typography>
                  )}
                </CardContent>
              </Card>
            </Box>
          </Box>
        )
      )}
    </Box>
  );
}
