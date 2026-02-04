# Enhanced Gold Table Initialization — Metadata, Maintenance, Validation, Logging

## Purpose
This notebook initializes all Gold‑layer Delta tables using a metadata‑driven pattern and includes optional maintenance, schema validation, and pipeline‑friendly logging.  
It ensures deterministic schema creation, eliminates drift, and provides operational visibility for pipeline runs.

## Why This Notebook Exists
Gold is a derived presentation layer. It should always reflect the current business model and never retain legacy schema artifacts.  
This enhanced initializer provides:

- A single source of truth for all Gold schemas  
- Automatic correction of missing, extra, or mis‑typed columns  
- Optional OPTIMIZE and ZORDER maintenance  
- Schema validation to detect drift  
- Logging to support pipeline observability  

This pattern aligns with Fabric Lakehouse best practices and supports long‑term maintainability.

## What This Notebook Does

### 1. Metadata‑Driven DDL
A Python dictionary defines all Gold tables and their columns.  
The notebook drops and recreates each table using this metadata, ensuring schema consistency across environments.

### 2. Maintenance (Optional)
After table creation, the notebook optionally runs:
- `OPTIMIZE` for file compaction  
- `ZORDER` for improved data skipping on common filter columns  

These operations are safe to skip if unsupported.

### 3. Schema Validation
The notebook compares the physical table schema to the metadata definition:
- Column names  
- Data types  
- Column order  

Any mismatches are logged and optionally can fail the pipeline.

### 4. Logging
A log entry is written to `gold_pipeline_log` containing:
- Timestamp  
- Process name  
- Status (SUCCESS or FAILED)  
- Table count  
- Validation error count  

This supports auditability and pipeline observability.

## Execution Context
This notebook must run in the **Lakehouse Spark engine**, not the Warehouse SQL endpoint.  
All DDL is executed via `spark.sql()` to ensure Spark‑native compatibility.

## Table Coverage
The metadata dictionary currently defines:

- `dim_product`  
- `fact_sales`  
- `exceptions_fact_sales`  

Additional tables can be added by extending the metadata dictionary.

## Downstream Dependencies
- Gold Modeling Notebook (`gold-modeling-build-star-schema`)  
- Gold Pipeline (Silver → Gold → Validation)  
- Warehouse semantic views  
- Power BI semantic model  

## Maintenance Notes
- OPTIMIZE and ZORDER are optional and non‑blocking  
- Schema validation can be configured to fail the pipeline  
- Logging ensures traceability for every run  

## Commit Notes
This notebook is a core artifact of the Gold pipeline.  
It should be executed whenever schema changes occur or when initializing a new environment.