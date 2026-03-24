import { useState, useCallback, useEffect } from 'react';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import ToggleButton from '@mui/material/ToggleButton';
import ToggleButtonGroup from '@mui/material/ToggleButtonGroup';
import TextField from '@mui/material/TextField';
import Card from '@mui/material/Card';
import CardActionArea from '@mui/material/CardActionArea';
import Stack from '@mui/material/Stack';
import IconButton from '@mui/material/IconButton';
import CircularProgress from '@mui/material/CircularProgress';
import AddIcon from '@mui/icons-material/Add';
import RemoveIcon from '@mui/icons-material/Remove';
import CameraAltIcon from '@mui/icons-material/CameraAlt';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import FitnessCenterIcon from '@mui/icons-material/FitnessCenter';
import { useNavigate } from '@tanstack/react-router';
import { OnboardingStep } from '@/components/onboarding/OnboardingStep';
import { useUpdateProfile } from '@/hooks/useProfile';
import { useGyms, useJoinGym } from '@/hooks/useGyms';
import { useDebounce } from '@/hooks/useDebounce';

const TOTAL_STEPS = 5;

type ExperienceLevel = 'beginner' | 'intermediate' | 'advanced';
type PrimaryGoal = 'strength' | 'hypertrophy' | 'general';
type WeightUnit = 'kg' | 'lb';

interface ProfileDraft {
  experienceLevel: ExperienceLevel | null;
  primaryGoal: PrimaryGoal | null;
  preferredWeightUnit: WeightUnit;
  trainingDaysPerWeek: number;
}

// ─── Screen 1: Welcome ────────────────────────────────────────────────────────

function WelcomeScreen({ onNext }: { onNext: () => void }) {
  return (
    <OnboardingStep
      totalSteps={TOTAL_STEPS}
      currentStep={0}
      onNext={onNext}
      nextLabel="Get Started"
      hideBack
    >
      <Box sx={{ textAlign: 'center' }}>
        <Box
          sx={{
            width: 96,
            height: 96,
            borderRadius: '50%',
            backgroundColor: 'rgba(46, 117, 182, 0.15)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            mx: 'auto',
            mb: 4,
          }}
        >
          <FitnessCenterIcon sx={{ fontSize: 52, color: 'primary.main' }} />
        </Box>
        <Typography
          variant="h3"
          sx={{ fontWeight: 800, letterSpacing: '-0.03em', mb: 1.5, color: 'text.primary' }}
        >
          Iron Tracker
        </Typography>
        <Typography variant="body1" sx={{ color: 'text.secondary', fontSize: '1.1rem' }}>
          Track every machine. Master every set.
        </Typography>
      </Box>
    </OnboardingStep>
  );
}

// ─── Screen 2: Profile Setup ─────────────────────────────────────────────────

function ProfileSetupScreen({
  draft,
  onChange,
  onNext,
  onBack,
}: {
  draft: ProfileDraft;
  onChange: (updates: Partial<ProfileDraft>) => void;
  onNext: () => void;
  onBack: () => void;
}) {
  return (
    <OnboardingStep
      totalSteps={TOTAL_STEPS}
      currentStep={1}
      onNext={onNext}
      onBack={onBack}
      nextLabel="Continue"
    >
      <Box>
        <Typography variant="h5" sx={{ fontWeight: 700, mb: 0.5, color: 'text.primary' }}>
          Tell us about yourself
        </Typography>
        <Typography variant="body2" sx={{ color: 'text.secondary', mb: 3 }}>
          We'll personalise your experience.
        </Typography>

        {/* Experience level */}
        <Typography variant="caption" sx={{ color: 'text.secondary', fontWeight: 600, mb: 1, display: 'block', textTransform: 'uppercase', letterSpacing: '0.08em' }}>
          Experience Level
        </Typography>
        <ToggleButtonGroup
          value={draft.experienceLevel}
          exclusive
          onChange={(_, v: ExperienceLevel | null) => v && onChange({ experienceLevel: v })}
          fullWidth
          sx={{ mb: 3 }}
        >
          <ToggleButton value="beginner">Beginner</ToggleButton>
          <ToggleButton value="intermediate">Intermediate</ToggleButton>
          <ToggleButton value="advanced">Advanced</ToggleButton>
        </ToggleButtonGroup>

        {/* Primary goal */}
        <Typography variant="caption" sx={{ color: 'text.secondary', fontWeight: 600, mb: 1, display: 'block', textTransform: 'uppercase', letterSpacing: '0.08em' }}>
          Primary Goal
        </Typography>
        <ToggleButtonGroup
          value={draft.primaryGoal}
          exclusive
          onChange={(_, v: PrimaryGoal | null) => v && onChange({ primaryGoal: v })}
          fullWidth
          sx={{ mb: 3 }}
        >
          <ToggleButton value="strength">Strength</ToggleButton>
          <ToggleButton value="hypertrophy">Hypertrophy</ToggleButton>
          <ToggleButton value="general">General Fitness</ToggleButton>
        </ToggleButtonGroup>

        {/* Weight unit */}
        <Typography variant="caption" sx={{ color: 'text.secondary', fontWeight: 600, mb: 1, display: 'block', textTransform: 'uppercase', letterSpacing: '0.08em' }}>
          Weight Unit
        </Typography>
        <ToggleButtonGroup
          value={draft.preferredWeightUnit}
          exclusive
          onChange={(_, v: WeightUnit | null) => v && onChange({ preferredWeightUnit: v })}
          sx={{ mb: 3 }}
        >
          <ToggleButton value="kg" sx={{ px: 4 }}>kg</ToggleButton>
          <ToggleButton value="lb" sx={{ px: 4 }}>lb</ToggleButton>
        </ToggleButtonGroup>

        {/* Training days per week */}
        <Typography variant="caption" sx={{ color: 'text.secondary', fontWeight: 600, mb: 1, display: 'block', textTransform: 'uppercase', letterSpacing: '0.08em' }}>
          Training Days Per Week
        </Typography>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
          <IconButton
            onClick={() => onChange({ trainingDaysPerWeek: Math.max(1, draft.trainingDaysPerWeek - 1) })}
            disabled={draft.trainingDaysPerWeek <= 1}
            sx={{ color: 'primary.main' }}
          >
            <RemoveIcon />
          </IconButton>
          <Typography variant="h5" sx={{ fontWeight: 700, minWidth: 32, textAlign: 'center', color: 'text.primary' }}>
            {draft.trainingDaysPerWeek}
          </Typography>
          <IconButton
            onClick={() => onChange({ trainingDaysPerWeek: Math.min(7, draft.trainingDaysPerWeek + 1) })}
            disabled={draft.trainingDaysPerWeek >= 7}
            sx={{ color: 'primary.main' }}
          >
            <AddIcon />
          </IconButton>
        </Box>
      </Box>
    </OnboardingStep>
  );
}

// ─── Screen 3: Select Your Gym ────────────────────────────────────────────────

function SelectGymScreen({
  selectedGymIds,
  onToggleGym,
  onNext,
  onBack,
  onSkip,
}: {
  selectedGymIds: Set<string>;
  onToggleGym: (id: string) => void;
  onNext: () => void;
  onBack: () => void;
  onSkip: () => void;
}) {
  const [search, setSearch] = useState('');
  const debouncedSearch = useDebounce(search, 300);
  const { data: gyms = [], isLoading } = useGyms(debouncedSearch || undefined);

  return (
    <OnboardingStep
      totalSteps={TOTAL_STEPS}
      currentStep={2}
      onNext={onNext}
      onBack={onBack}
      onSkip={onSkip}
      nextLabel="Continue"
    >
      <Box>
        <Typography variant="h5" sx={{ fontWeight: 700, mb: 0.5, color: 'text.primary' }}>
          Select Your Gym
        </Typography>
        <Typography variant="body2" sx={{ color: 'text.secondary', mb: 2 }}>
          Optional — we'll show you machines at your gym.
        </Typography>

        <TextField
          placeholder="Search by name or city…"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          fullWidth
          size="small"
          sx={{ mb: 2 }}
          inputProps={{ 'aria-label': 'Search gyms' }}
        />

        {isLoading ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', py: 4 }}>
            <CircularProgress size={32} />
          </Box>
        ) : gyms.length === 0 ? (
          <Typography variant="body2" sx={{ color: 'text.secondary', textAlign: 'center', py: 4 }}>
            No gyms found. Try a different search.
          </Typography>
        ) : (
          <Stack spacing={1} sx={{ maxHeight: '40vh', overflowY: 'auto' }}>
            {gyms.map((gym) => {
              const selected = selectedGymIds.has(gym.id);
              return (
                <Card
                  key={gym.id}
                  sx={{
                    border: selected ? '2px solid' : '1px solid',
                    borderColor: selected ? 'primary.main' : 'rgba(202, 196, 208, 0.12)',
                    backgroundColor: selected ? 'rgba(46, 117, 182, 0.08)' : 'background.paper',
                    transition: 'border-color 0.2s, background-color 0.2s',
                  }}
                >
                  <CardActionArea onClick={() => onToggleGym(gym.id)} sx={{ px: 2, py: 1.5 }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                      <Box>
                        <Typography variant="body1" sx={{ fontWeight: 600, color: 'text.primary' }}>
                          {gym.name}
                        </Typography>
                        <Typography variant="caption" sx={{ color: 'text.secondary' }}>
                          {gym.city} · {gym.machine_count} machines
                        </Typography>
                      </Box>
                      {selected && <CheckCircleIcon sx={{ color: 'primary.main', ml: 1 }} />}
                    </Box>
                  </CardActionArea>
                </Card>
              );
            })}
          </Stack>
        )}
      </Box>
    </OnboardingStep>
  );
}

// ─── Screen 4: First Machine ─────────────────────────────────────────────────

function FirstMachineScreen({
  onCamera,
  onBack,
  onSkip,
}: {
  onCamera: () => void;
  onBack: () => void;
  onSkip: () => void;
}) {
  return (
    <OnboardingStep
      totalSteps={TOTAL_STEPS}
      currentStep={3}
      onNext={onCamera}
      onBack={onBack}
      onSkip={onSkip}
      nextLabel="Open Camera"
    >
      <Box sx={{ textAlign: 'center' }}>
        <Box
          sx={{
            width: 80,
            height: 80,
            borderRadius: '50%',
            backgroundColor: 'rgba(46, 117, 182, 0.15)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            mx: 'auto',
            mb: 3,
          }}
        >
          <CameraAltIcon sx={{ fontSize: 40, color: 'primary.main' }} />
        </Box>
        <Typography variant="h5" sx={{ fontWeight: 700, mb: 1, color: 'text.primary' }}>
          Add Your First Machine
        </Typography>
        <Typography variant="body1" sx={{ color: 'text.secondary', lineHeight: 1.6 }}>
          Photograph a machine to get started instantly. Our AI will identify it and set it up for you.
        </Typography>
      </Box>
    </OnboardingStep>
  );
}

// ─── Screen 5: Ready ─────────────────────────────────────────────────────────

function ReadyScreen({ onStart, isSaving }: { onStart: () => void; isSaving: boolean }) {
  return (
    <OnboardingStep
      totalSteps={TOTAL_STEPS}
      currentStep={4}
      onNext={onStart}
      nextLabel={isSaving ? 'Setting up…' : 'Start Logging'}
      nextDisabled={isSaving}
      hideBack
    >
      <Box sx={{ textAlign: 'center' }}>
        <Box
          sx={{
            width: 96,
            height: 96,
            borderRadius: '50%',
            backgroundColor: 'rgba(46, 117, 182, 0.15)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            mx: 'auto',
            mb: 4,
            '@keyframes pulse': {
              '0%': { transform: 'scale(1)', boxShadow: '0 0 0 0 rgba(46, 117, 182, 0.4)' },
              '70%': { transform: 'scale(1.05)', boxShadow: '0 0 0 16px rgba(46, 117, 182, 0)' },
              '100%': { transform: 'scale(1)', boxShadow: '0 0 0 0 rgba(46, 117, 182, 0)' },
            },
            animation: 'pulse 2s infinite',
          }}
        >
          <FitnessCenterIcon sx={{ fontSize: 52, color: 'primary.main' }} />
        </Box>
        <Typography variant="h4" sx={{ fontWeight: 800, letterSpacing: '-0.02em', mb: 1.5, color: 'text.primary' }}>
          You're all set. Let's lift.
        </Typography>
        <Typography variant="body1" sx={{ color: 'text.secondary' }}>
          Your profile is ready. Start logging your first workout.
        </Typography>
      </Box>
    </OnboardingStep>
  );
}

// ─── Main OnboardingPage ──────────────────────────────────────────────────────

export function OnboardingPage() {
  const navigate = useNavigate();
  const updateProfile = useUpdateProfile();
  const joinGym = useJoinGym();

  const [step, setStep] = useState(() => {
    const saved = sessionStorage.getItem('onboarding-step');
    return saved ? parseInt(saved, 10) : 0;
  });
  const [isSaving, setIsSaving] = useState(false);

  useEffect(() => {
    sessionStorage.setItem('onboarding-step', String(step));
  }, [step]);

  const [profileDraft, setProfileDraft] = useState<ProfileDraft>({
    experienceLevel: null,
    primaryGoal: null,
    preferredWeightUnit: 'kg',
    trainingDaysPerWeek: 3,
  });

  const [selectedGymIds, setSelectedGymIds] = useState<Set<string>>(new Set());

  const handleProfileChange = useCallback((updates: Partial<ProfileDraft>) => {
    setProfileDraft((prev) => ({ ...prev, ...updates }));
  }, []);

  const handleToggleGym = useCallback((gymId: string) => {
    setSelectedGymIds((prev) => {
      const next = new Set(prev);
      if (next.has(gymId)) {
        next.delete(gymId);
      } else {
        next.add(gymId);
      }
      return next;
    });
  }, []);

  const handleCamera = useCallback(() => {
    // Navigate to machine identify, then come back / continue onboarding
    void navigate({ to: '/log/identify' });
  }, [navigate]);

  const handleFinish = useCallback(async () => {
    setIsSaving(true);
    try {
      // Save profile
      await updateProfile.mutateAsync({
        experience_level: profileDraft.experienceLevel,
        primary_goal: profileDraft.primaryGoal,
        preferred_weight_unit: profileDraft.preferredWeightUnit,
        training_days_per_week: profileDraft.trainingDaysPerWeek,
        onboarding_completed: true,
      });

      // Join selected gyms in parallel
      if (selectedGymIds.size > 0) {
        await Promise.allSettled(
          Array.from(selectedGymIds).map((gymId) => joinGym.mutateAsync(gymId)),
        );
      }

      sessionStorage.removeItem('onboarding-step');
      void navigate({ to: '/log' });
    } catch (_err) {
      // Even on error, navigate to app — don't block the user
      sessionStorage.removeItem('onboarding-step');
      void navigate({ to: '/log' });
    } finally {
      setIsSaving(false);
    }
  }, [updateProfile, joinGym, profileDraft, selectedGymIds, navigate]);

  const next = () => setStep((s) => s + 1);
  const back = () => setStep((s) => s - 1);

  return (
    <>
      {step === 0 && <WelcomeScreen onNext={next} />}
      {step === 1 && (
        <ProfileSetupScreen
          draft={profileDraft}
          onChange={handleProfileChange}
          onNext={next}
          onBack={back}
        />
      )}
      {step === 2 && (
        <SelectGymScreen
          selectedGymIds={selectedGymIds}
          onToggleGym={handleToggleGym}
          onNext={next}
          onBack={back}
          onSkip={next}
        />
      )}
      {step === 3 && (
        <FirstMachineScreen
          onCamera={handleCamera}
          onBack={back}
          onSkip={next}
        />
      )}
      {step === 4 && (
        <ReadyScreen
          onStart={() => void handleFinish()}
          isSaving={isSaving}
        />
      )}
    </>
  );
}
