# Sales Table — Data Dictionary

This document defines the schema, field‑level meaning, and business logic for the Sales table as it moves through the Lakehouse layers. It provides a single source of truth for analysts, engineers, and downstream consumers.

---

## Table Purpose

The Sales table represents individual sales transactions captured from the source system. It is the foundational dataset for revenue reporting, customer analytics, and downstream fact modeling.

---

## Schema Definition

| Field Name        | Data Type | Description |
|-------------------|-----------|-------------|
| sale_id           | string    | Unique identifier for each sale transaction. |
| sale_date         | date      | The date the sale occurred. |
| customer_id       | string    | Identifier linking the sale to a customer record. |
| product_id        | string    | Identifier linking the sale to a product record. |
| quantity          | integer   | Number of units sold in the transaction. |
| unit_price        | decimal   | Price per unit at the time of sale. |
| total_amount      | decimal   | Calculated field: `quantity * unit_price`. |
| sales_channel     | string    | Channel through which the sale was made (e.g., online, retail). |
| region            | string    | Geographic region associated with the sale. |

---

## Business Rules

- `sale_id` must be unique.  
- `quantity` must be greater than zero.  
- `unit_price` must be non‑negative.  
- `total_amount` must equal `quantity * unit_price`.  
- `customer_id` and `product_id` must match valid dimension records.  

These rules are enforced in the Data Quality layer.

---

## Layer‑Specific Notes

### Bronze  
- Raw fields are cast to deterministic types.  
- No business logic is applied.  

### Data Quality  
- Null checks, range checks, and referential checks are applied.  
- Invalid rows are flagged or rejected.  

### Silver  
- Derived fields (e.g., `total_amount`) are calculated.  
- Categories and date attributes may be normalized.  

### Gold  
- Aggregations and business‑aligned metrics are produced.  
- The table may be joined with dimensions to create curated fact models.  

---

## Usage

The Sales table is used for:

- Revenue reporting  
- Customer analytics  
- Product performance analysis  
- Executive dashboards  
- Gold‑layer fact modeling  

This dictionary ensures consistent interpretation across all consumers.