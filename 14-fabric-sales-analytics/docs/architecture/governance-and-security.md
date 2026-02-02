# 10. Governance & Security

## 10.1 Overview
Governance and security ensure that the Lakehouse operates as a trusted, compliant, and well‑managed analytics platform. Gulf to Bay Analytics applies a layered governance model that spans data access, workspace roles, semantic model certification, and operational oversight. This framework guarantees that analytical outputs are consistent, auditable, and aligned with organizational standards.

---

## 10.2 Workspace Governance
Fabric workspaces serve as the primary governance boundary for the Sales Analytics solution.

**Key principles:**
- **Role‑based access control (RBAC)** defines who can view, edit, or publish artifacts.
- **Separation of Dev and Prod** ensures controlled promotion of notebooks, pipelines, and semantic models.
- **Artifact‑level permissions** restrict access to sensitive datasets and operational components.

**Typical workspace roles:**
- *Admin* — full control over workspace configuration and deployment.
- *Member* — engineering contributors who modify notebooks, pipelines, and models.
- *Contributor* — analysts who build reports using certified datasets.
- *Viewer* — consumers with read‑only access to published reports and dashboards.

---

## 10.3 Data Access & Security
Data access is governed through a combination of Fabric security features and Lakehouse‑level controls.

**Core mechanisms:**
- **Lakehouse item permissions** restrict access to Bronze, Silver, and Gold tables.
- **Row‑level security (RLS)** is applied in the semantic model where business rules require filtered access.
- **Column‑level protections** ensure sensitive attributes (e.g., PII) are masked or excluded from downstream layers.
- **OneLake inheritance** ensures consistent access rules across notebooks, pipelines, and semantic endpoints.

This layered approach ensures that users only see the data appropriate for their role and responsibilities.

---

## 10.4 Data Quality & Lineage Governance
Fabric provides built‑in lineage tracking that documents the full data journey:

- Source → Bronze → Silver → Gold → Semantic Model → Reports

This lineage is visible in the workspace and supports:
- **Impact analysis** when modifying upstream logic
- **Auditability** for compliance and operational reviews
- **Transparency** for analysts and engineers

Data quality is reinforced through:
- Schema validation in Bronze ingestion
- Referential integrity checks in Silver
- KPI and metric validation in Gold

These controls ensure that downstream analytics are trustworthy and repeatable.

---

## 10.5 Semantic Model Governance
The semantic model is the authoritative source for certified metrics and business logic.

Governance includes:
- **Certified datasets** to signal trusted, production‑ready models
- **Measure definitions** documented and version‑controlled in `SalesAnalyticsModel.json`
- **Deployment script** (`deploy-semantic-model.ps1`) to enforce consistent Dev → Prod promotion
- **Naming conventions** for tables, measures, and hierarchies

This ensures that all reports share consistent definitions and lineage.

---

## 10.6 Operational Governance
Operational governance ensures that refreshes, deployments, and troubleshooting follow predictable patterns.

Key components:
- **Refresh schedules** documented in `config/refresh-schedules.md`
- **Environment configuration** documented in `config/environment.md`
- **Pipeline monitoring** through Fabric’s run history and alerts
- **Decision logs** maintained in `docs/decisions/` for architectural transparency

This structure ensures that operational behavior is intentional, documented, and easy to audit.

---

## 10.7 Compliance & Auditability
The Lakehouse supports compliance requirements through:
- Immutable Bronze data for audit trails
- Documented transformations in Silver and Gold
- Version‑controlled notebooks, pipelines, and semantic models
- Workspace‑level access logs and activity history

These capabilities provide a clear, defensible record of how data is processed and consumed.

---

## 10.8 Governance Summary
The governance and security framework ensures that the Lakehouse is:
- Secure by design  
- Transparent in lineage and data quality  
- Governed through clear roles, permissions, and certified datasets  
- Operationally predictable and auditable  

This foundation enables Gulf to Bay Analytics to scale analytics confidently while maintaining trust, compliance, and consistency across the organization.