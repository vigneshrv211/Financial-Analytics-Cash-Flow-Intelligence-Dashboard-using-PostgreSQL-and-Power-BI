CREATE OR REPLACE VIEW vw_customer_count_by_risk AS
SELECT
    customer_risk_tier,
    COUNT(*) AS customer_count
FROM customers
GROUP BY customer_risk_tier;