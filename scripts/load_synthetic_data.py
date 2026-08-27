import duckdb
import os
import sys

print("=" * 70)
print("VisitOps Intelligence - Load Synthetic Data")
print("=" * 70)

try:
    # Connect to DuckDB
    print("\n[1/7] Connecting to DuckDB...")
    conn = duckdb.connect('db/careops.duckdb')
    print("      ✓ Connected to db/careops.duckdb")
    
    # Define CSV files and their corresponding tables
    files_to_load = [
        ('data/synthetic/SERVICE_USERS.csv', 'SERVICE_USERS'),
        ('data/synthetic/CARERS.csv', 'CARERS'),
        ('data/synthetic/VISITS.csv', 'VISITS'),
        ('data/synthetic/INCIDENTS.csv', 'INCIDENTS'),
        ('data/synthetic/INVOICES.csv', 'INVOICES'),
        ('data/synthetic/STAFF_ROSTER.csv', 'STAFF_ROSTER'),
    ]
    
    # Load each CSV into its table
    print("\n[2/7] Loading SERVICE_USERS...")
    conn.execute(f"COPY SERVICE_USERS FROM 'data/synthetic/SERVICE_USERS.csv' (FORMAT CSV, HEADER TRUE)")
    print("      ✓ Loaded SERVICE_USERS")
    
    print("\n[3/7] Loading CARERS...")
    conn.execute(f"COPY CARERS FROM 'data/synthetic/CARERS.csv' (FORMAT CSV, HEADER TRUE)")
    print("      ✓ Loaded CARERS")
    
    print("\n[4/7] Loading VISITS...")
    conn.execute(f"COPY VISITS FROM 'data/synthetic/VISITS.csv' (FORMAT CSV, HEADER TRUE)")
    print("      ✓ Loaded VISITS")
    
    print("\n[5/7] Loading INCIDENTS...")
    conn.execute(f"COPY INCIDENTS FROM 'data/synthetic/INCIDENTS.csv' (FORMAT CSV, HEADER TRUE)")
    print("      ✓ Loaded INCIDENTS")
    
    print("\n[6/7] Loading INVOICES...")
    conn.execute(f"COPY INVOICES FROM 'data/synthetic/INVOICES.csv' (FORMAT CSV, HEADER TRUE)")
    print("      ✓ Loaded INVOICES")
    
    print("\n[7/7] Loading STAFF_ROSTER...")
    conn.execute(f"COPY STAFF_ROSTER FROM 'data/synthetic/STAFF_ROSTER.csv' (FORMAT CSV, HEADER TRUE)")
    print("      ✓ Loaded STAFF_ROSTER")
    
    # Verify data loaded
    print("\n" + "=" * 70)
    print("VERIFICATION - Row Counts by Table")
    print("=" * 70 + "\n")
    
    tables = ['SERVICE_USERS', 'CARERS', 'VISITS', 'INCIDENTS', 'INVOICES', 'STAFF_ROSTER']
    total_rows = 0
    
    for table in tables:
        row_count = conn.execute(f"SELECT COUNT(*) FROM {table}").fetchall()[0][0]
        total_rows += row_count
        print(f"  {table:20} {row_count:>10,} rows")
    
    print(f"\n  {'TOTAL':20} {total_rows:>10,} rows")
    
    print("\n" + "=" * 70)
    print("✓ SUCCESS - All synthetic data loaded into database")
    print("=" * 70)
    
    # Sample queries to show data is there
    print("\nSample Data Checks:")
    
    # Service users age range
    age_check = conn.execute("SELECT MIN(age) as min_age, MAX(age) as max_age FROM SERVICE_USERS").fetchall()[0]
    print(f"  - Service users age range: {age_check[0]}-{age_check[1]}")
    
    # Visit completion rate
    completion_rate = conn.execute("SELECT ROUND(100.0 * SUM(visit_completed) / COUNT(*), 1) FROM VISITS").fetchall()[0][0]
    print(f"  - Visit completion rate: {completion_rate}%")
    
    # Average visits per carer
    avg_visits = conn.execute("SELECT ROUND(AVG(visit_count), 1) FROM (SELECT carer_id, COUNT(*) as visit_count FROM VISITS GROUP BY carer_id)").fetchall()[0][0]
    print(f"  - Average visits per carer: {avg_visits}")
    
    # Date range
    date_range = conn.execute("SELECT MIN(scheduled_date), MAX(scheduled_date) FROM VISITS").fetchall()[0]
    print(f"  - Visit date range: {date_range[0]} to {date_range[1]}")
    
    print("\n" + "=" * 70)
    print("Database ready for analytics and Power BI dashboard")
    print("=" * 70)
    
    conn.close()
    sys.exit(0)

except Exception as e:
    print(f"\n✗ ERROR: {e}")
    sys.exit(1)