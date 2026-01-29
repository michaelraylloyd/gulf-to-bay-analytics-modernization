# Pipeline Walkthrough

This walkthrough provides a step-by-step narrative of how data moves through the Lakehouse architecture, from raw ingestion to curated analytical models. It explains the purpose of each layer, the transformation logic applied, and how the final outputs support reporting, analytics, and downstream workloads.

The Lakehouse pipeline follows a structured Bronze → Silver → Gold progression. Each layer is intentionally designed to separate concerns, improve data quality, and maintain clear lineage across the entire data lifecycle.

---

## Bronze Layer — Raw Ingestion

The Bronze layer captures data exactly as it arrives from source systems. No cleansing, normalization, or business logic is applied at this stage. The goal is to preserve fidelity, maintain auditability, and provide a reliable foundation for downstream processing.

Key characteristics:
- Stores raw, unmodified data in Delta format
- Supports both batch and streaming ingestion patterns
- Retains full historical records for replay and recovery
- Provides schema evolution and time travel capabilities

Typical operations:
- Ingest CSV, JSON, API, or database extracts
- Append-only writes using Auto Loader or PySpark ingestion scripts
- Basic metadata tagging (source system, load timestamp, file path)

The Bronze layer ensures that all downstream transformations begin from a consistent, traceable source of truth.

---

## Silver Layer — Cleansing and Normalization

The Silver layer applies the first level of transformation logic. Data is cleaned, standardized, and validated to create reliable analytical datasets. This layer removes noise and inconsistencies while preserving the structure needed for business modeling.

Key characteristics:
- Cleans and normalizes raw data
- Applies schema alignment and type enforcement
- Handles missing values, duplicates, and malformed records
- Introduces basic business logic and reference data joins

Typical operations:
- Deduplication and null-handling
- Standardizing date formats, identifiers, and categorical values
- Joining with lookup tables or reference datasets
- Filtering out invalid or incomplete records

The Silver layer produces datasets that are ready for business modeling and downstream transformations.

---

## Gold Layer — Curated Business Models

The Gold layer contains fully curated, business-ready tables optimized for reporting, analytics, and Power BI semantic modeling. This is where KPIs, metrics, and dimensional structures are defined.

Key characteristics:
- Modeled for consumption by BI tools and analysts
- Contains business logic, aggregations, and KPI definitions
- Supports star-schema or wide-table designs depending on use case
- Provides consistent, trusted data for dashboards and predictive analytics

Typical operations:
- Creating fact and dimension tables
- Applying business rules and metric calculations
- Aggregating data for performance optimization
- Preparing tables for Power BI import or Direct Lake consumption

The Gold layer is the primary interface between the Lakehouse and the reporting ecosystem.

---

## Transformation Flow

The pipeline is orchestrated through PySpark notebooks and Delta Lake operations. Each stage reads from the previous layer, applies transformations, and writes back using ACID-compliant Delta transactions.

High-level flow:
1. Ingest raw data into Bronze
2. Clean and normalize into Silver
3. Model and curate into Gold
4. Expose Gold tables to Power BI

This modular design allows each layer to evolve independently while maintaining clear lineage and reproducibility.

---

## Delta Lake Behaviors

Delta Lake provides the reliability and performance needed for a modern Lakehouse:

- ACID transactions ensure consistent writes
- Schema evolution allows controlled structural changes
- Time travel supports auditing and rollback
- Optimized storage improves query performance
- Auto-compaction and Z-ordering enhance read efficiency

These capabilities make the pipeline resilient, scalable, and production-ready.

---

## Power BI Integration

The Gold layer feeds directly into Power BI through a semantic model that defines relationships, KPIs, and DAX measures. This ensures that reporting is consistent, governed, and aligned with business definitions.

Integration patterns:
- Import mode for smaller curated tables
- Direct Lake or DirectQuery for large-scale datasets
- Semantic model built on top of Gold tables
- KPI definitions aligned with business logic in the Gold layer

This creates a clean separation between data engineering and reporting, while maintaining a unified source of truth.

---

## Summary

The Lakehouse pipeline provides a structured, reliable, and scalable approach to data ingestion, transformation, and modeling. By separating the workflow into Bronze, Silver, and Gold layers, the architecture ensures data quality, lineage, and maintainability across the entire analytics ecosystem.

This document serves as the operational walkthrough for the Lakehouse subproject. Additional documentation covers architecture, data dictionaries, and real-time ingestion patterns.