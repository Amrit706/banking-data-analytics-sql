-- =====================================================
-- database_schema.sql
-- Structural definition of the banking dataset
-- Source: Kaggle - Synthetic Banking Dataset
-- =====================================================

CREATE TABLE customers (
    CustomerID BIGINT PRIMARY KEY,
    FirstName TEXT,
    LastName TEXT,
    DateOfBirth TEXT,
    AddressID BIGINT,
    CustomerTypeID BIGINT
);

CREATE TABLE accounts (
    AccountID BIGINT PRIMARY KEY,
    CustomerID BIGINT,
    AccountTypeID BIGINT,
    AccountStatusID BIGINT,
    Balance DOUBLE,
    OpeningDate TEXT
);

CREATE TABLE transactions (
    TransactionID BIGINT PRIMARY KEY,
    AccountOriginID BIGINT,
    AccountDestinationID BIGINT,
    TransactionTypeID BIGINT,
    Amount DOUBLE,
    TransactionDate TEXT,
    BranchID BIGINT,
    Description TEXT
);

CREATE TABLE loans (
    LoanID BIGINT PRIMARY KEY,
    AccountID BIGINT,
    LoanStatusID BIGINT,
    PrincipalAmount DOUBLE,
    InterestRate DOUBLE,
    StartDate TEXT,
    EstimatedEndDate TEXT
);

CREATE TABLE branches (
    BranchID BIGINT PRIMARY KEY,
    BranchName TEXT,
    AddressID BIGINT
);

CREATE TABLE addresses (
    AddressID BIGINT PRIMARY KEY,
    Street TEXT,
    City TEXT,
    Country TEXT
);

CREATE TABLE account_types (
    AccountTypeID BIGINT PRIMARY KEY,
    TypeName TEXT
);

CREATE TABLE account_statuses (
    AccountStatusID BIGINT PRIMARY KEY,
    StatusName TEXT
);

CREATE TABLE customer_types (
    CustomerTypeID BIGINT PRIMARY KEY,
    TypeName TEXT
);

CREATE TABLE loan_statuses (
    LoanStatusID BIGINT PRIMARY KEY,
    StatusName TEXT
);

CREATE TABLE transaction_types (
    TransactionTypeID BIGINT PRIMARY KEY,
    TypeName TEXT
);


-- =====================================================
-- Relationships (not enforced via FK constraints in source data)
-- =====================================================
-- accounts.CustomerID          -> customers.CustomerID
-- accounts.AccountTypeID       -> account_types.AccountTypeID
-- accounts.AccountStatusID     -> account_statuses.AccountStatusID
-- transactions.AccountOriginID      -> accounts.AccountID
-- transactions.AccountDestinationID -> accounts.AccountID
-- transactions.TransactionTypeID    -> transaction_types.TransactionTypeID
-- transactions.BranchID             -> branches.BranchID
-- loans.AccountID               -> accounts.AccountID
-- loans.LoanStatusID            -> loan_statuses.LoanStatusID
-- customers.AddressID           -> addresses.AddressID
-- customers.CustomerTypeID      -> customer_types.CustomerTypeID
-- branches.AddressID            -> addresses.AddressID