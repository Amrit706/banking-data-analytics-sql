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