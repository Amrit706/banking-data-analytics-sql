-- =====================================================
-- 01_data_quality.sql
-- Section: Schema Discovery & Structural Validation
-- =====================================================

USE finance_fraud_loans;

-- -----------------------------------------------------
-- 1. Confirm database and list all tables
-- -----------------------------------------------------
SHOW TABLES;

-- -----------------------------------------------------
-- 2. Inspect structure of every table
-- -----------------------------------------------------
DESCRIBE customers;
DESCRIBE accounts;
DESCRIBE transactions;
DESCRIBE loans;
DESCRIBE branches;
DESCRIBE addresses;
DESCRIBE account_types;
DESCRIBE account_statuses;
DESCRIBE customer_types;
DESCRIBE loan_statuses;
DESCRIBE transaction_types;

-- -----------------------------------------------------
-- 3. Full column inventory with key flags
-- -----------------------------------------------------
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    COLUMN_KEY
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'finance_fraud_loans'
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- -----------------------------------------------------
-- 4. Extract foreign key relationships
-- -----------------------------------------------------
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'finance_fraud_loans'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, COLUMN_NAME;

-- -----------------------------------------------------
-- 5. Row counts across all tables
-- -----------------------------------------------------
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'accounts', COUNT(*) FROM accounts
UNION ALL
SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL
SELECT 'loans', COUNT(*) FROM loans
UNION ALL
SELECT 'branches', COUNT(*) FROM branches
UNION ALL
SELECT 'addresses', COUNT(*) FROM addresses
UNION ALL
SELECT 'account_types', COUNT(*) FROM account_types
UNION ALL
SELECT 'account_statuses', COUNT(*) FROM account_statuses
UNION ALL
SELECT 'customer_types', COUNT(*) FROM customer_types
UNION ALL
SELECT 'loan_statuses', COUNT(*) FROM loan_statuses
UNION ALL
SELECT 'transaction_types', COUNT(*) FROM transaction_types;


-- =====================================================
-- 6. MISSING VALUES (NULL CHECKS)
-- =====================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(FirstName)       AS null_FirstName,
    COUNT(*) - COUNT(LastName)        AS null_LastName,
    COUNT(*) - COUNT(DateOfBirth)     AS null_DateOfBirth,
    COUNT(*) - COUNT(AddressID)       AS null_AddressID,
    COUNT(*) - COUNT(CustomerTypeID)  AS null_CustomerTypeID
FROM customers;

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(CustomerID)      AS null_CustomerID,
    COUNT(*) - COUNT(AccountTypeID)   AS null_AccountTypeID,
    COUNT(*) - COUNT(AccountStatusID) AS null_AccountStatusID,
    COUNT(*) - COUNT(Balance)         AS null_Balance,
    COUNT(*) - COUNT(OpeningDate)     AS null_OpeningDate
FROM accounts;

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(AccountOriginID)      AS null_AccountOriginID,
    COUNT(*) - COUNT(AccountDestinationID) AS null_AccountDestinationID,
    COUNT(*) - COUNT(TransactionTypeID)    AS null_TransactionTypeID,
    COUNT(*) - COUNT(Amount)               AS null_Amount,
    COUNT(*) - COUNT(TransactionDate)      AS null_TransactionDate,
    COUNT(*) - COUNT(BranchID)             AS null_BranchID
FROM transactions;

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(AccountID)         AS null_AccountID,
    COUNT(*) - COUNT(LoanStatusID)      AS null_LoanStatusID,
    COUNT(*) - COUNT(PrincipalAmount)   AS null_PrincipalAmount,
    COUNT(*) - COUNT(InterestRate)      AS null_InterestRate,
    COUNT(*) - COUNT(StartDate)         AS null_StartDate,
    COUNT(*) - COUNT(EstimatedEndDate)  AS null_EstimatedEndDate
FROM loans;

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(BranchName) AS null_BranchName,
    COUNT(*) - COUNT(AddressID)  AS null_AddressID
FROM branches;

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(Street)  AS null_Street,
    COUNT(*) - COUNT(City)    AS null_City,
    COUNT(*) - COUNT(Country) AS null_Country
FROM addresses;


-- =====================================================
-- 7. DUPLICATE RECORDS
-- =====================================================

-- 7a. Duplicate primary keys (should return 0 rows)
SELECT CustomerID, COUNT(*) FROM customers GROUP BY CustomerID HAVING COUNT(*) > 1;
SELECT AccountID, COUNT(*) FROM accounts GROUP BY AccountID HAVING COUNT(*) > 1;
SELECT TransactionID, COUNT(*) FROM transactions GROUP BY TransactionID HAVING COUNT(*) > 1;
SELECT LoanID, COUNT(*) FROM loans GROUP BY LoanID HAVING COUNT(*) > 1;

-- 7b. Duplicate business-logic rows
SELECT FirstName, LastName, DateOfBirth, AddressID, COUNT(*) AS cnt
FROM customers
GROUP BY FirstName, LastName, DateOfBirth, AddressID
HAVING COUNT(*) > 1;

SELECT AccountOriginID, AccountDestinationID, TransactionTypeID, Amount, TransactionDate, COUNT(*) AS cnt
FROM transactions
GROUP BY AccountOriginID, AccountDestinationID, TransactionTypeID, Amount, TransactionDate
HAVING COUNT(*) > 1;


-- =====================================================
-- 8. INVALID / INCONSISTENT VALUES
-- =====================================================

SELECT * FROM accounts WHERE Balance < 0;
SELECT * FROM transactions WHERE Amount <= 0;
SELECT * FROM transactions WHERE AccountOriginID = AccountDestinationID;
SELECT * FROM loans WHERE PrincipalAmount <= 0;
SELECT * FROM loans WHERE InterestRate < 0;

-- Date columns are stored as TEXT — check they're actually parseable before trusting them
SELECT DateOfBirth FROM customers
WHERE STR_TO_DATE(DateOfBirth, '%Y-%m-%d') IS NULL AND DateOfBirth IS NOT NULL;

SELECT
    SUM(CASE WHEN DateOfBirth = 'NaT' THEN 1 ELSE 0 END) AS count_NaT,
    SUM(CASE WHEN DateOfBirth REGEXP '^[0-9]{2}\\.[0-9]{2}\\.[0-9]{4}$' THEN 1 ELSE 0 END) AS count_dot_format,
    SUM(CASE WHEN DateOfBirth REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$' THEN 1 ELSE 0 END) AS count_slash_ymd,
    SUM(CASE WHEN DateOfBirth REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN 1 ELSE 0 END) AS count_slash_dmy,
    COUNT(*) AS total_customers
FROM customers;

CREATE VIEW customers_cleaned AS
SELECT
    CustomerID,
    FirstName,
    LastName,
    CASE
        WHEN DateOfBirth = 'NaT' THEN NULL
        WHEN DateOfBirth REGEXP '^[0-9]{2}\\.[0-9]{2}\\.[0-9]{4}$' THEN STR_TO_DATE(DateOfBirth, '%d.%m.%Y')
        WHEN DateOfBirth REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$' THEN STR_TO_DATE(DateOfBirth, '%Y/%m/%d')
        WHEN DateOfBirth REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN STR_TO_DATE(DateOfBirth, '%d/%m/%Y')
        ELSE STR_TO_DATE(DateOfBirth, '%Y-%m-%d')
    END AS DateOfBirth_clean,
    AddressID,
    CustomerTypeID
FROM customers;

SELECT TransactionDate FROM transactions
WHERE STR_TO_DATE(TransactionDate, '%Y-%m-%d') IS NULL AND TransactionDate IS NOT NULL;

SELECT OpeningDate FROM accounts
WHERE STR_TO_DATE(OpeningDate, '%Y-%m-%d') IS NULL AND OpeningDate IS NOT NULL;

SELECT StartDate FROM loans
WHERE STR_TO_DATE(StartDate, '%Y-%m-%d') IS NULL AND StartDate IS NOT NULL;

-- NOTE: if any of the 4 checks above return rows, the format mask '%Y-%m-%d' is wrong for
-- this data — tell me what the raw text looks like and I'll correct the mask before Step 9.


-- =====================================================
-- 9. DATE RANGE CHECKS
-- =====================================================

SELECT MIN(STR_TO_DATE(DateOfBirth, '%Y-%m-%d')) AS earliest_dob,
       MAX(STR_TO_DATE(DateOfBirth, '%Y-%m-%d')) AS latest_dob
FROM customers;

SELECT MIN(STR_TO_DATE(OpeningDate, '%Y-%m-%d')) AS earliest_account_opened,
       MAX(STR_TO_DATE(OpeningDate, '%Y-%m-%d')) AS latest_account_opened
FROM accounts;

SELECT MIN(STR_TO_DATE(TransactionDate, '%Y-%m-%d')) AS earliest_txn,
       MAX(STR_TO_DATE(TransactionDate, '%Y-%m-%d')) AS latest_txn
FROM transactions;

SELECT MIN(STR_TO_DATE(StartDate, '%Y-%m-%d')) AS earliest_loan_start,
       MAX(STR_TO_DATE(StartDate, '%Y-%m-%d')) AS latest_loan_start
FROM loans;

SELECT * FROM customers WHERE STR_TO_DATE(DateOfBirth, '%Y-%m-%d') > CURDATE();
SELECT * FROM transactions WHERE STR_TO_DATE(TransactionDate, '%Y-%m-%d') > CURDATE();
SELECT * FROM accounts WHERE STR_TO_DATE(OpeningDate, '%Y-%m-%d') > CURDATE();


-- =====================================================
-- 10. CATEGORICAL VALIDATION + REFERENTIAL INTEGRITY
-- =====================================================

-- 10a. Confirm every foreign-key ID used actually exists in its lookup table
SELECT DISTINCT a.AccountTypeID
FROM accounts a LEFT JOIN account_types t ON a.AccountTypeID = t.AccountTypeID
WHERE t.AccountTypeID IS NULL;

SELECT DISTINCT a.AccountStatusID
FROM accounts a LEFT JOIN account_statuses s ON a.AccountStatusID = s.AccountStatusID
WHERE s.AccountStatusID IS NULL;

SELECT DISTINCT c.CustomerTypeID
FROM customers c LEFT JOIN customer_types ct ON c.CustomerTypeID = ct.CustomerTypeID
WHERE ct.CustomerTypeID IS NULL;

SELECT DISTINCT l.LoanStatusID
FROM loans l LEFT JOIN loan_statuses ls ON l.LoanStatusID = ls.LoanStatusID
WHERE ls.LoanStatusID IS NULL;

SELECT DISTINCT t.TransactionTypeID
FROM transactions t LEFT JOIN transaction_types tt ON t.TransactionTypeID = tt.TransactionTypeID
WHERE tt.TransactionTypeID IS NULL;

-- 10b. Actual distribution of each category (also a preview of later analysis)
SELECT tt.TypeName, COUNT(*) AS txn_count
FROM transactions t JOIN transaction_types tt ON t.TransactionTypeID = tt.TransactionTypeID
GROUP BY tt.TypeName;

SELECT s.StatusName, COUNT(*) AS account_count
FROM accounts a JOIN account_statuses s ON a.AccountStatusID = s.AccountStatusID
GROUP BY s.StatusName;

SELECT ls.StatusName, COUNT(*) AS loan_count
FROM loans l JOIN loan_statuses ls ON l.LoanStatusID = ls.LoanStatusID
GROUP BY ls.StatusName;

-- 10c. Orphan / referential integrity checks across every FK relationship
SELECT t.TransactionID, t.AccountOriginID
FROM transactions t LEFT JOIN accounts a ON t.AccountOriginID = a.AccountID
WHERE a.AccountID IS NULL;

SELECT t.TransactionID, t.AccountDestinationID
FROM transactions t LEFT JOIN accounts a ON t.AccountDestinationID = a.AccountID
WHERE a.AccountID IS NULL;

SELECT t.TransactionID, t.BranchID
FROM transactions t LEFT JOIN branches b ON t.BranchID = b.BranchID
WHERE b.BranchID IS NULL;

SELECT a.AccountID, a.CustomerID
FROM accounts a LEFT JOIN customers c ON a.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;

SELECT l.LoanID, l.AccountID
FROM loans l LEFT JOIN accounts a ON l.AccountID = a.AccountID
WHERE a.AccountID IS NULL;

SELECT c.CustomerID, c.AddressID
FROM customers c LEFT JOIN addresses ad ON c.AddressID = ad.AddressID
WHERE ad.AddressID IS NULL;

SELECT b.BranchID, b.AddressID
FROM branches b LEFT JOIN addresses ad ON b.AddressID = ad.AddressID
WHERE ad.AddressID IS NULL;

