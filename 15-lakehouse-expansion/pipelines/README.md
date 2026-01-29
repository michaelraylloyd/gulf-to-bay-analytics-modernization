# Gulf to Bay Analytics — Lakehouse Expansion

This subproject extends the Gulf to Bay Analytics modernization effort into a modern **Lakehouse architecture** using PySpark, Delta Lake, and real‑time ingestion patterns. It builds on the foundation established in the core modernization project and demonstrates how a traditional BI ecosystem can evolve into a scalable, cloud‑ready analytics platform.

## Purpose

The goal of this project is to showcase a Lakehouse‑style analytics environment that supports:

- Distributed compute with **PySpark**
- ACID‑compliant storage using **Delta Lake**
- Bronze → Silver → Gold **multi‑layered data modeling**
- **Real‑time ingestion** patterns (Auto Loader–style)
- Power BI semantic modeling on top of curated Gold tables
- CI/CD workflows for data engineering assets

This subproject highlights how modern data engineering practices can be integrated into an existing BI modernization initiative.

## Contents

This folder includes:

- **notebooks** — PySpark notebooks for ingestion, transformation, and modeling  
- **pipelines** — Batch and Delta Live Table (DLT) pipeline definitions  
- **delta** — Bronze, Silver, and Gold Delta Lake storage layers  
- **tests** — PySpark and Delta validation tests  
- **docs** — Architecture, pipeline walkthroughs, and Lakehouse design notes  
- **.github/workflows** — CI/CD scaffolding for future automation

## Modernization Context

As part of the end‑to‑end modernization strategy, this Lakehouse expansion demonstrates:

- How legacy BI systems can evolve into cloud‑ready analytics platforms  
- How distributed compute and Delta Lake improve scalability and reliability  
- How real‑time ingestion patterns complement traditional batch ETL  
- How structured documentation and SDLC discipline support long‑term maintainability  
- How a unified modernization narrative ties together SQL, Python, Power BI, and Lakehouse engineering

This subproject continues the modernization journey by introducing advanced data engineering capabilities while maintaining the same clarity, structure, and professionalism as the rest of the Gulf to Bay Analytics ecosystem.