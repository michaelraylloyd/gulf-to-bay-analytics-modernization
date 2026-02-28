# Equipment Request API

This API exposes CRUD operations for equipment requests stored in Dataverse. It is implemented using FastAPI or Azure Functions and secured with Azure AD OAuth2. The API supports integration with Power Apps, Fabric pipelines, and Databricks notebooks.

## Purpose
The Equipment Request API provides a clean service boundary for managing equipment requests across the GTB modernization ecosystem. It demonstrates contract‑first API design, secure authentication, and integration with enterprise data systems.

## Endpoints (v1)
- GET `/equipment-requests` — Retrieve all equipment requests.  
- GET `/equipment-requests/{id}` — Retrieve a single request by ID.  
- POST `/equipment-requests` — Create a new equipment request.  
- PATCH `/equipment-requests/{id}` — Update an existing request.  
- DELETE `/equipment-requests/{id}` — Remove a request (optional for portfolio).

## Technical Highlights
- FastAPI or Azure Functions implementation  
- OpenAPI specification included (`openapi.yaml`)  
- Azure AD App Registration + OAuth2  
- Dataverse integration using Web API endpoints  
- Pydantic models for request/response validation  
- Example consumers (Power Apps, Fabric pipeline, Databricks notebook)

## Dev → Prod Workflow
1. Develop and test the API in the Dev branch.  
2. Deploy Dev API to a Dev environment.  
3. Validate with Dev Dataverse and Fabric.  
4. Promote Dev → Main in Fabric.  
5. Deploy Main API to Prod environment.  
6. (Optional) Pull Main to Prod on‑prem for archival or offline execution.