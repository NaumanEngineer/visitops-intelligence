-- VisitOps Intelligence - Time-Series Trends
-- Views for tracking trends, moving averages, and seasonal patterns

-- 1. Weekly completion rate trend
CREATE OR REPLACE VIEW v_weekly_completion_trend AS
SELECT
    STRFTIME('%Y-W%V', scheduled_date) as week,
    MIN(scheduled_date) as week_start_date,
    MAX(scheduled_date) as week_end_date,
    COUNT(*) as total_visits,
    SUM(CASE WHEN visit_completed = 1 THEN 1 ELSE 0 END) as completed_visits,
    SUM(CASE WHEN visit_completed = 0 THEN 1 ELSE 0 END) as missed_visits,
    ROUND(100.0 * SUM(CASE WHEN visit_completed = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) as completion_rate_pct,
    LAG(ROUND(100.0 * SUM(CASE WHEN visit_completed = 1 THEN 1 ELSE 0 END) / COUNT(*), 1)) 
        OVER (ORDER BY STRFTIME('%Y-W%V', scheduled_date)) as prior_week_completion_rate_pct
FROM VISITS
GROUP BY week
ORDER BY week DESC;

-- 2. Monthly revenue forecast (moving average)
CREATE OR REPLACE VIEW v_monthly_revenue_forecast AS
SELECT
    STRFTIME('%Y-%m', invoice_date) as month,
    SUM(total_amount) as monthly_revenue,
    SUM(num_visits_invoiced) as visits_invoiced,
    ROUND(SUM(total_amount) / SUM(num_visits_invoiced), 2) as revenue_per_visit,
    ROUND(AVG(SUM(total_amount)) OVER (
        ORDER BY STRFTIME('%Y-%m', invoice_date)
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) as moving_avg_3month_revenue
FROM INVOICES
GROUP BY month
ORDER BY month DESC;

-- 3. Lateness trend analysis
CREATE OR REPLACE VIEW v_lateness_trend_analysis AS
SELECT
    STRFTIME('%Y-%m', scheduled_date) as month,
    COUNT(*) as total_visits,
    SUM(CASE WHEN visit_late_by_minutes > 0 THEN 1 ELSE 0 END) as late_visits,
    ROUND(100.0 * SUM(CASE WHEN visit_late_by_minutes > 0 THEN 1 ELSE 0 END) / COUNT(*), 1) as late_rate_pct,
    ROUND(AVG(CASE WHEN visit_late_by_minutes IS NOT NULL THEN visit_late_by_minutes ELSE 0 END), 1) as avg_lateness_minutes,
    ROUND(AVG(AVG(CASE WHEN visit_late_by_minutes IS NOT NULL THEN visit_late_by_minutes ELSE 0 END)) 
        OVER (ORDER BY STRFTIME('%Y-%m', scheduled_date) ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 1) as moving_avg_lateness
FROM VISITS
GROUP BY month
ORDER BY month DESC;

-- 4. Incident trend analysis
CREATE OR REPLACE VIEW v_incident_trend_analysis AS
SELECT
    STRFTIME('%Y-%m', i.reported_date) as month,
    COUNT(DISTINCT i.incident_id) as incidents,
    SUM(CASE WHEN i.severity = 'high' THEN 1 ELSE 0 END) as high_severity_incidents,
    SUM(CASE WHEN i.severity = 'medium' THEN 1 ELSE 0 END) as medium_severity_incidents,
    SUM(CASE WHEN i.severity = 'low' THEN 1 ELSE 0 END) as low_severity_incidents,
    LAG(COUNT(DISTINCT i.incident_id)) 
        OVER (ORDER BY STRFTIME('%Y-%m', i.reported_date)) as prior_month_incidents
FROM INCIDENTS i
GROUP BY month
ORDER BY month DESC;