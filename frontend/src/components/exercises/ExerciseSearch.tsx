import { useState } from 'react';
import type { RefObject } from 'react';
import TextField from '@mui/material/TextField';
import InputAdornment from '@mui/material/InputAdornment';
import IconButton from '@mui/material/IconButton';
import SearchIcon from '@mui/icons-material/Search';
import ClearIcon from '@mui/icons-material/Clear';

interface ExerciseSearchProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  inputRef?: RefObject<HTMLInputElement>;
}

export function ExerciseSearch({
  value,
  onChange,
  placeholder = 'Search exercises...',
  inputRef,
}: ExerciseSearchProps) {
  const [focused, setFocused] = useState(false);

  return (
    <TextField
      fullWidth
      value={value}
      onChange={(e) => onChange(e.target.value)}
      placeholder={placeholder}
      onFocus={() => setFocused(true)}
      onBlur={() => setFocused(false)}
      inputRef={inputRef}
      size="small"
      InputProps={{
        startAdornment: (
          <InputAdornment position="start">
            <SearchIcon
              sx={{
                color: focused ? 'primary.main' : 'text.secondary',
                fontSize: 20,
                transition: 'color 0.2s',
              }}
            />
          </InputAdornment>
        ),
        endAdornment: value ? (
          <InputAdornment position="end">
            <IconButton
              size="medium"
              onClick={() => onChange('')}
              aria-label="Clear search"
              edge="end"
              sx={{ color: 'text.secondary', minWidth: 44, minHeight: 44 }}
            >
              <ClearIcon fontSize="small" />
            </IconButton>
          </InputAdornment>
        ) : null,
      }}
      sx={{
        '& .MuiOutlinedInput-root': {
          borderRadius: '28px', // MD3 search bar full pill
          backgroundColor: 'background.paper',
          '& fieldset': {
            borderColor: 'rgba(202, 196, 208, 0.38)',
          },
          '&:hover fieldset': {
            borderColor: 'primary.main',
          },
          '&.Mui-focused fieldset': {
            borderColor: 'primary.main',
          },
        },
        '& .MuiInputBase-input': {
          py: 1.25,
        },
      }}
    />
  );
}
