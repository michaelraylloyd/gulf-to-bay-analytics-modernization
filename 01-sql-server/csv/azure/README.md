# Azure SQL Export — Raw CSV Files

This folder contains the **raw CSV exports** pulled directly from the Azure SQL Database (`AdventureWorksCloud`).  
These files represent the **source‑of‑truth datasets** used during the early stages of the Gulf to Bay modernization project.

## Purpose
The CSVs in this directory serve as:

- A **frozen snapshot** of the Azure SQL tables at the time of extraction  
- A **portable raw dataset** for local development, testing, and validation  
- A **baseline input** for downstream ingestion pipelines (Fabric, Databricks, SQL Server)  
- A **reference point** for schema inspection and data quality checks  

These files are intentionally unmodified to preserve the integrity of the original Azure SQL data.

## How These Files Were Generated
The CSVs were exported using a PowerShell‑based extraction workflow.

Each table was queried with a simple `SELECT *` and written to CSV without transformations.

## Usage in the Modernization Pipeline
These raw CSVs support multiple modernization layers:

- **SQL Server migration** — validating schema parity between on‑prem and Azure SQL  
- **Fabric Lakehouse ingestion** — Bronze layer population  
- **Databricks Lakehouse ingestion** — Bronze notebook testing  
- **Data quality validation** — comparing raw vs. transformed outputs  

They provide a consistent, reproducible input dataset across all platforms.

## File Characteristics
- Format: `.csv`  
- Encoding: UTF‑8  
- Headers: Included  
- Transformations: None  
- Source: Azure SQL Database (AdventureWorksCloud)

## Relationship to the Repo
This folder is part of the broader SQL Server and Azure SQL modernization story:

- `01-sql-server/` — SQL Server + Azure SQL migration artifacts  
- `10-databricks-notebooks/` — notebooks that ingest these CSVs into Bronze  
- `10-databricks-jobs/` — orchestration of the medallion pipeline  
- `15-lakehouse-expansion/` — Fabric Lakehouse equivalent  

Together, these files anchor the raw data layer for both cloud and on‑prem modernization paths.