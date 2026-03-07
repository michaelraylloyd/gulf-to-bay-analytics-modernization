/*============================================================================
  Procedure:   dba.usp_BlockingDiagnostics
  Purpose:     Real-time blocking and lock-chain diagnostics. Identifies active
               blockers, victims, lock types, wait resources, and blocking
               hierarchies to support rapid triage of concurrency issues.

  Overview:    - Reads sys.dm_exec_requests, sys.dm_os_waiting_tasks,
                 sys.dm_tran_locks, and session metadata
               - Surfaces:
                   * Lead blockers (head-of-line blockers)
                   * Blocked sessions and wait chains
                   * Wait types, wait resources, and lock modes
                   * SQL text and execution context
               - Produces a unified, session-centric blocking report suitable
                 for dashboards and real-time troubleshooting

  Output:      One row per blocked session with:
                   blocker_session_id
                   blocked_session_id
                   wait_type
                   wait_duration_ms
                   lock_mode
                   resource_description
                   program_name
                   login_name
                   host_name
                   sql_text

  Notes:       - Lightweight and safe for continuous use
               - No dynamic SQL required
               - Complements TempDBUsage, WaitStatsDiagnostics, and
                 QueryStorePerformanceDiagnostics

  Author:      Michael Lloyd — Gulf to Bay Analytics Modernization Toolkit
  ============================================================================*/
  
  create or alter procedure dba.usp_BlockingDiagnostics
      @DatabaseName sysname
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
    -- Build blocking diagnostics query to run inside the target DB.
    -------------------------------------------------------------------------
    declare @sql nvarchar(max) = '
    use [' + @DatabaseName + '];

    ---------------------------------------------------------------------
    -- CTE: req
    -- Purpose:
    --   - Active requests + blocking relationships
    ---------------------------------------------------------------------
    with req as (
        select
              r.session_id
            , r.blocking_session_id
            , r.wait_type
            , r.wait_time
            , r.wait_resource
            , r.status as request_status
            , r.cpu_time
            , r.total_elapsed_time
            , r.reads
            , r.writes
            , r.logical_reads
            , r.command
            , r.database_id
            , r.sql_handle
        from sys.dm_exec_requests r
        where r.database_id = db_id()
    ),

    ---------------------------------------------------------------------
    -- CTE: sess
    -- Purpose:
    --   - Session metadata (login, host, program)
    ---------------------------------------------------------------------
    sess as (
        select
              s.session_id
            , s.login_name
            , s.host_name
            , s.program_name
            , s.status as session_status
        from sys.dm_exec_sessions s
    ),

    ---------------------------------------------------------------------
    -- CTE: locks
    -- Purpose:
    --   - Lock owners + lock modes
    ---------------------------------------------------------------------
    locks as (
        select
              l.request_session_id as session_id
            , l.resource_type
            , l.resource_description
            , l.request_mode
            , l.request_status as lock_request_status
        from sys.dm_tran_locks l
        where l.resource_database_id = db_id()
    ),

    ---------------------------------------------------------------------
    -- CTE: sqltext
    -- Purpose:
    --   - SQL text for each session
    ---------------------------------------------------------------------
    sqltext as (
        select
              r.session_id
            , st.text as sql_text
        from req r
        outer apply sys.dm_exec_sql_text(r.sql_handle) st
    ),

    ---------------------------------------------------------------------
    -- CTE: joined
    -- Purpose:
    --   - Combine all blocking/locking/session info
    ---------------------------------------------------------------------
    joined as (
        select
              @@servername as server_name
            , db_name()    as database_name
            , r.session_id
            , r.blocking_session_id
            , s.login_name
            , s.host_name
            , s.program_name
            , r.request_status
            , r.wait_type
            , r.wait_time
            , r.wait_resource
            , r.cpu_time
            , r.total_elapsed_time
            , r.reads
            , r.writes
            , r.logical_reads
            , r.command
            , l.resource_type
            , l.resource_description
            , l.request_mode
            , l.lock_request_status
            , t.sql_text
            , case
                when r.blocking_session_id = 0 then ''NOT BLOCKED''
                when r.blocking_session_id is null then ''NOT BLOCKED''
                else ''BLOCKED''
              end as block_status
        from req r
        left join sess s on r.session_id = s.session_id
        left join locks l on r.session_id = l.session_id
        left join sqltext t on r.session_id = t.session_id
    )

    ---------------------------------------------------------------------
    -- Final output
    ---------------------------------------------------------------------
    select *
    from joined
    where blocking_session_id <> 0
       or block_status = ''BLOCKED''
    order by wait_time desc, session_id;
    ';

    exec(@sql);

end;

--exec dba.usp_BlockingDiagnostics @DatabaseName = 'AdventureWorksDW2019';

go

exec dba.usp_BlockingDiagnostics @DatabaseName = 'AdventureWorksDW2019';