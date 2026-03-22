import AddIcon from '@mui/icons-material/Add';
import { Chip, Stack } from '@mui/material';
import type { EquipmentVariant, GymMachine } from '@/types/database';

function truncate(str: string, maxLen: number): string {
  return str.length > maxLen ? `${str.slice(0, maxLen)}…` : str;
}

interface VariantChipRowProps {
  variants: EquipmentVariant[];
  selectedId: string | null;
  onSelect: (variantId: string) => void;
  onAddClick: () => void;
  gymMachines?: GymMachine[];
}

export function VariantChipRow({
  variants,
  selectedId,
  onSelect,
  onAddClick,
  gymMachines = [],
}: VariantChipRowProps) {
  // Determine which gym machines have not yet been cloned
  const clonedMachineIds = new Set(variants.map((v) => v.gym_machine_id).filter(Boolean));
  const unclonedMachines = gymMachines.filter((m) => !clonedMachineIds.has(m.id));

  // Hidden when there is nothing meaningful to show
  if (variants.length <= 1 && unclonedMachines.length === 0) {
    return null;
  }

  return (
    <Stack
      direction="row"
      spacing={1}
      sx={{
        overflowX: 'auto',
        py: 0.5,
        px: 1,
        // Hide scrollbar visually but keep functionality
        scrollbarWidth: 'none',
        '&::-webkit-scrollbar': { display: 'none' },
        flexShrink: 0,
      }}
    >
      {/* User variants */}
      {variants.map((variant) => (
        <Chip
          key={variant.id}
          label={truncate(variant.name, 20)}
          onClick={() => onSelect(variant.id)}
          color={selectedId === variant.id ? 'primary' : 'default'}
          variant={selectedId === variant.id ? 'filled' : 'outlined'}
          sx={{ flexShrink: 0, minHeight: 48, fontSize: '0.875rem' }}
        />
      ))}

      {/* Ghost chips for uncloned gym machines */}
      {unclonedMachines.map((machine) => (
        <Chip
          key={machine.id}
          label={truncate(machine.name, 20)}
          icon={<AddIcon fontSize="small" />}
          onClick={onAddClick}
          variant="outlined"
          sx={{
            flexShrink: 0,
            minHeight: 48,
            fontSize: '0.875rem',
            opacity: 0.6,
            borderStyle: 'dashed',
          }}
        />
      ))}

      {/* Add new variant chip */}
      <Chip
        label="+ Add"
        icon={<AddIcon fontSize="small" />}
        onClick={onAddClick}
        variant="outlined"
        sx={{ flexShrink: 0, minHeight: 48, fontSize: '0.875rem' }}
      />
    </Stack>
  );
}
