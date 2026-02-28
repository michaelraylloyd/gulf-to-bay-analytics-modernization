create or alter procedure ml.Load_FactInternetSalesFixed
as
begin
    set nocount on;

    -------------------------------------------------------------------------
    -- 1. Rebuild staging table
    -------------------------------------------------------------------------
    drop table if exists stg.FactInternetSalesRaw;

    create table stg.FactInternetSalesRaw
    (
          SalesOrderID             int
        , SalesOrderLineNumber     int
        , SalesOrderNumber         nvarchar(25)
        , CarrierTrackingNumber    nvarchar(25)
        , CustomerPONumber         nvarchar(25)
        , CustomerID               int
        , ProductID                int
        , ProductStandardCost      money
        , TotalProductCost         money
        , DiscountAmount           money
        , PromotionKey             int
        , CurrencyKey              int
        , OrderDate                date
        , DueDate                  date
        , ShipDate                 date
        , OrderQty                 int
        , UnitPrice                money
        , SalesAmount                money
        , ProductSubcategoryID     int
        , ProductCategoryID        int
        , GeographyKey             int
        , PostalCode               nvarchar(15)
    );

    -------------------------------------------------------------------------
    -- 2. Load staging table from OLTP + DW enrichment
    -------------------------------------------------------------------------
    insert into stg.FactInternetSalesRaw
    (
          SalesOrderID
        , SalesOrderLineNumber
        , SalesOrderNumber
        , CarrierTrackingNumber
        , CustomerPONumber
        , CustomerID
        , ProductID
        , ProductStandardCost
        , TotalProductCost
        , DiscountAmount
        , PromotionKey
        , CurrencyKey
        , OrderDate
        , DueDate
        , ShipDate
        , OrderQty
        , UnitPrice
        , SalesAmount
        , ProductSubcategoryID
        , ProductCategoryID
        , GeographyKey
        , PostalCode
    )
    select
          sod.SalesOrderID
        , sod.SalesOrderDetailID as SalesOrderLineNumber
        , soh.SalesOrderNumber
        , sod.CarrierTrackingNumber
        , soh.PurchaseOrderNumber as CustomerPONumber
        , soh.CustomerID
        , sod.ProductID
        , p.StandardCost as ProductStandardCost
        , sod.LineTotal as TotalProductCost
        , sod.UnitPriceDiscount as DiscountAmount
        , sod.SpecialOfferID as PromotionKey
        , soh.CurrencyRateID as CurrencyKey
        , soh.OrderDate
        , soh.DueDate
        , soh.ShipDate
        , sod.OrderQty
        , sod.UnitPrice
        , sod.LineTotal
        , dps.ProductSubcategoryKey
        , dpc.ProductCategoryKey
        , dg.GeographyKey
        , dg.PostalCode
from AdventureWorks2019.Sales.SalesOrderDetail                  sod
    join AdventureWorks2019.Sales.SalesOrderHeader              soh on soh.SalesOrderID          = sod.SalesOrderID
    join AdventureWorks2019.Sales.Customer                      c   on c.CustomerID              = soh.CustomerID
    join AdventureWorks2019.Production.Product                  p   on p.ProductID               = sod.ProductID
    left join AdventureWorksDW2019.dbo.DimProduct               dp  on dp.ProductAlternateKey    = p.ProductNumber
    left join AdventureWorksDW2019.dbo.DimProductSubcategory    dps on dps.ProductSubcategoryKey = dp.ProductSubcategoryKey
    left join AdventureWorksDW2019.dbo.DimProductCategory       dpc on dpc.ProductCategoryKey    = dps.ProductCategoryKey
    left join AdventureWorksDW2019.dbo.DimCustomer              dc  on dc.CustomerAlternateKey   = c.AccountNumber
    left join AdventureWorksDW2019.dbo.DimGeography             dg  on dg.GeographyKey           = dc.GeographyKey
;

    -------------------------------------------------------------------------
    -- 3. Rebuild hybrid fact table
    -------------------------------------------------------------------------
    drop table if exists ml.FactInternetSalesFixed;

    create table ml.FactInternetSalesFixed
    (
          FactSalesKey             int identity(1,1) primary key
        , SalesOrderID             int
        , SalesOrderLineNumber     int
        , SalesOrderNumber         nvarchar(25)
        , CarrierTrackingNumber    nvarchar(25)
        , CustomerPONumber         nvarchar(25)
        , CustomerKey              int
        , ProductKey                int
        , ProductStandardCost      money
        , TotalProductCost         money
        , DiscountAmount           money
        , PromotionKey             int
        , CurrencyKey              int
        , OrderDate                date
        , DueDate                  date
        , ShipDate                 date
        , OrderQty                 int
        , UnitPrice                money
        , SalesAmount              money
        , ProductSubcategoryKey     int
        , ProductCategoryKey        int
        , GeographyKey             int
        , PostalCode               nvarchar(15)
        , LoadDate                 datetime default getdate()
    );

    -------------------------------------------------------------------------
    -- 4. Load hybrid fact table from staging
    -------------------------------------------------------------------------
    insert into ml.FactInternetSalesFixed
    (
          SalesOrderID
        , SalesOrderLineNumber
        , SalesOrderNumber
        , CarrierTrackingNumber
        , CustomerPONumber
        , CustomerKey
        , ProductKey
        , ProductStandardCost
        , TotalProductCost
        , DiscountAmount
        , PromotionKey
        , CurrencyKey
        , OrderDate
        , DueDate
        , ShipDate
        , OrderQty
        , UnitPrice
        , SalesAmount
        , ProductSubcategoryKey
        , ProductCategoryKey
        , GeographyKey
        , PostalCode
    )
    select
          SalesOrderID
        , SalesOrderLineNumber
        , SalesOrderNumber
        , CarrierTrackingNumber
        , CustomerPONumber
        , CustomerID
        , ProductID
        , ProductStandardCost
        , TotalProductCost
        , DiscountAmount
        , PromotionKey
        , CurrencyKey
        , OrderDate
        , DueDate
        , ShipDate
        , OrderQty
        , UnitPrice
        , SalesAmount
        , ProductSubcategoryID
        , ProductCategoryID
        , GeographyKey
        , PostalCode
    from stg.FactInternetSalesRaw;

end;
go