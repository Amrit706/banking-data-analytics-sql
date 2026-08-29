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

