# README — Gulf to Bay Analytics: End‑to‑End Modernization of the Enterprise BI Ecosystem

## 🏷️ Overview

Gulf to Bay Analytics is a full modernization narrative demonstrating how a legacy Microsoft BI ecosystem evolves into a clean, automated, cloud‑aligned analytics platform. This project showcases the complete lifecycle of enterprise analytics modernization — from SQL Server and SSIS to Fabric Data Factory, Python ETL, semantic modeling, and automated reporting.

The repository is intentionally structured to reflect a real‑world modernization journey, with clear folder boundaries, modular pipelines, and production‑grade documentation.

---

## Navigation 🧭

This repository is organized into clear, modular components that reflect the full modernization workflow:

- **01‑azure‑data-factory** — Legacy Azure Data Factory pipelines and JSON assets  
- **02‑fabric‑data-factory** — Modern Fabric Data Factory pipelines and orchestration  
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

Each folder contains its own README, automatically generated for consistency.

---

## 🧱 Architecture at a Glance

- **On‑Prem Foundations:** SQL Server, SSIS, SSAS, SSRS  
- **Modern Cloud ETL:** Azure Data Factory → Fabric Data Factory → Databricks  
- **Python & R ETL:** Modular extract/transform/load pipelines  
- **Semantic Modeling:** SSAS Tabular → Power BI  
- **Automation:** Power Automate refresh orchestration  
- **Documentation:** Auto‑generated READMEs, repo hygiene, and folder‑level summaries  

This repo is designed to be both a technical showcase and a narrative artifact — demonstrating not just *what* was built, but *why* each modernization step matters.

---

## 📁 Repository Structure

The top‑level folders are intentionally prefixed to guide readers through the modernization flow:

| Prefix | Folder | Purpose |
|--------|--------|---------|
| **01‑** | azure‑data-factory | Legacy ADF pipelines and assets |
| **02‑** | fabric‑data-factory | Modern Fabric pipelines |
| **03‑** | sql‑server | SQL scripts, metadata, and database elements |
| **04‑** | python | Python ETL pipelines |
| **05‑** | r | R analytics and modeling |
| **06‑** | databricks | Spark notebooks and lakehouse transformations |
| **07‑** | dataverse | Dataverse schema and integration |
| **08‑** | ssis | Legacy ETL packages |
| **09‑** | ssas | Tabular model artifacts |
| **10‑** | ssrs | Reporting Services assets |
| **11‑** | power‑bi | PBIX files, DAX, M scripts |
| **12‑** | power‑automate | Automated refresh flows |
| **13‑** | power‑apps | KPI Explorer app |
| **14‑** | powershell | Repo automation and SDLC tooling |
| — | assets | Branding and visual assets |
| — | docs | Modernization notes and diagrams |

---

## 🚀 Modernization Storyline

This project walks through a realistic modernization arc:

1. **Assess the legacy stack**  
2. **Extract and modularize SQL logic**  
3. **Migrate ETL from SSIS to Python, Fabric, and Databricks**  
4. **Rebuild semantic models for Power BI**  
5. **Automate refreshes and deployments**  
6. **Document everything with clarity and intent**

The repo is structured to help recruiters, engineers, and hiring managers follow the journey step‑by‑step.

---

## 📊 Sample Gulf to Bay Analytics Dashboard

Explore a live, interactive Power BI report that showcases the **Revenue Stream KPI Overview** used in this modernization project.

This dashboard highlights:

- Revenue trends across product lines  
- KPI performance against targets  
- Year‑over‑year comparisons  
- Drill‑through paths for deeper analysis  
- Clean, modern visuals aligned with the Gulf to Bay branding  

🔗 **Sample Gulf to Bay Analytics Dashboard**  
https://app.powerbi.com/view?r=eyJrIjoiNjEwZWU1M2UtMzhiZS00OTExLThmMjctNDczOGNmZmU5OWE0IiwidCI6ImE0MzI2YTU4LWY3ZDktNDQ0ZC1iM2FhLWIwOTAyN2U1ZTg2NiIsImMiOjF9

---

## 🔗 Related Projects

- **Profile Repo:** https://github.com/michaelraylloyd/michaelraylloyd  
- **Featured Project:** Gulf to Bay Analytics — End‑to‑End BI Modernization  
  https://github.com/michaelraylloyd/gulf-to-bay-analytics-modernization

---

## 🧭 Philosophy

- **Clarity:** Clean folder structure, readable SQL, documented pipelines  
- **Scalability:** Architectures that grow with the business  
- **Modernization:** Bridging legacy systems with cloud‑native tools  
- **Automation:** Reducing manual refreshes and maintenance  
- **Narrative:** Every artifact tells a story of improvement