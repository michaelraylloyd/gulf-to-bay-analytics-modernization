# Product Dimension — Data Dictionary

This document defines the schema, field‑level meaning, and business logic for the Product Dimension. It provides a single source of truth for product attributes used across the Lakehouse and downstream analytical models.

---

## Table Purpose

The Product Dimension represents the catalog of products available for sale. It provides descriptive attributes used to enrich fact tables, support category‑level analytics, and enable product performance reporting.

---

## Schema Definition

| Field Name        | Data Type | Description |
|-------------------|-----------|-------------|
| product_id        | string    | Unique identifier for each product. |
| product_name      | string    | Human‑readable product name. |
| product_category  | string    | Category or grouping for the product. |
| product_subtype   | string    | More granular classification (optional). |
| unit_cost         | decimal   | Cost to produce or acquire the product. |
| unit_price        | decimal   | Standard selling price. |
| is_active         | boolean   | Indicates whether the product is currently offered. |
| effective_start   | timestamp | SCD2 start timestamp for the record version. |
| effective_end     | timestamp | SCD2 end timestamp for the record version. |
| is_current        | boolean   | Indicates whether this is the active record version. |

---

## Business Rules

- `product_id` must be unique within each SCD2 version range.  
- `unit_cost` and `unit_price` must be non‑negative.  
- `product_category` must match a valid business taxonomy.  
- `is_current` must be true for exactly one version per product.  
- `effective_start` and `effective_end` must not overlap across versions.  

These rules are enforced during Silver transformations and validated during SCD2 processing.

---

## Layer‑Specific Notes

### Bronze  
- Raw product records are ingested and typed.  
- No SCD2 logic is applied.  

### Data Quality  
- Required fields are validated.  
- Price and cost fields are checked for valid ranges.  

### Silver  
- SCD2 logic is applied to track historical changes.  
- Product categories may be normalized or derived.  

### Gold  
- The dimension is joined with fact tables to support curated analytics.  
- Only `is_current = true` records are used for most reporting scenarios.  

---

## Usage

The Product Dimension is used for:

- Product performance analysis  
- Margin and profitability reporting  
- Category‑level analytics  
- Fact table enrichment  
- Executive dashboards  

This dictionary ensures consistent interpretation across all consumers.