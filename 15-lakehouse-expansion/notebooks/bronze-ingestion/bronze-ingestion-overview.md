# Bronze Ingestion Overview

The Bronze ingestion process establishes the foundational layer of the Lakehouse by converting raw source data into a structured, append‑only Delta format. This layer preserves the fidelity of the original data while enforcing deterministic schema typing and adding operational metadata required for downstream processing.

Bronze ingestion is implemented through a modular set of engineering artifacts:

- **Notebook:** The primary ingestion logic, including schema enforcement, metadata application, and Delta writes.
- **Schema Definition:** A canonical JSON schema that ensures consistent typing across all ingestion paths.
- **Configuration File:** Externalized parameters for source paths, target paths, formats, and table identifiers.
- **Ingestion Script:** A pipeline‑ready Python script that mirrors the notebook logic for automated execution.
- **Pipeline Definition:** An orchestration artifact that coordinates ingestion tasks and defines retry and scheduling behavior.

This structure ensures that ingestion is reproducible, environment‑agnostic, and aligned with enterprise data engineering standards. The Bronze layer serves as the authoritative entry point for all subsequent transformations in the Silver and Gold layers.