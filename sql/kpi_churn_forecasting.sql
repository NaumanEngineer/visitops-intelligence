-- VisitOps Intelligence - Churn & Forecasting Analysis
-- Views for predicting risk and forecasting future demand

-- 1. Carer churn risk indicators
CREATE OR REPLACE VIEW v_carer_churn_risk AS
SELECT
    c.carer_id,
    c.name,
    c.employment_type,
    CAST((CURRENT_DATE - c.start_date) / 365.25 AS INT) as tenure_years,
    COUNT(DISTINCT v.visit_id) as total_visits,
    COUNT(DISTINCT v.scheduled_date) as days_worked,
    ROUND(100.0 * SUM(CASE WHEN v.visit_completed = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(v.visit_id), 0), 1) as overall_completion_rate_pct,
    ROUND(100.0 * SUM(CASE WHEN v.scheduled_date >= CURRENT_DATE - INTERVAL '30 days' AND v.visit_completed = 1 THEN 1 ELSE 0 END) / 
          NULLIF(SUM(CASE WHEN v.scheduled_date >= CURRENT_DATE - INTERVAL '30 days' THEN 1 ELSE 0 END), 0), 1) as recent_30day_completion_rate_pct,
    SUM(CASE WHEN v.scheduled_date >= CURRENT_DATE - INTERVAL '30 days' THEN 1 ELSE 0 END) as visits_last_30_days,
    CASE
        WHEN ROUND(100.0 * SUM(CASE WHEN v.scheduled_date >= CURRENT_DATE - INTERVAL '30 days' AND v.visit_completed = 1 THEN 1 ELSE 0 END) / 
              NULLIF(SUM(CASE WHEN v.scheduled_date >= CURRENT_DATE - INTERVAL '30 days' THEN 1 ELSE 0 END), 0), 1) < 85 
             AND COUNT(DISTINCT v.scheduled_date) < 5 THEN 'HIGH RISK'
        WHEN ROUND(100.0 * SUM(CASE WHEN v.scheduled_date >= CURRENT_DATE - INTERVAL '30 days' AND v.visit_completed = 1 THEN 1 ELSE 0 END) / 
              NULLIF(SUM(CASE WHEN v.scheduled_date >= CURRENT_DATE - INTERVAL '30 days' THEN 1 ELSE 0 END), 0), 1) < 90 THEN 'MEDIUM RISK'
        WHEN CAST((CURRENT_DATE - c.start_date) / 365.25 AS INT) < 1 THEN 'EARLY STAGE'
        ELSE 'LOW RISK'
    END as churn_risk_level
FROM CARERS c
LEFT JOIN VISITS v ON c.carer_id = v.carer_id
WHERE c.is_active = 1
GROUP BY c.carer_id, c.name, c.employment_type, c.start_date
ORDER BY churn_risk_level DESC;

-- 2. Commissioner churn risk
CREATE OR REPLACE VIEW v_commissioner_churn_risk AS
SELECT
    i.commissioner_name,
    COUNT(DISTINCT i.invoice_id) as total_invoices,
    SUM(i.num_visits_invoiced) as total_visits_invoiced,
    SUM(i.total_amount) as total_revenue,
    MAX(i.invoice_date) as last_invoice_date,
    CAST((CURRENT_DATE - MAX(i.invoice_date)) AS INT) as days_since_last_invoice,
    ROUND(100.0 * SUM(CASE WHEN i.payment_status = 'paid' THEN 1 ELSE 0 END) / COUNT(DISTINCT i.invoice_id), 1) as paid_rate_pct,
    ROUND(100.0 * SUM(CASE WHEN i.payment_status = 'rejected' THEN 1 ELSE 0 END) / COUNT(DISTINCT i.invoice_id), 1) as rejection_rate_pct,
    SUM(CASE WHEN i.invoice_date >= CURRENT_DATE - INTERVAL '30 days' THEN i.total_amount ELSE 0 END) as recent_30day_revenue,
    CASE
        WHEN CAST((CURRENT_DATE - MAX(i.invoice_date)) AS INT) > 60 THEN 'HIGH RISK'
        WHEN ROUND(100.0 * SUM(CASE WHEN i.payment_status = 'rejected' THEN 1 ELSE 0 END) / COUNT(DISTINCT i.invoice_id), 1) > 20 THEN 'HIGH RISK'
        WHEN CAST((CURRENT_DATE - MAX(i.invoice_date)) AS INT) > 30 THEN 'MEDIUM RISK'
        WHEN ROUND(100.0 * SUM(CASE WHEN i.payment_status = 'rejected' THEN 1 ELSE 0 END) / COUNT(DISTINCT i.invoice_id), 1) > 10 THEN 'MEDIUM RISK'
        ELSE 'LOW RISK'
    END as churn_risk_level
FROM INVOICES i
GROUP BY i.commissioner_name
ORDER BY churn_risk_level DESC;

-- 3. Visit forecast (next 30 days)
CREATE OR REPLACE VIEW v_visit_forecast_next_30days AS
SELECT
    STRFTIME('%Y-%m', scheduled_date) as forecast_month,
    COUNT(*) as visits_completed_this_month,
    ROUND(AVG(COUNT(*)) OVER (ORDER BY STRFTIME('%Y-%m', scheduled_date) ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 0) as moving_avg_monthly_visits,
    ROUND(COUNT(*) * 0.95, 0) as conservative_forecast,
    ROUND(COUNT(*) * 1.05, 0) as optimistic_forecast,
    MIN(scheduled_date) as month_start,
    MAX(scheduled_date) as month_end
FROM VISITS
WHERE scheduled_date >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY STRFTIME('%Y-%m', scheduled_date)
ORDER BY forecast_month DESC;