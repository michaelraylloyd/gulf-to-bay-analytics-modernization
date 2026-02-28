# External API Integrations

This folder contains examples of consuming third‑party APIs and integrating external data sources into the GTB modernization ecosystem. These examples demonstrate authentication, pagination, schema normalization, and ingestion into the Lakehouse or Snowflake layers.

## Purpose
External API ingestion is a core competency for modern data engineering. These examples show how outside data can be pulled, transformed, and incorporated into enterprise analytics pipelines.

## Included Examples
- NOAA Weather API — Retrieves historical and forecast weather data to enrich operational analytics and equipment‑usage modeling.
- US Census API — Pulls demographic and geographic data for customer segmentation and KPI enrichment.
- OpenFDA API — Demonstrates large‑scale JSON ingestion, pagination, and schema flattening.

## Technical Highlights
- REST API consumption using Python or PowerShell  
- OAuth2 / API key authentication patterns  
- Pagination, rate‑limit handling, and retry logic  
- JSON → Delta/Snowflake ingestion  
- Integration with Fabric pipelines and Databricks notebooks  

## Dev → Prod Workflow
1. Develop and test ingestion logic in the Dev branch.  
2. Validate transformations and Lakehouse loads in the Dev workspace.  
3. Promote Dev → Main in Fabric.  
4. (Optional) Pull Main to Prod on‑prem for archival or offline execution.