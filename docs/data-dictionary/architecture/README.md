## 2. Repository Structure

The repository is organized into clear functional domains that mirror the architecture of the Lakehouse:

### **config/**
Environment‑specific settings and operational schedules.
- `environment.md` — workspace assumptions and deployment context  
- `refresh-schedules.md` — documented refresh cadence  
- `.gitignore`

---

### **docs/**
Comprehensive documentation for architecture, medallion layers, data definitions, and decision history.
- **architecture/** — system overview, operational model, governance, standards  
- **bronze/** — ingestion strategy and raw‑layer documentation  
- **silver/** — cleansing and conformance documentation  
- **gold/** — dimensional modeling and KPI logic  
- **data-dictionary/** — column definitions and business meaning  
- **decisions/** — architectural decision log  
- `.gitignore`

---

### **notebooks/**
Ordered Fabric notebooks implementing the Medallion Architecture.
- **0-raw-data/** — sample CSVs and SQL definitions  
- **1-bronze-ingest-sales/** — Bronze ingestion notebook  
- **2-silver-transform-sales/** — Silver transformation notebook  
- **3-gold-model-sales/** — Gold modeling notebook  
- `.gitignore` files included at each level

---

### **pipelines/**
Fabric orchestration assets.
- `sales-refresh-pipeline.json` — end‑to‑end medallion pipeline  
- `README.md`  
- `.gitignore`

---

### **semantic-model/**
Governed semantic layer for enterprise reporting.
- `SalesAnalyticsModel.json` — model definition  
- `deploy-semantic-model.ps1` — deployment script  
- `.gitignore`

---

This structure provides a clean, intuitive layout that aligns directly with the architecture and engineering workflow.