-- Workout plans feature: plans, plan_days, plan_items

CREATE TABLE IF NOT EXISTS plans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS plan_days (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id uuid NOT NULL REFERENCES plans(id) ON DELETE CASCADE,
  weekday smallint NOT NULL CHECK (weekday BETWEEN 0 AND 6), -- 0=Monday, 6=Sunday
  label text, -- e.g. "Push Day", "Legs"
  UNIQUE (plan_id, weekday)
);

CREATE TABLE IF NOT EXISTS plan_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_day_id uuid NOT NULL REFERENCES plan_days(id) ON DELETE CASCADE,
  exercise_id uuid NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  sort_order smallint NOT NULL DEFAULT 0,
  target_sets smallint NOT NULL DEFAULT 3,
  target_reps_min smallint NOT NULL DEFAULT 8,
  target_reps_max smallint NOT NULL DEFAULT 12,
  target_weight numeric,
  notes text
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_plans_user_id ON plans(user_id);
CREATE INDEX IF NOT EXISTS idx_plan_days_plan_id ON plan_days(plan_id);
CREATE INDEX IF NOT EXISTS idx_plan_items_plan_day_id ON plan_items(plan_day_id);

-- RLS
ALTER TABLE plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE plan_days ENABLE ROW LEVEL SECURITY;
ALTER TABLE plan_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can CRUD their own plans"
  ON plans FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can CRUD plan_days via their plans"
  ON plan_days FOR ALL
  USING (plan_id IN (SELECT id FROM plans WHERE user_id = auth.uid()))
  WITH CHECK (plan_id IN (SELECT id FROM plans WHERE user_id = auth.uid()));

CREATE POLICY "Users can CRUD plan_items via their plans"
  ON plan_items FOR ALL
  USING (plan_day_id IN (
    SELECT pd.id FROM plan_days pd
    JOIN plans p ON pd.plan_id = p.id
    WHERE p.user_id = auth.uid()
  ))
  WITH CHECK (plan_day_id IN (
    SELECT pd.id FROM plan_days pd
    JOIN plans p ON pd.plan_id = p.id
    WHERE p.user_id = auth.uid()
  ));
