CREATE OR REPLACE VIEW vw_cashflow_forecast AS
SELECT
    aging_bucket,

    COUNT(invoice_id) AS invoice_count,

    SUM(outstanding_amount) AS total_outstanding,

    AVG(days_overdue) AS avg_days_overdue,

    CASE
        WHEN aging_bucket = 'CURRENT' THEN 0.92
        WHEN aging_bucket = '31-60' THEN 0.58
        WHEN aging_bucket = '61-90' THEN 0.38
        WHEN aging_bucket = '90+' THEN 0.02
        ELSE 0
    END AS collection_probability,

    SUM(outstanding_amount) *
    CASE
        WHEN aging_bucket = 'CURRENT' THEN 0.92
        WHEN aging_bucket = '31-60' THEN 0.58
        WHEN aging_bucket = '61-90' THEN 0.38
        WHEN aging_bucket = '90+' THEN 0.02
        ELSE 0
    END AS forecasted_collections,

    CASE
        WHEN aging_bucket = 'CURRENT' THEN 'Low'
        WHEN aging_bucket = '31-60' THEN 'Medium'
        WHEN aging_bucket = '61-90' THEN 'High'
        WHEN aging_bucket = '90+' THEN 'Very High'
    END AS cashflow_risk

FROM invoices
WHERE invoice_status <> 'PAID'
GROUP BY aging_bucket;