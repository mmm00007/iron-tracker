import { Box, BottomNavigation, BottomNavigationAction } from '@mui/material';
import { Outlet, useRouter, useLocation } from '@tanstack/react-router';
import FitnessCenterIcon from '@mui/icons-material/FitnessCenter';
import HistoryIcon from '@mui/icons-material/History';
import BarChartIcon from '@mui/icons-material/BarChart';
import PersonOutlineIcon from '@mui/icons-material/PersonOutline';
import { OfflineIndicator } from '@/components/common/OfflineIndicator';
import { GlobalRestTimer } from '@/components/common/GlobalRestTimer';
import { SyncStatus } from '@/components/common/SyncStatus';
import { InstallPrompt } from '@/components/common/InstallPrompt';

const NAV_TABS = [
  { label: 'Log', value: '/log', icon: <FitnessCenterIcon /> },
  { label: 'History', value: '/history', icon: <HistoryIcon /> },
  { label: 'Stats', value: '/stats', icon: <BarChartIcon /> },
  { label: 'Profile', value: '/profile', icon: <PersonOutlineIcon /> },
] as const;

type NavPath = (typeof NAV_TABS)[number]['value'];

function getActiveTab(pathname: string): NavPath {
  const match = NAV_TABS.find((tab) => pathname.startsWith(tab.value));
  return match?.value ?? '/log';
}

export function AppLayout() {
  const router = useRouter();
  const location = useLocation();
  const activeTab = getActiveTab(location.pathname);

  const handleNavChange = (_event: React.SyntheticEvent, newValue: string) => {
    void router.navigate({ to: newValue });
  };

  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'column',
        height: '100dvh',
        backgroundColor: 'background.default',
        position: 'relative',
      }}
    >
      {/* Offline indicator — rendered above the app bar */}
      <OfflineIndicator />

      {/* Global rest timer — persists across all screens */}
      <GlobalRestTimer />

      {/* Sync status chip — appears after coming back online */}
      <SyncStatus />

      {/* PWA install prompt — shown after 3 visits */}
      <InstallPrompt />

      {/* Main content area */}
      <Box
        component="main"
        sx={{
          flex: 1,
          overflowY: 'auto',
          overflowX: 'hidden',
          backgroundColor: 'background.default',
          // Ensure content doesn't go under bottom nav
          pb: '80px',
        }}
      >
        <Outlet />
      </Box>

      {/* MD3 NavigationBar — bottom navigation */}
      <Box
        component="nav"
        sx={{
          position: 'fixed',
          bottom: 0,
          left: 0,
          right: 0,
          zIndex: (theme) => theme.zIndex.appBar,
        }}
      >
        <BottomNavigation value={activeTab} onChange={handleNavChange} showLabels>
          {NAV_TABS.map((tab) => (
            <BottomNavigationAction
              key={tab.value}
              label={tab.label}
              value={tab.value}
              icon={tab.icon}
              sx={{
                // MD3 active indicator pill
                '&.Mui-selected': {
                  '& .MuiBottomNavigationAction-label': {
                    color: 'primary.main',
                  },
                  '& .MuiSvgIcon-root': {
                    color: 'primary.main',
                  },
                },
                '&.Mui-selected::before': {
                  content: '""',
                  position: 'absolute',
                  top: '8px',
                  left: '50%',
                  transform: 'translateX(-50%)',
                  width: '64px',
                  height: '32px',
                  backgroundColor: 'rgba(168, 199, 250, 0.16)',
                  borderRadius: '100px',
                  zIndex: -1,
                },
                position: 'relative',
                overflow: 'visible',
                minWidth: 0,
              }}
            />
          ))}
        </BottomNavigation>
      </Box>
    </Box>
  );
}
