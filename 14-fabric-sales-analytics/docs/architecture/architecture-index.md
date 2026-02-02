# Architecture Documentation Index

## 1. Overview
This index provides a single, authoritative entry point for all architecture‑related documentation in the **Fabric Sales Analytics Lakehouse** project. It mirrors the structure of the modernization effort and allows engineers, reviewers, and recruiters to navigate the system with zero friction.

Each linked document corresponds to a fully version‑controlled artifact within the `docs/architecture/` folder.

---

## 2. Core Architecture Documents

### 2.1 High‑Level System Overview
**File:** `high-level-system-overview.md`  
Describes the modernization purpose, objectives, business value, and architectural principles guiding the Lakehouse.

### 2.2 End‑to‑End Data Flow
**File:** `end-to-end-data-flow.md` *(if split)*  
or included within the master `architecture.md`  
Explains how data moves from source systems through Bronze, Silver, Gold, and into the semantic model.

### 2.3 Component Architecture
**File:** `architecture.md`  
The master architecture narrative covering all major components:
- Lakehouse storage  
- Notebooks  
- Pipelines  
- Semantic model  
- Documentation  
- Operational and governance layers  

---

## 3. Operational & Governance Documents

### 3.1 Operational Model  
**File:** `operational-model.md`  
Defines refresh sequencing, pipeline orchestration, environment configuration, monitoring, and troubleshooting.

### 3.2 Governance & Security  
**File:** `governance-and-security.md`  
Covers workspace roles, data access, lineage, RLS, certified datasets, and compliance considerations.

---

## 4. Engineering Standards

### 4.1 Engineering Standards & Naming Conventions  
**File:** `engineering-standards-and-naming-conventions.md`  
Documents the conventions for:
- Notebook structure  
- Table naming  
- Column naming  
- File/folder naming  
- Pipeline patterns  
- Semantic model standards  

These conventions ensure clarity, maintainability, and recruiter‑ready polish.

---

## 5. Narrative & Presentation

### 5.1 Recruiter‑Ready Narrative Summary  
**File:** `recruiter-ready-narrative-summary.md`  
Provides an executive‑level modernization story designed for interviews, portfolio presentation, and stakeholder communication.

---

## 6. Reference Materials

### 6.1 Appendix & References  
**File:** `appendix-and-references.md`  
Includes:
- Repo map  
- Mermaid diagrams  
- Data dictionary references  
- Decision logs  
- Raw data references  
- Pipeline and semantic model pointers  

### 6.2 Model Diagram  
**File:** `model_diagram.mmd`  
A Mermaid diagram visualizing fact/dimension relationships and high‑level data flow.

---

## 7. How to Use This Index
This index is designed to be the **first stop** for anyone exploring the architecture. Recommended reading order:

1. **high-level-system-overview.md**  
2. **architecture.md**  
3. **operational-model.md**  
4. **governance-and-security.md**  
5. **engineering-standards-and-naming-conventions.md**  
6. **recruiter-ready-narrative-summary.md**  
7. **appendix-and-references.md**

This sequence mirrors the modernization narrative from strategy → architecture → operations → governance → engineering discipline → executive summary → references.

---

## 8. Summary
The architecture documentation set provides a complete, polished, and narratable view of the Fabric Sales Analytics Lakehouse. This index ties all documents together into a single, discoverable entrypoint, ensuring that engineers, reviewers, and recruiters can navigate the system with clarity and confidence.