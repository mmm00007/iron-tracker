import { useState } from 'react';
import { Link as RouterLink, useNavigate } from '@tanstack/react-router';
import {
  Box,
  Button,
  Container,
  Divider,
  Paper,
  TextField,
  Typography,
  Alert,
  CircularProgress,
} from '@mui/material';
import GoogleIcon from '@mui/icons-material/Google';
import FitnessCenterIcon from '@mui/icons-material/FitnessCenter';
import { useAuthStore } from '@/stores/authStore';

function validateEmail(email: string): string | null {
  if (!email) return 'Email is required';
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return 'Enter a valid email address';
  return null;
}

function validatePassword(password: string): string | null {
  if (!password) return 'Password is required';
  if (password.length < 6) return 'Password must be at least 6 characters';
  return null;
}

export function LoginPage() {
  const navigate = useNavigate();
  const { signInWithEmail, signInWithGoogle, loading, error, clearError } = useAuthStore();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [fieldErrors, setFieldErrors] = useState<{ email?: string; password?: string }>({});
  const [submitting, setSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    clearError();

    const emailErr = validateEmail(email);
    const passwordErr = validatePassword(password);
    if (emailErr || passwordErr) {
      setFieldErrors({ email: emailErr ?? undefined, password: passwordErr ?? undefined });
      return;
    }
    setFieldErrors({});
    setSubmitting(true);
    try {
      await signInWithEmail(email, password);
      void navigate({ to: '/log' });
    } catch {
      // error is stored in the store
    } finally {
      setSubmitting(false);
    }
  };

  const handleGoogleSignIn = async () => {
    clearError();
    try {
      await signInWithGoogle();
      // OAuth redirect — navigation handled by Supabase
    } catch {
      // error is stored in the store
    }
  };

  const isLoading = loading || submitting;

  return (
    <Container maxWidth="xs" sx={{ py: 8 }}>
      <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', mb: 4 }}>
        <FitnessCenterIcon sx={{ fontSize: 48, color: 'primary.main', mb: 1 }} />
        <Typography variant="h4" fontWeight={700} gutterBottom>
          Iron Tracker
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Sign in to continue tracking your lifts
        </Typography>
      </Box>

      <Paper sx={{ p: 3 }}>
        {error && (
          <Alert severity="error" sx={{ mb: 2 }} onClose={clearError}>
            {error}
          </Alert>
        )}

        <Box component="form" onSubmit={(e) => void handleSubmit(e)} noValidate>
          <TextField
            label="Email"
            type="email"
            fullWidth
            autoComplete="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            error={!!fieldErrors.email}
            helperText={fieldErrors.email}
            margin="normal"
            disabled={isLoading}
          />
          <TextField
            label="Password"
            type="password"
            fullWidth
            autoComplete="current-password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            error={!!fieldErrors.password}
            helperText={fieldErrors.password}
            margin="normal"
            disabled={isLoading}
          />

          <Box sx={{ textAlign: 'right', mt: 0.5, mb: 2 }}>
            <RouterLink
              to="/forgot-password"
              style={{ color: 'inherit', fontSize: '0.875rem', textDecoration: 'underline' }}
            >
              Forgot password?
            </RouterLink>
          </Box>

          <Button
            type="submit"
            variant="contained"
            fullWidth
            disabled={isLoading}
            sx={{ py: 1.25 }}
          >
            {submitting ? <CircularProgress size={20} color="inherit" /> : 'Sign in'}
          </Button>
        </Box>

        <Divider sx={{ my: 2 }}>
          <Typography variant="caption" color="text.secondary">
            or
          </Typography>
        </Divider>

        <Button
          variant="outlined"
          fullWidth
          startIcon={<GoogleIcon />}
          onClick={() => void handleGoogleSignIn()}
          disabled={isLoading}
          sx={{ py: 1.25 }}
        >
          Sign in with Google
        </Button>

        <Box sx={{ textAlign: 'center', mt: 3 }}>
          <Typography variant="body2" color="text.secondary">
            Don't have an account?{' '}
            <RouterLink to="/signup" style={{ color: 'var(--mui-palette-primary-light, #A8C7FA)' }}>
              Sign up
            </RouterLink>
          </Typography>
        </Box>
      </Paper>
    </Container>
  );
}
