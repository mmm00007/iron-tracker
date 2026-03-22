import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Skeleton from '@mui/material/Skeleton';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import HistoryIcon from '@mui/icons-material/History';
import { useSessions } from '@/hooks/useSessions';
import { SessionCard } from '@/components/history/SessionCard';

function LoadingSkeleton() {
  return (
    <Box sx={{ px: 2, pt: 1 }}>
      {[1, 2, 3].map((i) => (
        <Skeleton
          key={i}
          variant="rectangular"
          height={160}
          sx={{ borderRadius: '16px', mb: 1.5 }}
        />
      ))}
    </Box>
  );
}

function EmptyState() {
  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        px: 3,
        py: 8,
        textAlign: 'center',
        gap: 2,
      }}
    >
      {/* Illustration placeholder */}
      <Box
        sx={{
          width: 88,
          height: 88,
          borderRadius: '50%',
          backgroundColor: 'rgba(168, 199, 250, 0.08)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          mb: 1,
        }}
      >
        <HistoryIcon sx={{ fontSize: 44, color: 'text.disabled' }} />
      </Box>

      <Typography variant="h6" sx={{ color: 'text.primary', fontWeight: 600 }}>
        No workouts yet
      </Typography>

      <Typography
        variant="body2"
        sx={{ color: 'text.secondary', maxWidth: 260, lineHeight: 1.6 }}
      >
        Start logging sets to see your history here.
      </Typography>
    </Box>
  );
}

export function HistoryPage() {
  const sessionsQuery = useSessions();

  const sessions = sessionsQuery.data ?? [];
  const isEmpty = !sessionsQuery.isLoading && sessions.length === 0;

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
        <Toolbar sx={{ px: 2, minHeight: '56px !important' }}>
          <Typography
            variant="h6"
            sx={{
              flex: 1,
              fontWeight: 700,
              letterSpacing: '-0.01em',
              color: 'text.primary',
            }}
          >
            History
          </Typography>
        </Toolbar>
      </AppBar>

      {/* Content */}
      {sessionsQuery.isLoading ? (
        <LoadingSkeleton />
      ) : isEmpty ? (
        <EmptyState />
      ) : (
        <Box sx={{ px: 2, pt: 1.5, pb: 2 }}>
          {sessions.map((session) => (
            <SessionCard key={session.id} session={session} />
          ))}
        </Box>
      )}
    </Box>
  );
}
