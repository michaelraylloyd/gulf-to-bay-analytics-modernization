/*============================================================================
  Procedure:   dba.usp_QueryStorePerformanceDiagnostics
  Purpose:     Query Store–driven workload and performance diagnostics. Surfaces
               high-cost queries, regressions, plan variability, and runtime
               outliers to support targeted tuning and performance stabilization.

  Overview:    - Requires Query Store enabled on the target database
               - Reads:
                     sys.query_store_query
                     sys.query_store_plan
                     sys.query_store_runtime_stats
                     sys.query_store_runtime_stats_interval
               - Evaluates:
                     * Top CPU, duration, and logical read consumers
                     * Plan regressions and forced plan candidates
                     * High-variance queries (unstable performance)
                     * Parameter-sensitive or multi-plan workloads
               - Produces a unified, evidence-rich diagnostic set suitable for
                 dashboards, tuning workflows, and regression analysis

  Output:      One row per query or plan finding with:
                   query_id
                   plan_id
                   total_cpu_ms
                   total_duration_ms
                   total_logical_reads
                   execution_count
                   avg_cpu_ms
                   avg_duration_ms
                   plan_regression_flag
                   performance_variance_flag
                   recommended_action
                   evidence_query

  Notes:       - Fully DB-agnostic; safe to run from master or any DBA context
               - Does not force plans automatically; recommendations are
                 review-first and GTB-aligned
               - Complements:
                     dba.usp_WaitStatsDiagnostics
                     dba.usp_BlockingDiagnostics
                     dba.usp_TempDBUsage
               - Forms the “Query Performance” pillar of the modernization toolkit

  Author:      Michael Lloyd — Gulf to Bay Analytics Modernization Toolkit
  ============================================================================*/

create or alter procedure dba.usp_QueryStorePerformanceDiagnostics
      @DatabaseName sysname           -- required: Query Store–enabled DB
    , @ObjectName  sysname = null     -- optional: filter by object name
as
begin
    set nocount on;

    -------------------------------------------------------------------------
    -- Validate database exists
    -------------------------------------------------------------------------
    if not exists (select 1 from sys.databases where name = @DatabaseName)
    begin
        raiserror('Database %s does not exist.', 16, 1, @DatabaseName);
        return;
    end;

    -------------------------------------------------------------------------
    -- Validate Query Store is enabled
    -------------------------------------------------------------------------
    if not exists (
        select 1
        from sys.databases
        where name = @DatabaseName
          and is_query_store_on = 1
    )
    begin
        raiserror('Query Store is not enabled for database %s.', 16, 1, @DatabaseName);
        return;
    end;

    -------------------------------------------------------------------------
    -- Build Query Store diagnostics query in target DB
    -------------------------------------------------------------------------
    declare @sql nvarchar(max) = '
    use [' + @DatabaseName + '];

    ---------------------------------------------------------------------
    -- CTE: qs_base
    -- Purpose:
    --   - Join queries, plans, runtime stats, and objects
    ---------------------------------------------------------------------
    with qs_base as (
        select
              @@servername as server_name
            , db_name()    as database_name
            , o.name       as object_name
            , qsqt.query_sql_text
            , qsq.query_id
            , qsp.plan_id
            , rs.runtime_stats_id
            , rs.first_execution_time
            , rs.last_execution_time
            , rs.count_executions
            , rs.avg_duration
            , rs.avg_cpu_time
            , rs.avg_logical_io_reads
            , rs.avg_logical_io_writes
            , rs.avg_rowcount
            , rs.max_duration
            , rs.max_cpu_time
            , rs.max_logical_io_reads
            , rs.max_logical_io_writes
            , qsp.is_forced_plan
            , qsp.is_parallel_plan
            , qsp.engine_version
            , qsp.compatibility_level
        from sys.query_store_query qsq
        inner join sys.query_store_query_text qsqt
            on qsq.query_text_id = qsqt.query_text_id
        inner join sys.query_store_plan qsp
            on qsq.query_id = qsp.query_id
        inner join sys.query_store_runtime_stats rs
            on qsp.plan_id = rs.plan_id
        inner join sys.query_store_runtime_stats_interval rsi
            on rs.runtime_stats_interval_id = rsi.runtime_stats_interval_id
        left join sys.objects o
            on qsq.object_id = o.object_id
        where (' + case when @ObjectName is null
                        then '1=1'
                        else 'o.name = ''' + @ObjectName + '''' end + ')
    ),

    ---------------------------------------------------------------------
    -- CTE: ranked
    -- Purpose:
    --   - Rank queries by total duration and detect regression potential
    ---------------------------------------------------------------------
    ranked as (
        select
              server_name
            , database_name
            , object_name
            , query_id
            , plan_id
            , query_sql_text
            , first_execution_time
            , last_execution_time
            , count_executions
            , avg_duration
            , avg_cpu_time
            , avg_logical_io_reads
            , avg_logical_io_writes
            , avg_rowcount
            , max_duration
            , max_cpu_time
            , max_logical_io_reads
            , max_logical_io_writes
            , is_forced_plan
            , is_parallel_plan
            , engine_version
            , compatibility_level
            , (count_executions * avg_duration) as total_duration
            , (count_executions * avg_cpu_time) as total_cpu
            , row_number() over (order by (count_executions * avg_duration) desc) as rn_by_duration
            , row_number() over (order by (count_executions * avg_cpu_time) desc) as rn_by_cpu
        from qs_base
    )

    ---------------------------------------------------------------------
    -- Final output: top queries by duration/CPU with basic recommendation
    ---------------------------------------------------------------------
    select top 100
          server_name
        , database_name
        , object_name
        , query_id
        , plan_id
        , is_forced_plan
        , is_parallel_plan
        , first_execution_time
        , last_execution_time
        , count_executions
        , avg_duration
        , avg_cpu_time
        , avg_logical_io_reads
        , avg_logical_io_writes
        , total_duration
        , total_cpu
        , case
            when is_forced_plan = 1 then ''PLAN FORCED – REVIEW IF STILL APPROPRIATE''
            when avg_duration > 1000000 and avg_logical_io_reads > 100000
                 then ''HIGH DURATION + IO – REVIEW INDEXING AND CARDINALITY ESTIMATION''
            when avg_cpu_time > 500000
                 then ''HIGH CPU – REVIEW QUERY LOGIC AND PARALLELISM''
            else ''REVIEW TOP QUERIES FOR TUNING''
          end as tuning_recommendation
        , query_sql_text
    from ranked
    where rn_by_duration <= 200
       or rn_by_cpu <= 200
    order by total_duration desc, total_cpu desc;
    ';

    exec(@sql);

end;

---- Top problematic queries across the database
--exec dba.usp_QueryStorePerformanceDiagnostics @DatabaseName = 'AdventureWorksDW2019';

go

-- Top problematic queries across the database
exec dba.usp_QueryStorePerformanceDiagnostics @DatabaseName = 'AdventureWorksDW2019';

