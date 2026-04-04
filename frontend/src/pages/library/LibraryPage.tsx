import { useState, useMemo } from 'react';
import AppBar from '@mui/material/AppBar';
import Alert from '@mui/material/Alert';
import Avatar from '@mui/material/Avatar';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Chip from '@mui/material/Chip';
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogTitle from '@mui/material/DialogTitle';
import FormControl from '@mui/material/FormControl';
import IconButton from '@mui/material/IconButton';
import InputAdornment from '@mui/material/InputAdornment';
import InputLabel from '@mui/material/InputLabel';
import List from '@mui/material/List';
import ListItemAvatar from '@mui/material/ListItemAvatar';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemText from '@mui/material/ListItemText';
import MenuItem from '@mui/material/MenuItem';
import Select from '@mui/material/Select';
import Skeleton from '@mui/material/Skeleton';
import Stack from '@mui/material/Stack';
import TextField from '@mui/material/TextField';
import ToggleButton from '@mui/material/ToggleButton';
import ToggleButtonGroup from '@mui/material/ToggleButtonGroup';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import AddIcon from '@mui/icons-material/Add';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import DeleteIcon from '@mui/icons-material/Delete';
import EditIcon from '@mui/icons-material/Edit';
import SearchIcon from '@mui/icons-material/Search';
import StarIcon from '@mui/icons-material/Star';
import StarBorderIcon from '@mui/icons-material/StarBorder';
import FitnessCenterIcon from '@mui/icons-material/FitnessCenter';
import MenuBookIcon from '@mui/icons-material/MenuBook';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { useAuthStore } from '@/stores/authStore';
import { useExercises, useMuscleGroups } from '@/hooks/useExercises';
import { useFavoriteIds, useToggleFavorite } from '@/hooks/useFavorites';
import type { Exercise } from '@/types/database';

const EQUIPMENT_TYPES = ['all', 'barbell', 'dumbbell', 'cable', 'machine', 'body only', 'bands', 'kettlebell'] as const;

const EXERCISE_TYPE_FILTERS = [
  { value: 'push', label: 'Push' },
  { value: 'pull', label: 'Pull' },
  { value: 'legs', label: 'Legs' },
  { value: 'core', label: 'Core' },
  { value: 'cardio', label: 'Cardio' },
  { value: 'full_body', label: 'Full Body' },
] as const;

function getEquipmentLabel(type: string): string {
  if (type === 'all') return 'All';
  if (type === 'body only') return 'Bodyweight';
  return type.charAt(0).toUpperCase() + type.slice(1);
}

// ─── Exercise Detail View ────────────────────────────────────────────────────

function ExerciseDetailView({
  exercise,
  onBack,
  onEdit,
  onDelete,
}: {
  exercise: Exercise;
  onBack: () => void;
  onEdit: () => void;
  onDelete: () => void;
}) {
  return (
    <Box sx={{ pb: { xs: 10, md: 2 } }}>
      <AppBar position="static" elevation={0} color="transparent">
        <Toolbar sx={{ px: 1, minHeight: '56px !important' }}>
          <IconButton onClick={onBack}><ArrowBackIcon /></IconButton>
          <Typography variant="h6" fontWeight={700} sx={{ flex: 1, ml: 1 }} noWrap>{exercise.name}</Typography>
          {exercise.is_custom && (
            <>
              <IconButton onClick={onEdit}><EditIcon /></IconButton>
              <IconButton onClick={onDelete} sx={{ color: 'error.main' }}><DeleteIcon /></IconButton>
            </>
          )}
        </Toolbar>
      </AppBar>

      <Box sx={{ px: 2 }}>
        {/* Thumbnail */}
        {exercise.image_urls?.[0] && (
          <Box
            sx={{
              width: '100%',
              height: { xs: 160, md: 240 },
              borderRadius: '16px',
              overflow: 'hidden',
              mb: 2,
              backgroundImage: `url(${exercise.image_urls[0]})`,
              backgroundSize: 'cover',
              backgroundPosition: 'center',
            }}
          />
        )}

        {/* Metadata chips */}
        <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5, mb: 2 }}>
          {exercise.exercise_type && <Chip label={exercise.exercise_type.charAt(0).toUpperCase() + exercise.exercise_type.slice(1).replace('_', ' ')} size="small" color="info" />}
          {exercise.movement_pattern && <Chip label={exercise.movement_pattern.replace(/_/g, ' ')} size="small" color="secondary" variant="outlined" />}
          {exercise.equipment && <Chip label={exercise.equipment} size="small" variant="outlined" />}
          {exercise.category && <Chip label={exercise.category} size="small" variant="outlined" />}
          {exercise.level && <Chip label={exercise.level} size="small" variant="outlined" />}
          {exercise.mechanic && <Chip label={exercise.mechanic} size="small" variant="outlined" />}
          {exercise.force && <Chip label={exercise.force} size="small" variant="outlined" />}
        </Box>

        {/* Defaults */}
        {(exercise.default_weight > 0 || exercise.default_reps > 0) && (
          <Card sx={{ mb: 2 }}>
            <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
              <Typography variant="subtitle2" fontWeight={600} gutterBottom>Defaults</Typography>
              <Typography variant="body2" color="text.secondary">
                {exercise.default_weight > 0 ? `${exercise.default_weight} kg` : ''} {exercise.default_reps > 0 ? `× ${exercise.default_reps} reps` : ''}
              </Typography>
            </CardContent>
          </Card>
        )}

        {/* Instructions */}
        {exercise.instructions && exercise.instructions.length > 0 && (
          <Card sx={{ mb: 2 }}>
            <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
              <Typography variant="subtitle2" fontWeight={600} gutterBottom>Instructions</Typography>
              <Stack spacing={0.5}>
                {exercise.instructions.map((step, i) => (
                  <Typography key={i} variant="body2" color="text.secondary">
                    {i + 1}. {step}
                  </Typography>
                ))}
              </Stack>
            </CardContent>
          </Card>
        )}

        {/* Form Tips */}
        {exercise.form_tips && exercise.form_tips.length > 0 && (
          <Card sx={{ mb: 2 }}>
            <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
              <Typography variant="subtitle2" fontWeight={600} gutterBottom>Form Tips</Typography>
              <Stack spacing={0.5}>
                {exercise.form_tips.map((tip, i) => (
                  <Typography key={i} variant="body2" color="text.secondary">
                    {tip}
                  </Typography>
                ))}
              </Stack>
            </CardContent>
          </Card>
        )}

        {/* Variations */}
        {exercise.variations && exercise.variations.length > 0 && (
          <Card sx={{ mb: 2 }}>
            <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
              <Typography variant="subtitle2" fontWeight={600} gutterBottom>Variations</Typography>
              <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5 }}>
                {exercise.variations.map((v, i) => <Chip key={i} label={v} size="small" variant="outlined" />)}
              </Box>
            </CardContent>
          </Card>
        )}

        {/* Notes */}
        {exercise.notes && (
          <Card sx={{ mb: 2 }}>
            <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
              <Typography variant="subtitle2" fontWeight={600} gutterBottom>Notes</Typography>
              <Typography variant="body2" color="text.secondary">{exercise.notes}</Typography>
            </CardContent>
          </Card>
        )}

        {/* Video */}
        {exercise.video_url && (
          <Card sx={{ mb: 2 }}>
            <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
              <Typography variant="subtitle2" fontWeight={600} gutterBottom>Video</Typography>
              <Button variant="outlined" size="small" href={exercise.video_url} target="_blank" rel="noopener">
                Watch Form Video
              </Button>
            </CardContent>
          </Card>
        )}
      </Box>
    </Box>
  );
}

// ─── Create/Edit Exercise Dialog ─────────────────────────────────────────────

interface MuscleEntry {
  muscle_group_id: number;
  is_primary: boolean;
  activation_percent: number;
}

function ExerciseFormDialog({
  open,
  onClose,
  exercise,
}: {
  open: boolean;
  onClose: () => void;
  exercise?: Exercise | null;
}) {
  const queryClient = useQueryClient();
  const user = useAuthStore((s) => s.user);
  const { data: muscleGroups } = useMuscleGroups();
  const [name, setName] = useState(exercise?.name ?? '');
  const [equipment, setEquipment] = useState(exercise?.equipment ?? '');
  const [exerciseType, setExerciseType] = useState(exercise?.exercise_type ?? '');
  const [level, setLevel] = useState(exercise?.level ?? '');
  const [notes, setNotes] = useState(exercise?.notes ?? '');
  const [muscles, setMuscles] = useState<MuscleEntry[]>([]);
  const [error, setError] = useState<string | null>(null);

  const addMuscle = (mgId: number) => {
    if (muscles.some((m) => m.muscle_group_id === mgId)) return;
    const isPrimary = muscles.filter((m) => m.is_primary).length === 0;
    setMuscles([...muscles, { muscle_group_id: mgId, is_primary: isPrimary, activation_percent: isPrimary ? 100 : 50 }]);
  };

  const removeMuscle = (mgId: number) => {
    setMuscles(muscles.filter((m) => m.muscle_group_id !== mgId));
  };

  const toggleRole = (mgId: number) => {
    setMuscles(muscles.map((m) =>
      m.muscle_group_id === mgId
        ? { ...m, is_primary: !m.is_primary, activation_percent: !m.is_primary ? 100 : 50 }
        : m
    ));
  };

  const setActivation = (mgId: number, pct: number) => {
    setMuscles(muscles.map((m) =>
      m.muscle_group_id === mgId ? { ...m, activation_percent: Math.max(1, Math.min(100, pct)) } : m
    ));
  };

  const mutation = useMutation({
    mutationFn: async () => {
      if (!user) throw new Error('Not authenticated');
      if (!name.trim()) throw new Error('Name is required');

      const payload = {
        name: name.trim(),
        equipment: equipment || null,
        exercise_type: exerciseType || null,
        level: level || null,
        notes: notes || null,
        is_custom: true,
        created_by: user.id,
      };

      let exerciseId = exercise?.id;

      if (exercise) {
        const { error: err } = await supabase
          .from('exercises')
          .update(payload)
          .eq('id', exercise.id);
        if (err) throw err;
      } else {
        const { data, error: err } = await supabase
          .from('exercises')
          .insert(payload)
          .select('id')
          .single();
        if (err) throw err;
        exerciseId = data.id;
      }

      // Save muscle associations
      if (exerciseId && muscles.length > 0) {
        // Delete existing associations for this exercise
        await supabase
          .from('exercise_muscles')
          .delete()
          .eq('exercise_id', exerciseId);

        // Insert new associations
        const { error: emErr } = await supabase
          .from('exercise_muscles')
          .insert(muscles.map((m) => ({
            exercise_id: exerciseId,
            muscle_group_id: m.muscle_group_id,
            is_primary: m.is_primary,
            activation_percent: m.activation_percent,
          })));
        if (emErr) throw emErr;
      }
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ['exercises'] });
      onClose();
    },
  });

  const handleSubmit = async () => {
    setError(null);
    try {
      await mutation.mutateAsync();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to save exercise');
    }
  };

  const mgLookup = new Map((muscleGroups ?? []).map((mg) => [mg.id, mg.name]));

  return (
    <Dialog open={open} onClose={onClose} fullWidth maxWidth="xs">
      <DialogTitle>{exercise ? 'Edit Exercise' : 'Create Exercise'}</DialogTitle>
      <DialogContent>
        <Stack spacing={2} sx={{ mt: 1 }}>
          {error && <Alert severity="error">{error}</Alert>}
          <TextField label="Exercise Name" value={name} onChange={(e) => setName(e.target.value)} fullWidth autoFocus required />
          <FormControl fullWidth>
            <InputLabel>Equipment</InputLabel>
            <Select value={equipment} label="Equipment" onChange={(e) => setEquipment(e.target.value)}>
              <MenuItem value="">None</MenuItem>
              {['barbell', 'dumbbell', 'cable', 'machine', 'body only', 'bands', 'kettlebell'].map((t) => (
                <MenuItem key={t} value={t}>{getEquipmentLabel(t)}</MenuItem>
              ))}
            </Select>
          </FormControl>
          <FormControl fullWidth>
            <InputLabel>Category</InputLabel>
            <Select value={exerciseType} label="Category" onChange={(e) => setExerciseType(e.target.value)}>
              <MenuItem value="">None</MenuItem>
              {EXERCISE_TYPE_FILTERS.map(({ value, label }) => (
                <MenuItem key={value} value={value}>{label}</MenuItem>
              ))}
            </Select>
          </FormControl>
          <FormControl fullWidth>
            <InputLabel>Level</InputLabel>
            <Select value={level} label="Level" onChange={(e) => setLevel(e.target.value)}>
              <MenuItem value="">Any</MenuItem>
              <MenuItem value="beginner">Beginner</MenuItem>
              <MenuItem value="intermediate">Intermediate</MenuItem>
              <MenuItem value="expert">Expert</MenuItem>
            </Select>
          </FormControl>

          {/* Muscle groups */}
          <Box>
            <Typography variant="subtitle2" sx={{ mb: 0.5, color: 'text.secondary' }}>Muscle Groups</Typography>
            <Stack direction="row" spacing={0.5} sx={{ flexWrap: 'wrap', gap: 0.5, mb: 1 }}>
              {(muscleGroups ?? []).map((mg) => {
                const selected = muscles.some((m) => m.muscle_group_id === mg.id);
                return (
                  <Chip
                    key={mg.id}
                    label={mg.name}
                    size="small"
                    onClick={() => selected ? removeMuscle(mg.id) : addMuscle(mg.id)}
                    color={selected ? 'primary' : 'default'}
                    variant={selected ? 'filled' : 'outlined'}
                    sx={{ fontSize: '0.7rem' }}
                  />
                );
              })}
            </Stack>

            {/* Selected muscles with role toggle and activation slider */}
            {muscles.length > 0 && (
              <Stack spacing={1}>
                {muscles.map((m) => (
                  <Box key={m.muscle_group_id} sx={{ display: 'flex', alignItems: 'center', gap: 1, px: 1, py: 0.5, borderRadius: '8px', bgcolor: 'rgba(168, 199, 250, 0.06)' }}>
                    <Typography variant="caption" sx={{ minWidth: 60, fontWeight: 500 }}>
                      {mgLookup.get(m.muscle_group_id) ?? '?'}
                    </Typography>
                    <Chip
                      label={m.is_primary ? 'Primary' : 'Secondary'}
                      size="small"
                      onClick={() => toggleRole(m.muscle_group_id)}
                      color={m.is_primary ? 'success' : 'default'}
                      variant="outlined"
                      sx={{ fontSize: '0.65rem', height: 20, cursor: 'pointer' }}
                    />
                    <TextField
                      type="number"
                      value={m.activation_percent}
                      onChange={(e) => setActivation(m.muscle_group_id, Number(e.target.value))}
                      size="small"
                      slotProps={{ htmlInput: { min: 1, max: 100, step: 5 } }}
                      sx={{ width: 64, '& input': { py: 0.25, fontSize: '0.75rem', textAlign: 'center' } }}
                    />
                    <Typography variant="caption" sx={{ color: 'text.disabled' }}>%</Typography>
                  </Box>
                ))}
              </Stack>
            )}
          </Box>

          <TextField label="Notes" value={notes} onChange={(e) => setNotes(e.target.value)} fullWidth multiline rows={2} />
        </Stack>
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose}>Cancel</Button>
        <Button variant="contained" onClick={() => void handleSubmit()} disabled={!name.trim() || mutation.isPending}>
          {mutation.isPending ? 'Saving...' : exercise ? 'Save' : 'Create'}
        </Button>
      </DialogActions>
    </Dialog>
  );
}

// ─── Library Page ────────────────────────────────────────────────────────────

export function LibraryPage() {
  const queryClient = useQueryClient();
  const { data: exercises, isLoading } = useExercises();
  const { data: muscleGroups } = useMuscleGroups();
  const favoriteIds = useFavoriteIds();
  const toggleFavorite = useToggleFavorite();

  const [search, setSearch] = useState('');
  const [equipmentFilter, setEquipmentFilter] = useState<string>('all');
  const [muscleFilter, setMuscleFilter] = useState<number | null>(null);
  const [categoryFilter, setCategoryFilter] = useState<string | null>(null);
  const [viewMode, setViewMode] = useState<'all' | 'favorites'>('all');

  // Detail / CRUD state
  const [selectedExercise, setSelectedExercise] = useState<Exercise | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [editExercise, setEditExercise] = useState<Exercise | null>(null);

  const filtered = useMemo(() => {
    let list = exercises ?? [];
    if (viewMode === 'favorites') list = list.filter((e) => favoriteIds.has(e.id));
    if (search.trim()) {
      const q = search.toLowerCase();
      list = list.filter((e) =>
        e.name.toLowerCase().includes(q) ||
        e.equipment?.toLowerCase().includes(q) ||
        e.category?.toLowerCase().includes(q)
      );
    }
    if (equipmentFilter !== 'all') list = list.filter((e) => e.equipment?.toLowerCase() === equipmentFilter);
    if (muscleFilter) list = list.filter((e) =>
      e.exercise_muscles?.some((em) => em.muscle_group_id === muscleFilter)
    );
    if (categoryFilter) {
      const hasOtherFilters = equipmentFilter !== 'all' || muscleFilter !== null;
      list = list.filter((e) =>
        e.exercise_type === categoryFilter || (hasOtherFilters && !e.exercise_type)
      );
    }
    return list;
  }, [exercises, search, equipmentFilter, muscleFilter, categoryFilter, viewMode, favoriteIds]);

  const handleToggleFavorite = (e: React.MouseEvent, exercise: Exercise) => {
    e.stopPropagation();
    void toggleFavorite.mutateAsync({ exerciseId: exercise.id, isFavorite: favoriteIds.has(exercise.id) });
  };

  const [deleteError, setDeleteError] = useState<string | null>(null);

  const handleDelete = async (exercise: Exercise) => {
    if (!exercise.is_custom) return;
    try {
      const { error } = await supabase.from('exercises').delete().eq('id', exercise.id);
      if (error) throw error;
      void queryClient.invalidateQueries({ queryKey: ['exercises'] });
      setSelectedExercise(null);
      setDeleteError(null);
    } catch (err) {
      setDeleteError(err instanceof Error ? err.message : 'Failed to delete exercise');
    }
  };

  // Detail view
  if (selectedExercise) {
    return (
      <ExerciseDetailView
        exercise={selectedExercise}
        onBack={() => setSelectedExercise(null)}
        onEdit={() => { setEditExercise(selectedExercise); setShowForm(true); }}
        onDelete={() => void handleDelete(selectedExercise)}
      />
    );
  }

  return (
    <Box sx={{ pb: { xs: 10, md: 2 } }}>
      <AppBar position="static" elevation={0} color="transparent">
        <Toolbar sx={{ px: 2, minHeight: '56px !important' }}>
          <MenuBookIcon sx={{ mr: 1, color: 'text.secondary' }} />
          <Typography variant="h6" component="h1" fontWeight={700} sx={{ flexGrow: 1 }}>Exercise Library</Typography>
          <Button size="small" startIcon={<AddIcon />} onClick={() => { setEditExercise(null); setShowForm(true); }}>
            New
          </Button>
        </Toolbar>
      </AppBar>

      <Box sx={{ px: 2 }}>
        <TextField
          size="small" fullWidth placeholder="Search exercises, equipment, muscles..."
          value={search} onChange={(e) => setSearch(e.target.value)}
          slotProps={{ input: { startAdornment: <InputAdornment position="start"><SearchIcon sx={{ fontSize: 20, color: 'text.secondary' }} /></InputAdornment> } }}
          sx={{ mb: 1 }}
        />

        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
          <ToggleButtonGroup value={viewMode} exclusive onChange={(_, v) => { if (v) setViewMode(v); }} size="small">
            <ToggleButton value="all" sx={{ px: 2, py: 0.25, fontSize: '0.75rem' }}>All ({(exercises ?? []).length})</ToggleButton>
            <ToggleButton value="favorites" sx={{ px: 2, py: 0.25, fontSize: '0.75rem' }}>
              <StarIcon sx={{ fontSize: 14, mr: 0.5, color: '#FFD700' }} /> Favorites ({favoriteIds.size})
            </ToggleButton>
          </ToggleButtonGroup>
        </Box>

        <Stack direction="row" spacing={0.5} sx={{ overflowX: 'auto', scrollbarWidth: 'none', '&::-webkit-scrollbar': { display: 'none' }, mb: 0.5 }}>
          {EQUIPMENT_TYPES.map((type) => (
            <Chip key={type} label={getEquipmentLabel(type)} size="small"
              onClick={() => setEquipmentFilter(type)}
              color={equipmentFilter === type ? 'primary' : 'default'}
              variant={equipmentFilter === type ? 'filled' : 'outlined'}
              sx={{ fontSize: '0.7rem', height: 26, flexShrink: 0 }}
            />
          ))}
        </Stack>

        <Stack direction="row" spacing={0.5} sx={{ overflowX: 'auto', scrollbarWidth: 'none', '&::-webkit-scrollbar': { display: 'none' }, mt: 0.5 }}>
          {EXERCISE_TYPE_FILTERS.map(({ value, label }) => (
            <Chip key={value} label={label} size="small"
              onClick={() => setCategoryFilter(categoryFilter === value ? null : value)}
              color={categoryFilter === value ? 'info' : 'default'}
              variant={categoryFilter === value ? 'filled' : 'outlined'}
              sx={{ fontSize: '0.7rem', height: 26, flexShrink: 0 }}
            />
          ))}
        </Stack>

        <Stack direction="row" spacing={0.5} sx={{ overflowX: 'auto', scrollbarWidth: 'none', '&::-webkit-scrollbar': { display: 'none' }, mt: 0.5, mb: 1 }}>
          {(muscleGroups ?? []).slice(0, 12).map((mg) => (
            <Chip key={mg.id} label={mg.name} size="small"
              onClick={() => setMuscleFilter(muscleFilter === mg.id ? null : mg.id)}
              color={muscleFilter === mg.id ? 'secondary' : 'default'}
              variant={muscleFilter === mg.id ? 'filled' : 'outlined'}
              sx={{ fontSize: '0.65rem', height: 24, flexShrink: 0 }}
            />
          ))}
        </Stack>
      </Box>

      {isLoading ? (
        <Box sx={{ px: 2 }}>
          {[1, 2, 3, 4, 5].map((i) => <Skeleton key={i} variant="rectangular" height={64} sx={{ borderRadius: '12px', mb: 0.5 }} />)}
        </Box>
      ) : (
        <List dense sx={{ px: 1 }}>
          {filtered.map((exercise) => {
            const isFav = favoriteIds.has(exercise.id);
            const thumbUrl = exercise.image_urls?.[0];
            return (
              <ListItemButton
                key={exercise.id}
                onClick={() => setSelectedExercise(exercise)}
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
                  secondary={[exercise.equipment, exercise.category, exercise.level].filter(Boolean).join(' · ')}
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
          {filtered.length === 0 && (
            <Box sx={{ textAlign: 'center', py: 4 }}>
              <Typography variant="body2" color="text.secondary">
                {viewMode === 'favorites' ? 'No favorites yet — star exercises to add them here' : 'No exercises match your filters'}
              </Typography>
            </Box>
          )}
        </List>
      )}

      {deleteError && (
        <Alert severity="error" sx={{ mx: 2, mb: 1 }} onClose={() => setDeleteError(null)}>
          {deleteError}
        </Alert>
      )}

      <ExerciseFormDialog
        key={editExercise?.id ?? 'new'}
        open={showForm}
        onClose={() => { setShowForm(false); setEditExercise(null); }}
        exercise={editExercise}
      />
    </Box>
  );
}
