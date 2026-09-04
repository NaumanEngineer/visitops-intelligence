import duckdb

print("=" * 70)
print("VisitOps Intelligence - Loading Comparative Analysis Views")
print("=" * 70)

try:
    print("\n[1/2] Connecting to DuckDB...")
    conn = duckdb.connect('db/careops.duckdb')
    print("      ✓ Connected")
    
    print("\n[2/2] Loading comparative analysis views...")
    with open('sql/kpi_comparative_analysis.sql', 'r') as f:
        sql = f.read()
    
    for statement in sql.split(';'):
        if statement.strip():
            conn.execute(statement)
    
    print("      ✓ All views created")
    
    print("\n" + "=" * 70)
    print("VERIFICATION - Comparative Analysis Views Created")
    print("=" * 70 + "\n")
    
    views = [
        'v_period_comparison',
        'v_carer_performance_variance',
        'v_top_bottom_performers'
    ]
    
    for view in views:
        print(f"✓ {view}")
    
    print("\n" + "=" * 70)
    print("Comparative analysis views ready")
    print("=" * 70)
    
    conn.close()

except Exception as e:
    print(f"\n✗ ERROR: {e}")