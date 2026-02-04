/*==============================================================
    FULL REBUILD — ML.FactInternetSalesFixed
    -------------------------------------------------------------
    Steps:
      1. Drop table if it exists
      2. Recreate table with correct schema + PK
      3. Reload enriched fact data
      4. Rebuild indexing strategy
==============================================================*/

---------------------------------------------------------------
-- 1. DROP TABLE IF EXISTS
---------------------------------------------------------------
if object_id('ML.FactInternetSalesFixed', 'U') is not null
    drop table ML.FactInternetSalesFixed;


---------------------------------------------------------------
-- 2. RECREATE TABLE (Schema matches dbo.FactInternetSales EXACTLY)
--    + enrichment fields + surrogate PK
---------------------------------------------------------------
create table ML.FactInternetSalesFixed (
      FactSalesFixedKey           int             not null identity(1,1)

    , ProductKey                  int             not null
    , OrderDateKey                int             not null
    , DueDateKey                  int             not null
    , ShipDateKey                 int             not null
    , CustomerKey                 int             not null
    , PromotionKey                int             not null
    , CurrencyKey                 int             not null
    , SalesTerritoryKey           int             not null
    , SalesOrderNumber            nvarchar(40)    not null
    , SalesOrderLineNumber        tinyint         not null
    , RevisionNumber              tinyint         not null
    , OrderQuantity               smallint        not null
    , UnitPrice                   money           not null
    , ExtendedAmount              money           not null
    , UnitPriceDiscountPct        float           not null
    , DiscountAmount              float           not null
    , ProductStandardCost         money           not null
    , TotalProductCost            money           not null
    , SalesAmount                 money           not null
    , TaxAmt                      money           not null
    , Freight                     money           not null
    , CarrierTrackingNumber       nvarchar(50)    null
    , CustomerPONumber            nvarchar(50)    null
    , OrderDate                   datetime        null
    , DueDate                     datetime        null
    , ShipDate                    datetime        null

    -- Enrichment fields
    , MissingKeyID                int             null
    , SalesOrderID                int             null
    , ProductID                   int             null
    , ProductSubcategoryKey       int             null
    , ProductCategoryKey          int             null
    , GeographyKey                int             null

    , LoadDate                    datetime        not null
);


---------------------------------------------------------------
-- 3. RELOAD ENRICHED FACT DATA
---------------------------------------------------------------
insert into ML.FactInternetSalesFixed (
      ProductKey
    , OrderDateKey
    , DueDateKey
    , ShipDateKey
    , CustomerKey
    , PromotionKey
    , CurrencyKey
    , SalesTerritoryKey
    , SalesOrderNumber
    , SalesOrderLineNumber
    , RevisionNumber
    , OrderQuantity
    , UnitPrice
    , ExtendedAmount
    , UnitPriceDiscountPct
    , DiscountAmount
    , ProductStandardCost
    , TotalProductCost
    , SalesAmount
    , TaxAmt
    , Freight
    , CarrierTrackingNumber
    , CustomerPONumber
    , OrderDate
    , DueDate
    , ShipDate

    , MissingKeyID
    , SalesOrderID
    , ProductID
    , ProductSubcategoryKey
    , ProductCategoryKey
    , GeographyKey

    , LoadDate
)
select
      fis.ProductKey
    , fis.OrderDateKey
    , fis.DueDateKey
    , fis.ShipDateKey
    , fis.CustomerKey
    , fis.PromotionKey
    , fis.CurrencyKey
    , fis.SalesTerritoryKey
    , fis.SalesOrderNumber
    , fis.SalesOrderLineNumber
    , fis.RevisionNumber
    , fis.OrderQuantity
    , fis.UnitPrice
    , fis.ExtendedAmount
    , fis.UnitPriceDiscountPct
    , fis.DiscountAmount
    , fis.ProductStandardCost
    , fis.TotalProductCost
    , fis.SalesAmount
    , fis.TaxAmt
    , fis.Freight
    , fis.CarrierTrackingNumber
    , fis.CustomerPONumber
    , fis.OrderDate
    , fis.DueDate
    , fis.ShipDate

    , mk.MissingKeyID
    , mk.SalesOrderID
    , mk.ProductID
    , p.ProductSubcategoryKey
    , ps.ProductCategoryKey
    , g.GeographyKey

    , getdate()
from dbo.FactInternetSales              fis
left join ML.MissingKeys                mk
    on fis.SalesOrderNumber = mk.SalesOrderNumber
left join dbo.DimProduct                p
    on fis.ProductKey = p.ProductKey
left join dbo.DimProductSubcategory     ps
    on p.ProductSubcategoryKey = ps.ProductSubcategoryKey
left join dbo.DimCustomer               c
    on fis.CustomerKey = c.CustomerKey
left join dbo.DimGeography              g
    on c.GeographyKey = g.GeographyKey;


---------------------------------------------------------------
-- 4. REBUILD INDEXING STRATEGY
---------------------------------------------------------------

-- Primary Key (nonclustered)
alter table ML.FactInternetSalesFixed
add constraint PK_FactInternetSalesFixed
primary key nonclustered (FactSalesFixedKey);

-- Clustered index on natural business key
create unique clustered index CIX_FactInternetSalesFixed_SON_SOLN
on ML.FactInternetSalesFixed (
      SalesOrderNumber
    , SalesOrderLineNumber
);

-- Dimension join indexes
create nonclustered index NCI_FactInternetSalesFixed_ProductKey
on ML.FactInternetSalesFixed (ProductKey);

create nonclustered index NCI_FactInternetSalesFixed_CustomerKey
on ML.FactInternetSalesFixed (CustomerKey);

create nonclustered index NCI_FactInternetSalesFixed_SalesTerritoryKey
on ML.FactInternetSalesFixed (SalesTerritoryKey);

-- Optional date-key indexes
create nonclustered index NCI_FactInternetSalesFixed_OrderDateKey
on ML.FactInternetSalesFixed (OrderDateKey);

create nonclustered index NCI_FactInternetSalesFixed_DueDateKey
on ML.FactInternetSalesFixed (DueDateKey);

create nonclustered index NCI_FactInternetSalesFixed_ShipDateKey
on ML.FactInternetSalesFixed (ShipDateKey);

-- Optional enrichment index
create nonclustered index NCI_FactInternetSalesFixed_MissingKeyID
on ML.FactInternetSalesFixed (MissingKeyID);
