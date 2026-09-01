import duckdb

conn = duckdb.connect('db/careops.duckdb')

with open('sql/kpi_operational.sql', 'r') as f:
    for statement in f.read().split(';'):
        if statement.strip():
            conn.execute(statement)

print("✓ Operational KPI views created")
conn.close()