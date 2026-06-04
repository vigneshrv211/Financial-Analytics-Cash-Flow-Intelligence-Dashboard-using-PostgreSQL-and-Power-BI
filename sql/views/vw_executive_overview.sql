CREATE OR REPLACE VIEW vw_executive_overview AS
SELECT
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(*) AS total_invoices,
    SUM(invoice_amount) AS total_invoice_amount,
    SUM(outstanding_amount) AS total_outstanding_amount,
    SUM(paid_amount) AS total_paid_amount,
    ROUND(
        SUM(paid_amount) * 100.0 /
        NULLIF(SUM(invoice_amount), 0),
        2
    ) AS collection_efficiency_pct,
    COUNT(
        CASE
            WHEN invoice_status <> 'PAID'
            THEN 1
        END
    ) AS overdue_invoices,
    SUM(
        CASE
            WHEN invoice_status <> 'PAID'
            THEN outstanding_amount
            ELSE 0
        END
    ) AS overdue_amount
FROM invoices;