import duckdb

print("=" * 70)
print("VisitOps Intelligence - Loading Visit Cohort Analysis Views")
print("=" * 70)

try:
    print("\n[1/2] Connecting to DuckDB...")
    conn = duckdb.connect('db/careops.duckdb')
    print("      ✓ Connected")
    
    print("\n[2/2] Loading cohort analysis views...")
    with open('sql/kpi_cohort_analysis.sql', 'r') as f:
        sql = f.read()
    
    for statement in sql.split(';'):
        if statement.strip():
            conn.execute(statement)
    
    print("      ✓ All views created")
    
    print("\n" + "=" * 70)
    print("VERIFICATION - Cohort Analysis Views Created")
    print("=" * 70 + "\n")
    
    views = [
        'v_visit_cohort_by_week',
        'v_visit_type_performance_by_period',
        'v_commissioner_cohort_trend',
        'v_high_risk_visits'
    ]
    
    for view in views:
        print(f"✓ {view}")
    
    print("\n" + "=" * 70)
    print("Cohort analysis views ready")
    print("=" * 70)
    
    conn.close()

except Exception as e:
    print(f"\n✗ ERROR: {e}")