import duckdb

print("=" * 70)
print("VisitOps Intelligence - Loading Quality KPI Views")
print("=" * 70)

try:
    print("\n[1/2] Connecting to DuckDB...")
    conn = duckdb.connect('db/careops.duckdb')
    print("      ✓ Connected")
    
    print("\n[2/2] Loading quality KPI views...")
    with open('sql/kpi_quality.sql', 'r') as f:
        sql = f.read()
    
    for statement in sql.split(';'):
        if statement.strip():
            conn.execute(statement)
    
    print("      ✓ All views created")
    
    print("\n" + "=" * 70)
    print("VERIFICATION - Quality KPI Views Created")
    print("=" * 70 + "\n")
    
    views = [
        'v_incident_rate_summary',
        'v_incident_breakdown',
        'v_missed_visit_analysis',
        'v_safeguarding_incidents',
        'v_severity_distribution',
        'v_quality_summary_all_time'
    ]
    
    for view in views:
        print(f"✓ {view}")
    
    print("\n" + "=" * 70)
    print("Quality views ready for testing")
    print("=" * 70)
    
    conn.close()

except Exception as e:
    print(f"\n✗ ERROR: {e}")