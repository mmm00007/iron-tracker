import { useEffect, useMemo, useRef, useState } from 'react';
import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CircularProgress from '@mui/material/CircularProgress';
import Tooltip from '@mui/material/Tooltip';
import Typography from '@mui/material/Typography';
import { useTrainingFrequency } from '@/hooks/useAnalytics';
import type { DayActivity } from '@/utils/analytics';
import { DATA_FONT, CHART_COLORS } from '@/theme';

// ─── Color scale (uses primary green gradient) ──────────────────────────────

function volumeToColor(volume: number, maxVolume: number): string {
  if (volume === 0 || maxVolume === 0) return 'rgba(160, 170, 184, 0.06)'; // empty cell
  const ratio = Math.min(volume / maxVolume, 1);

  if (ratio < 0.25) return `${CHART_COLORS.primary}25`;
  if (ratio < 0.5) return `${CHART_COLORS.primary}50`;
  if (ratio < 0.75) return `${CHART_COLORS.primary}90`;
  return CHART_COLORS.primary;
}

// ─── Build grid ──────────────────────────────────────────────────────────────

interface CalCell {
  date: string;
  volume: number;
  setCount: number;
  dayOfWeek: number;
}

function buildCalendarGrid(activities: DayActivity[]): { cells: (CalCell | null)[][] } {
  const activityMap = new Map(activities.map((a) => [a.date, a]));
  const today = new Date();
  const todayStr = today.toISOString().slice(0, 10);

  const startDate = new Date(today);
  const dayOfWeek = today.getDay() || 7;
  startDate.setDate(today.getDate() - dayOfWeek + 1 - 11 * 7);

  const cells: (CalCell | null)[][] = [];

  for (let w = 0; w < 12; w++) {
    const week: (CalCell | null)[] = [];
    const weekStart = new Date(startDate);
    weekStart.setDate(startDate.getDate() + w * 7);

    for (let d = 0; d < 7; d++) {
      const date = new Date(weekStart);
      date.setDate(weekStart.getDate() + d);
      const dateStr = date.toISOString().slice(0, 10);

      if (dateStr > todayStr) {
        week.push(null);
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

  return { cells };
}

const DAY_LABELS = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

// ─── Component ───────────────────────────────────────────────────────────────

export function TrainingCalendar() {
  const { data, isLoading, isError } = useTrainingFrequency();
  const [tooltip, setTooltip] = useState<{ date: string; volume: number; sets: number } | null>(null);
  const calendarRef = useRef<HTMLDivElement>(null);

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

  const { cells, maxVolume, totalDays } = useMemo(() => {
    if (!data) return { cells: [], maxVolume: 0, totalDays: 0 };
    const { cells } = buildCalendarGrid(data);
    const maxVol = Math.max(...data.map((a) => a.volume), 1);
    return { cells, maxVolume: maxVol, totalDays: data.length };
  }, [data]);

  return (
    <Card sx={{ mb: 2 }}>
      <CardContent sx={{ p: { xs: 1.5, md: 2 }, '&:last-child': { pb: { xs: 1.5, md: 2 } } }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 1.5 }}>
          <Typography variant="overline" sx={{ color: 'text.secondary' }}>
            Training Calendar
          </Typography>
          {totalDays > 0 && (
            <Typography
              sx={{
                fontFamily: DATA_FONT,
                fontSize: '0.6875rem',
                fontWeight: 700,
                color: CHART_COLORS.primary,
              }}
            >
              {totalDays} days
            </Typography>
          )}
        </Box>

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
                    fontSize: '0.55rem',
                    fontFamily: DATA_FONT,
                    lineHeight: 1,
                  }}
                >
                  {label}
                </Typography>
              ))}
            </Box>

            {/* Calendar grid */}
            <Box
              ref={calendarRef}
              sx={{
                display: 'flex',
                flexDirection: 'column',
                gap: { xs: '2px', md: '3px', lg: '4px' },
                maxWidth: { lg: 600 },
                mx: { lg: 'auto' },
              }}
            >
              {cells.map((week, weekIdx) => (
                <Box
                  key={weekIdx}
                  sx={{
                    display: 'grid',
                    gridTemplateColumns: 'repeat(7, 1fr)',
                    gap: { xs: '2px', md: '3px', lg: '4px' },
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
                            outline: isSelected ? `2px solid ${CHART_COLORS.primary}` : 'none',
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
              <Typography
                sx={{ color: 'text.disabled', fontSize: '0.55rem', fontFamily: DATA_FONT }}
              >
                Less
              </Typography>
              {[
                'rgba(160, 170, 184, 0.06)',
                `${CHART_COLORS.primary}25`,
                `${CHART_COLORS.primary}50`,
                `${CHART_COLORS.primary}90`,
                CHART_COLORS.primary,
              ].map((c) => (
                <Box
                  key={c}
                  sx={{
                    width: 10,
                    height: 10,
                    borderRadius: '2px',
                    backgroundColor: c,
                  }}
                />
              ))}
              <Typography
                sx={{ color: 'text.disabled', fontSize: '0.55rem', fontFamily: DATA_FONT }}
              >
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
                  backgroundColor: 'rgba(91, 234, 162, 0.04)',
                  border: `1px solid ${CHART_COLORS.primary}20`,
                }}
              >
                <Typography variant="caption" sx={{ color: 'text.primary' }}>
                  {tooltip.date} ·{' '}
                  <Box component="span" sx={{ fontFamily: DATA_FONT, fontWeight: 700 }}>
                    {tooltip.sets} sets
                  </Box>{' '}
                  ·{' '}
                  <Box component="span" sx={{ fontFamily: DATA_FONT, fontWeight: 700, color: CHART_COLORS.primary }}>
                    {Math.round(tooltip.volume)} vol
                  </Box>
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
