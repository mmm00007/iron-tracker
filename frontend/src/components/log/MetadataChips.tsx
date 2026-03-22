import { useState, useRef } from 'react';
import Box from '@mui/material/Box';
import Chip from '@mui/material/Chip';
import Popover from '@mui/material/Popover';
import TextField from '@mui/material/TextField';
import ToggleButton from '@mui/material/ToggleButton';
import ToggleButtonGroup from '@mui/material/ToggleButtonGroup';
import Typography from '@mui/material/Typography';
import { useWorkoutStore } from '@/stores/workoutStore';

type SetType = 'warmup' | 'working' | 'dropset' | 'amrap' | 'failure';

const SET_TYPE_OPTIONS: Array<{ value: SetType; label: string }> = [
  { value: 'working', label: 'Working' },
  { value: 'warmup', label: 'Warm-up' },
  { value: 'dropset', label: 'Drop Set' },
  { value: 'amrap', label: 'AMRAP' },
  { value: 'failure', label: 'Failure' },
];

const RPE_OPTIONS = [6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10];

export function MetadataChips() {
  const { currentRpe, currentSetType, currentNotes, setRpe, setSetType, setNotes } =
    useWorkoutStore();

  // RPE popover
  const rpeRef = useRef<HTMLDivElement>(null);
  const [rpeOpen, setRpeOpen] = useState(false);

  // Set type popover
  const setTypeRef = useRef<HTMLDivElement>(null);
  const [setTypeOpen, setSetTypeOpen] = useState(false);

  // Notes expanded inline
  const [notesOpen, setNotesOpen] = useState(false);

  const rpeLabel = currentRpe !== null ? `RPE ${currentRpe}` : 'RPE';
  const setTypeLabel =
    currentSetType !== 'working'
      ? (SET_TYPE_OPTIONS.find((o) => o.value === currentSetType)?.label ?? currentSetType)
      : 'Set Type';
  const notesLabel =
    currentNotes.length > 0
      ? currentNotes.length > 16
        ? currentNotes.slice(0, 16) + '…'
        : currentNotes
      : 'Notes';

  return (
    <Box>
      {/* Chips row */}
      <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
        {/* RPE chip */}
        <div ref={rpeRef}>
          <Chip
            label={rpeLabel}
            onClick={() => setRpeOpen(true)}
            variant={currentRpe !== null ? 'filled' : 'outlined'}
            size="small"
            sx={{
              height: 32,
              ...(currentRpe !== null
                ? {
                    backgroundColor: 'rgba(168, 199, 250, 0.15)',
                    color: 'primary.light',
                    border: '1px solid rgba(168, 199, 250, 0.3)',
                  }
                : {
                    borderColor: 'rgba(202, 196, 208, 0.3)',
                    color: 'text.secondary',
                  }),
            }}
          />
        </div>

        {/* Set type chip */}
        <div ref={setTypeRef}>
          <Chip
            label={setTypeLabel}
            onClick={() => setSetTypeOpen(true)}
            variant={currentSetType !== 'working' ? 'filled' : 'outlined'}
            size="small"
            sx={{
              height: 32,
              ...(currentSetType !== 'working'
                ? {
                    backgroundColor: 'rgba(249, 168, 37, 0.12)',
                    color: 'warning.main',
                    border: '1px solid rgba(249, 168, 37, 0.3)',
                  }
                : {
                    borderColor: 'rgba(202, 196, 208, 0.3)',
                    color: 'text.secondary',
                  }),
            }}
          />
        </div>

        {/* Notes chip */}
        <Chip
          label={notesLabel}
          onClick={() => setNotesOpen((v) => !v)}
          variant={currentNotes.length > 0 ? 'filled' : 'outlined'}
          size="small"
          sx={{
            height: 32,
            ...(currentNotes.length > 0
              ? {
                  backgroundColor: 'rgba(102, 187, 106, 0.12)',
                  color: 'success.light',
                  border: '1px solid rgba(102, 187, 106, 0.3)',
                }
              : {
                  borderColor: 'rgba(202, 196, 208, 0.3)',
                  color: 'text.secondary',
                }),
          }}
        />
      </Box>

      {/* Notes inline text field */}
      {notesOpen && (
        <Box sx={{ mt: 1.5 }}>
          <TextField
            fullWidth
            size="small"
            placeholder="Add a note for this set…"
            value={currentNotes}
            onChange={(e) => setNotes(e.target.value)}
            multiline
            maxRows={3}
            autoFocus
            sx={{
              '& .MuiOutlinedInput-root': {
                backgroundColor: 'rgba(202, 196, 208, 0.04)',
              },
            }}
          />
        </Box>
      )}

      {/* RPE Popover */}
      <Popover
        open={rpeOpen}
        anchorEl={rpeRef.current}
        onClose={() => setRpeOpen(false)}
        anchorOrigin={{ vertical: 'bottom', horizontal: 'left' }}
        transformOrigin={{ vertical: 'top', horizontal: 'left' }}
        PaperProps={{
          sx: {
            p: 2,
            backgroundColor: '#2A2A3E',
            border: '1px solid rgba(202, 196, 208, 0.12)',
            borderRadius: '16px',
          },
        }}
      >
        <Typography variant="caption" sx={{ color: 'text.secondary', mb: 1.5, display: 'block' }}>
          Rate of Perceived Exertion
        </Typography>
        <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.75, maxWidth: 240 }}>
          {/* Clear option */}
          <Chip
            label="—"
            size="small"
            onClick={() => { setRpe(null); setRpeOpen(false); }}
            variant={currentRpe === null ? 'filled' : 'outlined'}
            sx={{
              minWidth: 42,
              ...(currentRpe === null
                ? { backgroundColor: 'primary.main', color: 'primary.contrastText' }
                : { borderColor: 'rgba(202, 196, 208, 0.3)', color: 'text.secondary' }),
            }}
          />
          {RPE_OPTIONS.map((rpe) => (
            <Chip
              key={rpe}
              label={rpe}
              size="small"
              onClick={() => { setRpe(rpe); setRpeOpen(false); }}
              variant={currentRpe === rpe ? 'filled' : 'outlined'}
              sx={{
                minWidth: 42,
                ...(currentRpe === rpe
                  ? { backgroundColor: 'primary.main', color: 'primary.contrastText' }
                  : { borderColor: 'rgba(202, 196, 208, 0.3)', color: 'text.secondary' }),
              }}
            />
          ))}
        </Box>
      </Popover>

      {/* Set type popover */}
      <Popover
        open={setTypeOpen}
        anchorEl={setTypeRef.current}
        onClose={() => setSetTypeOpen(false)}
        anchorOrigin={{ vertical: 'bottom', horizontal: 'left' }}
        transformOrigin={{ vertical: 'top', horizontal: 'left' }}
        PaperProps={{
          sx: {
            p: 2,
            backgroundColor: '#2A2A3E',
            border: '1px solid rgba(202, 196, 208, 0.12)',
            borderRadius: '16px',
          },
        }}
      >
        <Typography variant="caption" sx={{ color: 'text.secondary', mb: 1.5, display: 'block' }}>
          Set Type
        </Typography>
        <ToggleButtonGroup
          exclusive
          orientation="vertical"
          value={currentSetType}
          onChange={(_e, val) => {
            if (val) {
              setSetType(val as SetType);
              setSetTypeOpen(false);
            }
          }}
          sx={{ width: '100%' }}
        >
          {SET_TYPE_OPTIONS.map((opt) => (
            <ToggleButton
              key={opt.value}
              value={opt.value}
              sx={{
                textTransform: 'none',
                justifyContent: 'flex-start',
                px: 2,
                py: 1,
                fontSize: '0.875rem',
                color: 'text.secondary',
                border: 'none',
                borderRadius: '8px !important',
                '&.Mui-selected': {
                  color: 'primary.main',
                  backgroundColor: 'rgba(168, 199, 250, 0.12)',
                },
              }}
            >
              {opt.label}
            </ToggleButton>
          ))}
        </ToggleButtonGroup>
      </Popover>
    </Box>
  );
}
