import duckdb

conn = duckdb.connect('db/careops.duckdb')

print("VISITS count:", conn.execute("SELECT COUNT(*) FROM VISITS").fetchone()[0])
print("Completion rate:", conn.execute("SELECT completion_rate_pct FROM v_operational_summary_all_time").fetchone()[0])

conn.close()