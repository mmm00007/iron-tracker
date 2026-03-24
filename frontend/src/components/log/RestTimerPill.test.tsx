import { render, screen } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { ThemeProvider } from '@mui/material/styles';
import { theme } from '@/theme';
import { RestTimerPill } from './RestTimerPill';

function renderWithProviders(ui: React.ReactElement) {
  return render(<ThemeProvider theme={theme}>{ui}</ThemeProvider>);
}

describe('RestTimerPill', () => {
  beforeEach(() => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date('2025-03-20T12:00:00.000Z'));
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  const now = new Date('2025-03-20T12:00:00.000Z').getTime();

  it('displays timer when running (time remaining)', () => {
    renderWithProviders(
      <RestTimerPill
        durationSeconds={120}
        endTime={now + 90_000} // 90 seconds from now
        onDismiss={vi.fn()}
        onAddTime={vi.fn()}
        onSubtractTime={vi.fn()}
      />,
    );

    // Should show time in MM:SS format; 90 seconds = "1:30"
    expect(screen.getByText('1:30')).toBeInTheDocument();
  });

  it('displays "Rest Complete" when timer has ended', () => {
    renderWithProviders(
      <RestTimerPill
        durationSeconds={120}
        endTime={now - 1000} // already ended 1 second ago
        onDismiss={vi.fn()}
        onAddTime={vi.fn()}
        onSubtractTime={vi.fn()}
      />,
    );

    expect(screen.getByText('Rest Complete')).toBeInTheDocument();
  });

  it('formats time as M:SS', () => {
    renderWithProviders(
      <RestTimerPill
        durationSeconds={120}
        endTime={now + 65_000} // 65 seconds
        onDismiss={vi.fn()}
        onAddTime={vi.fn()}
        onSubtractTime={vi.fn()}
      />,
    );

    expect(screen.getByText('1:05')).toBeInTheDocument();
  });

  it('shows 0:XX for sub-minute times', () => {
    renderWithProviders(
      <RestTimerPill
        durationSeconds={60}
        endTime={now + 45_000} // 45 seconds
        onDismiss={vi.fn()}
        onAddTime={vi.fn()}
        onSubtractTime={vi.fn()}
      />,
    );

    expect(screen.getByText('0:45')).toBeInTheDocument();
  });

  it('shows +30s and -30s buttons while timer is running', () => {
    renderWithProviders(
      <RestTimerPill
        durationSeconds={120}
        endTime={now + 60_000}
        onDismiss={vi.fn()}
        onAddTime={vi.fn()}
        onSubtractTime={vi.fn()}
      />,
    );

    expect(screen.getByLabelText('Add 30 seconds')).toBeInTheDocument();
    expect(screen.getByLabelText('Subtract 30 seconds')).toBeInTheDocument();
  });

  it('hides +30s and -30s buttons when timer is complete', () => {
    renderWithProviders(
      <RestTimerPill
        durationSeconds={120}
        endTime={now - 1000}
        onDismiss={vi.fn()}
        onAddTime={vi.fn()}
        onSubtractTime={vi.fn()}
      />,
    );

    expect(screen.queryByLabelText('Add 30 seconds')).not.toBeInTheDocument();
    expect(screen.queryByLabelText('Subtract 30 seconds')).not.toBeInTheDocument();
  });

  it('shows progress bar while timer is running', () => {
    renderWithProviders(
      <RestTimerPill
        durationSeconds={120}
        endTime={now + 60_000}
        onDismiss={vi.fn()}
        onAddTime={vi.fn()}
        onSubtractTime={vi.fn()}
      />,
    );

    expect(screen.getByRole('progressbar')).toBeInTheDocument();
  });

  it('hides progress bar when timer is complete', () => {
    renderWithProviders(
      <RestTimerPill
        durationSeconds={120}
        endTime={now - 1000}
        onDismiss={vi.fn()}
        onAddTime={vi.fn()}
        onSubtractTime={vi.fn()}
      />,
    );

    expect(screen.queryByRole('progressbar')).not.toBeInTheDocument();
  });
});
