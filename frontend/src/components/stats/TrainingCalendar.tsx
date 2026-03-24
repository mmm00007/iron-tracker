import { useEffect, useMemo, useRef, useState } from 'react';
import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CircularProgress from '@mui/material/CircularProgress';
import Tooltip from '@mui/material/Tooltip';
import Typography from '@mui/material/Typography';
import { useTrainingFrequency } from '@/hooks/useAnalytics';
import type { DayActivity } from '@/utils/analytics';

// ─── Color scale ───────────────────────────────────────────────────────────────

function volumeToColor(volume: number, maxVolume: number): string {
  if (volume === 0 || maxVolume === 0) return '#2A2A3E'; // empty cell
  const ratio = Math.min(volume / maxVolume, 1);

  if (ratio < 0.25) return '#1A3A5C'; // low — dark blue
  if (ratio < 0.5) return '#1565C0';  // mid-low — blue
  if (ratio < 0.75) return '#2E7D32'; // mid-high — green
  return '#F9A825';                   // high — yellow
}

// ─── Build grid ───────────────────────────────────────────────────────────────

interface CalCell {
  date: string; // YYYY-MM-DD
  volume: number;
  setCount: number;
  dayOfWeek: number; // 0=Sun, 6=Sat
}

function buildCalendarGrid(activities: DayActivity[]): { cells: (CalCell | null)[][]; weeks: string[] } {
  const activityMap = new Map(activities.map((a) => [a.date, a]));

  // Start 12 weeks ago from today (Monday)
  const today = new Date();
  const todayStr = today.toISOString().slice(0, 10);

  // Find the Monday 12 weeks back
  const startDate = new Date(today);
  const dayOfWeek = today.getDay() || 7; // Monday = 1, Sunday = 7
  startDate.setDate(today.getDate() - dayOfWeek + 1 - 11 * 7); // back to Monday 12 weeks ago

  // Build 12 weeks × 7 days grid (row = week, col = day of week Mon–Sun)
  const weeks: string[] = [];
  const cells: (CalCell | null)[][] = [];

  for (let w = 0; w < 12; w++) {
    const week: (CalCell | null)[] = [];
    const weekStart = new Date(startDate);
    weekStart.setDate(startDate.getDate() + w * 7);
    weeks.push(weekStart.toISOString().slice(0, 10));

    for (let d = 0; d < 7; d++) {
      const date = new Date(weekStart);
      date.setDate(weekStart.getDate() + d);
      const dateStr = date.toISOString().slice(0, 10);

      if (dateStr > todayStr) {
        week.push(null); // future dates
        continue;
      }

      const activity = activityMap.get(dateStr);
      week.push({
        date: dateStr,
        volume: activity?.volume ?? 0,
        setCount: activity?.setCount ?? 0,
        dayOfWeek: d,
      });
    }
    cells.push(week);
  }

  return { cells, weeks };
}

const DAY_LABELS = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

// ─── Component ────────────────────────────────────────────────────────────────

export function TrainingCalendar() {
  const { data, isLoading, isError } = useTrainingFrequency();
  const [tooltip, setTooltip] = useState<{ date: string; volume: number; sets: number } | null>(null);
  const calendarRef = useRef<HTMLDivElement>(null);

  // Clear tooltip when tapping outside the calendar grid (touch devices)
  useEffect(() => {
    if (!tooltip) return;
    const handleOutsideClick = (e: MouseEvent | TouchEvent) => {
      if (calendarRef.current && !calendarRef.current.contains(e.target as Node)) {
        setTooltip(null);
      }
    };
    document.addEventListener('mousedown', handleOutsideClick);
    document.addEventListener('touchstart', handleOutsideClick);
    return () => {
      document.removeEventListener('mousedown', handleOutsideClick);
      document.removeEventListener('touchstart', handleOutsideClick);
    };
  }, [tooltip]);

  const { cells, maxVolume } = useMemo(() => {
    if (!data) return { cells: [], maxVolume: 0 };
    const { cells } = buildCalendarGrid(data);
    const maxVol = Math.max(...data.map((a) => a.volume), 1);
    return { cells, maxVolume: maxVol };
  }, [data]);

  return (
    <Card sx={{ mb: 2 }}>
      <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
        <Typography variant="overline" sx={{ color: 'text.secondary', display: 'block', mb: 1.5 }}>
          Training Calendar
        </Typography>

        {isLoading && (
          <Box sx={{ display: 'flex', justifyContent: 'center', py: 3 }}>
            <CircularProgress size={24} />
          </Box>
        )}

        {isError && (
          <Typography variant="body2" sx={{ color: 'error.main', textAlign: 'center', py: 2 }}>
            Failed to load calendar
          </Typography>
        )}

        {!isLoading && !isError && (
          <>
            {/* Day-of-week labels */}
            <Box
              sx={{
                display: 'grid',
                gridTemplateColumns: `repeat(7, 1fr)`,
                gap: '3px',
                mb: 0.5,
              }}
            >
              {DAY_LABELS.map((label, i) => (
                <Typography
                  key={i}
                  variant="caption"
                  sx={{
                    color: 'text.disabled',
                    textAlign: 'center',
                    fontSize: '0.6rem',
                    lineHeight: 1,
                  }}
                >
                  {label}
                </Typography>
              ))}
            </Box>

            {/* Calendar grid — rows = weeks, cols = days */}
            <Box
              ref={calendarRef}
              sx={{ display: 'flex', flexDirection: 'column', gap: '3px' }}
            >
              {cells.map((week, weekIdx) => (
                <Box
                  key={weekIdx}
                  sx={{
                    display: 'grid',
                    gridTemplateColumns: 'repeat(7, 1fr)',
                    gap: '3px',
                  }}
                >
                  {week.map((cell, dayIdx) => {
                    if (cell === null) {
                      return (
                        <Box
                          key={dayIdx}
                          sx={{
                            aspectRatio: '1',
                            borderRadius: '3px',
                            backgroundColor: 'transparent',
                          }}
                        />
                      );
                    }

                    const color = volumeToColor(cell.volume, maxVolume);
                    const isSelected = tooltip?.date === cell.date;

                    return (
                      <Tooltip
                        key={dayIdx}
                        title={
                          cell.volume > 0
                            ? `${cell.date}: ${cell.setCount} sets · ${Math.round(cell.volume)} vol`
                            : `${cell.date}: Rest day`
                        }
                        placement="top"
                        arrow
                      >
                        <Box
                          sx={{
                            aspectRatio: '1',
                            borderRadius: '3px',
                            backgroundColor: color,
                            cursor: cell.volume > 0 ? 'pointer' : 'default',
                            transition: 'transform 0.1s',
                            outline: isSelected ? '2px solid rgba(255,255,255,0.5)' : 'none',
                            '&:hover': cell.volume > 0
                              ? { transform: 'scale(1.2)', zIndex: 1 }
                              : {},
                          }}
                          onMouseEnter={() =>
                            cell.volume > 0 &&
                            setTooltip({ date: cell.date, volume: cell.volume, sets: cell.setCount })
                          }
                          onMouseLeave={() => setTooltip(null)}
                          onClick={() => {
                            if (cell.volume === 0) {
                              setTooltip(null);
                              return;
                            }
                            // Toggle off if same cell tapped again; otherwise show this cell
                            setTooltip(isSelected
                              ? null
                              : { date: cell.date, volume: cell.volume, sets: cell.setCount }
                            );
                          }}
                        />
                      </Tooltip>
                    );
                  })}
                </Box>
              ))}
            </Box>

            {/* Legend */}
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5, mt: 1.5, justifyContent: 'flex-end' }}>
              <Typography variant="caption" sx={{ color: 'text.disabled', fontSize: '0.6rem' }}>
                Less
              </Typography>
              {['#2A2A3E', '#1A3A5C', '#1565C0', '#2E7D32', '#F9A825'].map((color) => (
                <Box
                  key={color}
                  sx={{
                    width: 10,
                    height: 10,
                    borderRadius: '2px',
                    backgroundColor: color,
                  }}
                />
              ))}
              <Typography variant="caption" sx={{ color: 'text.disabled', fontSize: '0.6rem' }}>
                More
              </Typography>
            </Box>

            {/* Tooltip detail (mobile) */}
            {tooltip && (
              <Box
                sx={{
                  mt: 1,
                  p: 1,
                  borderRadius: '8px',
                  backgroundColor: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(202, 196, 208, 0.12)',
                }}
              >
                <Typography variant="caption" sx={{ color: 'text.primary' }}>
                  {tooltip.date} · {tooltip.sets} sets · {Math.round(tooltip.volume)} vol
                </Typography>
              </Box>
            )}

            {data && data.length === 0 && (
              <Typography variant="body2" sx={{ color: 'text.disabled', textAlign: 'center', py: 3 }}>
                No workouts in the last 12 weeks. Time to train!
              </Typography>
            )}
          </>
        )}
      </CardContent>
    </Card>
  );
}
