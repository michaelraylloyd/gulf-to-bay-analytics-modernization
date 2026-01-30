# Bronze → Data Quality Pipeline Walkthrough

This document explains the execution flow, purpose, and guarantees of the Bronze ingestion pipeline followed by Data Quality validation. It provides a human‑readable walkthrough of the orchestration defined in `bronze-sales-with-dq-pipeline.json`.

---

## Purpose

The Bronze → Data Quality pipeline ensures that all raw data entering the Lakehouse is:

- Schema‑aligned  
- Type‑consistent  
- Validated against business rules  
- Safe for downstream Silver transformations  

This pipeline establishes the foundational contract for the entire Lakehouse.

---

## Execution Flow

### 1. Bronze Ingestion  
**Notebook:** `bronze-ingest-sales.ipynb`  
**Responsibility:**  
- Read raw files from `/lakehouse/default/Files/`  
- Apply schema normalization  
- Cast all fields to deterministic types  
- Write the Bronze Delta table  

This step guarantees that all raw data is structured and typed before validation.

---

### 2. Data Quality Validation  
**Notebook:** `dq-run-sales.ipynb`  
**Responsibility:**  
- Load the Bronze table  
- Apply schema checks  
- Apply rule‑based validations (null checks, range checks, referential checks)  
- Produce a pass/fail result  

If validation fails, the pipeline stops and prevents contaminated data from entering Silver.

---

## Pipeline Definition

**Artifact:** `bronze-sales-with-dq-pipeline.json`  
**Flow:**  
1. `bronze_ingest_sales`  
2. `dq_sales` (depends on Bronze success)

This ensures deterministic sequencing and prevents partial or invalid ingestion.

---

## Guarantees

- No unvalidated data reaches Silver  
- All Bronze tables are schema‑aligned  
- All transformations operate on trusted inputs  
- Failures are isolated early in the pipeline  

This walkthrough provides the conceptual understanding behind the pipeline’s JSON definition and its role in the Lakehouse Expansion pillar.