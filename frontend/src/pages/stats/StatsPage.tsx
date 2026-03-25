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
import LinearProgress from '@mui/material/LinearProgress';
import { useNavigate, useSearch } from '@tanstack/react-router';
import { statsRoute } from '@/router';
import { WeeklySnapshotCard } from '@/components/stats/WeeklySnapshotCard';
import { TrainingCalendar } from '@/components/stats/TrainingCalendar';
import { MuscleDistributionChart } from '@/components/stats/MuscleDistributionChart';
import { MuscleVolumeChart } from '@/components/stats/MuscleVolumeChart';
import { DeloadBanner } from '@/components/stats/DeloadBanner';
import {
  useRecentPRs,
  useTrainingFrequency,
  useMuscleDistribution,
  useTopExercises,
  useRPEDistribution,
  useMuscleBalance,
} from '@/hooks/useAnalytics';
import { useWeeklyMuscleVolume } from '@/hooks/useMuscleVolume';
import { RPEDistributionChart } from '@/components/stats/RPEDistributionChart';
import { MuscleBalanceRadar } from '@/components/stats/MuscleBalanceRadar';
import { useProfile } from '@/hooks/useProfile';
import { formatRelativeDate, formatVolume } from '@/utils/formatters';
import { DATA_FONT, CHART_COLORS } from '@/theme';

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
  const { data: muscleVolumeData } = useWeeklyMuscleVolume(period);
  const { data: rpeData, isLoading: rpeLoading } = useRPEDistribution(period);
  const { data: muscleBalanceData, isLoading: muscleBalanceLoading } = useMuscleBalance(period);
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

      {/* Full-page skeleton */}
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
        /* Empty state */
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
                gridTemplateColumns: { xs: '1fr', md: 'repeat(2, 1fr)', lg: 'repeat(3, 1fr)' },
                gap: 2,
              }}
            >
              {/* Weekly Snapshot — full width */}
              <Box sx={{ gridColumn: { md: '1 / -1' } }}>
                <WeeklySnapshotCard />
              </Box>

              {/* Recent PRs — full width */}
              <Card sx={{ gridColumn: { md: '1 / -1' } }}>
                <CardContent sx={{ p: 2 }}>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1.5 }}>
                    <EmojiEvents sx={{ color: '#FFD700', fontSize: 20 }} />
                    <Typography variant="subtitle1" fontWeight={600}>
                      Recent PRs
                    </Typography>
                  </Box>
                  {recentPRs && recentPRs.length > 0 ? (
                    <Stack direction="row" spacing={1.5} sx={{ overflowX: 'auto', pb: 0.5 }}>
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
                          <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mb: 0.5 }}>
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
                          <Typography variant="caption" color="text.disabled" sx={{ fontSize: '0.6875rem' }}>
                            {formatRelativeDate(pr.achievedAt)}
                          </Typography>
                        </Box>
                      ))}
                    </Stack>
                  ) : (
                    <Typography variant="body2" color="text.secondary" sx={{ py: 2, textAlign: 'center' }}>
                      No PRs yet. Keep pushing!
                    </Typography>
                  )}
                </CardContent>
              </Card>

              {/* Training Calendar — full width */}
              <Box sx={{ gridColumn: { md: '1 / -1' } }}>
                <TrainingCalendar />
              </Box>

              {/* Muscle Distribution — takes 1 column on desktop */}
              <MuscleDistributionChart
                data={muscleData ?? []}
                isLoading={muscleLoading}
              />

              {/* Weekly Volume by Muscle — spans 2 columns on desktop */}
              <Card sx={{ gridColumn: { md: '1 / -1', lg: '2 / -1' } }}>
                <CardContent>
                  <Typography variant="subtitle1" fontWeight={600} gutterBottom>
                    Weekly Volume by Muscle
                  </Typography>
                  {muscleVolumeData && muscleVolumeData.length > 0 ? (
                    <MuscleVolumeChart data={muscleVolumeData} />
                  ) : (
                    <Typography variant="body2" color="text.secondary" sx={{ py: 2, textAlign: 'center' }}>
                      No data for this period
                    </Typography>
                  )}
                </CardContent>
              </Card>

              {/* RPE Distribution */}
              {rpeData && rpeData.length > 0 && (
                <Box sx={{ gridColumn: { md: '1 / -1', lg: '1 / span 1' } }}>
                  <RPEDistributionChart data={rpeData} isLoading={rpeLoading} />
                </Box>
              )}

              {/* Muscle Balance Radar */}
              {muscleBalanceData && muscleBalanceData.length >= 3 && (
                <Box sx={{ gridColumn: { md: '1 / -1', lg: '2 / -1' } }}>
                  <MuscleBalanceRadar data={muscleBalanceData} isLoading={muscleBalanceLoading} />
                </Box>
              )}

              {/* Top Exercises */}
              <Card sx={{ gridColumn: { lg: '1 / -1' } }}>
                <CardContent>
                  <Typography variant="subtitle1" fontWeight={600} gutterBottom>
                    Top Exercises
                  </Typography>
                  {topExercises && topExercises.length > 0 ? (
                    <List disablePadding>
                      {topExercises.map((ex, idx) => {
                        const maxVol = topExercises[0]?.totalVolume ?? 1;
                        const volPct = (ex.totalVolume / maxVol) * 100;
                        const barColor = CHART_COLORS.series[idx % CHART_COLORS.series.length] ?? CHART_COLORS.primary;
                        return (
                          <ListItemButton
                            key={ex.exerciseId}
                            onClick={() =>
                              navigate({ to: '/stats/$exerciseId', params: { exerciseId: ex.exerciseId } })
                            }
                            sx={{ borderRadius: 1, mb: 0.5, flexDirection: 'column', alignItems: 'stretch' }}
                          >
                            <Box sx={{ display: 'flex', alignItems: 'center', width: '100%' }}>
                              <ListItemIcon sx={{ minWidth: 36 }}>
                                <Typography
                                  sx={{
                                    fontFamily: DATA_FONT,
                                    fontWeight: 700,
                                    color: barColor,
                                    fontSize: '0.875rem',
                                  }}
                                >
                                  #{idx + 1}
                                </Typography>
                              </ListItemIcon>
                              <ListItemText
                                primary={ex.exerciseName}
                                secondary={
                                  <Typography
                                    component="span"
                                    sx={{ fontFamily: DATA_FONT, fontSize: '0.75rem', color: 'text.secondary' }}
                                  >
                                    {ex.setCount} sets · {formatVolume(ex.totalVolume)}
                                  </Typography>
                                }
                              />
                              {ex.trend === 'up' ? (
                                <TrendingUp sx={{ color: CHART_COLORS.primary, fontSize: 20 }} />
                              ) : ex.trend === 'down' ? (
                                <TrendingDown sx={{ color: 'error.main', fontSize: 20 }} />
                              ) : (
                                <FitnessCenter sx={{ color: 'text.disabled', fontSize: 20 }} />
                              )}
                            </Box>
                            <LinearProgress
                              variant="determinate"
                              value={volPct}
                              sx={{
                                mt: 0.5,
                                ml: 4.5,
                                height: 4,
                                borderRadius: 2,
                                backgroundColor: `${barColor}15`,
                                '& .MuiLinearProgress-bar': { backgroundColor: barColor, borderRadius: 2 },
                              }}
                            />
                          </ListItemButton>
                        );
                      })}
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
