# Bronze Layer

The **Bronze Layer** is the raw ingestion layer of the SQL Data Warehouse. Data is loaded as-is from source systems (CRM and ERP) with no transformations applied.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     SOURCE SYSTEMS                       │
├──────────────────────┬──────────────────────────────────┤
│   CRM (Source CRM)   │      ERP (Source ERP)            │
│  ┌────────────────┐  │  ┌─────────────────────────────┐ │
│  │  cust_info.csv │  │  │  loc_a101.csv               │ │
│  │  prd_info.csv  │  │  │  cust_az12.csv              │ │
│  │  sales_details │  │  │  px_cat_g1v2.csv            │ │
│  └────────────────┘  │  └─────────────────────────────┘ │
└──────────┬───────────┴──────────────┬────────────────────┘
           │                          │
           ▼                          ▼
┌─────────────────────────────────────────────────────────┐
│                    BRONZE LAYER                          │
│              (Raw Data - No Changes)                     │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌─────────────────────┐  ┌──────────────────────────┐  │
│  │   CRM Tables        │  │   ERP Tables             │  │
│  │  • crm_cust_info    │  │  • erp_loc_a101          │  │
│  │  • crm_prd_info     │  │  • erp_cust_az12         │  │
│  │  • crm_sales_details│  │  • erp_px_cat_g1v2       │  │
│  └─────────────────────┘  └──────────────────────────┘  │
│                                                          │
│  Schema: bronze                                          │
│  Load Procedure: bronze.load_bronze                      │
│  Method: BULK INSERT (CSV → Table)                       │
└─────────────────────────────────────────────────────────┘
```

## Tables

### CRM Tables

| Table | Description | Source File |
|-------|-------------|-------------|
| `crm_cust_info` | Customer information (name, gender, marital status) | `cust_info.csv` |
| `crm_prd_info` | Product catalog (name, cost, line, validity dates) | `prd_info.csv` |
| `crm_sales_details` | Sales transaction details (order, quantity, price) | `sales_details.csv` |

### ERP Tables

| Table | Description | Source File |
|-------|-------------|-------------|
| `erp_loc_a101` | Customer location/country data | `loc_a101.csv` |
| `erp_cust_az12` | Customer birth date and gender | `cust_az12.csv` |
| `erp_px_cat_g1v2` | Product category and maintenance info | `px_cat_g1v2.csv` |

## How to Run

### 1. Create Database & Schemas

```sql
-- Run create_schema.sql first
USE master;
CREATE DATABASE sql_data_warehouse;
USE sql_data_warehouse;

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
```

### 2. Create Tables

```sql
-- Run create_ddl.sql to create all bronze tables
```

### 3. Load Data

```sql
-- Execute the stored procedure
EXEC bronze.load_bronze;
```

> **Note:** Update the file paths in `load_data.sql` to match your environment before running.

## Data Flow

1. CSV files are placed in `data/source_crm/` and `data/source_erp/`
2. `create_schema.sql` sets up the database and three schema layers (bronze, silver, gold)
3. `create_ddl.sql` creates the raw tables in the `bronze` schema
4. `load_data.sql` defines a stored procedure (`bronze.load_bronze`) that:
   - Truncates existing data (full refresh)
   - Bulk inserts CSVs into bronze tables
   - Logs load duration for each table

## Source

Data sourced from [DataWithBaraa/sql-data-warehouse-project](https://github.com/DataWithBaraa/sql-data-warehouse-project/tree/main/datasets).

## License

MIT License - see [LICENSE.txt](../../LICENSE.txt)
