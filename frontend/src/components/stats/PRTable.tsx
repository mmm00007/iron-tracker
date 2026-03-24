import {
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Typography,
  Chip,
} from '@mui/material';
import { EmojiEvents } from '@mui/icons-material';
import { formatRelativeDate } from '@/utils/formatters';
import { useProfile } from '@/hooks/useProfile';

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

export function PRTable({ records }: PRTableProps) {
  const { data: profile } = useProfile();
  const unit = profile?.preferred_weight_unit ?? 'kg';

  const recordMap = new Map(records.map((r) => [r.repCount, r]));

  return (
    <TableContainer>
      <Table size="small">
        <TableHead>
          <TableRow>
            <TableCell>Rep Range</TableCell>
            <TableCell align="right">Weight</TableCell>
            <TableCell align="right">Est. 1RM</TableCell>
            <TableCell align="right">Date</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {REP_RANGES.map((reps) => {
            const record = recordMap.get(reps);
            return (
              <TableRow key={reps}>
                <TableCell>
                  <Chip
                    icon={record ? <EmojiEvents sx={{ fontSize: 14 }} /> : undefined}
                    label={`${reps}RM`}
                    size="small"
                    sx={{
                      bgcolor: record ? 'rgba(255, 215, 0, 0.1)' : undefined,
                      color: record ? '#FFD700' : 'text.secondary',
                    }}
                    variant={record ? 'filled' : 'outlined'}
                  />
                </TableCell>
                <TableCell align="right">
                  {record ? (
                    <Typography variant="body2" fontWeight={600}>
                      {record.weight} {unit}
                    </Typography>
                  ) : (
                    <Typography variant="body2" color="text.disabled">
                      —
                    </Typography>
                  )}
                </TableCell>
                <TableCell align="right">
                  {record ? (
                    <Typography variant="body2">{Math.round(record.estimated1rm)} {unit}</Typography>
                  ) : (
                    <Typography variant="body2" color="text.disabled">
                      —
                    </Typography>
                  )}
                </TableCell>
                <TableCell align="right">
                  {record ? (
                    <Typography variant="body2" color="text.secondary">
                      {formatRelativeDate(record.date)}
                    </Typography>
                  ) : (
                    <Typography variant="body2" color="text.disabled">
                      —
                    </Typography>
                  )}
                </TableCell>
              </TableRow>
            );
          })}
        </TableBody>
      </Table>
    </TableContainer>
  );
}
