import { useState } from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Chip from '@mui/material/Chip';
import CircularProgress from '@mui/material/CircularProgress';
import Typography from '@mui/material/Typography';
import DownloadIcon from '@mui/icons-material/Download';
import { supabase } from '@/lib/supabase';
import { useAuthStore } from '@/stores/authStore';

type ExportFormat = 'csv' | 'json';

function toCsv(rows: Record<string, unknown>[]): string {
  if (rows.length === 0) return '';
  const headers = Object.keys(rows[0]!);
  const lines = [
    headers.join(','),
    ...rows.map((row) =>
      headers
        .map((h) => {
          const val = row[h];
          if (val === null || val === undefined) return '';
          const str = String(val);
          return str.includes(',') || str.includes('"') || str.includes('\n')
            ? `"${str.replace(/"/g, '""')}"`
            : str;
        })
        .join(',')
    ),
  ];
  return lines.join('\n');
}

function download(filename: string, content: string, type: string) {
  const blob = new Blob([content], { type });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  setTimeout(() => URL.revokeObjectURL(url), 100);
}

export function DataExport() {
  const user = useAuthStore((s) => s.user);
  const [format, setFormat] = useState<ExportFormat>('csv');
  const [exporting, setExporting] = useState(false);

  const handleExport = async () => {
    if (!user) return;
    setExporting(true);

    try {
      // Fetch all user sets
      const { data: sets } = await supabase
        .from('sets')
        .select('id, exercise_id, variant_id, weight, weight_unit, reps, rpe, set_type, notes, logged_at')
        .eq('user_id', user.id)
        .order('logged_at', { ascending: true });

      // Fetch exercise names
      const exerciseIds = [...new Set((sets ?? []).map((s) => s.exercise_id))];
      let exerciseNames = new Map<string, string>();
      if (exerciseIds.length > 0) {
        const { data: exercises } = await supabase
          .from('exercises')
          .select('id, name')
          .in('id', exerciseIds);
        exerciseNames = new Map((exercises ?? []).map((e) => [e.id, e.name]));
      }

      // Fetch PRs
      const { data: prs } = await supabase
        .from('personal_records')
        .select('id, exercise_id, record_type, rep_count, value, achieved_at')
        .eq('user_id', user.id)
        .order('achieved_at', { ascending: true });

      // Enrich sets with exercise names
      const enrichedSets = (sets ?? []).map((s) => ({
        ...s,
        exercise_name: exerciseNames.get(s.exercise_id) ?? s.exercise_id,
      }));

      const enrichedPRs = (prs ?? []).map((p) => ({
        ...p,
        exercise_name: exerciseNames.get(p.exercise_id) ?? p.exercise_id,
      }));

      const dateStr = new Date().toISOString().slice(0, 10);

      if (format === 'csv') {
        download(`iron-tracker-sets-${dateStr}.csv`, toCsv(enrichedSets), 'text/csv');
        if (enrichedPRs.length > 0) {
          download(`iron-tracker-prs-${dateStr}.csv`, toCsv(enrichedPRs), 'text/csv');
        }
      } else {
        const exportData = {
          exported_at: new Date().toISOString(),
          sets: enrichedSets,
          personal_records: enrichedPRs,
        };
        download(
          `iron-tracker-export-${dateStr}.json`,
          JSON.stringify(exportData, null, 2),
          'application/json'
        );
      }
    } finally {
      setExporting(false);
    }
  };

  return (
    <Card sx={{ mt: 2 }}>
      <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
        <Typography variant="subtitle1" fontWeight={600} gutterBottom>
          Export Your Data
        </Typography>
        <Typography variant="body2" sx={{ color: 'text.secondary', mb: 2 }}>
          Download all your sets and personal records.
        </Typography>

        <Box sx={{ display: 'flex', gap: 1, mb: 2 }}>
          <Chip
            label="CSV"
            onClick={() => setFormat('csv')}
            color={format === 'csv' ? 'primary' : 'default'}
            variant={format === 'csv' ? 'filled' : 'outlined'}
          />
          <Chip
            label="JSON"
            onClick={() => setFormat('json')}
            color={format === 'json' ? 'primary' : 'default'}
            variant={format === 'json' ? 'filled' : 'outlined'}
          />
        </Box>

        <Button
          variant="outlined"
          startIcon={exporting ? <CircularProgress size={16} /> : <DownloadIcon />}
          onClick={() => void handleExport()}
          disabled={exporting}
          fullWidth
        >
          {exporting ? 'Exporting...' : `Export as ${format.toUpperCase()}`}
        </Button>
      </CardContent>
    </Card>
  );
}
