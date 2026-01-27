# README — Gulf to Bay Analytics: End‑to‑End Modernization of the Enterprise BI Ecosystem

## 🏷️ Overview

Gulf to Bay Analytics is a full modernization narrative that demonstrates how a legacy Microsoft BI ecosystem evolves into a clean, automated, cloud‑aligned analytics platform. This project showcases the complete lifecycle of enterprise analytics modernization — from SQL Server and SSIS to Fabric Data Factory, Python ETL, semantic modeling, and automated reporting.

The repository is intentionally structured to reflect a real‑world modernization journey, with clear folder boundaries, modular pipelines, and production‑grade documentation.

---

## 🧱 Architecture at a Glance

- **On‑Prem Foundations:** SQL Server, SSIS, SSAS, SSRS  
- **Modern Cloud ETL:** Azure Data Factory → Fabric Data Factory  
- **Python ETL:** Modular extract/transform/load pipelines  
- **Semantic Modeling:** SSAS Tabular → Power BI  
- **Automation:** Power Automate refresh orchestration  
- **Documentation:** Auto‑generated READMEs, repo hygiene, and folder‑level summaries  

This repo is designed to be both a technical showcase and a narrative artifact — demonstrating not just *what* was built, but *why* each modernization step matters.

---

## 📁 Repository Structure

The top‑level folders are intentionally prefixed to guide readers through the modernization flow:

| Prefix | Folder | Purpose |
|--------|--------|---------|
| **01‑** | azure‑data‑factory | Legacy ADF pipelines and assets |
| **02‑** | fabric‑data‑factory | Modern Fabric pipelines |
| **03‑** | sql‑server | SQL scripts, metadata, and database elements |
| **04‑** | ssis | Legacy ETL packages |
| **05‑** | ssas | Tabular model artifacts |
| **06‑** | ssrs | Reporting Services assets |
| **07‑** | power‑bi | PBIX files, M scripts, DAX, themes |
| **08‑** | power‑automate | Automated refresh flows |
| **09‑** | power‑apps | KPI Explorer app |
| **10‑** | python | ETL scripts and modular pipeline |
| **11‑** | powershell | Repo automation and documentation tooling |
| **12‑** | docs | Modernization notes, diagrams, and architecture |
| **13‑** | images | Branding and visual assets |

Each folder contains its own README, automatically generated for consistency.

---

## 🚀 Modernization Storyline

This project walks through a realistic modernization arc:

1. **Assess the legacy stack**  
2. **Extract and modularize SQL logic**  
3. **Migrate ETL from SSIS to Python + Fabric**  
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