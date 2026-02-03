--FactInternetSales table definition in tabular model. I'm only pulling in the fields I need.

select
    fis.CarrierTrackingNumber
    , fis.CustomerKey
    , fis.CurrencyKey
    , fis.CustomerPONumber
    , fis.DiscountAmount
    , CAST(DATEPART(YEAR, DATEADD(year, 12, fis.OrderDate)) AS varchar(4))
        + ' - Q'
        + CAST(DATEPART(QUARTER, DATEADD(year, 12, fis.OrderDate)) AS varchar(1)) AS 'OrderYearQuarter'
    , dateadd(year, 12, fis.OrderDate) as OrderDate
    , fis.OrderDateKey
    , fis.OrderQuantity
    , fis.ProductKey
    , fis.ProductStandardCost
    , fis.PromotionKey
    , fis.SalesAmount
    , fis.SalesOrderLineNumber
    , fis.SalesOrderNumber
    , fis.TotalProductCost
    , dateadd(year, 12, fis.ShipDate)  as 'ShipDate' --ML Note:  Bring ShipDate up to current times, since this it is 2026 at the time this was written.
    , dateadd(year, 12, fis.DueDate) as 'DueDate' --ML Note:  Bring DueDate up to current times, since this it is 2026 at the time this was written.

    -- Enrichment fields
    , MissingKeyID               
    , SalesOrderID               
    , ProductID                  
    , ProductSubcategoryKey      
    , ProductCategoryKey         
    , GeographyKey               

from
    ml.FactInternetSalesFixed fis
where
    year(fis.OrderDate) >= '2011'
    and year(fis.OrderDate) < '2014'