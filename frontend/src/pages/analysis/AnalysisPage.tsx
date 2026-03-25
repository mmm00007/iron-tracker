import { useState } from 'react';
import AppBar from '@mui/material/AppBar';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Chip from '@mui/material/Chip';
import CircularProgress from '@mui/material/CircularProgress';
import Divider from '@mui/material/Divider';
import Skeleton from '@mui/material/Skeleton';
import Stack from '@mui/material/Stack';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import AutoAwesomeIcon from '@mui/icons-material/AutoAwesome';
import LightbulbIcon from '@mui/icons-material/Lightbulb';
import TipsAndUpdatesIcon from '@mui/icons-material/TipsAndUpdates';
import { useAnalysisReports, useRequestAnalysis } from '@/hooks/useAnalysis';
import type { AnalysisReport, AnalysisInsight } from '@/hooks/useAnalysis';
import { formatRelativeDate } from '@/utils/formatters';

type ScopeType = 'week' | 'month';

function getDateRange(scope: ScopeType): { start: string; end: string } {
  const end = new Date();
  const start = new Date();
  if (scope === 'week') {
    start.setDate(start.getDate() - 7);
  } else {
    start.setMonth(start.getMonth() - 1);
  }
  return {
    start: start.toISOString().slice(0, 10),
    end: end.toISOString().slice(0, 10),
  };
}

function ReportCard({ report }: { report: AnalysisReport }) {
  return (
    <Card>
      <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}>
          <Chip
            label={`${report.scope_type} · ${report.scope_start} → ${report.scope_end}`}
            size="small"
            sx={{ fontSize: '0.65rem', height: 20 }}
          />
          <Typography variant="caption" sx={{ color: 'text.disabled' }}>
            {formatRelativeDate(report.created_at)}
          </Typography>
        </Box>

        <Typography variant="body2" sx={{ color: 'text.primary', mb: 1.5 }}>
          {report.summary}
        </Typography>

        {Array.isArray(report.insights) && report.insights.length > 0 && (
          <>
            <Divider sx={{ mb: 1.5 }} />
            <Stack spacing={1.5}>
              {(report.insights as unknown as AnalysisInsight[]).map((insight, i) => (
                <Box key={i} sx={{ display: 'flex', gap: 1 }}>
                  <LightbulbIcon sx={{ fontSize: 18, color: 'warning.main', mt: 0.25, flexShrink: 0 }} />
                  <Box>
                    <Typography variant="caption" sx={{ color: 'primary.main', fontWeight: 600, display: 'block' }}>
                      {insight.metric}
                      {insight.delta && (
                        <Box component="span" sx={{ color: 'text.secondary', fontWeight: 400 }}>
                          {' · '}{insight.delta}
                        </Box>
                      )}
                    </Typography>
                    <Typography variant="body2" sx={{ color: 'text.secondary', fontSize: '0.8rem' }}>
                      {insight.finding}
                    </Typography>
                    <Typography variant="body2" sx={{ color: 'success.main', fontSize: '0.8rem', fontWeight: 500, mt: 0.25 }}>
                      {insight.recommendation}
                    </Typography>
                  </Box>
                </Box>
              ))}
            </Stack>
          </>
        )}
      </CardContent>
    </Card>
  );
}

export function AnalysisPage() {
  const { data: reports, isLoading } = useAnalysisReports();
  const requestAnalysis = useRequestAnalysis();
  const [scope, setScope] = useState<ScopeType>('week');
  const [error, setError] = useState<string | null>(null);

  const handleAnalyze = async () => {
    setError(null);
    const { start, end } = getDateRange(scope);
    try {
      await requestAnalysis.mutateAsync({
        scopeType: scope,
        scopeStart: start,
        scopeEnd: end,
        goals: ['strength', 'volume'],
      });
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Analysis failed');
    }
  };

  return (
    <Box sx={{ pb: { xs: 10, md: 2 } }}>
      <AppBar position="static" elevation={0} color="transparent">
        <Toolbar sx={{ px: 2, minHeight: '56px !important' }}>
          <Typography variant="h6" component="h1" fontWeight={700} sx={{ flexGrow: 1 }}>
            AI Analysis
          </Typography>
        </Toolbar>
      </AppBar>

      {/* Analysis request section */}
      <Box sx={{ px: 2, pb: 2 }}>
        <Card
          sx={{
            border: '1px solid rgba(168, 199, 250, 0.2)',
            background: 'linear-gradient(135deg, rgba(168, 199, 250, 0.06) 0%, transparent 100%)',
          }}
        >
          <CardContent sx={{ p: 2, '&:last-child': { pb: 2 } }}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1.5 }}>
              <TipsAndUpdatesIcon sx={{ color: 'primary.main' }} />
              <Typography variant="subtitle1" fontWeight={600}>
                Get AI Training Insights
              </Typography>
            </Box>
            <Typography variant="body2" sx={{ color: 'text.secondary', mb: 2 }}>
              Analyze your recent training for personalized recommendations on volume, intensity, and programming.
            </Typography>

            <Box sx={{ display: 'flex', gap: 1, mb: 2 }}>
              <Chip
                label="Last Week"
                onClick={() => setScope('week')}
                color={scope === 'week' ? 'primary' : 'default'}
                variant={scope === 'week' ? 'filled' : 'outlined'}
              />
              <Chip
                label="Last Month"
                onClick={() => setScope('month')}
                color={scope === 'month' ? 'primary' : 'default'}
                variant={scope === 'month' ? 'filled' : 'outlined'}
              />
            </Box>

            {error && (
              <Alert severity="error" sx={{ mb: 2 }} onClose={() => setError(null)}>
                {error}
              </Alert>
            )}

            <Button
              variant="contained"
              startIcon={
                requestAnalysis.isPending ? (
                  <CircularProgress size={16} color="inherit" />
                ) : (
                  <AutoAwesomeIcon />
                )
              }
              onClick={() => void handleAnalyze()}
              disabled={requestAnalysis.isPending}
              fullWidth
            >
              {requestAnalysis.isPending ? 'Analyzing...' : 'Analyze My Training'}
            </Button>
          </CardContent>
        </Card>
      </Box>

      {/* Past reports */}
      <Box sx={{ px: 2 }}>
        <Typography variant="overline" sx={{ color: 'text.secondary', display: 'block', mb: 1 }}>
          Past Reports
        </Typography>

        {isLoading ? (
          <Stack spacing={2}>
            <Skeleton variant="rounded" height={120} />
            <Skeleton variant="rounded" height={120} />
          </Stack>
        ) : !reports || reports.length === 0 ? (
          <Box sx={{ textAlign: 'center', py: 4 }}>
            <AutoAwesomeIcon sx={{ fontSize: 48, color: 'text.disabled', mb: 1 }} />
            <Typography variant="body2" color="text.secondary">
              No analysis reports yet. Run your first analysis above.
            </Typography>
          </Box>
        ) : (
          <Stack spacing={2}>
            {reports.map((report) => (
              <ReportCard key={report.id} report={report} />
            ))}
          </Stack>
        )}
      </Box>
    </Box>
  );
}
