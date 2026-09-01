-- VisitOps Intelligence - Financial KPIs
-- Views for revenue, profitability, and payment tracking

-- 1. Financial summary by commissioner
CREATE OR REPLACE VIEW v_financial_by_commissioner AS
SELECT
    commissioner_name,
    COUNT(*) as total_invoices,
    SUM(num_visits_invoiced) as visits_invoiced,
    SUM(total_amount) as total_revenue,
    ROUND(AVG(total_amount), 2) as avg_invoice_amount,
    SUM(CASE WHEN payment_status = 'paid' THEN 1 ELSE 0 END) as paid_invoices,
    SUM(CASE WHEN payment_status = 'pending' THEN 1 ELSE 0 END) as pending_invoices,
    SUM(CASE WHEN payment_status = 'rejected' THEN 1 ELSE 0 END) as rejected_invoices,
    ROUND(100.0 * SUM(CASE WHEN payment_status = 'paid' THEN 1 ELSE 0 END) / COUNT(*), 1) as paid_rate_pct
FROM INVOICES
GROUP BY commissioner_name
ORDER BY total_revenue DESC;

-- 2. Revenue per visit by commissioner
CREATE OR REPLACE VIEW v_revenue_per_visit AS
SELECT
    i.commissioner_name,
    ROUND(SUM(i.total_amount) / SUM(i.num_visits_invoiced), 2) as revenue_per_visit,
    SUM(i.num_visits_invoiced) as total_visits_invoiced,
    SUM(i.total_amount) as total_revenue
FROM INVOICES i
GROUP BY i.commissioner_name
ORDER BY revenue_per_visit DESC;

-- 3. Payment status summary
CREATE OR REPLACE VIEW v_payment_status_summary AS
SELECT
    payment_status,
    COUNT(*) as invoice_count,
    SUM(total_amount) as total_amount,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM INVOICES), 1) as pct_of_invoices,
    ROUND(100.0 * SUM(total_amount) / (SELECT SUM(total_amount) FROM INVOICES), 1) as pct_of_revenue
FROM INVOICES
GROUP BY payment_status
ORDER BY total_amount DESC;

-- 4. Invoice rejection analysis
CREATE OR REPLACE VIEW v_rejection_analysis AS
SELECT
    commissioner_name,
    SUM(CASE WHEN payment_status = 'rejected' THEN 1 ELSE 0 END) as rejected_count,
    SUM(CASE WHEN payment_status = 'rejected' THEN total_amount ELSE 0 END) as rejected_amount,
    COUNT(*) as total_invoices,
    ROUND(100.0 * SUM(CASE WHEN payment_status = 'rejected' THEN 1 ELSE 0 END) / COUNT(*), 1) as rejection_rate_pct
FROM INVOICES
GROUP BY commissioner_name
HAVING SUM(CASE WHEN payment_status = 'rejected' THEN 1 ELSE 0 END) > 0
ORDER BY rejection_rate_pct DESC;

-- 5. Financial summary (all-time)
CREATE OR REPLACE VIEW v_financial_summary_all_time AS
SELECT
    COUNT(*) as total_invoices,
    SUM(num_visits_invoiced) as total_visits_invoiced,
    SUM(total_amount) as total_revenue,
    ROUND(AVG(total_amount), 2) as avg_invoice_amount,
    SUM(CASE WHEN payment_status = 'paid' THEN total_amount ELSE 0 END) as paid_revenue,
    SUM(CASE WHEN payment_status = 'pending' THEN total_amount ELSE 0 END) as pending_revenue,
    SUM(CASE WHEN payment_status = 'rejected' THEN total_amount ELSE 0 END) as rejected_revenue,
    ROUND(SUM(total_amount) / SUM(num_visits_invoiced), 2) as overall_revenue_per_visit,
    MIN(invoice_date) as earliest_invoice,
    MAX(invoice_date) as latest_invoice
FROM INVOICES;