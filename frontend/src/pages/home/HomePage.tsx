import { lazy, Suspense } from 'react';
import Box from '@mui/material/Box';
import Stack from '@mui/material/Stack';
import Skeleton from '@mui/material/Skeleton';
import { GreetingCard } from '@/components/home/GreetingCard';
import { TrainingStreakCard } from '@/components/home/TrainingStreakCard';
import { QuickActionsCard } from '@/components/home/QuickActionsCard';
import { RecentPRsCard } from '@/components/home/RecentPRsCard';
import { HomeMuscleDonut } from '@/components/home/HomeMuscleDonut';
import { VolumeTrendCard } from '@/components/home/VolumeTrendCard';
import { TodaysPlanCard } from '@/components/home/TodaysPlanCard';
import { SorenessPromptCard } from '@/components/home/SorenessPromptCard';
import { ExerciseProgressCard } from '@/components/home/ExerciseProgressCard';
import { WeeklySnapshotCard } from '@/components/stats/WeeklySnapshotCard';

// Lazy-load chart components (recharts is ~150KB)
const TrainingCalendar = lazy(() => import('@/components/stats/TrainingCalendar').then(m => ({ default: m.TrainingCalendar })));

export function HomePage() {
  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'column',
        minHeight: '100%',
        backgroundColor: 'background.default',
        pb: { xs: 10, md: 2 },
      }}
    >
      <GreetingCard />

      <Box sx={{ px: 2, pt: 2 }}>
        <Stack spacing={2}>
          {/* Soreness prompt (1-3 days after training) */}
          <SorenessPromptCard />

          {/* Today's plan suggestion */}
          <TodaysPlanCard />

          {/* Quick action buttons */}
          <QuickActionsCard />

          {/* Responsive dashboard grid */}
          <Box
            sx={{
              display: 'grid',
              gridTemplateColumns: {
                xs: '1fr',
                md: 'repeat(2, 1fr)',
                lg: '1fr 1.5fr 1fr',
              },
              gap: 2,
            }}
          >
            {/* Weekly snapshot — full width on all layouts */}
            <Box sx={{ gridColumn: { xs: '1', md: '1 / -1' } }}>
              <WeeklySnapshotCard />
            </Box>

            {/* Streak + Volume trend + Muscle donut — 3 columns on desktop */}
            <TrainingStreakCard />
            <VolumeTrendCard />
            <HomeMuscleDonut />

            {/* Exercise Progress — spans 2 columns on tablet, full on desktop */}
            <Box sx={{ gridColumn: { md: '1 / -1', lg: '1 / span 2' } }}>
              <ExerciseProgressCard />
            </Box>

            {/* Training Calendar — 1 column on desktop */}
            <Box sx={{ gridColumn: { md: '1 / -1', lg: 'auto' } }}>
              <Suspense fallback={<Skeleton variant="rectangular" height={200} />}>
                <TrainingCalendar />
              </Suspense>
            </Box>

            {/* Recent PRs — full width */}
            <Box sx={{ gridColumn: { md: '1 / -1' } }}>
              <RecentPRsCard />
            </Box>
          </Box>
        </Stack>
      </Box>
    </Box>
  );
}
