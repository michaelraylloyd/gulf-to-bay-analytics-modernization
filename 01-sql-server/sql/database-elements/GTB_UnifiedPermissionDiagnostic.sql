/*==============================================================================
    Purpose:
        Unified, deduplicated diagnostic query showing all relevant details
        about the database user `fabric_user` in the current database.

        Surfaces:
            - Principal existence
            - Role memberships
            - Object-level permissions
            - Schema-level permissions
            - Server + database context

        Notes:
            - Run inside the target database (DW, OLTP, etc.)
            - Results reflect only the current DB (Azure SQL is DB-scoped)
            - Ideal for debugging ADF runtime identity issues
==============================================================================*/

with user_info as
(
    /*----------------------------------------------------------------------
        Principal existence
        Confirms the user is mapped in this database and shows type.
    ----------------------------------------------------------------------*/
    select
          'principal'          as source
        , db_name()            as database_name
        , @@servername         as server_name
        , p.name               as principal_name
        , p.type_desc          as principal_type
        , null                 as role_name
        , null                 as permission_name
        , null                 as state_desc
        , null                 as object_name
        , null                 as schema_name
    from sys.database_principals p
    where p.name = 'fabric_user'

    union all

    /*----------------------------------------------------------------------
        Role memberships
        Shows built-in or custom roles the user belongs to.
    ----------------------------------------------------------------------*/
    select
          'role_membership'    as source
        , db_name()            as database_name
        , @@servername         as server_name
        , m.name               as principal_name
        , m.type_desc          as principal_type
        , r.name               as role_name
        , null                 as permission_name
        , null                 as state_desc
        , null                 as object_name
        , null                 as schema_name
    from sys.database_role_members rm
    join sys.database_principals r on rm.role_principal_id = r.principal_id
    join sys.database_principals m on rm.member_principal_id = m.principal_id
    where m.name = 'fabric_user'

    union all

    /*----------------------------------------------------------------------
        Object-level permissions
        Shows GRANT/DENY at the table/view/function level.
    ----------------------------------------------------------------------*/
    select
          'object_permission'  as source
        , db_name()            as database_name
        , @@servername         as server_name
        , p.name               as principal_name
        , p.type_desc          as principal_type
        , null                 as role_name
        , dp.permission_name   as permission_name
        , dp.state_desc        as state_desc
        , o.name               as object_name
        , s.name               as schema_name
    from sys.database_permissions dp
    join sys.database_principals p on dp.grantee_principal_id = p.principal_id
    join sys.objects o             on dp.major_id = o.object_id
    join sys.schemas s             on o.schema_id = s.schema_id
    where p.name = 'fabric_user'

    union all

    /*----------------------------------------------------------------------
        Schema-level permissions
        Shows GRANT/DENY at the schema level (SELECT/INSERT/etc.).
        dp.class = 3 ? schema permissions.
    ----------------------------------------------------------------------*/
    select
          'schema_permission'  as source
        , db_name()            as database_name
        , @@servername         as server_name
        , p.name               as principal_name
        , p.type_desc          as principal_type
        , null                 as role_name
        , dp.permission_name   as permission_name
        , dp.state_desc        as state_desc
        , null                 as object_name
        , s.name               as schema_name
    from sys.database_permissions dp
    join sys.database_principals p on dp.grantee_principal_id = p.principal_id
    join sys.schemas s             on dp.major_id = s.schema_id
    where dp.class = 3
      and p.name = 'fabric_user'
)

select distinct
      source
    , database_name
    , server_name
    , principal_name
    , principal_type
    , role_name
    , permission_name
    , state_desc
    , object_name
    , schema_name
from user_info
order by
      source
    , role_name
    , permission_name
    , schema_name
    , object_name;
