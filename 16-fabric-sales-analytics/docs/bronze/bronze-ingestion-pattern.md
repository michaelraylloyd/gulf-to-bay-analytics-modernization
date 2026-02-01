# Bronze Ingestion Pattern — Sales Analytics Lakehouse

This document summarizes the ingestion logic implemented in the Bronze notebook. The notebook uses a kill‑and‑fill pattern to ensure deterministic, repeatable ingestion during development.

---

## 1. Kill + Fill (Drop Existing Tables)

The notebook begins by dropping Bronze tables to prevent schema drift. This guarantees a clean slate for every run and ensures that schema changes never accumulate silently.

---

## 2. Explicit Schemas

All CSVs are loaded using explicit schemas to avoid header inference issues. This prevents Spark from misinterpreting column names, types, or malformed headers. Each table (customers, products, sales) has a defined schema that enforces structure and consistency.

---

## 3. Load Raw CSV Files

CSV files are read from the Lakehouse Files area using `header=False` and the explicit schemas. This ensures deterministic column names and types regardless of source file quirks.

---

## 4. Minimal Cleanup (Trim Strings)

A helper function trims whitespace from all string columns. This is the only transformation performed in Bronze, and it ensures technical cleanliness without altering business meaning.

---

## 5. Write Delta Tables

Clean DataFrames are written to Bronze Delta tables using overwrite mode. This produces stable, queryable Delta tables that downstream layers can rely on.

---

## 6. Validation

Row counts are printed to confirm ingestion completeness. This provides a quick sanity check during development and ensures that the ingestion process is functioning as expected.

---

## Summary

The Bronze notebook provides a clean, deterministic ingestion layer that:

- Enforces explicit schemas  
- Avoids header inference  
- Normalizes technical quality  
- Produces clean Delta tables  
- Supports repeatable development cycles  

This forms the foundation for Silver transformations.