with customer_stats as (
    SELECT customer_id,
        SUM(outstanding_amount) AS total_outstanding,
        SUM(CASE WHEN aging_bucket = '90+' THEN outstanding_amount ELSE 0 END
        ) / NULLIF(SUM(outstanding_amount),0) * 100 AS pct_90plus,
        AVG(days_overdue) AS avg_days_overdue,
        
        COUNT(CASE WHEN invoice_status = 'PARTIAL' THEN 1 END ) * 100.0 / 
        COUNT(*) AS pct_partial,
        MAX(days_overdue) AS max_days_overdue
    FROM invoices
    WHERE invoice_status <> 'PAID'
    GROUP BY customer_id)
SELECT
    customer_id,
    total_outstanding,
    ROUND(pct_90plus,1) AS pct_90plus,
    ROUND(avg_days_overdue,1) AS avg_days_overdue,
    LEAST(
        100,
        ROUND(
            (pct_90plus * 0.40)
            +
            (LEAST(avg_days_overdue,90) / 90 * 100 * 0.35)
            +
            (pct_partial * 0.25)
        )
    ) AS risk_score,

    CASE
        WHEN pct_90plus > 50 OR max_days_overdue > 120 THEN 'CRITICAL'
        WHEN pct_90plus > 30 OR avg_days_overdue > 60 THEN 'RED'
        WHEN pct_90plus > 10 OR avg_days_overdue > 30 THEN 'AMBER'
        ELSE 'GREEN'
    END AS risk_label

FROM customer_stats
ORDER BY risk_score DESC;