-- VisitOps Intelligence - Visit Cohort Analysis
-- Advanced views for cohort analysis, trends, and risk identification

-- 1. Visit cohort retention by week
CREATE OR REPLACE VIEW v_visit_cohort_by_week AS
SELECT
    STRFTIME('%Y-W%V', scheduled_date) as cohort_week,
    COUNT(*) as total_visits,
    SUM(CASE WHEN visit_completed = 1 THEN 1 ELSE 0 END) as completed_visits,
    ROUND(100.0 * SUM(CASE WHEN visit_completed = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) as completion_rate_pct,
    SUM(CASE WHEN visit_late_by_minutes > 0 THEN 1 ELSE 0 END) as late_visits,
    ROUND(AVG(CASE WHEN visit_late_by_minutes IS NOT NULL THEN visit_late_by_minutes ELSE 0 END), 1) as avg_lateness_minutes,
    MIN(scheduled_date) as week_start_date,
    MAX(scheduled_date) as week_end_date
FROM VISITS
GROUP BY cohort_week
ORDER BY cohort_week DESC;

-- 2. Visit type performance by period
CREATE OR REPLACE VIEW v_visit_type_performance_by_period AS
SELECT
    STRFTIME('%Y-%m', scheduled_date) as period,
    visit_type,
    COUNT(*) as visits_in_period,
    SUM(CASE WHEN visit_completed = 1 THEN 1 ELSE 0 END) as completed,
    SUM(CASE WHEN visit_completed = 0 THEN 1 ELSE 0 END) as missed,
    ROUND(100.0 * SUM(CASE WHEN visit_completed = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) as completion_rate_pct,
    ROUND(AVG(CASE WHEN visit_late_by_minutes IS NOT NULL THEN visit_late_by_minutes ELSE 0 END), 1) as avg_lateness_minutes
FROM VISITS
GROUP BY period, visit_type
ORDER BY period DESC, visit_type;

-- 3. Commissioner cohort trend analysis
CREATE OR REPLACE VIEW v_commissioner_cohort_trend AS
SELECT
    STRFTIME('%Y-%m', i.invoice_date) as period,
    i.commissioner_name,
    COUNT(DISTINCT i.invoice_id) as invoices_in_period,
    SUM(i.num_visits_invoiced) as visits_invoiced,
    SUM(i.total_amount) as revenue_in_period,
    ROUND(SUM(i.total_amount) / SUM(i.num_visits_invoiced), 2) as revenue_per_visit,
    SUM(CASE WHEN i.payment_status = 'paid' THEN 1 ELSE 0 END) as paid_invoices,
    SUM(CASE WHEN i.payment_status = 'pending' THEN 1 ELSE 0 END) as pending_invoices,
    ROUND(100.0 * SUM(CASE WHEN i.payment_status = 'paid' THEN 1 ELSE 0 END) / COUNT(DISTINCT i.invoice_id), 1) as paid_rate_pct
FROM INVOICES i
GROUP BY period, i.commissioner_name
ORDER BY period DESC, i.commissioner_name;

-- 4. High-risk visit identification
CREATE OR REPLACE VIEW v_high_risk_visits AS
SELECT
    v.visit_id,
    v.service_user_id,
    v.carer_id,
    v.scheduled_date,
    v.visit_type,
    CASE
        WHEN v.visit_completed = 0 THEN 'MISSED'
        WHEN v.visit_late_by_minutes > 30 THEN 'VERY LATE'
        WHEN v.visit_late_by_minutes > 15 THEN 'LATE'
        ELSE 'COMPLETED'
    END as risk_category,
    v.visit_late_by_minutes,
    c.name as carer_name,
    c.employment_type,
    su.name as service_user_name,
    su.health_needs_level,
    COUNT(DISTINCT i.incident_id) as incidents_on_visit
FROM VISITS v
LEFT JOIN CARERS c ON v.carer_id = c.carer_id
LEFT JOIN SERVICE_USERS su ON v.service_user_id = su.service_user_id
LEFT JOIN INCIDENTS i ON v.visit_id = i.visit_id
WHERE v.visit_completed = 0 OR v.visit_late_by_minutes > 15
GROUP BY v.visit_id, v.service_user_id, v.carer_id, v.scheduled_date, v.visit_type, 
         v.visit_completed, v.visit_late_by_minutes, c.name, c.employment_type,
         su.name, su.health_needs_level
ORDER BY v.scheduled_date DESC;