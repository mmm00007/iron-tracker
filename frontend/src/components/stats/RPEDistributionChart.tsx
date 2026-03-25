import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CircularProgress from '@mui/material/CircularProgress';
import Typography from '@mui/material/Typography';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  ResponsiveContainer,
  Cell,
  Tooltip,
} from 'recharts';
import { CHART_AXIS_COLOR, DATA_FONT } from '@/theme';

/* ─── RPE zone colors ─────────────────────────────────────────────────────── */
const RPE_ZONE = {
  optimal: '#5BEAA2',   // RPE 7-8  — green, hypertrophy sweet-spot
  acceptable: '#F9A825', // RPE 6, 9 — amber
  review: '#EF5350',     // RPE <=5 or 10 — red
} as const;

function rpeColor(rpe: number): string {
  if (rpe >= 7 && rpe <= 8) return RPE_ZONE.optimal;
  if (rpe === 6 || rpe === 9) return RPE_ZONE.acceptable;
  return RPE_ZONE.review;
}

/* ─── Tooltip ─────────────────────────────────────────────────────────────── */
interface CustomTooltipProps {
  active?: boolean;
  payload?: Array<{ payload: { rpe: number; count: number } }>;
}

function CustomTooltip({ active, payload }: CustomTooltipProps) {
  if (!active || !payload || payload.length === 0) return null;
  const { rpe, count } = payload[0]!.payload;
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
      <Typography sx={{ fontFamily: DATA_FONT, fontSize: '0.75rem', color: '#EAEEF4', fontWeight: 600 }}>
        RPE {rpe}: {count} set{count !== 1 ? 's' : ''}
      </Typography>
    </Box>
  );
}

/* ─── Legend dot ───────────────────────────────────────────────────────────── */
function LegendDot({ color, label }: { color: string; label: string }) {
  return (
    <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
      <Box sx={{ width: 10, height: 10, borderRadius: '2px', backgroundColor: color, flexShrink: 0 }} />
      <Typography variant="caption" sx={{ color: 'text.secondary' }}>
        {label}
      </Typography>
    </Box>
  );
}

/* ─── Component ───────────────────────────────────────────────────────────── */
interface RPEDistributionChartProps {
  data: Array<{ rpe: number; count: number }>;
  isLoading?: boolean;
}

export function RPEDistributionChart({ data, isLoading }: RPEDistributionChartProps) {
  // Return null when there is nothing meaningful to render
  if (!data || data.length === 0 || data.every((d) => d.count === 0)) return null;

  return (
    <Card sx={{ mb: 2 }}>
      <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
        <Typography variant="subtitle1" sx={{ color: 'text.primary', mb: 1 }}>
          RPE Distribution
        </Typography>

        {isLoading ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', py: 3 }}>
            <CircularProgress size={24} />
          </Box>
        ) : (
          <>
            <Box sx={{ width: '100%', height: { xs: 200, md: 260 } }}>
              <ResponsiveContainer width="100%" height="100%">
                <BarChart
                  data={data}
                  layout="vertical"
                  margin={{ top: 4, right: 16, left: 4, bottom: 4 }}
                >
                  <XAxis
                    type="number"
                    allowDecimals={false}
                    tick={{ fill: CHART_AXIS_COLOR, fontSize: 10, fontFamily: DATA_FONT }}
                    axisLine={{ stroke: 'rgba(160, 170, 184, 0.1)' }}
                    tickLine={false}
                  />
                  <YAxis
                    type="category"
                    dataKey="rpe"
                    tick={{ fill: CHART_AXIS_COLOR, fontSize: 11, fontFamily: DATA_FONT }}
                    axisLine={false}
                    tickLine={false}
                    width={32}
                    tickFormatter={(v: number) => `${v}`}
                  />
                  <Tooltip content={<CustomTooltip />} cursor={{ fill: 'rgba(160, 170, 184, 0.06)' }} />
                  <Bar dataKey="count" radius={[0, 4, 4, 0]} barSize={14}>
                    {data.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={rpeColor(entry.rpe)} />
                    ))}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            </Box>

            {/* Legend */}
            <Box sx={{ display: 'flex', gap: 2, mt: 1.5, flexWrap: 'wrap' }}>
              <LegendDot color={RPE_ZONE.optimal} label="Optimal (7-8)" />
              <LegendDot color={RPE_ZONE.acceptable} label="Acceptable (6, 9)" />
              <LegendDot color={RPE_ZONE.review} label="Review (<6, 10)" />
            </Box>
          </>
        )}
      </CardContent>
    </Card>
  );
}
