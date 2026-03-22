import { render, screen } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import { ThemeProvider } from '@mui/material/styles';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { theme } from '@/theme';
import { ExerciseListPage } from './ExerciseListPage';

// Mock TanStack Router hooks
vi.mock('@tanstack/react-router', () => ({
  useNavigate: () => vi.fn(),
  Link: ({ children }: { children: React.ReactNode }) => <>{children}</>,
}));

// Mock Supabase
vi.mock('@/lib/supabase', () => ({
  supabase: {
    from: vi.fn(() => ({
      select: vi.fn(() => ({
        order: vi.fn(() => Promise.resolve({ data: [], error: null })),
        ilike: vi.fn(() => ({
          order: vi.fn(() => ({
            limit: vi.fn(() => Promise.resolve({ data: [], error: null })),
          })),
        })),
        eq: vi.fn(() => ({
          order: vi.fn(() => Promise.resolve({ data: [], error: null })),
        })),
        in: vi.fn(() => Promise.resolve({ data: [], error: null })),
        limit: vi.fn(() => Promise.resolve({ data: [], error: null })),
      })),
    })),
    auth: {
      getUser: vi.fn(() => Promise.resolve({ data: { user: null }, error: null })),
    },
  },
}));

function createTestQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,
        gcTime: Infinity,
      },
    },
  });
}

function renderWithProviders(ui: React.ReactElement) {
  const queryClient = createTestQueryClient();
  return render(
    <QueryClientProvider client={queryClient}>
      <ThemeProvider theme={theme}>{ui}</ThemeProvider>
    </QueryClientProvider>,
  );
}

describe('ExerciseListPage', () => {
  it('renders the Log title', () => {
    renderWithProviders(<ExerciseListPage />);
    expect(screen.getByText('Log')).toBeInTheDocument();
  });

  it('renders the search bar', () => {
    renderWithProviders(<ExerciseListPage />);
    expect(screen.getByPlaceholderText('Search exercises...')).toBeInTheDocument();
  });

  it('shows loading skeleton initially', () => {
    renderWithProviders(<ExerciseListPage />);
    // MUI Skeleton renders with role="progressbar" or can be found by class
    // The loading state renders skeletons before data resolves
    const skeletons = document.querySelectorAll('.MuiSkeleton-root');
    expect(skeletons.length).toBeGreaterThan(0);
  });

  it('renders the camera icon button', () => {
    renderWithProviders(<ExerciseListPage />);
    expect(screen.getByLabelText('Identify machine with camera')).toBeInTheDocument();
  });
});
