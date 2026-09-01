-- VisitOps Intelligence - Workforce KPIs
-- Views for carer performance, utilization, and reliability metrics

-- 1. Carer performance summary
CREATE OR REPLACE VIEW v_carer_performance AS
SELECT
    c.carer_id,
    c.name,
    c.employment_type,
    COUNT(v.visit_id) as total_visits,
    SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) as completed_visits,
    SUM(CASE WHEN v.visit_completed = 0 THEN 1 ELSE 0 END) as missed_visits,
    ROUND(100.0 * SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) / COUNT(v.visit_id), 1) as completion_rate_pct,
    ROUND(AVG(CASE WHEN v.visit_late_by_minutes IS NOT NULL THEN v.visit_late_by_minutes ELSE 0 END), 1) as avg_lateness_minutes,
    COUNT(DISTINCT v.scheduled_date) as days_worked
FROM CARERS c
LEFT JOIN VISITS v ON c.carer_id = v.carer_id
GROUP BY c.carer_id, c.name, c.employment_type
ORDER BY completed_visits DESC;

-- 2. Carer utilization analysis
CREATE OR REPLACE VIEW v_carer_utilization AS
SELECT
    c.carer_id,
    c.name,
    COUNT(DISTINCT sr.shift_date) as days_scheduled,
    ROUND(AVG(sr.num_scheduled_visits), 1) as avg_visits_per_shift,
    SUM(CASE WHEN sr.is_overtime = 1 THEN 1 ELSE 0 END) as overtime_shifts,
    COUNT(DISTINCT sr.shift_date) as total_shifts
FROM CARERS c
LEFT JOIN STAFF_ROSTER sr ON c.carer_id = sr.carer_id
GROUP BY c.carer_id, c.name
ORDER BY days_scheduled DESC;

-- 3. Employment type comparison
CREATE OR REPLACE VIEW v_employment_type_summary AS
SELECT
    employment_type,
    COUNT(DISTINCT c.carer_id) as total_carers,
    SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) as completed_visits,
    SUM(CASE WHEN v.visit_completed = 0 THEN 1 ELSE 0 END) as missed_visits,
    ROUND(100.0 * SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) / COUNT(v.visit_id), 1) as completion_rate_pct,
    COUNT(v.visit_id) as total_visits
FROM CARERS c
LEFT JOIN VISITS v ON c.carer_id = v.carer_id
GROUP BY employment_type
ORDER BY total_visits DESC;

-- 4. Carer lateness ranking
CREATE OR REPLACE VIEW v_carer_lateness_ranking AS
SELECT
    c.carer_id,
    c.name,
    COUNT(v.visit_id) as total_visits,
    SUM(CASE WHEN v.visit_late_by_minutes > 0 THEN 1 ELSE 0 END) as late_visits,
    ROUND(100.0 * SUM(CASE WHEN v.visit_late_by_minutes > 0 THEN 1 ELSE 0 END) / COUNT(v.visit_id), 1) as late_rate_pct,
    ROUND(AVG(CASE WHEN v.visit_late_by_minutes > 0 THEN v.visit_late_by_minutes ELSE NULL END), 1) as avg_lateness_when_late_minutes
FROM CARERS c
LEFT JOIN VISITS v ON c.carer_id = v.carer_id
GROUP BY c.carer_id, c.name
ORDER BY late_rate_pct DESC;

-- 5. High performer list (completion rate > 95%, min 20 visits)
CREATE OR REPLACE VIEW v_high_performing_carers AS
SELECT
    c.carer_id,
    c.name,
    c.employment_type,
    COUNT(v.visit_id) as total_visits,
    ROUND(100.0 * SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) / COUNT(v.visit_id), 1) as completion_rate_pct,
    ROUND(AVG(CASE WHEN v.visit_late_by_minutes IS NOT NULL THEN v.visit_late_by_minutes ELSE 0 END), 1) as avg_lateness_minutes
FROM CARERS c
LEFT JOIN VISITS v ON c.carer_id = v.carer_id
GROUP BY c.carer_id, c.name, c.employment_type
HAVING COUNT(v.visit_id) >= 20 AND ROUND(100.0 * SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) / COUNT(v.visit_id), 1) > 95
ORDER BY completion_rate_pct DESC;