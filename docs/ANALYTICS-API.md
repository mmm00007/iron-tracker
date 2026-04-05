# Iron Tracker Analytics API Surface

Complete reference for the analytics schema added in migrations 058-098.
All views use `security_invoker = true` (RLS applies). All functions are
`SECURITY DEFINER` with `SET search_path = public, pg_catalog`.

## Tables Created

| Table | Migration | Purpose |
|-------|-----------|---------|
| `volume_landmark_defaults` | 058 | Public reference: MEV/MAV/MRV per muscle × goal × experience (135 rows) |
| `volume_landmarks` | 058 | Per-user volume landmarks (seeded from defaults) |
| `phase_type_defaults` | 059 | Public reference: 8 phase types with targets |
| `training_phases` | 059 | Per-user periodization phases (single active enforced) |
| `cluster_type_defaults` | 060 | Public reference: 14 cluster types with fatigue multipliers |
| `set_clusters` | 060 | Per-user set groupings (supersets, drop sets, etc.) |
| `exercise_joint_stress` | 062 | Per-exercise joint stress levels (reference data) |
| `workload_metrics` | 063 | Per-user daily ACWR with generated `acwr_ratio` + `risk_zone` |
| `workload_alerts` | 063 | Coaching alerts triggered by workload thresholds |
| `muscle_fatigue_state` | 064 | Per-user per-muscle daily fatigue composite (0-100) |
| `pr_events` | 076 | Append-only PR history (auto-populated via trigger) |
| `weekly_volume_snapshots` | 078 | Materialized weekly volume per muscle |
| `achievements` | 083 | Public reference: 26 named achievements |
| `user_achievements` | 083 | Per-user unlock records |
| `program_templates` | 090 | Public reference: 5 pre-built programs |
| `program_template_sessions` | 090 | Sessions within programs |
| `program_template_items` | 090 | Exercise prescriptions per session |
| `exercise_coaching_cues` | 094 | Public reference: 85 structured cues for 10 lifts |
| `cron_job_registry` | 098 | Backend cron schedule (service-role only) |

## Extended Columns (existing tables)

| Table | Columns Added | Migration |
|-------|--------------|-----------|
| `sets` | `cluster_id`, `cluster_position`, `cluster_round`, `eccentric_seconds`, `pause_bottom_seconds`, `concentric_seconds`, `pause_top_seconds`, `rom_quality`, `form_quality`, `tut_seconds` (generated) | 060, 061 |
| `exercises` | `skill_ceiling`, `fatigue_cost`, `cns_demand`, `energy_system`, `typical_rep_range_min/max`, `common_form_errors` | 062 |
| `personal_records` | `body_weight_at_record`, `body_weight_unit`, `pr_context`, `pr_weight_unit`, `dots_score`, `is_competition_lift`, `body_weight_multiple` (generated) | 065, 075 |
| `plans` | `phase_id` | 059 |
| `exercise_effectiveness_scores` | `phase_context`, `phase_id` | 069 |

## Functions (callable from backend)

### Cron Functions (nightly batch)

| Function | Schedule | Args | Migration |
|----------|----------|------|-----------|
| `compute_workload_metrics_all_users(days_back)` | 02:00 UTC | `7` | 071 |
| `compute_muscle_fatigue_state_all_users(date)` | 02:15 UTC | `CURRENT_DATE` | 072 |
| `refresh_weekly_volume_snapshots_all_users(weeks_back)` | 02:30 UTC | `4` | 078 |
| `detect_new_achievements(user_id)` | 02:45 UTC | per-user loop | 083 |

### Per-User Functions (on-demand)

| Function | Returns | Use Case | Migration |
|----------|---------|----------|-----------|
| `initialize_user_volume_landmarks(user_id)` | int | Call on onboarding | 058 |
| `get_user_phase_on_date(user_id, date)` | training_phases row | Phase lookup | 059 |
| `compute_workload_metrics(user_id, start, end)` | int | After session | 071 |
| `compute_workload_metrics_recent(user_id, days)` | int | Quick refresh | 071 |
| `compute_muscle_fatigue_state(user_id, date)` | int | After session | 072 |
| `get_training_recommendations(user_id, date)` | table | Dashboard cards | 074 |
| `get_top_training_priorities(user_id, limit)` | table | Home screen | 074 |
| `classify_lifter_level(e1rm, bw, name, sex)` | text | Strength tier | 075 |
| `generate_warmup_ramp(weight, intensity, bar, increment)` | table | Session prep | 079 |
| `generate_warmup_ramp_for_user(user_id, exercise_id, weight, bar)` | table | Smart warmup | 079 |
| `get_deload_readiness(user_id, date)` | table | Deload decision | 084 |
| `get_progression_options(user_id, exercise_id, limit)` | table | Plateau menu | 085 |
| `detect_pr_stagnation(user_id, weeks, active_window)` | table | Coaching alert | 076 |
| `get_training_streaks(user_id, min_days)` | table | Streak widget | 096 |
| `get_session_readiness(user_id, date)` | table | Morning check | 097 |
| `find_injury_safe_alternatives(user_id, exercise_id, max_stress, limit)` | table | Injury screening | 073 |
| `exercise_injury_risk_score(user_id, exercise_id)` | table | Per-exercise risk | 073 |
| `get_exercise_companions(user_id, exercise_id, limit)` | table | Session suggestions | 095 |
| `predict_session_duration(user_id, exercise_ids[], sets[], startup_min)` | table | Time estimate | 091 |
| `compute_daily_load(rpe, minutes)` | numeric | Foster sRPE | 067 |
| `find_lower_joint_stress_alternatives(exercise_id, joint, max_stress)` | table | Alt finder | 062 |
| `forecast_muscle_recovery(user_id, date)` | table | Recovery timeline | 089 |

## Views (queryable from frontend via Supabase JS)

### Dashboard / Home Screen

| View | Powers | Migration |
|------|--------|-----------|
| `user_dashboard_summary` | One-row state snapshot (phase, ACWR, fatigue, activity) | 067 |
| `user_streak_summary` | Current + best week-streak with tier | 096 |
| `next_likely_unlock` | Soonest achievement forecast | 093 |
| `body_composition_current` | Latest BW/BF/BMI/FFMI | 077 |

### Volume & Landmarks

| View | Powers | Migration |
|------|--------|-----------|
| `weekly_muscle_effective_sets` | Activation-weighted volume per muscle per week | 067 |
| `volume_vs_landmarks_current_week` | Current week vs MEV/MAV/MRV with zone | 067 |
| `volume_vs_baseline` | Current week vs 12-week personal average | 080 |
| `volume_trend_per_muscle` | 12-week REGR_SLOPE trend direction | 078 |

### Training Quality & Comparison

| View | Powers | Migration |
|------|--------|-----------|
| `session_quality_vs_baseline` | Current week quality vs 12-week avg | 080 |
| `consistency_vs_baseline` | Training days + sets vs personal avg | 080 |
| `exercise_this_week_vs_pr` | Per-exercise "near_pr!" surfacing | 080 |
| `weekly_retrospective` | Sunday summary with week_grade + narrative JSONB | 092 |
| `weekly_retrospective_with_deltas` | + week-over-week deltas | 092 |

### Overtraining & Recovery

| View | Powers | Migration |
|------|--------|-----------|
| `current_muscle_fatigue` | Latest fatigue per muscle (heatmap) | 064 |
| `muscle_readiness_forecast` | Days-to-ready per muscle (recovery planner) | 089 |
| `training_monotony_strain` | Foster 2001 monotony + strain per date | 081 |
| `current_overtraining_risk` | Unified ACWR + monotony + strain snapshot | 081 |
| `deload_history` | User's deload timeline with gaps | 084 |

### Phase & Effectiveness

| View | Powers | Migration |
|------|--------|-----------|
| `phase_adherence_check` | Current reps/RPE vs phase targets | 068 |
| `effectiveness_current_phase` | Phase-filtered effectiveness scores | 069 |

### Balance & Diversity

| View | Powers | Migration |
|------|--------|-----------|
| `antagonist_balance_4w` | Antagonist-pair volume ratio + severity | 086 |
| `push_pull_ratio_4w` | Push:pull ratio with recommendation | 086 |
| `movement_pattern_distribution_4w` | Movement-pattern set distribution | 086 |
| `balance_alerts_current` | Actionable imbalance alerts only | 086 |
| `rep_range_distribution_per_exercise` | Per-exercise rep-range histogram | 087 |
| `rep_range_rut_detection` | Stuck-in-one-range detection | 087 |
| `user_rep_range_overview` | Aggregate rep-range distribution | 087 |

### PR & Strength

| View | Powers | Migration |
|------|--------|-----------|
| `pr_progression_timeline` | Chronological PR trajectory + deltas | 076 |
| `pr_momentum_summary` | PR counts in 30/90/365d windows | 076 |
| `user_strength_percentile` | Per-lift classification + delta-to-next-tier | 075 |

### Body Composition

| View | Powers | Migration |
|------|--------|-----------|
| `body_composition_snapshot` | BMI/FFMI/lean/fat per log entry | 077 |
| `body_composition_weekly` | Weekly averages + recomp/bulk/cut detection | 077 |

### Nutrition

| View | Powers | Migration |
|------|--------|-----------|
| `nutrition_training_daily` | Daily nutrition + training + quality join | 082 |
| `protein_adherence_30d` | 30-day protein target hit-rate | 082 |
| `nutrition_impact_on_training` | Protein impact on session quality | 082 |
| `training_vs_rest_day_macros` | Macro split by training vs rest day | 082 |

### Sleep

| View | Powers | Migration |
|------|--------|-----------|
| `sleep_performance_daily` | Day-level sleep + quality join | 088 |
| `sleep_impact_summary` | Good-sleep vs poor-sleep quality delta | 088 |
| `sleep_bucket_summary` | Metrics by sleep-hour bucket | 088 |
| `sleep_debt_14d` | Rolling sleep debt vs 8h target | 088 |

### Exercise Intelligence

| View | Powers | Migration |
|------|--------|-----------|
| `exercise_joint_stress_summary` | Max stress per joint per exercise | 062 |
| `user_daily_safe_exercises` | Injury-filtered exercise catalog | 073 |
| `user_exercise_pacing` | Per-exercise median rest seconds | 091 |
| `user_exercise_cooccurrence` | Exercise-pair co-occurrence counts | 095 |
| `exercise_training_companions` | Companion exercises with confidence | 095 |
| `user_implicit_split` | De-facto training split extraction | 095 |

### Achievements

| View | Powers | Migration |
|------|--------|-----------|
| `achievement_progress` | Per-achievement progress_pct | 083 |
| `achievement_forecasts` | Days-to-unlock projections | 093 |

## Triggers

| Trigger | Table | Action | Migration |
|---------|-------|--------|-----------|
| `sets_validate_cluster_ownership` | sets | Validates cluster belongs to same user | 060 |
| `personal_records_log_event` | personal_records | Auto-logs to pr_events | 076 |

## Seed Data Summary

| Data | Rows | Migration |
|------|------|-----------|
| Volume landmark defaults | 135 (15 muscles × 3 goals × 3 levels) | 058 |
| Phase type defaults | 8 | 059 |
| Cluster type defaults | 14 (with fatigue multipliers) | 060 |
| Biomechanics (exercises) | ~60 exercises enriched | 066, 070 |
| Joint stress mappings | ~70 rows across ~18 compound lifts | 066, 070 |
| Strength standards | 30 (15 lifts × 2 genders) | 065 seed in 025 |
| Coaching cues | 85 across 10 compound lifts | 094 |
| Achievements | 26 across 5 categories × 5 rarity tiers | 083 |
| Program templates | 5 programs, 28 exercise items | 090 |
