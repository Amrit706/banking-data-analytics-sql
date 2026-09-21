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