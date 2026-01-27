CREATE PROCEDURE ML.usp_UnifiedMetadataQueryTablesViews
--(
--      @SchemaName SYSNAME = 'ML'     -- Default schema
--)
AS
BEGIN
    SET NOCOUNT ON;

     declare @SchemaName SYSNAME = 'ML'     -- Default schema

    /* ============================
       TABLES (with PK + Indexes)
       ============================ */
    SELECT
          @@SERVERNAME AS ServerName
        , DB_NAME() AS DatabaseName
        , s.name AS SchemaName
        , t.name AS ObjectName
        , 'TABLE' AS ObjectType
        , c.name AS ColumnName
        , ty.name AS DataType
        , c.max_length AS MaxLength
        , c.is_nullable AS IsNullable
        , CASE WHEN kc.type = 'PK' THEN 1 ELSE 0 END AS IsPrimaryKey
        , i.name AS IndexName
        , i.type_desc AS IndexType
        , i.is_unique AS IsUnique
        , ic.key_ordinal AS IndexColumnOrder
    FROM sys.tables t
    INNER JOIN sys.schemas s
        ON t.schema_id = s.schema_id
    INNER JOIN sys.columns c
        ON c.object_id = t.object_id
    INNER JOIN sys.types ty
        ON c.user_type_id = ty.user_type_id
    LEFT JOIN sys.index_columns ic
        ON ic.object_id = t.object_id
        AND ic.column_id = c.column_id
    LEFT JOIN sys.indexes i
        ON i.object_id = t.object_id
        AND i.index_id = ic.index_id
    LEFT JOIN sys.key_constraints kc
        ON kc.parent_object_id = t.object_id
        AND kc.unique_index_id = i.index_id
    WHERE s.name = @SchemaName

    UNION ALL

    /* ============================
       VIEWS (no PKs or Indexes)
       ============================ */
    SELECT
          @@SERVERNAME AS ServerName
        , DB_NAME() AS DatabaseName
        , s.name AS SchemaName
        , v.name AS ObjectName
        , 'VIEW' AS ObjectType
        , c.name AS ColumnName
        , ty.name AS DataType
        , c.max_length AS MaxLength
        , c.is_nullable AS IsNullable
        , NULL AS IsPrimaryKey
        , NULL AS IndexName
        , NULL AS IndexType
        , NULL AS IsUnique
        , NULL AS IndexColumnOrder
    FROM sys.views v
    INNER JOIN sys.schemas s
        ON v.schema_id = s.schema_id
    INNER JOIN sys.columns c
        ON c.object_id = v.object_id
    INNER JOIN sys.types ty
        ON c.user_type_id = ty.user_type_id
    WHERE s.name = @SchemaName

    ORDER BY
          SchemaName
        , ObjectType
        , ObjectName
        , ColumnName;
END;
GO