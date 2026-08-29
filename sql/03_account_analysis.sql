-- ===============================
-- Account Analysis
-- ===============================

USE finance_fraud_loans;

-- • Number of accounts by account type

SELECT t2.TypeName AS type, COUNT(t1.AccountID) AS num_of_acc
FROM accounts AS t1
INNER JOIN account_types AS t2
ON t1.AccountTypeID = t2.AccountTypeID
GROUP BY type
ORDER BY num_of_acc DESC;