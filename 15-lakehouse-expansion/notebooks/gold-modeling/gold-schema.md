# Gold Schema Definition

The Gold schema defines the dimensional and fact structures that make up the Lakehouse star schema. It represents the business‑aligned, analytics‑ready model used by semantic layers, KPI logic, and executive dashboards. The schema enforces deterministic typing, establishes surrogate key patterns, and ensures that all downstream consumers operate on a stable and predictable foundation.

The schema is maintained as a standalone JSON artifact (`gold-schema.json`) to guarantee consistency across both interactive development and automated pipeline execution. By externalizing the schema, the Gold modeling process remains modular, reproducible, and environment‑agnostic.

## Dimensional Structures

### Customer Dimension
The customer dimension provides a conformed view of customer identifiers, enriched with a surrogate key to support analytical joins.

Fields:
- `customer_key` — long  
- `customer_id` — string  

### Product Dimension
The product dimension standardizes product identifiers and introduces a surrogate key for analytical modeling.

Fields:
- `product_key` — long  
- `product_id` — string  

### Date Dimension
The date dimension captures temporal attributes derived from the order timestamp, enabling flexible time‑based analysis.

Fields:
- `date_key` — long  
- `order_timestamp` — timestamp  
- `year` — integer  
- `month` — integer  
- `day` — integer  
- `hour` — integer  

## Fact Table Structure

### Sales Fact
The sales fact table represents the core business process of product sales. It links to each dimension through surrogate keys and includes quantitative measures used for KPI logic and reporting.

Fields:
- `customer_key` — long  
- `product_key` — long  
- `date_key` — long  
- `quantity` — integer  
- `unit_price` — double  
- `total_amount` — double  

## Summary

The Gold schema provides the structural backbone of the Lakehouse’s analytical layer. By defining clear dimensional and fact structures, it ensures that downstream semantic models, dashboards, and KPI frameworks operate on a consistent, business‑aligned foundation.