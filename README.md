# SQL Data Warehouse

A medallion architecture data warehouse built with SQL Server, featuring Bronze, Silver, and Gold layers for progressive data cleansing and transformation.

## Architecture

```
┌─────────────────┐     ┌─────────────────┐
│  CRM Datasets   │     │  ERP Datasets   │
│  (CSV files)    │     │  (CSV files)    │
└────────┬────────┘     └────────┬────────┘
         │                       │
         └───────────┬───────────┘
                     ▼
         ┌───────────────────────┐
         │     BRONZE LAYER      │
         │   (Raw Ingestion)     │
         │  No transformations   │
         └───────────┬───────────┘
                     ▼
         ┌───────────────────────┐
         │     SILVER LAYER      │
         │  (Clean & Standardize)│
         │  Dedup, normalize,    │
         │  validate, derive     │
         └───────────┬───────────┘
                     ▼
         ┌───────────────────────┐
         │      GOLD LAYER       │
         │   (Business-Ready)    │
         │  Aggregated, enriched │
         └───────────┬───────────┘
                     ▼
         ┌───────────────────────┐
         │   Analysis & BI       │
         │  (Tableau, Power BI)  │
         └───────────────────────┘
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
│   ├── bronze/
│   │   ├── create_schema.sql
│   │   ├── create_ddl.sql
│   │   └── load_data.sql
│   ├── silver/
│   │   ├── silver_ddl.sql
│   │   └── silver_data_cleaning.sql
│   └── gold/
├── test/
│   └── silver_test.sql
├── LICENSE
└── README.md
```

## Quick Start

```sql
-- 1. Create schemas and bronze tables, then load
-- Run: src/bronze/create_schema.sql
-- Run: src/bronze/create_ddl.sql
EXEC bronze.load_bronze;

-- 2. Create silver tables and transform
-- Run: src/silver/silver_ddl.sql
EXEC silver.load_silver;

-- 3. Run silver data quality tests
-- Run: test/silver_test.sql
```

## Source

Data sourced from [DataWithBaraa/sql-data-warehouse-project](https://github.com/DataWithBaraa/sql-data-warehouse-project/tree/main/datasets).

## License

MIT License - see [LICENSE](LICENSE)
