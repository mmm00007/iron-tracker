import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import {
  formatRelativeDate,
  formatDuration,
  formatVolume,
  formatWeightReps,
  formatTime,
} from './formatters';

describe('formatVolume', () => {
  it('formats volume with comma separator and unit', () => {
    expect(formatVolume(12500)).toBe('12,500 kg');
  });

  it('formats small volume', () => {
    expect(formatVolume(500)).toBe('500 kg');
  });

  it('uses custom unit', () => {
    expect(formatVolume(1000, 'lb')).toBe('1,000 lb');
  });

  it('handles zero', () => {
    expect(formatVolume(0)).toBe('0 kg');
  });
});

describe('formatRelativeDate', () => {
  beforeEach(() => {
    vi.useFakeTimers();
    // Pin to 2025-03-20 12:00 UTC (Thursday)
    vi.setSystemTime(new Date('2025-03-20T12:00:00Z'));
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('returns "Today" for today\'s date', () => {
    expect(formatRelativeDate('2025-03-20T08:00:00Z')).toBe('Today');
  });

  it('returns "Yesterday" for yesterday', () => {
    expect(formatRelativeDate('2025-03-19T15:00:00Z')).toBe('Yesterday');
  });

  it('returns "Weekday, MonthDay" for dates within the past week', () => {
    // 2025-03-16 is Sunday, 4 days ago from Thursday
    const result = formatRelativeDate('2025-03-16T10:00:00Z');
    expect(result).toContain('Sunday');
    expect(result).toContain('Mar');
    expect(result).toContain('16');
  });

  it('returns "MonthDay" for dates older than a week in same year', () => {
    const result = formatRelativeDate('2025-02-10T10:00:00Z');
    expect(result).toContain('Feb');
    expect(result).toContain('10');
    // Should not contain year
    expect(result).not.toContain('2025');
  });

  it('includes year for dates in a different year', () => {
    const result = formatRelativeDate('2024-12-25T10:00:00Z');
    expect(result).toContain('2024');
  });

  it('accepts Date objects', () => {
    expect(formatRelativeDate(new Date('2025-03-20T10:00:00Z'))).toBe('Today');
  });
});

describe('formatDuration', () => {
  it('formats minutes-only duration', () => {
    expect(formatDuration('2025-03-20T10:00:00Z', '2025-03-20T10:45:00Z')).toBe('45 min');
  });

  it('formats hours with minutes', () => {
    expect(formatDuration('2025-03-20T10:00:00Z', '2025-03-20T11:15:00Z')).toBe('1h 15min');
  });

  it('formats exact hours (no trailing minutes)', () => {
    expect(formatDuration('2025-03-20T10:00:00Z', '2025-03-20T12:00:00Z')).toBe('2h');
  });

  it('returns "0 min" for same start and end', () => {
    expect(formatDuration('2025-03-20T10:00:00Z', '2025-03-20T10:00:00Z')).toBe('0 min');
  });

  it('handles end before start (returns 0 min)', () => {
    expect(formatDuration('2025-03-20T12:00:00Z', '2025-03-20T10:00:00Z')).toBe('0 min');
  });
});

describe('formatWeightReps', () => {
  it('formats weight x reps', () => {
    expect(formatWeightReps(100, 8)).toBe('100 kg × 8');
  });

  it('uses custom unit', () => {
    expect(formatWeightReps(225, 5, 'lb')).toBe('225 lb × 5');
  });
});

describe('formatTime', () => {
  it('formats a time string', () => {
    const result = formatTime('2025-03-20T14:30:00Z');
    // The exact output depends on timezone, but it should be a formatted time string
    expect(result).toBeTruthy();
    expect(typeof result).toBe('string');
  });

  it('accepts Date objects', () => {
    const result = formatTime(new Date('2025-03-20T14:30:00Z'));
    expect(result).toBeTruthy();
  });
});
