import { useState } from 'react';
import { Link as RouterLink, useNavigate } from '@tanstack/react-router';
import {
  Alert,
  Box,
  Button,
  CircularProgress,
  Container,
  Paper,
  TextField,
  Typography,
} from '@mui/material';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import FitnessCenterIcon from '@mui/icons-material/FitnessCenter';
import { useAuthStore } from '@/stores/authStore';

export function ForgotPasswordPage() {
  const navigate = useNavigate();
  const { resetPassword, error, clearError } = useAuthStore();

  const [email, setEmail] = useState('');
  const [emailError, setEmailError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [success, setSuccess] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    clearError();

    if (!email) {
      setEmailError('Email is required');
      return;
    }
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      setEmailError('Enter a valid email address');
      return;
    }
    setEmailError(null);
    setSubmitting(true);
    try {
      await resetPassword(email);
      setSuccess(true);
    } catch {
      // error is stored in the store
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <Container maxWidth="xs" sx={{ py: 8 }}>
      <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', mb: 4 }}>
        <FitnessCenterIcon sx={{ fontSize: 48, color: 'primary.main', mb: 1 }} />
        <Typography variant="h4" fontWeight={700} gutterBottom>
          Iron Tracker
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Reset your password
        </Typography>
      </Box>

      <Paper sx={{ p: 3 }}>
        {success ? (
          <Box>
            <Alert severity="success" sx={{ mb: 2 }}>
              Password reset email sent. Check your inbox.
            </Alert>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
              Follow the link in the email to set a new password. Check your spam folder if you
              don't see it.
            </Typography>
            <Button
              variant="outlined"
              fullWidth
              onClick={() => void navigate({ to: '/login' })}
            >
              Back to sign in
            </Button>
          </Box>
        ) : (
          <Box>
            {error && (
              <Alert severity="error" sx={{ mb: 2 }} onClose={clearError}>
                {error}
              </Alert>
            )}

            <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
              Enter the email address for your account and we'll send a reset link.
            </Typography>

            <Box component="form" onSubmit={(e) => void handleSubmit(e)} noValidate>
              <TextField
                label="Email"
                type="email"
                fullWidth
                autoComplete="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                error={!!emailError}
                helperText={emailError}
                margin="normal"
                disabled={submitting}
              />

              <Button
                type="submit"
                variant="contained"
                fullWidth
                disabled={submitting}
                sx={{ mt: 2, py: 1.25 }}
              >
                {submitting ? <CircularProgress size={20} color="inherit" /> : 'Send reset link'}
              </Button>
            </Box>

            <Box sx={{ textAlign: 'center', mt: 3 }}>
              <RouterLink
                to="/login"
                style={{
                  color: '#A8C7FA',
                  fontSize: '0.875rem',
                  display: 'inline-flex',
                  alignItems: 'center',
                  gap: '4px',
                }}
              >
                <ArrowBackIcon fontSize="small" />
                Back to sign in
              </RouterLink>
            </Box>
          </Box>
        )}
      </Paper>
    </Container>
  );
}
