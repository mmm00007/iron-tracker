import { useState, useMemo } from 'react';
import AppBar from '@mui/material/AppBar';
import Avatar from '@mui/material/Avatar';
import Box from '@mui/material/Box';
import Chip from '@mui/material/Chip';
import IconButton from '@mui/material/IconButton';
import InputAdornment from '@mui/material/InputAdornment';
import List from '@mui/material/List';
import ListItemAvatar from '@mui/material/ListItemAvatar';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemText from '@mui/material/ListItemText';
import Skeleton from '@mui/material/Skeleton';
import Stack from '@mui/material/Stack';
import TextField from '@mui/material/TextField';
import ToggleButton from '@mui/material/ToggleButton';
import ToggleButtonGroup from '@mui/material/ToggleButtonGroup';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import SearchIcon from '@mui/icons-material/Search';
import StarIcon from '@mui/icons-material/Star';
import StarBorderIcon from '@mui/icons-material/StarBorder';
import FitnessCenterIcon from '@mui/icons-material/FitnessCenter';
import MenuBookIcon from '@mui/icons-material/MenuBook';
import { useNavigate } from '@tanstack/react-router';
import { useExercises, useMuscleGroups } from '@/hooks/useExercises';
import { useFavoriteIds, useToggleFavorite } from '@/hooks/useFavorites';
import type { Exercise } from '@/types/database';

const EQUIPMENT_TYPES = ['all', 'barbell', 'dumbbell', 'cable', 'machine', 'body only', 'bands', 'kettlebell'] as const;

function getEquipmentLabel(type: string): string {
  if (type === 'all') return 'All';
  if (type === 'body only') return 'Bodyweight';
  return type.charAt(0).toUpperCase() + type.slice(1);
}

export function LibraryPage() {
  const navigate = useNavigate();
  const { data: exercises, isLoading } = useExercises();
  const { data: muscleGroups } = useMuscleGroups();
  const favoriteIds = useFavoriteIds();
  const toggleFavorite = useToggleFavorite();

  const [search, setSearch] = useState('');
  const [equipmentFilter, setEquipmentFilter] = useState<string>('all');
  const [muscleFilter, setMuscleFilter] = useState<string | null>(null);
  const [viewMode, setViewMode] = useState<'all' | 'favorites'>('all');

  const filtered = useMemo(() => {
    let list = exercises ?? [];

    if (viewMode === 'favorites') {
      list = list.filter((e) => favoriteIds.has(e.id));
    }

    if (search.trim()) {
      const q = search.toLowerCase();
      list = list.filter((e) =>
        e.name.toLowerCase().includes(q) ||
        e.equipment?.toLowerCase().includes(q) ||
        e.category?.toLowerCase().includes(q)
      );
    }

    if (equipmentFilter !== 'all') {
      list = list.filter((e) => e.equipment?.toLowerCase() === equipmentFilter);
    }

    if (muscleFilter) {
      list = list.filter((e) => e.category === muscleFilter);
    }

    return list;
  }, [exercises, search, equipmentFilter, muscleFilter, viewMode, favoriteIds]);

  const handleToggleFavorite = (e: React.MouseEvent, exercise: Exercise) => {
    e.stopPropagation();
    void toggleFavorite.mutateAsync({
      exerciseId: exercise.id,
      isFavorite: favoriteIds.has(exercise.id),
    });
  };

  return (
    <Box sx={{ pb: { xs: 10, md: 2 } }}>
      <AppBar position="static" elevation={0} color="transparent">
        <Toolbar sx={{ px: 2, minHeight: '56px !important' }}>
          <MenuBookIcon sx={{ mr: 1, color: 'text.secondary' }} />
          <Typography variant="h6" fontWeight={700} sx={{ flexGrow: 1 }}>
            Exercise Library
          </Typography>
          <Typography variant="caption" sx={{ color: 'text.disabled' }}>
            {filtered.length} exercises
          </Typography>
        </Toolbar>
      </AppBar>

      <Box sx={{ px: 2 }}>
        {/* Search */}
        <TextField
          size="small"
          fullWidth
          placeholder="Search exercises, equipment, muscles..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          slotProps={{
            input: {
              startAdornment: (
                <InputAdornment position="start">
                  <SearchIcon sx={{ fontSize: 20, color: 'text.secondary' }} />
                </InputAdornment>
              ),
            },
          }}
          sx={{ mb: 1 }}
        />

        {/* All / Favorites toggle */}
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
          <ToggleButtonGroup
            value={viewMode}
            exclusive
            onChange={(_, v) => { if (v) setViewMode(v); }}
            size="small"
          >
            <ToggleButton value="all" sx={{ px: 2, py: 0.25, fontSize: '0.75rem' }}>All</ToggleButton>
            <ToggleButton value="favorites" sx={{ px: 2, py: 0.25, fontSize: '0.75rem' }}>
              <StarIcon sx={{ fontSize: 14, mr: 0.5, color: '#FFD700' }} />
              Favorites
            </ToggleButton>
          </ToggleButtonGroup>
        </Box>

        {/* Equipment type chips */}
        <Stack direction="row" spacing={0.5} sx={{ overflowX: 'auto', scrollbarWidth: 'none', '&::-webkit-scrollbar': { display: 'none' }, mb: 0.5 }}>
          {EQUIPMENT_TYPES.map((type) => (
            <Chip
              key={type}
              label={getEquipmentLabel(type)}
              size="small"
              onClick={() => setEquipmentFilter(type)}
              color={equipmentFilter === type ? 'primary' : 'default'}
              variant={equipmentFilter === type ? 'filled' : 'outlined'}
              sx={{ fontSize: '0.7rem', height: 26, flexShrink: 0 }}
            />
          ))}
        </Stack>

        {/* Muscle group chips */}
        <Stack direction="row" spacing={0.5} sx={{ overflowX: 'auto', scrollbarWidth: 'none', '&::-webkit-scrollbar': { display: 'none' }, mt: 0.5, mb: 1 }}>
          {(muscleGroups ?? []).slice(0, 12).map((mg) => (
            <Chip
              key={mg.id}
              label={mg.name}
              size="small"
              onClick={() => setMuscleFilter(muscleFilter === mg.name ? null : mg.name)}
              color={muscleFilter === mg.name ? 'secondary' : 'default'}
              variant={muscleFilter === mg.name ? 'filled' : 'outlined'}
              sx={{ fontSize: '0.65rem', height: 24, flexShrink: 0 }}
            />
          ))}
        </Stack>
      </Box>

      {/* Exercise list */}
      {isLoading ? (
        <Box sx={{ px: 2 }}>
          {[1, 2, 3, 4, 5].map((i) => (
            <Skeleton key={i} variant="rectangular" height={64} sx={{ borderRadius: '12px', mb: 0.5 }} />
          ))}
        </Box>
      ) : (
        <List dense sx={{ px: 1 }}>
          {filtered.map((exercise) => {
            const isFav = favoriteIds.has(exercise.id);
            const thumbUrl = exercise.image_urls?.[0];

            return (
              <ListItemButton
                key={exercise.id}
                onClick={() => void navigate({ to: '/log/$exerciseId', params: { exerciseId: exercise.id } })}
                sx={{ borderRadius: '12px', mb: 0.25 }}
              >
                <ListItemAvatar sx={{ minWidth: 48 }}>
                  {thumbUrl ? (
                    <Avatar src={thumbUrl} variant="rounded" sx={{ width: 40, height: 40 }} />
                  ) : (
                    <Avatar variant="rounded" sx={{ width: 40, height: 40, bgcolor: 'rgba(168, 199, 250, 0.08)' }}>
                      <FitnessCenterIcon sx={{ fontSize: 20, color: 'text.disabled' }} />
                    </Avatar>
                  )}
                </ListItemAvatar>
                <ListItemText
                  primary={exercise.name}
                  secondary={
                    [exercise.equipment, exercise.category, exercise.level]
                      .filter(Boolean)
                      .join(' · ')
                  }
                  primaryTypographyProps={{ variant: 'body2', fontWeight: 500 }}
                  secondaryTypographyProps={{ variant: 'caption', sx: { color: 'text.disabled' } }}
                />
                <IconButton
                  size="small"
                  onClick={(e) => handleToggleFavorite(e, exercise)}
                  sx={{ color: isFav ? '#FFD700' : 'text.disabled' }}
                >
                  {isFav ? <StarIcon fontSize="small" /> : <StarBorderIcon fontSize="small" />}
                </IconButton>
              </ListItemButton>
            );
          })}
        </List>
      )}
    </Box>
  );
}
