import { useEffect, useState } from 'react';
import {
  Alert,
  Box,
  Button,
  CircularProgress,
  Container,
  Divider,
  FormControl,
  IconButton,
  InputLabel,
  MenuItem,
  Paper,
  Select,
  Stack,
  ToggleButton,
  ToggleButtonGroup,
  Typography,
} from '@mui/material';
import Switch from '@mui/material/Switch';
import AddIcon from '@mui/icons-material/Add';
import RemoveIcon from '@mui/icons-material/Remove';
import LogoutIcon from '@mui/icons-material/Logout';
import BugReportIcon from '@mui/icons-material/BugReport';
import DarkModeIcon from '@mui/icons-material/DarkMode';
import LightModeIcon from '@mui/icons-material/LightMode';
import { useNavigate } from '@tanstack/react-router';
import { useAuthStore } from '@/stores/authStore';
import { useProfile, useUpdateProfile } from '@/hooks/useProfile';
import { DataExport } from '@/components/profile/DataExport';
import { useThemeMode } from '@/hooks/useThemeMode';
import type { Profile } from '@/types/database';

export function ProfilePage() {
  const navigate = useNavigate();
  const { user, signOut } = useAuthStore();
  const { data: profile, isLoading } = useProfile();
  const updateProfile = useUpdateProfile();
  const { mode: themeMode, toggle: toggleTheme } = useThemeMode();

  const [experienceLevel, setExperienceLevel] = useState<Profile['experience_level']>(null);
  const [primaryGoal, setPrimaryGoal] = useState<Profile['primary_goal']>(null);
  const [weightUnit, setWeightUnit] = useState<'kg' | 'lb'>('kg');
  const [trainingDays, setTrainingDays] = useState(3);
  const [saveSuccess, setSaveSuccess] = useState(false);

  // Sync local state when profile loads
  useEffect(() => {
    if (profile) {
      setExperienceLevel(profile.experience_level);
      setPrimaryGoal(profile.primary_goal);
      setWeightUnit(profile.preferred_weight_unit);
      setTrainingDays(profile.training_days_per_week);
    }
  }, [profile]);

  const handleSave = async () => {
    setSaveSuccess(false);
    try {
      await updateProfile.mutateAsync({
        experience_level: experienceLevel,
        primary_goal: primaryGoal,
        preferred_weight_unit: weightUnit,
        training_days_per_week: trainingDays,
      });
      setSaveSuccess(true);
      setTimeout(() => setSaveSuccess(false), 3000);
    } catch {
      // error handled by mutation state
    }
  };

  const handleSignOut = async () => {
    try {
      await signOut();
    } catch {
      // silently fail
    }
  };

  if (isLoading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', py: 8 }}>
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Container maxWidth="sm" sx={{ py: 4 }}>
      <Typography variant="h5" fontWeight={600} gutterBottom>
        Profile
      </Typography>

      <Paper sx={{ p: 3, mb: 2 }}>
        <Typography variant="subtitle2" color="text.secondary" gutterBottom>
          ACCOUNT
        </Typography>
        <Typography variant="body1">{user?.email}</Typography>
      </Paper>

      <Paper sx={{ p: 3, mb: 2 }}>
        <Typography variant="subtitle2" color="text.secondary" gutterBottom>
          APPEARANCE
        </Typography>
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            {themeMode === 'dark' ? (
              <DarkModeIcon sx={{ color: 'text.secondary' }} />
            ) : (
              <LightModeIcon sx={{ color: 'text.secondary' }} />
            )}
            <Typography variant="body1">
              {themeMode === 'dark' ? 'Dark mode' : 'Light mode'}
            </Typography>
          </Box>
          <Switch
            checked={themeMode === 'light'}
            onChange={toggleTheme}
            inputProps={{ 'aria-label': 'Toggle light mode' }}
          />
        </Box>
      </Paper>

      <Paper sx={{ p: 3, mb: 2 }}>
        <Typography variant="subtitle2" color="text.secondary" gutterBottom sx={{ mb: 2 }}>
          TRAINING PREFERENCES
        </Typography>

        <Stack spacing={3}>
          <FormControl fullWidth>
            <InputLabel id="experience-level-label">Experience Level</InputLabel>
            <Select
              labelId="experience-level-label"
              value={experienceLevel ?? ''}
              label="Experience Level"
              onChange={(e) =>
                setExperienceLevel(
                  (e.target.value as Profile['experience_level']) || null
                )
              }
            >
              <MenuItem value="">
                <em>Not set</em>
              </MenuItem>
              <MenuItem value="beginner">Beginner</MenuItem>
              <MenuItem value="intermediate">Intermediate</MenuItem>
              <MenuItem value="advanced">Advanced</MenuItem>
            </Select>
          </FormControl>

          <FormControl fullWidth>
            <InputLabel id="primary-goal-label">Primary Goal</InputLabel>
            <Select
              labelId="primary-goal-label"
              value={primaryGoal ?? ''}
              label="Primary Goal"
              onChange={(e) =>
                setPrimaryGoal(
                  (e.target.value as Profile['primary_goal']) || null
                )
              }
            >
              <MenuItem value="">
                <em>Not set</em>
              </MenuItem>
              <MenuItem value="strength">Strength</MenuItem>
              <MenuItem value="hypertrophy">Hypertrophy</MenuItem>
              <MenuItem value="general">General Fitness</MenuItem>
            </Select>
          </FormControl>

          <Box>
            <Typography variant="body2" color="text.secondary" gutterBottom>
              Preferred Weight Unit
            </Typography>
            <ToggleButtonGroup
              exclusive
              value={weightUnit}
              onChange={(_e, val) => {
                if (val !== null) setWeightUnit(val as 'kg' | 'lb');
              }}
              size="small"
            >
              <ToggleButton value="kg">kg</ToggleButton>
              <ToggleButton value="lb">lb</ToggleButton>
            </ToggleButtonGroup>
          </Box>

          <Box>
            <Typography variant="body2" color="text.secondary" gutterBottom>
              Training Days per Week
            </Typography>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
              <IconButton
                size="medium"
                onClick={() => setTrainingDays((d: number) => Math.max(1, d - 1))}
                disabled={trainingDays <= 1}
                sx={{ border: '1px solid', borderColor: 'divider', minWidth: 44, minHeight: 44 }}
              >
                <RemoveIcon fontSize="small" />
              </IconButton>
              <Typography variant="h6" sx={{ minWidth: 24, textAlign: 'center' }}>
                {trainingDays}
              </Typography>
              <IconButton
                size="medium"
                onClick={() => setTrainingDays((d: number) => Math.min(7, d + 1))}
                disabled={trainingDays >= 7}
                sx={{ border: '1px solid', borderColor: 'divider', minWidth: 44, minHeight: 44 }}
              >
                <AddIcon fontSize="small" />
              </IconButton>
            </Box>
          </Box>
        </Stack>
      </Paper>

      {saveSuccess && (
        <Alert severity="success" sx={{ mb: 2 }}>
          Profile saved successfully.
        </Alert>
      )}
      {updateProfile.isError && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {updateProfile.error instanceof Error
            ? updateProfile.error.message
            : 'Failed to save profile. Please try again.'}
        </Alert>
      )}

      <Button
        variant="contained"
        fullWidth
        onClick={() => void handleSave()}
        disabled={updateProfile.isPending}
        sx={{ mb: 2, py: 1.25 }}
      >
        {updateProfile.isPending ? <CircularProgress size={20} color="inherit" /> : 'Save'}
      </Button>

      <DataExport />

      <Button
        variant="text"
        fullWidth
        startIcon={<BugReportIcon />}
        onClick={() => void navigate({ to: '/diagnostics' })}
        sx={{ mt: 2, color: 'text.secondary', justifyContent: 'flex-start' }}
      >
        Diagnostics
      </Button>

      <Divider sx={{ my: 2 }} />

      <Button
        variant="outlined"
        color="error"
        fullWidth
        startIcon={<LogoutIcon />}
        onClick={() => void handleSignOut()}
        sx={{ py: 1.25 }}
      >
        Sign out
      </Button>
    </Container>
  );
}
