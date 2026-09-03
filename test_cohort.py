import duckdb

conn = duckdb.connect('db/careops.duckdb')

print("\n[1] VISIT COHORT BY WEEK (Last 3 weeks)")
result = conn.execute("SELECT cohort_week, total_visits, completion_rate_pct FROM v_visit_cohort_by_week LIMIT 3").fetchall()
for row in result:
    print(f"  {row[0]}: {row[1]} visits, {row[2]:.1f}% completion")

print("\n[2] VISIT TYPE PERFORMANCE (Sample)")
result = conn.execute("SELECT period, visit_type, completion_rate_pct FROM v_visit_type_performance_by_period LIMIT 5").fetchall()
for row in result:
    print(f"  {row[0]} - {row[1]}: {row[2]:.1f}%")

print("\n[3] COMMISSIONER COHORT TREND (Latest period)")
result = conn.execute("SELECT commissioner_name, revenue_in_period, paid_rate_pct FROM v_commissioner_cohort_trend LIMIT 3").fetchall()
for row in result:
    print(f"  {row[0]}: £{row[1]:.2f}, {row[2]:.1f}% paid")

print("\n[4] HIGH-RISK VISITS (Count)")
result = conn.execute("SELECT COUNT(*) FROM v_high_risk_visits").fetchone()
print(f"  Total high-risk visits: {result[0]}")

conn.close()