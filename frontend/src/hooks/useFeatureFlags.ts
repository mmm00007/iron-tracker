import { useQuery } from '@tanstack/react-query';
import { API_BASE_URL } from '@/lib/supabase';

export interface FeatureFlags {
  plansEnabled: boolean;
  analysisEnabled: boolean;
  sorenessEnabled: boolean;
  prBoardEnabled: boolean;
  dataExportEnabled: boolean;
  weightSuggestionEnabled: boolean;
  diagnosticsEnabled: boolean;
  advancedAnalyticsEnabled: boolean;
}

const DEFAULT_FLAGS: FeatureFlags = {
  plansEnabled: true,
  analysisEnabled: true,
  sorenessEnabled: true,
  prBoardEnabled: true,
  dataExportEnabled: true,
  weightSuggestionEnabled: true,
  diagnosticsEnabled: true,
  advancedAnalyticsEnabled: false,
};

export function useFeatureFlags(): FeatureFlags {
  const { data } = useQuery<FeatureFlags>({
    queryKey: ['featureFlags'],
    queryFn: async () => {
      // Try to fetch remote flags from backend
      try {
        const res = await fetch(`${API_BASE_URL}/api/rollout-flags`, { signal: AbortSignal.timeout(3000) });
        if (res.ok) {
          const remote = await res.json();
          return { ...DEFAULT_FLAGS, ...remote };
        }
      } catch {
        // Silently fall back to defaults if backend unavailable
      }
      return DEFAULT_FLAGS;
    },
    staleTime: 10 * 60 * 1000, // 10 minutes
    retry: false,
  });

  return data ?? DEFAULT_FLAGS;
}
