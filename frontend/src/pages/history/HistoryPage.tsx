import { useState, useEffect, useRef } from 'react';
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import CircularProgress from '@mui/material/CircularProgress';
import Skeleton from '@mui/material/Skeleton';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import HistoryIcon from '@mui/icons-material/History';
import { useSessions } from '@/hooks/useSessions';
import { SessionCard } from '@/components/history/SessionCard';
import type { SessionGroup } from '@/utils/sessionGrouping';

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
  const [page, setPage] = useState(0);
  const [allSessions, setAllSessions] = useState<SessionGroup[]>([]);
  const loadedPages = useRef(new Set<number>());
  const [hasMore, setHasMore] = useState(true);

  const sessionsQuery = useSessions(page);

  // Accumulate sessions across pages — each page is appended only once
  useEffect(() => {
    if (!sessionsQuery.isSuccess || !sessionsQuery.data) return;
    const sessions = sessionsQuery.data;

    if (sessions.length === 0) {
      setHasMore(false);
      return;
    }

    if (loadedPages.current.has(page)) return;
    loadedPages.current.add(page);

    if (page === 0) {
      setAllSessions(sessions);
    } else {
      setAllSessions((prev) => [...prev, ...sessions]);
    }
  }, [sessionsQuery.isSuccess, sessionsQuery.data, page]);

  const isInitialLoading = sessionsQuery.isLoading && page === 0;
  const isEmpty = !isInitialLoading && allSessions.length === 0;
  const isLoadingMore = sessionsQuery.isLoading && page > 0;

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
          backgroundColor: 'surface.container',
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
      {isInitialLoading ? (
        <LoadingSkeleton />
      ) : sessionsQuery.isError ? (
        <Box sx={{ textAlign: 'center', py: 8 }}>
          <Typography color="error" gutterBottom>Failed to load sessions</Typography>
          <Button onClick={() => sessionsQuery.refetch()}>Retry</Button>
        </Box>
      ) : isEmpty ? (
        <EmptyState />
      ) : (
        <Box sx={{ px: 2, pt: 1.5, pb: 2 }}>
          {allSessions.map((session) => (
            <SessionCard key={session.id} session={session} />
          ))}

          {hasMore && (
            <Box sx={{ display: 'flex', justifyContent: 'center', mt: 2 }}>
              <Button
                variant="outlined"
                onClick={() => setPage((p) => p + 1)}
                disabled={isLoadingMore}
                startIcon={isLoadingMore ? <CircularProgress size={16} /> : undefined}
                sx={{ borderRadius: '20px', px: 3 }}
              >
                {isLoadingMore ? 'Loading…' : 'Load More'}
              </Button>
            </Box>
          )}
        </Box>
      )}
    </Box>
  );
}
