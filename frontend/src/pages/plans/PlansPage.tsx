import { useState } from 'react';
import Alert from '@mui/material/Alert';
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Chip from '@mui/material/Chip';
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogTitle from '@mui/material/DialogTitle';
import Divider from '@mui/material/Divider';
import IconButton from '@mui/material/IconButton';
import List from '@mui/material/List';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemText from '@mui/material/ListItemText';
import Skeleton from '@mui/material/Skeleton';
import Stack from '@mui/material/Stack';
import TextField from '@mui/material/TextField';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import AddIcon from '@mui/icons-material/Add';
import DeleteIcon from '@mui/icons-material/Delete';
import EventNoteIcon from '@mui/icons-material/EventNote';
import {
  usePlans,
  useCreatePlan,
  useDeletePlan,
  useUpsertPlanDay,
  useAddPlanItem,
  useDeletePlanItem,
  WEEKDAY_LABELS,
} from '@/hooks/usePlans';
import type { PlanWithDays, PlanDayWithItems } from '@/hooks/usePlans';
import { useExercises } from '@/hooks/useExercises';

// ─── Exercise Picker Dialog ──────────────────────────────────────────────────

function ExercisePickerDialog({
  open,
  onClose,
  onSelect,
}: {
  open: boolean;
  onClose: () => void;
  onSelect: (exerciseId: string, exerciseName: string) => void;
}) {
  const [search, setSearch] = useState('');
  const { data: exercises } = useExercises();

  const filtered = (exercises ?? [])
    .filter((e) => !search.trim() || e.name.toLowerCase().includes(search.toLowerCase()))
    .slice(0, 30);

  return (
    <Dialog open={open} onClose={onClose} fullWidth maxWidth="xs">
      <DialogTitle>Add Exercise</DialogTitle>
      <DialogContent>
        <TextField
          size="small"
          fullWidth
          placeholder="Search exercises..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          autoFocus
          sx={{ mb: 1 }}
        />
        <List dense sx={{ maxHeight: 300, overflow: 'auto' }}>
          {filtered.map((ex) => (
            <ListItemButton
              key={ex.id}
              onClick={() => {
                onSelect(ex.id, ex.name);
                onClose();
                setSearch('');
              }}
              sx={{ borderRadius: 1 }}
            >
              <ListItemText
                primary={ex.name}
                secondary={ex.category ?? ex.equipment}
              />
            </ListItemButton>
          ))}
          {filtered.length === 0 && (
            <Typography variant="body2" sx={{ color: 'text.disabled', py: 2, textAlign: 'center' }}>
              No exercises found
            </Typography>
          )}
        </List>
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose}>Cancel</Button>
      </DialogActions>
    </Dialog>
  );
}

// ─── Plan Card ───────────────────────────────────────────────────────────────

function PlanCard({ plan, onDelete }: { plan: PlanWithDays; onDelete: () => void }) {
  const upsertDay = useUpsertPlanDay();
  const addItem = useAddPlanItem();
  const deleteItem = useDeletePlanItem();
  const [showDayPicker, setShowDayPicker] = useState(false);
  const [addExerciseDay, setAddExerciseDay] = useState<PlanDayWithItems | null>(null);

  const existingWeekdays = new Set(plan.days.map((d) => d.weekday));

  const handleAddDay = async (weekday: number) => {
    setShowDayPicker(false);
    await upsertDay.mutateAsync({ planId: plan.id, weekday });
  };

  const handleAddExercise = async (exerciseId: string) => {
    if (!addExerciseDay) return;
    await addItem.mutateAsync({ planDayId: addExerciseDay.id, exerciseId });
    setAddExerciseDay(null);
  };

  return (
    <Card>
      <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
          <Box>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <Typography variant="subtitle1" fontWeight={700}>
                {plan.name}
              </Typography>
              {plan.is_active && (
                <Chip label="Active" size="small" color="primary" sx={{ height: 20, fontSize: '0.65rem' }} />
              )}
            </Box>
            {plan.description && (
              <Typography variant="body2" sx={{ color: 'text.secondary', mt: 0.25 }}>
                {plan.description}
              </Typography>
            )}
          </Box>
          <IconButton size="small" onClick={onDelete} sx={{ color: 'text.disabled' }}>
            <DeleteIcon fontSize="small" />
          </IconButton>
        </Box>

        <Divider sx={{ my: 1.5 }} />

        {/* Days */}
        <Stack spacing={1.5}>
          {plan.days.map((day) => (
            <Box key={day.id}>
              <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <Typography variant="caption" sx={{ color: 'primary.main', fontWeight: 600 }}>
                  {day.label ?? WEEKDAY_LABELS[day.weekday]}
                </Typography>
                <IconButton
                  size="small"
                  onClick={() => setAddExerciseDay(day)}
                  sx={{ color: 'primary.main', p: 0.25 }}
                >
                  <AddIcon sx={{ fontSize: 16 }} />
                </IconButton>
              </Box>
              {day.items.length > 0 ? (
                <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5, mt: 0.25 }}>
                  {day.items.map((item) => (
                    <Chip
                      key={item.id}
                      label={`${item.exerciseName ?? 'Exercise'} · ${item.target_sets}×${item.target_reps_min}-${item.target_reps_max}`}
                      size="small"
                      variant="outlined"
                      onDelete={() => void deleteItem.mutateAsync(item.id)}
                      sx={{ fontSize: '0.7rem', height: 24 }}
                    />
                  ))}
                </Box>
              ) : (
                <Typography variant="caption" sx={{ color: 'text.disabled' }}>
                  No exercises — tap + to add
                </Typography>
              )}
            </Box>
          ))}
        </Stack>

        {/* Add day button */}
        <Button
          size="small"
          startIcon={<AddIcon />}
          onClick={() => setShowDayPicker(true)}
          sx={{ mt: 1.5, fontSize: '0.75rem' }}
        >
          Add Day
        </Button>

        {/* Day picker dialog */}
        <Dialog open={showDayPicker} onClose={() => setShowDayPicker(false)}>
          <DialogTitle>Add Training Day</DialogTitle>
          <DialogContent>
            <List dense>
              {WEEKDAY_LABELS.map((label, idx) => (
                <ListItemButton
                  key={idx}
                  disabled={existingWeekdays.has(idx)}
                  onClick={() => void handleAddDay(idx)}
                  sx={{ borderRadius: 1 }}
                >
                  <ListItemText
                    primary={label}
                    secondary={existingWeekdays.has(idx) ? 'Already added' : undefined}
                  />
                </ListItemButton>
              ))}
            </List>
          </DialogContent>
        </Dialog>

        {/* Exercise picker */}
        <ExercisePickerDialog
          open={addExerciseDay !== null}
          onClose={() => setAddExerciseDay(null)}
          onSelect={(exerciseId) => void handleAddExercise(exerciseId)}
        />
      </CardContent>
    </Card>
  );
}

// ─── Plans Page ──────────────────────────────────────────────────────────────

export function PlansPage() {
  const { data: plans, isLoading } = usePlans();
  const createPlan = useCreatePlan();
  const deletePlan = useDeletePlan();
  const [showCreate, setShowCreate] = useState(false);
  const [newPlanName, setNewPlanName] = useState('');
  const [newPlanDesc, setNewPlanDesc] = useState('');

  const [createError, setCreateError] = useState<string | null>(null);

  const handleCreate = async () => {
    if (!newPlanName.trim()) return;
    setCreateError(null);
    try {
      await createPlan.mutateAsync({ name: newPlanName, description: newPlanDesc || undefined });
      setNewPlanName('');
      setNewPlanDesc('');
      setShowCreate(false);
    } catch (err) {
      setCreateError(err instanceof Error ? err.message : 'Failed to create plan. The plans table may not be set up yet — run migration 011.');
    }
  };

  return (
    <Box sx={{ pb: { xs: 10, md: 2 } }}>
      <AppBar position="static" elevation={0} color="transparent">
        <Toolbar sx={{ px: 2, minHeight: '56px !important' }}>
          <Typography variant="h6" component="h1" fontWeight={700} sx={{ flexGrow: 1 }}>
            Workout Plans
          </Typography>
          <Button variant="contained" size="small" startIcon={<AddIcon />} onClick={() => setShowCreate(true)}>
            New Plan
          </Button>
        </Toolbar>
      </AppBar>

      {isLoading ? (
        <Box sx={{ px: 2 }}>
          <Stack spacing={2}>
            <Skeleton variant="rounded" height={120} />
            <Skeleton variant="rounded" height={120} />
          </Stack>
        </Box>
      ) : !plans || plans.length === 0 ? (
        <Box sx={{ textAlign: 'center', py: 8, px: 3 }}>
          <EventNoteIcon sx={{ fontSize: 64, color: 'text.disabled', mb: 2 }} />
          <Typography variant="h6" gutterBottom>No workout plans yet</Typography>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 3, maxWidth: 280, mx: 'auto' }}>
            Create a plan to structure your training week with target sets and reps.
          </Typography>
          <Button variant="contained" startIcon={<AddIcon />} onClick={() => setShowCreate(true)}>
            Create Your First Plan
          </Button>
        </Box>
      ) : (
        <Box sx={{ px: 2, display: 'grid', gridTemplateColumns: { xs: '1fr', md: 'repeat(2, 1fr)' }, gap: 2 }}>
          {plans.map((plan) => (
            <PlanCard key={plan.id} plan={plan} onDelete={() => void deletePlan.mutateAsync(plan.id)} />
          ))}
        </Box>
      )}

      {/* Create plan dialog */}
      <Dialog open={showCreate} onClose={() => setShowCreate(false)} fullWidth maxWidth="xs">
        <DialogTitle>New Workout Plan</DialogTitle>
        <DialogContent>
          <Stack spacing={2} sx={{ mt: 1 }}>
            {createError && (
              <Alert severity="error" onClose={() => setCreateError(null)}>
                {createError}
              </Alert>
            )}
            <TextField label="Plan Name" value={newPlanName} onChange={(e) => setNewPlanName(e.target.value)} fullWidth autoFocus placeholder="e.g. Push Pull Legs" />
            <TextField label="Description (optional)" value={newPlanDesc} onChange={(e) => setNewPlanDesc(e.target.value)} fullWidth multiline rows={2} placeholder="e.g. 6-day PPL split" />
          </Stack>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setShowCreate(false)}>Cancel</Button>
          <Button variant="contained" onClick={() => void handleCreate()} disabled={!newPlanName.trim() || createPlan.isPending}>
            {createPlan.isPending ? 'Creating...' : 'Create'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}
