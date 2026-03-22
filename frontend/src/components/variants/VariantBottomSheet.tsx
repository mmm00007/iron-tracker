import AddIcon from '@mui/icons-material/Add';
import CameraAltIcon from '@mui/icons-material/CameraAlt';
import CloseIcon from '@mui/icons-material/Close';
import DeleteIcon from '@mui/icons-material/Delete';
import {
  Autocomplete,
  Box,
  Button,
  Chip,
  Dialog,
  DialogActions,
  DialogContent,
  DialogContentText,
  DialogTitle,
  Drawer,
  FormControl,
  IconButton,
  InputLabel,
  MenuItem,
  Select,
  Stack,
  TextField,
  ToggleButton,
  ToggleButtonGroup,
  Typography,
} from '@mui/material';
import { useEffect, useState } from 'react';
import type { EquipmentVariant } from '@/types/database';
import { useCreateVariant, useDeleteVariant, useManufacturers, useUpdateVariant } from '@/hooks/useVariants';

type EquipmentType =
  | 'machine_selectorized'
  | 'machine_plate'
  | 'cable'
  | 'barbell'
  | 'dumbbell'
  | 'bodyweight'
  | 'smith_machine'
  | 'other';

const EQUIPMENT_TYPE_LABELS: Record<EquipmentType, string> = {
  machine_selectorized: 'Machine (Selectorized)',
  machine_plate: 'Machine (Plate-Loaded)',
  cable: 'Cable',
  barbell: 'Barbell',
  dumbbell: 'Dumbbell',
  bodyweight: 'Bodyweight',
  smith_machine: 'Smith Machine',
  other: 'Other',
};

const WEIGHT_INCREMENT_PRESETS = [2.5, 5, 10];
const SEAT_SETTING_PRESETS = ['Seat Position', 'Pad Height', 'Cable Setting'];

interface SeatSettingRow {
  key: string;
  value: string;
}

function seatSettingsToRows(settings: Record<string, string>): SeatSettingRow[] {
  return Object.entries(settings).map(([key, value]) => ({ key, value }));
}

function rowsToSeatSettings(rows: SeatSettingRow[]): Record<string, string> {
  const result: Record<string, string> = {};
  for (const row of rows) {
    if (row.key.trim()) {
      result[row.key.trim()] = row.value;
    }
  }
  return result;
}

interface VariantBottomSheetProps {
  open: boolean;
  onClose: () => void;
  exerciseId: string;
  variant?: EquipmentVariant | null;
}

export function VariantBottomSheet({
  open,
  onClose,
  exerciseId,
  variant = null,
}: VariantBottomSheetProps) {
  const isEdit = variant !== null;

  const [name, setName] = useState('');
  const [equipmentType, setEquipmentType] = useState<EquipmentType>('other');
  const [manufacturer, setManufacturer] = useState<string | null>(null);
  const [weightIncrement, setWeightIncrement] = useState<number>(2.5);
  const [weightUnit, setWeightUnit] = useState<'kg' | 'lb'>('kg');
  const [seatRows, setSeatRows] = useState<SeatSettingRow[]>([]);
  const [notes, setNotes] = useState('');
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);

  const { data: manufacturers = [] } = useManufacturers();
  const createVariant = useCreateVariant();
  const updateVariant = useUpdateVariant();
  const deleteVariant = useDeleteVariant();

  // Populate form when editing
  useEffect(() => {
    if (open) {
      if (variant) {
        setName(variant.name);
        setEquipmentType((variant.equipment_type as EquipmentType) || 'other');
        setManufacturer(variant.manufacturer);
        setWeightIncrement(variant.weight_increment);
        setWeightUnit(variant.weight_unit);
        setSeatRows(seatSettingsToRows(variant.seat_settings));
        setNotes(variant.notes ?? '');
      } else {
        setName('');
        setEquipmentType('other');
        setManufacturer(null);
        setWeightIncrement(2.5);
        setWeightUnit('kg');
        setSeatRows([]);
        setNotes('');
      }
    }
  }, [open, variant]);

  function handleAddSeatRow() {
    setSeatRows((rows) => [...rows, { key: '', value: '' }]);
  }

  function handleAddPresetSeatRow(preset: string) {
    if (!seatRows.some((r) => r.key === preset)) {
      setSeatRows((rows) => [...rows, { key: preset, value: '' }]);
    }
  }

  function handleSeatRowChange(index: number, field: 'key' | 'value', val: string) {
    setSeatRows((rows) => rows.map((r, i) => (i === index ? { ...r, [field]: val } : r)));
  }

  function handleDeleteSeatRow(index: number) {
    setSeatRows((rows) => rows.filter((_, i) => i !== index));
  }

  async function handleSave() {
    if (!name.trim()) return;

    const payload = {
      exercise_id: exerciseId,
      name: name.trim(),
      equipment_type: equipmentType,
      manufacturer: manufacturer?.trim() || null,
      weight_increment: weightIncrement,
      weight_unit: weightUnit,
      seat_settings: rowsToSeatSettings(seatRows),
      notes: notes.trim() || null,
      photo_url: variant?.photo_url ?? null,
      gym_machine_id: variant?.gym_machine_id ?? null,
    };

    if (isEdit && variant) {
      await updateVariant.mutateAsync({
        id: variant.id,
        exerciseId,
        updates: payload,
      });
    } else {
      await createVariant.mutateAsync(payload);
    }

    onClose();
  }

  async function handleDelete() {
    if (!variant) return;
    await deleteVariant.mutateAsync({ id: variant.id, exerciseId });
    setDeleteDialogOpen(false);
    onClose();
  }

  const isSaving = createVariant.isPending || updateVariant.isPending;

  return (
    <>
      <Drawer
        anchor="bottom"
        open={open}
        onClose={onClose}
        PaperProps={{
          sx: {
            borderTopLeftRadius: 16,
            borderTopRightRadius: 16,
            maxHeight: '95dvh',
            display: 'flex',
            flexDirection: 'column',
          },
        }}
      >
        {/* Drag handle */}
        <Box sx={{ display: 'flex', justifyContent: 'center', pt: 1.5, pb: 0.5, flexShrink: 0 }}>
          <Box
            sx={{
              width: 32,
              height: 4,
              borderRadius: 2,
              bgcolor: 'text.disabled',
            }}
          />
        </Box>

        {/* Header */}
        <Box
          sx={{
            display: 'flex',
            alignItems: 'center',
            px: 2,
            py: 1,
            flexShrink: 0,
          }}
        >
          <Typography variant="h6" sx={{ flex: 1 }}>
            {isEdit ? 'Edit Variant' : 'Add Variant'}
          </Typography>
          <IconButton onClick={onClose} edge="end" aria-label="close" size="large">
            <CloseIcon />
          </IconButton>
        </Box>

        {/* Scrollable form body */}
        <Box sx={{ overflowY: 'auto', flex: 1, px: 2, pb: 2 }}>
          <Stack spacing={3}>
            {/* Name */}
            <TextField
              label="Name"
              placeholder="e.g., Hammer Strength Plate-Loaded"
              value={name}
              onChange={(e) => setName(e.target.value)}
              required
              fullWidth
              inputProps={{ style: { minHeight: 48 } }}
            />

            {/* Equipment Type */}
            <FormControl fullWidth>
              <InputLabel id="equipment-type-label">Equipment Type</InputLabel>
              <Select
                labelId="equipment-type-label"
                label="Equipment Type"
                value={equipmentType}
                onChange={(e) => setEquipmentType(e.target.value as EquipmentType)}
                sx={{ minHeight: 48 }}
              >
                {(Object.entries(EQUIPMENT_TYPE_LABELS) as [EquipmentType, string][]).map(
                  ([value, label]) => (
                    <MenuItem key={value} value={value}>
                      {label}
                    </MenuItem>
                  )
                )}
              </Select>
            </FormControl>

            {/* Manufacturer */}
            <Autocomplete
              freeSolo
              options={manufacturers}
              value={manufacturer ?? ''}
              onInputChange={(_e, val) => setManufacturer(val || null)}
              renderInput={(params) => (
                <TextField {...params} label="Manufacturer" placeholder="e.g., Life Fitness" />
              )}
            />

            {/* Weight Increment */}
            <Box>
              <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                Weight Increment
              </Typography>
              <Stack direction="row" spacing={1} sx={{ flexWrap: 'wrap', gap: 1 }}>
                {WEIGHT_INCREMENT_PRESETS.map((preset) => (
                  <Chip
                    key={preset}
                    label={`${preset} ${weightUnit}`}
                    onClick={() => setWeightIncrement(preset)}
                    color={weightIncrement === preset ? 'primary' : 'default'}
                    variant={weightIncrement === preset ? 'filled' : 'outlined'}
                    sx={{ minHeight: 48 }}
                  />
                ))}
                <TextField
                  type="number"
                  label="Custom"
                  value={weightIncrement}
                  onChange={(e) => {
                    const val = parseFloat(e.target.value);
                    if (!isNaN(val) && val > 0) setWeightIncrement(val);
                  }}
                  size="small"
                  sx={{ width: 100 }}
                  inputProps={{ min: 0.25, step: 0.25 }}
                />
              </Stack>
            </Box>

            {/* Weight Unit */}
            <Box>
              <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                Weight Unit
              </Typography>
              <ToggleButtonGroup
                exclusive
                value={weightUnit}
                onChange={(_e, val) => {
                  if (val) setWeightUnit(val as 'kg' | 'lb');
                }}
                sx={{ '& .MuiToggleButton-root': { minHeight: 48, px: 4 } }}
              >
                <ToggleButton value="kg">kg</ToggleButton>
                <ToggleButton value="lb">lb</ToggleButton>
              </ToggleButtonGroup>
            </Box>

            {/* Seat Settings */}
            <Box>
              <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                Seat Settings
              </Typography>

              {/* Preset buttons */}
              <Stack direction="row" spacing={1} sx={{ mb: 1.5, flexWrap: 'wrap', gap: 1 }}>
                {SEAT_SETTING_PRESETS.map((preset) => (
                  <Chip
                    key={preset}
                    label={preset}
                    icon={<AddIcon fontSize="small" />}
                    onClick={() => handleAddPresetSeatRow(preset)}
                    variant="outlined"
                    size="small"
                    sx={{ minHeight: 40 }}
                  />
                ))}
              </Stack>

              {/* Setting rows */}
              <Stack spacing={1.5}>
                {seatRows.map((row, index) => (
                  <Stack key={index} direction="row" spacing={1} alignItems="center">
                    <TextField
                      label="Setting"
                      value={row.key}
                      onChange={(e) => handleSeatRowChange(index, 'key', e.target.value)}
                      size="small"
                      sx={{ flex: 1 }}
                    />
                    <TextField
                      label="Value"
                      value={row.value}
                      onChange={(e) => handleSeatRowChange(index, 'value', e.target.value)}
                      size="small"
                      sx={{ flex: 1 }}
                    />
                    <IconButton
                      onClick={() => handleDeleteSeatRow(index)}
                      size="small"
                      aria-label="remove setting"
                    >
                      <DeleteIcon fontSize="small" />
                    </IconButton>
                  </Stack>
                ))}
              </Stack>

              <Button
                startIcon={<AddIcon />}
                onClick={handleAddSeatRow}
                size="small"
                sx={{ mt: 1, minHeight: 40 }}
              >
                Add Setting
              </Button>
            </Box>

            {/* Notes */}
            <TextField
              label="Notes"
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              multiline
              minRows={2}
              fullWidth
              placeholder="Any notes about this setup..."
            />

            {/* Photo placeholder */}
            <Box>
              <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                Photo
              </Typography>
              <Button
                variant="outlined"
                startIcon={<CameraAltIcon />}
                disabled
                sx={{ minHeight: 48 }}
              >
                Add Photo (coming soon)
              </Button>
            </Box>
          </Stack>
        </Box>

        {/* Action buttons */}
        <Box
          sx={{
            px: 2,
            pb: 3,
            pt: 2,
            flexShrink: 0,
            borderTop: 1,
            borderColor: 'divider',
          }}
        >
          <Stack spacing={1}>
            <Button
              variant="contained"
              onClick={handleSave}
              disabled={!name.trim() || isSaving}
              fullWidth
              sx={{ minHeight: 48 }}
            >
              {isSaving ? 'Saving…' : 'Save'}
            </Button>
            <Button onClick={onClose} sx={{ minHeight: 48 }}>
              Cancel
            </Button>
            {isEdit && (
              <Button
                onClick={() => setDeleteDialogOpen(true)}
                color="error"
                sx={{ minHeight: 48 }}
              >
                Delete Variant
              </Button>
            )}
          </Stack>
        </Box>
      </Drawer>

      {/* Delete confirmation dialog */}
      <Dialog open={deleteDialogOpen} onClose={() => setDeleteDialogOpen(false)}>
        <DialogTitle>Delete Variant?</DialogTitle>
        <DialogContent>
          <DialogContentText>
            This will permanently delete &ldquo;{variant?.name}&rdquo;. This action cannot be
            undone.
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDeleteDialogOpen(false)}>Cancel</Button>
          <Button
            onClick={handleDelete}
            color="error"
            disabled={deleteVariant.isPending}
          >
            Delete
          </Button>
        </DialogActions>
      </Dialog>
    </>
  );
}
