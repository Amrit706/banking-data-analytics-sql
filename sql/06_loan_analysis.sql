-- =======================
-- Loan Analysis
-- =======================

USE finance_fraud_loans;

-- • Number of loans

SELECT t2.StatusName AS loan_status, COUNT(t1.LoanID) AS counts
FROM loans AS t1
INNER JOIN loan_statuses AS t2
	ON t1.LoanStatusID = t2.LoanStatusID
GROUP BY loan_status
ORDER BY counts DESC;

-- • Calculate the total estimated loan amount (Principal + Simple Interest) for each loan status
-- We will calculate here Simple Interest
-- Amount = PrincipalAmount + SI

WITH cte AS
(
	SELECT t2.StatusName AS loan_status, t1.PrincipalAmount, t1.InterestRate, 
		DATE(t1.StartDate) AS start_date ,
        CASE WHEN DATE(t1.EstimatedEndDate) > CURRENT_DATE() THEN CURRENT_DATE()
			WHEN DATE(t1.EstimatedEndDate) < CURRENT_DATE() THEN DATE(t1.EstimatedEndDate)
		END AS end_date
	FROM loans AS t1
	INNER JOIN loan_statuses AS t2
		ON t1.LoanStatusID = t2.LoanStatusID
),

cte2 AS
(
	SELECT loan_status, PrincipalAmount, InterestRate, (YEAR(end_date) - YEAR(start_date)) AS duration
	FROM cte
)

SELECT loan_status, ROUND(SUM((PrincipalAmount + ((PrincipalAmount * InterestRate * duration) / 100) )),2) AS total_amount
FROM cte2
GROUP BY loan_status;

-- • Total loan amount

SELECT 
    t2.StatusName AS loan_status,
    ROUND(SUM(t1.PrincipalAmount), 2) AS total_loan_amount
FROM loans AS t1
INNER JOIN loan_statuses AS t2
    ON t1.LoanStatusID = t2.LoanStatusID
GROUP BY t2.StatusName;

-- • Average loan amount

SELECT 
    t2.StatusName AS loan_status,
    ROUND(AVG(t1.PrincipalAmount), 2) AS avg_loan_amount
FROM loans AS t1
INNER JOIN loan_statuses AS t2
    ON t1.LoanStatusID = t2.LoanStatusID
GROUP BY t2.StatusName;

-- • Loan distribution by loan status

SELECT 
    t2.StatusName AS loan_status,
    COUNT(*) AS loan_counts
FROM loans AS t1
INNER JOIN loan_statuses AS t2
    ON t1.LoanStatusID = t2.LoanStatusID
GROUP BY t2.StatusName;

-- • Loan distribution by branch

SELECT 
    COALESCE(t5.BranchName, 'Unmapped') AS branch,
    t2.StatusName AS loan_status,
    COUNT(DISTINCT t1.LoanID) AS loan_counts
FROM loans AS t1
INNER JOIN loan_statuses AS t2
    ON t1.LoanStatusID = t2.LoanStatusID
LEFT JOIN accounts AS t3
    ON t1.AccountID = t3.AccountID
LEFT JOIN customers_cleaned AS t4
    ON t3.CustomerID = t4.CustomerID
LEFT JOIN branches AS t5
    ON t4.AddressID = t5.AddressID
GROUP BY branch, loan_status;

-- • Customers with multiple loans

SELECT t1.CustomerID, CONCAT_WS(" ", t1.FirstName, t1.LastName) AS customer_name, COUNT(DISTINCT t3.LoanID) AS loan_counts
FROM customers_cleaned AS t1
INNER JOIN accounts AS t2
	ON t1.CustomerID = t2.CustomerID
INNER JOIN loans AS t3
	ON t2.AccountID = t3.AccountID
GROUP BY t1.CustomerID, customer_name
HAVING loan_counts > 1
ORDER BY loan_counts DESC;

-- • Customers with the highest total loan amounts

SELECT t1.CustomerID, CONCAT_WS(" ", t1.FirstName, t1.LastName) AS customer_name, 
	ROUND(SUM(t3.PrincipalAmount),2) AS total_loan_amount
FROM customers_cleaned AS t1
INNER JOIN accounts AS t2
	ON t1.CustomerID = t2.CustomerID
INNER JOIN loans AS t3
	ON t2.AccountID = t3.AccountID
GROUP BY t1.CustomerID, customer_name
ORDER BY total_loan_amount DESC LIMIT 1;

-- • Average loan amount by customer segment

-- High value customers

WITH cte AS
(
	SELECT t1.CustomerID, CONCAT_WS(" ",t1.FirstName, t1.LastName) AS customer_name, t2.Balance
	FROM customers_cleaned AS t1
	INNER JOIN accounts AS t2
		ON t1.CustomerID = t2.CustomerID
	INNER JOIN account_statuses AS t3
		ON t2.AccountStatusID = t3.AccountStatusID
	WHERE t3.StatusName = "Active"
),

cte2 AS 
(
	SELECT CustomerID, customer_name, ROUND(SUM(Balance),2) AS total_balance
	FROM cte
	GROUP BY CustomerID, customer_name
	ORDER BY total_balance DESC
),

cte3 AS
(
	SELECT t.CustomerID, t.customer_name, t.total_balance
	FROM (SELECT CustomerID, customer_name, total_balance,
			ROUND(((COUNT(*) OVER() ) * 0.2)) AS top_20_percent,
			ROW_NUMBER() OVER(ORDER BY total_balance DESC) AS rnk
		  FROM cte2) AS t
	WHERE t.rnk <= t.top_20_percent
),

cte4 AS
(
	SELECT t1.CustomerID, CONCAT_WS(" ", t1.FirstName, t1.LastName) AS customer_name, t3.TransactionID
	FROM customers_cleaned AS t1
	INNER JOIN accounts AS t2
		ON t1.CustomerID = t2.CustomerID
	INNER JOIN transactions AS t3
		ON t2.AccountID = t3.AccountOriginID
	UNION
	SELECT t1.CustomerID, CONCAT_WS(" ", t1.FirstName, t1.LastName) AS customer_name, t3.TransactionID
	FROM customers_cleaned AS t1
	INNER JOIN accounts AS t2
		ON t1.CustomerID = t2.CustomerID
	INNER JOIN transactions AS t3
		ON t2.AccountID = t3.AccountDestinationID
),

cte5 AS
(
	SELECT CustomerID, customer_name, COUNT(TransactionID) AS trans_counts,
		ROUND((COUNT(*) OVER() * 0.2)) AS top_20_percent,
        ROW_NUMBER() OVER(ORDER BY COUNT(TransactionID) DESC) AS rnk
	FROM cte4
	GROUP BY CustomerID, customer_name
),

cte6 AS
(
	SELECT CustomerID, customer_name, trans_counts
	FROM cte5
	WHERE rnk <= top_20_percent
)

SELECT 
    'High-Value' AS customer_segment,
    ROUND(AVG(t3.PrincipalAmount), 2) AS avg_loan_amount
FROM cte3 AS t1
INNER JOIN cte6 AS t2
    ON t1.CustomerID = t2.CustomerID
INNER JOIN accounts AS t4
    ON t1.CustomerID = t4.CustomerID
INNER JOIN loans AS t3
    ON t4.AccountID = t3.AccountID;

-- • Average loan amount by customer segment
-- High-Frequency Customers

WITH cte AS
(
	SELECT t1.CustomerID, 
		   CONCAT_WS(" ", t1.FirstName, t1.LastName) AS customer_name, 
           t3.TransactionID
	FROM customers_cleaned AS t1
	INNER JOIN accounts AS t2
		ON t1.CustomerID = t2.CustomerID
	INNER JOIN transactions AS t3
		ON t2.AccountID = t3.AccountOriginID
	
	UNION
	
	SELECT t1.CustomerID, 
		   CONCAT_WS(" ", t1.FirstName, t1.LastName) AS customer_name, 
           t3.TransactionID
	FROM customers_cleaned AS t1
	INNER JOIN accounts AS t2
		ON t1.CustomerID = t2.CustomerID
	INNER JOIN transactions AS t3
		ON t2.AccountID = t3.AccountDestinationID
),

cte2 AS
(
	SELECT CustomerID, 
		   customer_name, 
           COUNT(TransactionID) AS trans_counts,
           ROUND((COUNT(*) OVER() * 0.2)) AS top_20_percent,
           DENSE_RANK() OVER(ORDER BY COUNT(TransactionID) DESC) AS rnk
	FROM cte
	GROUP BY CustomerID, customer_name
),

cte3 AS
(
	SELECT CustomerID, 
		   customer_name, 
           trans_counts
	FROM cte2
	WHERE rnk <= top_20_percent
)

SELECT 
	'High-Frequency' AS customer_segment,
    ROUND(AVG(t3.PrincipalAmount), 2) AS avg_loan_amount
FROM cte3 AS t1
INNER JOIN accounts AS t2
	ON t1.CustomerID = t2.CustomerID
INNER JOIN loans AS t3
	ON t2.AccountID = t3.AccountID;

-- • Average loan amount by customer segment
-- Dormant Customers

WITH cte AS
(
    SELECT 
        t1.CustomerID,
        t1.AccountID,
        MAX(t2.TransactionDate) AS latest_trans
    FROM accounts AS t1
    LEFT JOIN transactions AS t2
        ON t1.AccountID = t2.AccountOriginID
    INNER JOIN account_statuses AS t3
        ON t1.AccountStatusID = t3.AccountStatusID
    WHERE t3.StatusName = 'Active'
    GROUP BY t1.CustomerID, t1.AccountID

    UNION ALL

    SELECT 
        t1.CustomerID,
        t1.AccountID,
        MAX(t2.TransactionDate) AS latest_trans
    FROM accounts AS t1
    LEFT JOIN transactions AS t2
        ON t1.AccountID = t2.AccountDestinationID
    INNER JOIN account_statuses AS t3
        ON t1.AccountStatusID = t3.AccountStatusID
    WHERE t3.StatusName = 'Active'
    GROUP BY t1.CustomerID, t1.AccountID
),

latest_activity AS
(
    SELECT 
        CustomerID,
        MAX(latest_trans) AS latest_trans_date
    FROM cte
    GROUP BY CustomerID
),

latest_dataset_date AS
(
    SELECT MAX(TransactionDate) AS max_transaction_date
    FROM transactions
),

dormant_customers AS
(
    SELECT 
        t1.CustomerID,
        t1.latest_trans_date,
        'Dormant' AS customer_category
    FROM latest_activity AS t1
    CROSS JOIN latest_dataset_date AS t2
    WHERE t1.latest_trans_date < DATE_SUB(t2.max_transaction_date, INTERVAL 12 MONTH)
       OR t1.latest_trans_date IS NULL
)

SELECT 
    'Dormant' AS customer_segment,
    ROUND(AVG(t3.PrincipalAmount), 2) AS avg_loan_amount
FROM dormant_customers AS t1
INNER JOIN accounts AS t2
    ON t1.CustomerID = t2.CustomerID
INNER JOIN loans AS t3
    ON t2.AccountID = t3.AccountID;
    
-- • Relationship between customer account balance and loan amount

WITH cte AS
(
	SELECT t1.CustomerID, CONCAT_WS(" ",t1.FirstName, t1.LastName) AS customer_name, ROUND(SUM(t2.Balance),2) AS total_account_balance
	FROM customers_cleaned AS t1
	INNER JOIN accounts AS t2
	ON t1.CustomerID = t2.CustomerID
	GROUP BY CustomerID, customer_name
),

cte2 AS
(
	SELECT t1.CustomerID, CONCAT_WS(" ", t1.FirstName, t1.LastName) AS customer_name, 
		ROUND(SUM(t3.PrincipalAmount),2) AS total_loan_amount
	FROM customers_cleaned AS t1
	INNER JOIN accounts AS t2
		ON t1.CustomerID = t2.CustomerID
	INNER JOIN loans AS t3
		ON t2.AccountID = t3.AccountID
	GROUP BY t1.CustomerID, customer_name
),

cte3 AS
(
	SELECT t1.CustomerID, t1.total_account_balance, t2.total_loan_amount
	FROM cte AS t1
	JOIN cte2 AS t2
		ON t1.CustomerID = t2.CustomerID
)

SELECT t1.CustomerID, t1.total_account_balance, t2.total_loan_amount
FROM cte AS t1
JOIN cte2 AS t2
	ON t1.CustomerID = t2.CustomerID;

-- Loan-to-balance ratio
WITH cte AS
(
	SELECT t1.CustomerID, CONCAT_WS(" ",t1.FirstName, t1.LastName) AS customer_name, ROUND(SUM(t2.Balance),2) AS total_account_balance
	FROM customers_cleaned AS t1
	INNER JOIN accounts AS t2
	ON t1.CustomerID = t2.CustomerID
	GROUP BY CustomerID, customer_name
),

cte2 AS
(
	SELECT t1.CustomerID, CONCAT_WS(" ", t1.FirstName, t1.LastName) AS customer_name, 
		ROUND(SUM(t3.PrincipalAmount),2) AS total_loan_amount
	FROM customers_cleaned AS t1
	INNER JOIN accounts AS t2
		ON t1.CustomerID = t2.CustomerID
	INNER JOIN loans AS t3
		ON t2.AccountID = t3.AccountID
	GROUP BY t1.CustomerID, customer_name
),

cte3 AS
(
	SELECT t1.CustomerID, t1.total_account_balance, t2.total_loan_amount
	FROM cte AS t1
	JOIN cte2 AS t2
		ON t1.CustomerID = t2.CustomerID
)

SELECT CustomerID, ROUND((total_loan_amount / total_account_balance),3) AS loan_to_amount_ratio
FROM cte3
ORDER BY loan_to_amount_ratio;

-- • Loan status patterns across loan amounts

WITH cte AS
(
	SELECT 
		t1.LoanID,
		t1.PrincipalAmount,
		t2.StatusName AS loan_status,
		NTILE(3) OVER (ORDER BY t1.PrincipalAmount) AS loan_group
	FROM loans AS t1
	INNER JOIN loan_statuses AS t2
		ON t1.LoanStatusID = t2.LoanStatusID
),

cte2 AS
(
	SELECT 
		LoanID,
		PrincipalAmount,
		loan_status,
		CASE
			WHEN loan_group = 1 THEN 'Low Loan Amount'
			WHEN loan_group = 2 THEN 'Medium Loan Amount'
			WHEN loan_group = 3 THEN 'High Loan Amount'
		END AS loan_amount_segment
	FROM cte
)

SELECT
	loan_amount_segment,
	loan_status,
	COUNT(DISTINCT LoanID) AS loan_count,
	ROUND(
		COUNT(DISTINCT LoanID) * 100.0 /
		SUM(COUNT(DISTINCT LoanID)) OVER
			(PARTITION BY loan_amount_segment),
		2
	) AS status_percentage
FROM cte2
GROUP BY loan_amount_segment, loan_status
ORDER BY
	CASE
		WHEN loan_amount_segment = 'Low Loan Amount' THEN 1
		WHEN loan_amount_segment = 'Medium Loan Amount' THEN 2
		WHEN loan_amount_segment = 'High Loan Amount' THEN 3
	END,
	loan_status;