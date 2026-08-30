-- ===============================
-- Account Analysis
-- ===============================

USE finance_fraud_loans;

-- • Number of accounts by account type

-- overall 

SELECT t2.TypeName AS type, COUNT(t1.AccountID) AS num_of_acc
FROM accounts AS t1
INNER JOIN account_types AS t2
ON t1.AccountTypeID = t2.AccountTypeID
GROUP BY type
ORDER BY num_of_acc DESC;

-- active accounts

SELECT t3.TypeName AS type, COUNT(t1.AccountID) AS num_of_acc
FROM accounts AS t1
INNER JOIN account_statuses AS t2
ON t1.AccountStatusID = t2.AccountStatusID
INNER JOIN account_types AS t3
ON t1.AccountTypeID = t3.AccountTypeID
WHERE t2.StatusName = 'Active'
GROUP BY type
ORDER BY num_of_acc DESC;

-- • Total balance by account type (Active accounts)

SELECT t3.TypeName AS type, ROUND(SUM(t1.Balance),2) AS total_balance
FROM accounts AS t1
INNER JOIN account_statuses AS t2
ON t1.AccountStatusID = t2.AccountStatusID
INNER JOIN account_types AS t3
ON t1.AccountTypeID = t3.AccountTypeID
WHERE t2.StatusName = 'Active'
GROUP BY type
ORDER BY total_balance DESC;

-- • Average balance by account type

SELECT t3.TypeName AS type, ROUND(AVG(t1.Balance),2) AS avg_balance
FROM accounts AS t1
INNER JOIN account_statuses AS t2
ON t1.AccountStatusID = t2.AccountStatusID
INNER JOIN account_types AS t3
ON t1.AccountTypeID = t3.AccountTypeID
WHERE t2.StatusName = 'Active'
GROUP BY type
ORDER BY avg_balance DESC;

-- • Branch-wise account distribution

WITH cte AS
(
	SELECT t3.BranchID, t3.BranchName, t1.AccountStatusID, COUNT(t1.AccountID) AS account_cnt
	FROM accounts AS t1
	INNER JOIN customers_cleaned AS t2
	ON t1.CustomerID = t2.CustomerID
	INNER JOIN branches AS t3
	ON t2.AddressID = t3.AddressID
	GROUP BY t3.BranchID, t3.BranchName, t1.AccountStatusID
	ORDER BY account_cnt DESC
)

SELECT t1.BranchName, t2.StatusName, t1.account_cnt
FROM cte AS t1
INNER JOIN account_statuses AS t2
ON t1.AccountStatusID = t2.AccountStatusID;

-- • Customers with multiple accounts (active, inactive, closed)

SELECT t1.CustomerID, CONCAT_WS(" ", t1.FirstName, t1.LastName) AS customer_name, 
		t3.StatusName AS account_status, COUNT(t2.AccountID) AS account_cnt
FROM customers_cleaned AS t1
INNER JOIN accounts AS t2
	ON t1.CustomerID = t2.CustomerID
INNER JOIN account_statuses AS t3
	ON t2.AccountStatusID = t3.AccountStatusID
GROUP BY t1.CustomerID, customer_name, account_status
	HAVING account_cnt > 1
ORDER BY account_cnt DESC;

-- • Accounts with unusually high or low balances

WITH ordered_balances AS (
    SELECT
        AccountID,
        Balance,
        ROW_NUMBER() OVER (ORDER BY Balance) AS rn,
        COUNT(*) OVER () AS total_rows
    FROM accounts
),

quartiles AS (
    SELECT
        MAX(CASE 
            WHEN rn = CEIL(total_rows * 0.25) 
            THEN Balance 
        END) AS Q1,
        
        MAX(CASE 
            WHEN rn = CEIL(total_rows * 0.75) 
            THEN Balance 
        END) AS Q3
    FROM ordered_balances
),

iqr_bounds AS (
    SELECT
        Q1,
        Q3,
        (Q3 - Q1) AS IQR,
        Q1 - 1.5 * (Q3 - Q1) AS lower_bound,
        Q3 + 1.5 * (Q3 - Q1) AS upper_bound
    FROM quartiles
)

SELECT t1.AccountID, t1.Balance,
	CASE WHEN t1.Balance < t2.lower_bound THEN 'unusually_low'
		WHEN t1.Balance > t2.upper_bound THEN 'unusually_high'
        END AS balance_category
FROM ordered_balances AS t1
CROSS JOIN iqr_bounds AS t2
WHERE t1.Balance < t2.lower_bound 
	OR t1.Balance > t2.upper_bound
ORDER BY t1.Balance;

-- Conclusion : Using the IQR method, no account balances were identified as unusually high or low.