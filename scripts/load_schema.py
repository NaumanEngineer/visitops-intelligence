import duckdb
import sys

print("=" * 60)
print("VisitOps Intelligence - Database Setup")
print("=" * 60)

try:
    # Connect to DuckDB (creates careops.duckdb if it doesn't exist)
    print("\n[1/4] Connecting to DuckDB...")
    conn = duckdb.connect('db/careops.duckdb')
    print("      ✓ Connected to db/careops.duckdb")
    
    # Read schema file
    print("\n[2/4] Reading schema.sql...")
    with open('db/schema.sql', 'r') as f:
        schema = f.read()
    print("      ✓ Schema file loaded")
    
    # Execute schema
    print("\n[3/4] Creating tables...")
    conn.execute(schema)
    print("      ✓ All tables created")
    
    # Verify tables
    print("\n[4/4] Verifying database structure...")
    tables = conn.execute("SELECT table_name FROM information_schema.tables WHERE table_schema = 'main' ORDER BY table_name").fetchall()
    
    print(f"\n✓ SUCCESS: Created {len(tables)} tables\n")
    for i, table in enumerate(tables, 1):
        table_name = table[0]
        row_count = conn.execute(f"SELECT COUNT(*) FROM {table_name}").fetchall()[0][0]
        print(f"  {i}. {table_name:20} (0 rows)")
    
    print("\n" + "=" * 60)
    print("Database ready for synthetic data generation")
    print("=" * 60)
    
    conn.close()
    sys.exit(0)

except Exception as e:
    print(f"\n✗ ERROR: {e}")
    sys.exit(1)