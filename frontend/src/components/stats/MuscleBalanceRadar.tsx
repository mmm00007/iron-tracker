import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CircularProgress from '@mui/material/CircularProgress';
import Typography from '@mui/material/Typography';
import { useTheme } from '@mui/material/styles';
import {
  RadarChart,
  Radar,
  PolarGrid,
  PolarAngleAxis,
  ResponsiveContainer,
  Tooltip,
} from 'recharts';
import { CHART_COLORS, DATA_FONT } from '@/theme';

// ─── Constants ───────────────────────────────────────────────────────────────
/** Midpoint of the evidence-based hypertrophy range (10-20 sets/muscle/week) */
const RECOMMENDED_SETS = 15;
const REFERENCE_COLOR = '#5BEAA215';

// ─── Types ───────────────────────────────────────────────────────────────────
interface MuscleBalanceEntry {
  muscleName: string;
  sets: number;
}

interface MuscleBalanceRadarProps {
  data: MuscleBalanceEntry[];
  isLoading?: boolean;
}

// ─── Custom Tooltip ──────────────────────────────────────────────────────────
interface CustomTooltipProps {
  active?: boolean;
  payload?: Array<{ payload: MuscleBalanceEntry }>;
}

function CustomTooltip({ active, payload }: CustomTooltipProps) {
  if (!active || !payload || payload.length === 0) return null;
  const entry = payload[0]!.payload;
  return (
    <Box
      sx={{
        backgroundColor: 'rgba(20, 24, 32, 0.95)',
        border: '1px solid rgba(160, 170, 184, 0.12)',
        borderRadius: '6px',
        px: 1.5,
        py: 0.75,
      }}
    >
      <Typography variant="body2" sx={{ color: '#EAEEF4', fontWeight: 600 }}>
        {entry.muscleName}
      </Typography>
      <Typography sx={{ fontFamily: DATA_FONT, fontSize: '0.75rem', color: '#A0AAB8' }}>
        {entry.sets} sets/week
      </Typography>
    </Box>
  );
}

// ─── Component ───────────────────────────────────────────────────────────────
export function MuscleBalanceRadar({ data, isLoading }: MuscleBalanceRadarProps) {
  const theme = useTheme();

  // Radar needs at least 3 axes to render meaningfully
  if (!isLoading && data.length < 3) return null;

  // Build chart data with a reference value at the recommended midpoint
  const chartData = data.map((d) => ({
    ...d,
    recommended: RECOMMENDED_SETS,
  }));

  return (
    <Card sx={{ mb: 2 }}>
      <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
        <Typography variant="overline" sx={{ color: 'text.secondary', display: 'block', mb: 0.5 }}>
          Muscle Balance
        </Typography>
        <Typography variant="caption" sx={{ color: 'text.disabled', display: 'block', mb: 1.5 }}>
          Sets per muscle group (weekly)
        </Typography>

        {isLoading ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', py: 3 }}>
            <CircularProgress size={24} />
          </Box>
        ) : (
          <Box sx={{ width: '100%', height: { xs: 260, md: 320 } }}>
            <ResponsiveContainer width="100%" height="100%">
              <RadarChart cx="50%" cy="50%" outerRadius="75%" data={chartData}>
                <PolarGrid stroke={theme.palette.divider} />
                <PolarAngleAxis
                  dataKey="muscleName"
                  tick={{ fill: theme.palette.text.secondary, fontSize: 11 }}
                />
                {/* Reference zone — recommended hypertrophy midpoint */}
                <Radar
                  name="Recommended"
                  dataKey="recommended"
                  stroke="transparent"
                  fill={REFERENCE_COLOR}
                  fillOpacity={1}
                />
                {/* User's actual set counts */}
                <Radar
                  name="Sets"
                  dataKey="sets"
                  stroke={CHART_COLORS.primary}
                  fill={CHART_COLORS.primary}
                  fillOpacity={0.3}
                />
                <Tooltip content={<CustomTooltip />} />
              </RadarChart>
            </ResponsiveContainer>
          </Box>
        )}
      </CardContent>
    </Card>
  );
}
