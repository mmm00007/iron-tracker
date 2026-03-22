import CameraAltIcon from '@mui/icons-material/CameraAlt';
import DeleteIcon from '@mui/icons-material/Delete';
import EditIcon from '@mui/icons-material/Edit';
import {
  Box,
  Card,
  CardActions,
  CardContent,
  Chip,
  Divider,
  IconButton,
  Stack,
  Tooltip,
  Typography,
} from '@mui/material';
import type { EquipmentVariant } from '@/types/database';

const EQUIPMENT_TYPE_LABELS: Record<string, string> = {
  machine_selectorized: 'Machine (Selectorized)',
  machine_plate: 'Machine (Plate-Loaded)',
  cable: 'Cable',
  barbell: 'Barbell',
  dumbbell: 'Dumbbell',
  bodyweight: 'Bodyweight',
  smith_machine: 'Smith Machine',
  other: 'Other',
};

interface VariantDetailProps {
  variant: EquipmentVariant;
  gymName?: string;
  onEdit?: (variant: EquipmentVariant) => void;
  onDelete?: (variant: EquipmentVariant) => void;
}

export function VariantDetail({ variant, gymName, onEdit, onDelete }: VariantDetailProps) {
  const seatEntries = Object.entries(variant.seat_settings);

  return (
    <Card variant="outlined">
      <CardContent>
        <Stack spacing={1.5}>
          {/* Header row: name + gym badge */}
          <Stack direction="row" alignItems="flex-start" justifyContent="space-between" spacing={1}>
            <Typography variant="h6" sx={{ flex: 1 }}>
              {variant.name}
            </Typography>
            {gymName && (
              <Chip
                label={`From ${gymName}`}
                size="small"
                color="secondary"
                variant="outlined"
                sx={{ flexShrink: 0 }}
              />
            )}
          </Stack>

          {/* Equipment type badge */}
          <Chip
            label={EQUIPMENT_TYPE_LABELS[variant.equipment_type] ?? variant.equipment_type}
            size="small"
            variant="outlined"
            sx={{ alignSelf: 'flex-start' }}
          />

          {/* Manufacturer */}
          {variant.manufacturer && (
            <Typography variant="body2" color="text.secondary">
              <strong>Manufacturer:</strong> {variant.manufacturer}
            </Typography>
          )}

          {/* Weight increment */}
          <Typography variant="body2" color="text.secondary">
            <strong>Weight increment:</strong> {variant.weight_increment} {variant.weight_unit}
          </Typography>

          {/* Seat settings */}
          {seatEntries.length > 0 && (
            <>
              <Divider />
              <Box>
                <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5 }}>
                  <strong>Seat Settings</strong>
                </Typography>
                <Stack spacing={0.5}>
                  {seatEntries.map(([key, value]) => (
                    <Typography key={key} variant="body2">
                      {key}: <span style={{ fontWeight: 500 }}>{value}</span>
                    </Typography>
                  ))}
                </Stack>
              </Box>
            </>
          )}

          {/* Notes */}
          {variant.notes && (
            <>
              <Divider />
              <Typography variant="body2" color="text.secondary">
                {variant.notes}
              </Typography>
            </>
          )}

          {/* Photo placeholder */}
          {!variant.photo_url && (
            <Box
              sx={{
                display: 'flex',
                alignItems: 'center',
                gap: 1,
                color: 'text.disabled',
              }}
            >
              <CameraAltIcon fontSize="small" />
              <Typography variant="caption">No photo</Typography>
            </Box>
          )}

          {variant.photo_url && (
            <Box
              component="img"
              src={variant.photo_url}
              alt={variant.name}
              sx={{ width: '100%', borderRadius: 1, maxHeight: 200, objectFit: 'cover' }}
            />
          )}
        </Stack>
      </CardContent>

      {(onEdit || onDelete) && (
        <CardActions sx={{ justifyContent: 'flex-end', pt: 0 }}>
          {onEdit && (
            <Tooltip title="Edit variant">
              <IconButton
                onClick={() => onEdit(variant)}
                size="large"
                aria-label="edit variant"
                sx={{ minWidth: 48, minHeight: 48 }}
              >
                <EditIcon />
              </IconButton>
            </Tooltip>
          )}
          {onDelete && (
            <Tooltip title="Delete variant">
              <IconButton
                onClick={() => onDelete(variant)}
                size="large"
                color="error"
                aria-label="delete variant"
                sx={{ minWidth: 48, minHeight: 48 }}
              >
                <DeleteIcon />
              </IconButton>
            </Tooltip>
          )}
        </CardActions>
      )}
    </Card>
  );
}
