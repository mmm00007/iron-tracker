import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import FitnessCenterIcon from '@mui/icons-material/FitnessCenter';
import { NAV_TABS, type NavProps } from './navConfig';

const TOP_NAV_HEIGHT = 64;

export { TOP_NAV_HEIGHT };

export function TopNav({ activeTab, onChange }: NavProps) {
  return (
    <AppBar
      position="fixed"
      elevation={0}
      sx={{
        backgroundColor: 'surface.container',
        borderBottom: '1px solid rgba(202, 196, 208, 0.08)',
        zIndex: (theme) => theme.zIndex.appBar,
      }}
    >
      <Toolbar sx={{ minHeight: `${TOP_NAV_HEIGHT}px !important`, maxWidth: 1400, width: '100%', mx: 'auto' }}>
        {/* App name */}
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mr: 4 }}>
          <FitnessCenterIcon sx={{ color: 'primary.main', fontSize: 24 }} />
          <Typography variant="h6" sx={{ fontWeight: 700, letterSpacing: '-0.01em', color: 'text.primary' }}>
            Iron Tracker
          </Typography>
        </Box>

        {/* Nav items */}
        <Box sx={{ display: 'flex', gap: 0.5, flex: 1 }}>
          {NAV_TABS.map((tab) => {
            const isActive = activeTab === tab.value;
            return (
              <Button
                key={tab.value}
                startIcon={tab.icon}
                onClick={(e) => onChange(e, tab.value)}
                sx={{
                  color: isActive ? 'primary.main' : 'text.secondary',
                  backgroundColor: isActive ? 'rgba(168, 199, 250, 0.12)' : 'transparent',
                  '&:hover': {
                    backgroundColor: isActive
                      ? 'rgba(168, 199, 250, 0.16)'
                      : 'rgba(168, 199, 250, 0.08)',
                  },
                  fontWeight: isActive ? 600 : 400,
                  fontSize: '0.875rem',
                  px: 2,
                  py: 0.75,
                }}
              >
                {tab.label}
              </Button>
            );
          })}
        </Box>
      </Toolbar>
    </AppBar>
  );
}
