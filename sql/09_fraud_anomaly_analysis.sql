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

-- =================================================
-- 3. Customers with sudden increases in transaction value
-- =================================================
-- Identify customers whose transaction value increased
-- by at least 100% compared with their previous observed month.

WITH cte AS
(
	SELECT t1.CustomerID,
		t3.TransactionID,
		t3.Amount,
		t3.TransactionDate
	FROM customers_cleaned AS t1
	INNER JOIN accounts AS t2
		ON t1.CustomerID = t2.CustomerID
	INNER JOIN transactions AS t3
		ON t2.AccountID = t3.AccountOriginID
	WHERE t3.TransactionDate IS NOT NULL
		AND t3.Amount IS NOT NULL

	UNION

	SELECT t1.CustomerID,
		t3.TransactionID,
		t3.Amount,
		t3.TransactionDate
	FROM customers_cleaned AS t1
	INNER JOIN accounts AS t2
		ON t1.CustomerID = t2.CustomerID
	INNER JOIN transactions AS t3
		ON t2.AccountID = t3.AccountDestinationID
	WHERE t3.TransactionDate IS NOT NULL
		AND t3.Amount IS NOT NULL
),

cte2 AS
(
	SELECT CustomerID,
		YEAR(TransactionDate) AS years,
		MONTH(TransactionDate) AS months,
		SUM(Amount) AS monthly_transaction_value
	FROM cte
	GROUP BY CustomerID, YEAR(TransactionDate), MONTH(TransactionDate)
),

cte3 AS
(
	SELECT CustomerID, years, months,
		monthly_transaction_value,
		LAG(monthly_transaction_value) OVER(PARTITION BY CustomerID ORDER BY years ASC, months ASC ) AS previous_month_value
	FROM cte2
)

SELECT CustomerID,
	years,
	months,
	ROUND(monthly_transaction_value,2) AS current_month_value,
	ROUND(previous_month_value,2) AS previous_month_value,
	ROUND(((monthly_transaction_value - previous_month_value)/ NULLIF(previous_month_value,0)) * 100,2) 
    AS percentage_increase,
	'Potentially Unusual Increase' AS anomaly_indicator
FROM cte3
WHERE previous_month_value IS NOT NULL
	AND previous_month_value > 0
	AND monthly_transaction_value >= 2 * previous_month_value
ORDER BY percentage_increase DESC;