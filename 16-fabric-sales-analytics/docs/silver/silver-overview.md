# Silver layer overview — Sales Analytics Lakehouse

The Silver layer transforms raw Bronze data into analytics‑ready Delta tables by enforcing
business rules, standardizing formats, and surfacing data quality issues without breaking
the pipeline.

Silver sits between raw ingestion (Bronze) and business modeling (Gold):

- Bronze: faithful landing of source files with minimal cleanup
- Silver: type casting, date parsing, deduplication, referential integrity, conformance
- Gold: semantic modeling and business‑friendly measures

In this project, the Silver layer produces:

- `silver_customers` — conformed customer attributes
- `silver_products` — conformed product attributes
- `silver_sales` — sales records that pass referential integrity checks
- `silver_sales_errors` — orphaned sales that fail customer or product lookups

This design reflects real‑world data engineering practice: preserve fidelity in Bronze,
enforce business logic in Silver, and only promote trusted data into Gold.