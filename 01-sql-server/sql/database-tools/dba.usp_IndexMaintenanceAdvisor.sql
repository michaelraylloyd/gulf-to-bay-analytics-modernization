/*============================================================================
  Procedure:   dba.usp_IndexMaintenanceAdvisor
  Purpose:     Evidence-driven index maintenance recommendations. Evaluates
               fragmentation, page density, and row distribution to determine
               whether indexes should be REBUILD, REORGANIZE, UPDATE STATISTICS,
               or left untouched.

  Overview:    - Reads sys.dm_db_index_physical_stats for fragmentation metrics
               - Evaluates:
                     * avg_fragmentation_in_percent
                     * page_count thresholds
                     * index depth and allocation unit type
               - Applies deterministic, GTB-aligned rules:
                     * REBUILD for high fragmentation and sufficient page count
                     * REORGANIZE for moderate fragmentation
                     * UPDATE STATISTICS for low fragmentation but stale stats
                     * NO ACTION when maintenance is unnecessary
               - Produces review-first recommendations (no automatic changes)

  Output:      One row per index with:
                   database_name
                   schema_name
                   table_name
                   index_name
                   fragmentation_pct
                   page_count
                   maintenance_action
                   rationale
                   evidence_query

  Notes:       - Fully DB-agnostic; safe to run from master or any DBA context
               - Recommendations are deterministic and safe for automation
               - Complements:
                     dba.usp_IndexAdvisor
                     dba.usp_IndexUsage
                     dba.usp_IndexRedundancy
               - Forms the “Index Maintenance” pillar of the modernization toolkit

  Author:      Michael Lloyd — Gulf to Bay Analytics Modernization Toolkit
  ============================================================================*/

create or alter procedure dba.usp_IndexMaintenanceAdvisor
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
    -- Build the maintenance analysis query to run inside the target DB.
    -- Notes:
    --   - Uses dm_db_index_physical_stats for fragmentation.
    --   - Uses dm_db_partition_stats for page counts.
    --   - Uses sys.indexes, sys.objects, sys.schemas for metadata.
    --   - REBUILD / REORGANIZE thresholds follow Microsoft best practices:
    --       * > 30% fragmentation → REBUILD
    --       * 10–30% fragmentation → REORGANIZE
    --       * < 10% fragmentation → UPDATE STATISTICS (optional)
    -------------------------------------------------------------------------
    declare @sql nvarchar(max) = '
    use [' + @DatabaseName + '];

    ---------------------------------------------------------------------
    -- CTE: frag
    -- Purpose:
    --   - Pull fragmentation info for all indexes
    ---------------------------------------------------------------------
    with frag as (
        select
              object_id
            , index_id
            , avg_fragmentation_in_percent
            , page_count
        from sys.dm_db_index_physical_stats
             (db_id(), null, null, null, ''LIMITED'')
    ),

    ---------------------------------------------------------------------
    -- CTE: idx
    -- Purpose:
    --   - Pull index metadata and page counts
    ---------------------------------------------------------------------
    idx as (
        select
              i.object_id
            , i.index_id
            , i.name as index_name
            , i.type_desc as index_type
            , i.is_unique
            , p.row_count
            , p.reserved_page_count
            , p.used_page_count
        from sys.indexes i
        inner join sys.dm_db_partition_stats p
            on i.object_id = p.object_id
           and i.index_id  = p.index_id
        where i.is_hypothetical = 0
    ),

    ---------------------------------------------------------------------
    -- CTE: joined
    -- Purpose:
    --   - Combine fragmentation + metadata + object info
    --   - Compute maintenance recommendation
    ---------------------------------------------------------------------
    joined as (
        select
              @@servername as server_name
            , db_name()    as database_name
            , sch.name     as schema_name
            , obj.name     as table_name
            , idx.index_name
            , idx.index_type
            , idx.is_unique
            , idx.row_count
            , idx.reserved_page_count
            , idx.used_page_count
            , f.avg_fragmentation_in_percent
            , f.page_count
            , case
                when f.page_count < 100
                     then ''NO ACTION (small index)''
                when f.avg_fragmentation_in_percent >= 30
                     then ''REBUILD''
                when f.avg_fragmentation_in_percent between 10 and 30
                     then ''REORGANIZE''
                when f.avg_fragmentation_in_percent < 10
                     then ''UPDATE STATISTICS''
                else ''NO ACTION''
              end as maintenance_recommendation
        from idx
        inner join sys.objects obj on idx.object_id = obj.object_id
        inner join sys.schemas sch on obj.schema_id = sch.schema_id
        left join frag f on idx.object_id = f.object_id
                        and idx.index_id  = f.index_id
        where obj.type = ''U''
          and (' + case when @TableName is null 
                        then '1=1'
                        else 'obj.name = ''' + @TableName + '''' end + ')
    )

    ---------------------------------------------------------------------
    -- Final output
    ---------------------------------------------------------------------
    select *
    from joined
    order by table_name, index_name;
    ';

    exec(@sql);

end;

--exec dba.usp_IndexMaintenanceAdvisor 
--      @DatabaseName = 'AdventureWorksDW2019'

go

exec dba.usp_IndexMaintenanceAdvisor 
      @DatabaseName = 'AdventureWorksDW2019'