CREATE OR REPLACE VIEW vw_monthly_cashflow_forecast AS
SELECT
    DATE_TRUNC('month', payment_date)::date AS forecast_month,
    TO_CHAR(
        DATE_TRUNC('month', payment_date),
        'Mon YYYY'
    ) AS month_year,
    SUM(payment_amount) * 1.10 AS forecasted_collections
FROM payments
GROUP BY DATE_TRUNC('month', payment_date);
