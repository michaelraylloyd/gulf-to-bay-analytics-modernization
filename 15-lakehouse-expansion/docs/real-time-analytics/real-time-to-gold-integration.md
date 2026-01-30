# Real‑Time to Gold Integration

This document explains how real‑time outputs flow into curated Gold‑layer models within the Lakehouse Expansion pillar. It describes the integration patterns, merge logic, and guarantees that ensure low‑latency updates remain consistent with business‑aligned metrics.

---

## Purpose

Real‑time to Gold integration enables the Lakehouse to:

- Deliver near‑real‑time insights to dashboards  
- Update curated fact tables with minimal latency  
- Blend streaming and batch data without inconsistencies  
- Maintain business logic across both processing modes  

This integration is the final step that makes real‑time analytics actionable for end users.

---

## Integration Flow

### 1. Real‑Time Events Arrive  
Events are ingested through a streaming source and processed using lightweight transformations.

### 2. Incremental Outputs Written  
Processed events are written to a staging Delta table optimized for incremental merges.

### 3. Merge into Silver  
Incremental updates are merged into Silver tables using deterministic rules.

### 4. Gold Refresh Triggered  
Gold‑layer models are updated using either:

- Micro‑batch refreshes  
- Event‑driven triggers  
- Scheduled incremental jobs  

### 5. Curated Metrics Updated  
Aggregations, KPIs, and business‑aligned metrics reflect the latest data.

---

## Merge Logic

Real‑time merges follow the same deterministic rules as batch pipelines:

- Match on primary keys  
- Update changed fields  
- Insert new records  
- Preserve historical versions for SCD2 dimensions  
- Maintain auditability and lineage  

This ensures that real‑time updates never corrupt curated models.

---

## Integration Patterns

### **1. Direct Incremental Merge**
Real‑time outputs are merged directly into Silver or Gold tables.

**Use cases:**  
- High‑frequency updates  
- Operational dashboards  

---

### **2. Micro‑Batch Gold Refresh**
Gold tables are refreshed at short intervals (e.g., every 5 minutes).

**Use cases:**  
- Rolling KPIs  
- Near‑real‑time reporting  

---

### **3. Hybrid Real‑Time + Batch Reconciliation**
Real‑time updates are merged incrementally, and batch jobs periodically reconcile full history.

**Use cases:**  
- High‑volume event streams  
- Scenarios requiring strict consistency  

---

## Guarantees

- **Freshness** — Gold models reflect recent events.  
- **Consistency** — Business logic remains aligned with batch transformations.  
- **Determinism** — Merges follow predictable, auditable rules.  
- **Scalability** — Supports both high‑volume and low‑latency workloads.  

---

## Summary

Real‑time to Gold integration enables the Lakehouse to deliver timely, curated insights without sacrificing reliability or consistency. It is the final step in blending streaming responsiveness with the Lakehouse’s deterministic, layered architecture.