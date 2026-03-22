import { useState, useEffect } from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Chip from '@mui/material/Chip';
import Drawer from '@mui/material/Drawer';
import IconButton from '@mui/material/IconButton';
import Typography from '@mui/material/Typography';
import BackspaceIcon from '@mui/icons-material/BackspaceOutlined';

interface NumpadBottomSheetProps {
  open: boolean;
  onClose: () => void;
  label: 'Weight (kg)' | 'Weight (lb)' | 'Reps';
  initialValue: number;
  onApply: (value: number) => void;
  /** Recent unique values for quick-select */
  recentValues?: number[];
  allowDecimal?: boolean;
}

export function NumpadBottomSheet({
  open,
  onClose,
  label,
  initialValue,
  onApply,
  recentValues = [],
  allowDecimal = false,
}: NumpadBottomSheetProps) {
  const [display, setDisplay] = useState(String(initialValue));

  // Sync display when sheet opens
  useEffect(() => {
    if (open) {
      setDisplay(String(initialValue));
    }
  }, [open, initialValue]);

  const handleDigit = (digit: string) => {
    setDisplay((prev) => {
      // Prevent multiple decimals
      if (digit === '.' && prev.includes('.')) return prev;
      // Prevent leading zeros (except "0.")
      if (prev === '0' && digit !== '.') return digit;
      // Max length guard
      if (prev.length >= 6) return prev;
      return prev + digit;
    });
  };

  const handleBackspace = () => {
    setDisplay((prev) => (prev.length > 1 ? prev.slice(0, -1) : '0'));
  };

  const handleDone = () => {
    const parsed = parseFloat(display);
    if (!isNaN(parsed) && parsed >= 0) {
      onApply(parsed);
    }
    onClose();
  };

  const handleQuickSelect = (value: number) => {
    setDisplay(String(value));
  };

  const numpadRows = [
    ['7', '8', '9'],
    ['4', '5', '6'],
    ['1', '2', '3'],
    [allowDecimal ? '.' : '', '0', 'back'],
  ];

  return (
    <Drawer
      anchor="bottom"
      open={open}
      onClose={onClose}
      PaperProps={{
        sx: {
          borderTopLeftRadius: 24,
          borderTopRightRadius: 24,
          backgroundColor: '#1E1E2E',
          pb: 'env(safe-area-inset-bottom)',
          maxWidth: 480,
          mx: 'auto',
          left: 0,
          right: 0,
        },
      }}
    >
      {/* Drag handle */}
      <Box sx={{ display: 'flex', justifyContent: 'center', pt: 1.5, pb: 0.5 }}>
        <Box
          sx={{
            width: 36,
            height: 4,
            borderRadius: 2,
            backgroundColor: 'rgba(202, 196, 208, 0.3)',
          }}
        />
      </Box>

      {/* Display area */}
      <Box sx={{ px: 3, pt: 1.5, pb: 1 }}>
        <Typography variant="caption" sx={{ color: 'text.secondary', letterSpacing: '0.07em' }}>
          {label.toUpperCase()}
        </Typography>
        <Typography
          variant="h2"
          sx={{
            color: 'text.primary',
            fontWeight: 700,
            textAlign: 'center',
            mt: 0.5,
            letterSpacing: '-0.02em',
          }}
        >
          {display}
        </Typography>
      </Box>

      {/* Quick-select recent values */}
      {recentValues.length > 0 && (
        <Box
          sx={{
            display: 'flex',
            gap: 1,
            px: 2,
            pb: 1.5,
            overflowX: 'auto',
            scrollbarWidth: 'none',
            '&::-webkit-scrollbar': { display: 'none' },
          }}
        >
          {recentValues.slice(0, 4).map((val) => (
            <Chip
              key={val}
              label={val}
              onClick={() => handleQuickSelect(val)}
              variant={display === String(val) ? 'filled' : 'outlined'}
              sx={{
                flexShrink: 0,
                fontWeight: 600,
                ...(display === String(val)
                  ? { backgroundColor: 'primary.main', color: 'primary.contrastText' }
                  : { borderColor: 'rgba(202, 196, 208, 0.3)', color: 'text.secondary' }),
              }}
            />
          ))}
        </Box>
      )}

      {/* Numpad */}
      <Box sx={{ px: 2, pb: 2 }}>
        {numpadRows.map((row, rowIdx) => (
          <Box
            key={rowIdx}
            sx={{ display: 'flex', gap: 1, mb: rowIdx < numpadRows.length - 1 ? 1 : 0 }}
          >
            {row.map((key, keyIdx) => {
              if (key === 'back') {
                return (
                  <IconButton
                    key={keyIdx}
                    onClick={handleBackspace}
                    sx={{
                      flex: 1,
                      height: 56,
                      borderRadius: '12px',
                      backgroundColor: 'rgba(202, 196, 208, 0.06)',
                      color: 'text.secondary',
                      '&:hover': { backgroundColor: 'rgba(202, 196, 208, 0.12)' },
                    }}
                    aria-label="Backspace"
                  >
                    <BackspaceIcon />
                  </IconButton>
                );
              }

              if (key === '') {
                return (
                  <Box key={keyIdx} sx={{ flex: 1, height: 56 }} />
                );
              }

              return (
                <Button
                  key={keyIdx}
                  onClick={() => handleDigit(key)}
                  sx={{
                    flex: 1,
                    height: 56,
                    borderRadius: '12px',
                    backgroundColor: 'rgba(202, 196, 208, 0.06)',
                    color: 'text.primary',
                    fontSize: '1.25rem',
                    fontWeight: 500,
                    minWidth: 0,
                    '&:hover': { backgroundColor: 'rgba(202, 196, 208, 0.12)' },
                  }}
                >
                  {key}
                </Button>
              );
            })}
          </Box>
        ))}

        {/* Done button */}
        <Button
          variant="contained"
          fullWidth
          onClick={handleDone}
          sx={{ mt: 1.5, height: 56, fontSize: '1rem', fontWeight: 600 }}
        >
          Done
        </Button>
      </Box>
    </Drawer>
  );
}
