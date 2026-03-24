import { render, screen, act } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { ThemeProvider } from '@mui/material/styles';
import { theme } from '@/theme';
import { PRCelebration } from './PRCelebration';
import type { PRCheckResult } from '@/utils/prDetection';

function renderWithProviders(ui: React.ReactElement) {
  return render(<ThemeProvider theme={theme}>{ui}</ThemeProvider>);
}

describe('PRCelebration', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  const prResult: PRCheckResult = {
    isPR: true,
    records: [
      { type: 'estimated_1rm', newValue: 130.0, previousValue: 120.0 },
      { type: 'rep_max', repCount: 5, newValue: 110, previousValue: 100 },
    ],
  };

  it('renders banner when isPR is true', () => {
    renderWithProviders(
      <PRCelebration prResult={prResult} exerciseName="Bench Press" onDismiss={vi.fn()} />,
    );

    expect(screen.getByText('New PR!')).toBeInTheDocument();
    expect(screen.getByText('Bench Press')).toBeInTheDocument();
    expect(screen.getByRole('status')).toBeInTheDocument();
  });

  it('renders nothing when isPR is false', () => {
    const noPR: PRCheckResult = { isPR: false, records: [] };

    const { container } = renderWithProviders(
      <PRCelebration prResult={noPR} exerciseName="Bench Press" onDismiss={vi.fn()} />,
    );

    expect(container.innerHTML).toBe('');
  });

  it('displays PR record details', () => {
    renderWithProviders(
      <PRCelebration prResult={prResult} exerciseName="Bench Press" onDismiss={vi.fn()} />,
    );

    // prLabel produces "New Est. 1RM — 130.0" and "New 5RM — 110"
    expect(screen.getByText(/New Est\. 1RM/)).toBeInTheDocument();
    expect(screen.getByText(/New 5RM/)).toBeInTheDocument();
  });

  it('auto-dismisses after 4 seconds', () => {
    const onDismiss = vi.fn();

    renderWithProviders(
      <PRCelebration prResult={prResult} exerciseName="Bench Press" onDismiss={onDismiss} />,
    );

    expect(onDismiss).not.toHaveBeenCalled();

    // Advance time by 4 seconds
    act(() => {
      vi.advanceTimersByTime(4000);
    });

    expect(onDismiss).toHaveBeenCalledTimes(1);
  });

  it('does not auto-dismiss before 4 seconds', () => {
    const onDismiss = vi.fn();

    renderWithProviders(
      <PRCelebration prResult={prResult} exerciseName="Bench Press" onDismiss={onDismiss} />,
    );

    act(() => {
      vi.advanceTimersByTime(3999);
    });

    expect(onDismiss).not.toHaveBeenCalled();
  });

  it('can be manually dismissed via close button', async () => {
    const onDismiss = vi.fn();

    renderWithProviders(
      <PRCelebration prResult={prResult} exerciseName="Bench Press" onDismiss={onDismiss} />,
    );

    const closeButton = screen.getByLabelText('Dismiss PR celebration');
    // Use real timers for user event interaction
    vi.useRealTimers();
    await userEvent.click(closeButton);
    expect(onDismiss).toHaveBeenCalled();
  });

  it('has role="status" for accessibility', () => {
    renderWithProviders(
      <PRCelebration prResult={prResult} exerciseName="Bench Press" onDismiss={vi.fn()} />,
    );

    expect(screen.getByRole('status')).toBeInTheDocument();
  });
});
