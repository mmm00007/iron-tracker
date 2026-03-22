import Collapse from '@mui/material/Collapse';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import WifiOffIcon from '@mui/icons-material/WifiOff';
import { useOnlineStatus } from '@/hooks/useOnlineStatus';
import { useOfflineStore } from '@/stores/offlineStore';

/**
 * Amber banner that slides in below the app bar when the device is offline.
 * Shows the number of mutations waiting to sync.
 */
export function OfflineIndicator() {
  const { isOnline } = useOnlineStatus();
  const pendingMutations = useOfflineStore((s) => s.pendingMutations);

  return (
    <Collapse in={!isOnline} unmountOnExit>
      <Box
        sx={{
          position: 'fixed',
          top: 56, // below standard MUI AppBar height
          left: 0,
          right: 0,
          zIndex: (theme) => theme.zIndex.appBar - 1,
          bgcolor: 'warning.main',
          color: 'warning.contrastText',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          gap: 1,
          px: 2,
          py: 0.75,
        }}
        role="status"
        aria-live="polite"
      >
        <WifiOffIcon fontSize="small" />
        <Typography variant="body2" fontWeight={500}>
          {pendingMutations > 0
            ? `You're offline — ${pendingMutations} change${pendingMutations === 1 ? '' : 's'} pending sync`
            : "You're offline — changes will sync when connected"}
        </Typography>
      </Box>
    </Collapse>
  );
}
