# Bronze layer — truncate + exception logging

The Bronze layer ingests raw CSV files exactly as delivered, preserving source fidelity while capturing malformed rows into exception tables.

This notebook uses a deterministic **TRUNCATE-based kill-and-fill** pattern:

- Tables persist permanently
- Each run clears them with `TRUNCATE TABLE`
- Clean rows append into Bronze tables
- Malformed rows append into exception tables
- Schemas are explicitly defined
- Exception tables include `_corrupt_record` for traceability
- Logic is Fabric/Delta–native and transferable to other modern stacks

## Pipeline steps

1. Define schemas for `customers`, `products`, and `sales`.
2. Ensure Bronze and exception tables exist (schema-only, no CTAS).
3. `TRUNCATE` all Bronze and exception tables.
4. Read CSVs in PERMISSIVE mode with `_corrupt_record`.
5. Split clean vs malformed rows per file.
6. Append clean rows into Bronze tables.
7. Append malformed rows into exception tables.
8. Print row counts for quick validation.
