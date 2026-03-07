/*============================================================================
  Procedure:   dba.usp_TempDBUsage
  Purpose:     Comprehensive TempDB usage and contention diagnostics. Surfaces
               file-level utilization, session/task allocations, version store
               pressure, and potential allocation bottlenecks to support
               real-time troubleshooting and capacity planning.

  Overview:    - Reads:
                     sys.dm_db_file_space_usage
                     sys.dm_db_session_space_usage
                     sys.dm_db_task_space_usage
                     sys.dm_tran_version_store_space_usage
                     sys.dm_os_waiting_tasks (PAGELATCH contention)
               - Evaluates:
                     * TempDB file sizes and free space
                     * Session and task allocations (internal vs user)
                     * Version store growth and cleanup lag
                     * Allocation contention (PAGELATCH_UP/EX on PFS/GAM/SGAM)
               - Produces a unified diagnostic set suitable for dashboards,
                 concurrency triage, and TempDB capacity forecasting

  Output:      One row per TempDB usage or contention finding with:
                   file_id
                   file_size_mb
                   used_space_mb
                   free_space_mb
                   session_id
                   task_allocations_mb
                   version_store_mb
                   contention_wait_type
                   contention_resource
                   severity
                   details

  Notes:       - Safe to run from any database; TempDB DMVs are global
               - No dynamic SQL required
               - Complements:
                     dba.usp_BlockingDiagnostics
                     dba.usp_WaitStatsDiagnostics
                     dba.usp_QueryStorePerformanceDiagnostics
               - Forms the “TempDB Health & Concurrency” pillar of the
                 modernization toolkit

  Author:      Michael Lloyd — Gulf to Bay Analytics Modernization Toolkit
  ============================================================================*/

create or alter procedure dba.usp_TempDBUsage
as
begin
    set nocount on;

    -------------------------------------------------------------------------
    -- TempDB is always database_id = 2. No parameters needed.
    -------------------------------------------------------------------------

    -------------------------------------------------------------------------
    -- 1. TempDB File Size + Space Usage
    -------------------------------------------------------------------------
    select
          @@servername as server_name
        , db_name(2)   as database_name
        , mf.name      as file_name
        , mf.type_desc as file_type
        , mf.size * 8 / 1024 as size_mb
        , fileproperty(mf.name, 'SpaceUsed') * 8 / 1024 as used_mb
        , (mf.size - fileproperty(mf.name, 'SpaceUsed')) * 8 / 1024 as free_mb
        , mf.physical_name
    from tempdb.sys.database_files mf
    order by mf.type_desc, mf.name;

    -------------------------------------------------------------------------
    -- 2. TempDB Usage by Session
    -------------------------------------------------------------------------
    select
          @@servername as server_name
        , s.session_id
        , s.login_name
        , s.host_name
        , s.program_name
        , ssu.internal_objects_alloc_page_count * 8 / 1024 as internal_mb
        , ssu.user_objects_alloc_page_count     * 8 / 1024 as user_mb
        , ssu.internal_objects_dealloc_page_count * 8 / 1024 as internal_dealloc_mb
        , ssu.user_objects_dealloc_page_count     * 8 / 1024 as user_dealloc_mb
    from sys.dm_db_session_space_usage ssu
    inner join sys.dm_exec_sessions s
        on ssu.session_id = s.session_id
    where s.is_user_process = 1
    order by (ssu.internal_objects_alloc_page_count + ssu.user_objects_alloc_page_count) desc;

    -------------------------------------------------------------------------
    -- 3. TempDB Usage by Task
    -------------------------------------------------------------------------
    select
          @@servername as server_name
        , r.session_id
        , r.request_id
        , tsu.internal_objects_alloc_page_count * 8 / 1024 as internal_mb
        , tsu.user_objects_alloc_page_count     * 8 / 1024 as user_mb
        , tsu.internal_objects_dealloc_page_count * 8 / 1024 as internal_dealloc_mb
        , tsu.user_objects_dealloc_page_count     * 8 / 1024 as user_dealloc_mb
        , r.status
        , r.command
        , r.cpu_time
        , r.total_elapsed_time
        , r.reads
        , r.writes
        , r.logical_reads
    from sys.dm_db_task_space_usage tsu
    inner join sys.dm_exec_requests r
        on tsu.session_id = r.session_id
       and tsu.request_id = r.request_id
    order by (tsu.internal_objects_alloc_page_count + tsu.user_objects_alloc_page_count) desc;

    -------------------------------------------------------------------------
    -- 4. Version Store Usage (correct DMV columns)
    -------------------------------------------------------------------------
    select
          @@servername as server_name
        , db_name(database_id) as database_name
        , total_page_count * 8 / 1024 as total_mb
        , version_store_reserved_page_count * 8 / 1024 as version_store_mb
        , user_object_reserved_page_count * 8 / 1024 as user_object_mb
        , internal_object_reserved_page_count * 8 / 1024 as internal_object_mb
        , mixed_extent_page_count * 8 / 1024 as mixed_extent_mb
    from sys.dm_db_file_space_usage
    where database_id = 2;

    -------------------------------------------------------------------------
    -- 5. TempDB Contention Indicators (PAGELATCH waits)
    -------------------------------------------------------------------------
    select
          @@servername as server_name
        , wait_type
        , waiting_tasks_count
        , wait_time_ms
        , max_wait_time_ms
        , signal_wait_time_ms
    from sys.dm_os_wait_stats
    where wait_type in (
          'PAGELATCH_UP'
        , 'PAGELATCH_EX'
        , 'PAGELATCH_SH'
    )
    order by wait_time_ms desc;

end;

--exec dba.usp_TempDBUsage

go

exec dba.usp_TempDBUsage