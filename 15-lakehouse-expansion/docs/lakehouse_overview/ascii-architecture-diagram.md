# ASCII Architecture Diagram

The diagram below provides a text-based visual representation of the Lakehouse architecture used in the Gulf to Bay Analytics modernization project. It illustrates the flow of data from ingestion through the Bronze, Silver, and Gold layers, and finally into the Power BI semantic model.

---------------------------------------------------------------------

                         +----------------------+
                         |      Source Data     |
                         |----------------------|
                         |  CSV / JSON / APIs   |
                         |  Databases / Streams |
                         +----------+-----------+
                                    |
                                    v
                         +----------------------+
                         |     Ingestion Layer  |
                         |----------------------|
                         |  Batch / Streaming   |
                         |  Auto Loader / ETL   |
                         +----------+-----------+
                                    |
                                    v
        +-------------------------------------------------------------+
        |                           BRONZE                            |
        |-------------------------------------------------------------|
        |  Raw, unmodified data                                       |
        |  Append-only Delta tables                                   |
        |  Schema drift + time travel                                 |
        +---------------------------+---------------------------------+
                                    |
                                    v
        +-------------------------------------------------------------+
        |                           SILVER                            |
        |-------------------------------------------------------------|
        |  Cleaned & standardized data                                |
        |  Type enforcement, deduplication                            |
        |  Joins with reference data                                  |
        |  Business logic begins here                                 |
        +---------------------------+---------------------------------+
                                    |
                                    v
        +-------------------------------------------------------------+
        |                            GOLD                             |
        |-------------------------------------------------------------|
        |  Curated business models                                    |
        |  Fact & dimension tables                                    |
        |  KPI logic, aggregations                                    |
        |  Optimized for BI consumption                               |
        +---------------------------+---------------------------------+
                                    |
                                    v
                         +----------------------+
                         |   Power BI Semantic  |
                         |        Model         |
                         |----------------------|
                         |  KPIs, DAX, visuals  |
                         |  Dashboards & Apps   |
                         +----------------------+

---------------------------------------------------------------------

This diagram provides a high-level visual reference for the Lakehouse pipeline. For detailed explanations of each layer and transformation stage, see:

- `lakehouse-overview.md`
- `architecture.md`
- `pipeline-walkthrough.md`
- `data-dictionary.md`
- `real-time-analytics.md`