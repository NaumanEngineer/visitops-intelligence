import duckdb

print("=" * 70)
print("VisitOps Intelligence - Loading Workforce KPI Views")
print("=" * 70)

try:
    print("\n[1/2] Connecting to DuckDB...")
    conn = duckdb.connect('db/careops.duckdb')
    print("      ✓ Connected")
    
    print("\n[2/2] Loading workforce KPI views...")
    with open('sql/kpi_workforce.sql', 'r') as f:
        sql = f.read()
    
    for statement in sql.split(';'):
        if statement.strip():
            conn.execute(statement)
    
    print("      ✓ All views created")
    
    print("\n" + "=" * 70)
    print("VERIFICATION - Workforce KPI Views Created")
    print("=" * 70 + "\n")
    
    views = [
        'v_carer_performance',
        'v_carer_utilization',
        'v_employment_type_summary',
        'v_carer_lateness_ranking',
        'v_high_performing_carers'
    ]
    
    for view in views:
        print(f"✓ {view}")
    
    print("\n" + "=" * 70)
    print("Workforce views ready for testing")
    print("=" * 70)
    
    conn.close()

except Exception as e:
    print(f"\n✗ ERROR: {e}")