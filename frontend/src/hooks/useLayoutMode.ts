import { useMediaQuery, useTheme } from '@mui/material';

export type LayoutMode = 'phone' | 'tablet' | 'desktop';

export function useLayoutMode(): LayoutMode {
  const theme = useTheme();
  const isDesktop = useMediaQuery(theme.breakpoints.up('lg'));
  const isTablet = useMediaQuery(theme.breakpoints.up('md'));

  if (isDesktop) return 'desktop';
  if (isTablet) return 'tablet';
  return 'phone';
}
