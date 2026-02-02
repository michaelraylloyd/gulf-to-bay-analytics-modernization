# 13. Appendix & Reference Materials

## 13.1 Overview
The appendix provides supporting materials, reference links, diagrams, and auxiliary documentation that complement the core architecture narrative. These resources help engineers, reviewers, and recruiters quickly understand the system’s structure, dependencies, and design rationale without searching through the full repo.

---

## 13.2 Repository Map
The following summarizes the full structure of the `14-fabric-sales-analytics` project:

- **config/** — environment assumptions, refresh schedules, global configuration  
- **docs/** — architecture, medallion layer overviews, data dictionary, decisions  
- **notebooks/** — ordered Bronze, Silver, Gold notebooks  
- **pipelines/** — Fabric pipeline definitions  
- **semantic-model/** — semantic model JSON + deployment script  

This map provides a quick orientation for new contributors.

---

## 13.3 Mermaid Model Diagram
The architecture includes a Mermaid diagram stored at:

- `docs/architecture/model_diagram.mmd`

This diagram visualizes:

- Fact and dimension relationships  
- Key business entities  
- High‑level data flow across medallion layers  

It serves as a fast, visual reference for interviews and onboarding.

---

## 13.4 Data Dictionary Reference
The data dictionary is maintained in:

- `docs/data-dictionary/README.md`

It includes:

- Column definitions  
- Data types  
- Business meaning  
- KPI descriptions  
- Relationships between entities  

This ensures that analysts and engineers share a common vocabulary.

---

## 13.5 Decision Log Reference
Architectural decisions, trade‑offs, and rejected alternatives are documented in:

- `docs/decisions/README.md`

Typical entries include:

- Why notebooks were chosen over Dataflows for ingestion  
- Why the medallion pattern was applied  
- How table naming conventions were selected  
- Rationale for semantic model structure  

This log demonstrates intentional, senior‑level engineering thinking.

---

## 13.6 Raw Data Reference
Sample raw data and SQL definitions are stored under:

- `notebooks/0-raw-data/csv/`  
- `notebooks/0-raw-data/sql/`

These assets support:

- Local testing  
- Schema validation  
- Troubleshooting  
- Demonstrations during interviews  

They provide a concrete foundation for the Bronze ingestion layer.

---

## 13.7 Semantic Model Reference
The semantic model is defined and deployed via:

- `semantic-model/SalesAnalyticsModel.json`  
- `semantic-model/deploy-semantic-model.ps1`

These files represent:

- Certified facts and dimensions  
- KPI logic  
- RLS roles  
- Deployment automation  

They are essential for understanding how business users consume curated data.

---

## 13.8 Pipeline Reference
The orchestrator pipeline is located at:

- `pipelines/sales-refresh-pipeline.json`

This file defines:

- Notebook execution order  
- Failure handling  
- Dependencies  
- Refresh orchestration  

It is the operational backbone of the Lakehouse.

---

## 13.9 Documentation Index
For convenience, the appendix includes a quick index of all major architecture documents:

- `architecture.md` — master architecture narrative  
- `high-level-system-overview.md` — modernization context  
- `operational-model.md` — refresh, orchestration, and environment model  
- `governance-and-security.md` — governance framework  
- `engineering-standards-and-naming-conventions.md` — engineering discipline  
- `recruiter-ready-narrative-summary.md` — executive‑level summary  

This index supports fast navigation during reviews and interviews.

---

## 13.10 Summary
The appendix consolidates all supporting materials that reinforce the Lakehouse’s clarity, structure, and professionalism. These references ensure that the architecture is not only technically sound but also fully explainable, auditable, and ready for presentation to stakeholders, engineers, and recruiters.