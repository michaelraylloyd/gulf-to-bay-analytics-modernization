# Pipeline Overview  
This directory contains the orchestration layer for the Sales Analytics Lakehouse.  
The pipeline coordinates the execution of the Bronze, Silver, and Gold notebooks in a fixed sequence to produce a complete medallion refresh.

---

## Purpose of This Pipeline
The pipeline exists to provide a predictable and repeatable refresh process.  
It ensures:

- Bronze runs before Silver  
- Silver runs before Gold  
- The entire Lakehouse can be refreshed from a single entrypoint  
- The process can be promoted between Dev and Prod without modification  

This design keeps orchestration simple, transparent, and easy to maintain.

---

## Activity Breakdown

### 1. Bronze Layer  
Notebook path:  
notebooks/1-bronze-ingest-sales/1-bronze-ingest-sales.ipynb  

This step loads raw CSV files into Bronze Delta tables using a truncate‑and‑reload pattern.  
It establishes the raw, unmodified foundation for downstream layers.

---

### 2. Silver Layer  
Notebook path:  
notebooks/2-silver-transform-sales/transform_sales.ipynb  

This step applies structure and quality rules:  
- Data type enforcement  
- Column normalization  
- Exception routing  
- Creation of clean Silver tables  

---

### 3. Gold Layer  
Notebook path:  
notebooks/3-gold-model-sales/3-gold-model-sales.ipynb  

This step builds the dimensional model:  
- Surrogate key creation  
- Fact and dimension tables  
- Relationship validation  
- Final analytics‑ready Gold tables  

---

## Screenshot Checklist  
After running the pipeline once, capture the following:

1. The full pipeline layout (all three activities visible)  
2. The Bronze activity configuration panel  
3. A successful run with all activities marked as completed  

Suggested storage location for screenshots:  
docs/pipelines/screenshots/

---

## Promotion Steps (Dev → Prod)

### Step 1 — Commit the pipeline JSON  
File:  
pipelines/sales-refresh-pipeline.json  

### Step 2 — Publish to Dev  
- Import or update the pipeline in the Dev workspace  
- Confirm notebook bindings  
- Execute one full run  

### Step 3 — Promote to Prod  
- Use Fabric Deployment Pipelines  
- Promote Dev → Test (optional)  
- Promote Test → Prod  
- Validate a successful execution in Prod  

---

## Files in This Directory

- README.md  
- sales-refresh-pipeline.json  

The JSON file is the exported definition of the pipeline from Fabric and represents the authoritative orchestration configuration.

---

## Notes  
This pipeline intentionally avoids unnecessary branching or complexity.  
It reflects the recommended pattern for orchestrating medallion layers in a Fabric Lakehouse: simple, ordered, and easy to promote.