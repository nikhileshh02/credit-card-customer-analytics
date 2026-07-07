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

## 🗂️ Project Structure

```
credit-card-customer-analytics/
│
├── README.md
├── requirements.txt
│
├── data/
│   ├── final_credit_card.csv
│   └── final_customers.csv
│
├── notebooks/
│   └── data_preparation.ipynb        # Raw data cleaning & merging (pandas)
│
├── sql/
│   └── credit_card_analysis.sql      # Schema + load + 50 KPI queries
│
└── powerbi/
    └── credit_card_financial_analysis.pbix
```

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
2. **Cleaning (Python/Pandas)** — Null checks, date type conversion, column renaming for consistency, concatenation into two unified tables
3. **Output** — `final_credit_card.csv` and `final_customers.csv`
4. **Load to MySQL** — Schema created with proper data types (see `sql/credit_card_analysis.sql`), data loaded via `LOAD DATA INFILE` with inline whitespace cleaning
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

Full queries in [`sql/credit_card_analysis.sql`](sql/credit_card_analysis.sql).

---

## 📈 Power BI Dashboard

**3 Pages:**
1. **CC Transaction Report** — Revenue, interest, transaction volume/amount by card category, chip usage, expense type
2. **CC Customer Report** — Revenue by demographic segment (age, income, education, marital status, state) with gender-wise breakdowns
3. **Insights** — Summary view

**Key DAX Features:**
- Calculated columns: `AgeGroup`, `IncomeGroup` for segmentation
- Week-over-Week (WoW) measures: current week vs. previous week comparisons for Revenue, Transaction Amount, Transaction Count, and Customer Count
- Explicit measures for all core KPIs (not relying on implicit aggregations)

---

## 🚀 How to Reproduce

### 1. Clone the repo
```bash
git clone https://github.com/<your-username>/credit-card-customer-analytics.git
cd credit-card-customer-analytics
```

### 2. Set up Python environment
```bash
pip install -r requirements.txt
```

### 3. Run data preparation notebook
Open `notebooks/data_preparation.ipynb` and run all cells to regenerate `final_credit_card.csv` and `final_customers.csv` (update file paths inside the notebook to match your local setup).

### 4. Load data into MySQL
- Open `sql/credit_card_analysis.sql` in MySQL Workbench
- **Update the `LOAD DATA LOCAL INFILE` file paths** to point to your local `data/` folder
- Run the script to create the schema, load data, and explore the 50 KPI queries

### 5. Open the Power BI dashboard
- Open `powerbi/credit_card_financial_analysis.pbix` in Power BI Desktop
- Update the MySQL connection string (Home → Transform Data → Data Source Settings) to point to your local MySQL instance
- Refresh

---

## 🔑 Key Insights

- Identified top revenue-contributing customer segments by job profile, income band, and state
- Found that customers in the 60–90% utilization band show markedly higher delinquency rates than lower-utilization customers
- Built Week-over-Week tracking to monitor revenue and customer acquisition trends over time

---

## 📬 Contact

**Nikhilesh Chouhan**
- LinkedIn: [linkedin.com/in/nikhilesh-chouhan](https://linkedin.com/in/nikhilesh-chouhan/)
- GitHub: [@nikhileshh02](https://github.com/nikhileshh02)
