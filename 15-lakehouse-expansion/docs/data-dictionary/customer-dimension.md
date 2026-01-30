# Customer Dimension — Data Dictionary

This document defines the schema, field‑level meaning, and business logic for the Customer Dimension. It provides a single source of truth for identity, demographic, and historical attributes used across the Lakehouse.

---

## Table Purpose

The Customer Dimension represents the set of unique customers and their associated descriptive attributes. It is used to enrich fact tables, support SCD2 historical tracking, and enable customer‑centric analytics.

---

## Schema Definition

| Field Name          | Data Type | Description |
|---------------------|-----------|-------------|
| customer_id         | string    | Unique identifier for each customer. |
| first_name          | string    | Customer’s first name. |
| last_name           | string    | Customer’s last name. |
| email               | string    | Primary email address. |
| phone_number        | string    | Primary contact number. |
| address_line1       | string    | Street address line 1. |
| address_line2       | string    | Street address line 2 (optional). |
| city                | string    | Customer’s city. |
| state               | string    | Customer’s state or region. |
| postal_code         | string    | Postal or ZIP code. |
| country             | string    | Customer’s country. |
| customer_segment    | string    | Business‑defined segment (e.g., retail, wholesale). |
| effective_start     | timestamp | SCD2 start timestamp for the record version. |
| effective_end       | timestamp | SCD2 end timestamp for the record version. |
| is_current          | boolean   | Indicates whether this is the active record version. |

---

## Business Rules

- `customer_id` must be unique within each SCD2 version range.  
- `effective_start` and `effective_end` must not overlap across versions.  
- `is_current` must be true for exactly one version per customer.  
- Contact fields (email, phone) must follow validation patterns.  
- Address fields must be non‑null for active customers.  

These rules are enforced in the Silver layer and validated during SCD2 processing.

---

## Layer‑Specific Notes

### Bronze  
- Raw customer records are ingested and typed.  
- No SCD2 logic is applied.  

### Data Quality  
- Email and phone formats are validated.  
- Required fields are checked for completeness.  

### Silver  
- SCD2 logic is applied to track historical changes.  
- Customer segments may be derived or normalized.  

### Gold  
- The dimension is joined with fact tables to support curated analytics.  
- Only `is_current = true` records are used for most reporting scenarios.  

---

## Usage

The Customer Dimension is used for:

- Customer segmentation  
- Historical attribute tracking (SCD2)  
- Fact table enrichment  
- Executive dashboards  
- Customer lifetime value analysis  

This dictionary ensures consistent interpretation across all consumers.