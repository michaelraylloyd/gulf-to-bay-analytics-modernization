# Gulf to Bay Analytics — End‑to‑End Modernization of the Enterprise BI Ecosystem

## 🏷️ Purpose

This repository represents the development workspace for the Gulf to Bay Analytics modernization effort. It demonstrates how a legacy Microsoft BI environment evolves into a clean, automated, cloud‑aligned analytics platform using modern engineering practices, structured documentation, and a disciplined Dev→Prod SDLC pipeline.

---

## 🧭 Navigation — Repo Map

This repository is organized into modular domains that reflect the full modernization journey from legacy Microsoft BI to a cloud‑aligned analytics ecosystem.

- **01‑azure-data-factory** — Legacy ADF pipelines and JSON assets  
- **02‑fabric-data-factory** — Modern Fabric Data Factory pipelines and orchestration  
- **03‑sql-server** — SQL scripts, schema definitions, metadata, and database logic  
- **04‑python** — Python ETL pipelines, transformations, and data quality utilities  
- **05‑r** — R scripts for statistical analysis, modeling, and exploratory work  
- **06‑databricks** — Databricks notebooks, Spark jobs, and lakehouse transformations  
- **07‑dataverse** — Dataverse schema, tables, and integration artifacts  
- **08‑ssis** — Legacy SSIS packages and migration reference materials  
- **09‑ssas** — SSAS Tabular models, partitions, and semantic layer definitions  
- **10‑ssrs** — SSRS report definitions, RDL files, and legacy reporting assets  
- **11‑power-bi** — PBIX files, DAX, M scripts, themes, and semantic modeling  
- **12‑power-automate** — Automated refresh flows and workflow orchestration  
- **13‑power-apps** — Power Apps components, screens, and app logic  
- **14‑powershell** — SDLC automation, Dev→Prod promotion pipeline, and repo tooling  
- **assets** — Branding, icons, screenshots, and visual assets  
- **docs** — Architecture diagrams, modernization notes, and narrative documentation  

Each folder includes an auto‑generated README describing its purpose and role in the modernization effort.

---

## 🧱 Modernization Context

This project spans the full analytics lifecycle:

- **Data Integration:** Azure Data Factory → Fabric Data Factory → Databricks  
- **Data Engineering:** SQL Server optimization, Python ETL, R analytics  
- **Semantic Modeling:** SSAS Tabular → Power BI  
- **Automation:** Power Automate refresh orchestration  
- **SDLC Discipline:** PowerShell‑driven Dev→Prod pipeline, repo hygiene, deterministic validators  
- **Documentation:** Auto‑generated folder READMEs and modernization notes  

The structure is intentionally designed to reflect real‑world enterprise engineering patterns and to present a clear modernization narrative.

---

## 🚀 Modernization Storyline

1. Assess the legacy BI ecosystem  
2. Modularize SQL logic and metadata  
3. Migrate ETL from SSIS to Python, Fabric, and Databricks  
4. Rebuild semantic models for Power BI  
5. Automate refreshes and deployments  
6. Document the modernization journey with clarity and intent  

---

## 🔗 Related Repositories

- **Profile:** https://github.com/michaelraylloyd  
- **Featured Project:** Gulf to Bay Analytics Modernization  
  https://github.com/michaelraylloyd/gulf-to-bay-analytics-modernization

---

## 🧭 Philosophy

- **Clarity:** Clean folder structure and readable pipelines  
- **Scalability:** Architectures that grow with the business  
- **Modernization:** Bridging legacy systems with cloud‑native tools  
- **Automation:** Reducing manual refreshes and maintenance  
- **Narrative:** Every artifact reinforces the modernization story  