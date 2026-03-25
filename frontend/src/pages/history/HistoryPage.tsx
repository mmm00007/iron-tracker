import { useState, useEffect, useRef, useMemo } from 'react';
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import CircularProgress from '@mui/material/CircularProgress';
import Skeleton from '@mui/material/Skeleton';
import TextField from '@mui/material/TextField';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import InputAdornment from '@mui/material/InputAdornment';
import IconButton from '@mui/material/IconButton';
import Chip from '@mui/material/Chip';
import Stack from '@mui/material/Stack';
import HistoryIcon from '@mui/icons-material/History';
import SearchIcon from '@mui/icons-material/Search';
import ClearIcon from '@mui/icons-material/Clear';

type DateFilter = 'all' | 'week' | 'month' | '3months';
const DATE_FILTER_LABELS: Record<DateFilter, string> = {
  all: 'All',
  week: 'This Week',
  month: 'This Month',
  '3months': '3 Months',
};
import { useSessions } from '@/hooks/useSessions';
import { SessionCard } from '@/components/history/SessionCard';
import { useAllSessionNames } from '@/hooks/useSessionNames';
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
  const [searchQuery, setSearchQuery] = useState('');
  const [dateFilter, setDateFilter] = useState<DateFilter>('all');

  const sessionsQuery = useSessions(page);
  const { data: sessionNames } = useAllSessionNames();

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
  const isLoadingMore = sessionsQuery.isLoading && page > 0;

  // Filter sessions by exercise name search and date range
  const filteredSessions = useMemo(() => {
    let result = allSessions;

    // Date filter
    if (dateFilter !== 'all') {
      const cutoff = new Date();
      if (dateFilter === 'week') cutoff.setDate(cutoff.getDate() - 7);
      else if (dateFilter === 'month') cutoff.setMonth(cutoff.getMonth() - 1);
      else if (dateFilter === '3months') cutoff.setMonth(cutoff.getMonth() - 3);
      result = result.filter((s) => new Date(s.startedAt) >= cutoff);
    }

    // Exercise name search
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase();
      result = result.filter((session) =>
        session.exercises.some((ex) => ex.exerciseName.toLowerCase().includes(q))
      );
    }

    return result;
  }, [allSessions, searchQuery, dateFilter]);

  const isEmpty = !isInitialLoading && allSessions.length === 0;

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
            component="h1"
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

      {/* Search bar */}
      {!isEmpty && !isInitialLoading && (
        <Box sx={{ px: 2, pt: 1.5, pb: 0.5 }}>
          <TextField
            size="small"
            fullWidth
            placeholder="Search by exercise name..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            slotProps={{
              input: {
                startAdornment: (
                  <InputAdornment position="start">
                    <SearchIcon sx={{ fontSize: 20, color: 'text.secondary' }} />
                  </InputAdornment>
                ),
                endAdornment: searchQuery ? (
                  <InputAdornment position="end">
                    <IconButton size="small" onClick={() => setSearchQuery('')}>
                      <ClearIcon sx={{ fontSize: 18 }} />
                    </IconButton>
                  </InputAdornment>
                ) : null,
              },
            }}
          />
          <Stack direction="row" spacing={0.75} sx={{ mt: 1, overflowX: 'auto' }}>
            {(Object.keys(DATE_FILTER_LABELS) as DateFilter[]).map((f) => (
              <Chip
                key={f}
                label={DATE_FILTER_LABELS[f]}
                size="small"
                onClick={() => setDateFilter(f)}
                color={dateFilter === f ? 'primary' : 'default'}
                variant={dateFilter === f ? 'filled' : 'outlined'}
                sx={{ fontSize: '0.75rem', flexShrink: 0 }}
              />
            ))}
          </Stack>
        </Box>
      )}

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
        <Box sx={{ px: 2, pt: 1.5, pb: { xs: 2, md: 2 } }}>
          <Box
            sx={{
              display: 'grid',
              gridTemplateColumns: { xs: '1fr', md: 'repeat(2, 1fr)' },
              gap: { xs: 1.5, md: 2 },
            }}
          >
            {filteredSessions.map((session) => (
              <SessionCard
                key={session.id}
                session={session}
                customName={sessionNames?.get(session.startedAt)}
              />
            ))}
          </Box>

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
