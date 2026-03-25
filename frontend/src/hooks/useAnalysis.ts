import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { useAuthStore } from '@/stores/authStore';
import type { AnalysisReport } from '@/types/database';

// Re-export for consumers that import from this module
export type { AnalysisReport } from '@/types/database';

export interface AnalysisInsight {
  metric: string;
  finding: string;
  delta: string | null;
  recommendation: string;
}

export function useAnalysisReports() {
  const user = useAuthStore((s) => s.user);

  return useQuery<AnalysisReport[]>({
    queryKey: ['analysisReports', user?.id],
    enabled: !!user,
    queryFn: async () => {
      if (!user) return [];

      const { data, error } = await supabase
        .from('analysis_reports')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false })
        .limit(20);

      if (error) throw error;
      return (data ?? []) as AnalysisReport[];
    },
    staleTime: 2 * 60 * 1000,
  });
}

export function useRequestAnalysis() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (input: {
      scopeType: string;
      scopeStart: string;
      scopeEnd: string;
      goals: string[];
    }) => {
      const { data: { session } } = await supabase.auth.getSession();
      if (!session) throw new Error('Not authenticated');

      // Call the backend API
      const apiBaseUrl = import.meta.env.VITE_API_URL || 'http://localhost:8000';
      const response = await fetch(`${apiBaseUrl}/api/ai/analyze`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${session.access_token}`,
        },
        body: JSON.stringify({
          scope_type: input.scopeType,
          scope_start: input.scopeStart,
          scope_end: input.scopeEnd,
          goals: input.goals,
        }),
      });

      if (!response.ok) {
        const errData = await response.json().catch(() => ({ detail: 'Analysis failed' }));
        throw new Error(errData.detail || `Analysis failed (${response.status})`);
      }

      return response.json();
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ['analysisReports'] });
    },
  });
}
