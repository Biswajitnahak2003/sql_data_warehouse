# Gold Layer

The **Gold Layer** is the business-ready layer of the SQL Data Warehouse. Silver data is integrated, aggregated, and modeled into a star schema with dimension and fact views for analytics and reporting.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                       SILVER LAYER                               │
│                  (Cleaned & Standardized)                        │
├─────────────────────────────────────────────────────────────────┤
│  crm_cust_info    crm_prd_info    crm_sales_details             │
│  erp_cust_az12    erp_loc_a101    erp_px_cat_g1v2               │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                       GOLD LAYER                                 │
│                  (Business-Ready)                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌────────────────┐  │
│  │ dim_customers   │  │ dim_products    │  │ fact_sales     │  │
│  │ (View)          │  │ (View)          │  │ (View)         │  │
│  └─────────────────┘  └─────────────────┘  └────────────────┘  │
│                                                                 │
│  Object Type: Views        Load: No Load (query-time)          │
│  Data Model: Star Schema   Transformations: Integrations,      │
│                            Aggregations, Business Logics        │
└─────────────────────────────────────────────────────────────────┘
```

## Tables (Views)

| View | Type | Description |
|------|------|-------------|
| `gold.dim_customers` | Dimension | Customer dimension with demographics and location |
| `gold.dim_products` | Dimension | Product dimension with category and maintenance info |
| `gold.fact_sales` | Fact | Sales transactions linked to customer and product dimensions |

## Transformations

### dim_customers

- **Surrogate Key**: `customer_key` generated via `ROW_NUMBER()` for dimension indexing
- **Gender Resolution**: CRM gender is primary source; falls back to ERP gender if CRM is `n/a`; defaults to `n/a` if both are unavailable
- **Data Integration**: Joins `crm_cust_info` (primary) with `erp_cust_az12` (demographics) and `erp_loc_a101` (location)

### dim_products

- **Surrogate Key**: `product_key` generated via `ROW_NUMBER()` ordered by start date and product key
- **Active Products Only**: Filters out historical records where `prd_end_dt IS NULL`
- **Data Integration**: Joins `crm_prd_info` with `erp_px_cat_g1v2` for category details

### fact_sales

- **Dimension Linking**: References `product_key` and `customer_key` from dimension views
- **Sales Metrics**: Contains order date, shipping date, due date, sales amount, quantity, and price

## Challenges Faced

### 1. Gender Conflict During LEFT JOIN

When joining `crm_cust_info` with `erp_cust_az12`, gender values conflicted:

```
CRM (master):  'n/a'     → gender unknown
ERP (joined):  'Male'    → has value

CRM (master):  'n/a'     → gender unknown
ERP (joined):  NULL      → also unknown
```

**Solution**: CRM is treated as the primary source. If CRM gender is `n/a`, fall back to ERP gender. If both are unavailable, default to `n/a`.

```sql
CASE
    WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
    ELSE COALESCE(ca.gen, 'n/a')
END AS gender
```

### 2. Surrogate Keys for Dimension Tables

Dimension tables need surrogate keys for efficient joins and indexing, rather than using natural business keys directly.

**Solution**: Generated `customer_key` and `product_key` using `ROW_NUMBER()` window function ordered by stable columns (ID, start date) to ensure consistent key assignment across loads.

```sql
ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key
ROW_NUMBER() OVER (ORDER BY prd_start_dt, prd_key) AS product_key
```

## How to Run

### 1. Prerequisites
Ensure Silver layer is loaded first:
```sql
EXEC silver.load_silver;
```

### 2. Create Gold Views
```sql
-- Run gold_views.sql to create all gold views
```

### 3. Query Gold Data
```sql
-- Example: Sales by customer and product
SELECT
    cu.first_name,
    cu.last_name,
    pr.product_name,
    fa.sales_amount,
    fa.quantity
FROM gold.fact_sales fa
JOIN gold.dim_customers cu ON fa.customer_key = cu.customer_key
JOIN gold.dim_products pr ON fa.product_key = pr.product_key;
```

## Data Flow

1. Silver layer must be loaded first (`silver.load_silver`)
2. `gold_views.sql` creates three views:
   - `gold.dim_customers` — integrates customer, demographic, and location data
   - `gold.dim_products` — integrates product and category data
   - `gold.fact_sales` — links sales transactions to dimensions via surrogate keys

## Source

Data sourced from [DataWithBaraa/sql-data-warehouse-project](https://github.com/DataWithBaraa/sql-data-warehouse-project/tree/main/datasets).

## License

MIT License - see [LICENSE](../../LICENSE)
