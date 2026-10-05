-- =========================================================
-- L&T FINANCIAL INTELLIGENCE & PERFORMANCE ANALYTICS
-- PostgreSQL Analysis
-- This file contains the main SQL analysis used for the project.
-- =========================================================
-- =========================================================


-- =========================================================
-- 1. TABLE STRUCTURE
-- =========================================================

CREATE TABLE bs (
    id SERIAL PRIMARY KEY,
    statement_type VARCHAR(20),
    fy VARCHAR(10),
    particular VARCHAR(100),
    value NUMERIC(18,2)
);

CREATE TABLE pl (
    id SERIAL PRIMARY KEY,
    statement_type VARCHAR(20),
    fy VARCHAR(10),
    particular VARCHAR(100),
    value NUMERIC(18,2)
);

CREATE TABLE cf (
    id SERIAL PRIMARY KEY,
    statement_type VARCHAR(20),
    fy VARCHAR(10),
    particular VARCHAR(100),
    value NUMERIC(18,2)
);

CREATE TABLE ratios (
    id SERIAL PRIMARY KEY,
    statement_type VARCHAR(20),
    fy VARCHAR(10),
    particular VARCHAR(100),
    value NUMERIC(18,2)
);

CREATE TABLE sh (
    id SERIAL PRIMARY KEY,
    fy VARCHAR(10),
    shareholder_type VARCHAR(50),
    holding_pct NUMERIC(10,2)
);


-- =========================================================
-- 2. DATA CHECK
-- =========================================================

-- Check the number of records in each table.
SELECT 'Balance Sheet' AS table_name, COUNT(*) AS row_count FROM bs
UNION ALL
SELECT 'Profit & Loss', COUNT(*) FROM pl
UNION ALL
SELECT 'Cash Flow', COUNT(*) FROM cf
UNION ALL
SELECT 'Ratios', COUNT(*) FROM ratios
UNION ALL
SELECT 'Shareholding', COUNT(*) FROM sh;


-- Check P&L records by year and statement type.
SELECT
    fy,
    statement_type,
    COUNT(*) AS record_count
FROM pl
GROUP BY fy, statement_type
ORDER BY fy, statement_type;


-- =========================================================
-- 3. P&L ANALYSIS
-- =========================================================

-- Sales by financial year.
SELECT
    fy,
    statement_type,
    value AS sales
FROM pl
WHERE particular = 'Sales'
ORDER BY fy, statement_type;


-- Net Profit by financial year.
SELECT
    fy,
    statement_type,
    value AS net_profit
FROM pl
WHERE particular = 'Net Profit'
ORDER BY fy, statement_type;


-- Total and average Sales by statement type.
SELECT
    statement_type,
    SUM(value) AS total_sales,
    ROUND(AVG(value), 2) AS average_sales
FROM pl
WHERE particular = 'Sales'
GROUP BY statement_type
ORDER BY statement_type;


-- Net Profit Margin.
SELECT
    s.fy,
    s.statement_type,
    s.value AS sales,
    p.value AS net_profit,
    ROUND((p.value / NULLIF(s.value, 0)) * 100, 2) AS net_profit_margin
FROM pl s
JOIN pl p
    ON s.fy = p.fy
    AND s.statement_type = p.statement_type
WHERE s.particular = 'Sales'
  AND p.particular = 'Net Profit'
ORDER BY s.fy, s.statement_type;


-- Operating Profit Margin.
SELECT
    s.fy,
    s.statement_type,
    s.value AS sales,
    o.value AS operating_profit,
    ROUND((o.value / NULLIF(s.value, 0)) * 100, 2) AS operating_profit_margin
FROM pl s
JOIN pl o
    ON s.fy = o.fy
    AND s.statement_type = o.statement_type
WHERE s.particular = 'Sales'
  AND o.particular = 'Operating Profit'
ORDER BY s.fy, s.statement_type;


-- =========================================================
-- 4. STANDALONE VS CONSOLIDATED ANALYSIS
-- =========================================================

-- Compare Standalone and Consolidated Sales.
SELECT
    fy,
    MAX(CASE WHEN statement_type = 'Standalone' THEN value END) AS standalone_sales,
    MAX(CASE WHEN statement_type = 'Consolidated' THEN value END) AS consolidated_sales
FROM pl
WHERE particular = 'Sales'
GROUP BY fy
ORDER BY fy;


-- Compare Standalone and Consolidated Net Profit.
SELECT
    fy,
    MAX(CASE WHEN statement_type = 'Standalone' THEN value END) AS standalone_profit,
    MAX(CASE WHEN statement_type = 'Consolidated' THEN value END) AS consolidated_profit
FROM pl
WHERE particular = 'Net Profit'
GROUP BY fy
ORDER BY fy;


-- =========================================================
-- 5. RATIO ANALYSIS
-- =========================================================

-- ROCE and RONW by financial year.
SELECT
    fy,
    statement_type,
    particular,
    value
FROM ratios
WHERE particular IN ('ROCE %', 'RONW %')
ORDER BY fy, statement_type, particular;


-- Debt-to-Equity ratio by financial year.
SELECT
    fy,
    statement_type,
    value AS debt_equity_ratio
FROM ratios
WHERE particular = 'Gross Debt: Equity ratio'
ORDER BY fy, statement_type;


-- Cash Conversion Cycle by financial year.
SELECT
    fy,
    statement_type,
    value AS cash_conversion_cycle
FROM ratios
WHERE particular = 'Cash Conversion Cycle'
ORDER BY fy, statement_type;


-- Simple ROCE performance classification.
SELECT
    fy,
    statement_type,
    value AS roce,
    CASE
        WHEN value >= 15 THEN 'Strong'
        WHEN value >= 10 THEN 'Average'
        ELSE 'Low'
    END AS roce_category
FROM ratios
WHERE particular = 'ROCE %'
ORDER BY fy, statement_type;


-- =========================================================
-- 6. SHAREHOLDING ANALYSIS
-- =========================================================

-- Shareholding structure by financial year.
SELECT
    fy,
    shareholder_type,
    holding_pct
FROM sh
ORDER BY fy, shareholder_type;


-- =========================================================
-- 7. POWER BI VIEWS
-- =========================================================

-- Clean P&L output for Power BI.
CREATE OR REPLACE VIEW vw_pl_analysis AS
SELECT
    s.fy,
    s.statement_type,
    s.value AS sales,
    p.value AS net_profit,
    ROUND((p.value / NULLIF(s.value, 0)) * 100, 2) AS net_profit_margin
FROM pl s
JOIN pl p
    ON s.fy = p.fy
    AND s.statement_type = p.statement_type
WHERE s.particular = 'Sales'
  AND p.particular = 'Net Profit';


-- Clean ratio output for Power BI.
CREATE OR REPLACE VIEW vw_ratio_analysis AS
SELECT
    fy,
    statement_type,
    MAX(CASE WHEN particular = 'ROCE %' THEN value END) AS roce,
    MAX(CASE WHEN particular = 'RONW %' THEN value END) AS ronw,
    MAX(CASE WHEN particular = 'Gross Debt: Equity ratio' THEN value END) AS debt_equity_ratio,
    MAX(CASE WHEN particular = 'Cash Conversion Cycle' THEN value END) AS cash_conversion_cycle
FROM ratios
GROUP BY fy, statement_type;


-- Check the P&L view.
SELECT *
FROM vw_pl_analysis
ORDER BY fy, statement_type;


-- Check the ratio view.
SELECT *
FROM vw_ratio_analysis
ORDER BY fy, statement_type;


-- =========================================================
-- END OF PROJECT SQL
-- =========================================================
