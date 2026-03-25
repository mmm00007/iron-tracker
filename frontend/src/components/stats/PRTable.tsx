import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import { EmojiEvents } from '@mui/icons-material';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  ResponsiveContainer,
  Cell,
  Tooltip,
} from 'recharts';
import { formatRelativeDate } from '@/utils/formatters';
import { useProfile } from '@/hooks/useProfile';
import { DATA_FONT, CHART_COLORS } from '@/theme';

interface PRRecord {
  repCount: number;
  weight: number;
  estimated1rm: number;
  date: string;
}

interface PRTableProps {
  records: PRRecord[];
}

const REP_RANGES = [1, 3, 5, 8, 10];
const REP_COLORS = [
  CHART_COLORS.primary,
  CHART_COLORS.secondary,
  CHART_COLORS.tertiary,
  CHART_COLORS.quaternary,
  CHART_COLORS.quinary,
];

function CustomTooltip({ active, payload, label }: {
  active?: boolean;
  payload?: Array<{ value: number; payload: { weight: number; date: string } }>;
  label?: string;
  unit?: string;
}) {
  if (!active || !payload || payload.length === 0) return null;
  const entry = payload[0]!;
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
      <Typography variant="caption" sx={{ color: '#A0AAB8', display: 'block' }}>
        {label}
      </Typography>
      <Typography sx={{ fontFamily: DATA_FONT, fontSize: '0.875rem', fontWeight: 700, color: '#FFD700' }}>
        {entry.payload.weight} @ {entry.value.toFixed(0)} e1RM
      </Typography>
      <Typography variant="caption" sx={{ color: '#636D7E' }}>
        {formatRelativeDate(entry.payload.date)}
      </Typography>
    </Box>
  );
}

export function PRTable({ records }: PRTableProps) {
  const { data: profile } = useProfile();
  const unit = profile?.preferred_weight_unit ?? 'kg';

  const recordMap = new Map(records.map((r) => [r.repCount, r]));

  const chartData = REP_RANGES.map((reps) => {
    const record = recordMap.get(reps);
    return {
      label: `${reps}RM`,
      e1rm: record?.estimated1rm ?? 0,
      weight: record?.weight ?? 0,
      date: record?.date ?? '',
      hasRecord: !!record,
    };
  });

  const hasAnyRecords = chartData.some((d) => d.hasRecord);

  return (
    <Box>
      {/* Bar chart visualization */}
      {hasAnyRecords && (
        <Box sx={{ height: { xs: 180, md: 220 }, mb: 2 }}>
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={chartData} margin={{ top: 8, right: 8, bottom: 0, left: -12 }} barCategoryGap="25%">
              <XAxis
                dataKey="label"
                tick={{ fill: '#A0AAB8', fontSize: 11, fontFamily: DATA_FONT, fontWeight: 600 }}
                axisLine={false}
                tickLine={false}
              />
              <YAxis
                tick={{ fill: '#636D7E', fontSize: 10, fontFamily: DATA_FONT }}
                axisLine={false}
                tickLine={false}
                tickFormatter={(v) => `${v}`}
                width={36}
              />
              <Tooltip content={<CustomTooltip />} />
              <Bar dataKey="e1rm" radius={[6, 6, 0, 0]}>
                {chartData.map((entry, index) => (
                  <Cell
                    key={index}
                    fill={entry.hasRecord ? REP_COLORS[index % REP_COLORS.length] : 'rgba(160, 170, 184, 0.08)'}
                  />
                ))}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </Box>
      )}

      {/* Detail list underneath */}
      {REP_RANGES.map((reps, idx) => {
        const record = recordMap.get(reps);
        return (
          <Box
            key={reps}
            sx={{
              display: 'flex',
              alignItems: 'center',
              gap: 1.5,
              py: 0.75,
              px: 0.5,
              borderBottom: '1px solid rgba(160, 170, 184, 0.06)',
              '&:last-child': { borderBottom: 'none' },
            }}
          >
            {/* Rep badge */}
            <Box
              sx={{
                minWidth: 44,
                height: 28,
                borderRadius: '6px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: 0.25,
                backgroundColor: record
                  ? `${REP_COLORS[idx % REP_COLORS.length]}15`
                  : 'rgba(160, 170, 184, 0.05)',
              }}
            >
              {record && <EmojiEvents sx={{ fontSize: 12, color: '#FFD700' }} />}
              <Typography
                sx={{
                  fontFamily: DATA_FONT,
                  fontSize: '0.6875rem',
                  fontWeight: 700,
                  color: record ? REP_COLORS[idx % REP_COLORS.length] : 'text.disabled',
                }}
              >
                {reps}RM
              </Typography>
            </Box>

            {/* Weight */}
            <Box sx={{ flex: 1 }}>
              {record ? (
                <Typography
                  sx={{
                    fontFamily: DATA_FONT,
                    fontSize: '0.9375rem',
                    fontWeight: 700,
                    color: 'text.primary',
                  }}
                >
                  {record.weight} {unit}
                </Typography>
              ) : (
                <Typography variant="body2" sx={{ color: 'text.disabled' }}>—</Typography>
              )}
            </Box>

            {/* Est. 1RM */}
            <Box sx={{ textAlign: 'right' }}>
              {record ? (
                <Typography
                  sx={{
                    fontFamily: DATA_FONT,
                    fontSize: '0.75rem',
                    fontWeight: 600,
                    color: 'text.secondary',
                  }}
                >
                  e1RM {Math.round(record.estimated1rm)}
                </Typography>
              ) : (
                <Typography variant="caption" sx={{ color: 'text.disabled' }}>—</Typography>
              )}
            </Box>

            {/* Date */}
            <Typography variant="caption" sx={{ color: 'text.disabled', minWidth: 48, textAlign: 'right' }}>
              {record ? formatRelativeDate(record.date) : ''}
            </Typography>
          </Box>
        );
      })}
    </Box>
  );
}
