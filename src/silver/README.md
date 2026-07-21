# Silver Layer

The **Silver Layer** is the cleaned and standardized layer of the SQL Data Warehouse. Data from the Bronze layer undergoes cleansing, deduplication, standardization, and validation before being stored in the Silver schema.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                       BRONZE LAYER                               │
│                  (Raw Data - No Changes)                         │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────┐  ┌──────────────────────────────────┐  │
│  │   CRM Tables        │  │   ERP Tables                     │  │
│  │  • crm_cust_info    │  │  • erp_loc_a101                  │  │
│  │  • crm_prd_info     │  │  • erp_cust_az12                 │  │
│  │  • crm_sales_details│  │  • erp_px_cat_g1v2               │  │
│  └──────────┬──────────┘  └──────────────┬───────────────────┘  │
└─────────────┼────────────────────────────┼──────────────────────┘
              │                            │
              ▼                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      SILVER LAYER                               │
│               (Cleaned & Standardized)                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Transformations Applied:                                       │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  • Data Cleansing (TRIM, NULL handling)                   │  │
│  │  • Deduplication (ROW_NUMBER for latest records)          │  │
│  │  • Standardization (code → full values, date formats)     │  │
│  │  • Data Validation (future dates, invalid prices)         │  │
│  │  • Derived Columns (category IDs, end dates)              │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌─────────────────────┐  ┌──────────────────────────────────┐  │
│  │   CRM Tables        │  │   ERP Tables                     │  │
│  │  • crm_cust_info    │  │  • erp_loc_a101                  │  │
│  │  • crm_prd_info     │  │  • erp_cust_az12                 │  │
│  │  • crm_sales_details│  │  • erp_px_cat_g1v2               │  │
│  └─────────────────────┘  └──────────────────────────────────┘  │
│                                                                 │
│  Schema: silver                                                 │
│  Load Procedure: silver.load_silver                             │
│  Method: Stored Procedure with transformations                  │
└─────────────────────────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────────┐
│                       GOLD LAYER                                 │
│                  (Business-Ready)                                │
└─────────────────────────────────────────────────────────────────┘
```

## Tables

### CRM Tables

| Table | Description | Key Transformations |
|-------|-------------|---------------------|
| `crm_cust_info` | Customer information | Deduplication, normalize marital status & gender, trim whitespace |
| `crm_prd_info` | Product catalog | Extract category ID from key, map product lines, calculate end dates |
| `crm_sales_details` | Sales transactions | Convert integer dates to DATE, recalculate sales/price for invalid values |

### ERP Tables

| Table | Description | Key Transformations |
|-------|-------------|---------------------|
| `erp_loc_a101` | Customer locations | Remove dashes from ID, normalize country codes (DE→Germany, US→United States) |
| `erp_cust_az12` | Customer demographics | Remove 'NAS' prefix, set future birthdates to NULL, normalize gender |
| `erp_px_cat_g1v2` | Product categories | Direct copy (no transformations needed) |

## Transformations

### crm_cust_info
- **Deduplication**: Uses `ROW_NUMBER()` partitioned by `cst_id` to keep only the most recent record
- **Whitespace**: `TRIM()` applied to first name and last name
- **Normalization**: Marital status codes (`S`→`Single`, `M`→`Married`) and gender codes (`F`→`Female`, `M`→`Male`)

### crm_prd_info
- **Category ID Extraction**: First 5 characters of `prd_key` with dash replaced by underscore
- **Product Key Extraction**: Characters from position 7 onwards of `prd_key`
- **Default Values**: NULL costs replaced with 0
- **Product Line Mapping**: Single-letter codes mapped to full names (`M`→`Mountain`, `R`→`Road`, `S`→`Other Sales`, `T`→`Touring`)
- **End Date Calculation**: Uses `LEAD()` window function to set end date as one day before next start date

### crm_sales_details
- **Date Conversion**: Integer dates (YYYYMMDD) converted to DATE type; invalid dates set to NULL
- **Sales Validation**: If sales is NULL, ≤ 0, or doesn't match `quantity × price`, it's recalculated
- **Price Derivation**: If price is NULL or ≤ 0, derived from `sales / quantity`

### erp_cust_az12
- **ID Cleanup**: Removes `NAS` prefix if present
- **Birthdate Validation**: Future birthdates set to NULL
- **Gender Normalization**: Standardized to `Male`, `Female`, or `n/a`

### erp_loc_a101
- **ID Cleanup**: Removes dash characters
- **Country Normalization**: `DE` → `Germany`, `US`/`USA` → `United States`, blank/NULL → `n/a`

## How to Run

### 1. Prerequisites
Ensure the Bronze layer is loaded first:
```sql
EXEC bronze.load_bronze;
```

### 2. Create Silver Tables
```sql
-- Run silver_ddl.sql to create all silver tables
```

### 3. Load Silver Data
```sql
-- Execute the stored procedure
EXEC silver.load_silver;
```

## Data Flow

1. Bronze layer must be loaded first (`bronze.load_bronze`)
2. `silver_ddl.sql` creates the silver tables with proper data types and a `dwh_create_date` audit column
3. `silver_data_cleaning.sql` defines the `silver.load_silver` stored procedure that:
   - Truncates existing data (full refresh)
   - Applies transformations and loads cleaned data
   - Logs load duration for each table

## Audit Columns

Each silver table includes a `dwh_create_date` column (`DATETIME2 DEFAULT GETDATE()`) that records when the row was loaded into the data warehouse.

## Source

Data sourced from [DataWithBaraa/sql-data-warehouse-project](https://github.com/DataWithBaraa/sql-data-warehouse-project/tree/main/datasets).

## License

MIT License - see [LICENSE](../../LICENSE)
