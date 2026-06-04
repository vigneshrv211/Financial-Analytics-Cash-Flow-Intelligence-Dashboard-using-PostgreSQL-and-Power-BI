with monthly_revenue as (
    SELECT customer_id,
        DATE_TRUNC('month',invoice_date) as month,
        SUM(invoice_amount) as monthly_invoiced
    FROM invoices
    GROUP BY customer_id, DATE_TRUNC('month',invoice_date)
),
monthly_ar AS (
    select customer_id,
        DATE_TRUNC('month', due_date) AS month,
        SUM(outstanding_amount) AS end_ar
    FROM invoices
    WHERE invoice_status <> 'PAID'
    GROUP BY customer_id, DATE_TRUNC('month', due_date)
)
SELECT
    r.customer_id,
    r.month,
    r.monthly_invoiced,
    COALESCE(a.end_ar,0) AS end_ar,
    ROUND((COALESCE(a.end_ar,0) / NULLIF(r.monthly_invoiced,0)) * 30,1) as dso
FROM monthly_revenue r
LEFT JOIN monthly_ar a
    USING(customer_id, month)
ORDER BY r.customer_id, r.month;