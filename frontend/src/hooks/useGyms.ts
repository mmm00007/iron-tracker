import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { useAuthStore } from '@/stores/authStore';
import type { Gym } from '@/types/database';

const GYMS_QUERY_KEY = (search?: string) => ['gyms', search ?? ''];
const USER_GYMS_QUERY_KEY = (userId: string) => ['user-gyms', userId];

/** Search gyms by name or city. Pass undefined/empty string to list all. */
export function useGyms(searchQuery?: string) {
  return useQuery<Gym[]>({
    queryKey: GYMS_QUERY_KEY(searchQuery),
    queryFn: async () => {
      let query = supabase
        .from('gyms')
        .select('*')
        .eq('is_active', true)
        .order('name', { ascending: true })
        .limit(50);

      if (searchQuery && searchQuery.trim().length > 0) {
        const term = `%${searchQuery.trim()}%`;
        query = query.or(`name.ilike.${term},city.ilike.${term}`);
      }

      const { data, error } = await query;
      if (error) throw error;
      return (data ?? []) as Gym[];
    },
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
}

interface GymMembership {
  id: string;
  user_id: string;
  gym_id: string;
  joined_at: string;
  gym: Gym;
}

/** Get the authenticated user's gym memberships. */
export function useUserGyms() {
  const user = useAuthStore((state) => state.user);
  const userId = user?.id;

  return useQuery<GymMembership[]>({
    queryKey: USER_GYMS_QUERY_KEY(userId ?? ''),
    enabled: !!userId,
    queryFn: async () => {
      if (!userId) return [];

      const { data, error } = await supabase
        .from('user_gym_memberships')
        .select('*, gym:gyms(*)')
        .eq('user_id', userId)
        .order('joined_at', { ascending: false });

      if (error) throw error;
      return (data ?? []) as GymMembership[];
    },
    staleTime: 2 * 60 * 1000,
  });
}

/** Join a gym — creates a gym_memberships row. */
export function useJoinGym() {
  const queryClient = useQueryClient();
  const user = useAuthStore((state) => state.user);
  const userId = user?.id;

  return useMutation({
    mutationFn: async (gymId: string) => {
      if (!userId) throw new Error('Not authenticated');

      const { data, error } = await supabase
        .from('user_gym_memberships')
        .insert({
          user_id: userId,
          gym_id: gymId,
          joined_at: new Date().toISOString(),
        })
        .select()
        .single();

      if (error) throw error;
      return data;
    },
    onSuccess: () => {
      if (userId) {
        void queryClient.invalidateQueries({ queryKey: USER_GYMS_QUERY_KEY(userId) });
      }
    },
  });
}

/** Leave a gym — removes the gym_memberships row. */
export function useLeaveGym() {
  const queryClient = useQueryClient();
  const user = useAuthStore((state) => state.user);
  const userId = user?.id;

  return useMutation({
    mutationFn: async (gymId: string) => {
      if (!userId) throw new Error('Not authenticated');

      const { error } = await supabase
        .from('user_gym_memberships')
        .delete()
        .eq('user_id', userId)
        .eq('gym_id', gymId);

      if (error) throw error;
    },
    onSuccess: () => {
      if (userId) {
        void queryClient.invalidateQueries({ queryKey: USER_GYMS_QUERY_KEY(userId) });
      }
    },
  });
}
