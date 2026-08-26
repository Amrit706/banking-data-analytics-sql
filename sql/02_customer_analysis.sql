-- ===============================
-- Customer Analysis
-- ===============================
USE finance_fraud_loans;

-- • How many unique customers does the bank have?

SELECT COUNT(DISTINCT customerID) AS unique_customer_count
FROM customers_cleaned;

-- • How are customers distributed by age (derived from DateOfBirth), customer type, and location (using the Addresses table)?

-- Distribution of customers by age

SELECT CASE WHEN DateOfBirth_clean IS NULL THEN 'Unknown'
		ELSE CAST(TIMESTAMPDIFF(YEAR, DateOfBirth_clean, CURDATE()) AS CHAR) 
        END AS age,
COUNT(customerID) AS customer_count
FROM customers_cleaned
GROUP BY age
ORDER BY age ASC;

-- NOTE - here age = 0 , showing that the age is less than a year.

-- Distribution of customers by customer type

SELECT t2.TypeName AS customer_type, COUNT(t1.customerID) AS customer_count
FROM customers_cleaned AS t1
JOIN customer_types AS t2
ON t1.CustomerTypeID = t2.CustomerTypeID
GROUP BY customer_type
ORDER BY customer_count;

-- Distribution of customers by locations

SELECT t2.Country, t2.City, COUNT(t1.customerID) AS customer_count
FROM customers_cleaned AS t1
JOIN addresses AS t2
ON t1.AddressID = t2.AddressID
GROUP BY t2.Country, t2.City;

-- • How many customers have one active account versus multiple active accounts?

WITH cte AS
(
	SELECT t1.CustomerID, COUNT(DISTINCT AccountID) AS account_count
	FROM customers_cleaned AS t1
	INNER JOIN accounts AS t2
	ON t1.CustomerID = t2.CustomerID
	INNER JOIN account_statuses AS t3
	ON t2.AccountStatusID = t3.AccountStatusID
    WHERE t3.StatusName = 'Active'
	GROUP BY t1.CustomerID
)

SELECT CASE WHEN account_count = 1 THEN 'one' ELSE 'more_than_one' END AS account_cnt, COUNT(*) AS customer_count
FROM cte
GROUP BY account_cnt;

-- • Which customers have the highest total account balance?

SELECT t1.CustomerID, CONCAT_WS(" ",t1.FirstName, t1.LastName) AS customer_name, ROUND(SUM(t2.Balance),2) AS total_account_balance
FROM customers_cleaned AS t1
INNER JOIN accounts AS t2
ON t1.CustomerID = t2.CustomerID
GROUP BY CustomerID, customer_name
ORDER BY total_account_balance DESC LIMIT 1;

-- • Which customers generate the highest transaction activity?

WITH cte
AS (
	SELECT t1.CustomerID, CONCAT_WS(" ",t1.FirstName, t1.LastName) AS customer_name, COUNT(t3.TransactionID) AS transaction_activity_cnt
	FROM customers_cleaned AS t1
	INNER JOIN accounts AS t2
	ON t1.CustomerID = t2.CustomerID
	INNER JOIN transactions AS t3
	ON t2.AccountID = t3.AccountOriginID
	GROUP BY t1.CustomerID, customer_name
	ORDER BY transaction_activity_cnt DESC LIMIT 1
)

SELECT customer_name 
FROM cte;