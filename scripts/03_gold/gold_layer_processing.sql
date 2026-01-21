/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- 1. Create Dimension: gold.dim_customers
-- =============================================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
    Customer_ID          AS customer_id,
    Company_Name         AS company_name,
    Industry             AS industry,
    Segment              AS segment,
    Region               AS region,
    State                AS state,
    Credit_Limit_USD     AS credit_limit,
    Payment_Terms        AS payment_terms,
    Account_Manager      AS account_manager,
    Email                AS email,
    Acquisition_Date     AS acquisition_date,
    Status               AS status
FROM silver.customers;
GO

-- =============================================================================
-- 2. Create Dimension: gold.dim_products
-- =============================================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS 
SELECT 
    Product_ID          AS product_id,
    SKU                 AS sku,
    UPC                 AS upc,
    Product_Name        AS product_name,
    Category            AS category,
    Brand               AS brand,
    Unit_Cost_USD       AS unit_cost,
    Unit_Price_USD      AS unit_price,
    Supplier_ID         AS supplier_id,
    Stock_Status        AS stock_status,
    Warranty_Months     AS warranty
FROM silver.products;
GO

-- =============================================================================
-- 3. Create Dimension: gold.dim_suppliers
-- =============================================================================
IF OBJECT_ID('gold.dim_suppliers', 'V') IS NOT NULL
    DROP VIEW gold.dim_suppliers;
GO

CREATE VIEW gold.dim_suppliers AS
SELECT 
    Supplier_ID         AS supplier_id,
    Category            AS category,
    City                AS city,
    Country             AS country,
    Lead_Time_Days      AS lead_time_days,
    Payment_Terms       AS payment_terms,
    Supplier_Rating     AS supplier_rating,
    Active_Status       AS active_status
FROM silver.suppliers;
GO

-- =============================================================================
-- 4. Create Dimension: gold.dim_employees
-- =============================================================================
IF OBJECT_ID('gold.dim_employees', 'V') IS NOT NULL
    DROP VIEW gold.dim_employees;
GO

CREATE VIEW gold.dim_employees AS
SELECT 
    Employee_ID                             AS employee_id,
    CONCAT(First_Name, ' ', Last_Name)      AS employee_name,
    Email                                   AS email,
    Department                              AS department,
    Title                                   AS title,
    Hire_Date                               AS hire_date,
    Manager_ID                              AS manager_id,
    Office_Location                         AS office_location,
    Employment_Status                       AS employment_status
FROM silver.employees;
GO

-- =============================================================================
-- 5. Create Fact: gold.fact_orders
-- =============================================================================
IF OBJECT_ID('gold.fact_orders', 'V') IS NOT NULL
    DROP VIEW gold.fact_orders;
GO

CREATE VIEW gold.fact_orders AS 
SELECT 
    o.Order_ID             AS order_id,  
    o.Order_Date           AS order_date,
    o.Customer_ID          AS customer_id,
    o.Product_ID           AS product_id,
    s.Supplier_ID          AS supplier_id,
    o.Sales_Employee_ID    AS employee_id,
    o.Quantity             AS quantity,
    o.Unit_Price_USD       AS unit_price,
    o.Subtotal_USD         AS subtotal,
    o.Discount_Percent     AS discount_percentage,
    o.Discount_Amount_USD  AS discount,
    o.Tax_Amount_USD       AS tax_amount,
    o.Total_Amount_USD     AS total_amount,
    o.Order_Status         AS order_status,
    o.Payment_Method       AS payment_method,
    o.Ship_Date            AS ship_date,
    o.Delivery_Date        AS delivery_date
FROM silver.orders o
LEFT JOIN silver.products p
    ON o.Product_ID = p.Product_ID
LEFT JOIN silver.suppliers s
    ON p.Supplier_ID = s.Supplier_ID;
GO


/*
===============================================================================
DDL Script: Create Gold Date Dimension  (Created Using Gen AI)
===============================================================================
Script Purpose:
    This script creates a robust Date Dimension view (gold.dim_date)
===============================================================================
*/

IF OBJECT_ID('gold.dim_date', 'V') IS NOT NULL
    DROP VIEW gold.dim_date;
GO

CREATE VIEW gold.dim_date AS
WITH 
    -- 1. Generate a small list of numbers (0-9)
    d0 AS (SELECT n FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) v(n)),
    
    -- 2. Cross join them to generate more numbers (10 * 10 * 10 * 10 = 10,000 days)
    -- 10,000 days is approx 27 years.
    d4 AS (
        SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
        FROM d0 t1, d0 t2, d0 t3, d0 t4
    ),

    -- 3. Calculate dates from the number list
    DateSeries AS (
        SELECT CAST(DATEADD(day, n, '2023-01-01') AS DATE) AS full_date
        FROM d4
        WHERE DATEADD(day, n, '2020-01-01') <= '2026-12-31'
    )

-- 4. Select final columns
SELECT
    CAST(CONVERT(VARCHAR(8), full_date, 112) AS INT) AS date_key,
    full_date                                       AS date,
    YEAR(full_date)                                 AS year,
    MONTH(full_date)                                AS month,
    DAY(full_date)                                  AS day,
    DATEPART(QUARTER, full_date)                    AS quarter,
    DATENAME(MONTH, full_date)                      AS month_name,
    LEFT(DATENAME(MONTH, full_date), 3)             AS month_short,
    DATENAME(WEEKDAY, full_date)                    AS day_name,
    LEFT(DATENAME(WEEKDAY, full_date), 3)           AS day_short,
    
    -- Fiscal Logic
    CASE 
        WHEN MONTH(full_date) >= 4 THEN YEAR(full_date) + 1
        ELSE YEAR(full_date) 
    END                                             AS fiscal_year,
    
    CASE 
        WHEN MONTH(full_date) >= 4 THEN MONTH(full_date) - 3
        ELSE MONTH(full_date) + 9 
    END                                             AS fiscal_month,

    -- Weekend Flag
    CASE 
        WHEN DATEPART(WEEKDAY, full_date) IN (1, 7) THEN 1 
        ELSE 0 
    END                                             AS is_weekend
FROM DateSeries;
GO
