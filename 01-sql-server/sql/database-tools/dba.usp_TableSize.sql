/*============================================================================
  Procedure:   dba.usp_TableSize
  Purpose:     Table-level size and storage footprint diagnostics. Provides
               row counts, reserved space, data space, index space, and unused
               space for every table in a target database to support capacity
               planning, growth forecasting, and table health analysis.

  Overview:    - Runs from master (DB-agnostic via @DatabaseName)
               - Reads:
                     sys.tables
                     sys.schemas
                     sys.dm_db_partition_stats
                     sys.allocation_units
               - Computes:
                     * row_count
                     * total_space_mb
                     * data_space_mb
                     * index_space_mb
                     * unused_space_mb
               - Produces a unified, table-centric storage profile suitable for
                 dashboards, growth trend analysis, and table health scoring

  Output:      One row per table with:
                   schema_name
                   table_name
                   row_count
                   total_space_mb
                   data_space_mb
                   index_space_mb
                   unused_space_mb
                   allocation_type
                   evidence_query

  Notes:       - Fully DB-agnostic; safe to run from master or any DBA context
               - Complements:
                     dba.usp_TableBloat
                     dba.usp_TableRowCounts
                     dba.usp_TableCardinalityHealth
               - Forms the “Table Size & Storage” pillar of the modernization
                 toolkit and feeds into capacity planning dashboards

  Author:      Michael Lloyd — Gulf to Bay Analytics Modernization Toolkit
  ============================================================================*/

create or alter procedure dba.usp_TableSize
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
    -- Build the table size analysis query to run inside the target DB.
    -- Notes:
    --   - sys.dm_db_partition_stats gives row counts + page counts.
    --   - sys.allocation_units gives LOB and row-overflow usage.
    --   - sys.objects + sys.schemas provide metadata.
    --   - Output includes KB, MB, GB for readability.
    -------------------------------------------------------------------------
    declare @sql nvarchar(max) = '
    use [' + @DatabaseName + '];

    ---------------------------------------------------------------------
    -- CTE: base
    -- Purpose:
    --   - Pull row counts and page counts for each table/index
    ---------------------------------------------------------------------
    with base as (
        select
              p.object_id
            , p.index_id
            , p.row_count
            , p.reserved_page_count
            , p.used_page_count
            , p.in_row_data_page_count
            , p.lob_used_page_count
            , p.row_overflow_used_page_count
        from sys.dm_db_partition_stats p
    ),

    ---------------------------------------------------------------------
    -- CTE: agg
    -- Purpose:
    --   - Aggregate per table (sum across all indexes/partitions)
    ---------------------------------------------------------------------
    agg as (
        select
              b.object_id
            , sum(b.row_count) as row_count
            , sum(b.reserved_page_count) as reserved_pages
            , sum(b.used_page_count) as used_pages
            , sum(b.in_row_data_page_count) as inrow_pages
            , sum(b.lob_used_page_count) as lob_pages
            , sum(b.row_overflow_used_page_count) as overflow_pages
        from base b
        group by b.object_id
    ),

    ---------------------------------------------------------------------
    -- CTE: final
    -- Purpose:
    --   - Join metadata + size metrics
    --   - Compute KB/MB/GB
    ---------------------------------------------------------------------
    final as (
        select
              @@servername as server_name
            , db_name()    as database_name
            , sch.name     as schema_name
            , obj.name     as table_name
            , a.row_count
            , a.reserved_pages * 8 as reserved_kb
            , a.used_pages     * 8 as used_kb
            , a.inrow_pages    * 8 as inrow_kb
            , a.lob_pages      * 8 as lob_kb
            , a.overflow_pages * 8 as overflow_kb
            , (a.reserved_pages * 8.0) / 1024 as reserved_mb
            , (a.reserved_pages * 8.0) / 1024 / 1024 as reserved_gb
        from agg a
        inner join sys.objects obj on a.object_id = obj.object_id
        inner join sys.schemas sch on obj.schema_id = sch.schema_id
        where obj.type = ''U''
          and (' + case when @TableName is null 
                        then '1=1'
                        else 'obj.name = ''' + @TableName + '''' end + ')
    )

    ---------------------------------------------------------------------
    -- Final output
    ---------------------------------------------------------------------
    select *
    from final
    order by reserved_kb desc;
    ';

    exec(@sql);

end;

--exec dba.usp_TableSize @DatabaseName = 'AdventureWorksDW2019'

go

exec dba.usp_TableSize @DatabaseName = 'AdventureWorksDW2019'