import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { useAuthStore } from '@/stores/authStore';

export interface ExerciseFavorite {
  id: string;
  exercise_id: string;
  notes: string | null;
  created_at: string;
}

const LS_KEY = 'iron-tracker-favorites';

function getLocalFavorites(): string[] {
  try {
    return JSON.parse(localStorage.getItem(LS_KEY) || '[]');
  } catch {
    return [];
  }
}

function setLocalFavorites(ids: string[]) {
  localStorage.setItem(LS_KEY, JSON.stringify(ids));
}

export function useFavorites() {
  const user = useAuthStore((s) => s.user);

  return useQuery<ExerciseFavorite[]>({
    queryKey: ['favorites', user?.id],
    enabled: !!user,
    queryFn: async () => {
      if (!user) return [];

      // Try DB first
      try {
        const { data, error } = await supabase
          .from('exercise_favorites')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', { ascending: false });

        if (!error && data) {
          // Sync localStorage with DB
          setLocalFavorites(data.map((f) => f.exercise_id));
          return data as ExerciseFavorite[];
        }
      } catch {
        // Table may not exist — fall through to localStorage
      }

      // Fallback to localStorage
      const localIds = getLocalFavorites();
      return localIds.map((id) => ({
        id: `local-${id}`,
        exercise_id: id,
        notes: null,
        created_at: new Date().toISOString(),
      }));
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

      // Always update localStorage immediately
      const localIds = getLocalFavorites();
      if (isFavorite) {
        setLocalFavorites(localIds.filter((id) => id !== exerciseId));
      } else {
        if (!localIds.includes(exerciseId)) {
          setLocalFavorites([...localIds, exerciseId]);
        }
      }

      // Try DB (may fail if table doesn't exist — that's OK)
      try {
        if (isFavorite) {
          await supabase
            .from('exercise_favorites')
            .delete()
            .eq('user_id', user.id)
            .eq('exercise_id', exerciseId);
        } else {
          await supabase
            .from('exercise_favorites')
            .upsert(
              { user_id: user.id, exercise_id: exerciseId },
              { onConflict: 'user_id,exercise_id' }
            );
        }
      } catch {
        // DB not available — localStorage is authoritative
      }
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ['favorites'] });
    },
  });
}
