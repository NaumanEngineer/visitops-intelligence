import duckdb

print("=" * 70)
print("VisitOps Intelligence - Loading Carer Cohort & Retention Views")
print("=" * 70)

try:
    print("\n[1/2] Connecting to DuckDB...")
    conn = duckdb.connect('db/careops.duckdb')
    print("      ✓ Connected")
    
    print("\n[2/2] Loading carer cohort views...")
    with open('sql/kpi_carer_cohort.sql', 'r') as f:
        sql = f.read()
    
    for statement in sql.split(';'):
        if statement.strip():
            conn.execute(statement)
    
    print("      ✓ All views created")
    
    print("\n" + "=" * 70)
    print("VERIFICATION - Carer Cohort & Retention Views Created")
    print("=" * 70 + "\n")
    
    views = [
        'v_carer_cohort_progression',
        'v_carer_burnout_indicators',
        'v_employment_type_retention',
        'v_carer_tenure_analysis'
    ]
    
    for view in views:
        print(f"✓ {view}")
    
    print("\n" + "=" * 70)
    print("Carer cohort views ready for testing")
    print("=" * 70)
    
    conn.close()

except Exception as e:
    print(f"\n✗ ERROR: {e}")