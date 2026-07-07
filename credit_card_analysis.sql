-- ============================================================
-- Credit Card Customer & Revenue Risk Analytics
-- SQL Setup + 50 Business KPI Queries
-- ============================================================

CREATE DATABASE IF NOT EXISTS credit_card_analysis;
USE credit_card_analysis;

-- ------------------------------------------------------------
-- Table: customers
-- ------------------------------------------------------------
CREATE TABLE customers (
    Client_Num                 BIGINT PRIMARY KEY,
    Customer_Age                INT,
    Gender                       VARCHAR(50),
    Dependent_Count              INT,
    Education_Level              VARCHAR(50),
    Marital_Status               VARCHAR(50),
    state_cd                     VARCHAR(50),
    Zipcode                      VARCHAR(10),   -- kept as text: zip codes are identifiers, not numbers (preserves leading zeros)
    Car_Owner                    VARCHAR(50),
    House_Owner                  VARCHAR(50),
    Personal_loan                VARCHAR(50),
    contact                      VARCHAR(50),
    Customer_Job                 VARCHAR(50),
    Income                       INT,
    Cust_Satisfaction_Score      INT
);

-- ------------------------------------------------------------
-- Table: credit_card
-- ------------------------------------------------------------
CREATE TABLE credit_card (
    Client_Num                  BIGINT,
    Card_Category                VARCHAR(50),
    Annual_Fees                  INT,
    Activation_30_Days           INT,
    Customer_Acq_Cost            INT,
    Week_Start_Date               DATE,
    Week_Num                      VARCHAR(50),
    Qtr                           VARCHAR(50),
    current_year                  INT,
    Credit_Limit                  FLOAT,
    Total_Revolving_Bal            INT,
    Total_Trans_Amt                 INT,
    Total_Trans_Vol                 INT,
    Avg_Utilization_Ratio            FLOAT,
    `Use Chip`                        VARCHAR(50),
    `Exp Type`                        VARCHAR(50),
    Interest_Earned                    FLOAT,
    Delinquent_Acc                     INT,
    CONSTRAINT fk_client
        FOREIGN KEY (Client_Num) REFERENCES customers(Client_Num)
);

-- ------------------------------------------------------------
-- Load data
-- NOTE: Update the file paths below to match your local system
-- before running. `SET` clause trims whitespace during load itself,
-- so no separate cleanup step is needed afterward.
-- ------------------------------------------------------------
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE "your_path/final_customers.csv"
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY "\n"
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE "your_path/final_credit_card.csv"
INTO TABLE credit_card
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY "\n"
IGNORE 1 ROWS
(Client_Num, Card_Category, Annual_Fees, Activation_30_Days, Customer_Acq_Cost,
 Week_Start_Date, Week_Num, Qtr, current_year, Credit_Limit, Total_Revolving_Bal,
 Total_Trans_Amt, Total_Trans_Vol, Avg_Utilization_Ratio, @UseChip, @ExpType,
 Interest_Earned, Delinquent_Acc)
SET
    `Use Chip` = TRIM(@UseChip),
    `Exp Type` = TRIM(@ExpType);

-- ------------------------------------------------------------
-- Sanity checks after load
-- ------------------------------------------------------------
SELECT * FROM credit_card LIMIT 10;
SELECT * FROM customers LIMIT 10;
SELECT DISTINCT `Use Chip` FROM credit_card;   -- should show: Chip, Swipe, Online (no trailing spaces)
SELECT DISTINCT `Exp Type` FROM credit_card;
SELECT Zipcode FROM customers LIMIT 5;         -- should behave as text


-- ============================================================
-- 💰 Revenue & Profitability (Business Growth)
-- ============================================================

-- 1. A bank wants to measure total earnings — what is the total interest revenue generated?
SELECT ROUND(SUM(Interest_Earned), 2) AS Total_Interest_Revenue
FROM credit_card;

-- 2. Management wants to track customer value — what is the average revenue per customer?
SELECT ROUND(AVG(Interest_Earned), 2) AS Avg_Revenue_Per_Customer
FROM credit_card;

-- 3. Which card category contributes the highest revenue for the business?
SELECT Card_Category,
       ROUND(SUM(Interest_Earned), 2) AS Total_Revenue
FROM credit_card
GROUP BY Card_Category
ORDER BY Total_Revenue DESC;

-- 4. How has revenue changed quarter-over-quarter in the last year?
SELECT Qtr, ROUND(SUM(Interest_Earned), 2) AS Revenue
FROM credit_card
GROUP BY Qtr
ORDER BY Qtr;

-- 5. Which customer segment (age group) generates the most revenue?
SELECT
  CASE
    WHEN c.Customer_Age < 30 THEN 'Under 30'
    WHEN c.Customer_Age BETWEEN 30 AND 45 THEN '30-45'
    WHEN c.Customer_Age BETWEEN 46 AND 60 THEN '46-60'
    ELSE '60+'
  END AS Age_Group,
  ROUND(SUM(cc.Interest_Earned), 2) AS Total_Revenue
FROM customers c
JOIN credit_card cc ON c.Client_Num = cc.Client_Num
GROUP BY Age_Group
ORDER BY Total_Revenue DESC;

-- 6. Does higher income lead to higher revenue contribution?
SELECT
  CASE
    WHEN c.Income < 40000  THEN 'Low (<40K)'
    WHEN c.Income < 80000  THEN 'Mid (40K-80K)'
    WHEN c.Income < 120000 THEN 'High (80K-120K)'
    ELSE 'Very High (120K+)'
  END AS Income_Band,
  ROUND(AVG(cc.Interest_Earned), 2) AS Avg_Revenue
FROM customers c
JOIN credit_card cc ON c.Client_Num = cc.Client_Num
GROUP BY Income_Band
ORDER BY Avg_Revenue DESC;

-- 7. Which states are generating the highest revenue for the bank?
SELECT c.state_cd,
       ROUND(SUM(cc.Interest_Earned)) AS State_Revenue
FROM customers c
JOIN credit_card cc ON c.Client_Num = cc.Client_Num
GROUP BY c.state_cd
ORDER BY State_Revenue DESC;

-- 8. What percentage of total revenue comes from top 10% customers?
WITH ranked AS (
  SELECT Client_Num,
         SUM(Interest_Earned) AS cust_rev,
         NTILE(10) OVER (ORDER BY SUM(Interest_Earned) DESC) AS decile
  FROM credit_card
  GROUP BY Client_Num
)
SELECT
  ROUND(SUM(CASE WHEN decile = 1 THEN cust_rev END) /
        SUM(cust_rev) * 100, 2) AS Top10_Pct_Revenue
FROM ranked;

-- 9. Are premium card users contributing more revenue than basic card users?
SELECT Card_Category,
       COUNT(DISTINCT Client_Num) AS Customers,
       ROUND(SUM(Interest_Earned), 2) AS Total_Revenue,
       ROUND(AVG(Interest_Earned), 2) AS Avg_Revenue
FROM credit_card
GROUP BY Card_Category
ORDER BY Avg_Revenue DESC;

-- 10. Which job profile customers are most profitable?
SELECT c.Customer_Job,
       ROUND(SUM(cc.Interest_Earned), 2) AS Profitable_Customers_by_Profile
FROM customers c
JOIN credit_card cc ON c.Client_Num = cc.Client_Num
GROUP BY c.Customer_Job
ORDER BY Profitable_Customers_by_Profile DESC;


-- ============================================================
-- 💳 Customer Activity & Engagement
-- ============================================================

-- 11. What is the total transaction amount processed by the bank?
SELECT SUM(Total_Trans_Amt) AS Total_Transaction_Amount
FROM credit_card;

-- 12. How many total transactions are performed across all customers?
SELECT SUM(Total_Trans_Vol) AS Total_Transaction_Volume
FROM credit_card;

-- 13. What is the average transaction value per customer?
SELECT Client_Num,
       ROUND(SUM(Total_Trans_Amt) / NULLIF(SUM(Total_Trans_Vol), 0), 2)
         AS Avg_Transaction_Value
FROM credit_card
GROUP BY Client_Num
ORDER BY Avg_Transaction_Value DESC;

-- 14. What percentage of customers are actively using their cards?
SELECT
  (COUNT(CASE WHEN Activation_30_Days = 1 THEN 1 END) * 100.0 / COUNT(*)) AS Active_Cards
FROM credit_card;

-- 15. Which customers have stopped making transactions (inactive users)?
SELECT DISTINCT Client_Num
FROM credit_card
WHERE Total_Trans_Vol = 0;

-- 16. What is the average number of transactions per customer?
SELECT ROUND(AVG(Total_Trans_Vol), 2) AS Avg_Transactions_Per_Customer
FROM credit_card;

-- 17. Which segment of customers uses credit cards most frequently?
SELECT c.Customer_Job,
       ROUND(AVG(cc.Total_Trans_Vol), 2) AS Avg_Txn_Volume
FROM customers c
JOIN credit_card cc ON c.Client_Num = cc.Client_Num
GROUP BY c.Customer_Job
ORDER BY Avg_Txn_Volume DESC;

-- 18. Are younger customers more active than older ones?
SELECT
  CASE
    WHEN c.Customer_Age < 30 THEN 'Under 30'
    WHEN c.Customer_Age BETWEEN 30 AND 45 THEN '30-45'
    WHEN c.Customer_Age BETWEEN 46 AND 60 THEN '46-60'
    ELSE '60+'
  END AS Age_Group,
  ROUND(AVG(cc.Total_Trans_Vol), 2) AS Avg_Transactions
FROM customers c
JOIN credit_card cc ON c.Client_Num = cc.Client_Num
GROUP BY Age_Group
ORDER BY Avg_Transactions DESC;

-- 19. What is the trend of customer activity over time?
SELECT Week_Num, Qtr, current_year,
       SUM(Total_Trans_Vol) AS Weekly_Transactions,
       SUM(Total_Trans_Amt) AS Weekly_Spend
FROM credit_card
GROUP BY current_year, Qtr, Week_Num
ORDER BY current_year, CAST(Week_Num AS UNSIGNED);

-- 20. Which customers are high-frequency but low-value spenders?
SELECT Client_Num,
       SUM(Total_Trans_Vol) AS Txn_Count,
       SUM(Total_Trans_Amt) AS Total_Spend,
       ROUND(SUM(Total_Trans_Amt) / NULLIF(SUM(Total_Trans_Vol), 0), 2) AS Avg_Txn_Value
FROM credit_card
GROUP BY Client_Num
HAVING Txn_Count > (SELECT AVG(Total_Trans_Vol) FROM credit_card)
   AND Avg_Txn_Value < (SELECT AVG(Total_Trans_Amt / NULLIF(Total_Trans_Vol, 0)) FROM credit_card)
ORDER BY Txn_Count DESC;


-- ============================================================
-- 📉 Risk & Credit Management
-- ============================================================

-- 21. What is the overall delinquency rate of customers?
SELECT
  ROUND(SUM(Delinquent_Acc) * 100.0 / COUNT(*), 2) AS Delinquency_Rate_Pct
FROM credit_card;

-- 22. Which segment of customers has the highest delinquency rate?
SELECT c.Customer_Job,
       ROUND(AVG(cc.Delinquent_Acc) * 100, 2) AS Delinquency_Rate_Pct
FROM customers c
JOIN credit_card cc ON c.Client_Num = cc.Client_Num
GROUP BY c.Customer_Job
ORDER BY Delinquency_Rate_Pct DESC;

-- 23. What percentage of customers are classified as high-risk?
SELECT
  ROUND(COUNT(CASE WHEN Avg_Utilization_Ratio > 0.75
                    AND Delinquent_Acc > 0 THEN 1 END) * 100.0 /
        COUNT(*), 2) AS High_Risk_Pct
FROM credit_card;

-- 24. Do customers with high utilization ratios default more often?
SELECT
  CASE
    WHEN Avg_Utilization_Ratio < 0.3  THEN 'Low (<30%)'
    WHEN Avg_Utilization_Ratio < 0.6  THEN 'Medium (30-60%)'
    WHEN Avg_Utilization_Ratio < 0.9  THEN 'High (60-90%)'
    ELSE 'Very High (90%+)'
  END AS Utilization_Band,
  ROUND(AVG(Delinquent_Acc) * 100, 2) AS Delinquency_Rate_Pct,
  COUNT(*) AS Total_Delinquent
FROM credit_card
GROUP BY Utilization_Band
ORDER BY Delinquency_Rate_Pct DESC;

-- 25. Which income group has the highest credit risk?
SELECT
  CASE
    WHEN c.Income < 40000  THEN 'Low (<40K)'
    WHEN c.Income < 80000  THEN 'Mid (40K-80K)'
    ELSE 'High (80K+)'
  END AS Income_Band,
  ROUND(AVG(cc.Delinquent_Acc) * 100, 2) AS Delinquency_Rate_Pct
FROM customers c
JOIN credit_card cc ON c.Client_Num = cc.Client_Num
GROUP BY Income_Band
ORDER BY Delinquency_Rate_Pct DESC;

-- 26. What is the average credit utilization ratio across customers?
SELECT ROUND(AVG(Avg_Utilization_Ratio) * 100, 2) AS Avg_Utilization_Pct
FROM credit_card;

-- 27. Which customers are close to exceeding their credit limits?
SELECT Client_Num,
       Credit_Limit,
       Total_Revolving_Bal,
       ROUND(Avg_Utilization_Ratio * 100, 2) AS Utilization_Pct
FROM credit_card
WHERE Avg_Utilization_Ratio > 0.9
ORDER BY Utilization_Pct DESC;

-- 28. Are customers with low satisfaction more likely to default?
SELECT c.Cust_Satisfaction_Score,
       ROUND(AVG(cc.Delinquent_Acc) * 100, 2) AS Delinquency_Rate_Pct,
       COUNT(*) AS Customer_Count
FROM customers c
JOIN credit_card cc ON c.Client_Num = cc.Client_Num
GROUP BY c.Cust_Satisfaction_Score
ORDER BY c.Cust_Satisfaction_Score;

-- 29. What is the relationship between credit limit and delinquency?
SELECT
  CASE
    WHEN Credit_Limit < 5000   THEN 'Under 5K'
    WHEN Credit_Limit < 10000  THEN '5K-10K'
    WHEN Credit_Limit < 20000  THEN '10K-20K'
    ELSE 'Above 20K'
  END AS Limit_Band,
  ROUND(AVG(Delinquent_Acc) * 100, 2) AS Delinquency_Rate_Pct
FROM credit_card
GROUP BY Limit_Band
ORDER BY Delinquency_Rate_Pct DESC;

-- 30. Which states have the highest number of delinquent accounts?
SELECT c.state_cd,
       SUM(cc.Delinquent_Acc) AS Total_Delinquent,
       COUNT(*) AS Total_Accounts,
       ROUND(SUM(cc.Delinquent_Acc) * 100.0 / COUNT(*), 2) AS Delinquency_Pct
FROM customers c
JOIN credit_card cc ON c.Client_Num = cc.Client_Num
GROUP BY c.state_cd
ORDER BY Total_Delinquent DESC;


-- ============================================================
-- 👥 Customer Segmentation & Profiling
-- ============================================================

-- 31. How many customers fall into each age group category?
SELECT
  CASE
    WHEN Customer_Age < 30 THEN 'Under 30'
    WHEN Customer_Age BETWEEN 30 AND 45 THEN '30-45'
    WHEN Customer_Age BETWEEN 46 AND 60 THEN '46-60'
    ELSE '60+'
  END AS Age_Group,
  COUNT(*) AS Customer_Count
FROM customers
GROUP BY Age_Group
ORDER BY Customer_Count DESC;

-- 32. What is the distribution of customers by income group?
SELECT
  CASE
    WHEN Income < 40000  THEN 'Low (<40K)'
    WHEN Income < 80000  THEN 'Mid (40K-80K)'
    WHEN Income < 120000 THEN 'High (80K-120K)'
    ELSE 'Very High (120K+)'
  END AS Income_Group,
  COUNT(*) AS Customers
FROM customers
GROUP BY Income_Group
ORDER BY Customers DESC;

-- 33. Which education level group contributes most to revenue?
SELECT c.Education_Level,
       ROUND(SUM(cc.Interest_Earned), 2) AS Total_Revenue,
       COUNT(DISTINCT c.Client_Num) AS Customers
FROM customers c
JOIN credit_card cc ON c.Client_Num = cc.Client_Num
GROUP BY c.Education_Level
ORDER BY Total_Revenue DESC;

-- 34. What is the customer distribution by marital status?
SELECT Marital_Status,
       COUNT(*) AS Customer_Count,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS Pct
FROM customers
GROUP BY Marital_Status
ORDER BY Customer_Count DESC;

-- 35. Which demographic segment is most profitable?
SELECT c.Gender, c.Education_Level,
       ROUND(AVG(cc.Interest_Earned), 2) AS Avg_Revenue,
       COUNT(DISTINCT c.Client_Num) AS Customers
FROM customers c
JOIN credit_card cc ON c.Client_Num = cc.Client_Num
GROUP BY c.Gender, c.Education_Level
ORDER BY Avg_Revenue DESC;

-- 36. Do homeowners spend more than non-homeowners?
SELECT c.House_Owner,
       ROUND(AVG(cc.Total_Trans_Amt), 2) AS Avg_Spend,
       COUNT(DISTINCT c.Client_Num) AS Customers
FROM customers c
JOIN credit_card cc ON c.Client_Num = cc.Client_Num
GROUP BY c.House_Owner
ORDER BY Avg_Spend DESC;

-- 37. Are car owners more active in transactions?
SELECT c.Car_Owner,
       ROUND(AVG(cc.Total_Trans_Vol), 2) AS Avg_Txn_Volume,
       ROUND(AVG(cc.Total_Trans_Amt), 2) AS Avg_Spend
FROM customers c
JOIN credit_card cc ON c.Client_Num = cc.Client_Num
GROUP BY c.Car_Owner;

-- 38. Which job category has the highest average transaction value?
SELECT c.Customer_Job,
       ROUND(AVG(cc.Total_Trans_Amt / NULLIF(cc.Total_Trans_Vol, 0)), 2) AS Avg_Txn_Value
FROM customers c
JOIN credit_card cc ON c.Client_Num = cc.Client_Num
GROUP BY c.Customer_Job
ORDER BY Avg_Txn_Value DESC;

-- 39. What is the gender-wise distribution of customers?
SELECT Gender,
       COUNT(*) AS Customer_Count,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS Pct
FROM customers
GROUP BY Gender;

-- 40. Which segment shows the highest customer satisfaction?
SELECT c.Customer_Job,
       ROUND(AVG(c.Cust_Satisfaction_Score), 2) AS Avg_Satisfaction
FROM customers c
GROUP BY c.Customer_Job
ORDER BY Avg_Satisfaction DESC;


-- ============================================================
-- 🛍️ Spending Behavior Analysis
-- ============================================================

-- 41. Which expense type contributes the highest spending?
SELECT `Exp Type`,
       SUM(Total_Trans_Amt) AS Total_Spend
FROM credit_card
GROUP BY `Exp Type`
ORDER BY Total_Spend DESC;

-- 42. What is the spending pattern across different customer segments?
SELECT c.Customer_Job, cc.`Exp Type`,
       ROUND(SUM(cc.Total_Trans_Amt), 2) AS Total_Spend
FROM customers c
JOIN credit_card cc ON c.Client_Num = cc.Client_Num
GROUP BY c.Customer_Job, cc.`Exp Type`
ORDER BY c.Customer_Job, Total_Spend DESC;

-- 43. Do high-income customers spend more on specific categories?
SELECT cc.`Exp Type`,
       ROUND(SUM(cc.Total_Trans_Amt), 2) AS Total_Spend
FROM customers c
JOIN credit_card cc ON c.Client_Num = cc.Client_Num
WHERE c.Income > 100000
GROUP BY cc.`Exp Type`
ORDER BY Total_Spend DESC;

-- 44. What is the average spending per transaction by expense type?
SELECT `Exp Type`,
       ROUND(SUM(Total_Trans_Amt) / NULLIF(SUM(Total_Trans_Vol), 0), 2) AS Avg_Spend_Per_Txn
FROM credit_card
GROUP BY `Exp Type`
ORDER BY Avg_Spend_Per_Txn DESC;

-- 45. Which customers have unusually high spending patterns?
SELECT Client_Num,
       SUM(Total_Trans_Amt) AS Total_Spend
FROM credit_card
GROUP BY Client_Num
HAVING Total_Spend > (
  SELECT AVG(Total_Spend) + 2 * STDDEV(Total_Spend)
  FROM (SELECT Client_Num, SUM(Total_Trans_Amt) AS Total_Spend
        FROM credit_card GROUP BY Client_Num) t
)
ORDER BY Total_Spend DESC;

-- 46. What is the trend of spending over time?
SELECT Week_Num, current_year, Qtr,
       SUM(Total_Trans_Amt) AS Weekly_Spend,
       ROUND(AVG(SUM(Total_Trans_Amt))
             OVER (ORDER BY current_year, CAST(Week_Num AS UNSIGNED)
                   ROWS BETWEEN 3 PRECEDING AND CURRENT ROW), 2) AS Moving_Avg_4W
FROM credit_card
GROUP BY current_year, Qtr, Week_Num
ORDER BY current_year, CAST(Week_Num AS UNSIGNED);

-- 47. Do customers prefer chip-based transactions over others?
SELECT `Use Chip`,
       COUNT(*) AS Transactions,
       SUM(Total_Trans_Amt) AS Total_Spend,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS Share_Pct
FROM credit_card
GROUP BY `Use Chip`
ORDER BY Transactions DESC;

-- 48. What is the adoption rate of chip usage among customers?
SELECT
  ROUND(COUNT(CASE WHEN `Use Chip` = 'Chip' THEN 1 END) * 100.0 / COUNT(*), 2) AS Chip_Adoption_Pct
FROM credit_card;

-- 49. Which segment prefers digital vs physical transactions?
SELECT c.Customer_Job,
       cc.`Use Chip` AS Transaction_Type,
       COUNT(*) AS Count
FROM customers c
JOIN credit_card cc ON c.Client_Num = cc.Client_Num
GROUP BY c.Customer_Job, cc.`Use Chip`
ORDER BY c.Customer_Job, Count DESC;

-- 50. Are customers shifting their spending behavior over time?
SELECT current_year, Qtr, `Exp Type`,
       ROUND(SUM(Total_Trans_Amt), 2) AS Quarterly_Spend
FROM credit_card
GROUP BY current_year, Qtr, `Exp Type`
ORDER BY current_year, Qtr, Quarterly_Spend DESC;


-- ============================================================
-- Reference: 5 categories, 50 KPIs
-- Revenue & Profitability   (Q1–10)  — interest revenue, QoQ growth, top-10% Pareto, profitability by job/state
-- Activity & Engagement     (Q11–20) — transaction volume/value, active vs dormant users, high-freq low-value spenders
-- Risk & Credit             (Q21–30) — delinquency rates, utilization-to-default correlation, near-limit accounts
-- Segmentation              (Q31–40) — age/income/education/marital distributions, homeowner vs non-homeowner spend
-- Spending Behavior         (Q41–50) — expense type breakdown, chip adoption, 4-week moving average, behavioral shift
-- ============================================================
