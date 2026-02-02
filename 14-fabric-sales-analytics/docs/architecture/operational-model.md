# 9. Operational Model

## 9.1 Overview
The operational model defines how the Lakehouse runs day‑to‑day: how data is ingested, transformed, validated, refreshed, monitored, and deployed across environments. The goal is to ensure deterministic, low‑friction operations that scale cleanly as new subject areas are added.

The Fabric Sales Analytics solution achieves this through a combination of:
- Structured notebooks for each medallion layer
- A single orchestrated refresh pipeline
- Clear environment configuration
- Documented schedules and operational expectations
- A governed semantic model deployment process

Together, these components form a predictable, repeatable operational backbone.

---

## 9.2 Notebook Execution Model
Each medallion layer is implemented as a dedicated notebook with a clear, numbered execution order:

1. **Bronze ingestion**  
   `notebooks/1-bronze-ingest-sales/1-bronze-ingest-sales.ipynb`

2. **Silver transformations**  
   `notebooks/2-silver-transform-sales/2-transform-sales.ipynb`

3. **Gold modeling**  
   `notebooks/3-gold-model-sales/3-model-sales.ipynb`

This ordering is intentional and enforced by the pipeline. Each notebook:

- Accepts well‑defined inputs (Bronze → Silver → Gold)
- Produces deterministic outputs
- Logs key operational details (row counts, schema checks, exceptions)
- Uses consistent naming conventions for tables and checkpoints

This structure ensures that any engineer can run the entire medallion flow manually or via pipeline without ambiguity.

---

## 9.3 Pipeline Orchestration Model
The operational pipeline is defined in:

- **`pipelines/sales-refresh-pipeline.json`**

This pipeline orchestrates the full medallion flow:

1. Run Bronze ingestion notebook  
2. Run Silver transformation notebook  
3. Run Gold modeling notebook  
4. Trigger semantic model refresh (optional, depending on workspace configuration)

**Pipeline guarantees:**

- **Deterministic sequencing** — notebooks run in the correct order every time.
- **Failure isolation** — failures halt downstream steps to prevent partial refreshes.
- **Retry logic** — transient issues can be retried without manual intervention.
- **Operational transparency** — pipeline runs are visible in Fabric monitoring.

The pipeline is the authoritative mechanism for scheduled refreshes and production‑grade execution.

---

## 9.4 Refresh Schedules
Refresh schedules are documented in:

- **`config/refresh-schedules.md`**

This file defines:

- The expected refresh cadence (e.g., daily at 6 AM EST)
- Any intraday refresh windows
- Dependencies on upstream systems
- Operational SLAs for data availability

By externalizing refresh schedules into documentation rather than embedding them in code, the system remains flexible and easy to adjust as business needs evolve.

---

## 9.5 Environment Configuration
Environment assumptions and workspace mappings are documented in:

- **`config/environment.md`**

This includes:

- Dev vs. Prod workspace names
- Lakehouse names and folder structures
- Notebook paths and pipeline identifiers
- Semantic model deployment expectations

This ensures that engineers can deploy or troubleshoot in either environment without guesswork.

---

## 9.6 Semantic Model Deployment
The semantic model is deployed using:

- **`semantic-model/deploy-semantic-model.ps1`**

This script provides:

- A deterministic deployment path for Dev and Prod
- A repeatable mechanism for updating measures, relationships, and metadata
- A clean separation between model definition (`SalesAnalyticsModel.json`) and deployment logic

This aligns the semantic layer with the same SDLC rigor applied to notebooks and pipelines.

---

## 9.7 Monitoring and Exception Handling
Operational monitoring is performed through Fabric’s built‑in capabilities:

- Pipeline run history
- Notebook execution logs
- Lakehouse table lineage
- Semantic model refresh history

Exception handling follows a simple, predictable pattern:

1. Identify the failing step (Bronze, Silver, Gold, or semantic model)
2. Review notebook logs for schema mismatches, null violations, or missing keys
3. Re‑run the failed notebook or pipeline step after correction
4. Document recurring issues in `docs/decisions/` if they represent architectural considerations

This approach ensures that operational issues are surfaced quickly and resolved cleanly.

---

## 9.8 Operational Summary
The operational model ensures that the Lakehouse:

- Runs predictably through a single orchestrated pipeline
- Produces deterministic outputs across all medallion layers
- Supports clean Dev → Prod promotion
- Provides transparent monitoring and troubleshooting
- Maintains clear documentation for every operational decision

This foundation enables Gulf to Bay Analytics to scale the Lakehouse confidently as new subject areas, datasets, and analytical workloads are introduced.