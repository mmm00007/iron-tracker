import { Box } from '@mui/material';
import { Outlet, useRouter, useLocation } from '@tanstack/react-router';
import { OfflineIndicator } from '@/components/common/OfflineIndicator';
import { GlobalRestTimer } from '@/components/common/GlobalRestTimer';
import { SyncStatus } from '@/components/common/SyncStatus';
import { InstallPrompt } from '@/components/common/InstallPrompt';
import { useLayoutMode } from '@/hooks/useLayoutMode';
import { getActiveTab } from './navConfig';
import { BottomNav } from './BottomNav';
import { RailNav, RAIL_WIDTH } from './RailNav';
import { TopNav, TOP_NAV_HEIGHT } from './TopNav';

export function AppLayout() {
  const router = useRouter();
  const location = useLocation();
  const layoutMode = useLayoutMode();
  const activeTab = getActiveTab(location.pathname);

  const handleNavChange = (_event: React.SyntheticEvent, newValue: string) => {
    void router.navigate({ to: newValue });
  };

  const overlays = (
    <>
      <OfflineIndicator />
      <GlobalRestTimer />
      <SyncStatus />
      <InstallPrompt />
    </>
  );

  // Phone: column layout with bottom nav
  if (layoutMode === 'phone') {
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
        {overlays}
        <Box
          component="main"
          sx={{
            flex: 1,
            overflowY: 'auto',
            overflowX: 'hidden',
            backgroundColor: 'background.default',
            pb: '80px',
          }}
        >
          <Outlet />
        </Box>
        <BottomNav activeTab={activeTab} onChange={handleNavChange} />
      </Box>
    );
  }

  // Tablet: rail sidebar on left
  if (layoutMode === 'tablet') {
    return (
      <Box
        sx={{
          display: 'flex',
          height: '100dvh',
          backgroundColor: 'background.default',
          position: 'relative',
        }}
      >
        <RailNav activeTab={activeTab} onChange={handleNavChange} />
        <Box
          sx={{
            display: 'flex',
            flexDirection: 'column',
            flex: 1,
            ml: `${RAIL_WIDTH}px`,
          }}
        >
          {overlays}
          <Box
            component="main"
            sx={{
              flex: 1,
              overflowY: 'auto',
              overflowX: 'hidden',
              backgroundColor: 'background.default',
            }}
          >
            <Outlet />
          </Box>
        </Box>
      </Box>
    );
  }

  // Desktop: top nav
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
      <TopNav activeTab={activeTab} onChange={handleNavChange} />
      {overlays}
      <Box
        component="main"
        sx={{
          flex: 1,
          overflowY: 'auto',
          overflowX: 'hidden',
          backgroundColor: 'background.default',
          pt: `${TOP_NAV_HEIGHT}px`,
        }}
      >
        <Box sx={{ maxWidth: 1400, mx: 'auto', width: '100%' }}>
          <Outlet />
        </Box>
      </Box>
    </Box>
  );
}
