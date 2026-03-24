import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardActionArea from '@mui/material/CardActionArea';
import CardContent from '@mui/material/CardContent';
import Chip from '@mui/material/Chip';
import Typography from '@mui/material/Typography';
import EventNoteIcon from '@mui/icons-material/EventNote';
import { useNavigate } from '@tanstack/react-router';
import { useTodaysPlan, WEEKDAY_LABELS } from '@/hooks/usePlans';

export function TodaysPlanCard() {
  const navigate = useNavigate();
  const todaysPlan = useTodaysPlan();

  if (!todaysPlan) return null;

  const { plan, day } = todaysPlan;
  const dayLabel = day.label ?? WEEKDAY_LABELS[day.weekday];

  return (
    <Card
      sx={{
        border: '1px solid rgba(168, 199, 250, 0.2)',
        background: 'linear-gradient(135deg, rgba(168, 199, 250, 0.06) 0%, rgba(168, 199, 250, 0.02) 100%)',
      }}
    >
      <CardActionArea onClick={() => void navigate({ to: '/plans' })}>
        <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
            <EventNoteIcon sx={{ fontSize: 18, color: 'primary.main' }} />
            <Typography variant="caption" sx={{ color: 'primary.main', fontWeight: 600 }}>
              Today's Plan · {dayLabel}
            </Typography>
            <Chip label={plan.name} size="small" sx={{ height: 20, fontSize: '0.6rem' }} />
          </Box>
          <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5 }}>
            {day.items.map((item) => (
              <Chip
                key={item.id}
                label={`${item.exerciseName ?? 'Exercise'} ${item.target_sets}×${item.target_reps_min}-${item.target_reps_max}`}
                size="small"
                variant="outlined"
                sx={{ fontSize: '0.7rem', height: 22 }}
              />
            ))}
          </Box>
        </CardContent>
      </CardActionArea>
    </Card>
  );
}
