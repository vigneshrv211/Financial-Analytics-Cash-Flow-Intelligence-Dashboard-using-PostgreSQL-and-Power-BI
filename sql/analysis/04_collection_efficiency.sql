SELECT
    customer_id,

    SUM(invoice_amount) AS total_invoiced,

    SUM(paid_amount) AS total_collected,

    ROUND(
        SUM(paid_amount) * 100.0 /
        NULLIF(SUM(invoice_amount),0),
        2
    ) AS collection_efficiency_pct,

    SUM(outstanding_amount) AS total_outstanding

FROM invoices
GROUP BY customer_id
ORDER BY collection_efficiency_pct;