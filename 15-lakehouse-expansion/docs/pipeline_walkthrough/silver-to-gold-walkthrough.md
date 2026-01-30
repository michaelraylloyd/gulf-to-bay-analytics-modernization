# Silver → Gold Pipeline Walkthrough

This document explains the execution flow, purpose, and guarantees of the Silver transformation pipeline followed by Gold‑layer curation. It provides a human‑readable walkthrough of the orchestration defined in `silver-to-gold-sales-pipeline.json`.

---

## Purpose

The Silver → Gold pipeline ensures that all curated analytical models are derived from:

- Cleaned, typed, enriched Silver data  
- Deterministic transformations  
- Business‑aligned logic  
- Fully validated upstream inputs  

This pipeline produces the final, trusted fact and dimension tables used by BI tools and executive reporting.

---

## Execution Flow

### 1. Silver Transformation  
**Notebook:** `silver-sales-transform.ipynb`  
**Responsibility:**  
- Load Bronze data that has passed Data Quality  
- Apply type normalization  
- Derive analytical attributes (dates, categories, metrics)  
- Produce the Silver sales table  

This step guarantees that all downstream aggregations operate on clean, enriched data.

---

### 2. Gold Fact Curation  
**Notebook:** `gold-sales-fact.ipynb`  
**Responsibility:**  
- Load the Silver sales table  
- Apply business‑aligned aggregations  
- Produce curated fact tables optimized for reporting  
- Write the Gold Delta table  

This step creates the final analytical dataset consumed by dashboards and semantic models.

---

## Pipeline Definition

**Artifact:** `silver-to-gold-sales-pipeline.json`  
**Flow:**  
1. `silver_sales_transform`  
2. `gold_sales_fact` (depends on Silver success)

This ensures deterministic sequencing and prevents Gold from running on incomplete or invalid Silver data.

---

## Guarantees

- All Gold models are derived from validated Silver data  
- All transformations follow deterministic, reproducible logic  
- Aggregations reflect business‑aligned definitions  
- BI tools consume only curated, trusted datasets  

This walkthrough provides the conceptual understanding behind the pipeline’s JSON definition and its role in the Lakehouse Expansion pillar.