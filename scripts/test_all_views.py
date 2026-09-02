import duckdb

print("=" * 70)
print("VisitOps Intelligence - Verification Test Suite")
print("=" * 70)

try:
    conn = duckdb.connect('db/careops.duckdb')
    
    # All 22 views to test
    views = [
        # Operational (5)
        'v_operational_daily_summary',
        'v_visit_type_summary',
        'v_operational_summary_all_time',
        'v_lateness_analysis',
        'v_completion_by_week',
        # Workforce (5)
        'v_carer_performance',
        'v_carer_utilization',
        'v_employment_type_summary',
        'v_carer_lateness_ranking',
        'v_high_performing_carers',
        # Financial (5)
        'v_financial_by_commissioner',
        'v_revenue_per_visit',
        'v_payment_status_summary',
        'v_rejection_analysis',
        'v_financial_summary_all_time',
        # Quality (6)
        'v_incident_rate_summary',
        'v_incident_breakdown',
        'v_missed_visit_analysis',
        'v_safeguarding_incidents',
        'v_severity_distribution',
        'v_quality_summary_all_time',
        # Dashboard (1)
        'v_dashboard_kpi_summary',
    ]
    
    print("\nTesting all 22 views...\n")
    passed = 0
    failed = 0
    
    for view in views:
        try:
            result = conn.execute(f"SELECT COUNT(*) FROM {view}").fetchone()
            row_count = result[0] if result else 0
            print(f"✓ {view:45} ({row_count} row(s))")
            passed += 1
        except Exception as e:
            print(f"✗ {view:45} ERROR: {str(e)[:40]}")
            failed += 1
    
    print("\n" + "=" * 70)
    print(f"RESULTS: {passed} passed, {failed} failed")
    print("=" * 70)
    
    if failed == 0:
        print("\n✓ ALL TESTS PASSED - Week 2 Complete!\n")
    else:
        print(f"\n✗ {failed} view(s) failed - check errors above\n")
    
    conn.close()

except Exception as e:
    print(f"\n✗ CRITICAL ERROR: {e}")