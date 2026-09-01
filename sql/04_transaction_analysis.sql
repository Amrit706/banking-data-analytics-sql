-- ===============================
-- Transaction Analysis
-- ===============================

-- Analyze transaction behavior across customers and accounts.

USE finance_fraud_loans;

-- • What is the total transaction volume?

SELECT COUNT(*) AS total_transactions_counts
FROM transactions;

-- • What is the total transaction value?

SELECT ROUND(SUM(Amount),2) AS total_transaction_amount
FROM transactions;

-- • What are the most common transaction types?

SELECT t2.TypeName AS trans_type, COUNT(t1.TransactionID) AS trans_count
FROM transactions AS t1
INNER JOIN transaction_types AS t2
	ON t1.TransactionTypeID = t2.TransactionTypeID
GROUP BY t2.TypeName
ORDER BY trans_count DESC LIMIT 1;

-- • What is the monthly transaction trend?

WITH cte AS
(
	SELECT CONCAT_WS(" ",MONTHNAME(TransactionDate) , YEAR(TransactionDate)) AS month_name, 
		YEAR(TransactionDate) AS years, MONTH(TransactionDate) AS months, COUNT(TransactionID) AS trans_count
	FROM transactions
	GROUP BY month_name, months, years
	ORDER BY YEAR(TransactionDate) ASC, MONTH(TransactionDate) ASC
)

SELECT month_name AS months, trans_count
FROM cte;

-- • What is the average transaction value?

SELECT ROUND(AVG(Amount),2) AS avg_amount
FROM transactions;

-- • Which branches have the highest transaction activity?

SELECT t2.BranchName AS branch, COUNT(t1.TransactionID) AS trans_counts
FROM transactions AS t1 
INNER JOIN branches AS t2
	ON t1.BranchID = t2.BranchID
GROUP BY t2.BranchName
ORDER BY trans_counts DESC LIMIT 1;

-- • Which branches have the highest transaction activity?

SELECT t2.BranchName AS branch, COUNT(t1.TransactionID) AS trans_counts
FROM transactions AS t1 
INNER JOIN branches AS t2
	ON t1.BranchID = t2.BranchID
GROUP BY t2.BranchName
ORDER BY trans_counts DESC LIMIT 1;

-- • Which customers perform the highest number of transactions?

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
)

SELECT CustomerID, customer_name, COUNT(TransactionID) AS trans_counts
FROM cte
GROUP BY CustomerID, customer_name
ORDER BY trans_counts DESC LIMIT 1;

-- • Which customers perform the highest number of transactions?

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
)

SELECT CustomerID, customer_name, COUNT(TransactionID) AS trans_counts
FROM cte
GROUP BY CustomerID, customer_name
ORDER BY trans_counts DESC LIMIT 1;

-- • Which customers have the highest transaction value?

WITH cte AS
(
	SELECT t1.CustomerID, CONCAT_WS(" ", t1.FirstName, t1.LastName) AS customer_name, t3.Amount, t3.TransactionID
	FROM customers_cleaned AS t1
	INNER JOIN accounts AS t2
		ON t1.CustomerID = t2.CustomerID
	INNER JOIN transactions AS t3
		ON t2.AccountID = t3.AccountOriginID
	UNION
	SELECT t1.CustomerID, CONCAT_WS(" ", t1.FirstName, t1.LastName) AS customer_name, t3.Amount, t3.TransactionID
	FROM customers_cleaned AS t1
	INNER JOIN accounts AS t2
		ON t1.CustomerID = t2.CustomerID
	INNER JOIN transactions AS t3
		ON t2.AccountID = t3.AccountDestinationID
)

SELECT CustomerID, customer_name, ROUND(SUM(Amount),2) AS total_amount
FROM cte
GROUP BY CustomerID, customer_name
ORDER BY total_amount DESC LIMIT 1;

-- • How are transactions distributed across the available transaction types?

SELECT t2.TypeName AS trans_type, COUNT(t1.TransactionID) AS trans_count
FROM transactions AS t1
INNER JOIN transaction_types AS t2
	ON t1.TransactionTypeID = t2.TransactionTypeID
GROUP BY t2.TypeName
ORDER BY trans_count DESC;