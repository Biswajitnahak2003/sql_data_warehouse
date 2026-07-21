-- Gold Layer Data Quality Tests
-- Run after gold views are created

-- =============================================================================
-- 1. dim_customers
-- =============================================================================

-- No duplicate customer_key
SELECT 'FAIL: dim_customers duplicate customer_key'
WHERE EXISTS (SELECT customer_key FROM gold.dim_customers GROUP BY customer_key HAVING COUNT(*) > 1);

-- No NULL customer_key
SELECT 'FAIL: dim_customers NULL customer_key'
WHERE EXISTS (SELECT 1 FROM gold.dim_customers WHERE customer_key IS NULL);

-- No NULL customer_id
SELECT 'FAIL: dim_customers NULL customer_id'
WHERE EXISTS (SELECT 1 FROM gold.dim_customers WHERE customer_id IS NULL);

-- Gender values normalized
SELECT 'FAIL: dim_customers unnormalized gender'
WHERE EXISTS (SELECT 1 FROM gold.dim_customers WHERE gender NOT IN ('Female', 'Male', 'n/a'));

-- Marital status normalized
SELECT 'FAIL: dim_customers unnormalized marital_status'
WHERE EXISTS (SELECT 1 FROM gold.dim_customers WHERE marital_status NOT IN ('Single', 'Married', 'n/a'));

-- No future birthdates
SELECT 'FAIL: dim_customers future birthdate'
WHERE EXISTS (SELECT 1 FROM gold.dim_customers WHERE birthdate > GETDATE());

-- Country not empty (should be 'n/a' or actual value)
SELECT 'FAIL: dim_customers empty country'
WHERE EXISTS (SELECT 1 FROM gold.dim_customers WHERE country = '');

-- Table has rows
SELECT 'FAIL: dim_customers is empty' WHERE NOT EXISTS (SELECT 1 FROM gold.dim_customers);

-- =============================================================================
-- 2. dim_products
-- =============================================================================

-- No duplicate product_key
SELECT 'FAIL: dim_products duplicate product_key'
WHERE EXISTS (SELECT product_key FROM gold.dim_products GROUP BY product_key HAVING COUNT(*) > 1);

-- No NULL product_key
SELECT 'FAIL: dim_products NULL product_key'
WHERE EXISTS (SELECT 1 FROM gold.dim_products WHERE product_key IS NULL);

-- No NULL product_id
SELECT 'FAIL: dim_products NULL product_id'
WHERE EXISTS (SELECT 1 FROM gold.dim_products WHERE product_id IS NULL);

-- Product line normalized
SELECT 'FAIL: dim_products unnormalized product_line'
WHERE EXISTS (SELECT 1 FROM gold.dim_products WHERE product_line NOT IN ('Mountain', 'Road', 'Other Sales', 'Touring', 'n/a'));

-- Cost non-negative
SELECT 'FAIL: dim_products negative cost'
WHERE EXISTS (SELECT 1 FROM gold.dim_products WHERE cost < 0);

-- No NULL category
SELECT 'FAIL: dim_products NULL category'
WHERE EXISTS (SELECT 1 FROM gold.dim_products WHERE category IS NULL);

-- No NULL subcategory
SELECT 'FAIL: dim_products NULL subcategory'
WHERE EXISTS (SELECT 1 FROM gold.dim_products WHERE subcategory IS NULL);

-- Table has rows
SELECT 'FAIL: dim_products is empty' WHERE NOT EXISTS (SELECT 1 FROM gold.dim_products);

-- =============================================================================
-- 3. fact_sales
-- =============================================================================

-- No NULL order_number
SELECT 'FAIL: fact_sales NULL order_number'
WHERE EXISTS (SELECT 1 FROM gold.fact_sales WHERE order_number IS NULL);

-- No NULL product_key (orphan check)
SELECT 'FAIL: fact_sales NULL product_key'
WHERE EXISTS (SELECT 1 FROM gold.fact_sales WHERE product_key IS NULL);

-- No NULL customer_key (orphan check)
SELECT 'FAIL: fact_sales NULL customer_key'
WHERE EXISTS (SELECT 1 FROM gold.fact_sales WHERE customer_key IS NULL);

-- Sales amount positive
SELECT 'FAIL: fact_sales non-positive sales_amount'
WHERE EXISTS (SELECT 1 FROM gold.fact_sales WHERE sales_amount <= 0);

-- Quantity positive
SELECT 'FAIL: fact_sales non-positive quantity'
WHERE EXISTS (SELECT 1 FROM gold.fact_sales WHERE quantity <= 0);

-- Price positive
SELECT 'FAIL: fact_sales non-positive price'
WHERE EXISTS (SELECT 1 FROM gold.fact_sales WHERE price <= 0);

-- Order date not NULL
SELECT 'FAIL: fact_sales NULL order_date'
WHERE EXISTS (SELECT 1 FROM gold.fact_sales WHERE order_date IS NULL);

-- Shipping date >= order date
SELECT 'FAIL: fact_sales ship before order'
WHERE EXISTS (
    SELECT 1 FROM gold.fact_sales
    WHERE shipping_date IS NOT NULL AND order_date IS NOT NULL AND shipping_date < order_date
);

-- sales_amount = quantity * price (consistency)
SELECT 'FAIL: fact_sales amount != quantity * price'
WHERE EXISTS (
    SELECT 1 FROM gold.fact_sales
    WHERE sales_amount != quantity * price
);

-- All product_keys exist in dim_products
SELECT 'FAIL: fact_sales orphan product_key (not in dim_products)'
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
WHERE p.product_key IS NULL;

-- All customer_keys exist in dim_customers
SELECT 'FAIL: fact_sales orphan customer_key (not in dim_customers)'
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;

-- Table has rows
SELECT 'FAIL: fact_sales is empty' WHERE NOT EXISTS (SELECT 1 FROM gold.fact_sales);

-- =============================================================================
-- End of Tests (27 checks)
-- =============================================================================
