# SQL Data Warehouse

A medallion architecture data warehouse built with SQL Server, featuring Bronze, Silver, and Gold layers for progressive data cleansing and transformation.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      DATA SOURCES                           │
├──────────────────────────┬──────────────────────────────────┤
│      CRM Systems         │         ERP Systems              │
│   (cust, products,       │    (locations, customer          │
│    sales)                │     demographics, categories)    │
└─────────────┬────────────┴──────────────┬───────────────────┘
              │                           │
              ▼                           ▼
┌─────────────────────────────────────────────────────────────┐
│                     BRONZE LAYER                            │
│                  (Raw Ingestion)                             │
│         Raw data loaded as-is from source CSVs              │
│         No transformations applied                          │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                     SILVER LAYER                            │
│               (Cleaned & Standardized)                      │
│         Data cleansing, deduplication, standardization      │
│         Upcoming...                                         │
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
│   ├── silver/              # 🔜 Silver layer (upcoming)
│   └── gold/                # 🔜 Gold layer (upcoming)
├── test/
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

## Tables

| Schema | Table | Source | Description |
|--------|-------|--------|-------------|
| bronze | `crm_cust_info` | CRM | Customer details |
| bronze | `crm_prd_info` | CRM | Product catalog |
| bronze | `crm_sales_details` | CRM | Sales transactions |
| bronze | `erp_loc_a101` | ERP | Customer locations |
| bronze | `erp_cust_az12` | ERP | Customer demographics |
| bronze | `erp_px_cat_g1v2` | ERP | Product categories |

## Source

Data provided by [Baraa](https://github.com/BaraaAlworafi) as part of the SQL Data Warehouse project.

## License

MIT License - see [LICENSE.txt](LICENSE.txt)
