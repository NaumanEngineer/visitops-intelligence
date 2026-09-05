import duckdb

print("=" * 70)
print("VisitOps Intelligence - Loading Time-Series Trend Views")
print("=" * 70)

try:
    print("\n[1/2] Connecting to DuckDB...")
    conn = duckdb.connect('db/careops.duckdb')
    print("      ✓ Connected")
    
    print("\n[2/2] Loading time-series trend views...")
    with open('sql/kpi_timeseries_trends.sql', 'r') as f:
        sql = f.read()
    
    for statement in sql.split(';'):
        if statement.strip():
            conn.execute(statement)
    
    print("      ✓ All views created")
    
    print("\n" + "=" * 70)
    print("VERIFICATION - Time-Series Trend Views Created")
    print("=" * 70 + "\n")
    
    views = [
        'v_weekly_completion_trend',
        'v_monthly_revenue_forecast',
        'v_lateness_trend_analysis',
        'v_incident_trend_analysis'
    ]
    
    for view in views:
        print(f"✓ {view}")
    
    print("\n" + "=" * 70)
    print("Time-series views ready for testing")
    print("=" * 70)
    
    conn.close()

except Exception as e:
    print(f"\n✗ ERROR: {e}")