-- VisitOps Intelligence - Comparative Analysis
-- Views for period-over-period comparisons and variance analysis

-- 1. Period-over-period comparison
CREATE OR REPLACE VIEW v_period_comparison AS
SELECT
    STRFTIME('%Y-%m', v.scheduled_date) as current_month,
    COUNT(*) as visits_this_month,
    SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) as completed_this_month,
    ROUND(100.0 * SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) as completion_rate_this_month,
    LAG(COUNT(*)) OVER (ORDER BY STRFTIME('%Y-%m', v.scheduled_date)) as visits_last_month,
    LAG(SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END)) OVER (ORDER BY STRFTIME('%Y-%m', v.scheduled_date)) as completed_last_month,
    LAG(ROUND(100.0 * SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) / COUNT(*), 1)) OVER (ORDER BY STRFTIME('%Y-%m', v.scheduled_date)) as completion_rate_last_month,
    ROUND(((COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY STRFTIME('%Y-%m', v.scheduled_date))) / NULLIF(LAG(COUNT(*)) OVER (ORDER BY STRFTIME('%Y-%m', v.scheduled_date)), 0) * 100), 1) as visit_volume_pct_change,
    ROUND((SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) - LAG(SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END)) OVER (ORDER BY STRFTIME('%Y-%m', v.scheduled_date))) / NULLIF(LAG(SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END)) OVER (ORDER BY STRFTIME('%Y-%m', v.scheduled_date)), 0) * 100, 1) as completion_volume_pct_change
FROM VISITS v
GROUP BY STRFTIME('%Y-%m', v.scheduled_date)
ORDER BY current_month DESC;

-- 2. Performance variance analysis - carers
CREATE OR REPLACE VIEW v_carer_performance_variance AS
SELECT
    c.name,
    c.employment_type,
    COUNT(DISTINCT v.visit_id) as total_visits,
    ROUND(100.0 * SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) / COUNT(v.visit_id), 1) as completion_rate_pct,
    ROUND(AVG(CASE WHEN v.visit_late_by_minutes IS NOT NULL THEN v.visit_late_by_minutes ELSE 0 END), 1) as avg_lateness_minutes,
    ROUND(STDDEV(CASE WHEN v.visit_late_by_minutes IS NOT NULL THEN v.visit_late_by_minutes ELSE 0 END), 1) as lateness_variance,
    CASE
        WHEN STDDEV(CASE WHEN v.visit_late_by_minutes IS NOT NULL THEN v.visit_late_by_minutes ELSE 0 END) > 20 THEN 'HIGH VARIANCE'
        WHEN STDDEV(CASE WHEN v.visit_late_by_minutes IS NOT NULL THEN v.visit_late_by_minutes ELSE 0 END) > 10 THEN 'MEDIUM VARIANCE'
        ELSE 'CONSISTENT'
    END as performance_consistency
FROM CARERS c
LEFT JOIN VISITS v ON c.carer_id = v.carer_id
WHERE c.is_active = 1
GROUP BY c.carer_id, c.name, c.employment_type
HAVING COUNT(v.visit_id) >= 20
ORDER BY lateness_variance DESC;

-- 3. Top and bottom performers
CREATE OR REPLACE VIEW v_top_bottom_performers AS
SELECT
    'TOP PERFORMERS' as performer_category,
    c.name,
    c.employment_type,
    COUNT(DISTINCT v.visit_id) as total_visits,
    ROUND(100.0 * SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) / COUNT(v.visit_id), 1) as completion_rate_pct,
    ROUND(AVG(CASE WHEN v.visit_late_by_minutes IS NOT NULL THEN v.visit_late_by_minutes ELSE 0 END), 1) as avg_lateness_minutes,
    ROW_NUMBER() OVER (ORDER BY ROUND(100.0 * SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) / COUNT(v.visit_id), 1) DESC) as rank
FROM CARERS c
LEFT JOIN VISITS v ON c.carer_id = v.carer_id
WHERE c.is_active = 1
GROUP BY c.carer_id, c.name, c.employment_type
HAVING COUNT(v.visit_id) >= 20
UNION ALL
SELECT
    'BOTTOM PERFORMERS' as performer_category,
    c.name,
    c.employment_type,
    COUNT(DISTINCT v.visit_id) as total_visits,
    ROUND(100.0 * SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) / COUNT(v.visit_id), 1) as completion_rate_pct,
    ROUND(AVG(CASE WHEN v.visit_late_by_minutes IS NOT NULL THEN v.visit_late_by_minutes ELSE 0 END), 1) as avg_lateness_minutes,
    ROW_NUMBER() OVER (ORDER BY ROUND(100.0 * SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) / COUNT(v.visit_id), 1) ASC) as rank
FROM CARERS c
LEFT JOIN VISITS v ON c.carer_id = v.carer_id
WHERE c.is_active = 1
GROUP BY c.carer_id, c.name, c.employment_type
HAVING COUNT(v.visit_id) >= 20
ORDER BY performer_category, rank;