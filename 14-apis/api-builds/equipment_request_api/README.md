# Equipment Request API  
A secure, contract‑first REST API for managing Equipment Requests stored in Microsoft Dataverse.  
Built with **FastAPI**, **OAuth2 (Azure AD)**, and a clean, modernization‑aligned architecture designed for real‑world enterprise integration.

---

## 🚀 Purpose

The Equipment Request API provides a unified service boundary for creating, retrieving, and updating equipment requests across the Gulf‑to‑Bay modernization ecosystem.  
It demonstrates:

- Senior‑level API design  
- Deterministic authentication patterns  
- Dataverse Web API integration  
- Clean Pydantic modeling  
- Consumer‑ready workflows for Power Apps, Fabric, and Databricks  

This API is intentionally minimal, readable, and portfolio‑ready—showcasing how a modern enterprise would expose Dataverse data through a secure, well‑documented REST interface.

---

## 📡 Endpoints (v1)

| Method | Route | Description |
|-------|--------|-------------|
| **GET** | `/equipment-requests` | Retrieve all equipment requests |
| **GET** | `/equipment-requests/{id}` | Retrieve a single request by Dataverse GUID |
| **POST** | `/equipment-requests` | Create a new equipment request |
| **PATCH** | `/equipment-requests/{id}` | Update an existing request |
| **DELETE** | `/equipment-requests/{id}` | Remove a request (optional for portfolio) |

All endpoints follow a contract‑first schema defined in `openapi.yaml`.

---

## 🧱 Architecture & Technical Highlights

### FastAPI Implementation
- Clean routing in `routes.py`
- Dependency‑injected authentication
- Pydantic models for request/response validation

### Authentication
- Azure AD App Registration  
- OAuth2 Client Credentials flow  
- Token acquisition handled in `auth.py`  
- Automatic token caching for efficient Dataverse calls

### Dataverse Integration
- Uses Dataverse Web API endpoints  
- CRUD operations mapped to Dataverse table: **EquipmentRequests**  
- Clean separation between Dataverse schema and API surface models

### Contract‑First Design
- Full OpenAPI specification included (`openapi.yaml`)  
- Ensures consistent consumer experience across platforms

### Consumer Examples
This API is intentionally built to be consumed by multiple modernization platforms:

- **Power Apps** (Canvas or Model‑Driven)  
- **Fabric Pipelines** (Notebook or Dataflow Gen2 ingestion)  
- **Databricks** (Python notebook integration)  

Each consumer demonstrates real‑world usability and downstream analytics potential.

---

## 🔄 Dev → Prod Workflow

This API follows the same deterministic Dev → Prod pattern used across the GTB modernization repo:

1. Develop and test locally in the **Dev** branch  
2. Deploy Dev API to a Dev environment  
3. Validate against Dev Dataverse + Fabric  
4. Promote Dev → Main in Fabric  
5. Deploy Main API to Prod environment  
6. (Optional) Pull Main to on‑prem Prod for offline execution or archival

This workflow reinforces clean separation, zero branch confusion, and repeatable deployment.

---

## 🧪 Local Development

### Activate virtual environment
..venv\Scripts\activate


### Run FastAPI locally
uvicorn main:app --reload


### View interactive docs
- Swagger UI: `http://localhost:8000/docs`  
- ReDoc: `http://localhost:8000/redoc`

---

## 📘 Why This API Matters (Portfolio Narrative)

This project demonstrates:

- Senior‑level API architecture  
- Clean Dataverse integration without platform friction  
- Secure, enterprise‑ready authentication  
- Contract‑first design with OpenAPI  
- Multi‑platform consumption (Power Apps, Fabric, Databricks)  
- A modernization‑aligned service boundary that mirrors real enterprise patterns  

It fits directly into the broader modernization story:  
**Dataverse → API → Lakehouse → Semantic Model → Power BI**