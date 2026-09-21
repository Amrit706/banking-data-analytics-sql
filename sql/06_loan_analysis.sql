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