-- Created stored procedure for loading silver layer
CREATE OR ALTER PROCEDURE silver.load_silver 
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Variables for timing and logging
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME;
    DECLARE @rows_processed INT = 0;
    
    SET @batch_start_time = GETDATE();
    
    BEGIN TRY
        
        -- =====================================================
        -- 1. LOAD CUSTOMERS
        -- =====================================================
        SET @start_time = GETDATE();
        PRINT '========================================';
        PRINT '>> Starting Silver Layer ETL Pipeline';
        PRINT '========================================';
        PRINT '';
        PRINT '[1/5] Processing Customers';
        
        TRUNCATE TABLE silver.customers;
        
        INSERT INTO silver.customers (
            Customer_ID,
            Company_Name,
            Industry,
            Segment,
            Region,
            State,
            Credit_limit_USD,
            Payment_Terms,
            Account_Manager,
            Email,
            Acquisition_Date,
            Status
        )
        SELECT 
            Customer_ID,
            Company_Name,
            Industry,
            Segment,
            Region,
            -- Expand state codes to full names
            CASE State 
                WHEN 'NY' THEN 'New York (NY)'
                WHEN 'CA' THEN 'California (CA)'
                WHEN 'TX' THEN 'Texas (TX)'
                WHEN 'IL' THEN 'Illinois (IL)'
                WHEN 'FL' THEN 'Florida (FL)'
                WHEN 'WA' THEN 'Washington (WA)'
                WHEN 'MA' THEN 'Massachusetts (MA)'
                WHEN 'PA' THEN 'Pennsylvania (PA)'
                WHEN 'GA' THEN 'Georgia (GA)'
                WHEN 'NC' THEN 'North Carolina (NC)'
                WHEN 'MI' THEN 'Michigan (MI)'
                WHEN 'OH' THEN 'Ohio (OH)'
                ELSE State  -- Keeps original if not in list
            END AS State,
            Credit_limit_USD,
            Payment_Terms,
            Account_Manager,
            Email,
            Acquisition_Date,
            Status
        FROM (
            -- Removed duplicates: keeps the first occurrences
            SELECT *, 
                ROW_NUMBER() OVER(PARTITION BY Customer_ID ORDER BY Customer_ID) AS rn 
            FROM bronze.customers
        ) t
        WHERE rn = 1;
        
        SET @rows_processed = @@ROWCOUNT;
        PRINT ' Customers loaded: ' + CAST(@rows_processed AS VARCHAR) + ' rows';
        PRINT ' Duration: ' + CAST(DATEDIFF(SECOND, @start_time, GETDATE()) AS VARCHAR) + ' seconds';
        PRINT '';
        
        -- =====================================================
        -- 2. LOAD EMPLOYEES
        -- =====================================================
        SET @start_time = GETDATE();
        PRINT '[2/5] Processing Employees';
        
        TRUNCATE TABLE silver.employees;
        
        INSERT INTO silver.employees (
            Employee_ID,
            First_Name,
            Last_Name,
            Email,
            Department,
            Title,
            Hire_Date,
            Manager_ID,
            Office_Location,
            Employment_Status
        )
        SELECT 
            Employee_ID,
            First_Name,
            Last_Name,
            Email,
            Department,
            Title,
            Hire_Date,
            COALESCE(Manager_ID, 'No Manager') AS Manager_ID,     -- Replacing  Null Values
            Office_Location,
            Employment_Status
        FROM bronze.employees;
        
        SET @rows_processed = @@ROWCOUNT;
        PRINT 'Employees loaded: ' + CAST(@rows_processed AS VARCHAR) + ' rows';
        PRINT 'Duration: ' + CAST(DATEDIFF(SECOND, @start_time, GETDATE()) AS VARCHAR) + ' seconds';
        PRINT '';
        
        -- =====================================================
        -- 3. LOAD PRODUCTS
        -- =====================================================
        SET @start_time = GETDATE();
        PRINT '[3/5] Processing Products';
        
        TRUNCATE TABLE silver.products;
        
        -- Calculate average margin by category and brand
        WITH AvgMargin AS (
            SELECT 
                Category,
                Brand,
                ROUND(AVG(Unit_Price_USD - Unit_Cost_USD), 2) AS Avg_Margin   -- Calculating avgerage margin by category for each brand
            FROM bronze.products
            WHERE Unit_Price_USD > Unit_Cost_USD  -- Checking Pricing inconsistencies
            GROUP BY Category, Brand
        )
        INSERT INTO silver.products (
            Product_ID,
            SKU,
            UPC,
            Product_Name,
            Category,
            Brand,
            Unit_Cost_USD,
            Unit_Price_USD,
            Supplier_ID,
            Stock_Status,
            Warranty_Months
        )
        SELECT 
            Product_ID, 
            SKU, 
            UPC, 
            Product_Name, 
            Category, 
            Brand, 
            Unit_Cost_USD,
            -- Fixing pricing errors: if price < cost, use cost + avg margin
            CASE 
                WHEN Unit_Price_USD <= Unit_Cost_USD 
                THEN Unit_Cost_USD + COALESCE(Avg_Margin,0)
                ELSE Unit_Price_USD 
            END AS Unit_Price_USD,
            Supplier_ID,
            Stock_Status,
            Warranty_Months
        FROM (SELECT p.*,m.Avg_Margin,ROW_NUMBER() OVER (PARTITION BY Product_ID ORDER BY Product_ID)AS flag FROM bronze.products p
        LEFT JOIN AvgMargin m 
            ON p.Category = m.Category 
            AND p.Brand = m.Brand)t 
        WHERE flag=1;
        
        SET @rows_processed = @@ROWCOUNT;
        PRINT 'Products loaded: ' + CAST(@rows_processed AS VARCHAR) + ' rows';
        PRINT 'Duration: ' + CAST(DATEDIFF(SECOND, @start_time, GETDATE()) AS VARCHAR) + ' seconds';
        PRINT '';
        
        -- =====================================================
        -- 4. LOAD SUPPLIERS
        -- =====================================================
        SET @start_time = GETDATE();
        PRINT '[4/5] Processing Suppliers';
        
        
        TRUNCATE TABLE silver.suppliers;

        WITH Imputation AS (
           SELECT 
            AVG(Supplier_Rating) as Avg_Rating, -- Finding avg rating for imputation
            (SELECT TOP(1) City FROM bronze.dim_suppliers GROUP BY City ORDER BY COUNT(*) DESC) as Mode_City  --- Finding Mode
            FROM bronze.suppliers)

        INSERT INTO silver.suppliers(
            Supplier_ID,
            Supplier_Name,
            Category,
            City,
            Lead_Time_Days,
            Payment_Terms,
            Supplier_Rating,
            Active_Status)
        
        SELECT 
            s.Supplier_ID,
            s.Supplier_Name,
            s.Category,
            COALESCE(s.City, i.Mode_City) AS City,  --- imputing null city with mode
            s.Lead_Time_Days,
            s.Payment_Terms,
            COALESCE(s.Supplier_Rating, i.Avg_Rating) AS Supplier_Rating,   --- imputing null rating with mean value
            s.Active_Status
        FROM bronze.suppliers s
        CROSS JOIN Imputation i;
        
        SET @rows_processed = @@ROWCOUNT;
        PRINT 'Suppliers loaded: ' + CAST(@rows_processed AS VARCHAR) + ' rows';
        PRINT 'Duration: ' + CAST(DATEDIFF(SECOND, @start_time, GETDATE()) AS VARCHAR) + ' seconds';
        PRINT '';
        
        -- =====================================================
        -- 5. LOAD ORDERS
        -- =====================================================
        SET @start_time = GETDATE();
        PRINT '[5/5] Processing Orders';
        
        TRUNCATE TABLE silver.orders
        
        INSERT INTO silver.orders (
            Order_ID,
            Order_Date,
            Customer_ID,
            Product_ID,
            Quantity,
            Unit_Price_USD,
            Subtotal_USD,
            Discount_Percent,
            Discount_Amount_USD,
            Tax_Amount_USD,
            Total_Amount_USD,
            Order_Status,
            Payment_Method,
            Sales_Employee_ID,
            Ship_Date,
            Delivery_Date
        )
        SELECT
            o.Order_ID,
            o.Order_Date,
            o.Customer_ID,
            o.Product_ID,
            ABS(o.Quantity) AS Quantity,  -- Fixed negative quantities
            o.Unit_Price_USD,
            ABS(o.Subtotal_USD) AS Subtotal_USD,   -- Fixed negative subtotals
            o.Discount_Percent,
            o.Discount_Amount_USD,
            o.Tax_Amount_USD,
            o.Total_Amount_USD,
            o.Order_Status,
            o.Payment_Method,
            o.Sales_Employee_ID,
            o.Ship_Date,
            CASE WHEN o.Delivery_Date<o.Ship_Date THEN DATEADD(DAY,5,o.Ship_Date) 
            ELSE o.Delivery_Date END AS Delivery_Date  --- Handling date inconsistencies
        FROM (
    SELECT 
        *,
        ROW_NUMBER() OVER(PARTITION BY Order_ID ORDER BY Order_Date DESC) as flag -- flagging duplicate order ID's 
    FROM bronze.orders
) o
        WHERE o.flag=1 AND  
            o.Order_Date BETWEEN '2023-01-01'AND'2023-12-28'
            AND o.Quantity <> 0  
            AND o.Customer_ID IN (SELECT Customer_ID FROM silver.customers)  -- Valid customers only
            AND o.Product_ID IN (SELECT Product_ID FROM silver.products)  -- Valid products only
            AND o.Sales_Employee_ID IN (SELECT Employee_ID FROM silver.employees);  -- Valid employees only
        
        

        SET @rows_processed = @@ROWCOUNT;
        PRINT 'Orders loaded: ' + CAST(@rows_processed AS VARCHAR) + ' rows';
        PRINT 'Duration: ' + CAST(DATEDIFF(SECOND, @start_time, GETDATE()) AS VARCHAR) + ' seconds';
        PRINT '';
        
        -- =====================================================
        -- SUMMARY
        -- =====================================================
        SET @end_time = GETDATE();
        PRINT '========================================';
        PRINT '>> Silver Layer ETL Complete!';
        PRINT '   Total Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @end_time) AS VARCHAR) + ' seconds';
        PRINT '========================================';
        PRINT '';
        
        -- Show row counts
        PRINT 'Final Row Counts:';
        PRINT '-------------------------------------------';
        SELECT 
            'customers' AS Table_Name, 
            COUNT(*) AS Row_Count 
        FROM silver.customers
        UNION ALL
        SELECT 'employees', COUNT(*) FROM silver.employees
        UNION ALL
        SELECT 'products', COUNT(*) FROM silver.products
        UNION ALL
        SELECT 'suppliers', COUNT(*) FROM silver.suppliers
        UNION ALL
        SELECT 'orders', COUNT(*) FROM silver.orders;
        
    END TRY
    BEGIN CATCH
        -- Simple error handling
        PRINT '';
        PRINT '========================================';
        PRINT '>> ERROR OCCURRED!';
        PRINT '>> Error Message: ' + ERROR_MESSAGE();
        PRINT '>> Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
        PRINT '========================================';
    END CATCH
END;
GO

-- =====================================================
-- EXECUTE THE PROCEDURE
-- =====================================================

EXEC silver.load_silver;
GO


