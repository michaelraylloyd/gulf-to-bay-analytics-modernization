# Gulf to Bay Analytics — End‑to‑End BI Modernization  
### Portfolio Overview — Michael Lloyd, Business Intelligence Developer

---

## Executive Summary

This portfolio presents the end‑to‑end modernization of Gulf to Bay Analytics from a fragmented, on‑premises Microsoft BI stack into a unified, cloud‑native analytics ecosystem built on Microsoft Fabric. The transformation spans SQL Server, SSIS, SSAS, and SSRS through Azure SQL, Fabric Lakehouse medallion architecture, Python‑based ETL, Fabric Data Factory pipelines, Databricks notebooks, Eventstream‑to‑Eventhouse real‑time ingestion, and a rebuilt Power BI semantic model. Operational workflows are delivered through Power Apps and Dataverse, with automated refresh and orchestration handled by Power Automate. The modernization is anchored by a fully restructured Git‑based SDLC featuring feature branching, Dev/Main separation, Fabric workspace source control, and deterministic promotion patterns that mirror enterprise engineering standards. This document provides a visual, narrative walkthrough of that journey, supported by architecture diagrams, screenshots, and detailed modernization notes.

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
| **01‑** | sql-server | SQL scripts, metadata, stored procedures, and legacy schema assets |
| **02‑** | ssis | Legacy SSIS ETL packages and migration references |
| **03‑** | ssas | Tabular model artifacts, semantic definitions, and lineage |
| **04‑** | ssrs | Reporting Services assets and paginated report definitions |
| **05‑** | azure-data-factory | Legacy ADF pipelines, mappings, and modernization notes |
| **06‑** | fabric-lakehouse | Full Fabric medallion architecture (Bronze/Silver/Gold), notebooks, pipelines, semantic model, and DQ subsystem |
| **07‑** | databricks | Spark notebooks, workflows, and future expansion for Lakehouse compute |
| **08‑** | power-bi | PBIX files, M scripts, DAX, semantic models, and report assets |
| **09‑** | power-automate | Automated refresh flows, orchestration logic, and operational alerts |
| **10‑** | power-apps | KPI Explorer, Equipment Requests, and operational workflow applications |
| **11‑** | dataverse | Dataverse tables, solutions, and Power Platform data integration |
| **12‑** | eventhouse | Eventstream ingestion, KQL database, real‑time telemetry, and streaming analytics |
| **assets** | assets | Branding, icons, screenshots, and visual elements |
| **docs** | docs | Architecture diagrams, modernization notes, READMEs, and narrative documentation |
| **tools** | tools | PowerShell automation scripts, repo utilities, and lock‑resolution helpers |

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
![alt text](../../assets/images/portfolio-overview/SQL_Server.png)

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
![alt text](../../assets/images/portfolio-overview/SSIS.png)  

<strong>🔄 Azure Data Factory Pipelines</strong>
![alt text](../../assets/images/portfolio-overview/Azure_Data_Factory_Pipeline.png)

<strong>🔄 Fabric Python Notebooks</strong>
![alt text](../../assets/images/portfolio-overview/Fabric_Python_Notebook_Header.png)
![alt text](../../assets/images/portfolio-overview/Fabric_Python_Notebook_Code.png)
![alt text](../../assets/images/portfolio-overview/Fabric_Python_Notebook_Footer.png)

<strong>🔄 Fabric Pipelines</strong>
![alt text](../../assets/images/portfolio-overview/Fabric_Pipeline.png)

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
![alt text](../../assets/images/portfolio-overview/SSAS.png)

<strong>📊 Lakehouse Semantic Model</strong>
![alt text](../../assets/images/portfolio-overview/Fabric_Lakehouse_Semantic_Model.png)

<strong>📊 Power BI Semantic Model</strong>
![alt text](../../assets/images/portfolio-overview/Power_BI_Star_Schema.png)

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
![alt text](../../assets/images/portfolio-overview/Python.png)

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
![alt text](../../assets/images/portfolio-overview/Fabric_Python_Notebook_Bronze.png)

<strong>🏛️ Python Silver Notebook</strong>
![alt text](../../assets/images/portfolio-overview/Fabric_Python_Notebook_Silver.png)

<strong>🏛️ Python Gold Notebook</strong>
![alt text](../../assets/images/portfolio-overview/Fabric_Python_Notebook_Gold.png)

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
![alt text](../../assets/images/portfolio-overview/Fabric_Dataflow_Power_Query.png)

<strong>🧮 M Query</strong>
![alt text](../../assets/images/portfolio-overview/Fabric_Dataflow_M.png)

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
![alt text](../../assets/images/portfolio-overview/Fabric_Lakehouse_Queries_Views.png)

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
![alt text](../../assets/images/portfolio-overview/Fabric_Pipeline.png)

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
![alt text](../../assets/images/portfolio-overview/Fabric_Python_Notebook_Silver_DQ.png)

---

## 14. Reporting & Dashboards

Power BI dashboards deliver executive‑ready KPIs and operational insights.

<details>
<summary><strong>📈 Reporting Highlights</strong></summary>

- SSRS paginated reporting
- Rebuilt KPI model  
- Global and regional DAX metrics  
- Drill‑through and detail pages  
- Consistent visual branding  
- Automated refresh integration  

</details>

### 📈 SSRS Paginated Report
![alt text](../../assets/images/portfolio-overview/SSRS.png)

### 📈 Power BI Revenue Stream KPI Overview

<strong>Gulf-To-Bay Analytics Revenue Stream KIP Overview</strong> Available to Public at: https://app.powerbi.com/view?r=eyJrIjoiMzcyYTIzN2EtYzBjNi00MmY5LWJhY2UtZDk5MDkyZTYwNDExIiwidCI6ImE0MzI2YTU4LWY3ZDktNDQ0ZC1iM2FhLWIwOTAyN2U1ZTg2NiIsImMiOjF9

<strong>📈 Revenue Stream KPI Overview - Global KPIs</strong>
[![alt text](../../assets/images/portfolio-overview/Rev_Stream_KPI_Overview_Global_KPIs.png)](https://app.powerbi.com/view?r=eyJrIjoiMzcyYTIzN2EtYzBjNi00MmY5LWJhY2UtZDk5MDkyZTYwNDExIiwidCI6ImE0MzI2YTU4LWY3ZDktNDQ0ZC1iM2FhLWIwOTAyN2U1ZTg2NiIsImMiOjF9)

<strong>📈 Revenue Stream KPI Overview - Sales KPIs</strong>
[![alt text](../../assets/images/portfolio-overview/Rev_Stream_KPI_Overview_Sales_KPIs.png)](https://app.powerbi.com/view?r=eyJrIjoiMzcyYTIzN2EtYzBjNi00MmY5LWJhY2UtZDk5MDkyZTYwNDExIiwidCI6ImE0MzI2YTU4LWY3ZDktNDQ0ZC1iM2FhLWIwOTAyN2U1ZTg2NiIsImMiOjF9)

<strong>📈 Revenue Stream KPI Overview - Orders KPIs</strong>
[![alt text](../../assets/images/portfolio-overview/Rev_Stream_KPI_Overview_Orders_KPIs.png)](https://app.powerbi.com/view?r=eyJrIjoiMzcyYTIzN2EtYzBjNi00MmY5LWJhY2UtZDk5MDkyZTYwNDExIiwidCI6ImE0MzI2YTU4LWY3ZDktNDQ0ZC1iM2FhLWIwOTAyN2U1ZTg2NiIsImMiOjF9)

<strong>📈 Revenue Stream KPI Overview - Customer KPIs</strong>
[![alt text](../../assets/images/portfolio-overview/Rev_Stream_KPI_Overview_Customers_KPIs.png)](https://app.powerbi.com/view?r=eyJrIjoiMzcyYTIzN2EtYzBjNi00MmY5LWJhY2UtZDk5MDkyZTYwNDExIiwidCI6ImE0MzI2YTU4LWY3ZDktNDQ0ZC1iM2FhLWIwOTAyN2U1ZTg2NiIsImMiOjF9)

<strong>📈 Revenue Stream KPI Overview - Details</strong>
[![alt text](../../assets/images/portfolio-overview/Rev_Stream_KPI_Overview_Details.png)](https://app.powerbi.com/view?r=eyJrIjoiMzcyYTIzN2EtYzBjNi00MmY5LWJhY2UtZDk5MDkyZTYwNDExIiwidCI6ImE0MzI2YTU4LWY3ZDktNDQ0ZC1iM2FhLWIwOTAyN2U1ZTg2NiIsImMiOjF9)

<strong>📈 DAX</strong>
![alt text](../../assets/images/portfolio-overview/Power_BI_DAX.png)

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
![alt text](../../assets/images/portfolio-overview/Power_Automate_Refresh_Semantic_Models.png)

---

## 16. Power Apps

A Power Apps interface provides interactive KPI exploration for business users<strong>📱 Power.

<details>
<summary><strong>Apps Highlights</strong></summary>

- KPI Explorer app
  - Drill‑down navigation
  - Embedded Power BI visuals
  - Role‑based access patterns
  - Operational workflow integration

- Equipment Request app
  - Data intake to Dataverse table
  - Role‑based access and approval routing
  - Quick‑access page for approvers
  - Embedded Power BI dashboard and details

</details>


### 📱 Power Apps

<strong>KPI Explorer</strong>
![alt text](../../assets/images/portfolio-overview/Power_Apps_KPI_Explorer.png)

<strong>Equipment Requests - Pending Approval</strong>
![alt text](../../assets/images/portfolio-overview/Power_Apps_Equipment_Requests_Pending_Approval.png)

<strong>Equipment Requests - Edit</strong>
![alt text](../../assets/images/portfolio-overview/Power_Apps_Equipment_Requests_Edit.png)

<strong>Equipment Requests - Dashboard</strong>
![alt text](../../assets/images/portfolio-overview/Power_Apps_Equipment_Requests_Dashboard.png)

<strong>Equipment Requests - Details</strong>
![alt text](../../assets/images/portfolio-overview/Power_Apps_Equipment_Requests_Details.png)

### 🟪📁 Dataverse Table - Equipment Requests
![alt text](../../assets/images/portfolio-overview/Dataverse_Table_EquipmentRequests.png)

---

## 17. Eventhouse

Eventhouse provides the real‑time analytics layer within the modernization ecosystem, enabling continuous ingestion, storage, and querying of streaming data. In this project, an Eventstream pipeline writes live S&P 500 market data into the Eventhouse database, making it immediately available for KQL‑based validation, profiling, and downstream analytics.

<details>
<summary><strong>Eventhouse Highlights</strong></summary>

- Real‑time ingestion through Eventstream  
- Continuous writes to the **Sp500Stocks** table  
- KQL‑based exploration and validation  
- Support for time‑series analytics and anomaly detection  
- Integration with downstream Fabric components  
- Foundation for dashboards, alerting, and automated insights  

</details>

### 📡 Eventhouse - S&P 500 Eventstream
![alt text](../../assets/images/portfolio-overview/Fabric_Eventhouse_Eventstream.png)

### 📡 Eventhouse - KQL Database
![alt text](../../assets/images/portfolio-overview/Fabric_Eventhouse_KQL_Database.png)

---

## 18. Documentation & Repo Hygiene

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
![alt text](../../assets/images/portfolio-overview/PowerShell.png)

---

## 19. SDLC Evolution — Introducing Fabric Workspace Source Control

Fabric’s built‑in Git integration extends the modernization SDLC into the analytics workspace itself, allowing Lakehouses, Eventhouses, Pipelines, Notebooks, and Power BI artifacts to participate in the same branch‑based workflow used across the rest of the repo. Source control now provides full visibility into workspace changes, commit history, and promotion patterns across feature, dev, and main branches.

<details>
<summary><strong>🔧 SDLC Timeline</strong></summary>

- Phase 1: No version control  
- Phase 2: PowerShell‑based Dev/Prod checks  
- Phase 3: GitKraken branching and commit discipline  
- Phase 4: Fabric Workspace Git integration  
  - Workspace items tracked directly in Git  
  - Branch‑based development inside Fabric  
  - Commit, diff, and merge visibility for notebooks, pipelines, and Eventhouse assets  
  - Real‑time sync of workspace changes to feature → dev → main  
  - Source‑controlled Eventstream, Eventhouse, and Lakehouse definitions  

</details>

### 🔧 Git Branch Protection and GitKraken Workflows

### 🔧 Git Branch Protection Rules
![alt text](../../assets/images/portfolio-overview/Git_Feature_Branch_Protection_Header.png)
![alt text](../../assets/images/portfolio-overview/Git_Feature_Branch_Protection_Rules.png)

### 🔧 Git Kracken Workflow
![alt text](../../assets/images/portfolio-overview/Git_Kracken_Workflow.png)

### 🔧 Fabric Workspace Source Control
![alt text](../../assets/images/portfolio-overview/Fabric_Workspace_Source_Control.png)

---

## 20. Architecture Diagram  
![alt text](../../assets/images/portfolio-overview/Architecture_Diagram.png)

---

## 21. About the Developer

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

## 22. Contact

- GitHub: https://github.com/michaelraylloyd  
- LinkedIn: https://www.linkedin.com/in/michael-lloyd-7aa62250/  
- Email: [mrlloyd9@gmail.com](mailto:mrlloyd9@gmail.com)

---