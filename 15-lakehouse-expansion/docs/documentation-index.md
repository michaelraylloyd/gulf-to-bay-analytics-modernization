# Lakehouse Expansion — Documentation Index

This index provides a structured view of all engineering and documentation artifacts that make up the Lakehouse Expansion pillar. It reflects the full Bronze → Data Quality → Silver → Gold modernization arc and serves as the central navigation point for the entire feature set.

---

## Bronze Layer
Raw but schema‑aligned ingestion with deterministic patterns.

- `bronze-ingest-overview.md`
- `bronze-schema.md`
- `bronze-ingest-patterns.md`

---

## Data Quality Layer
Deterministic validation of Bronze outputs.

- `dq-overview.md`
- `dq-rules-and-checks.md`

---

## Silver Layer
Refined, typed, normalized datasets with enforced schemas.

- `silver-transform-overview.md`
- `silver-schema.md`
- `silver-transform-patterns.md`

---

## Gold Layer
Curated star‑schema modeling with surrogate keys and conformed dimensions.

- `gold-modeling-overview.md`
- `gold-schema.md`
- `gold-modeling-patterns.md`

---

## Pipelines
JSON‑based orchestration for reproducible execution.

- `bronze_sales_with_dq_pipeline.json`
- `silver_to_gold_sales_pipeline.json`

---

## Engineering Artifacts
Shared principles and cross‑layer patterns.

- Deterministic single‑block notebooks  
- Externalized JSON configs  
- Schema definitions  
- Pipeline‑ready scripts  
- Layered lineage from raw → Bronze → Silver → Gold  

---

This index completes the documentation structure for the Lakehouse Expansion pillar and provides a clear, recruiter‑ready entrypoint into the entire modernization effort.