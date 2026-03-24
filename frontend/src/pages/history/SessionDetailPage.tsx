import { useMemo } from 'react';
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Divider from '@mui/material/Divider';
import IconButton from '@mui/material/IconButton';
import Paper from '@mui/material/Paper';
import Skeleton from '@mui/material/Skeleton';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import { useNavigate, useParams } from '@tanstack/react-router';
import { useSessionSets } from '@/hooks/useSessions';
import { SetRow } from '@/components/log/SetRow';
import { groupSetsIntoSessions } from '@/utils/sessionGrouping';
import {
  formatRelativeDate,
  formatDuration,
  formatVolume,
} from '@/utils/formatters';
import type { WorkoutSet } from '@/types/database';

interface ExerciseBlock {
  exerciseId: string;
  exerciseName: string;
  sets: WorkoutSet[];
  volume: number;
}

function buildExerciseBlocks(
  sets: (WorkoutSet & { exerciseName?: string })[],
): ExerciseBlock[] {
  const order: string[] = [];
  const map = new Map<
    string,
    { exerciseName: string; sets: WorkoutSet[]; volume: number }
  >();

  for (const set of sets) {
    if (!map.has(set.exercise_id)) {
      order.push(set.exercise_id);
      map.set(set.exercise_id, {
        exerciseName: set.exerciseName ?? set.exercise_id,
        sets: [],
        volume: 0,
      });
    }
    const block = map.get(set.exercise_id)!;
    block.sets.push(set);
    block.volume += set.weight * set.reps;
  }

  return order.map((id) => ({ exerciseId: id, ...map.get(id)! }));
}

function SummaryCard({
  duration,
  totalSets,
  totalVolume,
  exerciseCount,
}: {
  duration: string;
  totalSets: number;
  totalVolume: number;
  exerciseCount: number;
}) {
  const stats = [
    { label: 'Duration', value: duration },
    { label: 'Sets', value: String(totalSets) },
    { label: 'Exercises', value: String(exerciseCount) },
    { label: 'Volume', value: formatVolume(totalVolume) },
  ];

  return (
    <Card
      sx={{
        mx: 2,
        mt: 2,
        mb: 2.5,
        borderRadius: '16px',
        backgroundColor: 'rgba(168, 199, 250, 0.06)',
        border: '1px solid rgba(168, 199, 250, 0.12)',
      }}
    >
      <CardContent sx={{ py: 1.75, px: 2, '&:last-child': { pb: 1.75 } }}>
        <Box
          sx={{
            display: 'grid',
            gridTemplateColumns: 'repeat(4, 1fr)',
            gap: 1,
            textAlign: 'center',
          }}
        >
          {stats.map(({ label, value }) => (
            <Box key={label}>
              <Typography
                variant="subtitle1"
                sx={{ fontWeight: 700, color: 'primary.main', lineHeight: 1.2 }}
              >
                {value}
              </Typography>
              <Typography variant="caption" sx={{ color: 'text.secondary', display: 'block' }}>
                {label}
              </Typography>
            </Box>
          ))}
        </Box>
      </CardContent>
    </Card>
  );
}

function LoadingSkeleton() {
  return (
    <Box sx={{ px: 2, pt: 2 }}>
      <Skeleton variant="rectangular" height={80} sx={{ borderRadius: '16px', mb: 2.5 }} />
      {[1, 2].map((i) => (
        <Box key={i} sx={{ mb: 2.5 }}>
          <Skeleton variant="text" width={140} height={24} sx={{ mb: 1 }} />
          {[1, 2, 3].map((j) => (
            <Skeleton
              key={j}
              variant="rectangular"
              height={48}
              sx={{ borderRadius: '8px', mb: 0.5 }}
            />
          ))}
        </Box>
      ))}
    </Box>
  );
}

/** Noop delete handler — history view is read-only */
function noop() {}

export function SessionDetailPage() {
  const navigate = useNavigate();
  const { sessionId } = useParams({ strict: false });

  // sessionId is the startedAt timestamp (URL-encoded)
  const startedAt = decodeURIComponent(sessionId);

  // We need the endedAt to bound the query. Derive it by fetching 1 session's sets first,
  // then the hook re-runs with the proper range. We approximate endedAt as startedAt + 3h
  // for the initial fetch so we capture the full session even before we know it.
  const approximateEndedAt = useMemo(() => {
    const d = new Date(startedAt);
    d.setHours(d.getHours() + 3);
    return d.toISOString();
  }, [startedAt]);

  const setsQuery = useSessionSets(startedAt, approximateEndedAt);
  const sets = setsQuery.data ?? [];

  // Group the fetched sets into sessions to get the precise endedAt
  const sessionGroup = useMemo(() => {
    if (sets.length === 0) return null;
    const groups = groupSetsIntoSessions(sets);
    return groups.length > 0 ? groups[0] : null;
  }, [sets]);

  const exerciseBlocks = useMemo(() => buildExerciseBlocks(sets), [sets]);

  const handleBack = () => {
    void navigate({ to: '/history' });
  };

  const dateLabel = formatRelativeDate(startedAt);
  const duration =
    sessionGroup ? formatDuration(sessionGroup.startedAt, sessionGroup.endedAt) : '—';

  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'column',
        minHeight: '100%',
        backgroundColor: 'background.default',
      }}
    >
      {/* Top App Bar */}
      <AppBar
        position="sticky"
        elevation={0}
        sx={{
          backgroundColor: '#1A1A2E',
          borderBottom: '1px solid rgba(202, 196, 208, 0.08)',
        }}
      >
        <Toolbar sx={{ px: 1, minHeight: '56px !important' }}>
          <IconButton
            edge="start"
            onClick={handleBack}
            aria-label="Go back"
            sx={{ color: 'text.secondary', mr: 0.5 }}
          >
            <ArrowBackIcon />
          </IconButton>
          <Typography
            variant="h6"
            sx={{ flex: 1, fontWeight: 700, letterSpacing: '-0.01em', color: 'text.primary' }}
          >
            {dateLabel}
          </Typography>
        </Toolbar>
      </AppBar>

      {setsQuery.isLoading ? (
        <LoadingSkeleton />
      ) : (
        <>
          {/* Summary card */}
          <SummaryCard
            duration={duration}
            totalSets={sets.length}
            totalVolume={sessionGroup?.totalVolume ?? 0}
            exerciseCount={exerciseBlocks.length}
          />

          {/* Exercise blocks */}
          <Box sx={{ px: 2, pb: 3 }}>
            {exerciseBlocks.map((block) => (
              <Box key={block.exerciseId} sx={{ mb: 3 }}>
                {/* Exercise header */}
                <Box
                  sx={{
                    display: 'flex',
                    alignItems: 'baseline',
                    justifyContent: 'space-between',
                    mb: 1,
                  }}
                >
                  <Typography
                    variant="subtitle2"
                    sx={{ color: 'text.primary', fontWeight: 600 }}
                  >
                    {block.exerciseName}
                  </Typography>
                  <Typography variant="caption" sx={{ color: 'text.secondary' }}>
                    {formatVolume(block.volume)}
                  </Typography>
                </Box>

                {/* Sets */}
                <Paper
                  elevation={0}
                  sx={{
                    borderRadius: '12px',
                    backgroundColor: '#1E1E1E',
                    border: '1px solid rgba(202, 196, 208, 0.08)',
                    overflow: 'hidden',
                  }}
                >
                  {block.sets.map((set, idx) => (
                    <Box key={set.id}>
                      <SetRow
                        set={set}
                        setNumber={idx + 1}
                        onDelete={noop}
                        isPR={false}
                      />
                      {idx < block.sets.length - 1 && (
                        <Divider sx={{ borderColor: 'rgba(202, 196, 208, 0.04)', mx: 2 }} />
                      )}
                    </Box>
                  ))}
                </Paper>
              </Box>
            ))}
          </Box>
        </>
      )}
    </Box>
  );
}
