import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Stack from '@mui/material/Stack';

interface OnboardingStepProps {
  children: React.ReactNode;
  totalSteps: number;
  currentStep: number;
  onNext?: () => void;
  onBack?: () => void;
  onSkip?: () => void;
  nextLabel?: string;
  nextDisabled?: boolean;
  hideBack?: boolean;
}

export function OnboardingStep({
  children,
  totalSteps,
  currentStep,
  onNext,
  onBack,
  onSkip,
  nextLabel = 'Next',
  nextDisabled = false,
  hideBack = false,
}: OnboardingStepProps) {
  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'column',
        minHeight: '100dvh',
        backgroundColor: 'background.default',
        px: 3,
        pt: 6,
        pb: 4,
      }}
    >
      {/* Main content — grows to fill available space */}
      <Box sx={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center' }}>
        {children}
      </Box>

      {/* Dot indicators */}
      <Box sx={{ display: 'flex', justifyContent: 'center', gap: 1, mb: 3 }}>
        {Array.from({ length: totalSteps }).map((_, i) => (
          <Box
            key={i}
            sx={{
              width: i === currentStep ? 20 : 8,
              height: 8,
              borderRadius: '100px',
              backgroundColor: i === currentStep ? 'primary.main' : 'rgba(202, 196, 208, 0.24)',
              transition: 'width 0.3s ease, background-color 0.3s ease',
            }}
          />
        ))}
      </Box>

      {/* Navigation buttons */}
      <Stack spacing={1.5}>
        {onNext && (
          <Button
            variant="contained"
            size="large"
            onClick={onNext}
            disabled={nextDisabled}
            fullWidth
            sx={{
              borderRadius: '100px',
              py: 1.5,
              fontWeight: 600,
              fontSize: '1rem',
            }}
          >
            {nextLabel}
          </Button>
        )}
        <Stack direction="row" spacing={1} justifyContent="center">
          {!hideBack && onBack && (
            <Button
              variant="text"
              onClick={onBack}
              sx={{ color: 'text.secondary', flex: 1 }}
            >
              Back
            </Button>
          )}
          {onSkip && (
            <Button
              variant="text"
              onClick={onSkip}
              sx={{ color: 'text.secondary', flex: 1 }}
            >
              Skip
            </Button>
          )}
        </Stack>
      </Stack>
    </Box>
  );
}
