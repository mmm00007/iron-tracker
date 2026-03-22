import { useState } from 'react';
import {
  Box,
  Typography,
  IconButton,
  Tabs,
  Tab,
  Card,
  CardContent,
  Chip,
  Stack,
  Skeleton,
  List,
  ListItem,
  ListItemText,
} from '@mui/material';
import { ArrowBack } from '@mui/icons-material';
import { useNavigate, useParams } from '@tanstack/react-router';
import { E1RMChart } from '@/components/stats/E1RMChart';
import { VolumeChart } from '@/components/stats/VolumeChart';
import { PRTable } from '@/components/stats/PRTable';
import {
  useE1RMTrend,
  useExerciseVolumeTrend,
  useExercisePRs,
  useExerciseHistory,
} from '@/hooks/useAnalytics';
import { useVariants } from '@/hooks/useVariants';
import { formatRelativeDate, formatWeightReps } from '@/utils/formatters';

export function ExerciseStatsPage() {
  const { exerciseId } = useParams({ from: '/stats/$exerciseId' as any });
  const navigate = useNavigate();
  const [tab, setTab] = useState(0);
  const [selectedVariant, setSelectedVariant] = useState<string | null>(null);

  const { data: variants } = useVariants(exerciseId);
  const { data: e1rmData, isLoading: e1rmLoading } = useE1RMTrend(exerciseId, selectedVariant);
  const { data: volumeData, isLoading: volumeLoading } = useExerciseVolumeTrend(exerciseId);
  const { data: prRecords, isLoading: prsLoading } = useExercisePRs(exerciseId);
  const { data: history, isLoading: historyLoading } = useExerciseHistory(
    exerciseId,
    selectedVariant,
  );

  const exerciseName =
    history && history.length > 0 ? (history[0] as any).exercise_name || 'Exercise' : 'Exercise';

  return (
    <Box sx={{ pb: 10 }}>
      {/* TopAppBar */}
      <Box
        sx={{
          display: 'flex',
          alignItems: 'center',
          px: 1,
          pt: 1,
          pb: 0.5,
        }}
      >
        <IconButton onClick={() => navigate({ to: '/stats' })}>
          <ArrowBack />
        </IconButton>
        <Typography variant="h6" fontWeight={600} sx={{ flex: 1, textAlign: 'center', mr: 5 }}>
          {exerciseName}
        </Typography>
      </Box>

      {/* Variant filter chips */}
      {variants && variants.length > 1 && (
        <Stack direction="row" spacing={1} sx={{ px: 2, pb: 1, overflowX: 'auto' }}>
          <Chip
            label="All Variants"
            onClick={() => setSelectedVariant(null)}
            color={selectedVariant === null ? 'primary' : 'default'}
            variant={selectedVariant === null ? 'filled' : 'outlined'}
          />
          {variants.map((v) => (
            <Chip
              key={v.id}
              label={v.name}
              onClick={() => setSelectedVariant(v.id)}
              color={selectedVariant === v.id ? 'primary' : 'default'}
              variant={selectedVariant === v.id ? 'filled' : 'outlined'}
            />
          ))}
        </Stack>
      )}

      {/* Tabs */}
      <Tabs value={tab} onChange={(_, v) => setTab(v)} variant="fullWidth" sx={{ mb: 2 }}>
        <Tab label="Strength" />
        <Tab label="Volume" />
        <Tab label="History" />
      </Tabs>

      <Box sx={{ px: 2 }}>
        {/* Strength Tab */}
        {tab === 0 && (
          <Stack spacing={2}>
            <Card>
              <CardContent>
                <Typography variant="subtitle1" fontWeight={600} gutterBottom>
                  Estimated 1RM Trend
                </Typography>
                {e1rmLoading ? (
                  <Skeleton variant="rounded" height={250} />
                ) : e1rmData && e1rmData.length > 0 ? (
                  <E1RMChart data={e1rmData} />
                ) : (
                  <Typography
                    variant="body2"
                    color="text.secondary"
                    sx={{ py: 4, textAlign: 'center' }}
                  >
                    Log some sets to see your 1RM trend
                  </Typography>
                )}
              </CardContent>
            </Card>

            <Card>
              <CardContent>
                <Typography variant="subtitle1" fontWeight={600} gutterBottom>
                  Personal Records
                </Typography>
                {prsLoading ? (
                  <Skeleton variant="rounded" height={200} />
                ) : prRecords && prRecords.length > 0 ? (
                  <PRTable records={prRecords} />
                ) : (
                  <Typography
                    variant="body2"
                    color="text.secondary"
                    sx={{ py: 4, textAlign: 'center' }}
                  >
                    No records yet
                  </Typography>
                )}
              </CardContent>
            </Card>
          </Stack>
        )}

        {/* Volume Tab */}
        {tab === 1 && (
          <Card>
            <CardContent>
              <Typography variant="subtitle1" fontWeight={600} gutterBottom>
                Weekly Volume
              </Typography>
              {volumeLoading ? (
                <Skeleton variant="rounded" height={250} />
              ) : volumeData && volumeData.length > 0 ? (
                <VolumeChart data={volumeData} />
              ) : (
                <Typography
                  variant="body2"
                  color="text.secondary"
                  sx={{ py: 4, textAlign: 'center' }}
                >
                  Log some sets to see your volume trend
                </Typography>
              )}
            </CardContent>
          </Card>
        )}

        {/* History Tab */}
        {tab === 2 && (
          <Card>
            <CardContent sx={{ p: 0 }}>
              <Typography variant="subtitle1" fontWeight={600} sx={{ p: 2, pb: 1 }}>
                All Sets
              </Typography>
              {historyLoading ? (
                <Stack spacing={1} sx={{ p: 2 }}>
                  {[1, 2, 3, 4, 5].map((i) => (
                    <Skeleton key={i} variant="rounded" height={40} />
                  ))}
                </Stack>
              ) : history && history.length > 0 ? (
                <List disablePadding>
                  {history.map((set) => (
                    <ListItem key={set.id} divider sx={{ py: 1 }}>
                      <ListItemText
                        primary={formatWeightReps(set.weight, set.reps, set.weight_unit)}
                        secondary={formatRelativeDate(set.logged_at)}
                      />
                      <Stack direction="row" spacing={0.5} alignItems="center">
                        {set.rpe && (
                          <Chip label={`RPE ${set.rpe}`} size="small" variant="outlined" />
                        )}
                        {set.set_type !== 'working' && (
                          <Chip label={set.set_type} size="small" variant="outlined" />
                        )}
                      </Stack>
                    </ListItem>
                  ))}
                </List>
              ) : (
                <Typography
                  variant="body2"
                  color="text.secondary"
                  sx={{ py: 4, textAlign: 'center' }}
                >
                  No sets logged yet
                </Typography>
              )}
            </CardContent>
          </Card>
        )}
      </Box>
    </Box>
  );
}
