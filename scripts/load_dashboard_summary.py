import duckdb

print("=" * 70)
print("VisitOps Intelligence - Loading Master Dashboard Summary")
print("=" * 70)

try:
    print("\n[1/2] Connecting to DuckDB...")
    conn = duckdb.connect('db/careops.duckdb')
    print("      ✓ Connected")
    
    print("\n[2/2] Loading master dashboard view...")
    with open('sql/kpi_dashboard_summary.sql', 'r') as f:
        sql = f.read()
    
    conn.execute(sql)
    print("      ✓ Master view created")
    
    print("\n" + "=" * 70)
    print("MASTER DASHBOARD SUMMARY VIEW")
    print("=" * 70 + "\n")
    
    result = conn.execute("SELECT * FROM v_dashboard_kpi_summary").fetchone()
    
    print("✓ v_dashboard_kpi_summary created")
    print("\nMetrics included:")
    print("  - Operational: visits, completion, lateness")
    print("  - Workforce: carers, utilization, employment type")
    print("  - Financial: revenue, payments, per-visit rate")
    print("  - Quality: incidents, severity, safeguarding")
    print("  - Service: active users, visit types")
    print("  - Data period: start/end dates")
    
    print("\n" + "=" * 70)
    print("Ready for Power BI dashboard")
    print("=" * 70)
    
    conn.close()

except Exception as e:
    print(f"\n✗ ERROR: {e}")