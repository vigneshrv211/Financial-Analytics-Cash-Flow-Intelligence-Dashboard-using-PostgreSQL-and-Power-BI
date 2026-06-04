SELECT
    CASE
        WHEN due_date BETWEEN CURRENT_DATE AND CURRENT_DATE + 30 THEN 'Due_0_30'
        WHEN due_date BETWEEN CURRENT_DATE + 31 AND CURRENT_DATE + 60 THEN 'Due_31_60'
        WHEN due_date BETWEEN CURRENT_DATE + 61 AND CURRENT_DATE + 90 THEN 'Due_61_90'
    END AS due_window,

    COUNT(*) AS invoice_count,

    SUM(outstanding_amount) AS expected_cash_inflow

FROM invoices
WHERE invoice_status <> 'PAID'
  AND due_date BETWEEN CURRENT_DATE AND CURRENT_DATE + 90

GROUP BY due_window
ORDER BY due_window;