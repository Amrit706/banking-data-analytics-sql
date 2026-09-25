-- ================================================
-- Business Insights & Recommendations
-- ================================================

USE finance_fraud_loans;


-- =================================================
-- 1. Customer Analysis
-- =================================================

-- Finding:
-- The customer analysis examines the bank's customer base by age,
-- customer type, location, account ownership, transaction activity,
-- and engagement level.

-- Business Meaning:
-- Understanding the composition and behaviour of the customer base
-- helps the bank identify dominant customer groups and differences
-- in engagement across customers.

-- Potential Action:
-- Use customer demographic and behavioural patterns to support
-- targeted product positioning, customer engagement, and retention
-- strategies.


-- =================================================
-- 2. Account Analysis
-- =================================================

-- Finding:
-- The account analysis compares account types, balances, branch
-- distribution, multiple-account ownership, and account activity.
-- The IQR-based outlier analysis found no account balances that were
-- unusually high or unusually low.
-- Dormant and inactive accounts were also identified using transaction
-- recency and account status.

-- Business Meaning:
-- The absence of IQR-based balance outliers suggests that account
-- balances are not dominated by a small number of extreme observations.
-- Dormant and inactive accounts indicate customer relationships with
-- limited recent activity.

-- Potential Action:
-- Consider targeted re-engagement of dormant customers and review
-- account-level activity patterns to improve customer engagement.


-- =================================================
-- 3. Transaction Analysis
-- =================================================

-- Finding:
-- The transaction table contains 50,000 transaction records.
-- Transaction dates range from 2020-01-01 to 2026-08-28, with
-- 1,000 records having NULL TransactionDate values.
-- Transaction analysis also examines total transaction value,
-- average transaction value, transaction types, monthly trends,
-- branch activity, and customer transaction activity.

-- Business Meaning:
-- The presence of 1,000 transactions without transaction dates limits
-- their use in time-based analyses such as monthly trends and date-based
-- activity analysis. The transaction-level analysis provides a basis
-- for understanding customer and branch activity patterns.

-- Potential Action:
-- Preserve the undated transactions for overall volume/value analysis,
-- but exclude or separately report them in time-based analyses until
-- their dates can be validated.


-- =================================================
-- 4. Customer Segmentation
-- =================================================

-- High-Value Customers

-- Finding:
-- High-Value customers were defined as customers belonging to the
-- top 20% by active-account balance and the top 20% by transaction
-- frequency.

-- Business Meaning:
-- This segment represents customers with both relatively high balances
-- and strong transaction engagement.

-- Potential Action:
-- Consider targeted retention, relationship-management, and
-- cross-selling strategies for this customer group.


-- High-Frequency Customers

-- Finding:
-- High-Frequency customers were identified using transaction frequency
-- and selected from the top 20% of customers by transaction count.

-- Business Meaning:
-- This segment represents customers with comparatively strong
-- transaction engagement.

-- Potential Action:
-- Analyse their product usage and consider targeted engagement and
-- cross-selling opportunities.


-- Dormant Customers

-- Finding:
-- Dormant customers were identified as customers whose active accounts
-- had no transaction activity within the 12 months preceding the latest
-- transaction date in the dataset, or had no recorded transaction activity.

-- Business Meaning:
-- These customers show limited recent engagement with their active
-- banking relationships.

-- Potential Action:
-- Consider re-engagement campaigns and investigate whether dormancy
-- is concentrated by account type, branch, or customer characteristics.


-- =================================================
-- 5. Loan Analysis
-- =================================================

-- Finding:
-- The loan portfolio contains 333 loan records.
-- Loan analysis covers principal loan amount, loan status, multiple-loan
-- customers, customer segments, customer account balance versus loan
-- amount, and loan-status patterns across loan-size segments.

-- Business Meaning:
-- Analysing loan size and status together helps the bank understand
-- lending exposure and identify customer or loan groups that may merit
-- closer monitoring.

-- Potential Action:
-- Use observed loan-status and customer-behaviour patterns to support
-- portfolio monitoring and targeted review.


-- =================================================
-- 6. Branch Performance
-- =================================================

-- Finding:
-- Branch performance was evaluated using customer count, account count,
-- account balance, transaction volume, transaction value, average
-- customer balance, and average transaction value.
-- Branches were also compared using multiple performance indicators.

-- Business Meaning:
-- Comparing branches across several indicators provides a broader view
-- of customer activity, deposit balances, and transaction behaviour than
-- relying on a single metric.

-- Potential Action:
-- Investigate branches where customer volume, account balances, and
-- transaction activity show substantially different patterns, and
-- identify operational or engagement factors that may explain those
-- differences.

-- NOTE:
-- Loan-to-branch mapping has incomplete coverage through the available
-- customer-address relationship. Unmapped loan records are therefore
-- retained rather than being excluded from the analysis.


-- =================================================
-- 7. Advanced / Anomaly Analysis
-- =================================================

-- Finding:
-- Advanced analysis examined month-over-month transaction growth,
-- running transaction totals, a 3-month moving average, and branch
-- contribution to transaction volume.
--
-- The anomaly analysis flags:
-- 1. The top 5% of transactions by Amount.
-- 2. Transactions occurring within 5 minutes of the previous transaction
--    for the same account.
-- 3. Customers whose monthly transaction value increased by at least
--    100% compared with their previous observed month.

-- Business Meaning:
-- These analyses identify transaction and behavioural patterns that
-- differ from normal observed activity. Such patterns can help narrow
-- the population requiring further investigation.

-- Potential Action:
-- Route flagged transactions or customer behaviours for additional
-- review using appropriate fraud/risk procedures instead of treating
-- every flagged observation as confirmed fraud.


-- =================================================
-- Final Business Recommendations
-- =================================================

-- 1. Customer Retention
-- Focus retention efforts on customers with high balances and strong
-- transaction engagement.

-- 2. Customer Engagement
-- Develop targeted engagement strategies for high-frequency customers.

-- 3. Dormant Customer Activation
-- Review dormant customer relationships and consider re-engagement
-- initiatives to restore recent activity.

-- 4. Loan Portfolio Monitoring
-- Monitor loan-status patterns across different loan-size and customer
-- segments to identify groups requiring additional review.

-- 5. Branch Strategy
-- Compare branch customer, balance, and transaction metrics together
-- before making operational or resource-allocation decisions.

-- 6. Transaction Monitoring
-- Use large-transaction, short-interval, and sudden-increase indicators
-- as inputs to further transaction monitoring and investigation.

-- 7. Data Quality Improvement
-- Investigate the 1,000 transactions with missing TransactionDate values,
-- since missing dates limit their use in historical and time-series
-- analysis.