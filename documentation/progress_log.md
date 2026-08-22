## 2026-08-23 — Data Quality Phase

**Worked on:** 01_data_quality.sql — schema discovery, missing values, 
duplicates, invalid values, referential integrity

**What I did:**
- Confirmed schema has 11 tables with no enforced FK constraints
- Ran NULL checks across all core tables
- Ran duplicate checks (PK-level and business-logic-level)
- Ran orphan/referential integrity checks — all returned 0 rows (data is 
  internally consistent despite no enforced FK constraints)
- Found DateOfBirth stored as TEXT with 3 inconsistent formats + 'NaT' 
  placeholder for missing values

**Problem encountered:** DateOfBirth values failed to parse under a single 
date format — 31 rows affected.

**How I resolved it:** Created a non-destructive view (customers_cleaned) 
that standardizes all formats and converts 'NaT' to proper NULL. Raw table 
left untouched.

**Decision made:** All future date-based customer queries use 
customers_cleaned, not customers.

**Next step:** Define customer analysis question scope and activity 
threshold, then begin 02_customer_analysis.sql.