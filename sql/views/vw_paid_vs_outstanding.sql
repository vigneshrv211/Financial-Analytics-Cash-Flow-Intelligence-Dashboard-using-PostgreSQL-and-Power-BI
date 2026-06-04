CREATE OR REPLACE VIEW vw_paid_vs_outstanding AS
SELECT
    'Paid Amount' AS metric,
    total_paid_amount AS amount
FROM vw_executive_overview

UNION ALL

SELECT
    'Outstanding Amount' AS metric,
    total_outstanding_amount AS amount
FROM vw_executive_overview;
