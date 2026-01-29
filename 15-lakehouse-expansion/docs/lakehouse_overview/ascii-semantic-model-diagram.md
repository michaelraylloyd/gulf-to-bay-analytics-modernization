# ASCII Semantic Model Diagram (Power BI)

This diagram shows how curated Gold tables flow into the Power BI semantic model, including fact tables, dimensions, relationships, and KPI logic.

---------------------------------------------------------------------

                         +----------------------+
                         |        GOLD          |
                         |----------------------|
                         |  gold_sales_fact     |
                         |  gold_product_dim    |
                         |  gold_date_dim       |
                         |  gold_customer_dim   |
                         +----------+-----------+
                                    |
                                    v
                    +----------------------------------+
                    |      Power BI Semantic Model     |
                    |----------------------------------|
                    |  Relationships (1:* / *:1)        |
                    |  Star-schema modeling             |
                    |  KPI definitions (DAX)            |
                    |  Measures & calculated columns    |
                    +----------------+------------------+
                                     |
                                     v
                         +------------------------------+
                         |        Dashboards & Apps     |
                         |------------------------------|
                         |  Executive KPIs              |
                         |  Trend analysis              |
                         |  Predictive insights         |
                         |  Drill-through reports       |
                         +------------------------------+

---------------------------------------------------------------------

Example Star Schema:

        +------------------+         +------------------+
        | gold_date_dim    |         | gold_product_dim |
        +--------+---------+         +---------+--------+
                 |                             |
                 |                             |
                 v                             v
               +----------------------------------+
               |        gold_sales_fact           |
               +----------------------------------+
               | date_key       product_key       |
               | customer_key   revenue           |
               | quantity       margin            |
               +----------------------------------+

---------------------------------------------------------------------