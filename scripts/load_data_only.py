import duckdb

conn = duckdb.connect('db/careops.duckdb')

tables = [
    ('SERVICE_USERS', 'data/synthetic/SERVICE_USERS.csv'),
    ('CARERS', 'data/synthetic/CARERS.csv'),
    ('VISITS', 'data/synthetic/VISITS.csv'),
    ('INCIDENTS', 'data/synthetic/INCIDENTS.csv'),
    ('INVOICES', 'data/synthetic/INVOICES.csv'),
    ('STAFF_ROSTER', 'data/synthetic/STAFF_ROSTER.csv'),
]

for table, csv in tables:
    conn.execute(f"COPY {table} FROM '{csv}' (FORMAT CSV, HEADER TRUE)")
    count = conn.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
    print(f"✓ {table}: {count:,} rows")

conn.close()
print("\n✓ Done")