# Silver Layer — Standardization and Type Enforcement

The Silver layer transforms raw Bronze data into clean, typed, and standardized tables.

It:

- Trims all string fields
- Enforces numeric types on selected columns
- Routes failed casts into Silver exception tables
- Preserves row-level fidelity for debugging and junior-friendly querying

This notebook uses a deterministic **TRUNCATE-based kill-and-fill** pattern:

- Tables persist permanently
- Each run clears them with `TRUNCATE TABLE`
- Clean rows append into Silver tables
- Bad type conversions append into exception tables

## Pipeline steps

1. Ensure Silver and Silver exception tables exist (schema from Bronze).
2. `TRUNCATE` all Silver and exception tables.
3. Load Bronze tables.
4. Trim all string columns.
5. Enforce numeric types using a safe, lineage-stable cast helper.
6. Route failed casts into exception tables.
7. Append clean rows into Silver tables.
8. Append exception rows into exception tables.
9. Print row counts for quick validation.