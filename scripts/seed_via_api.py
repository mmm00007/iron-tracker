#!/usr/bin/env python3
"""Execute seed SQL files against Supabase via the Management API."""

import glob
import json
import os
import re
import sys
import urllib.request

PROJECT_ID = os.environ.get("SUPABASE_PROJECT_ID", "")
API_URL = f"https://api.supabase.com/v1/projects/{PROJECT_ID}/database/query"
TOKEN = os.environ.get("SUPABASE_PAT", "")

if not PROJECT_ID or not TOKEN:
    print("Error: SUPABASE_PROJECT_ID and SUPABASE_PAT environment variables must be set.")
    sys.exit(1)
CHUNK_SIZE = 20  # statements per API call


def execute_sql(sql, retries=3):
    """Execute SQL via the Supabase Management API with retry."""
    import time
    data = json.dumps({"query": sql}).encode()
    for attempt in range(retries):
        req = urllib.request.Request(
            API_URL,
            data=data,
            headers={
                "Authorization": f"Bearer {TOKEN}",
                "Content-Type": "application/json",
                "User-Agent": "SupabaseCLI/2.75.0",
                "Accept": "application/json",
            },
            method="POST",
        )
        try:
            with urllib.request.urlopen(req, timeout=120) as resp:
                return True
        except urllib.error.HTTPError as e:
            body = e.read().decode()
            print(f"    HTTP {e.code}: {body[:300]}")
            return False
        except Exception as e:
            if attempt < retries - 1:
                wait = 2 ** (attempt + 1)
                print(f"    Connection error, retrying in {wait}s...")
                time.sleep(wait)
            else:
                print(f"    Failed after {retries} attempts: {e}")
                return False


def split_statements(filepath):
    """Split a SQL file into individual INSERT statements."""
    with open(filepath) as f:
        content = f.read()
    # Split on INSERT INTO boundaries
    parts = re.split(r'(?=INSERT INTO )', content)
    return [s.strip() for s in parts if s.strip().startswith('INSERT')]


def seed_file(filepath, label):
    """Seed a SQL file in chunks."""
    statements = split_statements(filepath)
    total = len(statements)
    ok = 0
    fail = 0

    for i in range(0, total, CHUNK_SIZE):
        batch = statements[i:i + CHUNK_SIZE]
        sql = "\n".join(batch)
        success = execute_sql(sql)
        batch_end = min(i + CHUNK_SIZE, total)
        if success:
            ok += len(batch)
            print(f"  {label}: {batch_end}/{total} OK")
        else:
            fail += len(batch)
            print(f"  {label}: {batch_end}/{total} FAIL")

    return ok, fail


def main():
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    seed_dir = os.path.join(repo_root, "supabase", "seed")

    print("=== Seeding exercises ===")
    ex_ok, ex_fail = seed_file(
        os.path.join(seed_dir, "002_exercises.sql"), "exercises"
    )
    print(f"  Done: {ex_ok} OK, {ex_fail} failed\n")

    print("=== Seeding exercise_muscles ===")
    em_ok, em_fail = seed_file(
        os.path.join(seed_dir, "003_exercise_muscles.sql"), "exercise_muscles"
    )
    print(f"  Done: {em_ok} OK, {em_fail} failed\n")

    print("=== Verifying ===")
    data = json.dumps({"query": "SELECT (SELECT count(*) FROM exercises) as exercises, (SELECT count(*) FROM exercise_muscles) as exercise_muscles, (SELECT count(*) FROM muscle_groups) as muscle_groups;"}).encode()
    req = urllib.request.Request(
        API_URL, data=data,
        headers={
            "Authorization": f"Bearer {TOKEN}",
            "Content-Type": "application/json",
            "User-Agent": "SupabaseCLI/2.75.0",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            print(f"  {json.loads(resp.read())}")
    except Exception as e:
        print(f"  Verify failed: {e}")


if __name__ == "__main__":
    main()
