-- Silver Layer Data Quality Tests
-- Run after: EXEC silver.load_silver

-- =============================================================================
-- 1. crm_cust_info
-- =============================================================================

-- PK: no NULL cst_id
SELECT 'FAIL: crm_cust_info NULL cst_id' WHERE EXISTS (SELECT 1 FROM silver.crm_cust_info WHERE cst_id IS NULL);

-- PK: no duplicate cst_id
SELECT 'FAIL: crm_cust_info duplicate cst_id'
WHERE EXISTS (SELECT cst_id FROM silver.crm_cust_info GROUP BY cst_id HAVING COUNT(*) > 1);

-- Marital status normalized
SELECT 'FAIL: crm_cust_info unnormalized marital_status'
WHERE EXISTS (SELECT 1 FROM silver.crm_cust_info WHERE cst_marital_status NOT IN ('Single', 'Married', 'n/a'));

-- Gender normalized
SELECT 'FAIL: crm_cust_info unnormalized gender'
WHERE EXISTS (SELECT 1 FROM silver.crm_cust_info WHERE cst_gndr NOT IN ('Female', 'Male', 'n/a'));

-- First name trimmed (no leading/trailing spaces)
SELECT 'FAIL: crm_cust_info untrimmed firstname'
WHERE EXISTS (SELECT 1 FROM silver.crm_cust_info WHERE cst_firstname != TRIM(cst_firstname));

-- Last name trimmed
SELECT 'FAIL: crm_cust_info untrimmed lastname'
WHERE EXISTS (SELECT 1 FROM silver.crm_cust_info WHERE cst_lastname != TRIM(cst_lastname));

-- Audit column populated
SELECT 'FAIL: crm_cust_info NULL dwh_create_date'
WHERE EXISTS (SELECT 1 FROM silver.crm_cust_info WHERE dwh_create_date IS NULL);

-- Table has rows
SELECT 'FAIL: crm_cust_info is empty' WHERE NOT EXISTS (SELECT 1 FROM silver.crm_cust_info);

-- =============================================================================
-- 2. crm_prd_info
-- =============================================================================

-- PK: no NULL prd_id
SELECT 'FAIL: crm_prd_info NULL prd_id' WHERE EXISTS (SELECT 1 FROM silver.crm_prd_info WHERE prd_id IS NULL);

-- PK: no duplicate prd_id
SELECT 'FAIL: crm_prd_info duplicate prd_id'
WHERE EXISTS (SELECT prd_id FROM silver.crm_prd_info GROUP BY prd_id HAVING COUNT(*) > 1);

-- cat_id format: 5 chars with underscore separator
SELECT 'FAIL: crm_prd_info invalid cat_id format'
WHERE EXISTS (SELECT 1 FROM silver.crm_prd_info WHERE cat_id NOT LIKE '_____%' OR cat_id LIKE '%-%');

-- prd_line normalized
SELECT 'FAIL: crm_prd_info unnormalized prd_line'
WHERE EXISTS (SELECT 1 FROM silver.crm_prd_info WHERE prd_line NOT IN ('Mountain', 'Road', 'Other Sales', 'Touring', 'n/a'));

-- prd_cost non-negative (NULLs replaced with 0)
SELECT 'FAIL: crm_prd_info negative prd_cost'
WHERE EXISTS (SELECT 1 FROM silver.crm_prd_info WHERE prd_cost < 0);

-- prd_start_dt not NULL
SELECT 'FAIL: crm_prd_info NULL prd_start_dt'
WHERE EXISTS (SELECT 1 FROM silver.crm_prd_info WHERE prd_start_dt IS NULL);

-- prd_end_dt >= prd_start_dt (where both exist)
SELECT 'FAIL: crm_prd_info end before start'
WHERE EXISTS (SELECT 1 FROM silver.crm_prd_info WHERE prd_end_dt IS NOT NULL AND prd_end_dt < prd_start_dt);

-- Audit column populated
SELECT 'FAIL: crm_prd_info NULL dwh_create_date'
WHERE EXISTS (SELECT 1 FROM silver.crm_prd_info WHERE dwh_create_date IS NULL);

-- =============================================================================
-- 3. crm_sales_details
-- =============================================================================

-- sls_ord_num not NULL
SELECT 'FAIL: crm_sales_details NULL sls_ord_num'
WHERE EXISTS (SELECT 1 FROM silver.crm_sales_details WHERE sls_ord_num IS NULL);

-- sls_sales positive
SELECT 'FAIL: crm_sales_details non-positive sales'
WHERE EXISTS (SELECT 1 FROM silver.crm_sales_details WHERE sls_sales <= 0);

-- sls_price positive
SELECT 'FAIL: crm_sales_details non-positive price'
WHERE EXISTS (SELECT 1 FROM silver.crm_sales_details WHERE sls_price <= 0);

-- sls_quantity positive
SELECT 'FAIL: crm_sales_details non-positive quantity'
WHERE EXISTS (SELECT 1 FROM silver.crm_sales_details WHERE sls_quantity <= 0);

-- sales = quantity × price (consistency check)
SELECT 'FAIL: crm_sales_details sales != quantity * price'
WHERE EXISTS (
    SELECT 1 FROM silver.crm_sales_details
    WHERE sls_sales != sls_quantity * sls_price
);

-- sls_order_dt not NULL
SELECT 'FAIL: crm_sales_details NULL order_dt'
WHERE EXISTS (SELECT 1 FROM silver.crm_sales_details WHERE sls_order_dt IS NULL);

-- sls_ship_dt >= sls_order_dt
SELECT 'FAIL: crm_sales_details ship before order'
WHERE EXISTS (
    SELECT 1 FROM silver.crm_sales_details
    WHERE sls_ship_dt IS NOT NULL AND sls_order_dt IS NOT NULL AND sls_ship_dt < sls_order_dt
);

-- Audit column populated
SELECT 'FAIL: crm_sales_details NULL dwh_create_date'
WHERE EXISTS (SELECT 1 FROM silver.crm_sales_details WHERE dwh_create_date IS NULL);

-- =============================================================================
-- 4. erp_cust_az12
-- =============================================================================

-- No 'NAS' prefix remaining in cid
SELECT 'FAIL: erp_cust_az12 NAS prefix not removed'
WHERE EXISTS (SELECT 1 FROM silver.erp_cust_az12 WHERE cid LIKE 'NAS%');

-- No future birthdates
SELECT 'FAIL: erp_cust_az12 future birthdate'
WHERE EXISTS (SELECT 1 FROM silver.erp_cust_az12 WHERE bdate > GETDATE());

-- Gender normalized
SELECT 'FAIL: erp_cust_az12 unnormalized gender'
WHERE EXISTS (SELECT 1 FROM silver.erp_cust_az12 WHERE gen NOT IN ('Female', 'Male', 'n/a'));

-- Audit column populated
SELECT 'FAIL: erp_cust_az12 NULL dwh_create_date'
WHERE EXISTS (SELECT 1 FROM silver.erp_cust_az12 WHERE dwh_create_date IS NULL);

-- cid not NULL
SELECT 'FAIL: erp_cust_az12 NULL cid'
WHERE EXISTS (SELECT 1 FROM silver.erp_cust_az12 WHERE cid IS NULL);

-- cid not empty string
SELECT 'FAIL: erp_cust_az12 empty cid'
WHERE EXISTS (SELECT 1 FROM silver.erp_cust_az12 WHERE cid = '');

-- No duplicate cid
SELECT 'FAIL: erp_cust_az12 duplicate cid'
WHERE EXISTS (SELECT cid FROM silver.erp_cust_az12 GROUP BY cid HAVING COUNT(*) > 1);

-- Table has rows
SELECT 'FAIL: erp_cust_az12 is empty' WHERE NOT EXISTS (SELECT 1 FROM silver.erp_cust_az12);

-- =============================================================================
-- 5. erp_loc_a101
-- =============================================================================

-- No dashes in cid
SELECT 'FAIL: erp_loc_a101 dash in cid'
WHERE EXISTS (SELECT 1 FROM silver.erp_loc_a101 WHERE cid LIKE '%-%');

-- Country normalized (no raw codes like DE, US, USA)
SELECT 'FAIL: erp_loc_a101 unnormalized country'
WHERE EXISTS (SELECT 1 FROM silver.erp_loc_a101 WHERE cntry IN ('DE', 'US', 'USA'));

-- No empty string country (should be 'n/a')
SELECT 'FAIL: erp_loc_a101 empty country'
WHERE EXISTS (SELECT 1 FROM silver.erp_loc_a101 WHERE cntry = '');

-- Audit column populated
SELECT 'FAIL: erp_loc_a101 NULL dwh_create_date'
WHERE EXISTS (SELECT 1 FROM silver.erp_loc_a101 WHERE dwh_create_date IS NULL);

-- cid not NULL
SELECT 'FAIL: erp_loc_a101 NULL cid'
WHERE EXISTS (SELECT 1 FROM silver.erp_loc_a101 WHERE cid IS NULL);

-- cid not empty string
SELECT 'FAIL: erp_loc_a101 empty cid'
WHERE EXISTS (SELECT 1 FROM silver.erp_loc_a101 WHERE cid = '');

-- No duplicate cid
SELECT 'FAIL: erp_loc_a101 duplicate cid'
WHERE EXISTS (SELECT cid FROM silver.erp_loc_a101 GROUP BY cid HAVING COUNT(*) > 1);

-- Table has rows
SELECT 'FAIL: erp_loc_a101 is empty' WHERE NOT EXISTS (SELECT 1 FROM silver.erp_loc_a101);

-- =============================================================================
-- 6. erp_px_cat_g1v2
-- =============================================================================

-- id not NULL
SELECT 'FAIL: erp_px_cat_g1v2 NULL id'
WHERE EXISTS (SELECT 1 FROM silver.erp_px_cat_g1v2 WHERE id IS NULL);

-- cat not NULL
SELECT 'FAIL: erp_px_cat_g1v2 NULL cat'
WHERE EXISTS (SELECT 1 FROM silver.erp_px_cat_g1v2 WHERE cat IS NULL);

-- subcat not NULL
SELECT 'FAIL: erp_px_cat_g1v2 NULL subcat'
WHERE EXISTS (SELECT 1 FROM silver.erp_px_cat_g1v2 WHERE subcat IS NULL);

-- maintenance not NULL
SELECT 'FAIL: erp_px_cat_g1v2 NULL maintenance'
WHERE EXISTS (SELECT 1 FROM silver.erp_px_cat_g1v2 WHERE maintenance IS NULL);

-- No duplicate id
SELECT 'FAIL: erp_px_cat_g1v2 duplicate id'
WHERE EXISTS (SELECT id FROM silver.erp_px_cat_g1v2 GROUP BY id HAVING COUNT(*) > 1);

-- Audit column populated
SELECT 'FAIL: erp_px_cat_g1v2 NULL dwh_create_date'
WHERE EXISTS (SELECT 1 FROM silver.erp_px_cat_g1v2 WHERE dwh_create_date IS NULL);

-- id not empty string
SELECT 'FAIL: erp_px_cat_g1v2 empty id'
WHERE EXISTS (SELECT 1 FROM silver.erp_px_cat_g1v2 WHERE id = '');

-- Table has rows
SELECT 'FAIL: erp_px_cat_g1v2 is empty' WHERE NOT EXISTS (SELECT 1 FROM silver.erp_px_cat_g1v2);

-- =============================================================================
-- Cross-table: Referential Integrity
-- =============================================================================

-- Sales cust_id references valid customer
SELECT 'FAIL: crm_sales_details orphan cust_id (no matching customer)'
FROM silver.crm_sales_details s
LEFT JOIN silver.crm_cust_info c ON s.sls_cust_id = c.cst_id
WHERE c.cst_id IS NULL;

-- Sales prd_key references valid product
SELECT 'FAIL: crm_sales_details orphan prd_key (no matching product)'
FROM silver.crm_sales_details s
LEFT JOIN silver.crm_prd_info p ON s.sls_prd_key = p.prd_key
WHERE p.prd_key IS NULL;

-- erp_cust_az12 cid matches crm_cust_info cst_key
SELECT 'FAIL: erp_cust_az12 cid not found in crm_cust_info'
FROM silver.erp_cust_az12 e
LEFT JOIN silver.crm_cust_info c ON e.cid = c.cst_key
WHERE c.cst_key IS NULL;

-- erp_loc_a101 cid matches crm_cust_info cst_key
SELECT 'FAIL: erp_loc_a101 cid not found in crm_cust_info'
FROM silver.erp_loc_a101 e
LEFT JOIN silver.crm_cust_info c ON e.cid = c.cst_key
WHERE c.cst_key IS NULL;

-- crm_prd_info cat_id matches erp_px_cat_g1v2 id
SELECT 'FAIL: crm_prd_info cat_id not found in erp_px_cat_g1v2'
FROM silver.crm_prd_info p
LEFT JOIN silver.erp_px_cat_g1v2 e ON p.cat_id = e.id
WHERE e.id IS NULL;

-- =============================================================================
-- End of Tests (48 checks)
-- =============================================================================
