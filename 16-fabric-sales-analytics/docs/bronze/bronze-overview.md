# Bronze Layer Overview — Sales Analytics Lakehouse

The Bronze layer is the raw-but-readable landing zone for all source data
ingested into the Sales Analytics Lakehouse. Its purpose is to preserve source
fidelity while enforcing technical cleanliness and deterministic structure.

Bronze is intentionally minimal:
- No business logic  
- No transformations beyond trimming and schema enforcement  
- No type casting or conformance  
- No deduplication  

These responsibilities belong to Silver.

---

## Objectives

- Land raw CSV files from the Lakehouse Files area into Delta tables  
- Apply explicit schemas to avoid header inference issues  
- Normalize technical column quality (trim whitespace)  
- Maintain a deterministic, repeatable ingestion pattern  
- Provide a clean foundation for Silver transformations  

---

## Source Files

The following files are stored in the Lakehouse under `Files/`:

- `customers.csv`
- `products.csv`
- `sales.csv`

These files are ingested directly by the Bronze notebook using explicit schemas.

---

## Ingestion Pattern

The Bronze ingestion process is implemented as a single Python notebook that:

1. Drops existing Bronze tables (kill + fill)
2. Defines explicit schemas
3. Loads CSV files with `header=False`
4. Applies minimal cleanup (trim string columns)
5. Writes Delta tables
6. Validates row counts

This ensures a clean, repeatable Bronze layer suitable for downstream processing.

---

## Resulting Bronze Tables

### `bronze_customers`
- customer_id  
- first_name  
- last_name  
- address  
- city  
- state  
- zip  
- country  

### `bronze_products`
- product_id  
- product_name  
- category  
- price  

### `bronze_sales`
- sale_id  
- customer_id  
- product_id  
- quantity  
- sale_date  

---

## Notes

- Bronze enforces **technical** quality only.  
- All **business** logic is deferred to Silver.  
- Date parsing, type casting, deduplication, and referential integrity checks occur in Silver.  
- The notebook is designed for iterative development and will be orchestrated later via Fabric pipelines.