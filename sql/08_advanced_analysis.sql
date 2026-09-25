-- =============================
-- Advanced SQL Analysis
-- =============================

USE finance_fraud_loans;

-- • Month-over-month transaction growth

WITH cte AS
(
	SELECT *, CONCAT_WS(" " , MONTHNAME(TransactionDate), YEAR(TransactionDate)) AS month_year,
		YEAR(TransactionDate) AS years, MONTH(TransactionDate) AS months
	FROM transactions
),

cte2 AS 
(
	SELECT month_year, years, months, COUNT(TransactionID) AS trans_count
	FROM cte
	GROUP BY month_year, years, months
),

cte3 AS
(
	SELECT month_year , trans_count AS curr_month , 
		LAG(trans_count) OVER(ORDER BY years ASC, months ASC) AS prev_month
	FROM cte2
	WHERE years IS NOT NULL AND months IS NOT NULL
)

SELECT month_year,
	curr_month,
    prev_month,
	ROUND((((curr_month - prev_month) / curr_month) * 100 ),2) AS MoM_growth_rate
FROM cte3;

-- • Running transaction total

WITH cte AS
(
	SELECT *, CONCAT_WS(" " , MONTHNAME(TransactionDate), YEAR(TransactionDate)) AS month_year,
		YEAR(TransactionDate) AS years, MONTH(TransactionDate) AS months
	FROM transactions
),

cte2 AS 
(
	SELECT month_year, years, months, COUNT(TransactionID) AS trans_count
	FROM cte
    WHERE years IS NOT NULL AND months IS NOT NULL
	GROUP BY month_year, years, months
)

SELECT month_year, trans_count AS monthly_transaction,
	SUM(trans_count) OVER(ORDER BY years ASC, months ASC 
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Running_total
FROM cte2;

-- • 3-Month Moving Average

WITH cte AS
(
	SELECT *,
		   CONCAT_WS(" ", MONTHNAME(TransactionDate), YEAR(TransactionDate)) AS month_year,
		   YEAR(TransactionDate) AS years,
		   MONTH(TransactionDate) AS months
	FROM transactions
),

cte2 AS 
(
	SELECT month_year, years, months, COUNT(TransactionID) AS trans_count
	FROM cte
	WHERE years IS NOT NULL AND months IS NOT NULL
	GROUP BY month_year, years, months
)

SELECT 
	month_year,
	trans_count AS monthly_transaction,
	ROUND(AVG(trans_count) OVER(ORDER BY years ASC, months ASC
			ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS three_month_moving_average
FROM cte2
ORDER BY years ASC, months ASC;