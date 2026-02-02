# 11. Engineering Standards & Naming Conventions

## 11.1 Overview
Engineering standards ensure that every artifact in the Lakehouse—tables, notebooks, pipelines, scripts, and documentation—follows a consistent, predictable pattern. These standards reduce cognitive load, improve onboarding, and create a professional, recruiter‑ready engineering environment. Naming conventions reinforce clarity and discoverability across all medallion layers and operational components.

---

## 11.2 Notebook Standards
All notebooks follow a strict, ordered structure:

1. **Header block**  
   - Purpose  
   - Inputs  
   - Outputs  
   - Dependencies  

2. **Configuration section**  
   - Environment variables  
   - Lakehouse paths  
   - Table names  

3. **Execution steps**  
   - Numbered, logically grouped sections  
   - Clear markdown explanations  
   - Deterministic transformations  

4. **Validation & logging**  
   - Row counts  
   - Schema checks  
   - Exception handling  

5. **Write‑out section**  
   - Persist Bronze/Silver/Gold tables  
   - Confirm materialization  

**Notebook naming pattern:**  
`<order>-<layer>-<action>-<subject>.ipynb`  
Examples:  
- `1-bronze-ingest-sales.ipynb`  
- `2-transform-sales.ipynb`  
- `3-model-sales.ipynb`

---

## 11.3 Table Naming Conventions
Tables follow a consistent, medallion‑aligned naming pattern:

### Bronze
- Raw tables preserve source names  
- Prefix: `bronze_`  
- Example: `bronze_sales_raw`

### Silver
- Cleaned and conformed tables  
- Prefix: `silver_`  
- Example: `silver_sales_conformed`

### Gold
- Dimensional and fact tables  
- Prefix: `dim_` or `fact_`  
- Example:  
  - `dim_customer`  
  - `fact_sales`

This structure ensures immediate recognition of a table’s purpose and layer.

---

## 11.4 Column Naming Standards
Column names follow a unified pattern across all layers:

- **snake_case** for all columns  
- **Primary keys** end with `_id`  
- **Foreign keys** match the primary key name in the referenced table  
- **Date fields** end with `_date`  
- **Boolean fields** begin with `is_` or `has_`

Examples:  
- `customer_id`  
- `order_date`  
- `is_active`

These conventions support consistent modeling and simplify semantic layer mapping.

---

## 11.5 File & Folder Naming Standards
All repo artifacts follow a predictable, lower‑kebab‑case naming pattern:

- `bronze-overview.md`  
- `silver-transformations.md`  
- `gold-modeling.md`  
- `sales-refresh-pipeline.json`  
- `deploy-semantic-model.ps1`

Folder names reflect architectural domains:

- `notebooks/`  
- `pipelines/`  
- `semantic-model/`  
- `docs/architecture/`  
- `docs/bronze/`  
- `docs/silver/`  
- `docs/gold/`

This structure ensures that engineers and reviewers can navigate the repo without friction.

---

## 11.6 Pipeline Standards
Pipelines follow a deterministic pattern:

- **Single orchestrator per subject area**  
- **Ordered notebook execution** (Bronze → Silver → Gold)  
- **Clear activity names**  
- **Consistent failure handling**  
- **No embedded business logic** (logic lives in notebooks)

Pipeline naming pattern:  
`<subject>-refresh-pipeline.json`  
Example: `sales-refresh-pipeline.json`

---

## 11.7 Semantic Model Standards
The semantic model adheres to strict modeling conventions:

- **Fact tables** contain numeric measures and foreign keys  
- **Dimension tables** contain descriptive attributes  
- **Measures** use PascalCase  
- **Folders** group related KPIs  
- **RLS roles** follow business‑aligned naming  

Examples:  
- Measure: `TotalSales`  
- Folder: `Sales KPIs`  
- Role: `RegionalManager`

These conventions ensure clarity for analysts and maintain consistency across reports.

---

## 11.8 Documentation Standards
Documentation follows a narrative‑driven, recruiter‑ready pattern:

- Each folder contains a `README.md` describing its purpose  
- Architecture docs use numbered sections  
- Medallion layer docs explain responsibilities, inputs, outputs, and guarantees  
- Decision logs capture trade‑offs and rationale  

This ensures that the entire system is explainable, auditable, and easy to extend.

---

## 11.9 Standards Summary
These engineering and naming conventions ensure that the Lakehouse is:

- Predictable  
- Discoverable  
- Maintainable  
- Scalable  
- Recruiter‑ready  

By enforcing consistent patterns across notebooks, tables, pipelines, and documentation, Gulf to Bay Analytics maintains a clean, professional engineering environment that supports long‑term growth and modernization.