"""
VisitOps Intelligence - CSV -> DuckDB pipeline

Full refresh of the core tables from data/synthetic/*.csv. Safe to re-run:
creates any missing tables from db/schema.sql, then replaces all table
contents in a working copy that is swapped in only if every table loads and
row counts match the CSVs, so a failure leaves the database exactly as it
was. KPI views are untouched and pick up the new data.

Usage:
    python scripts/pipeline.py [--db db/careops.duckdb] [--data-dir data/synthetic]
"""
import argparse
import os
import re
import shutil
import sys
import time
from pathlib import Path

import duckdb

# Parents before children, so foreign keys resolve on load
TABLES = ['SERVICE_USERS', 'CARERS', 'VISITS', 'INCIDENTS', 'INVOICES', 'STAFF_ROSTER']


def existing_tables(conn):
    rows = conn.execute(
        "SELECT upper(table_name) FROM information_schema.tables "
        "WHERE table_schema = 'main' AND table_type = 'BASE TABLE'"
    ).fetchall()
    return {r[0] for r in rows}


def ensure_schema(conn, schema_path):
    """Create only the tables that don't exist yet."""
    present = existing_tables(conn)
    created = []
    for statement in schema_path.read_text().split(';'):
        match = re.search(r'CREATE\s+TABLE\s+(\w+)', statement, re.IGNORECASE)
        if match and match.group(1).upper() not in present:
            conn.execute(statement)
            created.append(match.group(1).upper())
    return created


def csv_row_count(path):
    with open(path, encoding='utf-8') as f:
        return sum(1 for line in f if line.strip()) - 1  # minus header


def check_inputs(data_dir):
    missing = [t for t in TABLES if not (data_dir / f'{t}.csv').exists()]
    if missing:
        raise FileNotFoundError(f"Missing CSVs in {data_dir}: {', '.join(missing)}")


def load(conn, data_dir):
    """Replace every table's contents. Returns {table: rows}."""
    # Each DELETE commits on its own: DuckDB checks FKs against committed
    # state, so deleting parents in the same transaction as children fails
    for table in reversed(TABLES):
        conn.execute(f'DELETE FROM {table}')
    counts = {}
    for table in TABLES:
        csv = data_dir / f'{table}.csv'
        conn.execute(f"COPY {table} FROM '{csv.as_posix()}' (FORMAT CSV, HEADER TRUE)")
        loaded = conn.execute(f'SELECT COUNT(*) FROM {table}').fetchone()[0]
        expected = csv_row_count(csv)
        if loaded != expected:
            raise ValueError(f'{table}: loaded {loaded:,} rows but CSV has {expected:,}')
        counts[table] = loaded
    return counts


def run(db_path, data_dir, schema_path):
    """Build into a working copy and swap it in only on success, so a failed
    run never leaves the real database half-loaded."""
    work = db_path.with_name(db_path.name + '.tmp')
    work.unlink(missing_ok=True)
    if db_path.exists():
        with duckdb.connect(str(db_path)) as conn:
            conn.execute('CHECKPOINT')  # flush the WAL so the file copy is complete
        shutil.copy2(db_path, work)
    try:
        with duckdb.connect(str(work)) as conn:
            created = ensure_schema(conn, schema_path)
            counts = load(conn, data_dir)
        os.replace(work, db_path)
    finally:
        work.unlink(missing_ok=True)
    return created, counts


def main():
    parser = argparse.ArgumentParser(description='Load synthetic CSVs into DuckDB')
    parser.add_argument('--db', default='db/careops.duckdb')
    parser.add_argument('--data-dir', default='data/synthetic')
    parser.add_argument('--schema', default='db/schema.sql')
    args = parser.parse_args()

    # Windows consoles default to cp1252, which can't print ✓/✗
    sys.stdout.reconfigure(encoding='utf-8')

    data_dir = Path(args.data_dir)
    start = time.time()

    print('=' * 60)
    print('VisitOps Intelligence - CSV -> DuckDB Pipeline')
    print('=' * 60)

    try:
        check_inputs(data_dir)
        created, counts = run(Path(args.db), data_dir, Path(args.schema))
        print(f"\n✓ Schema: {'created ' + ', '.join(created) if created else 'all tables present'}")
    except Exception as e:
        print(f'\n✗ ERROR: {e}')
        print('  Database unchanged.')
        sys.exit(1)

    print()
    for table, n in counts.items():
        print(f'  {table:20} {n:>10,} rows')
    print(f"\n  {'TOTAL':20} {sum(counts.values()):>10,} rows")
    print(f'\n✓ Loaded into {args.db} in {time.time() - start:.1f}s')


if __name__ == '__main__':
    main()
