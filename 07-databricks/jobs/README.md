# Databricks Jobs — Gulf to Bay Lakehouse Pipeline

This folder contains the **job definition artifacts** for the Gulf to Bay Databricks Lakehouse Pipeline.  
These files document the orchestration layer that executes the medallion architecture (Bronze → Silver → Gold) inside Databricks Workflows.

## Purpose
The goal of this folder is to provide a **reproducible, version‑controlled definition** of the Databricks pipeline used to run the Lakehouse notebooks.  
While the job itself lives inside the Databricks workspace, the JSON definition stored here ensures:

- Full transparency of the orchestration logic  
- Easy recreation of the job in any Databricks workspace  
- Clean version history for pipeline changes  
- A professional modernization narrative for recruiters and engineering teams  

## Contents
### `gulf-to-bay-lakehouse-pipeline.json`
The exported Databricks Job definition, including:

- Job name  
- Task list (bronze, silver, gold)  
- Notebook paths  
- Task dependencies  
- Performance settings  
- Queueing behavior  
- Notification configuration  

This JSON file **does not execute anything** on its own.  
It serves as documentation and a reproducible specification for the Databricks orchestration layer.

## How to Recreate the Job in Databricks
1. Open **Jobs & Pipelines** in Databricks.  
2. Create a new job.  
3. Use the UI to add tasks matching the JSON definition  
   (Databricks does not currently support direct JSON import).  
4. Attach the notebooks from the `10-databricks-notebooks` folder.  
5. Save the job.

## Relationship to the Repo
This folder pairs with:

- `10-databricks-notebooks/` — the executable medallion notebooks  
- `15-lakehouse-expansion/` — the Fabric equivalent  
- `docs/` — architecture diagrams and modernization notes  

Together, they form the Databricks Lakehouse portion of the Gulf to Bay modernization project.
