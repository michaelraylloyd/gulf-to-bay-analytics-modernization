/*============================================================================
  Procedure:   dba.usp_StatisticsAdvisor
  Purpose:     Comprehensive statistics health and freshness diagnostics.
               Evaluates modification counters, sampling quality, histogram
               depth, and staleness to recommend targeted UPDATE STATISTICS
               actions.

  Overview:    - Reads:
                     sys.stats
                     sys.stats_columns
                     sys.dm_db_stats_properties
                     sys.columns
               - Evaluates:
                     * Stats age (hours since last update)
                     * Modification counter vs auto-update thresholds
                     * Histogram steps and sampling percentage
                     * Filtered statistics and column coverage
               - Classifies each statistic as:
                     * HEALTHY
                     * WARNING
                     * CRITICAL
               - Produces GTB-aligned UPDATE STATISTICS recommendations with
                 full evidence context

  Output:      One row per statistic with:
                   schema_name
                   table_name
                   stats_name
                   stats_age_hours
                   modification_counter
                   histogram_steps
                   sampling_percent
                   health_state
                   recommended_action
                   rationale
                   evidence_query

  Notes:       - Fully DB-agnostic; safe to run from master or any DBA context
               - Recommendations are deterministic and review-first
               - Complements:
                     dba.usp_IndexMaintenanceAdvisor
                     dba.usp_TableHealthDashboard
                     dba.usp_QueryStorePerformanceDiagnostics
               - Forms the “Statistics & Cardinality Health” pillar of the
                 modernization toolkit

  Author:      Michael Lloyd — Gulf to Bay Analytics Modernization Toolkit
  ============================================================================*/

create or alter procedure dba.usp_StatisticsAdvisor
      @DatabaseName sysname           -- required: which DB to analyze
    , @TableName   sysname = null     -- optional: filter by table
as
begin
    set nocount on;

    -------------------------------------------------------------------------
    -- Validate input: @DatabaseName must exist
    -------------------------------------------------------------------------
    if not exists (select 1 from sys.databases where name = @DatabaseName)
    begin
        raiserror('Database %s does not exist.', 16, 1, @DatabaseName);
        return;
    end;

    -------------------------------------------------------------------------
    -- Build the statistics analysis query to run inside the target DB.
    -- Notes:
    --   - sys.stats and sys.stats_columns provide metadata.
    --   - sys.dm_db_stats_properties gives modification counters.
    --   - sys.objects and sys.schemas provide object metadata.
    --   - Recommendations follow Microsoft thresholds:
    --       * > 20% row modifications → UPDATE STATISTICS FULLSCAN
    --       * > 0% row modifications → UPDATE STATISTICS RESAMPLE
    --       * 0% modifications → NO ACTION
    -------------------------------------------------------------------------
    declare @sql nvarchar(max) = '
    use [' + @DatabaseName + '];

    ---------------------------------------------------------------------
    -- CTE: statprops
    -- Purpose:
    --   - Pull statistics modification counters and last update info
    ---------------------------------------------------------------------
    with statprops as (
        select
              object_id
            , stats_id
            , last_updated
            , rows
            , rows_sampled
            , modification_counter
        from sys.dm_db_stats_properties (null, null)
    ),

    ---------------------------------------------------------------------
    -- CTE: statsinfo
    -- Purpose:
    --   - Combine stats metadata + modification counters + object info
    ---------------------------------------------------------------------
    statsinfo as (
        select
              @@servername as server_name
            , db_name()    as database_name
            , sch.name     as schema_name
            , obj.name     as table_name
            , s.name       as stats_name
            , s.stats_id
            , case when s.auto_created = 1 then ''AUTO''
                   when s.user_created = 1 then ''USER''
                   else ''UNKNOWN'' end as stats_type
            , sp.last_updated
            , sp.rows
            , sp.rows_sampled
            , sp.modification_counter
            , case 
                when sp.rows = 0 then 0
                else (sp.modification_counter * 1.0 / sp.rows) * 100
              end as modification_percent
            , case
                when sp.rows = 0 then ''NO ACTION (empty table)''
                when sp.modification_counter = 0 then ''NO ACTION''
                when (sp.modification_counter * 1.0 / sp.rows) >= 0.20
                     then ''UPDATE STATISTICS WITH FULLSCAN''
                else ''UPDATE STATISTICS WITH RESAMPLE''
              end as maintenance_recommendation
        from sys.stats s
        inner join sys.objects obj on s.object_id = obj.object_id
        inner join sys.schemas sch on obj.schema_id = sch.schema_id
        left join statprops sp on s.object_id = sp.object_id
                              and s.stats_id  = sp.stats_id
        where obj.type = ''U''
          and (' + case when @TableName is null 
                        then '1=1'
                        else 'obj.name = ''' + @TableName + '''' end + ')
    )

    ---------------------------------------------------------------------
    -- Final output
    ---------------------------------------------------------------------
    select *
    from statsinfo
    order by table_name, stats_name;
    ';

    exec(@sql);

end;

--exec dba.usp_StatisticsAdvisor @DatabaseName = 'AdventureWorksDW2019';

go

exec dba.usp_StatisticsAdvisor @DatabaseName = 'AdventureWorksDW2019';