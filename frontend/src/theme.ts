import { createTheme } from '@mui/material/styles';

// MD3 dark palette seeded from #2E75B6 (steel blue)
// Primary tones mapped to MUI palette roles
export const theme = createTheme({
  breakpoints: {
    values: {
      xs: 0,
      sm: 600,
      md: 768,   // tablet
      lg: 1200,  // desktop
      xl: 1536,
    },
  },
  palette: {
    mode: 'dark',
    primary: {
      main: '#A8C7FA', // MD3 primary (light tone for dark theme)
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
      default: '#121212', // MD3 surface
      paper: '#1E1E1E',   // MD3 surface container
    },
    surface: {
      main: '#121212',
      container: '#1A1A2E',        // app bars, elevated headers
      containerHigh: '#2A2A3E',    // popovers, menus, tooltips
      containerHighest: '#1E1E1E', // cards, paper
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
      primary: '#E6E1E5',   // MD3 onSurface
      secondary: '#CAC4D0', // MD3 onSurfaceVariant
      disabled: '#938F99',
    },
    divider: 'rgba(202, 196, 208, 0.12)',
    // Custom semantic colors (accessed via theme.palette directly)
    prGold: {
      main: '#FFD700',
      contrastText: '#1A1A00',
    },
    restTimer: {
      main: '#42A5F5',
      contrastText: '#001E36',
    },
  },
  typography: {
    fontFamily: '"Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif',
    h1: {
      fontSize: '2.5rem',
      fontWeight: 700,
      letterSpacing: '-0.02em',
    },
    h2: {
      fontSize: '2rem',
      fontWeight: 600,
      letterSpacing: '-0.01em',
    },
    h3: {
      fontSize: '1.5rem',
      fontWeight: 600,
    },
    h4: {
      fontSize: '1.25rem',
      fontWeight: 600,
    },
    h5: {
      fontSize: '1.125rem',
      fontWeight: 500,
    },
    h6: {
      fontSize: '1rem',
      fontWeight: 500,
    },
    subtitle1: {
      fontSize: '1rem',
      fontWeight: 500,
      letterSpacing: '0.009em',
    },
    subtitle2: {
      fontSize: '0.875rem',
      fontWeight: 500,
      letterSpacing: '0.007em',
    },
    body1: {
      fontSize: '1rem',
      fontWeight: 400,
      letterSpacing: '0.031em',
    },
    body2: {
      fontSize: '0.875rem',
      fontWeight: 400,
      letterSpacing: '0.018em',
    },
    caption: {
      fontSize: '0.75rem',
      fontWeight: 400,
      letterSpacing: '0.033em',
    },
    overline: {
      fontSize: '0.6875rem',
      fontWeight: 500,
      letterSpacing: '0.07em',
      textTransform: 'uppercase',
    },
    button: {
      fontSize: '0.875rem',
      fontWeight: 500,
      letterSpacing: '0.007em',
    },
  },
  shape: {
    borderRadius: 12, // MD3 style
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
          backgroundColor: '#121212',
          color: '#E6E1E5',
          scrollbarWidth: 'thin',
          scrollbarColor: '#49454F #1E1E1E',
          '&::-webkit-scrollbar': {
            width: '6px',
          },
          '&::-webkit-scrollbar-track': {
            background: '#1E1E1E',
          },
          '&::-webkit-scrollbar-thumb': {
            background: '#49454F',
            borderRadius: '3px',
          },
        },
      },
    },
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: '100px', // MD3 full-round pill buttons
          textTransform: 'none',
          fontWeight: 500,
          fontSize: '0.875rem',
          letterSpacing: '0.007em',
          padding: '10px 24px',
        },
        contained: {
          boxShadow: 'none',
          '&:hover': {
            boxShadow: '0px 1px 2px rgba(0, 0, 0, 0.3)',
          },
        },
        outlined: {
          borderColor: 'rgba(202, 196, 208, 0.38)',
        },
      },
      defaultProps: {
        disableElevation: true,
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          borderRadius: '16px', // MD3 card corner radius
          backgroundImage: 'none',
          backgroundColor: '#1E1E1E',
          border: '1px solid rgba(202, 196, 208, 0.08)',
        },
      },
      defaultProps: {
        elevation: 0,
      },
    },
    MuiPaper: {
      styleOverrides: {
        root: {
          backgroundImage: 'none',
          backgroundColor: '#1E1E1E',
        },
        rounded: {
          borderRadius: '16px',
        },
      },
    },
    MuiBottomNavigation: {
      styleOverrides: {
        root: {
          backgroundColor: '#1A1A2E',
          borderTop: '1px solid rgba(202, 196, 208, 0.12)',
          height: '80px',
          paddingBottom: 'env(safe-area-inset-bottom)',
        },
      },
    },
    MuiBottomNavigationAction: {
      styleOverrides: {
        root: {
          color: '#CAC4D0',
          '&.Mui-selected': {
            color: '#A8C7FA',
          },
          '& .MuiBottomNavigationAction-label': {
            fontSize: '0.75rem',
            fontWeight: 500,
            '&.Mui-selected': {
              fontSize: '0.75rem',
            },
          },
        },
      },
    },
    MuiIconButton: {
      styleOverrides: {
        root: {
          borderRadius: '12px',
        },
      },
    },
    MuiTextField: {
      styleOverrides: {
        root: {
          '& .MuiOutlinedInput-root': {
            borderRadius: '12px',
            '& fieldset': {
              borderColor: 'rgba(202, 196, 208, 0.38)',
            },
            '&:hover fieldset': {
              borderColor: '#A8C7FA',
            },
            '&.Mui-focused fieldset': {
              borderColor: '#A8C7FA',
            },
          },
        },
      },
    },
    MuiChip: {
      styleOverrides: {
        root: {
          borderRadius: '8px',
          fontWeight: 500,
        },
      },
    },
    MuiListItem: {
      styleOverrides: {
        root: {
          borderRadius: '12px',
        },
      },
    },
    MuiAppBar: {
      styleOverrides: {
        root: {
          backgroundColor: '#1A1A2E',
          backgroundImage: 'none',
          boxShadow: 'none',
          borderBottom: '1px solid rgba(202, 196, 208, 0.08)',
        },
      },
    },
    MuiDivider: {
      styleOverrides: {
        root: {
          borderColor: 'rgba(202, 196, 208, 0.12)',
        },
      },
    },
    MuiLinearProgress: {
      styleOverrides: {
        root: {
          borderRadius: '4px',
          backgroundColor: 'rgba(168, 199, 250, 0.12)',
        },
        bar: {
          borderRadius: '4px',
        },
      },
    },
    MuiFab: {
      styleOverrides: {
        root: {
          borderRadius: '16px',
          boxShadow: '0px 4px 8px rgba(0, 0, 0, 0.4)',
        },
      },
    },
  },
});

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
