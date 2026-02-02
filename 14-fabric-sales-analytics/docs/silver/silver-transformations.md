# Silver Layer Transformations — Sales Analytics Lakehouse

The Silver layer applies structured, deterministic transformations to the raw Bronze tables.  
Its purpose is to enforce data types, standardize formats, validate relationships, and surface data quality issues without interrupting the pipeline.  
Each Bronze table is refined into a conformed, analytics‑ready Silver table.

---

## Customers

**Source:** bronze_customers  
**Target:** silver_customers  

### Transformations Applied

**Type Enforcement**  
- customer_id → integer  
- zip → string  

**Deduplication**  
- Remove duplicate rows based on customer_id  

**Conformance**  
- first_name, last_name, city → InitCap  
- state → UPPERCASE  

### Result  
A clean, conformed customer reference table suitable for downstream modeling and Gold‑layer dimension construction.

---

## Products

**Source:** bronze_products  
**Target:** silver_products  

### Transformations Applied

**Type Enforcement**  
- product_id → integer  
- price → double  

**Deduplication**  
- Remove duplicate rows based on product_id  

**Conformance**  
- product_name, category → InitCap  

### Result  
A standardized product reference table with consistent naming conventions and reliable numeric pricing.

---

## Sales

**Source:** bronze_sales  
**Targets:** silver_sales, silver_sales_errors  

### Transformations Applied

**Type Enforcement**  
- sale_id, customer_id, product_id, quantity → integer  

**Date Parsing**  
- sale_date → date (yyyy‑MM‑dd)  

**Deduplication**  
- Remove duplicate rows based on sale_id  

**Referential Integrity Validation**  
- silver_sales:  
  - Inner join to silver_customers on customer_id  
  - Inner join to silver_products on product_id  
- silver_sales_errors:  
  - Capture rows failing customer or product lookups  
  - Remove duplicates on sale_id  

### Result  
A trusted, validated sales fact table (`silver_sales`) and a companion error table (`silver_sales_errors`) that preserves data quality issues for inspection and remediation.

---

## Summary

The Silver layer transforms raw Bronze data into clean, conformed, analytics‑ready datasets by:

- Enforcing correct data types  
- Standardizing text formats  
- Removing duplicates  
- Validating referential integrity  
- Capturing malformed or orphaned rows  

These refined Silver tables form the foundation for the Gold dimensional model.