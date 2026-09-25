-- ================================================
-- Fraud / Anomaly Investigation
-- ================================================

USE finance_fraud_loans;

-- These queries identify potentially unusual transaction patterns
-- that may require further investigation.
-- They do not confirm fraudulent activity.


-- =================================================
-- 1. Unusually large transactions
-- =================================================
-- Identify the top 5% largest transactions.

WITH cte AS
(
	SELECT TransactionID, Amount,
		ROW_NUMBER() OVER(ORDER BY Amount DESC) AS rnk,
		COUNT(*) OVER() AS total_transactions
	FROM transactions
	WHERE Amount IS NOT NULL
),

cte2 AS
(
	SELECT TransactionID, Amount, rnk, total_transactions,
		ROUND(total_transactions * 0.05) AS top_5_percent
	FROM cte
)

SELECT TransactionID, ROUND(Amount,2) AS transaction_amount,
	'Potentially Unusual' AS anomaly_indicator
FROM cte2
WHERE rnk <= top_5_percent
ORDER BY transaction_amount DESC;