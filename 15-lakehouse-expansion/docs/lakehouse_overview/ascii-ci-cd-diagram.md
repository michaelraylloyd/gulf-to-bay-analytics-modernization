# ASCII CI/CD Pipeline Diagram

This diagram illustrates the Dev → Prod workflow used in the Gulf to Bay Analytics modernization project. It covers Git branching, validation steps, Lakehouse pipeline deployment, and Power BI semantic model promotion.

---------------------------------------------------------------------

                   +----------------------+
                   |      Developer       |
                   |----------------------|
                   |  Local changes       |
                   |  Feature branches    |
                   +----------+-----------+
                              |
                              v
                   +----------------------+
                   |      Git Commit      |
                   |----------------------|
                   |  Commit to 'dev'     |
                   |  Push to remote      |
                   +----------+-----------+
                              |
                              v
                   +----------------------+
                   |    Pull Request      |
                   |----------------------|
                   |  Code review         |
                   |  Linting / checks    |
                   |  Lakehouse tests     |
                   +----------+-----------+
                              |
                              v
                   +----------------------+
                   |     Merge to Dev     |
                   |----------------------|
                   |  Dev Lakehouse runs  |
                   |  Dev Power BI model  |
                   +----------+-----------+
                              |
                              v
                   +----------------------+
                   |   Manual Promotion   |
                   |----------------------|
                   |  Tag release         |
                   |  Merge to 'prod'     |
                   +----------+-----------+
                              |
                              v
                   +----------------------+
                   |     PROD Deploy      |
                   |----------------------|
                   |  Lakehouse pipelines |
                   |  Gold tables         |
                   |  Power BI semantic   |
                   |  Dashboard refresh   |
                   +----------------------+

---------------------------------------------------------------------

This CI/CD flow ensures:

- Clean Dev → Prod separation  
- Deterministic Lakehouse deployments  
- Version-controlled Power BI assets  
- Manual approval for production releases  
- Full traceability of changes  