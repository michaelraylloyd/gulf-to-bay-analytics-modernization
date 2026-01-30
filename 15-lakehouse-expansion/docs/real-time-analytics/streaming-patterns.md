# Streaming Patterns

This document describes the core streaming patterns supported by the Real‑Time Analytics component of the Lakehouse Expansion pillar. These patterns define how events are ingested, processed, and delivered with low latency while maintaining alignment with the Lakehouse’s batch‑oriented layers.

---

## Purpose

Streaming patterns provide a consistent framework for handling real‑time data. They ensure:

- Predictable event flow  
- Low‑latency processing  
- Clean integration with batch layers  
- Scalable and fault‑tolerant execution  

These patterns are intentionally lightweight to preserve reliability and maintainability.

---

## Core Streaming Patterns

### 1. **Append‑Only Event Stream**

Events are appended to a real‑time Delta table with no updates or deletes.

**Use cases:**  
- Telemetry  
- Clickstream  
- Application events  

**Benefits:**  
- High throughput  
- Minimal transformation  
- Ideal for real‑time monitoring  

---

### 2. **Filtered Stream**

Events are filtered in real time based on business rules or thresholds.

**Use cases:**  
- Alerting  
- Fraud detection  
- Operational dashboards  

**Benefits:**  
- Reduces downstream load  
- Enables immediate action  

---

### 3. **Enriched Stream**

Events are joined with reference data (e.g., customer or product attributes) to produce enriched real‑time outputs.

**Use cases:**  
- Real‑time personalization  
- Context‑aware alerts  
- Incremental fact updates  

**Benefits:**  
- Adds business meaning to raw events  
- Supports hybrid real‑time + batch models  

---

### 4. **Micro‑Batch Aggregation**

Events are aggregated over short windows (e.g., 1–5 minutes) to produce near‑real‑time metrics.

**Use cases:**  
- Rolling KPIs  
- Operational reporting  
- Real‑time dashboards  

**Benefits:**  
- Low latency  
- Smooth integration with Gold models  

---

## Integration with the Lakehouse

Streaming outputs are periodically merged into:

- **Silver** for enriched, typed, validated data  
- **Gold** for curated, business‑aligned metrics  

This ensures that real‑time insights remain consistent with batch‑processed data.

---

## Design Principles

- **Lightweight transformations** — keep real‑time logic simple.  
- **Event‑driven flow** — process data as it arrives.  
- **Fault tolerance** — ensure no data loss during spikes or failures.  
- **Lakehouse alignment** — maintain consistency with batch layers.  

---

## Summary

These streaming patterns provide a flexible, scalable foundation for real‑time analytics within the Lakehouse Expansion pillar. They support a wide range of use cases while maintaining alignment with the Lakehouse’s deterministic, layered architecture.