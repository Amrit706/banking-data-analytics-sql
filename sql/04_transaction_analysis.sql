-- ===============================
-- Transaction Analysis
-- ===============================

-- Analyze transaction behavior across customers and accounts.

USE finance_fraud_loans;

-- • What is the total transaction volume?

SELECT COUNT(*) AS total_transactions_counts
FROM transactions;