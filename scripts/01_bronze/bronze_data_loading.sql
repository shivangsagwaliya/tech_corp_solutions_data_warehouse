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
        PRINT '[1/5] Loading bronze.customers';
        
        TRUNCATE TABLE bronze.customers;
        
        BULK INSERT bronze.customers
        FROM 'C:\Users\hp\Downloads\cloud_data\PROJECT\customers.csv'
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
        PRINT '[2/5] Loading bronze.employees';
        
        TRUNCATE TABLE bronze.employees;
        
        BULK INSERT bronze.dim_employees
        FROM 'C:\Users\hp\Downloads\cloud_data\PROJECT\employees.csv'
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
        PRINT '[3/5] Loading bronze.products';
        
        TRUNCATE TABLE bronze.products;
        
        BULK INSERT bronze.dim_products
        FROM 'C:\Users\hp\Downloads\cloud_data\PROJECT\products.csv'
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
        PRINT '[4/5] Loading bronze.suppliers';
        
        TRUNCATE TABLE bronze.suppliers;
        
        BULK INSERT bronze.suppliers
        FROM 'C:\Users\hp\Downloads\cloud_data\PROJECT\suppliers.csv'
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
        PRINT '[5/5] Loading bronze.orders';
        
        TRUNCATE TABLE bronze.orders;
        
        BULK INSERT bronze.orders
        FROM 'C:\Users\hp\Downloads\cloud_data\PROJECT\orders.csv'
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
            'customers' AS Table_Name, 
            COUNT(*) AS Row_Count 
        FROM bronze.customers
        UNION ALL
        SELECT 'employees', COUNT(*) FROM bronze.employees
        UNION ALL
        SELECT 'products', COUNT(*) FROM bronze.products
        UNION ALL
        SELECT 'suppliers', COUNT(*) FROM bronze.suppliers
        UNION ALL
        SELECT 'orders', COUNT(*) FROM bronze.orders;
        
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
