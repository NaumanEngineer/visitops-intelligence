-- VisitOps Intelligence - Carer Cohort & Retention Analysis
-- Views for tracking carer trajectories, burnout, and retention patterns

-- 1. Carer cohort progression by hire cohort
CREATE OR REPLACE VIEW v_carer_cohort_progression AS
SELECT
    c.carer_id,
    c.name,
    c.employment_type,
    c.start_date as hire_date,
    CAST((CURRENT_DATE - c.start_date) / 365.25 AS INT) as tenure_years,
    COUNT(DISTINCT v.visit_id) as total_visits_completed,
    ROUND(100.0 * SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(v.visit_id), 0), 1) as overall_completion_rate_pct,
    ROUND(AVG(CASE WHEN v.visit_late_by_minutes IS NOT NULL THEN v.visit_late_by_minutes ELSE 0 END), 1) as avg_lateness_minutes,
    COUNT(DISTINCT v.scheduled_date) as days_worked,
    COUNT(DISTINCT sr.shift_date) as scheduled_shifts
FROM CARERS c
LEFT JOIN VISITS v ON c.carer_id = v.carer_id
LEFT JOIN STAFF_ROSTER sr ON c.carer_id = sr.carer_id
WHERE c.is_active = 1
GROUP BY c.carer_id, c.name, c.employment_type, c.start_date
ORDER BY tenure_years DESC, c.name;

-- 2. Burnout indicators - completion rate declining over time
CREATE OR REPLACE VIEW v_carer_burnout_indicators AS
SELECT
    c.carer_id,
    c.name,
    c.employment_type,
    CAST((CURRENT_DATE - c.start_date) / 365.25 AS INT) as tenure_years,
    COUNT(DISTINCT v.visit_id) as total_visits,
    ROUND(100.0 * SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(v.visit_id), 0), 1) as overall_completion_rate_pct,
    ROUND(100.0 * SUM(CASE WHEN v.scheduled_date >= CURRENT_DATE - INTERVAL '30 days' AND v.visit_completed = 1 THEN 1 ELSE 0 END) / 
          NULLIF(SUM(CASE WHEN v.scheduled_date >= CURRENT_DATE - INTERVAL '30 days' THEN 1 ELSE 0 END), 0), 1) as recent_30day_completion_rate_pct,
    SUM(CASE WHEN v.visit_late_by_minutes > 30 THEN 1 ELSE 0 END) as visits_very_late_recent,
    CASE
        WHEN ROUND(100.0 * SUM(CASE WHEN v.scheduled_date >= CURRENT_DATE - INTERVAL '30 days' AND v.visit_completed = 1 THEN 1 ELSE 0 END) / 
          NULLIF(SUM(CASE WHEN v.scheduled_date >= CURRENT_DATE - INTERVAL '30 days' THEN 1 ELSE 0 END), 0), 1) < 85 THEN 'HIGH RISK'
        WHEN ROUND(100.0 * SUM(CASE WHEN v.scheduled_date >= CURRENT_DATE - INTERVAL '30 days' AND v.visit_completed = 1 THEN 1 ELSE 0 END) / 
          NULLIF(SUM(CASE WHEN v.scheduled_date >= CURRENT_DATE - INTERVAL '30 days' THEN 1 ELSE 0 END), 0), 1) < 92 THEN 'MEDIUM RISK'
        ELSE 'LOW RISK'
    END as burnout_risk_level
FROM CARERS c
LEFT JOIN VISITS v ON c.carer_id = v.carer_id
WHERE c.is_active = 1
GROUP BY c.carer_id, c.name, c.employment_type, c.start_date
HAVING COUNT(v.visit_id) >= 10
ORDER BY recent_30day_completion_rate_pct ASC;

-- 3. Employment type retention analysis
CREATE OR REPLACE VIEW v_employment_type_retention AS
SELECT
    c.employment_type,
    COUNT(*) as total_carers,
    SUM(CASE WHEN c.is_active = 1 THEN 1 ELSE 0 END) as active_carers,
    ROUND(100.0 * SUM(CASE WHEN c.is_active = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) as retention_rate_pct,
    COUNT(DISTINCT v.carer_id) as carers_with_visits,
    ROUND(AVG(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) * 100, 1) as avg_completion_rate_pct,
    ROUND(AVG(CAST((CURRENT_DATE - c.start_date) / 365.25 AS REAL)), 1) as avg_tenure_years
FROM CARERS c
LEFT JOIN VISITS v ON c.carer_id = v.carer_id
GROUP BY c.employment_type
ORDER BY retention_rate_pct DESC;

-- 4. Carer tenure analysis - experience buckets
CREATE OR REPLACE VIEW v_carer_tenure_analysis AS
SELECT
    CASE
        WHEN CAST((CURRENT_DATE - c.start_date) / 365.25 AS INT) < 1 THEN 'New (< 1 year)'
        WHEN CAST((CURRENT_DATE - c.start_date) / 365.25 AS INT) < 2 THEN '1-2 years'
        WHEN CAST((CURRENT_DATE - c.start_date) / 365.25 AS INT) < 3 THEN '2-3 years'
        ELSE '3+ years'
    END as tenure_bucket,
    COUNT(*) as num_carers,
    COUNT(DISTINCT v.carer_id) as carers_with_visits,
    ROUND(AVG(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) * 100, 1) as avg_completion_rate_pct,
    ROUND(AVG(CASE WHEN v.visit_late_by_minutes IS NOT NULL THEN v.visit_late_by_minutes ELSE 0 END), 1) as avg_lateness_minutes,
    SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) as total_visits_completed,
    SUM(CASE WHEN v.visit_completed = 0 THEN 1 ELSE 0 END) as total_visits_missed
FROM CARERS c
LEFT JOIN VISITS v ON c.carer_id = v.carer_id
WHERE c.is_active = 1
GROUP BY tenure_bucket
ORDER BY 
    CASE
        WHEN tenure_bucket = 'New (< 1 year)' THEN 1
        WHEN tenure_bucket = '1-2 years' THEN 2
        WHEN tenure_bucket = '2-3 years' THEN 3
        ELSE 4
    END;