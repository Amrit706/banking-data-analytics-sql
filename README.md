🏦 Banking Data Analytics — SQL Business Case Study
=====================================================

> **End-to-End Retail Banking Analytics using MySQL**
> Customer Behaviour • Account Analytics • Transaction Intelligence • Customer Segmentation • Loan Portfolio • Branch Performance • Advanced SQL • Anomaly Investigation

![Database](https://img.shields.io/badge/DATABASE-MYSQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Language](https://img.shields.io/badge/LANGUAGE-SQL-025E8C?style=for-the-badge)
![Version Control](https://img.shields.io/badge/VERSION_CONTROL-GIT-F05032?style=for-the-badge&logo=git&logoColor=white)
![Repository](https://img.shields.io/badge/REPOSITORY-GITHUB-181717?style=for-the-badge&logo=github&logoColor=white)
![Focus](https://img.shields.io/badge/FOCUS-BUSINESS_ANALYTICS-2E8B57?style=for-the-badge)
![Status](https://img.shields.io/badge/STATUS-COMPLETE-brightgreen?style=for-the-badge)

---

## 📖 Table of Contents
- [Overview](#-project-overview)
- [Repository Structure](#️-repository-structure)
- [Database Schema](#-database-schema)
- [Analysis Breakdown](#-analysis-breakdown)
- [Tech Stack](#️-tech-stack)
- [How to Use](#️-how-to-use)
- [Key Business Insights](#-key-business-insights)
- [Author](#-author)

---

## 📌 Project Overview

This project analyzes a relational banking database (`finance_fraud_loans`) to answer real-world business questions purely through SQL — no external BI tool required. It progresses from raw data cleaning through customer segmentation, loan and branch performance, advanced window-function analytics, and finally fraud/anomaly detection.

**Business questions answered:**
- 👥 Who are our most valuable and most engaged customers?
- 💳 Which accounts and 🏢 branches drive the most activity?
- 🏠 How are loans distributed, and how do they relate to customer balances?
- 🚨 Which transactions or behaviors look anomalous and worth investigating?

Findings are documented in [`documentation/business_insights.md`](./documentation/business_insights.md).

---

## 🗂️ Repository Structure

```
banking-data-analytics-sql/
│
├── documentation/
│   └── business_insights.md          📝 Final written summary of key findings
│
├── schema/                           🧱 Database schema (DDL / ER structure)
│
├── sql/
│   ├── 01_data_quality.sql           ✅ Data quality checks + customers_cleaned view
│   ├── 02_customer_analysis.sql      👥 Customer demographics, value & engagement
│   ├── 03_account_analysis.sql       💳 Account types, balances, dormancy
│   ├── 04_transaction_analysis.sql   💸 Volume, value, trends, outliers
│   ├── 05_customer_segmentation.sql  🎯 High-value / high-frequency / dormant segments
│   ├── 06_loan_analysis.sql          🏠 Loan amounts, status, segment breakdown
│   ├── 07_branch_analysis.sql        🏢 Branch-level performance & rankings
│   ├── 08_advanced_analysis.sql      📈 MoM growth, running totals, moving averages
│   ├── 09_fraud_anomaly_analysis.sql 🚨 Unusual transactions & activity spikes
│   └── 10_business_insights.sql      💡 Queries backing the final insights report
│
└── README.md
```

---

## 🧱 Database Schema

**Schema name:** `finance_fraud_loans`

| Domain | Tables |
|---|---|
| 👤 Customers | `customers_cleaned`, `addresses`, `customer_types` |
| 💳 Accounts | `accounts`, `account_types`, `account_statuses` |
| 💸 Transactions | `transactions`, `transaction_types` |
| 🏠 Loans | `loans`, `loan_statuses` |
| 🏢 Branches | `branches` |

Full table definitions and relationships are in the [`schema/`](./schema) folder.

---

## 🔍 Analysis Breakdown

| # | Script | Focus | Highlights |
|---|---|---|---|
| 1️⃣ | `01_data_quality.sql` | ✅ Data Quality | Builds the cleaned `customers_cleaned` view used across the project |
| 2️⃣ | `02_customer_analysis.sql` | 👥 Customer Analysis | Demographics, single vs. multi-account customers, top balances & activity, engagement tiers |
| 3️⃣ | `03_account_analysis.sql` | 💳 Account Analysis | Balances by type, branch distribution, IQR outliers, dormant/inactive accounts |
| 4️⃣ | `04_transaction_analysis.sql` | 💸 Transaction Analysis | Volume & value trends, top branches/customers, statistical outliers (AVG + 2×STDDEV) |
| 5️⃣ | `05_customer_segmentation.sql` | 🎯 Segmentation | High-Value, High-Frequency, and Dormant customer groups (top 20% rules) |
| 6️⃣ | `06_loan_analysis.sql` | 🏠 Loan Analysis | Loan totals by status, simple-interest estimates, loan-to-balance ratio |
| 7️⃣ | `07_branch_analysis.sql` | 🏢 Branch Analysis | Combined performance ranking, high-customer/low-activity branches, loan portfolios |
| 8️⃣ | `08_advanced_analysis.sql` | 📈 Advanced SQL | MoM growth, running totals, 3-month moving averages, branch % contribution |
| 9️⃣ | `09_fraud_anomaly_analysis.sql` | 🚨 Fraud & Anomalies | Top 5% transactions, rapid-fire transactions, sudden monthly spend spikes |
| 🔟 | `10_business_insights.sql` | 💡 Business Insights | Supporting queries for the final insights report |

> ⚠️ Note: Fraud/anomaly queries flag *potentially unusual* patterns for review — they do not confirm fraudulent activity.

---

## 🛠️ Tech Stack

![MySQL](https://img.shields.io/badge/Database-MySQL-4479A1?logo=mysql&logoColor=white)
![CTE](https://img.shields.io/badge/SQL-CTEs-lightgrey)
![Window Functions](https://img.shields.io/badge/SQL-Window_Functions-blueviolet)
![Stats](https://img.shields.io/badge/Technique-IQR_%26_Outlier_Detection-yellow)

**Core techniques used:** CTEs · Window Functions (`ROW_NUMBER`, `RANK`, `DENSE_RANK`, `NTILE`, `LAG`) · Aggregations · IQR-based outlier detection · Date/time functions

---

## ▶️ How to Use

1. 🧱 Set up the `finance_fraud_loans` schema using the DDL in [`schema/`](./schema).
2. 📥 Load the sample data into the relevant tables.
3. 🔢 Run the scripts in [`sql/`](./sql) in numerical order (01 → 10) — later scripts depend on views/logic built earlier (e.g. `customers_cleaned`).
4. 📖 Review [`documentation/business_insights.md`](./documentation/business_insights.md) for the summarized findings.

---

## 📊 Key Business Insights

- 💰 Customer activity, balances, and loan usage are **unevenly distributed** — a small share of customers hold a disproportionate share of balances and activity.
- 😴 A subset of accounts and customers show **extended inactivity** (12+ months), representing dormancy risk.
- 🚨 Certain transaction patterns (large single transactions, rapid repeated transactions, sudden monthly spikes) are **flagged for fraud review**.
- 🏢 Branch performance varies significantly by both balance holdings and transaction volume — a few branches show **high customer counts paired with low activity**.

📄 Full details in [`documentation/business_insights.md`](./documentation/business_insights.md).

---

## 👤 Author

**Amrit706** 🚀

## 📄 License

This project is available under the license of your choice (e.g. MIT 📜) — add a `LICENSE` file if making the repository public.

---

⭐ *If you found this project useful, consider giving the repo a star!*