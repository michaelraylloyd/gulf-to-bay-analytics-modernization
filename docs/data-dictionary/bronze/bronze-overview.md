# Bronze Layer Overview — Sales Analytics Lakehouse

The Bronze layer serves as the structured landing zone for all raw source data ingested into the Sales Analytics Lakehouse. Its role is to preserve source fidelity while enforcing predictable schemas and minimal technical cleanup. Bronze is intentionally lightweight and free of business logic, ensuring that downstream layers receive data in a consistent, reliable form.

Bronze performs only the following responsibilities:
- Enforce explicit schemas  
- Apply minimal technical cleanup (string trimming)  
- Maintain deterministic ingestion behavior  
- Preserve raw data structure without interpretation  

All conformance, type casting, deduplication, and business rules are deferred to Silver.

---

## Objectives

The Bronze layer is designed to:

- Load raw CSV files from the Lakehouse Files area into Delta tables  
- Avoid header inference by applying explicit schemas  
- Normalize technical column quality (e.g., trimming whitespace)  
- Provide a repeatable, deterministic ingestion pattern  
- Establish a stable foundation for Silver transformations  

---

## Source Files

The following raw files are stored under the Lakehouse `Files/` area:

- customers.csv  
- products.csv  
- sales.csv  

Each file is ingested using a predefined schema to ensure structural consistency.

---

## Ingestion Pattern

Bronze ingestion is implemented as a single notebook that performs the following steps:

1. **Reset Bronze tables (kill + fill)**  
   Ensures no schema drift or residual data from prior runs.

2. **Apply explicit schemas**  
   Prevents Spark from inferring incorrect column names or types.

3. **Load raw CSV files with header inference disabled**  
   Guarantees deterministic column ordering and naming.

4. **Perform minimal cleanup**  
   Trims whitespace from string columns to improve technical quality.

5. **Write Delta tables using overwrite semantics**  
   Produces clean, queryable Bronze tables for downstream layers.

6. **Validate ingestion**  
   Prints row counts to confirm completeness and correctness.

This pattern ensures that Bronze remains stable, predictable, and easy to reason about during development.

---

## Resulting Bronze Tables

### bronze_customers
- customer_id  
- first_name  
- last_name  
- address  
- city  
- state  
- zip  
- country  

### bronze_products
- product_id  
- product_name  
- category  
- price  

### bronze_sales
- sale_id  
- customer_id  
- product_id  
- quantity  
- sale_date  

---

## Notes

- Bronze enforces **technical quality only**.  
- All **business logic** is deferred to Silver.  
- Type casting, date parsing, deduplication, and referential integrity checks occur in Silver.  
- The Bronze notebook is optimized for iterative development and is orchestrated via Fabric pipelines for full refresh cycles.