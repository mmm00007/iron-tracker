import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import type { EquipmentVariant, GymMachine } from '@/types/database';

// Query key factories
const VARIANTS_KEY = (exerciseId: string) => ['variants', exerciseId];
const GYM_MACHINES_KEY = (exerciseId: string) => ['gymMachines', exerciseId];
const MANUFACTURERS_KEY = () => ['manufacturers'];

/**
 * Fetch equipment variants for an exercise, ordered by most recently used.
 */
export function useVariants(exerciseId: string) {
  return useQuery<EquipmentVariant[]>({
    queryKey: VARIANTS_KEY(exerciseId),
    queryFn: async () => {
      const {
        data: { user },
      } = await supabase.auth.getUser();

      if (!user) return [];

      const { data, error } = await supabase
        .from('equipment_variants')
        .select('*')
        .eq('exercise_id', exerciseId)
        .eq('user_id', user.id)
        .order('last_used_at', { ascending: false, nullsFirst: false });

      if (error) throw error;
      return data ?? [];
    },
    enabled: !!exerciseId,
    staleTime: 5 * 60 * 1000,
  });
}

// Create a new variant
export function useCreateVariant() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (
      input: Omit<EquipmentVariant, 'id' | 'user_id' | 'created_at' | 'last_used_at'>
    ) => {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) throw new Error('Not authenticated');

      const { data, error } = await supabase
        .from('equipment_variants')
        .insert({ ...input, user_id: user.id })
        .select()
        .single();

      if (error) throw error;
      return data as EquipmentVariant;
    },
    onMutate: async (input) => {
      await queryClient.cancelQueries({ queryKey: VARIANTS_KEY(input.exercise_id) });

      const previousVariants = queryClient.getQueryData<EquipmentVariant[]>(
        VARIANTS_KEY(input.exercise_id)
      );

      const optimistic: EquipmentVariant = {
        ...input,
        id: `optimistic-${Date.now()}`,
        user_id: 'optimistic',
        created_at: new Date().toISOString(),
        last_used_at: null,
      };

      queryClient.setQueryData<EquipmentVariant[]>(VARIANTS_KEY(input.exercise_id), (old) => [
        ...(old ?? []),
        optimistic,
      ]);

      return { previousVariants };
    },
    onError: (_err, input, context) => {
      if (context?.previousVariants) {
        queryClient.setQueryData(VARIANTS_KEY(input.exercise_id), context.previousVariants);
      }
    },
    onSettled: (_data, _err, input) => {
      queryClient.invalidateQueries({ queryKey: VARIANTS_KEY(input.exercise_id) });
      queryClient.invalidateQueries({ queryKey: MANUFACTURERS_KEY() });
    },
  });
}

// Update a variant
export function useUpdateVariant() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({
      id,
      exerciseId: _exerciseId,
      updates,
    }: {
      id: string;
      exerciseId: string;
      updates: Partial<Omit<EquipmentVariant, 'id' | 'user_id' | 'created_at'>>;
    }) => {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) throw new Error('Not authenticated');

      const { data, error } = await supabase
        .from('equipment_variants')
        .update(updates)
        .eq('id', id)
        .eq('user_id', user.id)
        .select()
        .single();

      if (error) throw error;
      return data as EquipmentVariant;
    },
    onMutate: async ({ id, exerciseId, updates }) => {
      await queryClient.cancelQueries({ queryKey: VARIANTS_KEY(exerciseId) });

      const previousVariants = queryClient.getQueryData<EquipmentVariant[]>(
        VARIANTS_KEY(exerciseId)
      );

      queryClient.setQueryData<EquipmentVariant[]>(VARIANTS_KEY(exerciseId), (old) =>
        (old ?? []).map((v) => (v.id === id ? { ...v, ...updates } : v))
      );

      return { previousVariants };
    },
    onError: (_err, { exerciseId }, context) => {
      if (context?.previousVariants) {
        queryClient.setQueryData(VARIANTS_KEY(exerciseId), context.previousVariants);
      }
    },
    onSettled: (_data, _err, { exerciseId }) => {
      queryClient.invalidateQueries({ queryKey: VARIANTS_KEY(exerciseId) });
      queryClient.invalidateQueries({ queryKey: MANUFACTURERS_KEY() });
    },
  });
}

// Delete a variant
export function useDeleteVariant() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ id, exerciseId }: { id: string; exerciseId: string }) => {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) throw new Error('Not authenticated');

      const { error } = await supabase.from('equipment_variants').delete().eq('id', id).eq('user_id', user.id);
      if (error) throw error;
      return { id, exerciseId };
    },
    onMutate: async ({ id, exerciseId }) => {
      await queryClient.cancelQueries({ queryKey: VARIANTS_KEY(exerciseId) });

      const previousVariants = queryClient.getQueryData<EquipmentVariant[]>(
        VARIANTS_KEY(exerciseId)
      );

      queryClient.setQueryData<EquipmentVariant[]>(VARIANTS_KEY(exerciseId), (old) =>
        (old ?? []).filter((v) => v.id !== id)
      );

      return { previousVariants };
    },
    onError: (_err, { exerciseId }, context) => {
      if (context?.previousVariants) {
        queryClient.setQueryData(VARIANTS_KEY(exerciseId), context.previousVariants);
      }
    },
    onSettled: (_data, _err, { exerciseId }) => {
      queryClient.invalidateQueries({ queryKey: VARIANTS_KEY(exerciseId) });
    },
  });
}

// Clone a gym machine to a user variant
export function useCloneGymMachine() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({
      gymMachine,
      exerciseId,
    }: {
      gymMachine: GymMachine;
      exerciseId: string;
    }) => {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) throw new Error('Not authenticated');

      const newVariant = {
        user_id: user.id,
        exercise_id: exerciseId,
        gym_machine_id: gymMachine.id,
        name: gymMachine.name,
        equipment_type: gymMachine.equipment_type,
        manufacturer: gymMachine.manufacturer,
        weight_increment: gymMachine.weight_increment,
        weight_unit: 'kg' as const,
        seat_settings: {},
        notes: null,
        photo_url: gymMachine.photo_url,
      };

      const { data, error } = await supabase
        .from('equipment_variants')
        .insert(newVariant)
        .select()
        .single();

      if (error) throw error;
      return data as EquipmentVariant;
    },
    onMutate: async ({ gymMachine, exerciseId }) => {
      await queryClient.cancelQueries({ queryKey: VARIANTS_KEY(exerciseId) });

      const previousVariants = queryClient.getQueryData<EquipmentVariant[]>(
        VARIANTS_KEY(exerciseId)
      );

      const optimistic: EquipmentVariant = {
        id: `optimistic-${Date.now()}`,
        user_id: 'optimistic',
        exercise_id: exerciseId,
        gym_machine_id: gymMachine.id,
        name: gymMachine.name,
        equipment_type: gymMachine.equipment_type,
        manufacturer: gymMachine.manufacturer,
        weight_increment: gymMachine.weight_increment,
        weight_unit: 'kg',
        seat_settings: {},
        notes: null,
        photo_url: gymMachine.photo_url,
        last_used_at: null,
        created_at: new Date().toISOString(),
      };

      queryClient.setQueryData<EquipmentVariant[]>(VARIANTS_KEY(exerciseId), (old) => [
        ...(old ?? []),
        optimistic,
      ]);

      return { previousVariants };
    },
    onError: (_err, { exerciseId }, context) => {
      if (context?.previousVariants) {
        queryClient.setQueryData(VARIANTS_KEY(exerciseId), context.previousVariants);
      }
    },
    onSettled: (_data, _err, { exerciseId }) => {
      queryClient.invalidateQueries({ queryKey: VARIANTS_KEY(exerciseId) });
      queryClient.invalidateQueries({ queryKey: GYM_MACHINES_KEY(exerciseId) });
    },
  });
}

// Fetch gym machines for an exercise at user's gyms
export function useGymMachines(exerciseId: string) {
  return useQuery<GymMachine[]>({
    queryKey: GYM_MACHINES_KEY(exerciseId),
    enabled: !!exerciseId,
    queryFn: async () => {
      const { data, error } = await supabase
        .from('gym_machines')
        .select('*')
        .eq('exercise_id', exerciseId)
        .eq('is_active', true);

      if (error) throw error;
      return data ?? [];
    },
    staleTime: 5 * 60 * 1000,
  });
}

// Fetch unique manufacturers the user has entered (for autocomplete)
export function useManufacturers() {
  return useQuery<string[]>({
    queryKey: MANUFACTURERS_KEY(),
    queryFn: async () => {
      const {
        data: { user },
      } = await supabase.auth.getUser();

      if (!user) return [];

      const { data, error } = await supabase
        .from('equipment_variants')
        .select('manufacturer')
        .eq('user_id', user.id)
        .not('manufacturer', 'is', null);

      if (error) throw error;

      const unique = Array.from(
        new Set((data ?? []).map((r) => r.manufacturer).filter(Boolean) as string[])
      ).sort();

      return unique;
    },
    staleTime: 5 * 60 * 1000,
  });
}
