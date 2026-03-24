import { createTheme, type PaletteMode } from '@mui/material/styles';

// ----- Dark palette (default) -----
const darkPalette = {
  mode: 'dark' as PaletteMode,
  primary: {
    main: '#A8C7FA',
    light: '#C5D9FC',
    dark: '#5B8DEF',
    contrastText: '#00305A',
  },
  secondary: {
    main: '#C2C7CF',
    light: '#D8DEE7',
    dark: '#8B9198',
    contrastText: '#2B3038',
  },
  background: {
    default: '#121212',
    paper: '#1E1E1E',
  },
  surface: {
    main: '#121212',
    container: '#1A1A2E',
    containerHigh: '#2A2A3E',
    containerHighest: '#1E1E1E',
  },
  error: {
    main: '#FFB4AB',
    contrastText: '#690005',
  },
  warning: {
    main: '#F9A825',
    light: '#FBC02D',
    dark: '#F57F17',
  },
  success: {
    main: '#66BB6A',
    light: '#81C784',
    dark: '#388E3C',
  },
  text: {
    primary: '#E6E1E5',
    secondary: '#CAC4D0',
    disabled: '#938F99',
  },
  divider: 'rgba(202, 196, 208, 0.12)',
  prGold: {
    main: '#FFD700',
    contrastText: '#1A1A00',
  },
  restTimer: {
    main: '#42A5F5',
    contrastText: '#001E36',
  },
};

// ----- Light palette -----
const lightPalette = {
  mode: 'light' as PaletteMode,
  primary: {
    main: '#1B5E8C',
    light: '#2E75B6',
    dark: '#0D3B5C',
    contrastText: '#FFFFFF',
  },
  secondary: {
    main: '#5A6069',
    light: '#72787F',
    dark: '#3E444B',
    contrastText: '#FFFFFF',
  },
  background: {
    default: '#FFFBFE',
    paper: '#F5F5F5',
  },
  surface: {
    main: '#FFFBFE',
    container: '#F0F0F8',
    containerHigh: '#EAEAF2',
    containerHighest: '#F5F5F5',
  },
  error: {
    main: '#BA1A1A',
    contrastText: '#FFFFFF',
  },
  warning: {
    main: '#F57F17',
    light: '#F9A825',
    dark: '#E65100',
  },
  success: {
    main: '#2E7D32',
    light: '#4CAF50',
    dark: '#1B5E20',
  },
  text: {
    primary: '#1C1B1F',
    secondary: '#49454F',
    disabled: '#938F99',
  },
  divider: 'rgba(28, 27, 31, 0.12)',
  prGold: {
    main: '#B8960F',
    contrastText: '#FFFFFF',
  },
  restTimer: {
    main: '#1565C0',
    contrastText: '#FFFFFF',
  },
};

/**
 * Create an MUI theme for the given mode.
 */
export function createAppTheme(mode: PaletteMode) {
  const palette = mode === 'light' ? lightPalette : darkPalette;
  const surfaceBg = mode === 'light' ? '#FFFBFE' : '#121212';
  const surfaceText = mode === 'light' ? '#1C1B1F' : '#E6E1E5';
  const containerBg = mode === 'light' ? '#F0F0F8' : '#1A1A2E';
  const paperBg = mode === 'light' ? '#F5F5F5' : '#1E1E1E';
  const borderColor = mode === 'light' ? 'rgba(28, 27, 31, 0.12)' : 'rgba(202, 196, 208, 0.12)';
  const navSelected = mode === 'light' ? '#1B5E8C' : '#A8C7FA';
  const navDefault = mode === 'light' ? '#49454F' : '#CAC4D0';

  return createTheme({
    breakpoints: {
      values: {
        xs: 0,
        sm: 600,
        md: 768,
        lg: 1200,
        xl: 1536,
      },
    },
    palette,
    typography: {
      fontFamily: '"Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif',
      h1: { fontSize: '2.5rem', fontWeight: 700, letterSpacing: '-0.02em' },
      h2: { fontSize: '2rem', fontWeight: 600, letterSpacing: '-0.01em' },
      h3: { fontSize: '1.5rem', fontWeight: 600 },
      h4: { fontSize: '1.25rem', fontWeight: 600 },
      h5: { fontSize: '1.125rem', fontWeight: 500 },
      h6: { fontSize: '1rem', fontWeight: 500 },
      subtitle1: { fontSize: '1rem', fontWeight: 500, letterSpacing: '0.009em' },
      subtitle2: { fontSize: '0.875rem', fontWeight: 500, letterSpacing: '0.007em' },
      body1: { fontSize: '1rem', fontWeight: 400, letterSpacing: '0.031em' },
      body2: { fontSize: '0.875rem', fontWeight: 400, letterSpacing: '0.018em' },
      caption: { fontSize: '0.75rem', fontWeight: 400, letterSpacing: '0.033em' },
      overline: {
        fontSize: '0.6875rem',
        fontWeight: 500,
        letterSpacing: '0.07em',
        textTransform: 'uppercase',
      },
      button: { fontSize: '0.875rem', fontWeight: 500, letterSpacing: '0.007em' },
    },
    shape: {
      borderRadius: 12,
    },
    components: {
      MuiCssBaseline: {
        styleOverrides: {
          '@media (prefers-reduced-motion: reduce)': {
            '*, *::before, *::after': {
              animationDuration: '0.01ms !important',
              animationIterationCount: '1 !important',
              transitionDuration: '0.01ms !important',
              scrollBehavior: 'auto !important',
            },
          },
          body: {
            backgroundColor: surfaceBg,
            color: surfaceText,
            scrollbarWidth: 'thin',
            scrollbarColor: `${navDefault} ${paperBg}`,
            '&::-webkit-scrollbar': { width: '6px' },
            '&::-webkit-scrollbar-track': { background: paperBg },
            '&::-webkit-scrollbar-thumb': { background: navDefault, borderRadius: '3px' },
          },
        },
      },
      MuiButton: {
        styleOverrides: {
          root: {
            borderRadius: '100px',
            textTransform: 'none',
            fontWeight: 500,
            fontSize: '0.875rem',
            letterSpacing: '0.007em',
            padding: '10px 24px',
          },
          contained: {
            boxShadow: 'none',
            '&:hover': { boxShadow: '0px 1px 2px rgba(0, 0, 0, 0.3)' },
          },
          outlined: {
            borderColor: borderColor,
          },
        },
        defaultProps: { disableElevation: true },
      },
      MuiCard: {
        styleOverrides: {
          root: {
            borderRadius: '16px',
            backgroundImage: 'none',
            backgroundColor: paperBg,
            border: `1px solid ${borderColor}`,
          },
        },
        defaultProps: { elevation: 0 },
      },
      MuiPaper: {
        styleOverrides: {
          root: { backgroundImage: 'none', backgroundColor: paperBg },
          rounded: { borderRadius: '16px' },
        },
      },
      MuiBottomNavigation: {
        styleOverrides: {
          root: {
            backgroundColor: containerBg,
            borderTop: `1px solid ${borderColor}`,
            height: '80px',
            paddingBottom: 'env(safe-area-inset-bottom)',
          },
        },
      },
      MuiBottomNavigationAction: {
        styleOverrides: {
          root: {
            color: navDefault,
            '&.Mui-selected': { color: navSelected },
            '& .MuiBottomNavigationAction-label': {
              fontSize: '0.75rem',
              fontWeight: 500,
              '&.Mui-selected': { fontSize: '0.75rem' },
            },
          },
        },
      },
      MuiIconButton: {
        styleOverrides: { root: { borderRadius: '12px' } },
      },
      MuiTextField: {
        styleOverrides: {
          root: {
            '& .MuiOutlinedInput-root': {
              borderRadius: '12px',
              '& fieldset': { borderColor: borderColor },
              '&:hover fieldset': { borderColor: palette.primary.main },
              '&.Mui-focused fieldset': { borderColor: palette.primary.main },
            },
          },
        },
      },
      MuiChip: {
        styleOverrides: { root: { borderRadius: '8px', fontWeight: 500 } },
      },
      MuiListItem: {
        styleOverrides: { root: { borderRadius: '12px' } },
      },
      MuiAppBar: {
        styleOverrides: {
          root: {
            backgroundColor: containerBg,
            backgroundImage: 'none',
            boxShadow: 'none',
            borderBottom: `1px solid ${borderColor}`,
          },
        },
      },
      MuiDivider: {
        styleOverrides: { root: { borderColor: borderColor } },
      },
      MuiLinearProgress: {
        styleOverrides: {
          root: { borderRadius: '4px', backgroundColor: `${palette.primary.main}20` },
          bar: { borderRadius: '4px' },
        },
      },
      MuiFab: {
        styleOverrides: {
          root: { borderRadius: '16px', boxShadow: '0px 4px 8px rgba(0, 0, 0, 0.4)' },
        },
      },
    },
  });
}

/** Default dark theme (used as fallback and in tests) */
export const theme = createAppTheme('dark');

// Extend MUI palette types for custom colors
declare module '@mui/material/styles' {
  interface Palette {
    surface: Palette['primary'] & {
      container: string;
      containerHigh: string;
      containerHighest: string;
    };
    prGold: Palette['primary'];
    restTimer: Palette['primary'];
  }
  interface PaletteOptions {
    surface?: PaletteOptions['primary'] & {
      container?: string;
      containerHigh?: string;
      containerHighest?: string;
    };
    prGold?: PaletteOptions['primary'];
    restTimer?: PaletteOptions['primary'];
  }
}
