# Power BI Semantic Model Overview

The Power BI semantic model provides a governed, business-ready layer on top of the Lakehouse Gold tables. It defines relationships, KPIs, DAX measures, and business logic that ensure consistent reporting across dashboards and analytics workloads.

This semantic model is built directly on curated Gold tables, which serve as the trusted source for all reporting.

---

## Model Structure

The semantic model follows a star-schema design:

- **Fact tables** contain measurable events (e.g., sales, transactions)
- **Dimension tables** provide descriptive attributes (e.g., products, dates, customers)
- **Relationships** enforce business logic and filter propagation
- **Measures** define KPIs using DAX

This structure improves performance, clarity, and maintainability.

---

## Gold Tables Used

- `gold_sales_fact`
- `gold_product_dim`
- `gold_date_dim`
- `gold_customer_dim`

These tables are optimized for BI consumption and contain all necessary business logic.

---

## Relationships

Typical relationships include:

- `gold_sales_fact[product_key]` → `gold_product_dim[product_key]`
- `gold_sales_fact[date_key]` → `gold_date_dim[date_key]`
- `gold_sales_fact[customer_key]` → `gold_customer_dim[customer_key]`

All relationships are one-to-many (1:*) with single-direction filter propagation.

---

## KPIs and Measures

The semantic model defines KPIs such as:

- Revenue
- Margin
- Average Order Value
- Quantity Sold
- Year-over-Year Growth

See `measures-catalog.md` for full definitions.

---

## Purpose

The semantic model ensures:

- Consistent business logic across all reports
- Centralized KPI definitions
- High-performance reporting
- A governed layer between engineering and analytics

This model is the primary interface between the Lakehouse and Power BI dashboards.