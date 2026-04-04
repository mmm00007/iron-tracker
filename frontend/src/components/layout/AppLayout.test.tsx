import { render, screen } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import { ThemeProvider } from '@mui/material/styles';
import { theme } from '@/theme';
import { AppLayout } from './AppLayout';

// Mock TanStack Router hooks
vi.mock('@tanstack/react-router', () => ({
  Outlet: () => <div data-testid="outlet">Outlet</div>,
  useRouter: () => ({ navigate: vi.fn() }),
  useLocation: () => ({ pathname: '/log' }),
}));

// Mock layout mode — default to phone (bottom nav)
vi.mock('@/hooks/useLayoutMode', () => ({
  useLayoutMode: () => 'phone',
}));

// Mock overlay components to avoid dependency chains
vi.mock('@/components/common/OfflineIndicator', () => ({
  OfflineIndicator: () => null,
}));
vi.mock('@/components/common/GlobalRestTimer', () => ({
  GlobalRestTimer: () => null,
}));
vi.mock('@/components/common/SyncStatus', () => ({
  SyncStatus: () => null,
}));
vi.mock('@/components/common/InstallPrompt', () => ({
  InstallPrompt: () => null,
}));
vi.mock('@/components/soreness/SorenessPrompt', () => ({
  SorenessPrompt: () => null,
}));

function renderWithProviders(ui: React.ReactElement) {
  return render(<ThemeProvider theme={theme}>{ui}</ThemeProvider>);
}

describe('AppLayout', () => {
  it('renders the bottom navigation with all tabs', () => {
    renderWithProviders(<AppLayout />);
    expect(screen.getByText('Home')).toBeInTheDocument();
    expect(screen.getByText('Log')).toBeInTheDocument();
    expect(screen.getByText('Library')).toBeInTheDocument();
    expect(screen.getByText('Plans')).toBeInTheDocument();
    expect(screen.getByText('History')).toBeInTheDocument();
    expect(screen.getByText('Stats')).toBeInTheDocument();
    expect(screen.getByText('Profile')).toBeInTheDocument();
  });

  it('renders the router outlet', () => {
    renderWithProviders(<AppLayout />);
    expect(screen.getByTestId('outlet')).toBeInTheDocument();
  });

  it('renders main navigation landmark', () => {
    renderWithProviders(<AppLayout />);
    expect(screen.getByRole('navigation', { name: 'Main navigation' })).toBeInTheDocument();
  });
});
