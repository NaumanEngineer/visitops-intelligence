-- VisitOps Intelligence - Operational KPIs
-- Views for visit completion, lateness, and performance metrics

-- 1. Daily operational summary
CREATE OR REPLACE VIEW v_operational_daily_summary AS
SELECT 
    scheduled_date,
    COUNT(*) as total_scheduled_visits,
    SUM(CASE WHEN visit_completed = 1 THEN 1 ELSE 0 END) as completed_visits,
    SUM(CASE WHEN visit_completed = 0 THEN 1 ELSE 0 END) as missed_visits,
    ROUND(100.0 * SUM(CASE WHEN visit_completed = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) as completion_rate_pct,
    SUM(CASE WHEN visit_late_by_minutes IS NOT NULL AND visit_late_by_minutes > 0 THEN 1 ELSE 0 END) as late_visits,
    ROUND(AVG(CASE WHEN visit_late_by_minutes IS NOT NULL THEN visit_late_by_minutes ELSE 0 END), 1) as avg_lateness_minutes
FROM VISITS
GROUP BY scheduled_date
ORDER BY scheduled_date DESC;

-- 2. Visit type breakdown
CREATE OR REPLACE VIEW v_visit_type_summary AS
SELECT
    visit_type,
    COUNT(*) as total_visits,
    SUM(CASE WHEN visit_completed = 1 THEN 1 ELSE 0 END) as completed_visits,
    SUM(CASE WHEN visit_completed = 0 THEN 1 ELSE 0 END) as missed_visits,
    ROUND(100.0 * SUM(CASE WHEN visit_completed = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) as completion_rate_pct,
    ROUND(AVG(CASE WHEN visit_late_by_minutes IS NOT NULL THEN visit_late_by_minutes ELSE 0 END), 1) as avg_lateness_minutes
FROM VISITS
GROUP BY visit_type
ORDER BY total_visits DESC;

-- 3. Overall operational metrics
CREATE OR REPLACE VIEW v_operational_summary_all_time AS
SELECT
    COUNT(*) as total_visits,
    SUM(CASE WHEN visit_completed = 1 THEN 1 ELSE 0 END) as completed_visits,
    SUM(CASE WHEN visit_completed = 0 THEN 1 ELSE 0 END) as missed_visits,
    ROUND(100.0 * SUM(CASE WHEN visit_completed = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) as completion_rate_pct,
    SUM(CASE WHEN visit_late_by_minutes IS NOT NULL AND visit_late_by_minutes > 0 THEN 1 ELSE 0 END) as late_visits,
    ROUND(100.0 * SUM(CASE WHEN visit_late_by_minutes IS NOT NULL AND visit_late_by_minutes > 0 THEN 1 ELSE 0 END) / COUNT(*), 1) as late_rate_pct,
    ROUND(AVG(CASE WHEN visit_late_by_minutes IS NOT NULL THEN visit_late_by_minutes ELSE 0 END), 1) as avg_lateness_minutes,
    MIN(scheduled_date) as data_start_date,
    MAX(scheduled_date) as data_end_date,
    COUNT(DISTINCT scheduled_date) as days_of_data
FROM VISITS;

-- 4. Lateness analysis
CREATE OR REPLACE VIEW v_lateness_analysis AS
SELECT
    CASE 
        WHEN visit_late_by_minutes IS NULL OR visit_late_by_minutes = 0 THEN 'On time'
        WHEN visit_late_by_minutes > 0 AND visit_late_by_minutes <= 15 THEN '1-15 minutes late'
        WHEN visit_late_by_minutes > 15 AND visit_late_by_minutes <= 30 THEN '16-30 minutes late'
        WHEN visit_late_by_minutes > 30 THEN '30+ minutes late'
        ELSE 'Not completed'
    END as lateness_category,
    COUNT(*) as visit_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM VISITS), 1) as pct_of_all_visits
FROM VISITS
GROUP BY lateness_category
ORDER BY visit_count DESC;

-- 5. Completion rate by week
CREATE OR REPLACE VIEW v_completion_by_week AS
SELECT
    STRFTIME('%Y-W%V', scheduled_date) as week,
    COUNT(*) as total_visits,
    SUM(CASE WHEN visit_completed = 1 THEN 1 ELSE 0 END) as completed_visits,
    ROUND(100.0 * SUM(CASE WHEN visit_completed = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) as completion_rate_pct
FROM VISITS
GROUP BY week
ORDER BY week DESC;