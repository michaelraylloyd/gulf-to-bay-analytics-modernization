/* ============================================================
   Stored Procedure: gold.usp_refresh_ga4_medallion
   ------------------------------------------------------------
   Purpose:
       Orchestrate the full GA4Analytics medallion refresh:
           1. Bronze ingestion (CSV → raw tables)
           2. Silver layer build (typed, cleaned)
           3. Gold layer build (business-ready)
           4. Semantic views (Power BI layer)

   Notes:
       • Safe to re-run end-to-end.
       • Executes each layer in correct dependency order.
       • Central orchestration point for automation
         (SQL Agent, Power Automate, Azure Automation, etc.)

   Author:
       Michael Lloyd — Gulf to Bay Analytics Modernization Toolkit
   ============================================================ */

set ansi_nulls on;
go
set quoted_identifier on;
go

create or alter procedure gold.usp_refresh_ga4_medallion
as
begin
    set nocount on;

    -----------------------------------------------------------
    -- 1. Bronze: Raw ingestion
    -----------------------------------------------------------
    exec bronze.usp_load_ga4;


    -----------------------------------------------------------
    -- 2. Silver: Typed, cleaned tables
    -----------------------------------------------------------
    exec silver.usp_build_silver_layer;


    -----------------------------------------------------------
    -- 3. Gold: Business-ready dimensional layer
    -----------------------------------------------------------
    exec gold.usp_build_gold_layer;


    -----------------------------------------------------------
    -- 4. Semantic Views: Power BI layer
    -----------------------------------------------------------
    exec gold.usp_build_semantic_views;

end;

--exec gold.usp_refresh_ga4_medallion;

go

exec gold.usp_refresh_ga4_medallion;