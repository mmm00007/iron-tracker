import { useState, useMemo, useRef } from 'react';
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import IconButton from '@mui/material/IconButton';
import List from '@mui/material/List';
import Skeleton from '@mui/material/Skeleton';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import CameraAltIcon from '@mui/icons-material/CameraAlt';
import FitnessCenterIcon from '@mui/icons-material/FitnessCenter';
import { useNavigate } from '@tanstack/react-router';
import {
  useExercises,
  useExerciseSearch,
  useRecentExercises,
  useMuscleGroups,
} from '@/hooks/useExercises';
import { useDebounce } from '@/hooks/useDebounce';
import { ExerciseCard } from '@/components/exercises/ExerciseCard';
import { ExerciseListItem } from '@/components/exercises/ExerciseListItem';
import { ExerciseSearch } from '@/components/exercises/ExerciseSearch';
import { MuscleGroupSection } from '@/components/exercises/MuscleGroupSection';

function LoadingSkeleton() {
  return (
    <Box sx={{ px: 2, pb: 2 }}>
      {/* Recent section skeleton */}
      <Skeleton variant="text" width={80} height={20} sx={{ mb: 1, mt: 2 }} />
      <Box sx={{ display: 'flex', gap: 1.5, overflowX: 'hidden' }}>
        {[1, 2, 3, 4].map((i) => (
          <Skeleton
            key={i}
            variant="rectangular"
            width={120}
            height={80}
            sx={{ borderRadius: '16px', flexShrink: 0 }}
          />
        ))}
      </Box>

      {/* By muscle section skeleton */}
      <Skeleton variant="text" width={120} height={20} sx={{ mb: 1, mt: 3 }} />
      {[1, 2, 3].map((i) => (
        <Skeleton
          key={i}
          variant="rectangular"
          height={52}
          sx={{ borderRadius: '12px', mb: 0.5 }}
        />
      ))}

      {/* All exercises skeleton */}
      <Skeleton variant="text" width={100} height={20} sx={{ mb: 1, mt: 3 }} />
      {[1, 2, 3, 4, 5].map((i) => (
        <Skeleton
          key={i}
          variant="rectangular"
          height={56}
          sx={{ borderRadius: '12px', mb: 0.5 }}
        />
      ))}
    </Box>
  );
}

function EmptyState({ onSearchFocus }: { onSearchFocus: () => void }) {
  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        px: 3,
        py: 6,
        textAlign: 'center',
        gap: 2,
      }}
    >
      <Box
        sx={{
          width: 80,
          height: 80,
          borderRadius: '50%',
          backgroundColor: 'rgba(168, 199, 250, 0.08)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          mb: 1,
        }}
      >
        <FitnessCenterIcon sx={{ fontSize: 40, color: 'text.secondary' }} />
      </Box>

      <Typography variant="h6" sx={{ color: 'text.primary', fontWeight: 600 }}>
        Start your first workout
      </Typography>

      <Typography
        variant="body2"
        sx={{ color: 'text.secondary', maxWidth: 260, lineHeight: 1.5 }}
      >
        Your exercises will appear here as you start logging. Browse all available exercises to
        get started.
      </Typography>

      <Button
        variant="contained"
        onClick={onSearchFocus}
        sx={{ mt: 1 }}
      >
        Search Exercises
      </Button>
    </Box>
  );
}

function NoSearchResults({ query }: { query: string }) {
  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        py: 6,
        px: 3,
        textAlign: 'center',
        gap: 1.5,
      }}
    >
      <Typography variant="body1" sx={{ color: 'text.secondary' }}>
        No exercises found for <strong style={{ color: '#E6E1E5' }}>"{query}"</strong>
      </Typography>
    </Box>
  );
}

export function ExerciseListPage() {
  const navigate = useNavigate();
  const searchRef = useRef<HTMLInputElement>(null);
  const [searchInput, setSearchInput] = useState('');
  const debouncedSearch = useDebounce(searchInput, 200);
  const isSearching = debouncedSearch.trim().length > 0;

  const exercisesQuery = useExercises();
  const recentQuery = useRecentExercises();
  const muscleGroupsQuery = useMuscleGroups();
  const searchQuery = useExerciseSearch(debouncedSearch);

  const isLoading =
    exercisesQuery.isLoading || recentQuery.isLoading || muscleGroupsQuery.isLoading;

  // Build a lookup map from recentQuery data: exercise ID → formatted last logged label
  const lastLoggedMap = useMemo(() => {
    const map = new Map<string, string>();
    for (const exercise of recentQuery.data ?? []) {
      if (exercise.lastLoggedAt) {
        const date = new Date(exercise.lastLoggedAt);
        const label = date.toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
        map.set(exercise.id, `Last logged ${label}`);
      }
    }
    return map;
  }, [recentQuery.data]);

  // Group exercises by muscle group
  // Since we don't have per-exercise muscle group in the base exercise, we group by category
  const exercisesByCategory = useMemo(() => {
    const exercises = exercisesQuery.data ?? [];
    const map = new Map<string, typeof exercises>();

    for (const exercise of exercises) {
      const category = exercise.category ?? 'Other';
      const existing = map.get(category) ?? [];
      existing.push(exercise);
      map.set(category, existing);
    }

    // Sort each group alphabetically
    map.forEach((list) => list.sort((a, b) => a.name.localeCompare(b.name)));

    return map;
  }, [exercisesQuery.data]);

  const hasRecentExercises = (recentQuery.data?.length ?? 0) > 0;
  const hasAnyExercises = (exercisesQuery.data?.length ?? 0) > 0;

  const isFirstTimeUser = !isLoading && !hasAnyExercises && !hasRecentExercises;

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
            Log
          </Typography>
          <IconButton
            aria-label="Identify machine with camera"
            size="medium"
            onClick={() => void navigate({ to: '/log/identify' })}
            sx={{
              color: 'text.secondary',
              '&:hover': { color: 'primary.main' },
            }}
          >
            <CameraAltIcon fontSize="small" />
          </IconButton>
        </Toolbar>
      </AppBar>

      {/* Search Bar */}
      <Box sx={{ px: 2, pt: 2, pb: 1 }}>
        <ExerciseSearch value={searchInput} onChange={setSearchInput} inputRef={searchRef} />
      </Box>

      {/* Content */}
      {isLoading ? (
        <LoadingSkeleton />
      ) : isFirstTimeUser ? (
        <EmptyState onSearchFocus={() => searchRef.current?.focus()} />
      ) : isSearching ? (
        /* Search Results */
        <Box sx={{ px: 1 }}>
          {searchQuery.isLoading ? (
            <Box sx={{ px: 1 }}>
              {[1, 2, 3].map((i) => (
                <Skeleton
                  key={i}
                  variant="rectangular"
                  height={56}
                  sx={{ borderRadius: '12px', mb: 0.5, mx: 1 }}
                />
              ))}
            </Box>
          ) : (searchQuery.data?.length ?? 0) === 0 ? (
            <NoSearchResults query={debouncedSearch} />
          ) : (
            <List dense disablePadding>
              {searchQuery.data?.map((exercise) => (
                <ExerciseListItem
                  key={exercise.id}
                  exercise={{
                    ...exercise,
                    name: exercise.name,
                  }}
                  lastLoggedInfo={lastLoggedMap.get(exercise.id)}
                />
              ))}
            </List>
          )}
        </Box>
      ) : (
        /* Default sections */
        <Box>
          {/* Recent section */}
          {hasRecentExercises && (
            <Box sx={{ mb: 1 }}>
              <Typography
                variant="overline"
                sx={{
                  px: 2,
                  pt: 1,
                  pb: 0.75,
                  display: 'block',
                  color: 'text.secondary',
                  letterSpacing: '0.08em',
                  fontSize: '0.7rem',
                }}
              >
                Recent
              </Typography>
              <Box
                sx={{
                  display: 'flex',
                  gap: 1.5,
                  px: 2,
                  pb: 1.5,
                  overflowX: 'auto',
                  scrollbarWidth: 'none',
                  '&::-webkit-scrollbar': { display: 'none' },
                }}
              >
                {recentQuery.data?.slice(0, 8).map((exercise) => (
                  <ExerciseCard key={exercise.id} exercise={exercise} />
                ))}
              </Box>
            </Box>
          )}

          {/* By Category (Muscle Group Sections) */}
          {exercisesByCategory.size > 0 && (
            <Box sx={{ mb: 1 }}>
              <Typography
                variant="overline"
                sx={{
                  px: 2,
                  pt: 1,
                  pb: 0.75,
                  display: 'block',
                  color: 'text.secondary',
                  letterSpacing: '0.08em',
                  fontSize: '0.7rem',
                }}
              >
                By Category
              </Typography>
              <Box sx={{ borderTop: '1px solid rgba(202, 196, 208, 0.08)' }}>
                {muscleGroupsQuery.data && muscleGroupsQuery.data.length > 0
                  ? muscleGroupsQuery.data.map((muscleGroup) => {
                      const groupExercises = exercisesByCategory.get(muscleGroup.name) ?? [];
                      if (groupExercises.length === 0) return null;
                      return (
                        <MuscleGroupSection
                          key={muscleGroup.id}
                          muscleGroup={muscleGroup}
                          exercises={groupExercises}
                        />
                      );
                    })
                  : Array.from(exercisesByCategory.entries()).map(([category, exercises]) => (
                      <MuscleGroupSection
                        key={category}
                        muscleGroup={{
                          id: category.charCodeAt(0),
                          name: category,
                          name_latin: null,
                          is_front: false,
                          svg_path_id: null,
                        }}
                        exercises={exercises}
                      />
                    ))}
              </Box>
            </Box>
          )}

          {/* All Exercises alphabetical list */}
          {hasAnyExercises && (
            <Box sx={{ mb: 2 }}>
              <Typography
                variant="overline"
                sx={{
                  px: 2,
                  pt: 1,
                  pb: 0.75,
                  display: 'block',
                  color: 'text.secondary',
                  letterSpacing: '0.08em',
                  fontSize: '0.7rem',
                }}
              >
                All Exercises
              </Typography>
              <Box sx={{ px: 1 }}>
                <List dense disablePadding>
                  {exercisesQuery.data?.map((exercise) => (
                    <ExerciseListItem
                      key={exercise.id}
                      exercise={exercise}
                      lastLoggedInfo={lastLoggedMap.get(exercise.id)}
                    />
                  ))}
                </List>
              </Box>
            </Box>
          )}
        </Box>
      )}
    </Box>
  );
}
