# Bronze Schema Definition

The Bronze schema defines the canonical structure applied to raw source data during ingestion. It ensures that all downstream processing begins from a consistent, typed, and predictable dataset. By enforcing explicit data types at the Bronze layer, the Lakehouse avoids schema drift, reduces ingestion ambiguity, and provides a stable foundation for Silver and Gold transformations.

The schema is maintained as a standalone JSON artifact (`bronze-schema.json`) to support reuse across notebooks, scripts, and orchestration pipelines. This separation of concerns ensures that ingestion logic remains modular and environment‑agnostic.

## Key Principles

- **Deterministic Typing:** All fields are explicitly typed to prevent inconsistencies across ingestion runs.
- **Raw Fidelity:** The schema preserves the original structure of the source system while adding only minimal operational metadata.
- **Reusability:** The schema file is referenced by both the ingestion notebook and the ingestion script, ensuring alignment across execution paths.
- **Extensibility:** Additional fields can be introduced as the source system evolves, without disrupting downstream layers.

## Current Schema Fields

The Bronze schema currently includes the following fields:

- `order_id` — string  
- `customer_id` — string  
- `product_id` — string  
- `quantity` — integer  
- `unit_price` — double  
- `order_timestamp` — timestamp  

These fields represent the authoritative structure for sales ingestion and serve as the baseline for all subsequent transformations.