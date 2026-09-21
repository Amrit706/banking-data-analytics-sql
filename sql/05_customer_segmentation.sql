-- ===============================
-- Customer Segmentation
-- ===============================
USE finance_fraud_loans;

-- • High-Value Customers
-- Customers with high balances and high transaction value.

WITH cte AS
(
	SELECT t1.CustomerID, CONCAT_WS(" ",t1.FirstName, t1.LastName) AS customer_name, t2.Balance
	FROM customers_cleaned AS t1
	INNER JOIN accounts AS t2
		ON t1.CustomerID = t2.CustomerID
	INNER JOIN account_statuses AS t3
		ON t2.AccountStatusID = t3.AccountStatusID
	WHERE t3.StatusName = "Active"
),

cte2 AS 
(
	SELECT CustomerID, customer_name, ROUND(SUM(Balance),2) AS total_balance
	FROM cte
	GROUP BY CustomerID, customer_name
	ORDER BY total_balance DESC
),

cte3 AS
(
	SELECT t.CustomerID, t.customer_name, t.total_balance
	FROM (SELECT CustomerID, customer_name, total_balance,
			ROUND(((COUNT(*) OVER() ) * 0.2)) AS top_20_percent,
			ROW_NUMBER() OVER(ORDER BY total_balance DESC) AS rnk
		  FROM cte2) AS t
	WHERE t.rnk <= t.top_20_percent
),

cte4 AS
(
	SELECT t1.CustomerID, CONCAT_WS(" ", t1.FirstName, t1.LastName) AS customer_name, t3.TransactionID
	FROM customers_cleaned AS t1
	INNER JOIN accounts AS t2
		ON t1.CustomerID = t2.CustomerID
	INNER JOIN transactions AS t3
		ON t2.AccountID = t3.AccountOriginID
	UNION
	SELECT t1.CustomerID, CONCAT_WS(" ", t1.FirstName, t1.LastName) AS customer_name, t3.TransactionID
	FROM customers_cleaned AS t1
	INNER JOIN accounts AS t2
		ON t1.CustomerID = t2.CustomerID
	INNER JOIN transactions AS t3
		ON t2.AccountID = t3.AccountDestinationID
),

cte5 AS
(
	SELECT CustomerID, customer_name, COUNT(TransactionID) AS trans_counts,
		ROUND((COUNT(*) OVER() * 0.2)) AS top_20_percent,
        ROW_NUMBER() OVER(ORDER BY COUNT(TransactionID) DESC) AS rnk
	FROM cte4
	GROUP BY CustomerID, customer_name
),

cte6 AS
(
	SELECT CustomerID, customer_name, trans_counts
	FROM cte5
	WHERE rnk <= top_20_percent
)

SELECT t1.CustomerID, t1.customer_name, t1.total_balance, trans_counts
FROM cte3 AS t1
INNER JOIN cte6 AS t2
	ON t1.CustomerID = t2.CustomerID AND t1.customer_name = t2.customer_name
ORDER BY total_balance DESC, trans_counts DESC;

-- • High-Frequency Customers
-- Customers performing transactions frequently.

WITH cte AS
(
	SELECT t1.CustomerID, CONCAT_WS(" ", t1.FirstName, t1.LastName) AS customer_name, t3.TransactionID
	FROM customers_cleaned AS t1
	INNER JOIN accounts AS t2
		ON t1.CustomerID = t2.CustomerID
	INNER JOIN transactions AS t3
		ON t2.AccountID = t3.AccountOriginID
	UNION
	SELECT t1.CustomerID, CONCAT_WS(" ", t1.FirstName, t1.LastName) AS customer_name, t3.TransactionID
	FROM customers_cleaned AS t1
	INNER JOIN accounts AS t2
		ON t1.CustomerID = t2.CustomerID
	INNER JOIN transactions AS t3
		ON t2.AccountID = t3.AccountDestinationID
),

cte2 AS
(
	SELECT CustomerID, customer_name, COUNT(TransactionID) AS trans_counts,
		ROUND((COUNT(*) OVER() * 0.2)) AS top_20_percent,
        DENSE_RANK() OVER(ORDER BY COUNT(TransactionID) DESC) AS rnk
	FROM cte
	GROUP BY CustomerID, customer_name
)

SELECT CustomerID, customer_name, trans_counts
FROM cte2
WHERE rnk <= top_20_percent;

-- • Dormant Customers
-- Customers with no recent transactions.

WITH cte AS
(
    SELECT 
        t1.CustomerID,
        t1.AccountID,
        MAX(t2.TransactionDate) AS latest_trans
    FROM accounts AS t1
    LEFT JOIN transactions AS t2
        ON t1.AccountID = t2.AccountOriginID
    INNER JOIN account_statuses AS t3
        ON t1.AccountStatusID = t3.AccountStatusID
    WHERE t3.StatusName = 'Active'
    GROUP BY t1.CustomerID, t1.AccountID

    UNION ALL

    SELECT 
        t1.CustomerID,
        t1.AccountID,
        MAX(t2.TransactionDate) AS latest_trans
    FROM accounts AS t1
    LEFT JOIN transactions AS t2
        ON t1.AccountID = t2.AccountDestinationID
    INNER JOIN account_statuses AS t3
        ON t1.AccountStatusID = t3.AccountStatusID
    WHERE t3.StatusName = 'Active'
    GROUP BY t1.CustomerID, t1.AccountID
),

latest_activity AS
(
    SELECT 
        CustomerID,
        MAX(latest_trans) AS latest_trans_date
    FROM cte
    GROUP BY CustomerID
),

latest_dataset_date AS
(
    SELECT MAX(TransactionDate) AS max_transaction_date
    FROM transactions
)

SELECT 
    t1.CustomerID,
    t1.latest_trans_date,
    'Dormant' AS customer_category
FROM latest_activity AS t1
CROSS JOIN latest_dataset_date AS t2
WHERE t1.latest_trans_date < DATE_SUB(t2.max_transaction_date, INTERVAL 12 MONTH)
   OR t1.latest_trans_date IS NULL;
