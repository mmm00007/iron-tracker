export interface Profile {
  id: string;
  display_name: string | null;
  experience_level: 'beginner' | 'intermediate' | 'advanced' | null;
  primary_goal: 'strength' | 'hypertrophy' | 'general' | null;
  preferred_weight_unit: 'kg' | 'lb';
  training_days_per_week: number;
  theme_seed_color: string;
  onboarding_completed: boolean;
  timezone: string;
  day_start_hour: number;
  height_cm: number | null;
  cluster_gap_minutes: number;
  // Fields from migration 023
  sleep_window_start: string | null;
  sleep_window_end: string | null;
  workout_window_start: string | null;
  workout_window_end: string | null;
  // Fields from migration 025
  current_body_weight_kg: number | null;
  // Fields from migration 032
  calorie_target: number | null;
  protein_target_g: number | null;
  protein_target_g_per_kg: number | null;
  created_at: string;
  updated_at: string;
}

export type MovementPattern =
  | 'squat' | 'hip_hinge' | 'lunge'
  | 'horizontal_push' | 'vertical_push'
  | 'horizontal_pull' | 'vertical_pull'
  | 'carry' | 'rotation' | 'isolation' | 'other'
  // Extended in migration 035
  | 'single_leg_squat' | 'lateral_raise' | 'elbow_flexion' | 'incline_press';

export type ExerciseType = 'push' | 'pull' | 'legs' | 'core' | 'cardio' | 'full_body';

export type Laterality = 'bilateral' | 'unilateral' | 'both';

export type ContraindicationTag =
  | 'shoulder_impingement' | 'lower_back_herniation' | 'knee_anterior'
  | 'wrist_strain' | 'elbow_strain' | 'neck_compression'
  | 'rotator_cuff' | 'hip_impingement';

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
  source_id: string | null;
  movement_pattern: MovementPattern | null;
  variations: string[];
  default_weight: number;
  default_reps: number;
  video_url: string | null;
  notes: string | null;
  // Fields from migration 019
  laterality: Laterality | null;
  aliases: string[];
  exercise_type: ExerciseType | null;
  // Fields from migration 021
  difficulty_level: 1 | 2 | 3 | 4 | 5 | null;
  contraindications: ContraindicationTag[];
  // Fields from migration 025
  default_rest_seconds: number | null;
  is_compound: boolean | null;
  // Fields from migration 039
  equipment_category: EquipmentCategory | null;
  // Fields from migration 042 (generated column)
  equipment_class: EquipmentClass | null;
}

/** Broad equipment grouping for top-level filters (generated from equipment_category). */
export type EquipmentClass = 'machine' | 'freeweight' | 'bodyweight';

/** Granular equipment subcategory (13 values). */
export type EquipmentCategory =
  | 'barbell' | 'dumbbell' | 'machine' | 'cable' | 'bodyweight'
  | 'kettlebell' | 'band' | 'smith_machine' | 'plate_loaded'
  | 'trap_bar' | 'ez_bar' | 'suspension' | 'other';

export type MuscleFunction = 'agonist' | 'synergist' | 'stabilizer';

export interface ExerciseMuscle {
  exercise_id: string;
  muscle_group_id: number;
  is_primary: boolean;
  activation_percent: number | null;
  function_type: MuscleFunction | null;
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
  // Fields from migration 023
  rating?: 1 | 2 | 3 | 4 | 5 | null;
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
  updated_at: string;
  // Fields from migration 019
  duration_seconds: number | null;
  distance_meters: number | null;
  distance_unit: 'm' | 'km' | 'mi' | 'yd' | null;
  training_date: string | null;
  side: 'left' | 'right' | null;
  // Fields from migration 021
  rest_seconds: number | null;
  workout_cluster_id: string | null;
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

export type PlanGoal = 'strength' | 'hypertrophy' | 'endurance' | 'power' | 'general' | 'body_recomposition';

export interface Plan {
  id: string;
  user_id: string;
  name: string;
  description: string | null;
  goal: PlanGoal | null;
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
  // Fields from migration 021
  target_rpe: number | null;
  target_rir: number | null;
  rest_target_seconds: number | null;
  tempo_prescription: string | null;
  superset_group: number | null;
  // Fields from migration 023
  target_weight_min: number | null;
  target_weight_max: number | null;
  target_weight_pct: number | null;
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
  // Fields from migration 039 + 042
  equipment_category: EquipmentCategory | null;
  equipment_class: EquipmentClass | null;
  updated_at: string;
}

// ─── New types from migration 019 ───────────────────────────────────────────

export interface BodyWeightLog {
  id: string;
  user_id: string;
  weight: number;
  weight_unit: 'kg' | 'lb';
  body_fat_pct: number | null;
  source: 'manual' | 'smart_scale' | 'import';
  notes: string | null;
  logged_at: string;
  updated_at: string;
}

export interface WorkoutFeedback {
  id: string;
  user_id: string;
  training_date: string;
  session_rpe: number | null;
  readiness_score: number | null;
  prior_sleep_quality: number | null;
  sleep_hours: number | null;
  stress_level: number | null;
  notes: string | null;
  created_at: string;
  updated_at: string;
}

export type SubstitutionType = 'same_pattern' | 'same_muscles' | 'regression' | 'progression';

export interface ExerciseSubstitution {
  id: string;
  source_exercise_id: string;
  target_exercise_id: string;
  substitution_type: SubstitutionType;
  similarity_score: number | null;
  notes: string | null;
  // Fields from migration 023
  progression_order: number | null;
  prerequisite_1rm_ratio: number | null;
}

export type ScopeGrouping = 'training_day' | 'session' | 'week' | 'cluster' | 'mesocycle' | 'custom';

export interface RecommendationScope {
  id: string;
  user_id: string;
  grouping: ScopeGrouping;
  date_start: string | null;
  date_end: string | null;
  included_set_types: string[];
  comparison_scope_id: string | null;
  metadata: Record<string, unknown>;
  created_at: string;
}

export interface ExerciseUsageStats {
  user_id: string;
  exercise_id: string;
  sets_7d: number;
  sets_30d: number;
  sets_90d: number;
  sets_all_time: number;
  last_used_at: string | null;
}

// ─── New types from migration 021 ───────────────────────────────────────────

export interface ExerciseTag {
  id: string;
  user_id: string;
  exercise_id: string;
  tag: string;
  created_at: string;
}

export interface TrainingVolumeTarget {
  id: string;
  user_id: string;
  muscle_group_id: number;
  target_mv: number | null;
  target_mev: number | null;
  target_mav: number | null;
  target_mrv: number | null;
  notes: string | null;
  updated_at: string;
}

export type MesocyclePhase = 'hypertrophy' | 'strength' | 'peaking' | 'deload' | 'transition' | 'general';

export interface Mesocycle {
  id: string;
  user_id: string;
  name: string;
  phase: MesocyclePhase;
  start_date: string;
  end_date: string | null;
  target_weeks: number | null;
  plan_id: string | null;
  notes: string | null;
  created_at: string;
  updated_at: string;
}

export type ReportType = 'recommendation' | 'weekly_trend' | 'deload_alert' | 'pr_analysis' | 'balance_report' | 'volume_check';
export type ReportStatus = 'ready' | 'failed' | 'in_progress' | 'stale';

export interface AnalysisReport {
  id: string;
  user_id: string;
  scope_type: 'day' | 'week' | 'month';
  scope_start: string;
  scope_end: string;
  goals: string[];
  summary: string;
  insights: Record<string, unknown>;
  recommendation_scope_id: string | null;
  evidence: Record<string, unknown>[];
  report_type: ReportType | null;
  status: ReportStatus;
  created_at: string;
}

export interface TrainingDaySummary {
  user_id: string;
  training_date: string;
  total_sets: number;
  working_sets: number;
  total_reps: number;
  total_volume_kg: number;
  distinct_exercises: number;
  avg_rpe: number | null;
  avg_rest_seconds: number | null;
  first_set_at: string;
  last_set_at: string;
  duration_minutes: number;
  cluster_count: number;
  best_estimated_1rm: number | null;
}

// ─── New types from migration 023 ───────────────────────────────────────────

export interface PlanAdherenceLog {
  id: string;
  user_id: string;
  plan_id: string;
  plan_day_id: string | null;
  training_date: string;
  planned_sets: number;
  completed_sets: number;
  adherence_ratio: number | null;
  items_complete: number;
  items_partial: number;
  items_skipped: number;
  surplus_sets: number;
  computed_at: string;
}

export type PairStrength = 'strong' | 'moderate';

export interface MuscleAntagonistPair {
  id: number;
  muscle_a_id: number;
  muscle_b_id: number;
  pair_name: string;
  pair_strength: PairStrength;
}

export interface UserExerciseNotes {
  id: string;
  user_id: string;
  exercise_id: string;
  form_cues: string | null;
  injury_notes: string | null;
  personal_best_context: string | null;
  preferred_grip: string | null;
  preferred_stance: string | null;
  preferred_rep_range: string | null;
  created_at: string;
  updated_at: string;
}

export type MilestoneUnit = 'kg' | 'lb' | 'sets' | 'reps' | 'days' | 'weeks' | 'ratio';

export interface TrainingMilestone {
  id: string;
  user_id: string;
  milestone_type: string;
  exercise_id: string | null;
  value: number | null;
  unit: MilestoneUnit | null;
  achieved_at: string;
  body_weight_at: number | null;
  notes: string | null;
}

export interface EquipmentUsageStats {
  user_id: string;
  equipment_variant_id: string;
  exercise_id: string;
  sets_7d: number;
  sets_30d: number;
  sets_90d: number;
  sets_all_time: number;
  last_used_at: string | null;
  rank_7d: number;
  rank_30d: number;
  rank_90d: number;
}

// ─── New types from migration 025 ───────────────────────────────────────────

export type MeasurementType = 'circumference' | 'skinfold';

export type CircumferenceSite =
  | 'neck' | 'shoulder' | 'chest' | 'arm_relaxed' | 'arm_flexed'
  | 'forearm' | 'waist' | 'hip' | 'thigh' | 'calf';

export type SkinfoldSite =
  | 'tricep_sf' | 'subscapular_sf' | 'midaxillary_sf'
  | 'suprailiac_sf' | 'abdomen_sf' | 'chest_sf' | 'thigh_sf';

export interface BodyMeasurement {
  id: string;
  user_id: string;
  measured_at: string;
  measurement_type: MeasurementType;
  site: CircumferenceSite | SkinfoldSite;
  value: number;
  unit: 'cm' | 'in' | 'mm';
  side: 'left' | 'right' | null;
  notes: string | null;
  created_at: string;
  updated_at: string;
}

export type StrengthTier = 'beginner' | 'novice' | 'intermediate' | 'advanced' | 'elite';

export interface StrengthStandard {
  id: number;
  exercise_name: string;
  sex: 'male' | 'female';
  reference_bw_kg: number;
  beginner_1rm: number;
  novice_1rm: number;
  intermediate_1rm: number;
  advanced_1rm: number;
  elite_1rm: number;
  beginner_bw_ratio: number | null;
  novice_bw_ratio: number | null;
  intermediate_bw_ratio: number | null;
  advanced_bw_ratio: number | null;
  elite_bw_ratio: number | null;
  source: string;
  notes: string | null;
}

// ─── View types from migration 025 ──────────────────────────────────────────

export interface ExercisePerformanceSummary {
  user_id: string;
  exercise_id: string;
  exercise_name: string;
  movement_pattern: MovementPattern | null;
  mechanic: string | null;
  is_compound: boolean | null;
  total_sets: number;
  working_sets: number;
  best_weight: number | null;
  best_e1rm: number | null;
  last_weight: number | null;
  last_reps: number | null;
  avg_rpe_all: number | null;
  avg_rpe_30d: number | null;
  first_logged_at: string;
  last_logged_at: string;
  distinct_training_days: number;
  sessions_7d: number;
  sessions_30d: number;
}

export interface WeeklyMuscleVolume {
  user_id: string;
  week_start: string;
  muscle_group_id: number;
  muscle_group_name: string;
  weighted_sets: number;
  raw_sets: number;
  weighted_volume_kg: number;
  avg_rpe: number | null;
}

export interface MovementPatternBalance {
  user_id: string;
  week_start: string;
  horizontal_push_sets: number;
  horizontal_pull_sets: number;
  vertical_push_sets: number;
  vertical_pull_sets: number;
  knee_dominant_sets: number;
  hip_dominant_sets: number;
  carry_sets: number;
  rotation_sets: number;
  isolation_sets: number;
  h_push_pull_ratio: number | null;
  v_push_pull_ratio: number | null;
  knee_hip_ratio: number | null;
  total_upper_sets: number;
  total_lower_sets: number;
}

// ─── New types from migration 027 ───────────────────────────────────────────

export interface UserExercisePreference {
  id: string;
  user_id: string;
  exercise_id: string;
  rating: 1 | 2 | 3 | 4 | 5 | null;
  is_favorite: boolean;
  default_weight: number | null;
  default_reps: number | null;
  default_rest_seconds: number | null;
  notes: string | null;
  created_at: string;
  updated_at: string;
}

export type BalancePeriodType = 'week' | 'month';

export interface WorkloadBalanceScore {
  id: string;
  user_id: string;
  period_type: BalancePeriodType;
  period_start: string;
  period_end: string;
  shannon_entropy: number | null;
  normalized_entropy: number | null;
  push_pull_ratio: number | null;
  upper_lower_ratio: number | null;
  h_push_pull_ratio: number | null;
  trained_muscle_count: number | null;
  total_weighted_sets: number | null;
  dominant_muscle_id: number | null;
  muscle_distribution: Record<string, number>;
  computed_at: string;
}

// ─── View types from migration 027 ──────────────────────────────────────────

export interface MuscleActivationWeight {
  exercise_id: string;
  muscle_group_id: number;
  is_primary: boolean;
  function_type: MuscleFunction | null;
  effective_activation_pct: number;
  volume_weight_factor: number;
  muscle_group_name: string;
  muscle_is_front: boolean;
}

// ─── New types from migration 031 ───────────────────────────────────────────

export type TemplateSourceType = 'manual' | 'from_session' | 'from_plan_day';

export interface WorkoutTemplate {
  id: string;
  user_id: string;
  name: string;
  description: string | null;
  source_type: TemplateSourceType;
  source_date: string | null;
  source_plan_day_id: string | null;
  is_pinned: boolean;
  use_count: number;
  last_used_at: string | null;
  created_at: string;
  updated_at: string;
}

export interface WorkoutTemplateItem {
  id: string;
  template_id: string;
  exercise_id: string;
  variant_id: string | null;
  sort_order: number;
  target_sets: number | null;
  target_reps_min: number | null;
  target_reps_max: number | null;
  target_weight: number | null;
  target_rpe: number | null;
  target_rir: number | null;
  rest_seconds: number | null;
  superset_group: number | null;
  notes: string | null;
}

// ─── New types from migration 032 ───────────────────────────────────────────

export type NutritionSource = 'manual' | 'myfitnesspal' | 'cronometer' | 'apple_health' | 'other';

export interface NutritionLog {
  id: string;
  user_id: string;
  logged_date: string;
  calories_kcal: number | null;
  protein_g: number | null;
  carbs_g: number | null;
  fat_g: number | null;
  fiber_g: number | null;
  water_ml: number | null;
  source: NutritionSource;
  notes: string | null;
  created_at: string;
  updated_at: string;
}

export interface NutritionTrainingCorrelation {
  user_id: string;
  logged_date: string;
  calories_kcal: number | null;
  protein_g: number | null;
  carbs_g: number | null;
  fat_g: number | null;
  fiber_g: number | null;
  protein_per_kg: number | null;
  total_sets: number;
  working_sets: number;
  total_volume_kg: number;
  avg_rpe: number | null;
  duration_minutes: number;
  best_estimated_1rm: number | null;
}

// ─── New types from migration 033 ───────────────────────────────────────────

export type SnapshotPeriodType = 'week' | 'month';

export interface ExerciseProgressSnapshot {
  id: string;
  user_id: string;
  exercise_id: string;
  period_type: SnapshotPeriodType;
  period_start: string;
  period_end: string;
  best_e1rm: number | null;
  best_e1rm_reps: number | null;
  best_weight: number | null;
  best_reps: number | null;
  total_sets: number;
  working_sets: number;
  total_volume_kg: number | null;
  avg_rpe: number | null;
  avg_rest_seconds: number | null;
  training_days: number;
  computed_at: string;
}

// ─── New types from migration 036 ───────────────────────────────────────────

export type WarmupContext = 'mobility' | 'activation' | 'pattern_rehearsal' | 'corrective';

export interface ExerciseWarmupPrerequisite {
  id: string;
  exercise_id: string;
  warmup_exercise_id: string | null;
  warmup_name: string;
  sort_order: number;
  duration_seconds: number | null;
  reps: number | null;
  context: WarmupContext;
  notes: string | null;
  created_at: string;
}

export type DataQuality = 'insufficient' | 'preliminary' | 'reliable';

export type EffectivenessRecommendation =
  | 'keep'
  | 'increase_volume'
  | 'decrease_volume'
  | 'consider_substitution'
  | 'new_exercise'
  | 'insufficient_data';

export interface ExerciseEffectivenessScore {
  id: string;
  user_id: string;
  exercise_id: string;
  window_weeks: number;
  period_start: string;
  period_end: string;
  e1rm_slope: number | null;
  e1rm_ci_lower: number | null;
  e1rm_ci_upper: number | null;
  volume_efficiency: number | null;
  perceived_recovery_cost: number | null;
  performance_recovery_cost: number | null;
  consistency_score: number | null;
  movement_category: string | null;
  effectiveness_rank: number | null;
  data_points: number;
  data_quality: DataQuality;
  recommendation: EffectivenessRecommendation | null;
  computed_at: string;
}

export type TrainingGoal = 'strength' | 'hypertrophy' | 'endurance' | 'general';

export interface UserRestRecommendation {
  id: string;
  user_id: string;
  exercise_id: string;
  training_goal: TrainingGoal;
  optimal_rest_seconds: number | null;
  min_effective_rest: number | null;
  max_useful_rest: number | null;
  spearman_rho: number | null;
  p_value: number | null;
  set_position_controlled: boolean;
  sessions_sampled: number;
  set_pairs_sampled: number;
  confidence: number | null;
  data_quality: DataQuality;
  computed_at: string;
}

export interface SessionQualityScore {
  id: string;
  user_id: string;
  training_date: string;
  workout_cluster_id: string | null;
  quality_score: number;
  volume_score: number | null;
  intensity_score: number | null;
  completion_score: number | null;
  density_score: number | null;
  progression_score: number | null;
  rest_score: number | null;
  exercises_progressed: number;
  exercises_regressed: number;
  exercises_maintained: number;
  exercises_total: number;
  total_working_sets: number | null;
  total_volume_kg: number | null;
  session_duration_min: number | null;
  avg_rpe: number | null;
  session_rpe: number | null;
  scoring_version: number;
  computed_at: string;
}

// ─── New types from migration 039 ───────────────────────────────────────────

export interface UserExerciseOverride {
  id: string;
  user_id: string;
  exercise_id: string;
  custom_name: string | null;
  custom_form_cues: string | null;
  custom_notes: string | null;
  default_weight_override: number | null;
  default_reps_override: number | null;
  preferred_equipment_category: EquipmentCategory | null;
  personal_difficulty: 1 | 2 | 3 | 4 | 5 | null;
  created_at: string;
  updated_at: string;
}

export interface ExerciseEquipment {
  id: string;
  exercise_id: string;
  equipment_category: EquipmentCategory;
  is_default: boolean;
  notes: string | null;
}

export interface ExerciseMuscleSummary {
  exercise_id: string;
  exercise_name: string;
  equipment_category: EquipmentCategory | null;
  equipment_class: EquipmentClass | null;
  is_compound: boolean | null;
  difficulty_level: number | null;
  movement_pattern: MovementPattern | null;
  primary_muscles: string;
  secondary_muscles: string | null;
  max_activation_pct: number | null;
}

export interface GymExerciseCatalogEntry {
  gym_id: string;
  gym_name: string;
  exercise_id: string;
  exercise_name: string;
  equipment_category: EquipmentCategory | null;
  equipment_class: EquipmentClass | null;
  machine_name: string | null;
  primary_muscles: string | null;
}
