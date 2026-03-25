# Frontend Visual Redesign & Chart-First Dashboard

**Date:** 2026-03-25
**Scope:** Frontend theme overhaul, 21 modified files, chart-heavy dashboard replacing raw numbers
**Inspiration:** [gym-tracker](https://github.com/mmm00007/gym-tracker) visual design -- dark charcoal aesthetic, monospace data fonts, custom charts everywhere

---

## Summary

The Iron Tracker frontend previously displayed most training metrics as raw text numbers (streak counts, volume totals, KPI values, PR tables). This change replaces those text-heavy displays with visual charts -- bar charts, area charts, line charts with trend lines, and color-coded heatmaps -- making it far easier for users to understand their lifting progress at a glance. The visual style was also upgraded with a more vibrant accent color, a dedicated monospace font for data values, and deeper dark backgrounds suited for gym environments.

Three specialist agents validated the changes before implementation:
- **Fitness Domain Expert** (opus) -- validated chart type choices against training science evidence
- **UX/UI Specialist** (opus) -- designed the visual hierarchy, typography, and responsive layouts
- **Data Science Expert** (opus) -- reviewed visualization best practices, axis scaling, and sparse-data handling

---

## Theme Overhaul

### File: `frontend/src/theme.ts`

**Accent color shift:** Primary changed from muted pastel blue `#A8C7FA` to vibrant mint green `#5BEAA2`. The fitness domain expert confirmed that a higher-energy accent is more appropriate for a gym application used in dim lighting. The green is WCAG AA compliant against the dark background.

**Deeper dark surfaces:** Background shifted from `#121212` to `#0D0F12`, paper from `#1E1E1E` to `#161A1F`, surface containers from purple-tinted `#1A1A2E` to blue-tinted `#141820`. This creates more depth between card layers and reduces eye strain in dark gym environments.

**Text contrast:** Primary text brightened to `#EAEEF4`, secondary to `#A0AAB8`, disabled to `#636D7E`. Higher contrast makes numbers readable on sweaty phone screens at arm's length.

**Unified chart palette:** New `CHART_COLORS` export consolidates all chart colors into a single source of truth. Previously, three separate color arrays (`MUSCLE_COLORS`, `VARIANT_COLORS`) were duplicated across 6 chart components with slight inconsistencies. Now all charts reference `CHART_COLORS.series[]` and `CHART_COLORS.getMuscleColor()`.

### File: `frontend/index.html`

**Data font:** Added JetBrains Mono (weights 400, 600, 700, 800) via Google Fonts. The UX/UI specialist recommended monospace for all numeric data values -- weights, reps, volumes, percentages -- to create visual separation between labels (Inter) and data (JetBrains Mono). The `DATA_FONT` constant is exported from `theme.ts` for consistent use.

---

## New Visualizations

### Training Frequency Bar Chart (replaces streak number)

**Files:** `components/home/TrainingStreakCard.tsx`, `hooks/useAnalytics.ts`, `utils/analytics.ts`

The TrainingStreakCard previously showed two text numbers: "day streak" and "week streak." The domain expert noted that consecutive-day streaks are anti-correlated with good programming (training the same muscles on consecutive days is suboptimal), and that weekly training frequency is the evidence-based metric (ACSM/NSCA guidelines target 3-6 days/week).

**What changed:**
- Added a Recharts `BarChart` showing training days per week for the last 8 weeks
- Each bar represents one ISO week; the current week is highlighted with full opacity
- A dashed `ReferenceLine` shows the average days/week
- Y-axis fixed at 0-7 (never auto-scaled, per data science expert recommendation)
- Streak numbers are preserved as compact badges in the card header

**New utility:** `trainingFrequencyPerWeek(sets, weeks)` in `analytics.ts` computes unique training days per ISO week. New hook `useTrainingFrequencyWeekly()` wraps it with React Query caching.

### Weekly Comparison Grouped Bar Chart (replaces KPI text)

**File:** `components/stats/WeeklySnapshotCard.tsx`

Previously showed three `MetricCell` boxes with text numbers (sets, volume, days) and small delta badges. Now includes a grouped bar chart below the KPI cells comparing this week vs last week visually.

**What changed:**
- KPI cells now use `DATA_FONT` for bold monospace numbers at 1.25rem
- Added a Recharts `BarChart` with two bar series: "lastWeek" (dim) and "thisWeek" (color-coded per metric)
- Each metric gets a distinct color from `CHART_COLORS.series`
- Compact legend below identifies the two series

**Domain expert caveat:** Week-over-week comparison is noisy for intermediate lifters. A 4-week rolling average baseline would be a future improvement.

### Volume Trend Area Chart (replaces sparkline + number)

**File:** `components/home/VolumeTrendCard.tsx`

Previously showed a small 100x40 sparkline next to a text number. Now features a full-width area chart with gradient fill.

**What changed:**
- Converted from `Sparkline` to Recharts `AreaChart` with a `linearGradient` fill from `#5BEAA230` to transparent
- Large monospace volume number (1.5rem, weight 800) as the hero element
- Percentage trend badge in the header
- Interactive tooltip showing exact values on hover

### Volume Chart with Moving Average Trend Line

**File:** `components/stats/VolumeChart.tsx`

Previously a plain `BarChart`. Now a `ComposedChart` overlaying bars with a 4-week Simple Moving Average trend line.

**What changed:**
- Converted from `BarChart` to `ComposedChart` to support mixed chart types
- Added a `Line` component for the 4-week SMA (dashed amber `#F9A825`, 2px stroke)
- SMA computed inline: for each week, average the current and previous 3 weeks' volume
- The data science expert specifically recommended SMA over EMA because all weeks in the window matter equally for training volume (unlike financial data where recency matters more)
- Current week bar highlighted at full opacity, historical bars at 80%

### PR Comparison Bar Chart (replaces table)

**File:** `components/stats/PRTable.tsx`

Previously a `<Table>` with 4 columns (Rep Range, Weight, Est. 1RM, Date) that was cramped on mobile. Now features a color-coded vertical bar chart with a detail list below.

**What changed:**
- Added a Recharts `BarChart` showing estimated 1RM per rep range (1RM, 3RM, 5RM, 8RM, 10RM)
- Each bar gets a distinct color from the chart series palette
- Empty rep ranges show a near-transparent placeholder bar
- Below the chart, a compact detail list replaces the table with monospace weight values, e1RM labels, and relative dates
- Trophy icons on rep badges that have records

### E1RM Chart Polish

**File:** `components/stats/E1RMChart.tsx`

Visual refinements to the existing line chart:
- Thicker strokes (2.5px up from 2px) for better visibility
- Styled active dots with dark border for precise hover targeting
- Monospace axis labels via `DATA_FONT`
- Gradient defs for potential area fills
- Updated tooltip with backdrop blur and monospace values
- Updated Brush component styling

---

## Component Style Upgrades

### Exercise Progress Card

**File:** `components/home/ExerciseProgressCard.tsx`

**Critical fix:** Removed `Math.random()` calls that generated fake sparkline data. Both the domain expert and UX/UI specialist flagged this as actively misleading -- random noise presented as real trends. Replaced with deterministic mini bar charts using `MiniVolumeBar` subcomponent with Recharts `BarChart`.

Other changes:
- Added rank badges (#1-#5) in monospace font
- Monospace for set count and volume values
- Color-coded per exercise from `CHART_COLORS.series`
- Hover state uses primary color tint

### Recent PRs Card

**File:** `components/home/RecentPRsCard.tsx`

- PR value now uses `DATA_FONT` at 1.125rem weight 800 in gold `#FFD700`
- Card backgrounds use subtle gradient: `linear-gradient(135deg, rgba(255, 215, 0, 0.06), rgba(255, 152, 0, 0.03))`
- Trophy icon moved to card header

### Muscle Distribution Chart

**File:** `components/stats/MuscleDistributionChart.tsx`

- Side-by-side layout on tablet/desktop (donut left, legend right) via `flexDirection: { xs: 'column', md: 'row' }`
- Legend shows both raw volume and percentage in monospace
- Donut center label uses `DATA_FONT`
- Shows up to 8 muscle groups (was 6)

### Muscle Volume Stacked Bar Chart

**File:** `components/stats/MuscleVolumeChart.tsx`

- Now uses `CHART_COLORS.getMuscleColor()` for consistent per-muscle colors across all charts
- Monospace axis labels and tooltip values
- Updated tooltip with total row in primary accent color

### Training Calendar Heatmap

**File:** `components/stats/TrainingCalendar.tsx`

- Color scale changed from multi-hue (blue/green/yellow) to single-hue green gradient (`#5BEAA225` through `#5BEAA2`) anchored to the primary accent
- Day count badge in header shows total training days
- Day-of-week labels use monospace font
- Mobile tooltip detail box uses primary accent tint border
- Selected cell outline uses primary color instead of white

### Session Card (History)

**File:** `components/history/SessionCard.tsx`

- Duration chip uses `DATA_FONT` for the time value
- Set count and exercise count use monospace
- Exercise detail rows use monospace for set/weight/rep data
- Volume footer uses monospace with primary accent color
- Mini bar chart increased to 56x28 from 48x24
- Updated muscle chip colors to use theme-consistent values

### Common Components

**File:** `components/common/Sparkline.tsx`
- Converted from `LineChart` to `AreaChart` with optional gradient fill (`filled` prop)
- Default color changed from hardcoded blue to `CHART_COLORS.primary`

**File:** `components/common/MiniBarChart.tsx`
- Default color changed to `CHART_COLORS.primary`
- Slightly increased bar border-radius to 1.5px

---

## Layout & Responsiveness

### Home Page

**File:** `pages/home/HomePage.tsx`

Added a three-tier responsive grid:
- **Phone** (`xs`): Single column
- **Tablet** (`md`): 2-column grid
- **Desktop** (`lg`): 3-column grid -- streak, volume trend, and muscle donut sit side-by-side

Card spanning: WeeklySnapshot and RecentPRs always span full width. ExerciseProgress spans 2 columns on desktop with TrainingCalendar beside it.

### Stats Page

**File:** `pages/stats/StatsPage.tsx`

- Added 3-column desktop grid (`lg: repeat(3, 1fr)`)
- MuscleDistribution takes 1 column, MuscleVolumeChart takes 2 columns on desktop
- TopExercises list spans full width on desktop
- PR card styling matches home page (gradient gold cards, monospace values)
- Updated all trend icons to use `CHART_COLORS.primary` instead of hardcoded blue

### Greeting Card

**File:** `components/home/GreetingCard.tsx`

- Responsive font size: `{ xs: '1.25rem', md: '1.5rem' }`
- Responsive top padding: `{ xs: 2, md: 3 }`

---

## Data Layer

### New Utility: `trainingFrequencyPerWeek()`

**File:** `utils/analytics.ts`

```typescript
export function trainingFrequencyPerWeek(sets: WorkoutSet[], weeks = 8): WeeklyFrequencyEntry[]
```

Returns an array of `{ label, weekStart, days }` for the last N ISO weeks. Counts unique training days per week by extracting `YYYY-MM-DD` from `set.logged_at` and using a `Set` for deduplication.

### New Hook: `useTrainingFrequencyWeekly()`

**File:** `hooks/useAnalytics.ts`

Wraps `trainingFrequencyPerWeek()` with React Query, fetching the last ~8.5 weeks of sets and computing 8-week frequency data. 5-minute stale time, consistent with other analytics hooks.

---

## Specialist Agent Recommendations Not Yet Implemented

These are validated suggestions from the specialist agents that were deferred for future work:

1. **Normalize exercise progress to % of personal best** (Data Science Expert) -- multi-line chart showing each exercise's E1RM as percentage of their personal best, enabling cross-exercise comparison on a 0-100% scale
2. **Conditional E1RM vs volume metric by exercise type** (Domain Expert) -- show E1RM for compounds, total volume for isolations, since the Epley formula is unreliable for isolation exercises
3. **Theoretical strength curve overlay on PR chart** (Domain Expert) -- overlay the expected weight at each rep range derived from E1RM using inverse Epley, highlighting undertrained rep ranges
4. **Push/pull and anterior/posterior ratio indicators** (Domain Expert) -- simple imbalance flags instead of a radar chart
5. **Partial week highlighting** (Data Science Expert) -- dim the current week's bar in the frequency chart with reduced opacity since the week is incomplete
6. **Card surface differentiation** (UX/UI Specialist) -- different background treatments for data cards vs chart cards vs action cards
