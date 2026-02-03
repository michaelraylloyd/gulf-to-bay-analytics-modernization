# Gulf to Bay Analytics — End‑to‑End BI Modernization  
### Portfolio Overview — Michael Lloyd, Business Intelligence Developer

---

## Executive Summary

This portfolio showcases the complete modernization of Gulf to Bay Analytics from a fragmented, on‑prem Microsoft BI stack into a unified, cloud‑native analytics ecosystem built on Microsoft Fabric. The transformation spans SQL Server, SSIS, SSAS, and SSRS through Azure SQL, Lakehouse medallion architecture, Python ETL, Fabric Data Factory pipelines, a rebuilt Power BI semantic model, automated refreshes via Power Automate, and Power Apps for operational workflows. The project also includes a fully restructured Git‑based SDLC with feature branching, Dev/Main separation, and deterministic promotion patterns that mirror real enterprise engineering practices. This document provides a visual, narrative walkthrough of that journey, supported by architecture diagrams, screenshots, and detailed modernization notes.

---

## 1. Introduction

This document provides a visual, narrative walkthrough of the **Gulf to Bay Analytics Modernization Project**, demonstrating how a legacy Microsoft BI ecosystem was transformed into a clean, automated, cloud‑aligned analytics platform.

---

## 2. Legacy Environment Overview

<details>
<summary><strong>🏗️ Expanded Legacy Environment Overview</strong></summary>

- SQL Server as central data store  
- SSIS for nightly ETL  
- SSAS Tabular models with manual refresh  
- SSRS reports with independent datasets  
- Manual refresh cycles and fragmented logic  
- No version control or automation  

</details>

---

## 3. Modernization Goals

<details>
<summary><strong>🏗️ Expanded Modernization Goals</strong></summary>

- Decouple logic from SSIS  
- Migrate ETL to Python and Fabric  
- Rebuild semantic models  
- Automate refreshes with Power Automate  
- Standardize documentation  
- Establish version control and SDLC  

</details>

---

## 4. Repository Structure

<details>
<summary><strong>🗂️ Expanded Repository Structure Notes</strong></summary>

The repository is organized into modular, prefixed folders that reflect the modernization journey from legacy on‑prem components to cloud‑native Fabric architecture. This structure ensures:

- Clear separation of legacy vs. modern components  
- Easy navigation for recruiters and engineers  
- Consistent documentation and automation tooling  
- A narrative flow that mirrors the transformation arc  

</details>

| Prefix | Folder | Purpose |
|--------|--------|---------|
| **01‑** | azure‑data‑factory | Legacy ADF pipelines and assets |
| **02‑** | fabric‑data‑factory | Modern Fabric pipelines and orchestration |
| **03‑** | sql‑server | SQL scripts, metadata, and stored procedures |
| **04‑** | databricks | Optional expansion for Spark‑based workflows |
| **05‑** | dataverse | Power Platform data integration and hybrid modeling |
| **06‑** | ssis | Legacy ETL packages and migration references |
| **07‑** | ssas | Tabular model artifacts and semantic lineage |
| **08‑** | ssrs | Reporting Services assets and paginated reports |
| **09‑** | power‑bi | PBIX files, M scripts, DAX, and semantic models |
| **10‑** | power‑automate | Automated refresh flows and alerting logic |
| **11‑** | power‑apps | KPI Explorer and operational workflow apps |
| **12‑** | fabric‑sales‑analytics | Lakehouse medallion architecture, notebooks, DQ subsystem |
| **assets** | assets | Branding, icons, and visual elements |
| **docs** | docs | Architecture diagrams, modernization notes, and README files |
| **tools** | tools | PowerShell scripts and repo automation utilities |

---

## 5. SQL Server Modernization

SQL Server objects were modernized, standardized, and prepared for migration into the cloud‑aligned architecture.

<details>
<summary><strong>🧱 SQL Modernization Highlights</strong></summary>

- Consolidated legacy stored procedures  
- Standardized naming and formatting  
- Introduced metadata‑driven patterns  
- Prepared schema for Lakehouse migration  
- Applied GTB SQL formatting conventions  

</details>

### 🧱 SQL Server  
![alt text](assets/images/portfolio-overview/SQL_Server.png)

---

## 6. ETL Migration (SSIS → Azure Data Factory → Fabric Python Notebooks and Pipeline Deployment)

The ETL pipeline evolved from SSIS packages to ADF pipelines and ultimately to Fabric‑native Lakehouse Python and Pipeline orchestration.

<details>
<summary><strong>🔄 ETL Migration Highlights</strong></summary>

- SSIS package inventory and logic extraction  
- ADF pipeline orchestration for cloud ETL  
- Fabric Lakehouse Python Notebooks
- Fabric Data Factory Pipeline migration for unified governance  
- Parameterized pipelines and reusable components  
- Incremental migration strategy  

</details>

### 🔄 ETL Migration

<strong>🔄 SSIS</strong>
![alt text](assets/images/portfolio-overview/SSIS.png)  

<strong>🔄 Azure Data Factory Pipelines</strong>
![alt text](assets/images/portfolio-overview/Azure_Data_Factory_Pipeline.png)

<strong>🔄 Fabric Python Notebooks</strong>
![alt text](assets/images/portfolio-overview/Fabric_Python_Notebook_Header.png)
![alt text](assets/images/portfolio-overview/Fabric_Python_Notebook_Code.png)
![alt text](assets/images/portfolio-overview/Fabric_Python_Notebook_Footer.png)

<strong>🔄 Fabric Pipelines</strong>
![alt text](assets/images/portfolio-overview/Fabric_Pipeline.png)

---

## 7. Semantic Modeling (SSAS → Fabric Lakehouse to Power BI)

The semantic layer was rebuilt in both Fabric Lakehouse and Power BI, replacing SSAS Tabular with a modern, cloud‑aligned model.

<details>
<summary><strong>📊 Semantic Modeling Highlights</strong></summary>

- SSAS Tabular model analysis and extraction
- Rebuilt in Fabric Lakehouse semantic model  
- Rebuilt Power BI semantic model  
- Star schema alignment with Lakehouse views  
- DAX standardization and KPI definitions  
- Automated refresh integration  

</details>

### 📊 Semantic Modeling

<strong>📊 SSAS</strong>
![alt text](assets/images/portfolio-overview/SSAS.png)

<strong>📊 Lakehouse Semantic Model</strong>
![alt text](assets/images/portfolio-overview/Fabric_Lakehouse_Semantic_Model.png)

<strong>📊 Power BI Semantic Model</strong>
![alt text](assets/images/portfolio-overview/Power_BI_Snowflake_Schema.png)

---

## 8. Python ETL Pipeline — Cloud Migration & Data Synchronization

Python notebooks were introduced to handle ingestion, transformation, and synchronization across cloud layers.

<details>
<summary><strong>🐍 Python ETL Highlights</strong></summary>

- Modular notebook‑based ETL  
- Pandas and PySpark transformations  
- Lakehouse ingestion and write‑back  
- DQ rule execution and logging  
- Cloud‑ready orchestration design  

</details>

### 🐍 Python ETL  
![alt text](assets/images/portfolio-overview/Python.png)

---

## 9. Lakehouse Architecture (Bronze → Silver → Gold)

A full medallion architecture was implemented to support scalable analytics and semantic modeling.

<details>
<summary><strong>🏛️ Lakehouse Architecture Highlights</strong></summary>

- Bronze ingestion via Python and Dataflows  
- Silver standardization and DQ enforcement  
- Gold star schema modeling  
- Metadata‑driven table creation  
- Notebook‑based transformations  

</details>

### 🏛️ Lakehouse Architecture

<strong>🏛️ Python Bronze Notebook</strong>
![alt text](assets/images/portfolio-overview/Fabric_Python_Notebook_Bronze.png)

<strong>🏛️ Python Silver Notebook</strong>
![alt text](assets/images/portfolio-overview/Fabric_Python_Notebook_Silver.png)

<strong>🏛️ Python Gold Notebook</strong>
![alt text](assets/images/portfolio-overview/Fabric_Python_Notebook_Gold.png)

---

## 10. Fabric Dataflows and M Queries

Fabric Dataflows provide reusable, GUI‑driven ingestion and transformation logic using M.

<details>
<summary><strong>🧮 Dataflow Highlights</strong></summary>

- Lakehouse‑connected dataflows  
- M code transformations  
- CSV ingestion via Lakehouse.Contents  
- View creation and metadata alignment  
- Power Query editor integration  

</details>

### 🧮 Dataflow Highlight
<strong>🧮 Power Query</strong>
![alt text](assets/images/portfolio-overview/Fabric_Dataflow_Power_Query.png)

<strong>🧮 M Query</strong>
![alt text](assets/images/portfolio-overview/Fabric_Dataflow_M.png)

---

## 11. Lakehouse SQL Views and Metadata Alignment

SQL views were created directly in the Lakehouse to support semantic modeling and reporting.

<details>
<summary><strong>🪵 View Creation Highlights</strong></summary>

- Modular SQL views for Gold layer  
- Surrogate key logic  
- Joinable star schema tables  
- Metadata‑driven naming and formatting  
- GTB SQL formatting applied  

</details>

### 🪵 Lakehouse SQL Queries and Views  
![alt text](assets/images/portfolio-overview/Fabric_Lakehouse_Queries_Views.png)

---

## 12. Fabric Pipeline Orchestration (Planned)

The Fabric pipeline will orchestrate the full ETL flow, including notebook execution and semantic refresh.

<details>
<summary><strong>⚙️ Pipeline Design Highlights</strong></summary>

- Triggered by schedule or manual run  
- Executes Python notebooks in sequence  
- Validates DQ rules  
- Refreshes semantic model  
- Logs execution and exceptions  

</details>

### ⚙️ Fabric Pipeline  
![alt text](assets/images/portfolio-overview/Fabric_Pipeline.png)

---

## 13. Data Quality Subsystem

A dedicated DQ subsystem validates, logs, and enforces data quality rules across the pipeline.

<details>
<summary><strong>🧪 Data Quality Highlights</strong></summary>

- Rule‑based validation framework  
- Notebook‑driven DQ execution  
- Logging and exception capture  
- Integration with Silver layer  
- Supports pipeline orchestration  

</details>

### 🧪 Data Quality  
![alt text](assets/images/portfolio-overview/Fabric_Python_Notebook_Silver_DQ.png)

---

## 14. Reporting & Dashboards

Power BI dashboards deliver executive‑ready KPIs and operational insights.

<details>
<summary><strong>📈 Reporting Highlights</strong></summary>

- Rebuilt KPI model  
- Global and regional metrics  
- Drill‑through and detail pages  
- Consistent visual branding  
- Automated refresh integration  

</details>

### 📈 Power BI Revenue Stream KPI Overview

<strong>Gulf-To-Bay Analytics Revenue Stream KIP Overview</strong> Available to Public at: https://app.powerbi.com/view?r=eyJrIjoiMzcyYTIzN2EtYzBjNi00MmY5LWJhY2UtZDk5MDkyZTYwNDExIiwidCI6ImE0MzI2YTU4LWY3ZDktNDQ0ZC1iM2FhLWIwOTAyN2U1ZTg2NiIsImMiOjF9

### 📈 Revenue Stream KPI Overview - Global KPIs

[![alt text](assets/images/portfolio-overview/Rev_Stream_KPI_Overview_Global_KPIs.png)](https://app.powerbi.com/view?r=eyJrIjoiMzcyYTIzN2EtYzBjNi00MmY5LWJhY2UtZDk5MDkyZTYwNDExIiwidCI6ImE0MzI2YTU4LWY3ZDktNDQ0ZC1iM2FhLWIwOTAyN2U1ZTg2NiIsImMiOjF9)

### 📈 Revenue Stream KPI Overview - Sales KPIs
[![alt text](assets/images/portfolio-overview/Rev_Stream_KPI_Overview_Sales_KPIs.png)](https://app.powerbi.com/view?r=eyJrIjoiMzcyYTIzN2EtYzBjNi00MmY5LWJhY2UtZDk5MDkyZTYwNDExIiwidCI6ImE0MzI2YTU4LWY3ZDktNDQ0ZC1iM2FhLWIwOTAyN2U1ZTg2NiIsImMiOjF9)

### 📈 Revenue Stream KPI Overview - Orders KPIs
[![alt text](assets/images/portfolio-overview/Rev_Stream_KPI_Overview_Orders_KPIs.png)](https://app.powerbi.com/view?r=eyJrIjoiMzcyYTIzN2EtYzBjNi00MmY5LWJhY2UtZDk5MDkyZTYwNDExIiwidCI6ImE0MzI2YTU4LWY3ZDktNDQ0ZC1iM2FhLWIwOTAyN2U1ZTg2NiIsImMiOjF9)

### 📈 Revenue Stream KPI Overview - Customer KPIs
[![alt text](assets/images/portfolio-overview/Rev_Stream_KPI_Overview_Customers_KPIs.png)](https://app.powerbi.com/view?r=eyJrIjoiMzcyYTIzN2EtYzBjNi00MmY5LWJhY2UtZDk5MDkyZTYwNDExIiwidCI6ImE0MzI2YTU4LWY3ZDktNDQ0ZC1iM2FhLWIwOTAyN2U1ZTg2NiIsImMiOjF9)

### 📈 Revenue Stream KPI Overview - Details
[![alt text](assets/images/portfolio-overview/Rev_Stream_KPI_Overview_Details.png)](https://app.powerbi.com/view?r=eyJrIjoiMzcyYTIzN2EtYzBjNi00MmY5LWJhY2UtZDk5MDkyZTYwNDExIiwidCI6ImE0MzI2YTU4LWY3ZDktNDQ0ZC1iM2FhLWIwOTAyN2U1ZTg2NiIsImMiOjF9)

---

## 15. Power Automate — Refresh & Notifications

Power Automate flows handle scheduled refreshes and alerting across the analytics ecosystem.

<details>
<summary><strong>🔔 Power Automate Highlights</strong></summary>

- Scheduled dataset refreshes  
- Failure notifications  
- Semantic model refresh triggers  
- Integration with Fabric and Power BI  
- Logging and monitoring  

</details>

### 🔔 Power Automate  
![alt text](assets/images/portfolio-overview/Power_Automate_Refresh_Semantic_Models.png)

---

## 16. Power Apps — KPI Explorer

A Power Apps interface provides interactive KPI exploration for business users<strong>📱 Power.

<details>
<summary> Apps Highlights</strong></summary>

- KPI Explorer app  
- Drill‑down navigation  
- Embedded Power BI visuals  
- Role‑based access patterns  
- Operational workflow integration  

</details>

### 📱 Power Apps
![alt text](assets/images/portfolio-overview/Power_Apps_KPI_Explorer.png)

---

## 17. Documentation & Repo Hygiene

Documentation and automation scripts ensure a clean, discoverable, and recruiter‑ready repository.

<details>
<summary><strong>🧼 Repo Hygiene Highlights</strong></summary> files  
- Consistent

- Modular README folder‑level documentation  
- PowerShell automation utilities  
- Deterministic Dev/Main/Prod structure  
- Screenshot‑driven modernization narrative  

</details>

### 🧼 Repo Hygiene  
![alt text](assets/images/portfolio-overview/PowerShell.png)

---

## 18. SDLC Evolution — From PowerShell to GitKraken Branching

<details>
<summary><strong>🔧 SDLC Timeline</strong></summary>

- Phase 1: No version control  
- Phase 2: PowerShell‑based Dev/Prod checks  
- Phase 3: GitKraken branching and commits  
- Feature branches → Dev → Main → Manual PROD publish  
- GitHub commit history and milestone tagging  

</details>

### 🔧 Git Branch Protection and GitKraken Workflows

### 🔧 Git Branch Protection Rules
![alt text](assets/images/portfolio-overview/Git_Feature_Branch_Protection_Header.png)
![alt text](assets/images/portfolio-overview/Git_Feature_Branch_Protection_Rules.png)

### 🔧 Git Kracken Workflow
![alt text](assets/images/portfolio-overview/Git_Kracken_Workflow.png)

---

## 19. Architecture Diagram  
![alt text](assets/images/portfolio-overview/Architecture_Diagram.png)

---

## 20. About the Developer

**Michael Lloyd**  
Business Intelligence Developer  
Gulf to Bay Analytics  
Clearwater, FL  

- SQL Server, SSIS, SSAS, SSRS  
- Python ETL  
- Fabric Data Factory  
- Power BI  
- Power Automate  
- Metadata‑driven design  
- Modernization strategy  

---

## 21. Contact

- GitHub: https://github.com/michaelraylloyd  
- LinkedIn: https://www.linkedin.com/in/michael-lloyd-7aa62250/  
- Email: [mrlloyd9@gmail.com](mailto:mrlloyd9@gmail.com)

---