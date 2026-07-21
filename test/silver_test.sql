-- Silver Layer Data Quality Tests
-- Run after: EXEC silver.load_silver

PRINT '================================================';
PRINT 'Silver Layer Data Quality Tests';
PRINT '================================================';

-- =====================================================
-- TEST 1: Check for NULL primary keys
-- =====================================================
PRINT '';
PRINT 'TEST 1: NULL Primary Keys';
PRINT '----------------------------------------------------';

-- Test crm_cust_info: cst_id should not be NULL
IF EXISTS (SELECT 1 FROM silver.crm_cust_info WHERE cst_id IS NULL)
    PRINT 'FAIL: crm_cust_info has NULL cst_id values';
ELSE
    PRINT 'PASS: crm_cust_info has no NULL cst_id values';

-- Test crm_prd_info: prd_id should not be NULL
IF EXISTS (SELECT 1 FROM silver.crm_prd_info WHERE prd_id IS NULL)
    PRINT 'FAIL: crm_prd_info has NULL prd_id values';
ELSE
    PRINT 'PASS: crm_prd_info has no NULL prd_id values';

-- Test crm_sales_details: sls_ord_num should not be NULL
IF EXISTS (SELECT 1 FROM silver.crm_sales_details WHERE sls_ord_num IS NULL)
    PRINT 'FAIL: crm_sales_details has NULL sls_ord_num values';
ELSE
    PRINT 'PASS: crm_sales_details has no NULL sls_ord_num values';

-- =====================================================
-- TEST 2: Check for duplicate primary keys
-- =====================================================
PRINT '';
PRINT 'TEST 2: Duplicate Primary Keys';
PRINT '----------------------------------------------------';

-- Test crm_cust_info: cst_id should be unique
IF EXISTS (
    SELECT cst_id, COUNT(*) AS cnt
    FROM silver.crm_cust_info
    GROUP BY cst_id
    HAVING COUNT(*) > 1
)
    PRINT 'FAIL: crm_cust_info has duplicate cst_id values';
ELSE
    PRINT 'PASS: crm_cust_info has unique cst_id values';

-- Test crm_prd_info: prd_id should be unique
IF EXISTS (
    SELECT prd_id, COUNT(*) AS cnt
    FROM silver.crm_prd_info
    GROUP BY prd_id
    HAVING COUNT(*) > 1
)
    PRINT 'FAIL: crm_prd_info has duplicate prd_id values';
ELSE
    PRINT 'PASS: crm_prd_info has unique prd_id values';

-- =====================================================
-- TEST 3: Check normalized values
-- =====================================================
PRINT '';
PRINT 'TEST 3: Normalized Values';
PRINT '----------------------------------------------------';

-- Test crm_cust_info: cst_marital_status should be normalized
IF EXISTS (
    SELECT 1 FROM silver.crm_cust_info
    WHERE cst_marital_status NOT IN ('Single', 'Married', 'n/a')
)
    PRINT 'FAIL: crm_cust_info has unnormalized marital status values';
ELSE
    PRINT 'PASS: crm_cust_info marital status values are normalized';

-- Test crm_cust_info: cst_gndr should be normalized
IF EXISTS (
    SELECT 1 FROM silver.crm_cust_info
    WHERE cst_gndr NOT IN ('Female', 'Male', 'n/a')
)
    PRINT 'FAIL: crm_cust_info has unnormalized gender values';
ELSE
    PRINT 'PASS: crm_cust_info gender values are normalized';

-- Test crm_prd_info: prd_line should be normalized
IF EXISTS (
    SELECT 1 FROM silver.crm_prd_info
    WHERE prd_line NOT IN ('Mountain', 'Road', 'Other Sales', 'Touring', 'n/a')
)
    PRINT 'FAIL: crm_prd_info has unnormalized product line values';
ELSE
    PRINT 'PASS: crm_prd_info product line values are normalized';

-- Test erp_cust_az12: gen should be normalized
IF EXISTS (
    SELECT 1 FROM silver.erp_cust_az12
    WHERE gen NOT IN ('Female', 'Male', 'n/a')
)
    PRINT 'FAIL: erp_cust_az12 has unnormalized gender values';
ELSE
    PRINT 'PASS: erp_cust_az12 gender values are normalized';

-- Test erp_loc_a101: cntry should be normalized
IF EXISTS (
    SELECT 1 FROM silver.erp_loc_a101
    WHERE cntry IN ('DE', 'US', 'USA')
)
    PRINT 'FAIL: erp_loc_a101 has unnormalized country codes';
ELSE
    PRINT 'PASS: erp_loc_a101 country values are normalized';

-- =====================================================
-- TEST 4: Check date validity
-- =====================================================
PRINT '';
PRINT 'TEST 4: Date Validity';
PRINT '----------------------------------------------------';

-- Test erp_cust_az12: bdate should not be in the future
IF EXISTS (
    SELECT 1 FROM silver.erp_cust_az12
    WHERE bdate > GETDATE()
)
    PRINT 'FAIL: erp_cust_az12 has future birthdates';
ELSE
    PRINT 'PASS: erp_cust_az12 has no future birthdates';

-- Test crm_sales_details: sls_order_dt should not be in the future (for most cases)
-- Note: This is a soft check as some test data may have future dates
DECLARE @future_orders INT;
SELECT @future_orders = COUNT(*)
FROM silver.crm_sales_details
WHERE sls_order_dt > GETDATE();

PRINT 'INFO: crm_sales_details has ' + CAST(@future_orders AS NVARCHAR) + ' orders with future dates';

-- =====================================================
-- TEST 5: Check data completeness
-- =====================================================
PRINT '';
PRINT 'TEST 5: Data Completeness';
PRINT '----------------------------------------------------';

-- Count records in each table
DECLARE @cnt INT;

SELECT @cnt = COUNT(*) FROM silver.crm_cust_info;
PRINT 'crm_cust_info: ' + CAST(@cnt AS NVARCHAR) + ' records';

SELECT @cnt = COUNT(*) FROM silver.crm_prd_info;
PRINT 'crm_prd_info: ' + CAST(@cnt AS NVARCHAR) + ' records';

SELECT @cnt = COUNT(*) FROM silver.crm_sales_details;
PRINT 'crm_sales_details: ' + CAST(@cnt AS NVARCHAR) + ' records';

SELECT @cnt = COUNT(*) FROM silver.erp_loc_a101;
PRINT 'erp_loc_a101: ' + CAST(@cnt AS NVARCHAR) + ' records';

SELECT @cnt = COUNT(*) FROM silver.erp_cust_az12;
PRINT 'erp_cust_az12: ' + CAST(@cnt AS NVARCHAR) + ' records';

SELECT @cnt = COUNT(*) FROM silver.erp_px_cat_g1v2;
PRINT 'erp_px_cat_g1v2: ' + CAST(@cnt AS NVARCHAR) + ' records';

-- =====================================================
-- TEST 6: Check for empty strings where NULL expected
-- =====================================================
PRINT '';
PRINT 'TEST 6: Empty String Handling';
PRINT '----------------------------------------------------';

-- Test erp_loc_a101: blank country should be 'n/a'
IF EXISTS (
    SELECT 1 FROM silver.erp_loc_a101
    WHERE cntry = ''
)
    PRINT 'FAIL: erp_loc_a101 has empty string country values';
ELSE
    PRINT 'PASS: erp_loc_a101 has no empty string country values';

-- =====================================================
-- TEST 7: Check referential integrity (basic)
-- =====================================================
PRINT '';
PRINT 'TEST 7: Referential Integrity (Basic)';
PRINT '----------------------------------------------------';

-- Check if sales Cust IDs exist in customer table
DECLARE @orphan_sales INT;
SELECT @orphan_sales = COUNT(*)
FROM silver.crm_sales_details s
LEFT JOIN silver.crm_cust_info c ON s.sls_cust_id = c.cst_id
WHERE c.cst_id IS NULL;

IF @orphan_sales > 0
    PRINT 'WARN: crm_sales_details has ' + CAST(@orphan_sales AS NVARCHAR) + ' records with no matching customer';
ELSE
    PRINT 'PASS: crm_sales_details has valid customer references';

-- =====================================================
-- TEST 8: Check dwh_create_date is populated
-- =====================================================
PRINT '';
PRINT 'TEST 8: Audit Column populated';
PRINT '----------------------------------------------------';

IF EXISTS (SELECT 1 FROM silver.crm_cust_info WHERE dwh_create_date IS NULL)
    PRINT 'FAIL: crm_cust_info has NULL dwh_create_date';
ELSE
    PRINT 'PASS: crm_cust_info dwh_create_date is populated';

IF EXISTS (SELECT 1 FROM silver.crm_prd_info WHERE dwh_create_date IS NULL)
    PRINT 'FAIL: crm_prd_info has NULL dwh_create_date';
ELSE
    PRINT 'PASS: crm_prd_info dwh_create_date is populated';

-- =====================================================
-- SUMMARY
-- =====================================================
PRINT '';
PRINT '================================================';
PRINT 'Silver Layer Tests Completed';
PRINT '================================================';
