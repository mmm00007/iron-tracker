import { useState, useEffect, useCallback } from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import IconButton from '@mui/material/IconButton';
import Typography from '@mui/material/Typography';
import CloseIcon from '@mui/icons-material/Close';
import GetAppIcon from '@mui/icons-material/GetApp';

const VISIT_COUNT_KEY = 'iron-tracker:visit-count';
const DISMISSED_KEY = 'iron-tracker:install-prompt-dismissed';
const MIN_VISITS_BEFORE_PROMPT = 3;

interface BeforeInstallPromptEvent extends Event {
  prompt(): Promise<void>;
  userChoice: Promise<{ outcome: 'accepted' | 'dismissed' }>;
}

export function InstallPrompt() {
  const [promptEvent, setPromptEvent] = useState<BeforeInstallPromptEvent | null>(null);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    // Track visit count
    const storedCount = parseInt(localStorage.getItem(VISIT_COUNT_KEY) ?? '0', 10);
    const newCount = storedCount + 1;
    localStorage.setItem(VISIT_COUNT_KEY, String(newCount));

    const dismissed = localStorage.getItem(DISMISSED_KEY) === 'true';
    if (dismissed) return;

    const handleBeforeInstallPrompt = (e: Event) => {
      e.preventDefault();
      setPromptEvent(e as BeforeInstallPromptEvent);

      if (newCount >= MIN_VISITS_BEFORE_PROMPT) {
        setVisible(true);
      }
    };

    window.addEventListener('beforeinstallprompt', handleBeforeInstallPrompt);
    return () => {
      window.removeEventListener('beforeinstallprompt', handleBeforeInstallPrompt);
    };
  }, []);

  const handleInstall = useCallback(async () => {
    if (!promptEvent) return;
    await promptEvent.prompt();
    const { outcome } = await promptEvent.userChoice;
    if (outcome === 'accepted') {
      setVisible(false);
      setPromptEvent(null);
    }
  }, [promptEvent]);

  const handleDismiss = useCallback(() => {
    localStorage.setItem(DISMISSED_KEY, 'true');
    setVisible(false);
  }, []);

  if (!visible || !promptEvent) return null;

  return (
    <Box
      role="banner"
      sx={{
        position: 'fixed',
        bottom: 80, // above bottom nav
        left: 16,
        right: 16,
        zIndex: 1300,
        backgroundColor: '#1A1A2E',
        border: '1px solid rgba(46, 117, 182, 0.4)',
        borderRadius: 2,
        px: 2,
        py: 1.5,
        display: 'flex',
        alignItems: 'center',
        gap: 1.5,
        boxShadow: '0 8px 24px rgba(0,0,0,0.4)',
        animation: 'slideUp 0.3s ease',
        '@keyframes slideUp': {
          from: { transform: 'translateY(16px)', opacity: 0 },
          to: { transform: 'translateY(0)', opacity: 1 },
        },
      }}
    >
      <GetAppIcon sx={{ color: 'primary.main', flexShrink: 0 }} />
      <Typography variant="body2" sx={{ flex: 1, color: 'text.primary', lineHeight: 1.4 }}>
        Add Iron Tracker to your home screen for the best experience
      </Typography>
      <Button
        variant="contained"
        size="small"
        onClick={() => void handleInstall()}
        sx={{ flexShrink: 0, borderRadius: '100px', px: 2 }}
      >
        Install
      </Button>
      <IconButton
        size="small"
        onClick={handleDismiss}
        sx={{ color: 'text.secondary', flexShrink: 0, p: 0.5 }}
        aria-label="Dismiss install prompt"
      >
        <CloseIcon fontSize="small" />
      </IconButton>
    </Box>
  );
}
