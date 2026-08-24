-- ===============================
-- Customer Analysis
-- ===============================
USE finance_fraud_loans;

-- • How many unique customers does the bank have?

SELECT COUNT(DISTINCT customerID) AS unique_customer_count
FROM customers_cleaned;

-- • How are customers distributed by age (derived from DateOfBirth), customer type, and location (using the Addresses table)?

-- Distribution of customers by age

SELECT CASE WHEN DateOfBirth_clean IS NULL THEN 'Unknown'
		ELSE CAST(TIMESTAMPDIFF(YEAR, DateOfBirth_clean, CURDATE()) AS CHAR) 
        END AS age,
COUNT(customerID) AS customer_count
FROM customers_cleaned
GROUP BY age
ORDER BY age ASC;

-- NOTE - here age = 0 , showing that the age is less than a year.

-- Distribution of customers by customer type

SELECT t2.TypeName AS customer_type, COUNT(t1.customerID) AS customer_count
FROM customers_cleaned AS t1
JOIN customer_types AS t2
ON t1.CustomerTypeID = t2.CustomerTypeID
GROUP BY customer_type
ORDER BY customer_count;

-- Distribution of customers by locations

SELECT t2.Country, t2.City, COUNT(t1.customerID) AS customer_count
FROM customers_cleaned AS t1
JOIN addresses AS t2
ON t1.AddressID = t2.AddressID
GROUP BY t2.Country, t2.City;