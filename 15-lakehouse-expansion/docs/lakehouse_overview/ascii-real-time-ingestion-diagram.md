# ASCII Real-Time Ingestion Diagram

This diagram illustrates how real-time and near–real-time data flows into the Lakehouse using streaming sources and Auto Loader, alongside traditional batch ingestion.

---------------------------------------------------------------------

                         +----------------------+
                         |      Source Data     |
                         |----------------------|
                         |  Batch Files (CSV)   |
                         |  APIs / Databases    |
                         |  Event Streams       |
                         |  Telemetry / Queues  |
                         +----------+-----------+
                                    |
             +----------------------+----------------------+
             |                                             |
             v                                             v
 +----------------------+                     +----------------------+
 |   Batch Ingestion    |                     |   Streaming Ingest   |
 |----------------------|                     |----------------------|
 |  Scheduled ETL Jobs  |                     |  Auto Loader         |
 |  File-based loads    |                     |  Event Hub / Kafka   |
 +----------+-----------+                     +----------+-----------+
            |                                              |
            +----------------------+-----------------------+
                                   |
                                   v
                         +----------------------+
                         |        BRONZE        |
                         |----------------------|
                         |  Raw Delta tables    |
                         |  Append-only writes  |
                         +----------+-----------+
                                    |
                                    v
                         +----------------------+
                         |        SILVER        |
                         |----------------------|
                         |  Cleaned, validated  |
                         |  Streaming or batch  |
                         +----------+-----------+
                                    |
                                    v
                         +----------------------+
                         |         GOLD         |
                         |----------------------|
                         |  Curated models      |
                         |  Real-time KPIs      |
                         +----------+-----------+
                                    |
                                    v
                         +----------------------+
                         |   Power BI Semantic  |
                         |        Model         |
                         +----------------------+

---------------------------------------------------------------------