# Databricks Notebooks — Gulf to Bay Lakehouse

This folder contains the **notebook implementations** of the Gulf to Bay Databricks Lakehouse medallion architecture.  
These notebooks are executed by the Databricks Job defined in `10-databricks-jobs`.

## Purpose
The notebooks in this folder implement the three core layers of the Lakehouse:

- **Bronze** — ingestion and raw landing  
- **Silver** — cleaning, standardization, and conformance  
- **Gold** — dimensional modeling and analytics‑ready tables  

Each notebook is written in a clean, deterministic, senior‑level style with:

- Minimal markdown  
- A single Python execution block  
- Clear comments  
- Consistent naming  
- Production‑aligned logic  

## Notebook Structure
### `01-bronze-ingestion-sales`
Reads raw sales data, applies schema, and writes Delta tables to the Bronze layer.

### `02-silver-transform`
Cleans and standardizes Bronze data, producing conformed Silver tables.

### `03-gold-modeling`
Builds dimensional models and fact tables for analytics and semantic modeling.

## Execution
These notebooks are **not** run manually in production.  
They are orchestrated by the Databricks Job defined in:
