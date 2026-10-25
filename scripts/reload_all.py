import duckdb
import sys

print("Reloading entire database...")

try:
    # Delete and recreate
    conn = duckdb.connect('db/careops.duckdb')
    
    # Create schema
    with open('db/schema.sql', 'r') as f:
        for statement in f.read().split(';'):
            if statement.strip():
                conn.execute(statement)
    
    print("✓ Schema created")
    
    # Load data
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
    print("\n✓ Database ready")
    
except Exception as e:
    print(f"✗ Error: {e}")
    sys.exit(1)