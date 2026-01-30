# Bronze Layer — Ingestion Framework

The Bronze layer serves as the structured landing zone for raw source data within the Lakehouse Expansion pillar. It applies schema alignment, enforces deterministic column types, and establishes a consistent foundation for downstream Data Quality checks, SCD2 processing, and Silver transformations.

## Objectives

- Normalize raw input data into a consistent schema  
- Preserve source fidelity while applying minimal transformations  
- Provide a stable, reproducible foundation for Data Quality execution  
- Enable deterministic ingestion patterns across all Lakehouse tables  

## Structure

- `bronze_ingest_sales.ipynb` — Ingests raw sales data into the Bronze Delta table  
- `raw/` — Source files delivered into the Lakehouse Files area  
- `bronze_sales` — Delta table created and maintained by the ingestion notebook  

## Workflow Summary

1. Read raw source files from the Lakehouse Files area  
2. Apply schema normalization and type casting  
3. Write the normalized dataset into the Bronze Delta table  
4. Trigger Data Quality validation through the Bronze → DQ pipeline  

This layer establishes the foundational contract for all subsequent Lakehouse layers, ensuring that data entering the system is structured, typed, and ready for validation.