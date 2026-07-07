# Credit Card Customer & Revenue Risk Analytics

An end-to-end data analytics project analyzing credit card customer behavior, revenue drivers, and credit risk using **Python, MySQL, and Power BI**. The project covers the full pipeline — from raw data cleaning to a 3-page interactive Power BI dashboard with Week-over-Week (WoW) KPI tracking.

> **Note on scope:** This project focuses on customer segmentation, revenue analysis, and delinquency/credit-risk patterns — it does not include fraud/anomaly detection modeling.

---

## 📌 Business Problem

A bank wants to understand:
- Where its credit card revenue is coming from (which customer segments, card types, and states drive the most revenue)
- How actively customers are using their cards
- Which customers are at risk of delinquency or default
- How key metrics are trending week-over-week

This project answers those questions through 50 targeted SQL business queries and an interactive Power BI dashboard.

---

## 🗂️ Repository Contents

| File | Description |
|---|---|
| [`credit_card_analysis.sql`](credit_card_analysis.sql) | Schema creation, data load, and 50 business KPI queries |
| [`credit_card_financial_analysis.pbix`](credit_card_financial_analysis.pbix) | Power BI dashboard (3 pages, DAX measures, WoW tracking) |
| [`data_preparation.ipynb`](data_preparation.ipynb) | Python/Pandas notebook — raw data cleaning & merging |
| [`final_credit_card.csv`](final_credit_card.csv) | Cleaned, merged credit card transaction dataset |
| [`final_customers.csv`](final_customers.csv) | Cleaned, merged customer demographic dataset |
| [`requirements.txt`](requirements.txt) | Python dependencies |

---

## 🔧 Tech Stack

| Layer | Tools |
|---|---|
| Data Cleaning | Python (Pandas, NumPy) |
| Database | MySQL |
| Analysis | SQL (CTEs, Window Functions, NTILE, STDDEV) |
| Visualization | Power BI (DAX, calculated columns, WoW measures) |

---

## 🔄 Data Pipeline

1. **Raw data** — Four source files (`cc_add.csv`, `credit_card.csv`, `cust_add.csv`, `customer.csv`) containing card-level and customer-level records
2. **Cleaning (Python/Pandas)** — Null checks, date type conversion, column renaming for consistency, concatenation into two unified tables (see `data_preparation.ipynb`)
3. **Output** — `final_credit_card.csv` and `final_customers.csv`
4. **Load to MySQL** — Schema created with proper data types (see `credit_card_analysis.sql`), data loaded via `LOAD DATA INFILE` with inline whitespace cleaning
5. **SQL Analysis** — 50 business KPI queries across 5 categories (Revenue, Engagement, Risk, Segmentation, Spending Behavior)
6. **Power BI Dashboard** — 3-page report with calculated columns (Age Group, Income Group), explicit DAX measures, and Week-over-Week trend tracking

---

## 📊 SQL Analysis — 50 KPIs Across 5 Categories

| Category | Examples |
|---|---|
| 💰 Revenue & Profitability (Q1–10) | Total interest revenue, revenue by card category, top 10% customer revenue share (Pareto) |
| 💳 Activity & Engagement (Q11–20) | Active vs. inactive customers, high-frequency low-value spenders |
| 📉 Risk & Credit Management (Q21–30) | Delinquency rate, utilization-to-default correlation, near-limit accounts |
| 👥 Segmentation & Profiling (Q31–40) | Age/income/education distributions, homeowner vs. non-homeowner spend |
| 🛍️ Spending Behavior (Q41–50) | Expense type breakdown, chip adoption rate, 4-week moving average |

Full queries in [`credit_card_analysis.sql`](credit_card_analysis.sql).

---

## 📈 Power BI Dashboard

**3 Pages:**
1. **CC Transaction Report** — Revenue, interest, transaction volume/amount by card category, chip usage, expense type
