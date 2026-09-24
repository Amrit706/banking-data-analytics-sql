-- ================================================
-- Branch Performance Analysis
-- ================================================

USE finance_fraud_loans;

-- 1. Branch customer/account/balance overview

-- • Number of customers
-- • Number of accounts
-- • Total account balance
-- • Average customer balance

WITH customer_branch_balance AS
(
    SELECT 
        t1.CustomerID,
        CASE 
            WHEN t2.BranchID IS NULL THEN 'Unmarked'
            ELSE CAST(t2.BranchID AS CHAR)
        END AS branch,
        COUNT(t3.AccountID) AS account_counts,
        ROUND(SUM(t3.Balance), 2) AS customer_balance
    FROM customers_cleaned AS t1
    LEFT JOIN branches AS t2
        ON t1.AddressID = t2.AddressID
    INNER JOIN accounts AS t3
        ON t1.CustomerID = t3.CustomerID
    GROUP BY 
        t1.CustomerID,
        branch
)

SELECT 
    branch,
    COUNT(CustomerID) AS customer_counts,
    SUM(account_counts) AS account_counts,
    ROUND(SUM(customer_balance), 2) AS total_account_balance,
    ROUND(AVG(customer_balance), 2) AS average_customer_balance
FROM customer_branch_balance
GROUP BY branch
ORDER BY branch;

-- 2. Branch transaction performance
-- • Transaction volume
-- • Transaction value
-- • Average transaction value

SELECT 
    BranchID AS branch,
    COUNT(TransactionID) AS transaction_volume,
    ROUND(SUM(Amount), 2) AS transaction_value,
    ROUND(AVG(Amount), 2) AS average_transaction_value
FROM transactions
GROUP BY BranchID
ORDER BY transaction_value DESC;