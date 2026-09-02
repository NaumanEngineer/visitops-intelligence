-- VisitOps Intelligence - Master Dashboard Summary
-- Single view with all key metrics for Power BI dashboard

CREATE OR REPLACE VIEW v_dashboard_kpi_summary AS
SELECT
    -- OPERATIONAL METRICS
    (SELECT COUNT(*) FROM VISITS) as total_visits,
    (SELECT SUM(CASE WHEN visit_completed = 1 THEN 1 ELSE 0 END) FROM VISITS) as completed_visits,
    (SELECT SUM(CASE WHEN visit_completed = 0 THEN 1 ELSE 0 END) FROM VISITS) as missed_visits,
    (SELECT ROUND(100.0 * SUM(CASE WHEN visit_completed = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) FROM VISITS) as visit_completion_rate_pct,
    (SELECT ROUND(AVG(CASE WHEN visit_late_by_minutes IS NOT NULL THEN visit_late_by_minutes ELSE 0 END), 1) FROM VISITS) as avg_lateness_minutes,
    
    -- WORKFORCE METRICS
    (SELECT COUNT(*) FROM CARERS WHERE is_active = 1) as active_carers,
    (SELECT COUNT(DISTINCT carer_id) FROM STAFF_ROSTER) as carers_scheduled,
    (SELECT ROUND(AVG(num_scheduled_visits), 1) FROM STAFF_ROSTER) as avg_visits_per_carer_shift,
    (SELECT COUNT(*) FROM CARERS WHERE employment_type = 'employed') as employed_carers,
    (SELECT COUNT(*) FROM CARERS WHERE employment_type = 'agency') as agency_carers,
    
    -- FINANCIAL METRICS
    (SELECT COUNT(*) FROM INVOICES) as total_invoices,
    (SELECT SUM(total_amount) FROM INVOICES) as total_revenue,
    (SELECT SUM(CASE WHEN payment_status = 'paid' THEN total_amount ELSE 0 END) FROM INVOICES) as paid_revenue,
    (SELECT SUM(CASE WHEN payment_status = 'pending' THEN total_amount ELSE 0 END) FROM INVOICES) as pending_revenue,
    (SELECT SUM(CASE WHEN payment_status = 'rejected' THEN total_amount ELSE 0 END) FROM INVOICES) as rejected_revenue,
    (SELECT SUM(CASE WHEN payment_status = 'paid' THEN 1 ELSE 0 END) FROM INVOICES) as paid_invoices,
    (SELECT SUM(CASE WHEN payment_status = 'pending' THEN 1 ELSE 0 END) FROM INVOICES) as pending_invoices,
    (SELECT ROUND(SUM(total_amount) / SUM(num_visits_invoiced), 2) FROM INVOICES) as revenue_per_visit,
    
    -- QUALITY METRICS
    (SELECT COUNT(*) FROM INCIDENTS) as total_incidents,
    (SELECT COUNT(*) FROM INCIDENTS WHERE severity = 'high') as high_severity_incidents,
    (SELECT COUNT(*) FROM INCIDENTS WHERE severity = 'medium') as medium_severity_incidents,
    (SELECT COUNT(*) FROM INCIDENTS WHERE severity = 'low') as low_severity_incidents,
    (SELECT COUNT(*) FROM INCIDENTS WHERE incident_type = 'missed_visit') as missed_visit_incidents,
    (SELECT COUNT(*) FROM INCIDENTS WHERE incident_type = 'late_visit') as late_visit_incidents,
    (SELECT COUNT(*) FROM INCIDENTS WHERE incident_type = 'safeguarding_concern') as safeguarding_incidents,
    (SELECT ROUND(1000.0 * COUNT(*) / (SELECT COUNT(*) FROM VISITS), 1) FROM INCIDENTS) as incidents_per_1000_visits,
    
    -- SERVICE METRICS
    (SELECT COUNT(*) FROM SERVICE_USERS WHERE is_active = 1) as active_service_users,
    (SELECT COUNT(DISTINCT visit_type) FROM VISITS) as visit_types_offered,
    
    -- DATA PERIOD
    (SELECT MIN(scheduled_date) FROM VISITS) as data_start_date,
    (SELECT MAX(scheduled_date) FROM VISITS) as data_end_date,
    (SELECT COUNT(DISTINCT scheduled_date) FROM VISITS) as days_of_data;