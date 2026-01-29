# Data Dictionary

This data dictionary defines the key tables, fields, and business concepts used across the Lakehouse layers. It provides clarity for engineers, analysts, and stakeholders by documenting the structure and meaning of curated datasets.

The dictionary is organized by layer: Bronze, Silver, and Gold.

---

## Bronze Layer

Bronze tables store raw, unmodified data. Field names and structures reflect the source system.

### Example: bronze_sales_raw
| Field Name        | Type        | Description |
|-------------------|-------------|-------------|
| transaction_id    | string      | Unique identifier from source system |
| product_id        | string      | Product identifier |
| quantity          | integer     | Units sold |
| price             | decimal     | Unit price at time of sale |
| transaction_ts    | timestamp   | Timestamp from source system |
| source_file       | string      | Ingested file path |
| load_ts           | timestamp   | Ingestion timestamp |

---

## Silver Layer

Silver tables apply cleansing, normalization, and schema alignment.

### Example: silver_sales_clean
| Field Name        | Type        | Description |
|-------------------|-------------|-------------|
| transaction_id    | string      | Cleaned and validated transaction ID |
| product_id        | string      | Standardized product identifier |
| quantity          | integer     | Validated quantity |
| price             | decimal     | Validated price |
| transaction_date  | date        | Normalized transaction date |
| transaction_time  | string      | Extracted time component |
| is_valid_record   | boolean     | Flag indicating data quality status |

---

## Gold Layer

Gold tables contain curated business models optimized for reporting and analytics.

### Example: gold_sales_fact
| Field Name        | Type        | Description |
|-------------------|-------------|-------------|
| transaction_id    | string      | Unique transaction key |
| product_key       | string      | Surrogate key for product dimension |
| date_key          | string      | Surrogate key for date dimension |
| quantity          | integer     | Units sold |
| revenue           | decimal     | quantity * price |
| cost              | decimal     | Cost of goods sold |
| margin            | decimal     | revenue - cost |

### Example: gold_product_dim
| Field Name        | Type        | Description |
|-------------------|-------------|-------------|
| product_key       | string      | Surrogate key |
| product_id        | string      | Source system identifier |
| product_name      | string      | Human-readable name |
| category          | string      | Product category |
| subcategory       | string      | Product subcategory |
| is_active         | boolean     | Active/inactive flag |

---

## KPI Definitions

### Revenue

SUM(revenue)


### Margin

SUM(revenue) - SUM(cost)

### Average Order Value

SUM(revenue) / COUNT(DISTINCT transaction_id)


---

## Summary

The data dictionary provides a shared understanding of the Lakehouse’s curated datasets. It ensures consistency across engineering, analytics, and reporting workflows, and supports clear communication of business logic and data structures.