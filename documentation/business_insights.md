# 📊 Business Insights & Recommendations

> **Banking Data Analytics — SQL Business Case Study**  
> **Database:** MySQL  
> **Focus:** Customer Behaviour, Transactions, Accounts, Loans, Branch Performance & Anomaly Investigation

---

## 🎯 Executive Summary

This project uses SQL to transform a relational banking dataset into
business-oriented insights across customers, accounts, transactions,
loans, branches, and potentially unusual transaction behaviour.

The analysis covers:

- 🧹 Data-quality validation
- 👥 Customer and account analysis
- 💳 Transaction trend analysis
- 🎯 Customer segmentation
- 💰 Loan portfolio analysis
- 🏦 Branch performance analysis
- 📈 Advanced SQL analysis
- 🔎 Transaction anomaly investigation

The objective is to understand **what is happening in the data, why the
observed patterns may matter, and where further business action or
investigation may be appropriate.**

---

## 🧹 1. Data Quality & Analytical Context

### 🔍 Key Observations

- The loan dataset contains **333 loan records**.
- Transaction dates range from **2020-01-01 to 2026-08-28**.
- **1,000 transaction records have NULL `TransactionDate` values**.
- The IQR-based analysis identified **no account balances outside the
  calculated outlier boundaries**.
- Branch-level loan mapping through the available customer-address
  relationship has incomplete coverage.

### 💡 Business Meaning

Data-quality issues can directly affect analytical conclusions.

For example, missing transaction dates prevent reliable time-based
analysis, while incomplete branch mapping can affect branch-level
loan analysis.

### ✅ Recommended Action

Validate missing transaction dates and investigate the underlying
relationship responsible for unmapped loan-branch records.

---

## 👥 2. Customer Insights

### 📌 Customer Behaviour

Customer analysis examined demographics, customer type, location,
account ownership, account balances, transaction activity, and engagement.

### 💡 Key Insight

Customer behaviour is not uniform. Differences in account balances,
transaction frequency, and recent activity allow the customer base to
be divided into meaningful behavioural groups.

### 🎯 Business Significance

Customers with high financial balances, frequent transactions, or very
low recent engagement may require different engagement strategies.

### ✅ Recommended Action

Use customer-level behavioural indicators to support:

- Customer retention
- Targeted engagement
- Product positioning
- Cross-selling
- Re-engagement initiatives

---

## 💳 3. Account Insights

### 📊 Account Balance Distribution

The IQR-based analysis found no account balances outside the calculated
statistical boundaries.

### 💡 Business Meaning

The account portfolio is not dominated by extreme balance observations
under the selected outlier methodology.

### ✅ Recommended Action

Continue monitoring account balances using appropriate statistical
methods rather than focusing only on extreme individual accounts.

### 💤 Dormant & Inactive Accounts

Accounts with limited or no recent transaction activity were identified.

### 💡 Business Meaning

Dormant or inactive accounts indicate weaker recent customer engagement
and may represent opportunities for reactivation.

### ✅ Recommended Action

Consider targeted re-engagement campaigns and investigate whether
dormancy is concentrated by account type, customer characteristics,
or branch.

---

## 💰 4. Transaction Insights

### 📈 Transaction Activity

Transaction analysis examined:

- Transaction volume
- Transaction value
- Average transaction value
- Transaction types
- Monthly transaction trends
- Customer transaction activity
- Branch transaction activity

### 💡 Business Meaning

Transaction behaviour provides an indication of how actively customers
use banking services.

Comparing transaction volume with transaction value also helps
distinguish between high-volume/lower-value and lower-volume/higher-value
activity.

### ✅ Recommended Action

Use transaction volume, transaction value, and average transaction value
jointly when evaluating customer and branch engagement.

### ⚠️ Missing Transaction Dates

The dataset contains **1,000 transactions without `TransactionDate`**.

### 💡 Business Meaning

These records can contribute to certain overall analyses, but they
cannot reliably be used in monthly or chronological analysis.

### ✅ Recommended Action

Investigate the source of the missing dates and recover them where possible.

---

## 🎯 5. Customer Segmentation Insights

### 🏆 High-Value Customers

**Definition:**  
Customers belonging to the top 20% by active-account balance **and**
the top 20% by transaction frequency.

### 💡 Business Meaning

This segment represents customers combining relatively high financial
balances with strong transaction engagement.

### ✅ Recommended Action

Consider targeted retention, relationship management, personalised
offers, and relevant cross-selling opportunities.

---

### ⚡ High-Frequency Customers

**Definition:**  
Customers from the top 20% by transaction count.

### 💡 Business Meaning

These customers demonstrate strong transaction engagement and regular
use of banking services.

### ✅ Recommended Action

Analyse their existing product relationships and identify relevant
cross-selling and engagement opportunities.

---

### 💤 Dormant Customers

**Definition:**  
Customers whose active accounts had no transaction activity within the
12 months preceding the latest transaction date in the dataset, or had
no recorded transaction activity.

### 💡 Business Meaning

These customers show limited recent engagement with their active banking
relationships.

### ✅ Recommended Action

Consider targeted re-engagement campaigns and investigate whether
dormancy is concentrated among particular customer or account groups.

---

## 💸 6. Loan Portfolio Insights

### 📊 Loan Portfolio

The dataset contains **333 loan records**.

The loan analysis examined:

- Principal loan amount
- Loan status
- Multiple-loan customers
- Average loan amount by customer segment
- Account balance versus loan amount
- Loan-status patterns across loan-size groups

### 💡 Business Meaning

Combining loan characteristics with customer behaviour provides a
broader view of lending exposure.

### ✅ Recommended Action

Use loan characteristics together with customer behaviour when
prioritising portfolio review.

---

### ⚖️ Account Balance vs Loan Amount

Customer-level analysis compared total account balance with total
principal loan amount.

A **Loan-to-Balance Ratio** was also calculated:

```text
Loan-to-Balance Ratio =
Total Loan Amount / Total Account Balance