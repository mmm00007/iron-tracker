import AddIcon from '@mui/icons-material/Add';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import {
  AppBar,
  Box,
  Button,
  CircularProgress,
  Dialog,
  DialogActions,
  DialogContent,
  DialogContentText,
  DialogTitle,
  Fab,
  Stack,
  Toolbar,
  Typography,
} from '@mui/material';
import { useParams } from '@tanstack/react-router';
import { useState } from 'react';
import { VariantBottomSheet } from '@/components/variants/VariantBottomSheet';
import { VariantDetail } from '@/components/variants/VariantDetail';
import type { EquipmentVariant, GymMachine } from '@/types/database';
import {
  useCloneGymMachine,
  useDeleteVariant,
  useGymMachines,
  useVariants,
} from '@/hooks/useVariants';

interface VariantManagerPageProps {
  exerciseId: string;
  exerciseName?: string;
}

export function VariantManagerPage({ exerciseId, exerciseName }: VariantManagerPageProps) {
  const { data: variants = [], isLoading: variantsLoading } = useVariants(exerciseId);
  const { data: gymMachines = [], isLoading: machinesLoading } = useGymMachines(exerciseId);
  const deleteVariant = useDeleteVariant();
  const cloneGymMachine = useCloneGymMachine();

  const [sheetOpen, setSheetOpen] = useState(false);
  const [editingVariant, setEditingVariant] = useState<EquipmentVariant | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<EquipmentVariant | null>(null);

  // Gym machines not yet cloned
  const clonedMachineIds = new Set(variants.map((v) => v.gym_machine_id).filter(Boolean));
  const unclonedMachines = gymMachines.filter((m) => !clonedMachineIds.has(m.id));

  function handleAddClick() {
    setEditingVariant(null);
    setSheetOpen(true);
  }

  function handleEditClick(variant: EquipmentVariant) {
    setEditingVariant(variant);
    setSheetOpen(true);
  }

  function handleDeleteClick(variant: EquipmentVariant) {
    setDeleteTarget(variant);
  }

  async function handleConfirmDelete() {
    if (!deleteTarget) return;
    await deleteVariant.mutateAsync({ id: deleteTarget.id, exerciseId });
    setDeleteTarget(null);
  }

  async function handleClone(machine: GymMachine) {
    await cloneGymMachine.mutateAsync({ gymMachine: machine, exerciseId });
  }

  const isLoading = variantsLoading || machinesLoading;

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100dvh', pb: 10 }}>
      {/* Top App Bar */}
      <AppBar position="sticky" color="default" elevation={0}>
        <Toolbar>
          <Button
            startIcon={<ArrowBackIcon />}
            onClick={() => window.history.back()}
            sx={{ mr: 1, minHeight: 48 }}
            color="inherit"
          >
            Back
          </Button>
          <Typography variant="h6" sx={{ flex: 1 }} noWrap>
            {exerciseName ? `${exerciseName} — Variants` : 'Manage Variants'}
          </Typography>
        </Toolbar>
      </AppBar>

      <Box sx={{ flex: 1, p: 2 }}>
        {isLoading ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}>
            <CircularProgress />
          </Box>
        ) : (
          <Stack spacing={2}>
            {/* User variants section */}
            {variants.length === 0 ? (
              <Typography color="text.secondary" sx={{ textAlign: 'center', mt: 4 }}>
                No variants yet. Tap + to add one.
              </Typography>
            ) : (
              variants.map((variant) => (
                <VariantDetail
                  key={variant.id}
                  variant={variant}
                  onEdit={handleEditClick}
                  onDelete={handleDeleteClick}
                />
              ))
            )}

            {/* Gym machines section */}
            {unclonedMachines.length > 0 && (
              <Box sx={{ mt: 2 }}>
                <Typography variant="subtitle1" sx={{ mb: 1.5, fontWeight: 600 }}>
                  Available at your gym
                </Typography>
                <Stack spacing={2}>
                  {unclonedMachines.map((machine) => (
                    <Box key={machine.id}>
                      <VariantDetail
                        variant={{
                          id: machine.id,
                          user_id: '',
                          exercise_id: exerciseId,
                          gym_machine_id: machine.id,
                          name: machine.name,
                          equipment_type: machine.equipment_type,
                          manufacturer: machine.manufacturer,
                          weight_increment: machine.weight_increment,
                          weight_unit: 'kg',
                          seat_settings: {},
                          notes: null,
                          photo_url: machine.photo_url,
                          last_used_at: null,
                          created_at: new Date().toISOString(),
                        }}
                      />
                      <Button
                        variant="outlined"
                        fullWidth
                        onClick={() => handleClone(machine)}
                        disabled={cloneGymMachine.isPending}
                        sx={{ mt: 1, minHeight: 48 }}
                      >
                        Add to My Library
                      </Button>
                    </Box>
                  ))}
                </Stack>
              </Box>
            )}
          </Stack>
        )}
      </Box>

      {/* FAB */}
      <Fab
        color="primary"
        aria-label="add variant"
        onClick={handleAddClick}
        sx={{ position: 'fixed', bottom: 80, right: 24 }}
      >
        <AddIcon />
      </Fab>

      {/* Create / Edit bottom sheet */}
      <VariantBottomSheet
        open={sheetOpen}
        onClose={() => {
          setSheetOpen(false);
          setEditingVariant(null);
        }}
        exerciseId={exerciseId}
        variant={editingVariant}
      />

      {/* Delete confirmation dialog */}
      <Dialog open={deleteTarget !== null} onClose={() => setDeleteTarget(null)}>
        <DialogTitle>Delete Variant?</DialogTitle>
        <DialogContent>
          <DialogContentText>
            This will permanently delete &ldquo;{deleteTarget?.name}&rdquo;. This action cannot be
            undone.
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDeleteTarget(null)}>Cancel</Button>
          <Button
            onClick={handleConfirmDelete}
            color="error"
            disabled={deleteVariant.isPending}
          >
            Delete
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}

// Route-aware wrapper that reads exerciseId from URL params
export function VariantManagerPageRoute() {
  const { exerciseId } = useParams({ strict: false });
  return <VariantManagerPage exerciseId={exerciseId} />;
}
