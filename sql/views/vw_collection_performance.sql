CREATE OR REPLACE VIEW vw_collection_performance AS
SELECT
    DATE_TRUNC('month', p.payment_date)::date AS payment_month,

    COUNT(p.payment_id) AS total_payments,

    SUM(p.payment_amount) AS total_paid_amount,

    AVG(p.days_to_pay) AS avg_days_to_pay,

    SUM(
        CASE
            WHEN p.on_time_flag = true
            THEN p.payment_amount
            ELSE 0
        END
    ) AS on_time_amount,

    SUM(
        CASE
            WHEN p.on_time_flag = false
            THEN p.payment_amount
            ELSE 0
        END
    ) AS late_amount,

    COUNT(
        CASE
            WHEN p.on_time_flag = true
            THEN 1
        END
    ) AS on_time_payments,

    COUNT(
        CASE
            WHEN p.on_time_flag = false
            THEN 1
        END
    ) AS late_payments

FROM payments p
GROUP BY DATE_TRUNC('month', p.payment_date)
ORDER BY payment_month;