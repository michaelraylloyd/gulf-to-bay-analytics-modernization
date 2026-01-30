# Data Quality Layer — Validation Framework

The Data Quality layer enforces structural and business‑rule validation across all Bronze datasets within the Lakehouse Expansion pillar. It ensures that only clean, schema‑aligned, and rule‑compliant data progresses into the Silver and Gold layers. This layer provides the critical contract that guarantees trust, consistency, and reliability across the entire analytical ecosystem.

## Objectives

- Validate Bronze data for schema consistency and type correctness  
- Apply rule‑based checks to detect anomalies and data integrity issues  
- Produce clear pass/fail outcomes for pipeline orchestration  
- Prevent invalid data from contaminating Silver and Gold layers  
- Maintain deterministic, reproducible validation workflows  

## Structure

- `dq_run_sales.ipynb` — Executes Data Quality checks for the sales dataset  
- `rules/` — Future location for reusable validation rule definitions  
- `dq_results/` — Optional location for persisted validation outcomes  

## Workflow Summary

1. Load Bronze datasets  
2. Apply schema and type validation  
3. Execute rule‑based checks (null checks, range checks, referential checks, etc.)  
4. Produce a validation result set  
5. Return a pass/fail signal to the orchestrating pipeline  

The Data Quality layer ensures that downstream transformations operate only on trusted, validated data, forming the backbone of a reliable Lakehouse architecture.