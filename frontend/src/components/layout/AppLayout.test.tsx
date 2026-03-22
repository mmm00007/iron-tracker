import { render, screen } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import { ThemeProvider } from '@mui/material/styles';
import { theme } from '@/theme';
import { AppLayout } from './AppLayout';

// Mock TanStack Router hooks used in AppLayout
vi.mock('@tanstack/react-router', () => ({
  Outlet: () => <div data-testid="outlet">Outlet</div>,
  useRouter: () => ({
    navigate: vi.fn(),
  }),
  useLocation: () => ({
    pathname: '/log',
  }),
}));

function renderWithProviders(ui: React.ReactElement) {
  return render(<ThemeProvider theme={theme}>{ui}</ThemeProvider>);
}

describe('AppLayout', () => {
  it('renders the app bar with Iron Tracker title', () => {
    renderWithProviders(<AppLayout />);
    expect(screen.getByText('Iron Tracker')).toBeInTheDocument();
  });

  it('renders the bottom navigation with 4 tabs', () => {
    renderWithProviders(<AppLayout />);
    expect(screen.getByText('Log')).toBeInTheDocument();
    expect(screen.getByText('History')).toBeInTheDocument();
    expect(screen.getByText('Stats')).toBeInTheDocument();
    expect(screen.getByText('Profile')).toBeInTheDocument();
  });

  it('renders the router outlet', () => {
    renderWithProviders(<AppLayout />);
    expect(screen.getByTestId('outlet')).toBeInTheDocument();
  });
});
