import { useState, useMemo, useRef, useCallback } from 'react';
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Chip from '@mui/material/Chip';
import IconButton from '@mui/material/IconButton';
import List from '@mui/material/List';
import Skeleton from '@mui/material/Skeleton';
import Stack from '@mui/material/Stack';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import CameraAltIcon from '@mui/icons-material/CameraAlt';
import FitnessCenterIcon from '@mui/icons-material/FitnessCenter';
import StarIcon from '@mui/icons-material/Star';
import { useNavigate } from '@tanstack/react-router';
import { useFavoriteIds } from '@/hooks/useFavorites';

const EQUIPMENT_TYPES = ['barbell', 'dumbbell', 'cable', 'machine', 'body only', 'bands', 'kettlebell'] as const;

const EXERCISE_TYPE_FILTERS = [
  { value: 'push', label: 'Push' },
  { value: 'pull', label: 'Pull' },
  { value: 'legs', label: 'Legs' },
  { value: 'core', label: 'Core' },
  { value: 'cardio', label: 'Cardio' },
  { value: 'full_body', label: 'Full Body' },
] as const;
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
import { AlphabetScrubber } from '@/components/exercises/AlphabetScrubber';

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
        No exercises found for <strong>"{query}"</strong>
      </Typography>
    </Box>
  );
}

export function ExerciseListPage() {
  const navigate = useNavigate();
  const searchRef = useRef<HTMLInputElement>(null);
  const [searchInput, setSearchInput] = useState('');
  const [equipmentFilter, setEquipmentFilter] = useState<string | null>(null);
  const [muscleFilter, setMuscleFilter] = useState<number | null>(null);
  const [categoryFilter, setCategoryFilter] = useState<string | null>(null);
  const [showFavoritesOnly, setShowFavoritesOnly] = useState(false);
  const favoriteIds = useFavoriteIds();
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

  // Group exercises by primary muscle group via exercise_muscles junction table
  const exercisesByMuscleGroup = useMemo(() => {
    const exercises = exercisesQuery.data ?? [];
    const mgLookup = new Map((muscleGroupsQuery.data ?? []).map((mg) => [mg.id, mg.name]));
    const map = new Map<string, typeof exercises>();

    for (const exercise of exercises) {
      // Find primary muscle groups for this exercise
      const primaryMuscleIds = exercise.exercise_muscles
        ?.filter(() => true) // all linked muscles (is_primary not in the select)
        ?.map((em) => em.muscle_group_id) ?? [];

      if (primaryMuscleIds.length === 0) {
        // Fallback to category for exercises without muscle associations
        const fallback = exercise.category ?? 'Other';
        const existing = map.get(fallback) ?? [];
        existing.push(exercise);
        map.set(fallback, existing);
      } else {
        // Add to each linked muscle group (exercise may appear in multiple groups)
        for (const mgId of primaryMuscleIds) {
          const groupName = mgLookup.get(mgId) ?? 'Other';
          const existing = map.get(groupName) ?? [];
          existing.push(exercise);
          map.set(groupName, existing);
        }
      }
    }

    // Sort each group alphabetically and deduplicate
    map.forEach((list, key) => {
      const seen = new Set<string>();
      const deduped = list.filter((e) => {
        if (seen.has(e.id)) return false;
        seen.add(e.id);
        return true;
      });
      deduped.sort((a, b) => a.name.localeCompare(b.name));
      map.set(key, deduped);
    });

    return map;
  }, [exercisesQuery.data, muscleGroupsQuery.data]);

  // Filter exercises by equipment type, muscle group (via junction table), and favorites
  const filteredExercises = useMemo(() => {
    let list = exercisesQuery.data ?? [];
    if (showFavoritesOnly) {
      list = list.filter((e) => favoriteIds.has(e.id));
    }
    if (equipmentFilter) {
      list = list.filter((e) => e.equipment?.toLowerCase() === equipmentFilter);
    }
    if (muscleFilter !== null) {
      list = list.filter((e) =>
        e.exercise_muscles?.some((em) => em.muscle_group_id === muscleFilter)
      );
    }
    if (categoryFilter) {
      list = list.filter((e) => e.exercise_type === categoryFilter);
    }
    return list;
  }, [exercisesQuery.data, equipmentFilter, muscleFilter, categoryFilter, showFavoritesOnly, favoriteIds]);

  const isFiltering = equipmentFilter !== null || muscleFilter !== null || categoryFilter !== null || showFavoritesOnly;
  const clearAllFilters = () => { setEquipmentFilter(null); setMuscleFilter(null); setCategoryFilter(null); setShowFavoritesOnly(false); };

  const hasRecentExercises = (recentQuery.data?.length ?? 0) > 0;
  const hasAnyExercises = (exercisesQuery.data?.length ?? 0) > 0;

  const isFirstTimeUser = !isLoading && !hasAnyExercises && !hasRecentExercises;

  // Compute active letters for the alphabet scrubber
  const activeLetters = useMemo(() => {
    const letters = new Set<string>();
    for (const exercise of exercisesQuery.data ?? []) {
      const first = exercise.name[0]?.toUpperCase();
      if (first && first >= 'A' && first <= 'Z') letters.add(first);
    }
    return letters;
  }, [exercisesQuery.data]);

  const handleLetterSelect = useCallback((letter: string) => {
    // Find the first exercise starting with this letter and scroll to it
    const el = document.getElementById(`exercise-letter-${letter}`);
    if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }, []);

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
      <Box sx={{ px: 2, pt: 2, pb: 0.5 }}>
        <ExerciseSearch value={searchInput} onChange={setSearchInput} inputRef={searchRef} />
      </Box>

      {/* Filter chips: equipment type */}
      {!isLoading && hasAnyExercises && (
        <Box sx={{ px: 2, pb: 0.5 }}>
          <Stack direction="row" spacing={0.5} sx={{ overflowX: 'auto', scrollbarWidth: 'none', '&::-webkit-scrollbar': { display: 'none' }, pb: 0.5 }}>
            <Chip
              icon={<StarIcon sx={{ fontSize: '14px !important', color: showFavoritesOnly ? '#FFD700' : undefined }} />}
              label={`Favorites${favoriteIds.size > 0 ? ` (${favoriteIds.size})` : ''}`}
              size="small"
              onClick={() => setShowFavoritesOnly(!showFavoritesOnly)}
              color={showFavoritesOnly ? 'warning' : 'default'}
              variant={showFavoritesOnly ? 'filled' : 'outlined'}
              sx={{ fontSize: '0.7rem', height: 26, flexShrink: 0 }}
            />
            {EQUIPMENT_TYPES.map((type) => (
              <Chip
                key={type}
                label={type === 'body only' ? 'Bodyweight' : type.charAt(0).toUpperCase() + type.slice(1)}
                size="small"
                onClick={() => setEquipmentFilter(equipmentFilter === type ? null : type)}
                color={equipmentFilter === type ? 'primary' : 'default'}
                variant={equipmentFilter === type ? 'filled' : 'outlined'}
                sx={{ fontSize: '0.7rem', height: 26, flexShrink: 0 }}
              />
            ))}
          </Stack>

          {/* Category filter chips (Push/Pull/Legs/Core) */}
          <Stack direction="row" spacing={0.5} sx={{ overflowX: 'auto', scrollbarWidth: 'none', '&::-webkit-scrollbar': { display: 'none' }, mt: 0.5 }}>
            {EXERCISE_TYPE_FILTERS.map(({ value, label }) => (
              <Chip
                key={value}
                label={label}
                size="small"
                onClick={() => setCategoryFilter(categoryFilter === value ? null : value)}
                color={categoryFilter === value ? 'info' : 'default'}
                variant={categoryFilter === value ? 'filled' : 'outlined'}
                sx={{ fontSize: '0.7rem', height: 26, flexShrink: 0 }}
              />
            ))}
          </Stack>

          {/* Muscle group filter chips */}
          <Stack direction="row" spacing={0.5} sx={{ overflowX: 'auto', scrollbarWidth: 'none', '&::-webkit-scrollbar': { display: 'none' }, mt: 0.5 }}>
            {(muscleGroupsQuery.data ?? []).slice(0, 12).map((mg) => (
              <Chip
                key={mg.id}
                label={mg.name}
                size="small"
                onClick={() => setMuscleFilter(muscleFilter === mg.id ? null : mg.id)}
                color={muscleFilter === mg.id ? 'secondary' : 'default'}
                variant={muscleFilter === mg.id ? 'filled' : 'outlined'}
                sx={{ fontSize: '0.65rem', height: 24, flexShrink: 0 }}
              />
            ))}
          </Stack>
        </Box>
      )}

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
      ) : isFiltering ? (
        /* Filtered results */
        <Box sx={{ px: 1 }}>
          {filteredExercises.length === 0 ? (
            <Box sx={{ textAlign: 'center', py: 4 }}>
              <Typography variant="body2" sx={{ color: 'text.secondary' }}>
                No exercises match the selected filters
              </Typography>
              <Button size="small" onClick={clearAllFilters} sx={{ mt: 1 }}>
                Clear Filters
              </Button>
            </Box>
          ) : (
            <Box
              sx={{
                display: 'grid',
                gridTemplateColumns: { xs: '1fr', md: 'repeat(2, 1fr)', lg: 'repeat(3, 1fr)' },
                gap: { xs: 0, md: 0.5 },
              }}
            >
              {filteredExercises.map((exercise) => (
                <ExerciseListItem
                  key={exercise.id}
                  exercise={exercise}
                  lastLoggedInfo={lastLoggedMap.get(exercise.id)}
                />
              ))}
            </Box>
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

          {/* By Muscle Group (via exercise_muscles junction) */}
          {exercisesByMuscleGroup.size > 0 && (
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
                By Muscle Group
              </Typography>
              <Box sx={{ borderTop: '1px solid rgba(202, 196, 208, 0.08)' }}>
                {muscleGroupsQuery.data && muscleGroupsQuery.data.length > 0
                  ? muscleGroupsQuery.data.map((muscleGroup) => {
                      const groupExercises = exercisesByMuscleGroup.get(muscleGroup.name) ?? [];
                      if (groupExercises.length === 0) return null;
                      return (
                        <MuscleGroupSection
                          key={muscleGroup.id}
                          muscleGroup={muscleGroup}
                          exercises={groupExercises}
                        />
                      );
                    })
                  : Array.from(exercisesByMuscleGroup.entries()).map(([groupName, exercises]) => (
                      <MuscleGroupSection
                        key={groupName}
                        muscleGroup={{
                          id: groupName.charCodeAt(0),
                          name: groupName,
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
              <Box
                sx={{
                  px: 1,
                  pr: { xs: 3, md: 1 }, // extra right padding for scrubber on mobile
                  display: 'grid',
                  gridTemplateColumns: { xs: '1fr', md: 'repeat(2, 1fr)', lg: 'repeat(3, 1fr)' },
                  gap: { xs: 0, md: 0.5 },
                }}
              >
                {exercisesQuery.data?.map((exercise, idx) => {
                  const letter = exercise.name[0]?.toUpperCase() ?? '';
                  const prevLetter = idx > 0 ? exercisesQuery.data?.[idx - 1]?.name[0]?.toUpperCase() : '';
                  const isFirstOfLetter = letter !== prevLetter;
                  return (
                    <Box key={exercise.id} id={isFirstOfLetter ? `exercise-letter-${letter}` : undefined}>
                      <ExerciseListItem
                        exercise={exercise}
                        lastLoggedInfo={lastLoggedMap.get(exercise.id)}
                      />
                    </Box>
                  );
                })}
              </Box>
              <AlphabetScrubber
                onLetterSelect={handleLetterSelect}
                activeLetters={activeLetters}
              />
            </Box>
          )}
        </Box>
      )}
    </Box>
  );
}
