import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { useAuthStore } from '@/stores/authStore';

export interface ExerciseFavorite {
  id: string;
  exercise_id: string;
  notes: string | null;
  created_at: string;
}

export function useFavorites() {
  const user = useAuthStore((s) => s.user);

  return useQuery<ExerciseFavorite[]>({
    queryKey: ['favorites', user?.id],
    enabled: !!user,
    queryFn: async () => {
      if (!user) return [];
      const { data, error } = await supabase
        .from('exercise_favorites')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false });

      if (error) throw error;
      return (data ?? []) as ExerciseFavorite[];
    },
    staleTime: 5 * 60 * 1000,
  });
}

export function useFavoriteIds(): Set<string> {
  const { data } = useFavorites();
  return new Set((data ?? []).map((f) => f.exercise_id));
}

export function useToggleFavorite() {
  const queryClient = useQueryClient();
  const user = useAuthStore((s) => s.user);

  return useMutation({
    mutationFn: async ({ exerciseId, isFavorite }: { exerciseId: string; isFavorite: boolean }) => {
      if (!user) throw new Error('Not authenticated');

      if (isFavorite) {
        // Remove favorite
        const { error } = await supabase
          .from('exercise_favorites')
          .delete()
          .eq('user_id', user.id)
          .eq('exercise_id', exerciseId);
        if (error) throw error;
      } else {
        // Add favorite
        const { error } = await supabase
          .from('exercise_favorites')
          .insert({ user_id: user.id, exercise_id: exerciseId });
        if (error) throw error;
      }
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ['favorites'] });
    },
  });
}
