[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared DimCustomer = let
  Source = Sql.Database("gtb-sqlserver.database.windows.net", "AdventureWorksCloudDW", [Query = "--DimCustomer table definition in tabular model. I'm only pulling in the fields I need.#(lf)#(lf)select#(lf)#(tab)dc.CustomerKey#(lf)#(tab), dc.GeographyKey --ML Note:  1/18/2022 we'll add this to the fact table later.#(lf)#(tab), dc.CustomerAlternateKey#(lf)#(tab), dc.FirstName#(lf)#(tab), dc.MiddleName#(lf)#(tab), dc.LastName#(lf)#(tab), CONCAT(dc.LastName, ', ', dc.FirstName) as 'FullName'#(lf)#(tab), dc.Gender#(lf)from#(lf)dbo.DimCustomer dc"])
in
  Source;
shared DimDate = let
  Source = Sql.Database("gtb-sqlserver.database.windows.net", "AdventureWorksCloudDW", [Query = "--DimDate table definition in tabular model. I'm only pulling in the fields I need.#(lf)#(lf)select#(lf)#(tab)dd.DateKey#(lf)#(tab), dateadd(year, 12, cast(dd.FullDateAlternateKey as date)) as 'Date' --ML Note:  Bring Date up to current times, since this it is 2026 at the time this was written.#(lf)#(tab), dd.CalendarYear#(lf)#(tab), dd.CalendarQuarter#(lf)#(tab), dd.EnglishMonthName#(tab)#(tab)#(tab)#(tab)#(tab)as 'Month'#(lf)from dbo.DimDate dd#(lf)where dd.FullDateAlternateKey between '2011' and '2014'"])
in
  Source;
shared DimGeography = let
  Source = Sql.Database("gtb-sqlserver.database.windows.net", "AdventureWorksCloudDW", [Query = "--DimGeography table definition in tabular model. I'm only pulling in the fields I need.#(lf)#(lf)select#(lf)#(tab)dg.GeographyKey#(lf)#(tab), case#(lf)#(tab)#(tab)when dg.EnglishCountryRegionName = 'Australia'#(tab)#(tab)then 'Australia'#(lf)#(tab)#(tab)when dg.EnglishCountryRegionName = 'Canada'#(tab)#(tab)#(tab)then 'North America'#(lf)#(tab)#(tab)when dg.EnglishCountryRegionName = 'France'#(tab)#(tab)#(tab)then 'Europe'#(lf)#(tab)#(tab)when dg.EnglishCountryRegionName = 'Germany'#(tab)#(tab)then 'Europe'#(lf)#(tab)#(tab)when dg.EnglishCountryRegionName = 'United Kingdom'#(tab)then 'Europe'#(lf)#(tab)#(tab)when dg.EnglishCountryRegionName = 'United States'#(tab)then 'North America'#(lf)#(tab)#(tab)else null#(lf)#(tab)end#(tab)#(tab)#(tab)#(tab)#(tab)#(tab)#(tab)#(tab)as 'Continent'#(lf)#(tab), dg.EnglishCountryRegionName#(tab)as 'Country'#(lf)#(tab), dg.StateProvinceName#(tab)#(tab)#(tab)as 'State Province'#(lf)#(tab), dg.City#(lf)from dbo.DimGeography dg#(lf)"])
in
  Source;
shared DimProductCategory = let
  Source = Sql.Database("gtb-sqlserver.database.windows.net", "AdventureWorksCloudDW", [Query = "--DimProductCategory table definition in tabular model. I'm only pulling in the fields I need.#(lf)#(lf)select#(lf)#(tab)dpc.ProductCategoryKey#(lf)#(tab), dpc.EnglishProductCategoryName as 'Category'#(lf)from dbo.DimProductCategory dpc"])
in
  Source;
shared DimProductSubCategory = let
  Source = Sql.Database("gtb-sqlserver.database.windows.net", "AdventureWorksCloudDW", [Query = "--DimProductSubCategory table definition in tabular model. I'm only pulling in the fields I need.#(lf)#(lf)select#(lf)#(tab)dpsc.ProductCategoryKey --ML Note:  1/18/2022 we'll add this to the fact table later.#(lf)#(tab), dpsc.ProductSubcategoryKey#(lf)#(tab), dpsc.EnglishProductSubcategoryName as 'Subcategory'#(lf)from dbo.DimProductSubcategory dpsc#(lf)"])
in
  Source;
shared DimProduct = let
  Source = Sql.Database("gtb-sqlserver.database.windows.net", "AdventureWorksCloudDW", [Query = "--DimProduct table definition in tabular model. I'm only pulling in the fields I need.#(lf)#(lf)select#(lf)#(tab)dp.ProductKey#(lf)#(tab), dp.ProductSubcategoryKey --ML Note:  1/18/2022 we'll add this to the fact table later.#(lf)#(tab), dp.Class#(lf)#(tab), dp.Style#(lf)#(tab), dp.ModelName#(lf)#(tab), dp.Color#(lf)#(tab), dp.Size#(lf)#(tab), dp.ProductLine#(lf)#(tab), case#(lf)#(tab)#(tab)when dp.ProductLine = 'M' then 'Mountain'#(lf)#(tab)#(tab)when dp.ProductLine = 'R' then 'Road'#(lf)#(tab)#(tab)when dp.ProductLine = 'S' then 'Sport'#(lf)#(tab)#(tab)when dp.ProductLine = 'T' then 'Touring'#(lf)#(tab)#(tab)else 'Not Applicable'#(lf)#(tab)end#(tab)#(tab)#(tab)#(tab)#(tab)#(tab)#(tab)#(tab)#(tab)#(tab)#(tab)#(tab)as 'ProductLineLabel'#(lf)#(tab), dp.StandardCost#(lf)#(tab), dp.ListPrice#(lf)#(tab), dp.Weight#(lf)#(tab), dp.Status#(lf)from dbo.DimProduct dp#(lf)"])
in
  Source;
shared FactInternetSales = let
  Source = Sql.Database("gtb-sqlserver.database.windows.net", "AdventureWorksCloudDW", [Query = "--FactInternetSales table definition in tabular model. I'm only pulling in the fields I need.#(lf)#(lf)select#(lf)    fis.CarrierTrackingNumber#(lf)    , fis.CustomerKey#(lf)    , fis.CurrencyKey#(lf)    , fis.CustomerPONumber#(lf)    , fis.DiscountAmount#(lf)    , CAST(DATEPART(YEAR, DATEADD(year, 12, fis.OrderDate)) AS varchar(4))#(lf)        + ' - Q'#(lf)        + CAST(DATEPART(QUARTER, DATEADD(year, 12, fis.OrderDate)) AS varchar(1)) AS 'OrderYearQuarter'#(lf)    , dateadd(year, 12, fis.OrderDate) as OrderDate#(lf)    , fis.OrderDateKey#(lf)    , fis.OrderQuantity#(lf)    , fis.ProductKey#(lf)    , fis.ProductStandardCost#(lf)    , fis.PromotionKey#(lf)    , fis.SalesAmount#(lf)    , fis.SalesOrderLineNumber#(lf)    , fis.SalesOrderNumber#(lf)    , fis.TotalProductCost#(lf)    , dateadd(year, 12, fis.ShipDate)  as 'ShipDate' --ML Note:  Bring ShipDate up to current times, since this it is 2026 at the time this was written.#(lf)    , dateadd(year, 12, fis.DueDate) as 'DueDate' --ML Note:  Bring DueDate up to current times, since this it is 2026 at the time this was written.#(lf)#(lf)    -- Enrichment fields#(lf)    , MissingKeyID               #(lf)    , SalesOrderID               #(lf)    , ProductID                  #(lf)    , ProductSubcategoryKey      #(lf)    , ProductCategoryKey         #(lf)    , GeographyKey               #(lf)#(lf)from#(lf)    ml.FactInternetSalesFixed fis#(lf)where#(lf)    year(fis.OrderDate) >= '2011'#(lf)    and year(fis.OrderDate) < '2014'"])
in
  Source;
