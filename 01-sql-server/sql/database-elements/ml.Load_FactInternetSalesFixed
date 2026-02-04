create or alter procedure ml.Load_FactInternetSalesFixed
as
begin

    set nocount on;

    -------------------------------------------------------------------------
    -- 1. Rebuild staging table (toggle pattern)
    --    Ensures staging is always clean and schema-correct.
    --    Safe because staging is non-persistent by design.
    -------------------------------------------------------------------------
    drop table if exists stg.FactInternetSalesRaw;

    create table stg.FactInternetSalesRaw
    (
          SalesOrderID           int
        , ProductID              int
        , CustomerID             int
        , OrderDate              date
        , DueDate                date
        , ShipDate               date
        , ShipToAddressID        int
        , OrderQty               int
        , UnitPrice              money
        , LineTotal              money
        , ProductSubcategoryID   int
        , ProductCategoryID      int
        , StateProvinceID        int
        , PostalCode             nvarchar(15)
    );

    -------------------------------------------------------------------------
    -- 2. Clear destination fact table (full reload pattern)
    -------------------------------------------------------------------------
    truncate table ml.FactInternetSalesFixed;

    -------------------------------------------------------------------------
    -- 3. Reset identity seed to start at 1
    --    Ensures FactSalesKey always begins at 1 for each full reload.
    -------------------------------------------------------------------------
    dbcc checkident ('ml.FactInternetSalesFixed', reseed, 0);

    -------------------------------------------------------------------------
    -- 4. Insert enriched rows into DW fact table
    --    Performs surrogate key lookups and DW enrichment.
    -------------------------------------------------------------------------
    insert into ml.FactInternetSalesFixed
    (
          SalesOrderID
        , ProductID
        , CustomerID
        , OrderDate
        , DueDate
        , ShipDate
        , ShipToAddressID
        , OrderQty
        , UnitPrice
        , LineTotal
        , ProductSubcategoryID
        , ProductCategoryID
        , StateProvinceID
        , PostalCode
    )
    select
          s.SalesOrderID

        ---------------------------------------------------------------------
        -- Customer surrogate key
        ---------------------------------------------------------------------
        , dc.CustomerKey

        ---------------------------------------------------------------------
        -- Geography surrogate key
        ---------------------------------------------------------------------
        , dg.GeographyKey

        ---------------------------------------------------------------------
        -- Product surrogate keys
        ---------------------------------------------------------------------
        --, dp.ProductKey
        , dps.ProductSubcategoryKey
        , dpc.ProductCategoryKey

        ---------------------------------------------------------------------
        -- Date surrogate keys
        ---------------------------------------------------------------------
        , dod.DateKey
        , ddd.DateKey
        , dsd.DateKey

        ---------------------------------------------------------------------
        -- Measures
        ---------------------------------------------------------------------
        , s.OrderQty
        , s.UnitPrice
        , s.LineTotal
        , s.PostalCode

    from stg.FactInternetSalesRaw              s

        ---------------------------------------------------------------------
        -- Dimension lookups (DW)
        ---------------------------------------------------------------------
        left join dbo.DimCustomer              dc  on dc.CustomerKey            = s.CustomerKey
        left join dbo.DimGeography             dg  on dg.StateProvinceCode      = s.StateProvinceCode
        left join dbo.DimProduct               dp  on dp.ProductID              = s.ProductID
        left join dbo.DimProductSubcategory    dps on dps.ProductSubcategoryID  = s.ProductSubcategoryID
        left join dbo.DimProductCategory       dpc on dpc.ProductCategoryKey    = s.ProductCategoryKey
        left join dbo.DimDate                  dod on dod.FullDateAlternateKey  = s.OrderDate
        left join dbo.DimDate                  ddd on ddd.FullDateAlternateKey  = s.DueDate
        left join dbo.DimDate                  dsd on dsd.FullDateAlternateKey  = s.ShipDate;

end;
go

/* -------------------------------------------------------------------------
-- EXECUTION TOGGLE BLOCK
-- Uncomment to manually run the stored procedure during development/testing.
-- This block stays commented out in production deployments.
---------------------------------------------------------------------------

-- exec ml.Load_FactInternetSalesFixed;

--------------------------------------------------------------------------- */