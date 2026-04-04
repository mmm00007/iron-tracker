import { render, screen } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import { ThemeProvider } from '@mui/material/styles';
import { theme } from '@/theme';
import { WeeklySnapshotCard } from './WeeklySnapshotCard';
import type { WeeklySnapshotResult } from '@/utils/analytics';

// Mock the useWeeklySnapshot hook
const mockUseWeeklySnapshot = vi.fn();

vi.mock('@/hooks/useAnalytics', () => ({
  useWeeklySnapshot: () => mockUseWeeklySnapshot(),
}));

// Mock MiniBarChart — Recharts doesn't render in jsdom
vi.mock('@/components/common/MiniBarChart', () => ({
  MiniBarChart: () => <div data-testid="mini-bar-chart" />,
}));

// Mock recharts — ResponsiveContainer has no layout in jsdom
vi.mock('recharts', () => ({
  BarChart: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
  Bar: () => null,
  XAxis: () => null,
  YAxis: () => null,
  ResponsiveContainer: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
  Tooltip: () => null,
}));

function renderWithProviders(ui: React.ReactElement) {
  return render(<ThemeProvider theme={theme}>{ui}</ThemeProvider>);
}

describe('WeeklySnapshotCard', () => {
  it('shows loading state', () => {
    mockUseWeeklySnapshot.mockReturnValue({
      data: undefined,
      isLoading: true,
      isError: false,
    });

    renderWithProviders(<WeeklySnapshotCard />);
    expect(screen.getByRole('progressbar')).toBeInTheDocument();
  });

  it('shows error state', () => {
    mockUseWeeklySnapshot.mockReturnValue({
      data: undefined,
      isLoading: false,
      isError: true,
    });

    renderWithProviders(<WeeklySnapshotCard />);
    expect(screen.getByText('Failed to load weekly stats')).toBeInTheDocument();
  });

  it('shows improvement with positive deltas (green indicators)', () => {
    const snapshot: WeeklySnapshotResult = {
      thisWeek: { sets: 20, volume: 10000, trainingDays: 4 },
      lastWeek: { sets: 15, volume: 8000, trainingDays: 3 },
      deltas: { sets: 33, volume: 25, trainingDays: 33 },
    };

    mockUseWeeklySnapshot.mockReturnValue({
      data: snapshot,
      isLoading: false,
      isError: false,
    });

    renderWithProviders(<WeeklySnapshotCard />);

    // Metric values
    expect(screen.getByText('20')).toBeInTheDocument(); // sets
    expect(screen.getByText('10.0k')).toBeInTheDocument(); // volume formatted
    expect(screen.getByText('4')).toBeInTheDocument(); // training days

    // Positive deltas
    expect(screen.getByText('+33%')).toBeInTheDocument();
    expect(screen.getByText('+25%')).toBeInTheDocument();
  });

  it('shows decline with negative deltas (red indicators)', () => {
    const snapshot: WeeklySnapshotResult = {
      thisWeek: { sets: 10, volume: 5000, trainingDays: 2 },
      lastWeek: { sets: 20, volume: 10000, trainingDays: 4 },
      deltas: { sets: -50, volume: -50, trainingDays: -50 },
    };

    mockUseWeeklySnapshot.mockReturnValue({
      data: snapshot,
      isLoading: false,
      isError: false,
    });

    renderWithProviders(<WeeklySnapshotCard />);

    expect(screen.getByText('10')).toBeInTheDocument();
    expect(screen.getByText('5.0k')).toBeInTheDocument();
    expect(screen.getByText('-50%')).toBeInTheDocument();
  });

  it('shows dash when last week has no data (null deltas)', () => {
    const snapshot: WeeklySnapshotResult = {
      thisWeek: { sets: 5, volume: 2000, trainingDays: 2 },
      lastWeek: { sets: 0, volume: 0, trainingDays: 0 },
      deltas: { sets: null, volume: null, trainingDays: null },
    };

    mockUseWeeklySnapshot.mockReturnValue({
      data: snapshot,
      isLoading: false,
      isError: false,
    });

    renderWithProviders(<WeeklySnapshotCard />);

    // When delta is null, DeltaBadge shows em-dash
    const dashes = screen.getAllByText('\u2014');
    expect(dashes.length).toBe(3);
  });

  it('displays last week summary text', () => {
    const snapshot: WeeklySnapshotResult = {
      thisWeek: { sets: 15, volume: 8000, trainingDays: 3 },
      lastWeek: { sets: 12, volume: 6000, trainingDays: 3 },
      deltas: { sets: 25, volume: 33, trainingDays: 0 },
    };

    mockUseWeeklySnapshot.mockReturnValue({
      data: snapshot,
      isLoading: false,
      isError: false,
    });

    renderWithProviders(<WeeklySnapshotCard />);

    expect(screen.getByText(/12 sets/)).toBeInTheDocument();
    expect(screen.getByText(/3 days/)).toBeInTheDocument();
  });

  it('shows volume below 1000 as rounded integer', () => {
    const snapshot: WeeklySnapshotResult = {
      thisWeek: { sets: 3, volume: 750, trainingDays: 1 },
      lastWeek: { sets: 0, volume: 0, trainingDays: 0 },
      deltas: { sets: null, volume: null, trainingDays: null },
    };

    mockUseWeeklySnapshot.mockReturnValue({
      data: snapshot,
      isLoading: false,
      isError: false,
    });

    renderWithProviders(<WeeklySnapshotCard />);
    expect(screen.getByText('750')).toBeInTheDocument();
  });

  it('always shows the title "This Week vs Last Week"', () => {
    mockUseWeeklySnapshot.mockReturnValue({
      data: undefined,
      isLoading: true,
      isError: false,
    });

    renderWithProviders(<WeeklySnapshotCard />);
    expect(screen.getByText('This Week vs Last Week')).toBeInTheDocument();
  });
});
