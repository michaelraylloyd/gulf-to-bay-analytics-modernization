# Gold Layer — Dimensional Modeling (Star Schema)

The Gold layer transforms clean Silver data into a dimensional star schema optimized for analytics, BI, and semantic modeling.

This layer:

- Builds conformed dimensions (Customer, Product)
- Builds a clean FactSales table
- Enforces join integrity
- Routes join failures into exception tables
- Uses surrogate keys (optional, enabled here)
- Uses a deterministic TRUNCATE-based kill-and-fill pattern

## Pipeline steps

1. Ensure Gold and Gold exception tables exist.
2. `TRUNCATE` all Gold and exception tables.
3. Load Silver tables.
4. Build dimensions with surrogate keys.
5. Build FactSales with validated foreign keys.
6. Route join failures into exception tables.
7. Append clean rows into Gold tables.
8. Append exception rows into exception tables.
9. Print row counts for validation.