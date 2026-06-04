CREATE OR REPLACE VIEW vw_cashflow_forecast_final AS
SELECT
    aging_bucket,
    invoice_count,
    total_outstanding,
    ROUND(
        total_outstanding /
        SUM(total_outstanding) OVER (),
        2
    ) AS pct_total_outstanding,
    avg_days_overdue,
    collection_probability,
    forecasted_collections,
    cashflow_risk
FROM vw_cashflow_forecast;
