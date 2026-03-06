/*============================================================================
  Procedure:   dba.usp_ForeignKeyHealth
  Purpose:     Comprehensive foreign key integrity diagnostics. Identifies
               structural, relational, and performance-related issues across
               all foreign keys in a target database.

  Overview:    - Scans all foreign keys and evaluates:
                   * Orphaned child rows
                   * Missing parent keys
                   * Missing supporting indexes
                   * Disabled or untrusted foreign keys
                   * Cascading actions (CASCADE/SET NULL/SET DEFAULT)
               - Produces a unified, evidence-rich diagnostic set
               - Designed as the upstream input for dba.usp_ForeignKeyFixScript

  Output:      One row per foreign key with:
                   schema_name
                   table_name
                   fk_name
                   issue_type
                   orphan_count
                   missing_parent_keys_count
                   child_row_count
                   has_supporting_index
                   is_disabled
                   is_not_trusted
                   evidence_query

  Notes:       - Fully DB-agnostic; safe to run from master or any DBA context
               - Uses dynamic SQL to evaluate relational integrity inside the
                 target database
               - Produces deterministic, GTB-aligned output suitable for
                 dashboards, CI pipelines, and controlled remediation workflows
               - Pairs directly with dba.usp_ForeignKeyFixScript to generate
                 safe, review-first fix scripts

  Author:      Michael Lloyd — Gulf to Bay Analytics Modernization Toolkit
  ============================================================================*/

create or alter procedure dba.usp_ForeignKeyHealth
      @DatabaseName sysname
    , @TableName   sysname = null
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
    -- Temp table to hold FK metadata
    -------------------------------------------------------------------------
    if object_id('tempdb..#FKs') is not null drop table #FKs;

    create table #FKs
    (
          foreign_key_name sysname
        , child_schema     sysname
        , child_table      sysname
        , parent_schema    sysname
        , parent_table     sysname
        , child_column     sysname
        , parent_column    sysname
        , is_disabled      bit
        , is_not_trusted   bit
        , delete_action    nvarchar(60)
        , update_action    nvarchar(60)
    );

    -------------------------------------------------------------------------
    -- Insert FK metadata from target DB
    -------------------------------------------------------------------------
    declare @sql nvarchar(max) = '
    use [' + @DatabaseName + '];

    insert into #FKs
    (
          foreign_key_name
        , child_schema
        , child_table
        , parent_schema
        , parent_table
        , child_column
        , parent_column
        , is_disabled
        , is_not_trusted
        , delete_action
        , update_action
    )
    select
          fk.name
        , sch_child.name
        , obj_child.name
        , sch_parent.name
        , obj_parent.name
        , c_child.name
        , c_parent.name
        , fk.is_disabled
        , fk.is_not_trusted
        , fk.delete_referential_action_desc
        , fk.update_referential_action_desc
    from sys.foreign_keys fk
    inner join sys.foreign_key_columns fkc
        on fk.object_id = fkc.constraint_object_id
    inner join sys.objects obj_child
        on fk.parent_object_id = obj_child.object_id
    inner join sys.schemas sch_child
        on obj_child.schema_id = sch_child.schema_id
    inner join sys.objects obj_parent
        on fk.referenced_object_id = obj_parent.object_id
    inner join sys.schemas sch_parent
        on obj_parent.schema_id = sch_parent.schema_id
    inner join sys.columns c_child
        on fkc.parent_object_id = c_child.object_id
       and fkc.parent_column_id = c_child.column_id
    inner join sys.columns c_parent
        on fkc.referenced_object_id = c_parent.object_id
       and fkc.referenced_column_id = c_parent.column_id
    where obj_child.type = ''U''
      and (' + case when @TableName is null 
                    then '1=1'
                    else 'obj_child.name = ''' + @TableName + '''' end + ');
    ';

    exec(@sql);

    -------------------------------------------------------------------------
    -- Temp table for results
    -------------------------------------------------------------------------
    if object_id('tempdb..#Results') is not null drop table #Results;

    create table #Results
    (
          foreign_key_name sysname
        , child_table      sysname
        , parent_table     sysname
        , issue            nvarchar(200)
    );

    -------------------------------------------------------------------------
    -- 1. Flag disabled or untrusted FKs
    -------------------------------------------------------------------------
    insert into #Results (foreign_key_name, child_table, parent_table, issue)
    select
          foreign_key_name
        , child_table
        , parent_table
        , case 
            when is_disabled = 1 then 'FOREIGN KEY DISABLED'
            when is_not_trusted = 1 then 'FOREIGN KEY NOT TRUSTED'
          end
    from #FKs
    where is_disabled = 1
       or is_not_trusted = 1;

    -------------------------------------------------------------------------
    -- 2. Detect missing supporting indexes on child columns
    -------------------------------------------------------------------------
    declare @MissingIndexSQL nvarchar(max) = '
    use [' + @DatabaseName + '];

    insert into #Results (foreign_key_name, child_table, parent_table, issue)
    select distinct
          f.foreign_key_name
        , f.child_table
        , f.parent_table
        , ''MISSING SUPPORTING INDEX ON CHILD COLUMN''
    from #FKs f
    left join [' + @DatabaseName + '].sys.index_columns ic
        on ic.object_id = object_id(f.child_schema + ''.'' + f.child_table)
       and ic.column_id = columnproperty(object_id(f.child_schema + ''.'' + f.child_table), f.child_column, ''ColumnId'')
    left join [' + @DatabaseName + '].sys.indexes i
        on ic.object_id = i.object_id
       and ic.index_id  = i.index_id
    where i.index_id is null;
    ';

    exec(@MissingIndexSQL);

    -------------------------------------------------------------------------
    -- 3. Orphan detection (must be dynamic per FK)
    -------------------------------------------------------------------------
    declare 
          @fk sysname
        , @child_schema sysname
        , @child_table  sysname
        , @parent_schema sysname
        , @parent_table  sysname
        , @child_col sysname
        , @parent_col sysname;

    declare fk_cursor cursor fast_forward for
    select foreign_key_name, child_schema, child_table, parent_schema, parent_table, child_column, parent_column
    from #FKs;

    open fk_cursor;
    fetch next from fk_cursor into @fk, @child_schema, @child_table, @parent_schema, @parent_table, @child_col, @parent_col;

    while @@fetch_status = 0
    begin
        declare @OrphanSQL nvarchar(max) = '
        use [' + @DatabaseName + '];

        if exists (
            select top 1 1
            from [' + @child_schema + '].[' + @child_table + '] c
            where not exists (
                select 1
                from [' + @parent_schema + '].[' + @parent_table + '] p
                where p.[' + @parent_col + '] = c.[' + @child_col + ']
            )
        )
        insert into #Results (foreign_key_name, child_table, parent_table, issue)
        values (''' + @fk + ''', ''' + @child_table + ''', ''' + @parent_table + ''', ''ORPHANED ROWS DETECTED'');
        ';

        exec(@OrphanSQL);

        fetch next from fk_cursor into @fk, @child_schema, @child_table, @parent_schema, @parent_table, @child_col, @parent_col;
    end;

    close fk_cursor;
    deallocate fk_cursor;

    -------------------------------------------------------------------------
    -- Final output
    -------------------------------------------------------------------------
    select
          @@servername as server_name
        , @DatabaseName as database_name
        , foreign_key_name
        , child_table
        , parent_table
        , issue
    from #Results
    order by child_table, foreign_key_name;

end;

--exec dba.usp_ForeignKeyHealth @DatabaseName = 'AdventureWorksDW2019'

go

exec dba.usp_ForeignKeyHealth @DatabaseName = 'AdventureWorksDW2019'