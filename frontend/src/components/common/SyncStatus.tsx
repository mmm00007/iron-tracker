import { useEffect, useState } from 'react';
import Fade from '@mui/material/Fade';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import CircularProgress from '@mui/material/CircularProgress';
import CheckCircleOutlineIcon from '@mui/icons-material/CheckCircleOutline';
import ErrorOutlineIcon from '@mui/icons-material/ErrorOutline';
import { useOnlineStatus } from '@/hooks/useOnlineStatus';
import { useOfflineStore } from '@/stores/offlineStore';

const AUTO_DISMISS_MS = 3000;

/**
 * Transient chip that appears after the device comes back online.
 * - "Syncing…" while isSyncing is true
 * - "All changes synced" for 3 s after success
 * - Error message if syncError is set
 *
 * Only shown after the user was previously offline (wasOffline gate).
 */
export function SyncStatus() {
  const { isOnline, wasOffline } = useOnlineStatus();
  const { isSyncing, syncError, lastSyncAt } = useOfflineStore();
  const [visible, setVisible] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);

  // Show when we come back online after being offline
  useEffect(() => {
    if (isOnline && wasOffline) {
      setVisible(true);
    }
  }, [isOnline, wasOffline]);

  // Track successful sync for auto-dismiss
  useEffect(() => {
    if (lastSyncAt && !isSyncing && !syncError) {
      setShowSuccess(true);
      const timer = window.setTimeout(() => {
        setVisible(false);
        setShowSuccess(false);
      }, AUTO_DISMISS_MS);
      return () => clearTimeout(timer);
    }
  }, [lastSyncAt, isSyncing, syncError]);

  if (!visible) return null;

  return (
    <Fade in={visible}>
      <Box
        sx={{
          position: 'fixed',
          bottom: 80, // above bottom nav
          left: '50%',
          transform: 'translateX(-50%)',
          zIndex: (theme) => theme.zIndex.snackbar,
          bgcolor: syncError ? 'error.main' : showSuccess ? 'success.main' : 'primary.main',
          color: syncError ? 'error.contrastText' : showSuccess ? 'success.contrastText' : 'primary.contrastText',
          borderRadius: 6,
          display: 'flex',
          alignItems: 'center',
          gap: 1,
          px: 2,
          py: 0.75,
          boxShadow: 4,
          whiteSpace: 'nowrap',
        }}
        role="status"
        aria-live="polite"
      >
        {isSyncing && !syncError && (
          <CircularProgress size={14} color="inherit" />
        )}
        {showSuccess && !syncError && (
          <CheckCircleOutlineIcon fontSize="small" />
        )}
        {syncError && (
          <ErrorOutlineIcon fontSize="small" />
        )}
        <Typography variant="body2" fontWeight={500}>
          {syncError
            ? `Sync failed: ${syncError}`
            : showSuccess
              ? 'All changes synced'
              : 'Syncing\u2026'}
        </Typography>
      </Box>
    </Fade>
  );
}
