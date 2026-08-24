-- ===============================
-- Customer Analysis
-- ===============================
USE finance_fraud_loans;

-- • How many unique customers does the bank have?

SELECT COUNT(DISTINCT customerID) AS unique_customer_count
FROM customers_cleaned;