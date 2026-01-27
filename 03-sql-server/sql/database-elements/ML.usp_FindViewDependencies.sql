/***********************************************************************************************
    View Dependency Search
    Recursively finds all tables/views referenced by a given view (or all views if no filter).
***********************************************************************************************/

DECLARE @ViewName VARCHAR(200) = NULL;   -- Example: 'vw_SalesSummary'

;WITH Dependencies
(
      SchemaName
    , ViewName
    , DependentOn
) AS
(
    /* Base level: direct dependencies */
    SELECT
          s.name
        , v.name
        , sed.referenced_entity_name
    FROM sys.sql_expression_dependencies sed
    INNER JOIN sys.views v
        ON sed.referencing_id = v.object_id
    INNER JOIN sys.schemas s
        ON v.schema_id = s.schema_id
    WHERE v.name = ISNULL(@ViewName, v.name)

    UNION ALL

    /* Recursive level: dependencies of dependencies */
    SELECT
          s.name
        , v.name
        , sed.referenced_entity_name
    FROM sys.sql_expression_dependencies sed
    INNER JOIN sys.views v
        ON sed.referencing_id = v.object_id
    INNER JOIN Dependencies d
        ON d.DependentOn = v.name
    INNER JOIN sys.schemas s
        ON v.schema_id = s.schema_id
)
SELECT
      @@SERVERNAME AS ServerName
    , DB_NAME()    AS DatabaseName
    , SchemaName
    , ViewName
    , DependentOn AS DependentOnTableOrView
FROM Dependencies
ORDER BY
      ServerName
    , DatabaseName
    , SchemaName
    , ViewName
    , DependentOn;