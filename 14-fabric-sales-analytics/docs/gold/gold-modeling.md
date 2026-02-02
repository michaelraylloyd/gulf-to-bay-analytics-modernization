# Gold Layer — Dimensional Modeling  
The Gold layer represents the curated, analytics‑ready dimensional model for the Sales Analytics Lakehouse.  
Its purpose is to transform conformed Silver data into business‑aligned fact and dimension tables that support reporting, KPI calculations, and semantic modeling.

Gold is where the Lakehouse becomes consumable for analysts, BI developers, and downstream applications.

---

## Purpose of the Gold Layer
The Gold layer focuses on:

- Creating clean, conformed dimension tables  
- Building a validated fact table with correct grain  
- Generating surrogate keys for consistent joins  
- Establishing relationships used by the semantic model  
- Producing a stable foundation for Power BI and downstream analytics  

Gold does not apply raw ingestion logic (Bronze) or data quality enforcement (Silver).  
Instead, it delivers **business‑ready structures** optimized for reporting and performance.

---

## Dimensional Model Components

### **1. Dimension: dim_customer**
Derived from `silver_customers`, this table provides a standardized view of customer attributes.

Key characteristics:
- Surrogate key: customer_sk  
- Natural key: customer_id  
- Conformed attributes: name, location, state, zip  
- Cleaned and standardized formats  

This dimension supports customer‑level slicing and filtering in the semantic model.

---

### **2. Dimension: dim_product**
Derived from `silver_products`, this table provides a consistent view of product attributes.

Key characteristics:
- Surrogate key: product_sk  
- Natural key: product_id  
- Conformed attributes: product_name, category, price  

This dimension supports product‑level analysis and category rollups.

---

### **3. Fact Table: fact_sales**
Derived from validated `silver_sales`, this table represents the core business process: a completed sale.

Key characteristics:
- Grain: one row per sale_id  
- Foreign keys: customer_sk, product_sk  
- Measures: quantity, price, extended_amount  
- Date attributes derived from sale_date  

The fact table is fully validated and contains only trusted sales records.

---

## Surrogate Key Strategy
Surrogate keys are generated in Gold to:

- Decouple reporting from natural key volatility  
- Ensure stable relationships across refresh cycles  
- Support slowly changing dimension patterns in future enhancements  

Each dimension receives a sequential surrogate key, and the fact table resolves foreign keys through Silver natural keys.

---

## Business Logic Applied in Gold

### **1. Extended Amount Calculation**
`extended_amount = quantity * price`  
This measure is used extensively in reporting and KPI calculations.

### **2. Date Derivations**
From `sale_date`, the model derives:
- sale_year  
- sale_month  
- sale_day  

These attributes support calendar‑based slicing without requiring a full date dimension.

### **3. Relationship Validation**
Gold ensures:
- Every fact row maps to a valid dimension row  
- No orphaned keys exist  
- All joins are deterministic and reproducible  

---

## Outputs of the Gold Layer

The Gold layer produces the following curated tables:

- **dim_customer** — conformed customer attributes with surrogate keys  
- **dim_product** — conformed product attributes with surrogate keys  
- **fact_sales** — validated sales facts with foreign keys and business measures  

These tables form the backbone of the semantic model and support all downstream reporting.

---

## Summary
The Gold layer delivers a clean, conformed dimensional model by:

- Generating surrogate keys  
- Building fact and dimension tables  
- Applying business logic and derived measures  
- Establishing relationships for the semantic model  
- Producing analytics‑ready structures for Power BI  

Gold is the final transformation stage in the medallion architecture and represents the trusted, business‑aligned view of the Sales Analytics Lakehouse.