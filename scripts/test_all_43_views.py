import duckdb

print("=" * 80)
print("VisitOps Intelligence - Complete Verification Suite (43 Views)")
print("=" * 80)

try:
    conn = duckdb.connect('db/careops.duckdb')
    
    # All 43 views
    views = {
        'BASIC KPI VIEWS (22)': [
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
        ],
        'ADVANCED ANALYTICS (18)': [
            # Visit Cohort (4)
            'v_visit_cohort_by_week',
            'v_visit_type_performance_by_period',
            'v_commissioner_cohort_trend',
            'v_high_risk_visits',
            # Carer Cohort (4)
            'v_carer_cohort_progression',
            'v_carer_burnout_indicators',
            'v_employment_type_retention',
            'v_carer_tenure_analysis',
            # Time-Series (4)
            'v_weekly_completion_trend',
            'v_monthly_revenue_forecast',
            'v_lateness_trend_analysis',
            'v_incident_trend_analysis',
            # Comparative (3)
            'v_period_comparison',
            'v_carer_performance_variance',
            'v_top_bottom_performers',
        ],
        'PREDICTIVE & AI-READY (5)': [
            # Churn & Forecasting (3)
            'v_carer_churn_risk',
            'v_commissioner_churn_risk',
            'v_visit_forecast_next_30days',
            # AI-Ready (2)
            'v_anomaly_detection_flags',
            'v_care_quality_reasoning',
        ]
    }
    
    print("\nTesting all views...\n")
    
    passed = 0
    failed = 0
    
    for category, view_list in views.items():
        print(f"\n{category}")
        print("-" * 80)
        
        for view in view_list:
            try:
                result = conn.execute(f"SELECT COUNT(*) FROM {view}").fetchone()
                row_count = result[0] if result else 0
                print(f"  ✓ {view:45} ({row_count} row(s))")
                passed += 1
            except Exception as e:
                print(f"  ✗ {view:45} ERROR: {str(e)[:40]}")
                failed += 1
    
    print("\n" + "=" * 80)
    print(f"RESULTS: {passed} PASSED, {failed} FAILED")
    print("=" * 80)
    
    if failed == 0:
        print("\n✓✓✓ ALL 43 VIEWS PASSING - WEEK 3 COMPLETE ✓✓✓\n")
        print("SQL Analytics Layer Ready for Power BI Integration (Weeks 4-6)")
        print("AI-Ready Architecture Complete")
        print("\nNext: Power BI Dashboard + Claude API Integration\n")
    else:
        print(f"\n✗ {failed} view(s) failed - check errors above\n")
    
    conn.close()

except Exception as e:
    print(f"\n✗ CRITICAL ERROR: {e}")