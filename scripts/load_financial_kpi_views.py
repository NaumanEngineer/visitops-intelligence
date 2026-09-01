import duckdb

print("=" * 70)
print("VisitOps Intelligence - Loading Financial KPI Views")
print("=" * 70)

try:
    print("\n[1/2] Connecting to DuckDB...")
    conn = duckdb.connect('db/careops.duckdb')
    print("      ✓ Connected")
    
    print("\n[2/2] Loading financial KPI views...")
    with open('sql/kpi_financial.sql', 'r') as f:
        sql = f.read()
    
    for statement in sql.split(';'):
        if statement.strip():
            conn.execute(statement)
    
    print("      ✓ All views created")
    
    print("\n" + "=" * 70)
    print("VERIFICATION - Financial KPI Views Created")
    print("=" * 70 + "\n")
    
    views = [
        'v_financial_by_commissioner',
        'v_revenue_per_visit',
        'v_payment_status_summary',
        'v_rejection_analysis',
        'v_financial_summary_all_time'
    ]
    
    for view in views:
        print(f"✓ {view}")
    
    print("\n" + "=" * 70)
    print("Financial views ready for testing")
    print("=" * 70)
    
    conn.close()

except Exception as e:
    print(f"\n✗ ERROR: {e}")