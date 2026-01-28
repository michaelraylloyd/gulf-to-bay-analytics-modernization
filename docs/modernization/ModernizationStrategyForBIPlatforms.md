# 🌊 **Gulf to Bay Analytics**  
### **End‑to‑End Modernization of the Enterprise BI Ecosystem**

A full modernization journey demonstrating how a traditional Microsoft BI stack evolves into a cloud‑ready, automated analytics platform. This repo blends legacy systems, cloud migration, semantic modeling, orchestration, and documentation into a single, portfolio‑grade case study.

---

# ⭐ **Recruiter‑Friendly Summary**

This project showcases my ability to modernize an entire BI ecosystem — from SQL Server, SSIS, SSAS, and SSRS to Azure Data Factory, Microsoft Fabric, Python ETL, Power BI, and Power Automate. It demonstrates real‑world architecture thinking, cloud migration patterns, automation, and clean engineering practices across the full analytics lifecycle.

If you're evaluating my technical depth, modernization experience, or ability to deliver end‑to‑end BI solutions, this repository is the best place to start.

---

# 🚀 **Skills Demonstrated in This Project**

### **Modern Data Engineering**
- Metadata‑driven ETL design  
- Python‑based pipelines replacing SSIS  
- Cloud‑ready orchestration patterns  
- Logging, auditing, and idempotent execution  

### **Cloud & Hybrid Architecture**
- Azure SQL Database  
- Azure Data Factory → Fabric Data Factory migration  
- Data Lake / Blob Storage integration  
- Gateway‑based hybrid connectivity  

### **Semantic Modeling**
- SSAS Tabular → Power BI semantic model migration  
- Calculation groups, RLS, incremental refresh  
- Dataflows for staged transformations  

### **Reporting & Visualization**
- SSRS → Power BI dashboard modernization  
- KPI design, drill‑through, cross‑filtering  
- Performance tuning with VertiPaq Analyzer  

### **Automation & Governance**
- Power Automate refresh pipelines  
- End‑to‑end orchestration (ADF → Fabric → Power BI)  
- Clean repo hygiene, documentation, and reproducibility  

---

# 🧭 **How to Navigate This Repo**

The repository mirrors a real enterprise BI ecosystem. Each folder contains its own README and documentation.

```
azure-data-factory/
    pipelines/          → Legacy ADF pipelines (JSON)
    datasets/           → Dataset definitions
    linked-services/    → Connection metadata
    triggers/           → Scheduling logic

fabric-data-factory/
    pipelines/          → Fabric pipeline JSON + documentation
    dataflows/          → Dataflow Gen2 definitions
    connections/        → Gateway + Fabric connection docs

power-automate/
    flows/              → Flow exports (definition.json, manifest.json)

sql/
    tables/             → Table DDL
    views/              → View definitions
    stored-procedures/  → DW logic
    scripts/            → Utility SQL scripts

docs/
    modernization/      → Architecture notes, strategy, diagrams
```

**Recommended starting points:**
- `README.md` (this document)  
- `docs/modernization/`  
- `azure-data-factory/pipelines/`  
- `fabric-data-factory/pipelines/`  
- `power-automate/flows/`  

---

# 🏗️ **Modernization Architecture Diagram (Text‑Based)**

```
                         ┌──────────────────────────────┐
                         │      AdventureWorks OLTP     │
                         └───────────────┬──────────────┘
                                         │
                                         ▼
                         ┌──────────────────────────────┐
                         │        SSIS (Legacy)         │
                         └───────────────┬──────────────┘
                                         │
                                         ▼
                         ┌──────────────────────────────┐
                         │       SQL Server (DW)        │
                         └───────────────┬──────────────┘
                                         │
                                         ▼
        ┌──────────────────────────────────────────────────────────────┐
        │                     Modernization Path                       │
        └──────────────────────────────────────────────────────────────┘
                                         │
                                         ▼
        ┌──────────────────────────────────────────────────────────────┐
        │        Python ETL (Metadata‑Driven Pipelines)                │
        └───────────────┬──────────────────────────────────────────────┘
                        │
                        ▼
        ┌──────────────────────────────────────────────────────────────┐
        │     Azure SQL / Data Lake / Blob Storage                     │
        └───────────────┬──────────────────────────────────────────────┘
                        │
                        ▼
        ┌──────────────────────────────────────────────────────────────┐
        │   ADF Pipelines → Fabric Data Factory Pipelines              │
        └───────────────┬──────────────────────────────────────────────┘
                        │
                        ▼
        ┌──────────────────────────────────────────────────────────────┐
        │   Power BI Dataflows → Semantic Models (Cloud)               │
        └───────────────┬──────────────────────────────────────────────┘
                        │
                        ▼
        ┌──────────────────────────────────────────────────────────────┐
        │   Power BI Dashboards + Power Automate Refresh               │
        └──────────────────────────────────────────────────────────────┘
```


---

# 📘 **Polished Repo Header Section**

```
# 🌊 Gulf to Bay Analytics  
### Modernizing the Enterprise BI Ecosystem from On‑Prem to Cloud

This repository documents a complete BI modernization journey — from SQL Server, SSIS, SSAS, and SSRS to Azure Data Factory, Microsoft Fabric, Python ETL, Power BI, and Power Automate. It is designed as a real‑world, portfolio‑grade demonstration of how legacy analytics systems evolve into modern, automated, cloud‑ready architectures.