/**
 * Format a date as a relative label:
 *   - "Today"
 *   - "Yesterday"
 *   - "Monday, Feb 24"   (within the past week)
 *   - "Feb 24, 2025"     (older)
 */
export function formatRelativeDate(date: string | Date): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  const now = new Date();

  // Normalize to midnight in local time for day comparison
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const target = new Date(d.getFullYear(), d.getMonth(), d.getDate());
  const diffDays = Math.round((today.getTime() - target.getTime()) / (1000 * 60 * 60 * 24));

  if (diffDays === 0) return 'Today';
  if (diffDays === 1) return 'Yesterday';

  const weekday = d.toLocaleDateString('en-US', { weekday: 'long' });
  const monthDay = d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });

  if (diffDays < 7) {
    return `${weekday}, ${monthDay}`;
  }

  // Older than a week — include year if different
  if (d.getFullYear() !== now.getFullYear()) {
    return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  }

  return monthDay;
}

/**
 * Format a duration between two ISO strings.
 * Examples: "45 min", "1h 15min", "2h"
 */
export function formatDuration(startedAt: string, endedAt: string): string {
  const start = new Date(startedAt).getTime();
  const end = new Date(endedAt).getTime();
  const totalMinutes = Math.max(0, Math.round((end - start) / (1000 * 60)));

  if (totalMinutes < 60) return `${totalMinutes} min`;

  const hours = Math.floor(totalMinutes / 60);
  const minutes = totalMinutes % 60;

  if (minutes === 0) return `${hours}h`;
  return `${hours}h ${minutes}min`;
}

/**
 * Format a volume number with comma separator and unit.
 * Example: "12,500 kg"
 */
export function formatVolume(volume: number, unit = 'kg'): string {
  return `${volume.toLocaleString('en-US')} ${unit}`;
}

/**
 * Format a weight × reps combination.
 * Example: "100 kg × 8"
 */
export function formatWeightReps(weight: number, reps: number, unit = 'kg'): string {
  return `${weight} ${unit} × ${reps}`;
}

/**
 * Format a time from a date/ISO string to a human-readable clock time.
 * Example: "2:30 PM"
 */
export function formatTime(date: string | Date): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  return d.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true });
}
