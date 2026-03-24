import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import { useAuthStore } from '@/stores/authStore';
import type { Plan, PlanDay, PlanItem } from '@/types/database';

export interface PlanDayWithItems extends PlanDay {
  items: (PlanItem & { exerciseName?: string })[];
}

export interface PlanWithDays extends Plan {
  days: PlanDayWithItems[];
}

const WEEKDAY_LABELS = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
export { WEEKDAY_LABELS };

// ─── Fetch all plans ───────────────────────────────────────────────────────

export function usePlans() {
  const user = useAuthStore((s) => s.user);
  return useQuery<PlanWithDays[]>({
    queryKey: ['plans', user?.id],
    enabled: !!user,
    queryFn: async () => {
      if (!user) return [];

      const { data: plans, error } = await supabase
        .from('plans')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false });

      if (error) throw error;
      if (!plans || plans.length === 0) return [];

      const planIds = plans.map((p) => p.id);
      const { data: days, error: daysError } = await supabase
        .from('plan_days')
        .select('*')
        .in('plan_id', planIds)
        .order('weekday', { ascending: true });

      if (daysError) throw daysError;

      const dayIds = (days ?? []).map((d) => d.id);
      let items: (PlanItem & { exercises?: { name: string } | null })[] = [];
      if (dayIds.length > 0) {
        const { data: itemsData, error: itemsError } = await supabase
          .from('plan_items')
          .select('*, exercises(name)')
          .in('plan_day_id', dayIds)
          .order('sort_order', { ascending: true });

        if (itemsError) throw itemsError;
        items = (itemsData ?? []) as typeof items;
      }

      // Build the plan tree
      return (plans as Plan[]).map((plan) => {
        const planDays = (days ?? [])
          .filter((d) => d.plan_id === plan.id)
          .map((day) => ({
            ...day,
            items: items
              .filter((item) => item.plan_day_id === day.id)
              .map((item) => ({
                ...item,
                exerciseName:
                  item.exercises && typeof item.exercises === 'object'
                    ? (item.exercises as { name: string }).name
                    : undefined,
              })),
          })) as PlanDayWithItems[];

        return { ...plan, days: planDays };
      });
    },
    staleTime: 2 * 60 * 1000,
  });
}

// ─── Create plan ───────────────────────────────────────────────────────────

export function useCreatePlan() {
  const queryClient = useQueryClient();
  const user = useAuthStore((s) => s.user);

  return useMutation({
    mutationFn: async (input: { name: string; description?: string }) => {
      if (!user) throw new Error('Not authenticated');

      const { data, error } = await supabase
        .from('plans')
        .insert({
          user_id: user.id,
          name: input.name,
          description: input.description ?? null,
        })
        .select()
        .single();

      if (error) throw error;
      return data as Plan;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ['plans'] });
    },
  });
}

// ─── Delete plan ───────────────────────────────────────────────────────────

export function useDeletePlan() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (planId: string) => {
      const { error } = await supabase.from('plans').delete().eq('id', planId);
      if (error) throw error;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ['plans'] });
    },
  });
}

// ─── Upsert plan day ──────────────────────────────────────────────────────

export function useUpsertPlanDay() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (input: { planId: string; weekday: number; label?: string }) => {
      const { data, error } = await supabase
        .from('plan_days')
        .upsert(
          { plan_id: input.planId, weekday: input.weekday, label: input.label ?? null },
          { onConflict: 'plan_id,weekday' }
        )
        .select()
        .single();

      if (error) throw error;
      return data as PlanDay;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ['plans'] });
    },
  });
}

// ─── Add plan item ────────────────────────────────────────────────────────

export function useAddPlanItem() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (input: {
      planDayId: string;
      exerciseId: string;
      targetSets?: number;
      targetRepsMin?: number;
      targetRepsMax?: number;
      targetWeight?: number;
    }) => {
      const { data, error } = await supabase
        .from('plan_items')
        .insert({
          plan_day_id: input.planDayId,
          exercise_id: input.exerciseId,
          target_sets: input.targetSets ?? 3,
          target_reps_min: input.targetRepsMin ?? 8,
          target_reps_max: input.targetRepsMax ?? 12,
          target_weight: input.targetWeight ?? null,
        })
        .select()
        .single();

      if (error) throw error;
      return data as PlanItem;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ['plans'] });
    },
  });
}

// ─── Delete plan item ─────────────────────────────────────────────────────

export function useDeletePlanItem() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (itemId: string) => {
      const { error } = await supabase.from('plan_items').delete().eq('id', itemId);
      if (error) throw error;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ['plans'] });
    },
  });
}

// ─── Today's plan ─────────────────────────────────────────────────────────

export function useTodaysPlan() {
  const { data: plans } = usePlans();
  const todayWeekday = (new Date().getDay() + 6) % 7; // JS: 0=Sun → our 0=Mon

  if (!plans) return null;

  const activePlan = plans.find((p) => p.is_active);
  if (!activePlan) return null;

  const todayDay = activePlan.days.find((d) => d.weekday === todayWeekday);
  if (!todayDay || todayDay.items.length === 0) return null;

  return { plan: activePlan, day: todayDay };
}
