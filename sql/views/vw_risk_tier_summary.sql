CREATE OR REPLACE VIEW vw_risk_tier_summary AS
SELECT
    customer_risk_tier,
    SUM(outstanding_amount) AS total_outstanding
FROM invoices i
JOIN customers c
    ON i.customer_id = c.customer_id
WHERE invoice_status <> 'PAID'
GROUP BY customer_risk_tier;