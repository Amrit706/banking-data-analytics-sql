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