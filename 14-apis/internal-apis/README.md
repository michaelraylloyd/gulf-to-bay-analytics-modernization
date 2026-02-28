# Internal API Integrations

This folder contains examples of consuming internal enterprise APIs, including Dataverse, Fabric, and Snowflake. These integrations demonstrate secure access to organizational systems and closed‑loop analytics patterns.

## Purpose
Internal APIs are common in enterprise environments. These examples show how authenticated services are accessed, how data is exchanged between systems, and how internal operations can be automated or enriched.

## Included Examples
- Dataverse Equipment API Consumer — Retrieves and updates equipment request records used across the GTB modernization project.
- Fabric KPI Adjuster API Consumer — Posts KPI adjustments into the Lakehouse to support closed‑loop BI.
- Snowflake Metadata API Consumer — Queries warehouse metadata for governance, lineage, and usage analytics.

## Technical Highlights
- Azure AD OAuth2 token acquisition  
- Secure API calls using bearer tokens  
- Integration with Dataverse tables and Fabric Lakehouse endpoints  
- JSON normalization and ingestion into Delta/Snowflake  
- Enterprise‑grade error handling and logging patterns  

## Dev → Prod Workflow
1. Develop API consumers in the Dev branch.  
2. Validate against Dev Dataverse/Fabric/Snowflake environments.  
3. Promote Dev → Main in Fabric.  
4. (Optional) Pull Main to Prod on‑prem for offline or scheduled execution.