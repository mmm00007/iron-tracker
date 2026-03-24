export interface Profile {
  id: string;
  display_name: string | null;
  experience_level: 'beginner' | 'intermediate' | 'advanced' | null;
  primary_goal: 'strength' | 'hypertrophy' | 'general' | null;
  preferred_weight_unit: 'kg' | 'lb';
  training_days_per_week: number;
  theme_seed_color: string;
  onboarding_completed: boolean;
  created_at: string;
  updated_at: string;
}

export type MovementPattern =
  | 'squat' | 'hip_hinge' | 'lunge'
  | 'horizontal_push' | 'vertical_push'
  | 'horizontal_pull' | 'vertical_pull'
  | 'carry' | 'rotation' | 'isolation' | 'other';

export interface Exercise {
  id: string;
  name: string;
  force: string | null;
  level: string | null;
  mechanic: string | null;
  equipment: string | null;
  category: string | null;
  instructions: string[] | null;
  form_tips: string[] | null;
  image_urls: string[] | null;
  is_custom: boolean;
  created_by: string | null;
  created_at: string;
  updated_at: string;
  // New fields from migration 015
  source_id: string | null;
  movement_pattern: MovementPattern | null;
  variations: string[];
  default_weight: number;
  default_reps: number;
  video_url: string | null;
  notes: string | null;
}

export interface ExerciseMuscle {
  exercise_id: string;
  muscle_group_id: number;
  is_primary: boolean;
  activation_percent: number | null;
}

export interface MuscleGroup {
  id: number;
  name: string;
  name_latin: string | null;
  is_front: boolean;
  svg_path_id: string | null;
}

export interface EquipmentVariant {
  id: string;
  user_id: string;
  exercise_id: string;
  gym_machine_id: string | null;
  name: string;
  equipment_type: string;
  manufacturer: string | null;
  weight_increment: number;
  weight_unit: 'kg' | 'lb';
  seat_settings: Record<string, string>;
  notes: string | null;
  photo_url: string | null;
  last_used_at: string | null;
  created_at: string;
  is_default?: boolean;
  weight_range_min?: number | null;
  weight_range_max?: number | null;
}

export interface WorkoutSet {
  id: string;
  user_id: string;
  exercise_id: string;
  variant_id: string | null;
  weight: number;
  weight_unit: 'kg' | 'lb';
  reps: number;
  rpe: number | null;
  rir: number | null;
  set_type: 'warmup' | 'working' | 'backoff' | 'dropset' | 'amrap' | 'failure';
  tempo: string | null;
  notes: string | null;
  estimated_1rm: number | null;
  logged_at: string;
  synced_at: string | null;
}

export interface PersonalRecord {
  id: string;
  user_id: string;
  exercise_id: string;
  variant_id: string | null;
  record_type: 'estimated_1rm' | 'rep_max' | 'max_weight' | 'max_volume';
  rep_count: number | null;
  value: number;
  set_id: string | null;
  achieved_at: string;
}

export interface Gym {
  id: string;
  name: string;
  address: string | null;
  city: string;
  latitude: number | null;
  longitude: number | null;
  photo_url: string | null;
  machine_count: number;
  is_active: boolean;
  slug: string | null;
  country_code: string;
}

export interface Plan {
  id: string;
  user_id: string;
  name: string;
  description: string | null;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface PlanDay {
  id: string;
  plan_id: string;
  weekday: number; // 0=Monday, 6=Sunday
  label: string | null;
}

export interface PlanItem {
  id: string;
  plan_day_id: string;
  exercise_id: string;
  sort_order: number;
  target_sets: number;
  target_reps_min: number;
  target_reps_max: number;
  target_weight: number | null;
  notes: string | null;
}

export interface GymMachine {
  id: string;
  gym_id: string;
  exercise_id: string;
  name: string;
  equipment_type: string;
  manufacturer: string | null;
  model: string | null;
  weight_range_min: number | null;
  weight_range_max: number | null;
  weight_increment: number;
  weight_unit: 'kg' | 'lb';
  seat_adjustment_labels: string[];
  location_hint: string | null;
  photo_url: string | null;
  notes: string | null;
  sort_order: number;
  is_active: boolean;
  updated_at: string;
}
