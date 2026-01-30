# Gold Layer — Curated Analytics Framework

The Gold layer contains curated, business‑ready fact and dimension models derived from the Silver layer. These datasets are optimized for reporting, KPI generation, dashboard consumption, and executive‑level analytics. The Gold layer represents the final, trusted view of the enterprise data model within the Lakehouse Expansion pillar.

## Objectives

- Aggregate and curate Silver data into business‑aligned models  
- Produce fact and dimension tables optimized for analytics  
- Ensure deterministic, reproducible transformations  
- Provide a stable foundation for BI tools and semantic models  
- Maintain clear lineage from Bronze → Silver → Gold  

## Structure

- `gold_sales_fact.ipynb` — Produces the curated daily sales fact table  
- `gold_sales_fact` — Delta table containing aggregated sales metrics  
- Additional Gold models will follow the same pattern as the Lakehouse expands  

## Workflow Summary

1. Load Silver datasets  
2. Apply aggregations and business logic  
3. Produce curated fact and dimension tables