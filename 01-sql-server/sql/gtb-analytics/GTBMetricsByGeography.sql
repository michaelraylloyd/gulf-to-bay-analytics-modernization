--SQL Query
use AdventureWorksDW2019
go

--Declare filter variables
declare
	@OrderDate varchar(4) = '2014'
	, @SalesAmount int = 0

--Main Query
select
    case
        when dg.EnglishCountryRegionName = 'Australia'      then 'Australia'
        when dg.EnglishCountryRegionName = 'Canada'         then 'North America'
        when dg.EnglishCountryRegionName = 'France'         then 'Europe'
        when dg.EnglishCountryRegionName = 'Germany'        then 'Europe'
        when dg.EnglishCountryRegionName = 'United Kingdom' then 'Europe'
        when dg.EnglishCountryRegionName = 'United States'  then 'North America'
        else 'N/A'
    end as 'Continent'
    , dg.EnglishCountryRegionName           as 'Country'
    , dg.StateProvinceName                  as 'State Province'
    , dg.City								as 'City'
    , count(distinct dc.CustomerKey)		as 'Total Customers'
	, sum(fs.OrderQuantity)					as 'Total Orders'
	, format(sum(fs.SalesAmount), 'c')		as 'Total Sales'
from
    dbo.FactInternetSales fs
    inner join dbo.DimCustomer dc               on dc.CustomerKey = fs.CustomerKey
    inner join dbo.DimGeography dg              on dg.GeographyKey = dc.GeographyKey
    inner join dbo.DimProduct dp                on dp.ProductKey = fs.ProductKey
    inner join dbo.DimProductSubcategory dpsc   on dpsc.ProductSubcategoryKey = dp.ProductSubcategoryKey
    inner join dbo.DimProductCategory dpc       on dpc.ProductCategoryKey = dpsc.ProductCategoryKey
    inner join dbo.DimDate dd                   on dd.DateKey = fs.OrderDateKey
where
    fs.OrderDate < @OrderDate
	and fs.SalesAmount > @SalesAmount
group by
	case
        when dg.EnglishCountryRegionName = 'Australia'      then 'Australia'
        when dg.EnglishCountryRegionName = 'Canada'         then 'North America'
        when dg.EnglishCountryRegionName = 'France'         then 'Europe'
        when dg.EnglishCountryRegionName = 'Germany'        then 'Europe'
        when dg.EnglishCountryRegionName = 'United Kingdom' then 'Europe'
        when dg.EnglishCountryRegionName = 'United States'  then 'North America'
        else 'N/A'
    end
    , dg.EnglishCountryRegionName
    , dg.StateProvinceName
    , dg.City
order by
	[Continent]
    , [Country]
    , [State Province]
    , [City]