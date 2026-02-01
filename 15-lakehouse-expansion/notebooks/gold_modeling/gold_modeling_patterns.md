# Gold Modeling Patterns

The Gold layer applies deterministic dimensional modeling patterns to transform refined Silver data into a business‑aligned star schema. These patterns ensure that analytical models remain stable, predictable, and optimized for KPI logic, semantic modeling, and executive‑grade reporting. The Gold layer focuses on business structure rather than data cleaning, producing curated tables that reflect core organizational processes.

## Core Modeling Principles

### 1. Surrogate Key Generation
Gold introduces surrogate keys to provide stable, non‑volatile identifiers for analytical joins. These keys decouple reporting logic from source system identifiers and ensure consistent relationships across ingestion cycles.

### 2. Conformed Dimensions
Dimensions are standardized and shared across fact tables to maintain analytical consistency. Conformed dimensions ensure that metrics and KPIs remain aligned across dashboards, reports, and downstream data products.

### 3. Grain Definition
Each fact table is modeled at a clearly defined grain. For the sales fact table, the grain is a single product sold in a single order at a specific timestamp. This explicit grain enables accurate aggregation and prevents double‑counting.

### 4. Derived Measures
Gold introduces analytical measures such as `total_amount`, which support KPI logic without embedding business rules. These measures provide a consistent foundation for semantic models and BI tools.

### 5. Temporal Modeling
The date dimension captures multiple levels of temporal granularity, enabling flexible time‑based analysis. This structure supports common reporting patterns such as year‑over‑year comparisons, monthly trends, and hourly breakdowns.

### 6. Schema Enforcement
The Gold schema is explicitly defined and applied during modeling. This prevents schema drift and ensures that downstream consumers operate on a predictable structure.

### 7. Dual Execution Paths
Gold supports two aligned execution modes:
- **Notebook execution** for iterative modeling and validation  
- **Script execution** for automated pipelines and scheduled jobs  

Both paths reference the same schema and configuration artifacts to maintain consistency.

### 8. Orchestration‑Ready Design
A dedicated pipeline definition coordinates Gold modeling tasks, defines retry behavior, and provides a clear operational entrypoint. This ensures reliable execution within enterprise orchestration frameworks.

## Summary

These modeling patterns ensure that the Gold layer is analytically reliable, business‑aligned, and ready for semantic modeling. By standardizing surrogate keys, conformed dimensions, fact grain, and derived measures, the Gold layer provides the trusted foundation required for KPI frameworks and executive reporting.