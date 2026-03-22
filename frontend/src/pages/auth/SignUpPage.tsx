import { useState } from 'react';
import { Link as RouterLink, useNavigate } from '@tanstack/react-router';
import {
  Alert,
  Box,
  Button,
  CircularProgress,
  Container,
  Divider,
  Paper,
  TextField,
  Typography,
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

export function SignUpPage() {
  const navigate = useNavigate();
  const { signUpWithEmail, signInWithGoogle, loading, error, clearError } = useAuthStore();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [fieldErrors, setFieldErrors] = useState<{
    email?: string;
    password?: string;
    confirmPassword?: string;
  }>({});
  const [submitting, setSubmitting] = useState(false);
  const [success, setSuccess] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    clearError();

    const emailErr = validateEmail(email);
    const passwordErr = validatePassword(password);
    const confirmErr = confirmPassword !== password ? 'Passwords do not match' : null;

    if (emailErr || passwordErr || confirmErr) {
      setFieldErrors({
        email: emailErr ?? undefined,
        password: passwordErr ?? undefined,
        confirmPassword: confirmErr ?? undefined,
      });
      return;
    }
    setFieldErrors({});
    setSubmitting(true);
    try {
      await signUpWithEmail(email, password);
      // If session is null after signup, email verification is required
      setSuccess(true);
    } catch {
      // error is stored in the store
    } finally {
      setSubmitting(false);
    }
  };

  const handleGoogleSignUp = async () => {
    clearError();
    try {
      await signInWithGoogle();
    } catch {
      // error is stored in the store
    }
  };

  const isLoading = loading || submitting;

  if (success) {
    return (
      <Container maxWidth="xs" sx={{ py: 8 }}>
        <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', mb: 4 }}>
          <FitnessCenterIcon sx={{ fontSize: 48, color: 'primary.main', mb: 1 }} />
          <Typography variant="h4" fontWeight={700} gutterBottom>
            Iron Tracker
          </Typography>
        </Box>
        <Paper sx={{ p: 3 }}>
          <Alert severity="success" sx={{ mb: 2 }}>
            Check your email for a verification link to complete your signup.
          </Alert>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
            Didn't receive it? Check your spam folder or try again.
          </Typography>
          <Button
            variant="outlined"
            fullWidth
            onClick={() => void navigate({ to: '/login' })}
          >
            Back to sign in
          </Button>
        </Paper>
      </Container>
    );
  }

  return (
    <Container maxWidth="xs" sx={{ py: 8 }}>
      <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', mb: 4 }}>
        <FitnessCenterIcon sx={{ fontSize: 48, color: 'primary.main', mb: 1 }} />
        <Typography variant="h4" fontWeight={700} gutterBottom>
          Iron Tracker
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Create your account to start tracking
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
            autoComplete="new-password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            error={!!fieldErrors.password}
            helperText={fieldErrors.password ?? 'At least 6 characters'}
            margin="normal"
            disabled={isLoading}
          />
          <TextField
            label="Confirm Password"
            type="password"
            fullWidth
            autoComplete="new-password"
            value={confirmPassword}
            onChange={(e) => setConfirmPassword(e.target.value)}
            error={!!fieldErrors.confirmPassword}
            helperText={fieldErrors.confirmPassword}
            margin="normal"
            disabled={isLoading}
          />

          <Button
            type="submit"
            variant="contained"
            fullWidth
            disabled={isLoading}
            sx={{ mt: 2, py: 1.25 }}
          >
            {submitting ? <CircularProgress size={20} color="inherit" /> : 'Create account'}
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
          onClick={() => void handleGoogleSignUp()}
          disabled={isLoading}
          sx={{ py: 1.25 }}
        >
          Sign up with Google
        </Button>

        <Box sx={{ textAlign: 'center', mt: 3 }}>
          <Typography variant="body2" color="text.secondary">
            Already have an account?{' '}
            <RouterLink to="/login" style={{ color: '#A8C7FA' }}>
              Sign in
            </RouterLink>
          </Typography>
        </Box>
      </Paper>
    </Container>
  );
}
