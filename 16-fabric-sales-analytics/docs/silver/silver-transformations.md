# Silver transformations — Sales Analytics Lakehouse

This document describes the transformations applied to each Bronze table to produce the
Silver layer outputs.

## Customers

**Source:** `bronze_customers`  
**Target:** `silver_customers`

Key transformations:

- Type casting:
  - `customer_id` → integer
  - `zip` → string
- Deduplication:
  - Drop duplicates on `customer_id`
- Conformance:
  - `first_name`, `last_name`, `city` → `InitCap`
  - `state` → upper case

Result: a conformed customer dimension candidate suitable for downstream modeling.

## Products

**Source:** `bronze_products`  
**Target:** `silver_products`

Key transformations:

- Type casting:
  - `product_id` → integer
  - `price` → double
- Deduplication:
  - Drop duplicates on `product_id`
- Conformance:
  - `product_name`, `category` → `InitCap`

Result: a clean product reference table with standardized naming and numeric pricing.

## Sales

**Source:** `bronze_sales`  
**Targets:** `silver_sales`, `silver_sales_errors`

Key transformations:

- Type casting:
  - `sale_id`, `customer_id`, `product_id`, `quantity` → integer
- Date parsing:
  - `sale_date` → date (`yyyy-MM-dd`)
- Deduplication:
  - Drop duplicates on `sale_id`
- Referential integrity:
  - `silver_sales`:
    - Inner join to `silver_customers` on `customer_id`
    - Inner join to `silver_products` on `product_id`
  - `silver_sales_errors`:
    - Rows failing customer or product lookup are isolated
    - Duplicates removed on `sale_id`

Result: a trusted `silver_sales` table for Gold modeling, plus a `silver_sales_errors`
table that preserves data quality issues for inspection and remediation.