# Semantic Relationships & Joins

This document defines the relationship structure used within the Semantic Model. It explains how fact and dimension tables connect, the rules that govern join paths, and the modeling standards that ensure consistent, accurate analytics across all BI tools.

---

## Purpose

Semantic relationships provide:

- Deterministic join paths  
- Consistent analytical behavior  
- Protection against double‑counting  
- Clear navigation for analysts  
- High‑performance query execution  

These relationships form the backbone of the semantic layer.

---

## Relationship Types

### One‑to‑Many (Dimension → Fact)
The most common relationship type.  
A single dimension record maps to many fact records.

**Examples:**  
- Customer → Sales  
- Product → Sales  
- Date → Sales  

This structure ensures clean slicing and filtering.

---

### Many‑to‑One (Fact → Dimension)
The inverse of the above, used when modeling from the fact table’s perspective.

**Example:**  
- Sales → Date  

This is functionally equivalent but defined based on the BI tool’s directionality.

---

### Many‑to‑Many (Avoided)
Many‑to‑many relationships introduce ambiguity and inconsistent aggregations.

**Principle:**  
The Semantic Model avoids many‑to‑many joins by:

- Using bridge tables  
- Normalizing dimensions  
- Enforcing clean surrogate keys  

This ensures analytical correctness.

---

## Join Keys

### Surrogate Keys
Preferred for all fact‑to‑dimension relationships.

**Benefits:**  
- Stable over time  
- Support SCD2  
- Avoid natural key drift  

### Natural Keys
Used only when stable and guaranteed unique.

**Examples:**  
- ISO country codes  
- Standard product codes  

---

## Relationship Direction

### Single Direction (Preferred)
Filters flow from dimension → fact.

**Benefits:**  
- Predictable behavior  
- No ambiguous filter paths  
- High performance  

### Bi‑Directional (Restricted)
Used only when:

- A dimension must filter another dimension  
- A bridge table requires controlled propagation  

Bi‑directional relationships must be explicitly justified.

---

## Grain Alignment

Every relationship must respect the grain of the fact table.

**Examples:**  
- Sales Fact grain: one row per sale  
- Customer Dimension grain: one row per customer (per SCD2 version)  
- Product Dimension grain: one row per product (per SCD2 version)  

Misaligned grain leads to incorrect aggregations.

---

## Bridge Tables

Bridge tables are used when:

- A fact relates to multiple dimension records  
- A many‑to‑many scenario must be resolved  
- A hierarchical structure requires flattening  

**Principle:**  
Bridge tables must be explicitly documented and governed.

---

## Relationship Validation

The Semantic Model enforces:

- No ambiguous paths  
- No circular relationships  
- No hidden many‑to‑many joins  
- Deterministic filter propagation  
- Consistent behavior across all reports  

This ensures analysts always get correct results.

---

## Summary

Semantic relationships define how facts and dimensions connect within the analytical model. By enforcing clean join paths, stable keys, and deterministic filter behavior, the Semantic Model delivers consistent, trustworthy insights across all BI tools and reporting workflows.