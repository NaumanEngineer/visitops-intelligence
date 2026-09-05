import duckdb

conn = duckdb.connect('db/careops.duckdb')

print("\n[1] CARER CHURN RISK")
result = conn.execute("SELECT name, churn_risk_level, recent_30day_completion_rate_pct FROM v_carer_churn_risk LIMIT 3").fetchall()
for row in result:
    print(f"  {row[0]}: {row[1]}, {row[2]:.1f}% recent")

print("\n[2] COMMISSIONER CHURN RISK")
result = conn.execute("SELECT commissioner_name, churn_risk_level, paid_rate_pct FROM v_commissioner_churn_risk LIMIT 3").fetchall()
for row in result:
    print(f"  {row[0]}: {row[1]}, {row[2]:.1f}% paid")

print("\n[3] VISIT FORECAST")
result = conn.execute("SELECT visits_completed_this_month, conservative_forecast, optimistic_forecast FROM v_visit_forecast_next_30days LIMIT 1").fetchone()
if result:
    print(f"  Last month: {result[0]} visits, Forecast: {int(result[1])}-{int(result[2])}")

print("\n[4] ANOMALY DETECTION (Sample)")
result = conn.execute("SELECT name, anomaly_flag FROM v_anomaly_detection_flags WHERE anomaly_flag != 'NORMAL' LIMIT 3").fetchall()
if result:
    for row in result:
        print(f"  {row[0]}: {row[1]}")
else:
    print("  No anomalies detected")

print("\n[5] CARE QUALITY REASONING (High risk)")
result = conn.execute("SELECT service_user_name, quality_status, incidents FROM v_care_quality_reasoning WHERE quality_status = 'HIGH RISK' LIMIT 2").fetchall()
if result:
    for row in result:
        print(f"  {row[0]}: {row[1]}, {row[2]} incidents")
else:
    print("  No high-risk cases")

conn.close()