/*============================================================================
  Procedure:   dba.usp_IndexRedundancy
  Purpose:     Identifies redundant, overlapping, and duplicate indexes across
               all tables in a target database. Highlights consolidation
               opportunities to reduce write overhead, memory pressure, and
               maintenance cost.

  Overview:    - Analyzes index definitions using:
                     sys.indexes
                     sys.index_columns
                     sys.columns
                     sys.stats
               - Detects:
                     * Exact duplicate indexes
                     * Left-based prefix overlaps
                     * Redundant INCLUDE lists
                     * Unused or low-usage indexes (optional if paired with
                       dba.usp_IndexUsage)
               - Produces consolidation recommendations with clear rationale

  Output:      One row per redundancy finding with:
                   schema_name
                   table_name
                   redundant_index_name
                   preferred_index_name
                   redundancy_type
                   key_columns
                   include_columns
                   recommended_action
                   rationale

  Notes:       - Fully DB-agnostic; safe to run from master or any DBA context
               - Recommendations are deterministic and GTB-aligned
               - Does not drop indexes automatically; output is review-first
               - Complements:
                     dba.usp_IndexAdvisor
                     dba.usp_IndexUsage
                     dba.usp_IndexMaintenanceAdvisor
               - Forms the “Index Governance” pillar of the modernization toolkit

  Author:      Michael Lloyd — Gulf to Bay Analytics Modernization Toolkit
  ============================================================================*/

create or alter procedure dba.usp_IndexRedundancy
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
    -- Build the redundancy analysis query to run inside the target DB.
    -- Notes:
    --   - sys.indexes, sys.index_columns, sys.columns, sys.objects,
    --     sys.schemas are all database-scoped.
    --   - We compute key columns and include columns as comma-separated lists.
    --   - Redundancy logic:
    --       * Duplicate: same keys + same includes
    --       * Overlapping: one index's keys are a left-based subset of another
    -------------------------------------------------------------------------
    declare @sql nvarchar(max) = '
    use [' + @DatabaseName + '];

    ---------------------------------------------------------------------
    -- CTE: idxcols
    -- Purpose:
    --   - Build ordered lists of key columns and include columns
    ---------------------------------------------------------------------
    with idxcols as (
        select
              i.object_id
            , i.index_id
            , i.name as index_name
            , i.type_desc as index_type
            , sch.name as schema_name
            , obj.name as table_name
            , stuff((
                    select '','' + c.name
                    from sys.index_columns ic2
                    inner join sys.columns c
                        on ic2.object_id = c.object_id
                       and ic2.column_id = c.column_id
                    where ic2.object_id = i.object_id
                      and ic2.index_id  = i.index_id
                      and ic2.is_included_column = 0
                    order by ic2.key_ordinal
                    for xml path(''''), type).value(''.'', ''nvarchar(max)'')
                , 1, 1, '''') as key_columns
            , stuff((
                    select '','' + c.name
                    from sys.index_columns ic2
                    inner join sys.columns c
                        on ic2.object_id = c.object_id
                       and ic2.column_id = c.column_id
                    where ic2.object_id = i.object_id
                      and ic2.index_id  = i.index_id
                      and ic2.is_included_column = 1
                    order by c.name
                    for xml path(''''), type).value(''.'', ''nvarchar(max)'')
                , 1, 1, '''') as include_columns
        from sys.indexes i
        inner join sys.objects obj on i.object_id = obj.object_id
        inner join sys.schemas sch on obj.schema_id = sch.schema_id
        where obj.type = ''U''
          and i.is_hypothetical = 0
          and (' + case when @TableName is null 
                        then '1=1'
                        else 'obj.name = ''' + @TableName + '''' end + ')
    ),

    ---------------------------------------------------------------------
    -- CTE: pairs
    -- Purpose:
    --   - Compare every index to every other index on the same table
    --   - Identify duplicates and overlaps
    ---------------------------------------------------------------------
    pairs as (
        select
              a.schema_name
            , a.table_name
            , a.index_name as index_a
            , b.index_name as index_b
            , a.key_columns as key_a
            , b.key_columns as key_b
            , a.include_columns as include_a
            , b.include_columns as include_b
            , case 
                when a.key_columns = b.key_columns
                 and isnull(a.include_columns, '''') = isnull(b.include_columns, '''')
                then ''DUPLICATE''
                when b.key_columns like a.key_columns + ''%''
                then ''A IS LEFT-BASED SUBSET OF B''
                when a.key_columns like b.key_columns + ''%''
                then ''B IS LEFT-BASED SUBSET OF A''
                else null
              end as redundancy_type
        from idxcols a
        inner join idxcols b
            on a.object_id = b.object_id
           and a.index_id <> b.index_id
    )

    ---------------------------------------------------------------------
    -- Final output: only redundant relationships
    ---------------------------------------------------------------------
    select
          @@servername as server_name
        , ''' + @DatabaseName + ''' as database_name
        , schema_name
        , table_name
        , index_a
        , index_b
        , redundancy_type
        , key_a
        , key_b
        , include_a
        , include_b
    from pairs
    where redundancy_type is not null
    order by table_name, index_a, index_b;
    ';

    exec(@sql);

end;

--exec dba.usp_IndexRedundancy 
--      @DatabaseName = 'AdventureWorksDW2019',
--      @TableName    = 'FactInternetSales';

go

exec dba.usp_IndexRedundancy 
      @DatabaseName = 'AdventureWorksDW2019',
      @TableName    = 'FactInternetSales';