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

-- =================================================
-- 2. Multiple transactions within a short interval
-- =================================================
-- Identify transactions occurring within 5 minutes
-- of the previous transaction for the same account.

WITH cte AS
(
	SELECT t1.AccountOriginID AS AccountID, 
		t1.TransactionID, 
		t1.TransactionDate
	FROM transactions AS t1
	WHERE t1.AccountOriginID IS NOT NULL
		AND t1.TransactionDate IS NOT NULL
	
	UNION
	
	SELECT t1.AccountDestinationID AS AccountID, 
		t1.TransactionID, 
		t1.TransactionDate
	FROM transactions AS t1
	WHERE t1.AccountDestinationID IS NOT NULL
		AND t1.TransactionDate IS NOT NULL
),

cte2 AS
(
	SELECT AccountID, TransactionID, TransactionDate,
		LAG(TransactionDate) OVER(PARTITION BY AccountID ORDER BY TransactionDate) AS previous_transaction_date
	FROM cte
)

SELECT AccountID, TransactionID, TransactionDate,
	previous_transaction_date,
	TIMESTAMPDIFF(MINUTE, previous_transaction_date, TransactionDate) AS minutes_difference,
	'Potentially Unusual Short Interval' AS anomaly_indicator
FROM cte2
WHERE previous_transaction_date IS NOT NULL
	AND TIMESTAMPDIFF(MINUTE, previous_transaction_date, TransactionDate) <= 5
ORDER BY minutes_difference ASC, AccountID, TransactionDate;