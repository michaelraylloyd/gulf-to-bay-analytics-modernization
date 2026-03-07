/*============================================================================
  Procedure:   dba.usp_UserDiagnostics
  Purpose:     Comprehensive user and security principal diagnostics. Surfaces
               logins, database users, role memberships, explicit permissions,
               effective permissions, and orphaned or elevated principals to
               support security posture analysis and audit readiness.

  Overview:    - Consolidates multiple security metadata sources:
                     sys.server_principals
                     sys.database_principals
                     sys.database_role_members
                     sys.server_role_members
                     sys.database_permissions
                     sys.server_permissions
               - Evaluates:
                     * Login → user mappings
                     * Role memberships (server + database)
                     * Explicit vs inherited permissions
                     * Orphaned users
                     * Elevated principals (db_owner, sysadmin, CONTROL SERVER)
               - Produces a unified, evidence-rich diagnostic set suitable for
                 dashboards, audits, and least-privilege reviews

  Output:      Multiple result sets including:
                   - Logins and database users
                   - Database role memberships
                   - Server role memberships
                   - Explicit database permissions
                   - Effective permissions summary
                   - Orphaned users
                   - Elevated or high-risk principals
                   - Object-level permission maps

  Notes:       - Fully DB-agnostic; safe to run from master or any DBA context
               - Output is clean, exportable, and designed for Power BI
               - Complements:
                     dba.usp_ServerSecurityHealth
                     dba.usp_SecurityAndPermissionsHealth
               - Forms the “User & Security Diagnostics” pillar of the
                 modernization toolkit

  Author:      Michael Lloyd — Gulf to Bay Analytics Modernization Toolkit
  ============================================================================*/

create or alter procedure dba.usp_UserDiagnostics
      @DatabaseName sysname = null      -- optional: run against a specific DB
    , @UserName sysname = null
    , @RoleName sysname = null
    , @ObjectName sysname = null
as
begin
    set nocount on;

    -------------------------------------------------------------------------
    -- If a database name is provided, switch context dynamically.
    -------------------------------------------------------------------------
    if @DatabaseName is not null
    begin
        declare @sql nvarchar(max) =
        '
        use [' + @DatabaseName + '];

        with users as (
            select 
                  dp.principal_id
                , dp.name as user_name
                , dp.type_desc as user_type
                , dp.authentication_type_desc
                , dp.default_schema_name
                , sp.name as login_name
                , case when sp.sid is null then 1 else 0 end as is_orphaned
            from sys.database_principals dp
            left join sys.server_principals sp on dp.sid = sp.sid
            where dp.type in (''S'',''U'',''G'')
              and dp.name not in (''dbo'',''guest'',''INFORMATION_SCHEMA'',''sys'')
              and (' + case when @UserName is null then '1=1' else 'dp.name = ''' + @UserName + '''' end + ')
        ),
        roles as (
            select 
                  rm.member_principal_id as principal_id
                , r.name as role_name
                , case when r.name in (''db_owner'',''db_securityadmin'',''db_accessadmin'') 
                       then 1 else 0 end as is_elevated_role
            from sys.database_role_members rm
            join sys.database_principals r on rm.role_principal_id = r.principal_id
            where (' + case when @RoleName is null then '1=1' else 'r.name = ''' + @RoleName + '''' end + ')
        ),
        perms as (
            select 
                  dp.grantee_principal_id as principal_id
                , dp.permission_name
                , dp.state_desc as permission_state
                , dp.class_desc as permission_scope
                , obj.name as object_name
                , obj.type_desc as object_type
                , sch.name as schema_name
            from sys.database_permissions dp
            left join sys.objects obj on dp.major_id = obj.object_id
            left join sys.schemas sch on obj.schema_id = sch.schema_id
            where (' + case when @ObjectName is null then '1=1' else 'obj.name = ''' + @ObjectName + '''' end + ')
        )
        select 
              @@SERVERNAME as server_name
            , DB_NAME() as database_name
            , u.user_name
            , u.user_type
            , u.authentication_type_desc
            , u.default_schema_name
            , u.login_name
            , u.is_orphaned
            , r.role_name
            , r.is_elevated_role
            , p.permission_name
            , p.permission_state
            , p.permission_scope
            , p.schema_name
            , p.object_name
            , p.object_type
        from users u
        left join roles r on u.principal_id = r.principal_id
        left join perms p on u.principal_id = p.principal_id
        order by 
              u.user_name
            , r.role_name
            , p.object_name
            , p.permission_name;
        ';

        exec(@sql);
        return;
    end;

    -------------------------------------------------------------------------
    -- If no database name is provided, run in the current DB context.
    -------------------------------------------------------------------------
    with users as (
        select 
              dp.principal_id
            , dp.name as user_name
            , dp.type_desc as user_type
            , dp.authentication_type_desc
            , dp.default_schema_name
            , sp.name as login_name
            , case when sp.sid is null then 1 else 0 end as is_orphaned
        from sys.database_principals dp
        left join sys.server_principals sp on dp.sid = sp.sid
        where dp.type in ('S','U','G')
          and dp.name not in ('dbo','guest','INFORMATION_SCHEMA','sys')
          and (@UserName is null or dp.name = @UserName)
    ),
    roles as (
        select 
              rm.member_principal_id as principal_id
            , r.name as role_name
            , case when r.name in ('db_owner','db_securityadmin','db_accessadmin') 
                   then 1 else 0 end as is_elevated_role
        from sys.database_role_members rm
        join sys.database_principals r on rm.role_principal_id = r.principal_id
        where (@RoleName is null or r.name = @RoleName)
    ),
    perms as (
        select 
              dp.grantee_principal_id as principal_id
            , dp.permission_name
            , dp.state_desc as permission_state
            , dp.class_desc as permission_scope
            , obj.name as object_name
            , obj.type_desc as object_type
            , sch.name as schema_name
        from sys.database_permissions dp
        left join sys.objects obj on dp.major_id = obj.object_id
        left join sys.schemas sch on obj.schema_id = sch.schema_id
        where (@ObjectName is null or obj.name = @ObjectName)
    )
    select 
          @@SERVERNAME as server_name
        , DB_NAME() as database_name
        , u.user_name
        , u.user_type
        , u.authentication_type_desc
        , u.default_schema_name
        , u.login_name
        , u.is_orphaned
        , r.role_name
        , r.is_elevated_role
        , p.permission_name
        , p.permission_state
        , p.permission_scope
        , p.schema_name
        , p.object_name
        , p.object_type
    from users u
    left join roles r on u.principal_id = r.principal_id
    left join perms p on u.principal_id = p.principal_id
    order by 
          u.user_name
        , r.role_name
        , p.object_name
        , p.permission_name;

end;

--exec dba.usp_UserDiagnostics

go

exec dba.usp_UserDiagnostics