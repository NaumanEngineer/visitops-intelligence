import duckdb
import os

print("=" * 70)
print("Exporting Views for Power BI (Excel Format)")
print("=" * 70)

try:
    conn = duckdb.connect('db/careops.duckdb')
    
    # Create export folder
    export_folder = 'data/powerbi_export'
    os.makedirs(export_folder, exist_ok=True)
    
    views_to_export = [
        'v_dashboard_kpi_summary',
        'v_operational_daily_summary',
        'v_visit_type_summary',
        'v_completion_by_week',
        'v_carer_performance',
        'v_carer_churn_risk',
        'v_financial_by_commissioner',
        'v_payment_status_summary',
        'v_incident_rate_summary',
        'v_care_quality_reasoning',
        'v_weekly_completion_trend',
        'v_monthly_revenue_forecast',
        'v_carer_burnout_indicators',
        'v_top_bottom_performers'
    ]
    
    print(f"\nExporting to: {export_folder}\n")
    
    for view in views_to_export:
        try:
            df = conn.execute(f"SELECT * FROM {view}").fetchdf()
            filename = f"{export_folder}/{view}.xlsx"
            df.to_excel(filename, index=False, sheet_name='Data')
            print(f"✓ {view} ({len(df)} rows)")
        except Exception as e:
            print(f"✗ {view}: {str(e)[:50]}")
    
    print("\n" + "=" * 70)
    print("Export complete!")
    print("=" * 70)
    
    conn.close()

except Exception as e:
    print(f"✗ ERROR: {e}")