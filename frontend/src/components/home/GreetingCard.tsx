import Box from '@mui/material/Box';
import Skeleton from '@mui/material/Skeleton';
import Typography from '@mui/material/Typography';
import { useAuthStore } from '@/stores/authStore';
import { useProfile } from '@/hooks/useProfile';

function getGreeting(): string {
  const hour = new Date().getHours();
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

function formatToday(): string {
  return new Date().toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'long',
    day: 'numeric',
  });
}

export function GreetingCard() {
  const user = useAuthStore((state) => state.user);
  const { data: profile, isLoading } = useProfile();

  const name =
    profile?.display_name ??
    user?.email?.split('@')[0] ??
    'Athlete';

  if (isLoading) {
    return (
      <Box sx={{ px: 2, pt: 2 }}>
        <Skeleton variant="text" width={200} height={32} />
        <Skeleton variant="text" width={160} height={20} />
      </Box>
    );
  }

  return (
    <Box sx={{ px: 2, pt: { xs: 2, md: 3 }, position: 'relative' }}>
      {/* Ambient glow */}
      <Box
        sx={{
          position: 'absolute',
          top: 0,
          left: '50%',
          transform: 'translateX(-50%)',
          width: '120%',
          height: '200px',
          background: 'radial-gradient(ellipse at 50% 0%, rgba(91, 234, 162, 0.06) 0%, transparent 70%)',
          pointerEvents: 'none',
        }}
      />
      <Typography
        variant="h5"
        sx={{
          fontWeight: 700,
          color: 'text.primary',
          fontSize: { xs: '1.5rem', md: '1.75rem' },
          position: 'relative',
        }}
      >
        {getGreeting()}, {name}
      </Typography>
      <Typography variant="body2" sx={{ color: 'text.secondary', mt: 0.25, position: 'relative' }}>
        {formatToday()}
      </Typography>
    </Box>
  );
}
