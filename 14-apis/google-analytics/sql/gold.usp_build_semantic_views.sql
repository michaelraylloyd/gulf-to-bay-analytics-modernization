/* ============================================================
   Stored Procedure: gold.usp_build_semantic_views
   ------------------------------------------------------------
   Purpose:
       Create semantic views on top of the Gold dimensional
       layer to provide a stable, Power BI–friendly interface.

   Pattern:
       • Views are thin wrappers over Gold tables
       • All views use CREATE OR ALTER
       • Safe to re-run

   Author:
       Michael Lloyd — Gulf to Bay Analytics Modernization Toolkit
   ============================================================ */

set ansi_nulls on;
go
set quoted_identifier on;
go

create or alter procedure gold.usp_build_semantic_views
as
begin
    set nocount on;

    -----------------------------------------------------------
    -- FACT VIEWS
    -----------------------------------------------------------

    exec('
        create or alter view gold.vw_FactDailyKPIs as
        select *
        from gold.fact_daily_kpis
    ');

    exec('
        create or alter view gold.vw_FactContentPerformance as
        select *
        from gold.fact_content_performance
    ');

    exec('
        create or alter view gold.vw_FactTopEvents as
        select *
        from gold.fact_top_events
    ');


    -----------------------------------------------------------
    -- DIMENSION VIEWS
    -----------------------------------------------------------

    exec('
        create or alter view gold.vw_DimDate as
        select *
        from gold.dim_date
    ');

    exec('
        create or alter view gold.vw_DimEvent as
        select *
        from gold.dim_event
    ');

    exec('
        create or alter view gold.vw_DimPage as
        select *
        from gold.dim_page
    ');
end;

--exec gold.usp_build_semantic_views;

go

exec gold.usp_build_semantic_views;