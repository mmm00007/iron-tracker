import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { useAuthStore } from '@/stores/authStore';
import type { Profile } from '@/types/database';

const PROFILE_QUERY_KEY = (userId: string) => ['profile', userId];

const DEFAULT_PROFILE: Omit<Profile, 'id' | 'created_at' | 'updated_at'> = {
  display_name: null,
  experience_level: null,
  primary_goal: null,
  preferred_weight_unit: 'kg',
  training_days_per_week: 3,
  theme_seed_color: '#2E75B6',
  onboarding_completed: false,
  timezone: 'UTC',
  day_start_hour: 4,
  height_cm: null,
  cluster_gap_minutes: 90,
  sleep_window_start: null,
  sleep_window_end: null,
  workout_window_start: null,
  workout_window_end: null,
  current_body_weight_kg: null,
  calorie_target: null,
  protein_target_g: null,
  protein_target_g_per_kg: null,
};

export function useProfile() {
  const user = useAuthStore((state) => state.user);
  const userId = user?.id;

  return useQuery<Profile | null>({
    queryKey: PROFILE_QUERY_KEY(userId ?? ''),
    enabled: !!userId,
    queryFn: async () => {
      if (!userId) return null;

      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .maybeSingle();

      if (error) throw error;

      // Auto-create profile on first fetch if it doesn't exist
      if (!data) {
        const newProfile: Profile = {
          ...DEFAULT_PROFILE,
          id: userId,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        };
        const { data: created, error: createError } = await supabase
          .from('profiles')
          .upsert(newProfile, { onConflict: 'id', ignoreDuplicates: true })
          .select()
          .single();

        if (createError) throw createError;
        return created as Profile;
      }

      return data as Profile;
    },
  });
}

export function useUpdateProfile() {
  const queryClient = useQueryClient();
  const user = useAuthStore((state) => state.user);
  const userId = user?.id;

  return useMutation({
    mutationFn: async (updates: Partial<Omit<Profile, 'id' | 'created_at'>>) => {
      if (!userId) throw new Error('Not authenticated');

      const { data, error } = await supabase
        .from('profiles')
        .update({ ...updates, updated_at: new Date().toISOString() })
        .eq('id', userId)
        .select()
        .single();

      if (error) throw error;
      return data as Profile;
    },
    onSuccess: (data) => {
      if (userId) {
        queryClient.setQueryData(PROFILE_QUERY_KEY(userId), data);
      }
    },
  });
}
