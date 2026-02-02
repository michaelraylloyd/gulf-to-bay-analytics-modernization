# Gold Layer Overview — Sales Analytics Lakehouse

The Gold layer represents the curated, business‑ready dimensional model for the Sales Analytics Lakehouse.  
Its purpose is to transform conformed Silver data into fact and dimension tables that support reporting, KPI calculations, and semantic modeling.  
Gold is the layer consumed directly by analysts, BI developers, and downstream applications.

Gold is intentionally focused on business alignment rather than raw ingestion or data quality enforcement:

- **Bronze:** Raw landing with minimal cleanup  
- **Silver:** Standardization, validation, and conformance  
- **Gold:** Dimensional modeling and business‑friendly structures  

---

## Objectives of the Gold Layer

The Gold layer is designed to:

- Build clean, conformed dimension tables  
- Construct a validated fact table at the correct grain  
- Generate surrogate keys for stable relationships  
- Apply business logic and derived measures  
- Establish the foundation for the semantic model and Power BI  

This layer provides the trusted, analytics‑ready view of the Lakehouse.

---

## Dimensional Model Structure

The Gold layer implements a simple star schema optimized for sales analytics.

### **Dimensions**
- **dim_customer**  
  Conformed customer attributes with a surrogate key and standardized naming.

- **dim_product**  
  Product attributes including category, pricing, and descriptive fields.

### **Fact Table**
- **fact_sales**  
  A validated, conformed fact table representing individual sales transactions.

The fact table links to dimensions through surrogate keys, ensuring stable relationships across refresh cycles.

---

## Business Logic Applied in Gold

### **1. Surrogate Key Generation**
Each dimension receives a sequential surrogate key (`*_sk`).  
This decouples reporting from natural key volatility and supports future SCD patterns.

### **2. Fact Table Construction**
The fact table is built at the grain of one row per sale.  
It includes:

- Foreign keys to customer and product dimensions  
- Quantity and price measures  
- Derived metrics such as extended_amount  

### **3. Date Derivations**
The model extracts year, month, and day attributes from `sale_date` to support calendar‑based slicing without requiring a full date dimension.

### **4. Relationship Validation**
Only validated Silver rows are promoted into Gold.  
Orphaned or malformed records remain isolated in Silver error tables.

---

## Outputs of the Gold Layer

The Gold layer produces the following curated tables:

- **dim_customer** — standardized customer attributes with surrogate keys  
- **dim_product** — standardized product attributes with surrogate keys  
- **fact_sales** — validated sales facts with business measures and foreign keys  

These tables form the backbone of the semantic model and support all downstream reporting.

---

## Summary

The Gold layer delivers a clean, business‑aligned dimensional model by:

- Generating surrogate keys  
- Building fact and dimension tables  
- Applying business logic and derived measures  
- Establishing relationships for the semantic model  
- Producing analytics‑ready structures for Power BI  

Gold is the final transformation stage in the medallion architecture and represents the trusted, consumable view of the Sales Analytics Lakehouse.