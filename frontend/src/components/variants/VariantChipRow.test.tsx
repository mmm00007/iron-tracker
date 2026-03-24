import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';
import { ThemeProvider } from '@mui/material/styles';
import { theme } from '@/theme';
import { VariantChipRow } from './VariantChipRow';
import type { EquipmentVariant } from '@/types/database';

function renderWithProviders(ui: React.ReactElement) {
  return render(<ThemeProvider theme={theme}>{ui}</ThemeProvider>);
}

function makeVariant(overrides: Partial<EquipmentVariant> & { id: string; name: string }): EquipmentVariant {
  return {
    user_id: 'u1',
    exercise_id: 'ex-1',
    gym_machine_id: null,
    equipment_type: 'barbell',
    manufacturer: null,
    weight_increment: 2.5,
    weight_unit: 'kg',
    seat_settings: {},
    notes: null,
    photo_url: null,
    last_used_at: null,
    created_at: '2025-01-01T00:00:00Z',
    ...overrides,
  };
}

describe('VariantChipRow', () => {
  const defaultProps = {
    selectedId: null as string | null,
    onSelect: vi.fn(),
    onAddClick: vi.fn(),
  };

  it('renders chips for 3 variants plus an Add chip', () => {
    const variants = [
      makeVariant({ id: 'v1', name: 'Flat Bench' }),
      makeVariant({ id: 'v2', name: 'Incline Bench' }),
      makeVariant({ id: 'v3', name: 'Decline Bench' }),
    ];

    renderWithProviders(
      <VariantChipRow {...defaultProps} variants={variants} />,
    );

    expect(screen.getByText('Flat Bench')).toBeInTheDocument();
    expect(screen.getByText('Incline Bench')).toBeInTheDocument();
    expect(screen.getByText('Decline Bench')).toBeInTheDocument();
    expect(screen.getByText('+ Add')).toBeInTheDocument();
  });

  it('returns null (hidden) with 0 variants and no uncloned machines', () => {
    const { container } = renderWithProviders(
      <VariantChipRow {...defaultProps} variants={[]} />,
    );

    expect(container.innerHTML).toBe('');
  });

  it('returns null (hidden) with 1 variant and no uncloned machines', () => {
    const variants = [makeVariant({ id: 'v1', name: 'Default' })];

    const { container } = renderWithProviders(
      <VariantChipRow {...defaultProps} variants={variants} />,
    );

    expect(container.innerHTML).toBe('');
  });

  it('shows row with 1 variant when there are uncloned gym machines', () => {
    const variants = [makeVariant({ id: 'v1', name: 'Default' })];
    const gymMachines = [
      {
        id: 'gm-1',
        gym_id: 'g1',
        exercise_id: 'ex-1',
        name: 'Machine A',
        equipment_type: 'cable',
        manufacturer: null,
        model: null,
        weight_range_min: null,
        weight_range_max: null,
        weight_increment: 5,
        weight_unit: 'kg' as const,
        seat_adjustment_labels: [],
        location_hint: null,
        photo_url: null,
        notes: null,
        sort_order: 0,
        is_active: true,
        updated_at: '2025-01-01T00:00:00Z',
      },
    ];

    renderWithProviders(
      <VariantChipRow {...defaultProps} variants={variants} gymMachines={gymMachines} />,
    );

    expect(screen.getByText('Default')).toBeInTheDocument();
    expect(screen.getByText('Machine A')).toBeInTheDocument();
  });

  it('gives selected chip filled variant styling', () => {
    const variants = [
      makeVariant({ id: 'v1', name: 'Flat Bench' }),
      makeVariant({ id: 'v2', name: 'Incline Bench' }),
    ];

    renderWithProviders(
      <VariantChipRow {...defaultProps} variants={variants} selectedId="v1" />,
    );

    const selectedChip = screen.getByText('Flat Bench').closest('.MuiChip-root');
    expect(selectedChip).toHaveClass('MuiChip-filled');
    expect(selectedChip).toHaveClass('MuiChip-colorPrimary');

    const unselectedChip = screen.getByText('Incline Bench').closest('.MuiChip-root');
    expect(unselectedChip).toHaveClass('MuiChip-outlined');
  });

  it('calls onSelect when a variant chip is clicked', async () => {
    const onSelect = vi.fn();
    const variants = [
      makeVariant({ id: 'v1', name: 'Flat Bench' }),
      makeVariant({ id: 'v2', name: 'Incline Bench' }),
    ];

    renderWithProviders(
      <VariantChipRow {...defaultProps} variants={variants} onSelect={onSelect} />,
    );

    await userEvent.click(screen.getByText('Incline Bench'));
    expect(onSelect).toHaveBeenCalledWith('v2');
  });

  it('calls onAddClick when Add chip is clicked', async () => {
    const onAddClick = vi.fn();
    const variants = [
      makeVariant({ id: 'v1', name: 'A' }),
      makeVariant({ id: 'v2', name: 'B' }),
    ];

    renderWithProviders(
      <VariantChipRow {...defaultProps} variants={variants} onAddClick={onAddClick} />,
    );

    await userEvent.click(screen.getByText('+ Add'));
    expect(onAddClick).toHaveBeenCalled();
  });

  it('truncates long variant names', () => {
    const variants = [
      makeVariant({ id: 'v1', name: 'A Very Long Variant Name That Exceeds Twenty Characters Limit' }),
      makeVariant({ id: 'v2', name: 'Short' }),
    ];

    renderWithProviders(
      <VariantChipRow {...defaultProps} variants={variants} />,
    );

    // The truncate function cuts at 20 chars and adds ellipsis
    expect(screen.queryByText('A Very Long Variant Name That Exceeds Twenty Characters Limit')).not.toBeInTheDocument();
    expect(screen.getByText('Short')).toBeInTheDocument();
  });
});
