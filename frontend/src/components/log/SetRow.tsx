import { useState, useCallback } from 'react';
import Box from '@mui/material/Box';
import IconButton from '@mui/material/IconButton';
import Typography from '@mui/material/Typography';
import Chip from '@mui/material/Chip';
import Button from '@mui/material/Button';
import TextField from '@mui/material/TextField';
import Snackbar from '@mui/material/Snackbar';
import DeleteIcon from '@mui/icons-material/Delete';
import StarIcon from '@mui/icons-material/Star';
import AddIcon from '@mui/icons-material/Add';
import RemoveIcon from '@mui/icons-material/Remove';
import CheckIcon from '@mui/icons-material/Check';
import CloseIcon from '@mui/icons-material/Close';
import { useSwipeToDelete, triggerHaptic } from '@/hooks/useSwipeToDelete';
import type { WorkoutSet } from '@/types/database';

interface SetRowProps {
  set: WorkoutSet;
  setNumber: number;
  onDelete: (setId: string) => void;
  onUpdate?: (setId: string, updates: { weight: number; reps: number }) => void;
  isPR?: boolean;
  isEditable?: boolean;
}

const SET_TYPE_LABELS: Record<string, string> = {
  warmup: 'Warm-up',
  dropset: 'Drop Set',
  amrap: 'AMRAP',
  failure: 'To Failure',
};

const UNDO_TIMEOUT_MS = 5000;

export function SetRow({
  set,
  setNumber,
  onDelete,
  onUpdate,
  isPR = false,
  isEditable = false,
}: SetRowProps) {
  const showSetTypeChip = set.set_type !== 'working';

  // --- Swipe-to-delete with undo ---
  const [pendingDelete, setPendingDelete] = useState(false);
  const [showUndo, setShowUndo] = useState(false);
  const [undoTimer, setUndoTimer] = useState<ReturnType<typeof setTimeout> | null>(null);

  const handleSwipeDelete = useCallback(() => {
    triggerHaptic();
    setPendingDelete(true);
    setShowUndo(true);

    const timer = setTimeout(() => {
      onDelete(set.id);
      setShowUndo(false);
      setPendingDelete(false);
    }, UNDO_TIMEOUT_MS);

    setUndoTimer(timer);
  }, [onDelete, set.id]);

  const handleUndo = useCallback(() => {
    if (undoTimer) clearTimeout(undoTimer);
    setPendingDelete(false);
    setShowUndo(false);
  }, [undoTimer]);

  const handleUndoClose = useCallback(() => {
    setShowUndo(false);
  }, []);

  const swipeHandlers = useSwipeToDelete(handleSwipeDelete);

  // --- Inline editing ---
  const [isEditing, setIsEditing] = useState(false);
  const [editWeight, setEditWeight] = useState(set.weight);
  const [editReps, setEditReps] = useState(set.reps);

  const startEditing = useCallback(() => {
    if (!isEditable) return;
    setEditWeight(set.weight);
    setEditReps(set.reps);
    setIsEditing(true);
  }, [isEditable, set.weight, set.reps]);

  const handleSave = useCallback(() => {
    if (onUpdate && (editWeight !== set.weight || editReps !== set.reps)) {
      onUpdate(set.id, { weight: editWeight, reps: editReps });
    }
    setIsEditing(false);
  }, [onUpdate, set.id, set.weight, set.reps, editWeight, editReps]);

  const handleCancel = useCallback(() => {
    setEditWeight(set.weight);
    setEditReps(set.reps);
    setIsEditing(false);
  }, [set.weight, set.reps]);

  // Don't render if pending delete (undo snackbar still visible)
  if (pendingDelete) {
    return (
      <Snackbar
        open={showUndo}
        autoHideDuration={UNDO_TIMEOUT_MS}
        onClose={handleUndoClose}
        message="Set deleted"
        action={
          <Button color="primary" size="small" onClick={handleUndo}>
            Undo
          </Button>
        }
        sx={{ bottom: 96 }}
      />
    );
  }

  return (
    <>
      <Box
        {...(isEditing ? {} : swipeHandlers)}
        onClick={isEditing ? undefined : startEditing}
        role={isEditable && !isEditing ? 'button' : undefined}
        tabIndex={isEditable && !isEditing ? 0 : undefined}
        aria-label={isEditable && !isEditing ? `Edit set ${setNumber}` : undefined}
        sx={{
          display: 'flex',
          alignItems: 'center',
          px: 2,
          py: 1.25,
          gap: 1.5,
          borderBottom: '1px solid rgba(202, 196, 208, 0.06)',
          '&:last-child': { borderBottom: 'none' },
          cursor: isEditable && !isEditing ? 'pointer' : 'default',
          position: 'relative',
          ...swipeHandlers.style,
        }}
      >
        {/* Set number badge OR Save/Cancel in edit mode */}
        {isEditing ? (
          <Box sx={{ display: 'flex', gap: 0.5, flexShrink: 0 }}>
            <IconButton
              size="small"
              onClick={(e) => {
                e.stopPropagation();
                handleSave();
              }}
              sx={{ color: 'success.main', minWidth: 32, minHeight: 32 }}
              aria-label="Save edit"
            >
              <CheckIcon fontSize="small" />
            </IconButton>
            <IconButton
              size="small"
              onClick={(e) => {
                e.stopPropagation();
                handleCancel();
              }}
              sx={{ color: 'text.disabled', minWidth: 32, minHeight: 32 }}
              aria-label="Cancel edit"
            >
              <CloseIcon fontSize="small" />
            </IconButton>
          </Box>
        ) : (
          <Box
            sx={{
              width: 28,
              height: 28,
              borderRadius: '50%',
              backgroundColor: 'rgba(168, 199, 250, 0.12)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              flexShrink: 0,
            }}
          >
            <Typography
              variant="caption"
              sx={{ color: 'primary.main', fontWeight: 600, lineHeight: 1 }}
            >
              {setNumber}
            </Typography>
          </Box>
        )}

        {/* Weight × Reps OR editable fields */}
        <Box sx={{ flex: 1, display: 'flex', alignItems: 'center', gap: 1, flexWrap: 'wrap' }}>
          {isEditing ? (
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
              <IconButton
                size="small"
                onClick={(e) => {
                  e.stopPropagation();
                  setEditWeight((w) => Math.max(0, w - 2.5));
                }}
                sx={{ minWidth: 32, minHeight: 32 }}
                aria-label="Decrease weight"
              >
                <RemoveIcon fontSize="small" />
              </IconButton>
              <TextField
                value={editWeight}
                onChange={(e) => setEditWeight(Number(e.target.value) || 0)}
                type="number"
                size="small"
                slotProps={{ htmlInput: { min: 0, step: 2.5, style: { textAlign: 'center', width: 56, padding: '4px' } } }}
                onClick={(e) => e.stopPropagation()}
              />
              <IconButton
                size="small"
                onClick={(e) => {
                  e.stopPropagation();
                  setEditWeight((w) => w + 2.5);
                }}
                sx={{ minWidth: 32, minHeight: 32 }}
                aria-label="Increase weight"
              >
                <AddIcon fontSize="small" />
              </IconButton>

              <Typography variant="body2" sx={{ mx: 0.5, color: 'text.secondary' }}>
                ×
              </Typography>

              <IconButton
                size="small"
                onClick={(e) => {
                  e.stopPropagation();
                  setEditReps((r) => Math.max(1, r - 1));
                }}
                sx={{ minWidth: 32, minHeight: 32 }}
                aria-label="Decrease reps"
              >
                <RemoveIcon fontSize="small" />
              </IconButton>
              <TextField
                value={editReps}
                onChange={(e) => setEditReps(Math.max(1, Number(e.target.value) || 1))}
                type="number"
                size="small"
                slotProps={{ htmlInput: { min: 1, step: 1, style: { textAlign: 'center', width: 40, padding: '4px' } } }}
                onClick={(e) => e.stopPropagation()}
              />
              <IconButton
                size="small"
                onClick={(e) => {
                  e.stopPropagation();
                  setEditReps((r) => r + 1);
                }}
                sx={{ minWidth: 32, minHeight: 32 }}
                aria-label="Increase reps"
              >
                <AddIcon fontSize="small" />
              </IconButton>
            </Box>
          ) : (
            <>
              <Typography variant="body2" sx={{ color: 'text.primary', fontWeight: 500 }}>
                {set.weight} {set.weight_unit} × {set.reps}
              </Typography>

              {/* RPE badge */}
              {set.rpe !== null && (
                <Chip
                  label={`RPE ${set.rpe}`}
                  size="small"
                  sx={{
                    height: 20,
                    fontSize: '0.7rem',
                    backgroundColor: 'rgba(168, 199, 250, 0.1)',
                    color: 'primary.light',
                    '& .MuiChip-label': { px: 0.75 },
                  }}
                />
              )}

              {/* Set type chip (not shown for 'working') */}
              {showSetTypeChip && (
                <Chip
                  label={SET_TYPE_LABELS[set.set_type] ?? set.set_type}
                  size="small"
                  sx={{
                    height: 20,
                    fontSize: '0.7rem',
                    backgroundColor: 'rgba(249, 168, 37, 0.1)',
                    color: 'warning.main',
                    '& .MuiChip-label': { px: 0.75 },
                  }}
                />
              )}
            </>
          )}
        </Box>

        {/* PR badge */}
        {isPR && !isEditing && (
          <StarIcon sx={{ fontSize: 18, color: '#FFD700', flexShrink: 0 }} aria-label="Personal Record" />
        )}

        {/* Delete button (fallback for non-swipe devices) */}
        {!isEditing && (
          <IconButton
            size="medium"
            onClick={(e) => {
              e.stopPropagation();
              handleSwipeDelete();
            }}
            aria-label={`Delete set ${setNumber}`}
            sx={{
              color: 'text.disabled',
              flexShrink: 0,
              minWidth: 44,
              minHeight: 44,
              '&:hover': { color: 'error.main', backgroundColor: 'rgba(255, 180, 171, 0.08)' },
            }}
          >
            <DeleteIcon fontSize="small" />
          </IconButton>
        )}
      </Box>
    </>
  );
}
