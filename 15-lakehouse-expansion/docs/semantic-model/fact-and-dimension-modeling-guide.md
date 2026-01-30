# Fact & Dimension Modeling Guide

This document explains how curated Gold‑layer tables are shaped into analytical models within the Semantic Model. It defines the roles of fact and dimension tables, the relationships between them, and the modeling standards that ensure consistent, business‑aligned analytics across BI tools.

---

## Purpose

Fact and dimension modeling provides:

- A structured analytical foundation  
- Consistent business logic  
- Intuitive navigation for analysts  
- High‑performance reporting  
- A governed semantic layer  

This guide establishes the modeling conventions used throughout the Lakehouse Expansion pillar.

---

## Fact Tables

Fact tables represent measurable business events.  
They contain:

- Numeric metrics (e.g., revenue, quantity)  
- Foreign keys to dimensions  
- Transaction‑level or aggregated data  
- Time‑stamped records  

**Examples:**  
- Sales Fact  
- Inventory Fact  
- Web Activity Fact  

**Characteristics:**  
- Large row counts  
- Additive or semi‑additive measures  
- High cardinality  

---

## Dimension Tables

Dimension tables provide descriptive attributes used to slice, filter, and group facts.  
They contain:

- Business entities (Customer, Product, Date)  
- Hierarchies (Year → Quarter → Month → Day)  
- Categories and classifications  
- SCD2 historical versions when needed  

**Characteristics:**  
- Smaller row counts  
- Rich descriptive fields  
- Stable keys  

---

## Relationships

Fact and dimension tables are connected through:

- One‑to‑many relationships (dimension → fact)  
- Surrogate keys or natural keys  
- Deterministic join paths  

**Principles:**  
- No circular relationships  
- No ambiguous joins  
- Clear grain for each fact table  

---

## Grain Definition

Every fact table must define its grain — the level at which data is stored.

**Examples:**  
- One row per sale transaction  
- One row per customer per day  
- One row per product per inventory snapshot  

A clearly defined grain prevents double‑counting and ensures accurate aggregations.

---

## Measures

Measures are business‑aligned calculations derived from fact tables.

**Examples:**  
- Total Revenue  
- Margin  
- Quantity Sold  
- Average Order Value  

**Principles:**  
- Defined once, reused everywhere  
- Reflect business definitions  
- Avoid duplication in reports  

---

## Hierarchies

Hierarchies provide intuitive drill paths for exploration.

**Examples:**  
- Date: Year → Quarter → Month → Day  
- Product: Category → Subtype → SKU  
- Customer: Segment → Region → Account  

Hierarchies improve usability and analytical clarity.

---

## Modeling Standards

- **Consistent naming** — business‑friendly, intuitive field names  
- **Deterministic relationships** — no ambiguous joins  
- **Clear grain** — every fact table declares its level of detail  
- **Reusable measures** — defined once in the semantic layer  
- **Governed logic** — business definitions are centralized  

These standards ensure that all BI tools produce consistent, trustworthy results.

---

## Summary

This guide defines how facts, dimensions, relationships, and measures form the backbone of the Semantic Model. It ensures that curated Gold data is transformed into a governed, intuitive analytical layer that supports reliable, enterprise‑grade reporting.