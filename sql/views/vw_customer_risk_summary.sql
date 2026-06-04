CREATE OR REPLACE VIEW vw_customer_risk_summary AS
SELECT
    c.customer_id,
    c.customer_name,
    c.customer_segment,
    c.customer_risk_tier,

    SUM(i.outstanding_amount) AS total_outstanding,

    SUM(
        CASE
            WHEN i.aging_bucket = 'CURRENT'
            THEN i.outstanding_amount
            ELSE 0
        END
    ) AS bucket_current,

    SUM(
        CASE
            WHEN i.aging_bucket = '31-60'
            THEN i.outstanding_amount
            ELSE 0
        END
    ) AS bucket_31_60,

    SUM(
        CASE
            WHEN i.aging_bucket = '61-90'
            THEN i.outstanding_amount
            ELSE 0
        END
    ) AS bucket_61_90,

    SUM(
        CASE
            WHEN i.aging_bucket = '90+'
            THEN i.outstanding_amount
            ELSE 0
        END
    ) AS bucket_90plus,

    COUNT(DISTINCT i.invoice_id) AS invoice_count,

    MAX(i.days_overdue) AS max_days_overdue

FROM customers c
JOIN invoices i
    ON c.customer_id = i.customer_id

WHERE i.invoice_status <> 'PAID'

GROUP BY
    c.customer_id,
    c.customer_name,
    c.customer_segment,
    c.customer_risk_tier;