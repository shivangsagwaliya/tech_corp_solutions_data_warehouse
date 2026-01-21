CREATE OR ALTER PROCEDURE bronze.load_bronze 
AS 
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME;
    SET @batch_start_time = GETDATE();
    
    BEGIN TRY
        PRINT '========================================';
        PRINT '>> Loading Bronze Layer (Raw Data)';
        PRINT '========================================';
        PRINT '';
        
        -- =====================================================
        -- 1. LOAD CUSTOMERS
        -- =====================================================
        SET @start_time = GETDATE();
        PRINT '[1/5] Loading bronze.dim_customers';
        
        TRUNCATE TABLE bronze.dim_customers;
        
        BULK INSERT bronze.dim_customers
        FROM 'C:\Users\hp\Downloads\cloud_data\PROJECT\dim_customers.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );
        
        SET @end_time = GETDATE();
        PRINT '>> Loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
        PRINT '>> Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        PRINT '';
        
        -- =====================================================
        -- 2. LOAD EMPLOYEES
        -- =====================================================
        SET @start_time = GETDATE();
        PRINT '[2/5] Loading bronze.dim_employees';
        
        TRUNCATE TABLE bronze.dim_employees;
        
        BULK INSERT bronze.dim_employees
        FROM 'C:\Users\hp\Downloads\cloud_data\PROJECT\dim_employees.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );
        
        SET @end_time = GETDATE();
        PRINT '>>  Loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
        PRINT '>> Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        PRINT '';
        
        -- =====================================================
        -- 3. LOAD PRODUCTS
        -- =====================================================
        SET @start_time = GETDATE();
        PRINT '[3/5] Loading bronze.dim_products';
        
        TRUNCATE TABLE bronze.dim_products;
        
        BULK INSERT bronze.dim_products
        FROM 'C:\Users\hp\Downloads\cloud_data\PROJECT\dim_products.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );
        
        SET @end_time = GETDATE();
        PRINT '>>  Loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
        PRINT '>> Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        PRINT '';
        
        -- =====================================================
        -- 4. LOAD SUPPLIERS
        -- =====================================================
        SET @start_time = GETDATE();
        PRINT '[4/5] Loading bronze.dim_suppliers';
        
        TRUNCATE TABLE bronze.dim_suppliers;
        
        BULK INSERT bronze.dim_suppliers
        FROM 'C:\Users\hp\Downloads\cloud_data\PROJECT\dim_suppliers.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );
        
        SET @end_time = GETDATE();
        PRINT '>> Loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
        PRINT '>> Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        PRINT '';

        
        -- =====================================================
        -- 5. LOAD ORDERS
        -- =====================================================
        SET @start_time = GETDATE();
        PRINT '[5/5] Loading bronze.fact_orders';
        
        TRUNCATE TABLE bronze.fact_orders;
        
        BULK INSERT bronze.fact_orders
        FROM 'C:\Users\hp\Downloads\cloud_data\PROJECT\fact_orders.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );
        
        SET @end_time = GETDATE();
        PRINT '>> Loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
        PRINT '>> Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        PRINT '';
        
        -- =====================================================
        -- SUMMARY
        -- =====================================================
        PRINT '========================================';
        PRINT '>> Bronze Layer Load Complete!';
        PRINT '   Total Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, GETDATE()) AS VARCHAR) + ' seconds';
        PRINT '========================================';
        PRINT '';
        
        -- Show final row counts
        PRINT 'Bronze Layer Row Counts:';
        PRINT '-------------------------------------------';
        SELECT 
            'dim_customers' AS Table_Name, 
            COUNT(*) AS Row_Count 
        FROM bronze.dim_customers
        UNION ALL
        SELECT 'dim_employees', COUNT(*) FROM bronze.dim_employees
        UNION ALL
        SELECT 'dim_products', COUNT(*) FROM bronze.dim_products
        UNION ALL
        SELECT 'dim_suppliers', COUNT(*) FROM bronze.dim_suppliers
        UNION ALL
        SELECT 'fact_orders', COUNT(*) FROM bronze.fact_orders;
        
    END TRY
    BEGIN CATCH
        PRINT '';
        PRINT '========================================';
        PRINT '>> ERROR OCCURRED DURING LOADING!';
        PRINT '>> Error Message: ' + ERROR_MESSAGE();
        PRINT '>> Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT '>> Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
        PRINT '>> Error State: ' + CAST(ERROR_STATE() AS VARCHAR);
        PRINT '========================================';
    END CATCH
END;
GO
-- =====================================================
-- EXECUTE BRONZE LAYER LOAD
-- =====================================================

EXEC bronze.load_bronze;
GO