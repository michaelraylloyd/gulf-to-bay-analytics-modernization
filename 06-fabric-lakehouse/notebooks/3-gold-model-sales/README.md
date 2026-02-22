# Gold Layer — Dimensional Modeling (Star Schema)

The Gold layer transforms clean Silver data into a dimensional star schema optimized for analytics, BI, and semantic modeling.

This layer:

- Builds conformed dimensions (Customer, Product)
- Builds a clean FactSales table
- Enforces join integrity
- Routes join failures into exception tables
- Uses surrogate keys (optional, enabled here)
- Uses a deterministic TRUNCATE-based kill-and-fill pattern

## Pipeline steps

1. Ensure Gold and Gold exception tables exist.
2. `TRUNCATE` all Gold and exception tables.
3. Load Silver tables.
4. Build dimensions with surrogate keys.
5. Build FactSales with validated foreign keys.
6. Route join failures into exception tables.
7. Append clean rows into Gold tables.
8. Append exception rows into exception tables.
9. Print row counts for validation.

---

# Gold Table Initialization — Lakehouse (Spark SQL)

## Purpose
Initializes all Gold‑layer Delta tables used by the Sales Analytics star schema.  
Ensures deterministic, Spark‑native table creation using Lakehouse‑compatible data types (`string`, `float`, `bigint`) and avoids Warehouse‑only T‑SQL types.

## Why This Exists
Fabric’s SQL editor can route DDL to the Warehouse engine, which does not support Spark SQL types.  
Executing DDL through a notebook guarantees the correct execution context and prevents type‑related failures.

## Tables Created
- `dim_customer`
- `dim_product`
- `fact_sales`
- `exceptions_fact_sales`

Each table is created using a two‑step pattern:
1. `DROP TABLE IF EXISTS <table>`
2. `CREATE TABLE <table> (...)`

This pattern supports kill‑and‑fill Gold modeling and aligns with the Lakehouse Expansion pillar.

## Execution Context
This notebook must run in the **Lakehouse Spark engine**, not the Warehouse SQL endpoint.  
All DDL is executed through `spark.sql()` to guarantee compatibility.

## Downstream Dependencies
- Gold Modeling Notebook (`gold-modeling-build-star-schema`)
- Gold Pipeline (Silver → Gold → Validation)
- Warehouse semantic views (`vw_dim_customer`, `vw_fact_sales`, etc.)
- Power BI semantic model

## Commit Notes
This notebook is a foundational artifact for the Gold pipeline.  
Execute whenever schema changes occur or when initializing a new environment.