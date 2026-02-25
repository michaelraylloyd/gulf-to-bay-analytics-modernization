# API Development (Build)

This folder contains APIs built as part of the GTB modernization project, including full CRUD operations, authentication, versioning, and Dev→Prod promotion. These APIs expose business operations as services and demonstrate senior‑level engineering patterns.

## Purpose
Building APIs shows the ability to design service boundaries, define contracts, implement secure endpoints, and integrate with enterprise systems. These examples represent real operational services used by applications and analytics pipelines.

## Included Projects
- Equipment Request API — A FastAPI/Azure Functions service that exposes CRUD operations for equipment requests stored in Dataverse. Includes OpenAPI documentation, authentication, and example consumers.
- KPI Adjuster API — A writeback API that posts KPI adjustments into the Fabric Lakehouse, enabling closed‑loop BI.
- Common Auth Module — Shared Azure AD authentication utilities for API development and consumption.

## Technical Highlights
- OpenAPI (Swagger) contract‑first design  
- FastAPI or Azure Functions implementation  
- Azure AD App Registration + OAuth2  
- Versioned endpoints (v1, v2)  
- Integration with Dataverse, Fabric, and Snowflake  
- Example consumers (Power Apps, Fabric pipelines, Databricks notebooks)  

## Dev → Prod Workflow
1. Build and test APIs in the Dev branch.  
2. Deploy Dev API to a Dev environment (local or Azure).  
3. Validate with Dev Dataverse/Fabric/Snowflake.  
4. Promote Dev → Main in Fabric.  
5. Deploy Main API to Prod environment.  
6. (Optional) Pull Main to Prod on‑prem for offline execution or archival.