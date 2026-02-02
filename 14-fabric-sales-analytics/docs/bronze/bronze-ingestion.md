# Bronze Layer — Ingestion Pattern  
The Bronze layer provides the raw, structured foundation for the Sales Analytics Lakehouse.  
Its purpose is to ingest source files exactly once per refresh cycle, enforce predictable schemas, and establish a clean technical baseline for downstream transformations.

---

## Purpose of the Bronze Layer
The Bronze layer captures raw data from the Lakehouse Files area and converts it into stable Delta tables.  
It focuses on:

- Deterministic ingestion  
- Schema consistency  
- Minimal technical cleanup  
- Repeatable development and testing cycles  

This layer does **not** apply business logic. It simply prepares raw data for the Silver layer.

---

## Ingestion Pattern  
The Bronze notebook follows a **kill‑and‑fill** pattern to guarantee a clean slate on every run.

### 1. Reset Existing Tables  
All Bronze tables are dropped at the start of the process.  
This prevents:

- Schema drift  
- Accidental column changes  
- Residual data from previous runs  

This ensures the Bronze layer always reflects the current state of the raw files.

---

### 2. Explicit Schema Enforcement  
Each CSV is loaded using a predefined schema.  
This avoids issues with:

- Header inference  
- Unexpected type changes  
- Malformed or missing columns  

The schema definitions for `customers`, `products`, and `sales` ensure structural consistency across refresh cycles.

---

### 3. Raw File Loading  
Files are read from the Lakehouse Files area with:

- `header = False`  
- Explicit column definitions  
- No inference or auto‑typing  

This preserves the raw shape of the data while ensuring predictable column names and types.

---

### 4. Minimal Technical Cleanup  
A lightweight cleanup step trims whitespace from string columns.  
This improves technical quality without altering business meaning.

No transformations, joins, or business rules are applied in Bronze.

---

### 5. Write to Delta Tables  
Each dataset is written to a Bronze Delta table using overwrite semantics.  
This produces:

- Stable, queryable tables  
- A consistent starting point for Silver  
- Clean lineage for debugging and validation  

---

### 6. Validation  
The notebook prints row counts for each table.  
This provides a quick sanity check and confirms that ingestion completed successfully.

---

## Summary  
The Bronze layer establishes a clean, deterministic ingestion foundation by:

- Enforcing explicit schemas  
- Avoiding header inference  
- Preserving raw data structure  
- Applying minimal cleanup  
- Producing stable Delta tables  

This layer feeds directly into the Silver transformation logic, where normalization and data quality rules are applied.