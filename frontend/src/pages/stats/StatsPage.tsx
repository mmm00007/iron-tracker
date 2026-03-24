import { useState } from 'react';
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
} from '@mui/material';
import { EmojiEvents, TrendingUp, TrendingDown, FitnessCenter } from '@mui/icons-material';
import { useNavigate } from '@tanstack/react-router';
import { WeeklySnapshotCard } from '@/components/stats/WeeklySnapshotCard';
import { TrainingCalendar } from '@/components/stats/TrainingCalendar';
import { MuscleDistributionChart } from '@/components/stats/MuscleDistributionChart';
import {
  useWeeklySnapshot,
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

export function StatsPage() {
  const [period, setPeriod] = useState<Period>('month');
  const navigate = useNavigate();

  const { data: snapshot, isLoading: snapshotLoading } = useWeeklySnapshot();
  const { data: recentPRs, isLoading: prsLoading } = useRecentPRs();
  const { data: frequency, isLoading: freqLoading } = useTrainingFrequency();
  const { data: muscleData, isLoading: muscleLoading } = useMuscleDistribution(period);
  const { data: topExercises, isLoading: topLoading } = useTopExercises(5);
  const { data: profile } = useProfile();
  const weightUnit = profile?.preferred_weight_unit ?? 'kg';

  return (
    <Box sx={{ pb: 10 }}>
      {/* TopAppBar */}
      <Box sx={{ px: 2, pt: 2, pb: 1 }}>
        <Typography variant="h5" fontWeight={700}>
          Stats
        </Typography>
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

      <Stack spacing={2} sx={{ px: 2 }}>
        {/* Card 1: Weekly Snapshot */}
        {snapshotLoading ? (
          <Skeleton variant="rounded" height={120} />
        ) : snapshot ? (
          <WeeklySnapshotCard />
        ) : null}

        {/* Card 2: Recent PRs */}
        <Card>
          <CardContent>
            <Typography variant="subtitle1" fontWeight={600} gutterBottom>
              Recent PRs
            </Typography>
            {prsLoading ? (
              <Stack direction="row" spacing={1}>
                {[1, 2, 3].map((i) => (
                  <Skeleton key={i} variant="rounded" width={140} height={80} />
                ))}
              </Stack>
            ) : recentPRs && recentPRs.length > 0 ? (
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

        {/* Card 3: Training Calendar */}
        <Card>
          <CardContent>
            <Typography variant="subtitle1" fontWeight={600} gutterBottom>
              Training Frequency
            </Typography>
            {freqLoading ? (
              <Skeleton variant="rounded" height={160} />
            ) : frequency ? (
              <TrainingCalendar />
            ) : (
              <Typography variant="body2" color="text.secondary" sx={{ py: 2, textAlign: 'center' }}>
                Log some workouts to see your training calendar
              </Typography>
            )}
          </CardContent>
        </Card>

        {/* Card 4: Muscle Distribution */}
        <Card>
          <CardContent>
            <Typography variant="subtitle1" fontWeight={600} gutterBottom>
              Muscle Distribution
            </Typography>
            {muscleLoading ? (
              <Skeleton variant="rounded" height={200} />
            ) : muscleData && muscleData.length > 0 ? (
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
            {topLoading ? (
              <Stack spacing={1}>
                {[1, 2, 3].map((i) => (
                  <Skeleton key={i} variant="rounded" height={48} />
                ))}
              </Stack>
            ) : topExercises && topExercises.length > 0 ? (
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
      </Stack>
    </Box>
  );
}
