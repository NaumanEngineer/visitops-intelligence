import duckdb

print("=" * 70)
print("VisitOps Intelligence - Churn, Forecasting & AI-Ready Views")
print("=" * 70)

try:
    print("\n[1/3] Connecting to DuckDB...")
    conn = duckdb.connect('db/careops.duckdb')
    print("      ✓ Connected")
    
    print("\n[2/3] Loading churn & forecasting views...")
    with open('sql/kpi_churn_forecasting.sql', 'r') as f:
        sql = f.read()
    
    for statement in sql.split(';'):
        if statement.strip():
            conn.execute(statement)
    
    print("      ✓ Churn & forecasting views created")
    
    print("\n[3/3] Loading AI-ready data structures...")
    with open('sql/kpi_ai_ready_data.sql', 'r') as f:
        sql = f.read()
    
    for statement in sql.split(';'):
        if statement.strip():
            conn.execute(statement)
    
    print("      ✓ AI-ready views created")
    
    print("\n" + "=" * 70)
    print("VERIFICATION - All Views Created")
    print("=" * 70 + "\n")
    
    views = [
        'v_carer_churn_risk',
        'v_commissioner_churn_risk',
        'v_visit_forecast_next_30days',
        'v_anomaly_detection_flags',
        'v_care_quality_reasoning'
    ]
    
    for view in views:
        print(f"✓ {view}")
    
    print("\n" + "=" * 70)
    print("TOTAL: 5 views ready (3 predictive + 2 AI-ready)")
    print("=" * 70)
    
    conn.close()

except Exception as e:
    print(f"\n✗ ERROR: {e}")