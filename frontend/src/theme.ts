import { createTheme, type PaletteMode } from '@mui/material/styles';

// ─── Font families ───────────────────────────────────────────────────────────
export const DATA_FONT = '"JetBrains Mono", "SF Mono", "Fira Code", monospace';

// ─── Shared data typography styles ──────────────────────────────────────────
export const DATA_LARGE = { fontFamily: DATA_FONT, fontSize: 'clamp(1.25rem, 4vw, 2rem)', fontWeight: 800, lineHeight: 1, letterSpacing: '-0.02em' } as const;
export const DATA_SMALL = { fontFamily: DATA_FONT, fontSize: 'clamp(0.6875rem, 2vw, 0.875rem)', fontWeight: 600 } as const;

// ─── Chart axis color (WCAG AA on card surfaces) ───────────────────────────
export const CHART_AXIS_COLOR = '#A0AAB8';

// ─── Chart color palette (consistent across all visualizations) ──────────────
export const CHART_COLORS = {
  primary: '#5BEAA2',    // main accent — vibrant mint
  secondary: '#42A5F5',  // cool blue
  tertiary: '#F9A825',   // amber
  quaternary: '#EF5350', // red
  quinary: '#AB47BC',    // purple
  senary: '#26C6DA',     // cyan
  series: [
    '#5BEAA2', '#42A5F5', '#F9A825', '#EF5350', '#AB47BC',
    '#26C6DA', '#FF7043', '#66BB6A', '#7E57C2', '#FFA726',
  ],
  muscle: {
    Chest: '#EF5350',
    Back: '#42A5F5',
    Shoulders: '#FFA726',
    Biceps: '#66BB6A',
    Triceps: '#AB47BC',
    Quadriceps: '#26C6DA',
    Hamstrings: '#00897B',
    Glutes: '#EC407A',
    Core: '#F9A825',
    Calves: '#78909C',
    Forearms: '#8D6E63',
    Trapezius: '#7E57C2',
    Abdominals: '#F9A825',
    Latissimus: '#42A5F5',
    Pectoralis: '#EF5350',
    Deltoids: '#FFA726',
  } as Record<string, string>,
  getMuscleColor(muscle: string, fallbackIdx: number): string {
    const direct = this.muscle[muscle];
    if (direct) return direct;
    for (const [key, color] of Object.entries(this.muscle)) {
      if (muscle.toLowerCase().includes(key.toLowerCase())) return color;
    }
    return this.series[fallbackIdx % this.series.length] ?? '#A8C7FA';
  },
};

// ----- Dark palette (default) -----
const darkPalette = {
  mode: 'dark' as PaletteMode,
  primary: {
    main: '#5BEAA2',
    light: '#8AF0BF',
    dark: '#2DBD75',
    contrastText: '#003822',
  },
  secondary: {
    main: '#C2C7CF',
    light: '#D8DEE7',
    dark: '#8B9198',
    contrastText: '#2B3038',
  },
  background: {
    default: '#0D0F12',
    paper: '#161A1F',
  },
  surface: {
    main: '#0D0F12',
    container: '#141820',
    containerHigh: '#1E2430',
    containerHighest: '#161A1F',
  },
  error: {
    main: '#FFB4AB',
    contrastText: '#690005',
  },
  warning: {
    main: '#F9A825',
    light: '#FBC02D',
    dark: '#F57F17',
    contrastText: '#1A1400',
  },
  success: {
    main: '#5BEAA2',
    light: '#8AF0BF',
    dark: '#2DBD75',
    contrastText: '#003822',
  },
  text: {
    primary: '#EAEEF4',
    secondary: '#A0AAB8',
    disabled: '#9CA5B4',
  },
  divider: 'rgba(160, 170, 184, 0.10)',
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
    main: '#0C8A50',
    light: '#12A862',
    dark: '#066838',
    contrastText: '#FFFFFF',
  },
  secondary: {
    main: '#5A6069',
    light: '#72787F',
    dark: '#3E444B',
    contrastText: '#FFFFFF',
  },
  background: {
    default: '#F8FAFB',
    paper: '#FFFFFF',
  },
  surface: {
    main: '#F8FAFB',
    container: '#EEF2F5',
    containerHigh: '#E4E9ED',
    containerHighest: '#FFFFFF',
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
    main: '#0C8A50',
    light: '#12A862',
    dark: '#066838',
  },
  text: {
    primary: '#111820',
    secondary: '#4A5568',
    disabled: '#6B7280',
  },
  divider: 'rgba(17, 24, 32, 0.10)',
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
  const surfaceBg = mode === 'light' ? '#F8FAFB' : '#0D0F12';
  const surfaceText = mode === 'light' ? '#111820' : '#EAEEF4';
  const containerBg = mode === 'light' ? '#EEF2F5' : '#141820';
  const paperBg = mode === 'light' ? '#FFFFFF' : '#161A1F';
  const borderColor = mode === 'light' ? 'rgba(17, 24, 32, 0.10)' : 'rgba(160, 170, 184, 0.12)';
  const navSelected = mode === 'light' ? '#0C8A50' : '#5BEAA2';
  const navDefault = mode === 'light' ? '#4A5568' : '#A0AAB8';

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
      subtitle1: { fontSize: '1.0625rem', fontWeight: 600, letterSpacing: '0.009em' },
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
      MuiCardContent: {
        styleOverrides: {
          root: {
            padding: '16px',
            '&:last-child': { paddingBottom: '16px' },
          },
        },
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
        styleOverrides: { root: { borderRadius: '100px', fontWeight: 500 } },
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
