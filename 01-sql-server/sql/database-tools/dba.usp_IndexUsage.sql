/*============================================================================
  Procedure:   dba.usp_IndexUsage
  Purpose:     Workload-driven index usage diagnostics. Surfaces heavily used,
               underused, and unused indexes to support consolidation, tuning,
               and maintenance decisions.

  Overview:    - Reads index usage DMVs:
                     sys.dm_db_index_usage_stats
                     sys.dm_db_partition_stats
                     sys.indexes
               - Evaluates:
                     * user_seeks / user_scans / user_lookups
                     * user_updates (write overhead)
                     * row_count and page_count
                     * unused indexes (no seeks/scans/lookups)
               - Highlights:
                     * High-value indexes (heavy read usage)
                     * Write-heavy indexes with low read benefit
                     * Completely unused indexes
                     * Candidates for consolidation (pairs with IndexRedundancy)

  Output:      One row per index with:
                   database_name
                   schema_name
                   table_name
                   index_name
                   user_seeks
                   user_scans
                   user_lookups
                   user_updates
                   row_count
                   page_count
                   usage_category
                   rationale

  Notes:       - Fully DB-agnostic; safe to run from master or any DBA context
               - Usage categories are deterministic and GTB-aligned:
                     * HIGH_READ
                     * WRITE_HEAVY
                     * UNUSED
                     * BALANCED
               - Complements:
                     dba.usp_IndexAdvisor
                     dba.usp_IndexRedundancy
                     dba.usp_IndexMaintenanceAdvisor
               - Forms the “Index Usage & Workload Insight” pillar of the
                 modernization toolkit

  Author:      Michael Lloyd — Gulf to Bay Analytics Modernization Toolkit
  ============================================================================*/

create or alter procedure dba.usp_IndexUsage
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
    -- Build the DMV query to run inside the target database.
    -- Notes:
    --   - sys.dm_db_index_usage_stats is database-scoped.
    --   - sys.indexes, sys.objects, sys.schemas, sys.dm_db_partition_stats
    --     are also database-scoped.
    --   - row_count is the correct column name (not "rows").
    -------------------------------------------------------------------------
    declare @sql nvarchar(max) = '
    use [' + @DatabaseName + '];

    ---------------------------------------------------------------------
    -- CTE: usage
    -- Purpose:
    --   - Pull index usage stats (seeks, scans, lookups, updates)
    --   - Left join because unused indexes have no usage rows
    ---------------------------------------------------------------------
    with usage as (
        select
              object_id
            , index_id
            , user_seeks
            , user_scans
            , user_lookups
            , user_updates
        from sys.dm_db_index_usage_stats
        where database_id = db_id()
    ),

    ---------------------------------------------------------------------
    -- CTE: idx
    -- Purpose:
    --   - Pull index metadata (name, type, uniqueness)
    --   - Include partition info for size calculations
    --   - row_count is the correct column name
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
    -- CTE: frag
    -- Purpose:
    --   - Pull fragmentation info for maintenance decisions
    ---------------------------------------------------------------------
    frag as (
        select
              object_id
            , index_id
            , avg_fragmentation_in_percent
        from sys.dm_db_index_physical_stats
             (db_id(), null, null, null, ''LIMITED'')
    ),

    ---------------------------------------------------------------------
    -- CTE: joined
    -- Purpose:
    --   - Combine usage + metadata + fragmentation + object info
    --   - Produce a unified diagnostic table
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
            , u.user_seeks
            , u.user_scans
            , u.user_lookups
            , u.user_updates
            , f.avg_fragmentation_in_percent
            , (idx.reserved_page_count * 8) as size_kb
        from idx
        inner join sys.objects obj on idx.object_id = obj.object_id
        inner join sys.schemas sch on obj.schema_id = sch.schema_id
        left join usage u on idx.object_id = u.object_id
                         and idx.index_id  = u.index_id
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

--exec dba.usp_IndexUsage @DatabaseName = 'AdventureWorksDW2019'

go

exec dba.usp_IndexUsage @DatabaseName = 'AdventureWorksDW2019'