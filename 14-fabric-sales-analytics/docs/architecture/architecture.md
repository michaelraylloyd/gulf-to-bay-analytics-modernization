# Gulf to Bay Analytics — Fabric Lakehouse Architecture

## 1. High‑Level System Overview
The Gulf to Bay Analytics Lakehouse modernization establishes a unified, cloud‑native analytics foundation built on Microsoft Fabric. It replaces fragmented legacy processes with a deterministic, medallion‑based architecture that supports scalable ingestion, transformation, modeling, and governed consumption.

The Lakehouse consolidates all engineering workflows—Bronze ingestion, Silver cleansing, Gold modeling, orchestration, and semantic modeling—into a single, well‑documented platform aligned with industry best practices.

---

## 2. End‑to‑End Data Flow
The Lakehouse follows a clean, predictable flow:

**Source Systems → Bronze → Silver → Gold → Semantic Model → Reports & Analytics**

- **Bronze** captures raw source data with full fidelity.  
- **Silver** standardizes, cleanses, and conforms datasets.  
- **Gold** delivers curated fact and dimension tables optimized for analytics.  
- **Semantic Model** exposes certified KPIs and business logic.  
- **Consumption Layer** provides governed access via Power BI, Direct Lake, and Warehouse endpoints.

This flow ensures transparency, lineage, and repeatable engineering behavior.

---

## 3. Component Architecture
The architecture is implemented through a cohesive set of Fabric components:

- **OneLake Lakehouse** for medallion storage  
- **Spark notebooks** for ingestion, transformation, and modeling  
- **Pipelines** for deterministic orchestration  
- **Semantic model** for governed analytics exposure  
- **Documentation & configuration** for clarity and maintainability  

The repository structure mirrors the architecture, enabling intuitive navigation from conceptual design to concrete implementation.

---

## 4. Data Engineering Components
### Bronze  
Raw data ingestion implemented in `1-bronze-ingest-sales.ipynb`.

### Silver  
Cleansing and conformance implemented in `2-transform-sales.ipynb`.

### Gold  
Dimensional modeling implemented in `3-model-sales.ipynb`.

Each notebook follows a numbered, structured pattern with clear inputs, outputs, and validation steps.

---

## 5. Orchestration & Refresh
A single orchestrator pipeline—`sales-refresh-pipeline.json`—executes the medallion flow in order:

1. Bronze ingestion  
2. Silver transformation  
3. Gold modeling  

Refresh schedules and environment assumptions are documented in `config/refresh-schedules.md` and `config/environment.md`.

---

## 6. Semantic Model & Consumption
The semantic layer is defined in `SalesAnalyticsModel.json` and deployed via `deploy-semantic-model.ps1`.

It provides:

- Certified fact and dimension tables  
- KPI logic  
- RLS roles  
- Business‑friendly naming and organization  

Power BI reports consume this model for governed, consistent analytics.

---

## 7. Governance & Security
Governance spans workspace roles, data access, lineage, and semantic model certification.

Key principles:

- Role‑based access control  
- Separation of Dev and Prod  
- Lineage visibility across all layers  
- Certified datasets for trusted reporting  
- Documented operational expectations  

This ensures compliance, auditability, and secure data consumption.

---

## 8. Engineering Standards & Naming Conventions
Engineering discipline is enforced through:

- Numbered, structured notebooks  
- Consistent table prefixes (`bronze_`, `silver_`, `dim_`, `fact_`)  
- snake_case column naming  
- Lower‑kebab‑case file and folder names  
- Deterministic pipeline patterns  
- Version‑controlled semantic model definitions  

These standards reduce friction and improve onboarding.

---

## 9. Operational Model
Operations are predictable and transparent:

- A single orchestrated pipeline governs refresh  
- Notebooks are deterministic and validated  
- Environment configuration is externalized  
- Monitoring uses Fabric’s built‑in run history and lineage  
- Troubleshooting follows a clear, documented workflow  

This ensures reliable day‑to‑day execution.

---

## 10. Recruiter‑Ready Narrative Summary
The Lakehouse demonstrates:

- Modern BI architecture mastery  
- Cloud‑native engineering fluency  
- Strong documentation and communication  
- Enterprise‑grade operational thinking  
- A complete modernization story from raw data to governed analytics  

It is a portfolio‑ready example of senior‑level data engineering capability.

---

## 11. Appendix & References
Supporting materials include:

- Mermaid model diagram (`model_diagram.mmd`)  
- Data dictionary (`docs/data-dictionary/`)  
- Decision log (`docs/decisions/`)  
- Raw data references (`notebooks/0-raw-data/`)  
- Pipeline and semantic model definitions  

These resources reinforce clarity, auditability, and extensibility.

---

## 12. Summary
The Fabric Sales Analytics Lakehouse is a clean, scalable, and fully modernized analytics platform. It replaces legacy friction with a deterministic medallion architecture, governed semantic modeling, and a disciplined engineering framework. Every component—from ingestion to reporting—is documented, narratable, and aligned with enterprise best practices.

This architecture positions Gulf to Bay Analytics for long‑term growth, operational efficiency, and future AI‑driven analytics.