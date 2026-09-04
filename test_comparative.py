import duckdb

conn = duckdb.connect('db/careops.duckdb')

print("\n[1] PERIOD COMPARISON (Last 3 months)")
result = conn.execute("SELECT current_month, visits_this_month, completion_rate_this_month, visit_volume_pct_change FROM v_period_comparison LIMIT 3").fetchall()
for row in result:
    change = f"{row[3]:+.1f}%" if row[3] else "—"
    print(f"  {row[0]}: {row[1]} visits, {row[2]:.1f}% completion, {change} change")

print("\n[2] PERFORMANCE VARIANCE (Top 5 most inconsistent)")
result = conn.execute("SELECT name, completion_rate_pct, lateness_variance, performance_consistency FROM v_carer_performance_variance LIMIT 5").fetchall()
for row in result:
    print(f"  {row[0]}: {row[1]:.1f}% completion, {row[2]:.1f} min variance, {row[3]}")

print("\n[3] TOP PERFORMERS (Top 5)")
result = conn.execute("SELECT name, completion_rate_pct FROM v_top_bottom_performers WHERE performer_category = 'TOP PERFORMERS' LIMIT 5").fetchall()
for row in result:
    print(f"  {row[0]}: {row[1]:.1f}%")

print("\n[4] BOTTOM PERFORMERS (Bottom 5)")
result = conn.execute("SELECT name, completion_rate_pct FROM v_top_bottom_performers WHERE performer_category = 'BOTTOM PERFORMERS' LIMIT 5").fetchall()
for row in result:
    print(f"  {row[0]}: {row[1]:.1f}%")

conn.close()