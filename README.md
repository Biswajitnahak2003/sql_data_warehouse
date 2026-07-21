# SQL Data Warehouse

A medallion architecture data warehouse built with SQL Server, featuring Bronze, Silver, and Gold layers for progressive data cleansing and transformation.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     BRONZE LAYER                            │
│                   (Raw Data)                                │
│         Ingest raw CSV data, no transformations             │
│         See: src/bronze/README.md                           │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                     SILVER LAYER                            │
│               (Cleaned & Standardized)                      │
│         Data cleansing, deduplication, standardization      │
│         See: src/silver/README.md                           │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                      GOLD LAYER                             │
│                 (Business-Ready)                             │
│         Aggregated, enriched, analytics-ready data          │
│         Upcoming...                                         │
└─────────────────────────────────────────────────────────────┘
```

## Project Structure

```
sql_data_warehouse/
├── data/
│   ├── source_crm/          # CRM source CSV files
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   └── source_erp/          # ERP source CSV files
│       ├── cust_az12.csv
│       ├── loc_a101.csv
│       └── px_cat_g1v2.csv
├── src/
│   ├── bronze/              # ✅ Bronze layer (completed)
│   │   ├── README.md
│   │   ├── create_schema.sql
│   │   ├── create_ddl.sql
│   │   └── load_data.sql
│   ├── silver/              # ✅ Silver layer (completed)
│   │   ├── README.md
│   │   ├── silver_ddl.sql
│   │   └── silver_data_cleaning.sql
│   └── gold/                # 🔜 Gold layer (upcoming)
├── test/
│   └── silver_test.sql      # Silver layer tests
├── LICENSE.txt
└── README.md
```

## Bronze Layer (Completed)

The Bronze layer ingests raw CSV data into SQL Server tables with no transformations. See [`src/bronze/README.md`](src/bronze/README.md) for detailed documentation.

### Quick Start

```sql
-- 1. Create database and schemas
-- Run: src/bronze/create_schema.sql

-- 2. Create bronze tables
-- Run: src/bronze/create_ddl.sql

-- 3. Load data
EXEC bronze.load_bronze;
```

## Silver Layer (Completed)

The Silver layer cleans and standardizes Bronze data with deduplication, normalization, and validation. See [`src/silver/README.md`](src/silver/README.md) for detailed documentation.

### Quick Start

```sql
-- 1. Create silver tables
-- Run: src/silver/silver_ddl.sql

-- 2. Load and transform data
EXEC silver.load_silver;
```

### Key Transformations

- **Deduplication**: Most recent records retained via `ROW_NUMBER()`
- **Normalization**: Code values expanded (e.g., `S` → `Single`, `DE` → `Germany`)
- **Validation**: Invalid dates, prices, and sales values corrected
- **Derived Columns**: Category IDs extracted, end dates calculated

## Tables

| Schema | Table | Source | Description |
|--------|-------|--------|-------------|
| bronze | `crm_cust_info` | CRM | Customer details (raw) |
| bronze | `crm_prd_info` | CRM | Product catalog (raw) |
| bronze | `crm_sales_details` | CRM | Sales transactions (raw) |
| bronze | `erp_loc_a101` | ERP | Customer locations (raw) |
| bronze | `erp_cust_az12` | ERP | Customer demographics (raw) |
| bronze | `erp_px_cat_g1v2` | ERP | Product categories (raw) |
| silver | `crm_cust_info` | CRM | Customer details (cleaned) |
| silver | `crm_prd_info` | CRM | Product catalog (cleaned) |
| silver | `crm_sales_details` | CRM | Sales transactions (cleaned) |
| silver | `erp_loc_a101` | ERP | Customer locations (cleaned) |
| silver | `erp_cust_az12` | ERP | Customer demographics (cleaned) |
| silver | `erp_px_cat_g1v2` | ERP | Product categories (cleaned) |

## Source

Data sourced from [DataWithBaraa/sql-data-warehouse-project](https://github.com/DataWithBaraa/sql-data-warehouse-project/tree/main/datasets).

## License

MIT License - see [LICENSE.txt](LICENSE.txt)
