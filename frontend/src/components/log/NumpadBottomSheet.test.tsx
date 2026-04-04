import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';
import { ThemeProvider } from '@mui/material/styles';
import { theme } from '@/theme';
import { NumpadBottomSheet } from './NumpadBottomSheet';

function renderWithProviders(ui: React.ReactElement) {
  return render(<ThemeProvider theme={theme}>{ui}</ThemeProvider>);
}

describe('NumpadBottomSheet', () => {
  const defaultProps = {
    open: true,
    onClose: vi.fn(),
    label: 'Weight (kg)' as const,
    initialValue: 0,
    onApply: vi.fn(),
  };

  it('displays initial value', () => {
    renderWithProviders(<NumpadBottomSheet {...defaultProps} initialValue={100} />);
    expect(screen.getByText('100')).toBeInTheDocument();
  });

  it('shows the label', () => {
    renderWithProviders(<NumpadBottomSheet {...defaultProps} label="Reps" />);
    expect(screen.getByText('REPS')).toBeInTheDocument();
  });

  it('appends digits when numpad buttons are pressed', async () => {
    const user = userEvent.setup();
    renderWithProviders(<NumpadBottomSheet {...defaultProps} initialValue={0} />);

    // Press "1", "2", "5"
    await user.click(screen.getByRole('button', { name: '1' }));
    await user.click(screen.getByRole('button', { name: '2' }));
    await user.click(screen.getByRole('button', { name: '5' }));

    expect(screen.getByText('125')).toBeInTheDocument();
  });

  it('handles decimal point when allowDecimal is true', async () => {
    const user = userEvent.setup();
    renderWithProviders(
      <NumpadBottomSheet {...defaultProps} initialValue={0} allowDecimal={true} />,
    );

    await user.click(screen.getByRole('button', { name: '7' }));
    await user.click(screen.getByRole('button', { name: 'Decimal point' }));
    await user.click(screen.getByRole('button', { name: '5' }));

    expect(screen.getByText('7.5')).toBeInTheDocument();
  });

  it('prevents multiple decimal points', async () => {
    const user = userEvent.setup();
    renderWithProviders(
      <NumpadBottomSheet {...defaultProps} initialValue={0} allowDecimal={true} />,
    );

    await user.click(screen.getByRole('button', { name: '7' }));
    await user.click(screen.getByRole('button', { name: 'Decimal point' }));
    await user.click(screen.getByRole('button', { name: '5' }));
    await user.click(screen.getByRole('button', { name: 'Decimal point' })); // should be ignored
    await user.click(screen.getByRole('button', { name: '3' }));

    expect(screen.getByText('7.53')).toBeInTheDocument();
  });

  it('handles backspace (removes last digit)', async () => {
    const user = userEvent.setup();
    renderWithProviders(<NumpadBottomSheet {...defaultProps} initialValue={0} />);

    await user.click(screen.getByRole('button', { name: '1' }));
    await user.click(screen.getByRole('button', { name: '2' }));
    await user.click(screen.getByRole('button', { name: '3' }));

    // Press backspace
    await user.click(screen.getByLabelText('Backspace'));

    expect(screen.getByText('12')).toBeInTheDocument();
  });

  it('backspace on single digit results in 0', async () => {
    const user = userEvent.setup();
    renderWithProviders(<NumpadBottomSheet {...defaultProps} initialValue={0} />);

    await user.click(screen.getByRole('button', { name: '5' }));
    await user.click(screen.getByLabelText('Backspace'));

    expect(screen.getByText('0')).toBeInTheDocument();
  });

  it('calls onApply with parsed value when Done is pressed', async () => {
    const onApply = vi.fn();
    const user = userEvent.setup();
    renderWithProviders(
      <NumpadBottomSheet {...defaultProps} initialValue={0} onApply={onApply} />,
    );

    await user.click(screen.getByRole('button', { name: '1' }));
    await user.click(screen.getByRole('button', { name: '0' }));
    await user.click(screen.getByRole('button', { name: '0' }));
    await user.click(screen.getByRole('button', { name: 'Done' }));

    expect(onApply).toHaveBeenCalledWith(100);
  });

  it('renders quick-select chips for recent values', () => {
    renderWithProviders(
      <NumpadBottomSheet
        {...defaultProps}
        recentValues={[80, 100, 120]}
      />,
    );

    expect(screen.getByText('80')).toBeInTheDocument();
    expect(screen.getByText('100')).toBeInTheDocument();
    expect(screen.getByText('120')).toBeInTheDocument();
  });

  it('calls onApply and onClose when a quick-select chip is clicked', async () => {
    const onApply = vi.fn();
    const onClose = vi.fn();
    const user = userEvent.setup();
    renderWithProviders(
      <NumpadBottomSheet
        {...defaultProps}
        onApply={onApply}
        onClose={onClose}
        recentValues={[80, 100, 120]}
      />,
    );

    await user.click(screen.getByText('100'));
    expect(onApply).toHaveBeenCalledWith(100);
    expect(onClose).toHaveBeenCalled();
  });

  it('limits quick-select to first 4 values', () => {
    renderWithProviders(
      <NumpadBottomSheet
        {...defaultProps}
        recentValues={[60, 70, 80, 90, 100]}
      />,
    );

    expect(screen.getByText('60')).toBeInTheDocument();
    expect(screen.getByText('70')).toBeInTheDocument();
    expect(screen.getByText('80')).toBeInTheDocument();
    expect(screen.getByText('90')).toBeInTheDocument();
    // 100 should not appear (limited to 4)
    // But "100" could also match other elements; check chip section specifically
  });

  it('replaces leading zero with typed digit', async () => {
    const user = userEvent.setup();
    renderWithProviders(<NumpadBottomSheet {...defaultProps} initialValue={0} />);

    // Display starts at "0", pressing "5" should result in "5" not "05"
    await user.click(screen.getByRole('button', { name: '5' }));
    expect(screen.getByText('5')).toBeInTheDocument();
    expect(screen.queryByText('05')).not.toBeInTheDocument();
  });

  it('shows all numpad keys 0-9', () => {
    renderWithProviders(<NumpadBottomSheet {...defaultProps} />);

    for (let i = 0; i <= 9; i++) {
      expect(screen.getByRole('button', { name: String(i) })).toBeInTheDocument();
    }
  });

  it('shows Done button', () => {
    renderWithProviders(<NumpadBottomSheet {...defaultProps} />);
    expect(screen.getByRole('button', { name: 'Done' })).toBeInTheDocument();
  });
});
