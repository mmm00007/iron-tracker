import { useState } from 'react';
import AppBar from '@mui/material/AppBar';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Chip from '@mui/material/Chip';
import CircularProgress from '@mui/material/CircularProgress';
import Stack from '@mui/material/Stack';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import ErrorIcon from '@mui/icons-material/Error';
import BugReportIcon from '@mui/icons-material/BugReport';
import { useAuthStore } from '@/stores/authStore';
import { useFeatureFlags } from '@/hooks/useFeatureFlags';
import { API_BASE_URL } from '@/lib/supabase';

export function DiagnosticsPage() {
  const { user, session } = useAuthStore();
  const flags = useFeatureFlags();
  const [healthStatus, setHealthStatus] = useState<'idle' | 'loading' | 'ok' | 'error'>('idle');
  const [healthLatency, setHealthLatency] = useState<number | null>(null);

  const apiBaseUrl = API_BASE_URL;

  const handleHealthCheck = async () => {
    setHealthStatus('loading');
    const start = performance.now();
    try {
      const res = await fetch(`${apiBaseUrl}/health`, { signal: AbortSignal.timeout(5000) });
      setHealthLatency(Math.round(performance.now() - start));
      setHealthStatus(res.ok ? 'ok' : 'error');
    } catch {
      setHealthLatency(Math.round(performance.now() - start));
      setHealthStatus('error');
    }
  };

  const sessionExpiry = session?.expires_at
    ? new Date(session.expires_at * 1000).toLocaleString()
    : 'N/A';

  return (
    <Box sx={{ pb: { xs: 10, md: 2 } }}>
      <AppBar position="static" elevation={0} color="transparent">
        <Toolbar sx={{ px: 2, minHeight: '56px !important' }}>
          <BugReportIcon sx={{ mr: 1, color: 'text.secondary' }} />
          <Typography variant="h6" fontWeight={700} sx={{ flexGrow: 1 }}>
            Diagnostics
          </Typography>
        </Toolbar>
      </AppBar>

      <Box sx={{ px: 2, display: 'grid', gridTemplateColumns: { xs: '1fr', md: 'repeat(2, 1fr)' }, gap: 2 }}>
        {/* API Configuration */}
        <Card>
          <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
            <Typography variant="subtitle2" fontWeight={600} gutterBottom>
              API Configuration
            </Typography>
            <Typography variant="body2" sx={{ color: 'text.secondary', wordBreak: 'break-all' }}>
              API_BASE_URL: {apiBaseUrl}
            </Typography>
            <Typography variant="body2" sx={{ color: 'text.secondary', mt: 0.5 }}>
              SENTRY_DSN: {import.meta.env.VITE_SENTRY_DSN ? 'configured' : 'not set'}
            </Typography>
          </CardContent>
        </Card>

        {/* Auth Status */}
        <Card>
          <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
            <Typography variant="subtitle2" fontWeight={600} gutterBottom>
              Authentication
            </Typography>
            <Typography variant="body2" sx={{ color: 'text.secondary' }}>
              User ID: {user?.id?.slice(0, 12) ?? 'N/A'}...
            </Typography>
            <Typography variant="body2" sx={{ color: 'text.secondary' }}>
              Email: {user?.email ?? 'N/A'}
            </Typography>
            <Typography variant="body2" sx={{ color: 'text.secondary' }}>
              Session expires: {sessionExpiry}
            </Typography>
            <Chip
              label={user ? 'Authenticated' : 'Not authenticated'}
              size="small"
              color={user ? 'success' : 'error'}
              sx={{ mt: 1, height: 22, fontSize: '0.65rem' }}
            />
          </CardContent>
        </Card>

        {/* Health Check */}
        <Card>
          <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
            <Typography variant="subtitle2" fontWeight={600} gutterBottom>
              Backend Health
            </Typography>
            <Button
              variant="outlined"
              size="small"
              onClick={() => void handleHealthCheck()}
              disabled={healthStatus === 'loading'}
              startIcon={healthStatus === 'loading' ? <CircularProgress size={14} /> : undefined}
              sx={{ mb: 1 }}
            >
              Ping
            </Button>
            {healthStatus === 'ok' && (
              <Alert severity="success" icon={<CheckCircleIcon fontSize="small" />} sx={{ py: 0 }}>
                OK — {healthLatency}ms
              </Alert>
            )}
            {healthStatus === 'error' && (
              <Alert severity="error" icon={<ErrorIcon fontSize="small" />} sx={{ py: 0 }}>
                Failed — {healthLatency}ms
              </Alert>
            )}
          </CardContent>
        </Card>

        {/* Feature Flags */}
        <Card>
          <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
            <Typography variant="subtitle2" fontWeight={600} gutterBottom>
              Feature Flags
            </Typography>
            <Stack spacing={0.5}>
              {Object.entries(flags).map(([key, value]) => (
                <Box key={key} sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <Typography variant="caption" sx={{ color: 'text.secondary' }}>
                    {key}
                  </Typography>
                  <Chip
                    label={value ? 'ON' : 'OFF'}
                    size="small"
                    color={value ? 'success' : 'default'}
                    sx={{ height: 18, fontSize: '0.6rem' }}
                  />
                </Box>
              ))}
            </Stack>
          </CardContent>
        </Card>

        {/* Environment */}
        <Card sx={{ gridColumn: { md: '1 / -1' } }}>
          <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
            <Typography variant="subtitle2" fontWeight={600} gutterBottom>
              Environment
            </Typography>
            <Typography variant="body2" sx={{ color: 'text.secondary' }}>
              Mode: {import.meta.env.MODE}
            </Typography>
            <Typography variant="body2" sx={{ color: 'text.secondary' }}>
              User Agent: {navigator.userAgent.slice(0, 80)}...
            </Typography>
            <Typography variant="body2" sx={{ color: 'text.secondary' }}>
              Online: {navigator.onLine ? 'Yes' : 'No'}
            </Typography>
            <Typography variant="body2" sx={{ color: 'text.secondary' }}>
              Service Worker: {('serviceWorker' in navigator) ? 'Supported' : 'Not supported'}
            </Typography>
          </CardContent>
        </Card>
      </Box>
    </Box>
  );
}
