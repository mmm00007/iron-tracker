#!/usr/bin/env python3
"""
Download exercise data from yuhonas/free-exercise-db and generate SQL seed files
for the Iron Tracker database.
"""

import json
import os
import urllib.request
from pathlib import Path

# Paths
SCRIPT_DIR = Path(__file__).parent
REPO_ROOT = SCRIPT_DIR.parent
CACHE_DIR = SCRIPT_DIR / '.cache'
CACHE_FILE = CACHE_DIR / 'exercises.json'
SEED_DIR = REPO_ROOT / 'supabase' / 'seed'

# Source data
EXERCISES_URL = 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json'
IMAGES_BASE_URL = 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/'

# Equipment mapping from free-exercise-db to our enum
EQUIPMENT_MAP = {
    'barbell': 'barbell',
    'dumbbell': 'dumbbell',
    'machine': 'machine',
    'cable': 'cable',
    'body only': 'body_only',
    'kettlebells': 'kettlebell',
    'bands': 'bands',
    'medicine ball': 'other',
    'exercise ball': 'other',
    'foam roll': 'other',
    'e-z curl bar': 'barbell',
    'other': 'other',
    'none': 'none',
}

# Category mapping
CATEGORY_MAP = {
    'strength': 'strength',
    'stretching': 'stretching',
    'plyometrics': 'plyometrics',
    'strongman': 'strongman',
    'powerlifting': 'powerlifting',
    'olympic weightlifting': 'olympic_weightlifting',
    'cardio': 'cardio',
}

# Force mapping
FORCE_MAP = {
    'push': 'push',
    'pull': 'pull',
    'static': 'static',
}

# Level mapping
LEVEL_MAP = {
    'beginner': 'beginner',
    'intermediate': 'intermediate',
    'expert': 'expert',
}

# Mechanic mapping
MECHANIC_MAP = {
    'compound': 'compound',
    'isolation': 'isolation',
}

# Muscle name to wger muscle group ID mapping
MUSCLE_NAME_TO_ID = {
    'abdominals': 10,
    'abductors': 8,
    'adductors': 9,
    'biceps': 1,
    'calves': 7,
    'chest': 4,
    'forearms': 5,
    'glutes': 8,
    'hamstrings': 11,
    'lats': 12,
    'lower back': 13,
    'middle back': 12,
    'neck': 14,
    'quadriceps': 10,
    'shoulders': 2,
    'traps': 9,
    'triceps': 5,
}

# Muscle group definitions for seed
MUSCLE_GROUPS = [
    (1,  'biceps',      'biceps brachii',        True,  'muscle-1'),
    (2,  'shoulders',   'deltoideus',             True,  'muscle-2'),
    (4,  'chest',       'pectoralis major',       True,  'muscle-4'),
    (5,  'forearms',    'flexores antebrachii',   True,  'muscle-5'),
    (7,  'calves',      'gastrocnemius',          False, 'muscle-7'),
    (8,  'glutes',      'glutaeus maximus',       False, 'muscle-8'),
    (9,  'traps',       'trapezius',              False, 'muscle-9'),
    (10, 'abs',         'rectus abdominis',       True,  'muscle-10'),
    (11, 'hamstrings',  'biceps femoris',         False, 'muscle-11'),
    (12, 'lats',        'latissimus dorsi',       False, 'muscle-12'),
    (13, 'lower back',  'erector spinae',         False, 'muscle-13'),
    (14, 'neck',        'sternocleidomastoid',    True,  'muscle-14'),
    (15, 'quadriceps',  'quadriceps femoris',     True,  'muscle-15'),
]


def sql_escape(value: str) -> str:
    """Escape a string for use in SQL by doubling single quotes."""
    return value.replace("'", "''")


def sql_string(value) -> str:
    """Wrap a value in SQL string quotes, or return NULL."""
    if value is None:
        return 'NULL'
    return f"'{sql_escape(str(value))}'"


def sql_array(values: list) -> str:
    """Format a Python list as a PostgreSQL ARRAY literal, or NULL if empty."""
    if not values:
        return 'NULL'
    escaped = [f"'{sql_escape(v)}'" for v in values]
    return f"ARRAY[{', '.join(escaped)}]"


def sql_bool(value: bool) -> str:
    return 'true' if value else 'false'


def download_exercises() -> list:
    """Download exercises JSON, using cache if available."""
    CACHE_DIR.mkdir(parents=True, exist_ok=True)

    if CACHE_FILE.exists():
        print(f'Using cached file: {CACHE_FILE}')
    else:
        print(f'Downloading exercises from {EXERCISES_URL}...')
        urllib.request.urlretrieve(EXERCISES_URL, CACHE_FILE)
        print(f'Saved to {CACHE_FILE}')

    with open(CACHE_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)

    print(f'Loaded {len(data)} exercises')
    return data


def transform_exercise(ex: dict) -> dict:
    """Transform a free-exercise-db exercise entry to our schema."""
    raw_equipment = (ex.get('equipment') or '').lower().strip()
    raw_category = (ex.get('category') or '').lower().strip()
    raw_force = (ex.get('force') or '').lower().strip()
    raw_level = (ex.get('level') or '').lower().strip()
    raw_mechanic = (ex.get('mechanic') or '').lower().strip()

    images = ex.get('images') or []
    image_urls = [f"{IMAGES_BASE_URL}{img}" for img in images]

    instructions = ex.get('instructions') or []

    return {
        'name': ex.get('name', '').strip(),
        'force': FORCE_MAP.get(raw_force),
        'level': LEVEL_MAP.get(raw_level),
        'mechanic': MECHANIC_MAP.get(raw_mechanic),
        'equipment': EQUIPMENT_MAP.get(raw_equipment),
        'category': CATEGORY_MAP.get(raw_category),
        'instructions': [i.strip() for i in instructions if i.strip()],
        'image_urls': image_urls,
        'primary_muscles': ex.get('primaryMuscles') or [],
        'secondary_muscles': ex.get('secondaryMuscles') or [],
    }


def generate_muscle_groups_sql() -> str:
    """Generate SQL for inserting muscle groups."""
    lines = ['-- Muscle groups from wger fitness database']
    lines.append('INSERT INTO muscle_groups (id, name, name_latin, is_front, svg_path_id) VALUES')

    value_rows = []
    for mg_id, name, name_latin, is_front, svg_path_id in MUSCLE_GROUPS:
        value_rows.append(
            f"  ({mg_id}, {sql_string(name)}, {sql_string(name_latin)}, "
            f"{sql_bool(is_front)}, {sql_string(svg_path_id)})"
        )

    lines.append(',\n'.join(value_rows))
    lines.append('ON CONFLICT (id) DO NOTHING;')
    lines.append('')
    return '\n'.join(lines)


def generate_exercises_sql(exercises: list) -> str:
    """Generate SQL for inserting exercises."""
    lines = [
        '-- Exercises from yuhonas/free-exercise-db',
        '-- https://github.com/yuhonas/free-exercise-db',
        '',
    ]

    for ex in exercises:
        name = ex['name']
        if not name:
            continue

        force = sql_string(ex['force'])
        level = sql_string(ex['level'])
        mechanic = sql_string(ex['mechanic'])
        equipment = sql_string(ex['equipment'])
        category = sql_string(ex['category'])
        instructions = sql_array(ex['instructions'])
        image_urls = sql_array(ex['image_urls'])

        lines.append(
            f"INSERT INTO exercises (id, name, force, level, mechanic, equipment, category, instructions, image_urls, is_custom, created_by)"
        )
        lines.append(f"VALUES (")
        lines.append(f"  gen_random_uuid(),")
        lines.append(f"  {sql_string(name)},")
        lines.append(f"  {force},")
        lines.append(f"  {level},")
        lines.append(f"  {mechanic},")
        lines.append(f"  {equipment},")
        lines.append(f"  {category},")
        lines.append(f"  {instructions},")
        lines.append(f"  {image_urls},")
        lines.append(f"  false,")
        lines.append(f"  NULL")
        lines.append(f") ON CONFLICT DO NOTHING;")
        lines.append('')

    return '\n'.join(lines)


def generate_exercise_muscles_sql(exercises: list) -> str:
    """Generate SQL for the exercise_muscles junction table."""
    lines = [
        '-- Exercise muscle relationships from yuhonas/free-exercise-db',
        '',
    ]

    for ex in exercises:
        name = ex['name']
        if not name:
            continue

        escaped_name = sql_escape(name)

        for muscle in ex['primary_muscles']:
            muscle_lower = muscle.lower().strip()
            muscle_id = MUSCLE_NAME_TO_ID.get(muscle_lower)
            if muscle_id is None:
                continue
            lines.append(
                f"INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)"
            )
            lines.append(
                f"SELECT e.id, {muscle_id}, true FROM exercises e "
                f"WHERE e.name = '{escaped_name}' AND e.created_by IS NULL"
            )
            lines.append(f"ON CONFLICT DO NOTHING;")
            lines.append('')

        for muscle in ex['secondary_muscles']:
            muscle_lower = muscle.lower().strip()
            muscle_id = MUSCLE_NAME_TO_ID.get(muscle_lower)
            if muscle_id is None:
                continue
            lines.append(
                f"INSERT INTO exercise_muscles (exercise_id, muscle_group_id, is_primary)"
            )
            lines.append(
                f"SELECT e.id, {muscle_id}, false FROM exercises e "
                f"WHERE e.name = '{escaped_name}' AND e.created_by IS NULL"
            )
            lines.append(f"ON CONFLICT DO NOTHING;")
            lines.append('')

    return '\n'.join(lines)


def print_stats(raw_exercises: list, transformed: list) -> None:
    """Print summary statistics."""
    total = len(transformed)
    missing_force = sum(1 for e in transformed if e['force'] is None)
    missing_mechanic = sum(1 for e in transformed if e['mechanic'] is None)
    missing_equipment = sum(1 for e in transformed if e['equipment'] is None)
    missing_category = sum(1 for e in transformed if e['category'] is None)
    missing_level = sum(1 for e in transformed if e['level'] is None)
    no_primary = sum(1 for e in transformed if not e['primary_muscles'])
    no_instructions = sum(1 for e in transformed if not e['instructions'])
    no_images = sum(1 for e in transformed if not e['image_urls'])

    # Muscle coverage
    all_muscles: set = set()
    for e in transformed:
        for m in e['primary_muscles'] + e['secondary_muscles']:
            all_muscles.add(m.lower().strip())
    mapped_muscles = {m for m in all_muscles if m in MUSCLE_NAME_TO_ID}
    unmapped_muscles = all_muscles - mapped_muscles

    print('\n=== Seed Statistics ===')
    print(f'Total exercises:           {total}')
    print(f'Missing force:             {missing_force}')
    print(f'Missing mechanic:          {missing_mechanic}')
    print(f'Missing equipment:         {missing_equipment}')
    print(f'Missing category:          {missing_category}')
    print(f'Missing level:             {missing_level}')
    print(f'No primary muscles:        {no_primary}')
    print(f'No instructions:           {no_instructions}')
    print(f'No images:                 {no_images}')
    print(f'\nMuscle group coverage:')
    print(f'  Unique muscles in data:  {len(all_muscles)}')
    print(f'  Mapped to IDs:           {len(mapped_muscles)}')
    print(f'  Unmapped (skipped):      {len(unmapped_muscles)}')
    if unmapped_muscles:
        print(f'  Unmapped muscles:        {sorted(unmapped_muscles)}')


def main():
    SEED_DIR.mkdir(parents=True, exist_ok=True)

    # Download
    raw_exercises = download_exercises()

    # Transform
    transformed = [transform_exercise(ex) for ex in raw_exercises]
    # Filter out exercises with no name
    transformed = [ex for ex in transformed if ex['name']]

    # Generate SQL files
    print('\nGenerating SQL seed files...')

    muscle_groups_path = SEED_DIR / '001_muscle_groups.sql'
    with open(muscle_groups_path, 'w', encoding='utf-8') as f:
        f.write(generate_muscle_groups_sql())
    print(f'Written: {muscle_groups_path}')

    exercises_path = SEED_DIR / '002_exercises.sql'
    with open(exercises_path, 'w', encoding='utf-8') as f:
        f.write(generate_exercises_sql(transformed))
    print(f'Written: {exercises_path}')

    muscles_path = SEED_DIR / '003_exercise_muscles.sql'
    with open(muscles_path, 'w', encoding='utf-8') as f:
        f.write(generate_exercise_muscles_sql(transformed))
    print(f'Written: {muscles_path}')

    # Stats
    print_stats(raw_exercises, transformed)


if __name__ == '__main__':
    main()
