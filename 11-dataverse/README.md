# Dataverse — Operational Data Layer (Coming Online)

This folder represents the starting point for the Dataverse portion of the Gulf to Bay modernization project.  
Dataverse serves as the **operational data layer** of the Microsoft Power Platform, providing structured, governed storage for Power Apps, Power Automate flows, and business processes.

This directory is intentionally lightweight. As the Dataverse implementation grows, additional components will be added in a controlled, solution‑driven way.

---

## Purpose

Dataverse complements the analytical Lakehouse layers (Fabric and Databricks) by providing:

- A secure, relational data store for operational apps  
- Native integration with Power Apps and Power Automate  
- Business rules, validation, and row‑level security  
- Solution packaging for proper ALM and deployment  
- A governed alternative to SharePoint lists and Excel‑based processes  

This folder will eventually contain the artifacts that define the Dataverse data model and its supporting solutions.

---

## Folder Structure

### `solutions/`
A placeholder for Dataverse **Solutions**, the packaging unit used for:

- Tables  
- Relationships  
- Business rules  
- Power Apps  
- Power Automate flows  
- Security roles  

Nothing is committed yet. This folder will grow as the Dataverse environment is built out.

### `tables/`
A placeholder for table definitions, schema documentation, and metadata exports.  
This will eventually include:

- Table schemas  
- Column definitions  
- Relationship diagrams  
- Data model notes  

---

## How Dataverse Fits Into the Modernization Arc

Dataverse represents the **operational** side of the modernization story:

- **Operational data** → Dataverse  
- **Analytical data** → Fabric Lakehouse, Databricks Lakehouse  
- **Source systems** → SQL Server, Azure SQL  
- **BI & reporting** → Power BI  

This structure allows the Gulf to Bay ecosystem to support both:

- **Business applications** (Power Apps + Power Automate)  
- **Enterprise analytics** (Fabric + Databricks)  

---

## Current Status

This folder is a scaffold.  
As Dataverse components are created, they will be added here in a structured, solution‑driven manner.