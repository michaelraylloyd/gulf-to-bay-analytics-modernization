# Silver Schema Definition

The Silver schema defines the refined structure of the dataset after applying deterministic cleaning, normalization, and deduplication rules to the Bronze layer. It represents the first point in the Lakehouse where data quality guarantees are enforced, ensuring that downstream analytical models operate on a stable and trustworthy foundation.

The schema is maintained as a standalone JSON artifact (`silver-schema.json`) to ensure consistent typing across both interactive development and automated pipeline execution. By externalizing the schema, the Silver transformation process remains modular, predictable, and environment‑agnostic.

## Key Principles

- **Deterministic Typing:** All fields are explicitly typed to eliminate ambiguity and prevent schema drift.
- **Refined Structure:** The schema introduces derived fields, such as `total_amount`, that support analytical modeling without embedding business logic.
- **Normalization:** Fields are cleaned, trimmed, and standardized to ensure consistency across ingestion runs.
- **Reusability:** The schema is referenced by both the Silver notebook and the Silver transformation script, ensuring alignment across execution paths.

## Current Schema Fields

The Silver schema includes the following fields:

- `order_id` — string  
- `customer_id` — string  
- `product_id` — string  
- `quantity` — integer  
- `unit_price` — double  
- `order_timestamp` — timestamp  
- `total_amount` — double  

These fields represent the canonical structure of the refined Silver dataset and serve as the baseline for business modeling and metric creation in the Gold layer.