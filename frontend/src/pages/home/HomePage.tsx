import Box from '@mui/material/Box';
import Stack from '@mui/material/Stack';
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
import { TrainingCalendar } from '@/components/stats/TrainingCalendar';

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

          {/* Two-column grid on tablet/desktop */}
          <Box
            sx={{
              display: 'grid',
              gridTemplateColumns: { xs: '1fr', md: 'repeat(2, 1fr)' },
              gap: 2,
            }}
          >
            {/* Weekly snapshot — full width */}
            <Box sx={{ gridColumn: { md: '1 / -1' } }}>
              <WeeklySnapshotCard />
            </Box>

            {/* Streak + Volume trend side by side on tablet/desktop */}
            <TrainingStreakCard />
            <VolumeTrendCard />

            {/* Muscle donut */}
            <HomeMuscleDonut />

            {/* Exercise Progress — full width */}
            <Box sx={{ gridColumn: { md: '1 / -1' } }}>
              <ExerciseProgressCard />
            </Box>

            {/* Training Calendar — full width */}
            <Box sx={{ gridColumn: { md: '1 / -1' } }}>
              <TrainingCalendar />
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
