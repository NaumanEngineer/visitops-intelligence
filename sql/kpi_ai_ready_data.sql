-- VisitOps Intelligence - AI-Ready Data Structures
-- Views prepared for Claude API reasoning layer

-- 1. Anomaly detection flags (prepared for Claude interpretation)
CREATE OR REPLACE VIEW v_anomaly_detection_flags AS
SELECT
    c.carer_id,
    c.name,
    c.employment_type,
    COUNT(DISTINCT v.visit_id) as total_visits,
    ROUND(100.0 * SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(v.visit_id), 0), 1) as overall_completion_rate_pct,
    ROUND(100.0 * SUM(CASE WHEN v.scheduled_date >= CURRENT_DATE - INTERVAL '30 days' AND v.visit_completed = 1 THEN 1 ELSE 0 END) / 
          NULLIF(SUM(CASE WHEN v.scheduled_date >= CURRENT_DATE - INTERVAL '30 days' THEN 1 ELSE 0 END), 0), 1) as recent_30day_completion_rate_pct,
    ROUND(100.0 * SUM(CASE WHEN v.scheduled_date >= CURRENT_DATE - INTERVAL '30 days' AND v.visit_completed = 1 THEN 1 ELSE 0 END) / 
          NULLIF(SUM(CASE WHEN v.scheduled_date >= CURRENT_DATE - INTERVAL '30 days' THEN 1 ELSE 0 END), 0), 1) - 
    ROUND(100.0 * SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(v.visit_id), 0), 1) as completion_rate_change_pct,
    ROUND(AVG(CASE WHEN v.visit_late_by_minutes IS NOT NULL THEN v.visit_late_by_minutes ELSE 0 END), 1) as avg_lateness_minutes,
    SUM(CASE WHEN v.scheduled_date >= CURRENT_DATE - INTERVAL '30 days' THEN 1 ELSE 0 END) as visits_last_30_days,
    CASE
        WHEN ROUND(100.0 * SUM(CASE WHEN v.scheduled_date >= CURRENT_DATE - INTERVAL '30 days' AND v.visit_completed = 1 THEN 1 ELSE 0 END) / 
              NULLIF(SUM(CASE WHEN v.scheduled_date >= CURRENT_DATE - INTERVAL '30 days' THEN 1 ELSE 0 END), 0), 1) - 
             ROUND(100.0 * SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(v.visit_id), 0), 1) < -10 THEN 'DECLINING PERFORMANCE'
        WHEN ROUND(AVG(CASE WHEN v.visit_late_by_minutes IS NOT NULL THEN v.visit_late_by_minutes ELSE 0 END), 1) > 30 THEN 'EXCESSIVE LATENESS'
        WHEN SUM(CASE WHEN v.scheduled_date >= CURRENT_DATE - INTERVAL '30 days' THEN 1 ELSE 0 END) < 3 THEN 'LOW ACTIVITY'
        ELSE 'NORMAL'
    END as anomaly_flag
FROM CARERS c
LEFT JOIN VISITS v ON c.carer_id = v.carer_id
WHERE c.is_active = 1
GROUP BY c.carer_id, c.name, c.employment_type
ORDER BY anomaly_flag DESC;

-- 2. Care quality reasoning data (prepared for Claude explanation)
CREATE OR REPLACE VIEW v_care_quality_reasoning AS
SELECT
    su.service_user_id,
    su.name as service_user_name,
    su.health_needs_level,
    COUNT(DISTINCT v.visit_id) as total_visits_for_user,
    ROUND(100.0 * SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(v.visit_id), 0), 1) as completion_rate_pct,
    SUM(CASE WHEN v.visit_completed = 0 THEN 1 ELSE 0 END) as missed_visits,
    COUNT(DISTINCT i.incident_id) as incidents,
    SUM(CASE WHEN i.severity = 'high' THEN 1 ELSE 0 END) as high_severity_incidents,
    ROUND(AVG(CASE WHEN v.visit_late_by_minutes IS NOT NULL THEN v.visit_late_by_minutes ELSE 0 END), 1) as avg_lateness_minutes,
    CASE
        WHEN su.health_needs_level = 'high' AND SUM(CASE WHEN v.visit_completed = 0 THEN 1 ELSE 0 END) > 0 THEN 'HIGH RISK'
        WHEN SUM(CASE WHEN i.severity = 'high' THEN 1 ELSE 0 END) > 0 THEN 'ESCALATION NEEDED'
        WHEN ROUND(100.0 * SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(v.visit_id), 0), 1) < 90 THEN 'QUALITY CONCERN'
        ELSE 'ACCEPTABLE'
    END as quality_status
FROM SERVICE_USERS su
LEFT JOIN VISITS v ON su.service_user_id = v.service_user_id
LEFT JOIN INCIDENTS i ON v.visit_id = i.visit_id
GROUP BY su.service_user_id, su.name, su.health_needs_level
ORDER BY quality_status DESC;