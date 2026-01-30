# Silver Layer — Transformation Framework

The Silver layer refines Bronze data into clean, typed, and analytics‑ready datasets. It applies deterministic transformations, derives business attributes, and prepares the data for SCD2 processing and Gold‑layer modeling. This layer represents the first point in the Lakehouse where data is fully validated, structured, and enriched.

## Objectives

- Normalize and type‑cast Bronze data  
- Apply deterministic business transformations  
- Derive core analytical attributes  
- Prepare datasets for SCD2 and Gold modeling  
- Maintain reproducible, environment‑agnostic workflows  

## Structure

- `silver_sales_transform.ipynb` — Transforms Bronze sales data into the Silver sales table  
- `silver_dim_customer_scd2.ipynb` — Applies SCD2 logic to the customer dimension  
- `silver_sales` — Delta table containing cleaned sales data  
- `silver_dim_customer` — Delta table containing historical customer dimension records  

## Workflow Summary

1. Load Bronze datasets  
2. Apply type normalization and business transformations  
3. Derive analytical attributes (dates, categories, metrics)  
4. Write curated Silver tables  
5. Trigger downstream SCD2 or Gold transformations  

The Silver layer establishes the clean, enriched foundation required for accurate historical modeling and business‑ready analytics.