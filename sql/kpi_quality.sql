-- VisitOps Intelligence - Quality KPIs
-- Views for incident tracking, safeguarding, and quality metrics

-- 1. Incident rate summary
CREATE OR REPLACE VIEW v_incident_rate_summary AS
SELECT
    ROUND(1000.0 * COUNT(DISTINCT i.incident_id) / COUNT(DISTINCT v.visit_id), 1) as incidents_per_1000_visits,
    COUNT(DISTINCT i.incident_id) as total_incidents,
    COUNT(DISTINCT v.visit_id) as total_visits,
    SUM(CASE WHEN v.visit_completed = 0 THEN 1 ELSE 0 END) as missed_visits,
    ROUND(100.0 * SUM(CASE WHEN v.visit_completed = 0 THEN 1 ELSE 0 END) / COUNT(DISTINCT v.visit_id), 1) as missed_visit_rate_pct
FROM VISITS v
LEFT JOIN INCIDENTS i ON v.visit_id = i.visit_id;

-- 2. Incident breakdown by type and severity
CREATE OR REPLACE VIEW v_incident_breakdown AS
SELECT
    incident_type,
    severity,
    COUNT(*) as incident_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM INCIDENTS), 1) as pct_of_total_incidents
FROM INCIDENTS
GROUP BY incident_type, severity
ORDER BY incident_count DESC;

-- 3. Missed visit analysis
CREATE OR REPLACE VIEW v_missed_visit_analysis AS
SELECT
    v.scheduled_date,
    COUNT(*) as missed_visits,
    COUNT(DISTINCT v.service_user_id) as affected_service_users,
    COUNT(DISTINCT v.carer_id) as carers_with_misses
FROM VISITS v
WHERE v.visit_completed = 0
GROUP BY v.scheduled_date
ORDER BY v.scheduled_date DESC;

-- 4. Safeguarding incidents
CREATE OR REPLACE VIEW v_safeguarding_incidents AS
SELECT
    incident_type,
    severity,
    COUNT(*) as incident_count,
    COUNT(DISTINCT i.visit_id) as affected_visits,
    MIN(i.reported_date) as first_reported,
    MAX(i.reported_date) as most_recent
FROM INCIDENTS i
WHERE incident_type IN ('safeguarding_concern', 'missed_visit', 'complaint')
GROUP BY incident_type, severity
ORDER BY incident_count DESC;

-- 5. Incident severity distribution
CREATE OR REPLACE VIEW v_severity_distribution AS
SELECT
    severity,
    COUNT(*) as incident_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM INCIDENTS), 1) as pct_of_incidents
FROM INCIDENTS
GROUP BY severity
ORDER BY 
    CASE 
        WHEN severity = 'high' THEN 1
        WHEN severity = 'medium' THEN 2
        WHEN severity = 'low' THEN 3
        ELSE 4
    END;

-- 6. Quality metrics (all-time)
CREATE OR REPLACE VIEW v_quality_summary_all_time AS
SELECT
    COUNT(DISTINCT v.visit_id) as total_visits,
    SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) as completed_visits,
    SUM(CASE WHEN v.visit_completed = 0 THEN 1 ELSE 0 END) as missed_visits,
    ROUND(100.0 * SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) / COUNT(DISTINCT v.visit_id), 1) as completion_rate_pct,
    COUNT(DISTINCT i.incident_id) as total_incidents,
    ROUND(1000.0 * COUNT(DISTINCT i.incident_id) / COUNT(DISTINCT v.visit_id), 1) as incidents_per_1000_visits,
    SUM(CASE WHEN i.severity = 'high' THEN 1 ELSE 0 END) as high_severity_incidents,
    SUM(CASE WHEN i.severity = 'medium' THEN 1 ELSE 0 END) as medium_severity_incidents,
    MIN(v.scheduled_date) as data_start_date,
    MAX(v.scheduled_date) as data_end_date
FROM VISITS v
LEFT JOIN INCIDENTS i ON v.visit_id = i.visit_id;