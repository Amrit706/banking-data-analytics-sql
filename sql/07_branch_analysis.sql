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

-- 3. Rank branches based on multiple performance indicators
-- • Total account balance
-- • Transaction volume

WITH branch_balance AS
(
	SELECT 
		CASE WHEN t2.BranchID IS NULL THEN 'Unmarked'
		ELSE CAST(t2.BranchID AS CHAR)
		END AS branch,
		ROUND(SUM(t3.Balance), 2) AS total_account_balance
	FROM customers_cleaned AS t1
	LEFT JOIN branches AS t2
		ON t1.AddressID = t2.AddressID
	INNER JOIN accounts AS t3
		ON t1.CustomerID = t3.CustomerID
	GROUP BY branch
),

branch_transactions AS
(
	SELECT 
		CAST(BranchID AS CHAR) AS branch,
		COUNT(TransactionID) AS transaction_volume
	FROM transactions
	WHERE BranchID IS NOT NULL
	GROUP BY BranchID
),

branch_ranking AS
(
	SELECT
		t1.branch,
		t1.total_account_balance,
		COALESCE(t2.transaction_volume, 0) AS transaction_volume,
		DENSE_RANK() OVER(ORDER BY t1.total_account_balance DESC) AS balance_rank,
		DENSE_RANK() OVER(ORDER BY COALESCE(t2.transaction_volume, 0) DESC) AS transaction_rank
	FROM branch_balance AS t1
	LEFT JOIN branch_transactions AS t2
		ON t1.branch = t2.branch
)

SELECT
	branch,
	total_account_balance,
	transaction_volume,
	balance_rank,
	transaction_rank,
	(balance_rank + transaction_rank) AS combined_rank
FROM branch_ranking
ORDER BY combined_rank;

-- 4. Branches with high customer count but low transaction activity

WITH branch_customers AS
(
	SELECT 
		CAST(t2.BranchID AS CHAR) AS branch,
		COUNT(DISTINCT t1.CustomerID) AS customer_counts
	FROM customers_cleaned AS t1
	INNER JOIN branches AS t2
		ON t1.AddressID = t2.AddressID
	GROUP BY t2.BranchID
),

branch_transactions AS
(
	SELECT
		CAST(BranchID AS CHAR) AS branch,
		COUNT(TransactionID) AS transaction_volume
	FROM transactions
	WHERE BranchID IS NOT NULL
	GROUP BY BranchID
),

branch_metrics AS
(
	SELECT
		t1.branch,
		t1.customer_counts,
		COALESCE(t2.transaction_volume, 0) AS transaction_volume
	FROM branch_customers AS t1
	LEFT JOIN branch_transactions AS t2
		ON t1.branch = t2.branch
),

branch_average AS
(
	SELECT
		AVG(customer_counts) AS avg_customers,
		AVG(transaction_volume) AS avg_transactions
	FROM branch_metrics
)

SELECT
	t1.branch,
	t1.customer_counts,
	t1.transaction_volume
FROM branch_metrics AS t1
CROSS JOIN branch_average AS t2
WHERE t1.customer_counts > t2.avg_customers
  AND t1.transaction_volume < t2.avg_transactions
ORDER BY t1.customer_counts DESC;