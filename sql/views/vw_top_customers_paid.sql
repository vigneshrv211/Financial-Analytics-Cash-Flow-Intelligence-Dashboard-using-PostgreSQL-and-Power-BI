CREATE OR REPLACE VIEW vw_top_customers_paid AS
SELECT
    c.customer_id,
    c.customer_name,
    SUM(p.payment_amount) AS total_paid_amount,
    COUNT(p.payment_id) AS total_payments,
    AVG(p.days_to_pay) AS avg_days_to_pay
FROM payments p
JOIN customers c
    ON p.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY
    total_paid_amount DESC
LIMIT 5;