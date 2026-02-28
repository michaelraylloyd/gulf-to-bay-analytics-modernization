with base as (
    select
          fis.SalesOrderNumber
        , fis.OrderDate
        , fis.CustomerKey
        , fis.ProductKey
        , fis.SalesAmount
        , fis.orderqty
        , fis.TotalProductCost

        -- Dimension attributes
        , dc.FirstName
        , dc.LastName
        , dg.Continent
        , dg.country
        , dg.stateprovince
        -- , dp.modelname
        , dpc.category
        , dps.subcategory
    from bronze.factinternetsales fis
    join bronze.dimcustomer dc on dc.CustomerKey = fis.CustomerKey
    join bronze.dimgeography dg on dg.GeographyKey = dc.GeographyKey
    -- left join bronze.dimproduct dp on dp.productkey = fis.p
    join bronze.dimproductsubcategory dps on dps.ProductSubcategoryKey = fis.ProductSubcategoryKey
    join bronze.dimproductcategory dpc on dpc.ProductCategoryKey = fis.ProductCategoryKey
    where 1=1
        -- and dg.Continent                   = v_continent
        -- and dg.CountryRegionCode           = v_country
        -- and dg.StateProvinceName           = v_state
        -- and dpc.EnglishProductCategoryName = v_product_cat
        -- and dps.EnglishProductSubcategoryName = v_product_subcat
        and fis.OrderDate between '1/1/2022' and '1/1/2026'
)

select
      date_trunc('month', OrderDate) as Month
    , category
    , subcategory
    , count(distinct SalesOrderNumber) as Orders
    , count(distinct CustomerKey)      as Customers
    , sum(SalesAmount)                 as TotalSales
    , sum(TotalProductCost)            as TotalCost
    -- , sum(SalesAmount) - sum(TotalProductCost) as GrossMargin
    , sum(SalesAmount) / nullif(count(distinct SalesOrderNumber),0) as AvgOrderValue
    , sum(orderqty)               as UnitsSold

    -- YoY Sales
    , sum(SalesAmount)
        / lag(sum(SalesAmount)) over (
            partition by subcategory
            order by date_trunc('month', OrderDate)
        ) - 1 as YoY_Sales_Growth

from base
group by
      date_trunc('month', OrderDate)
    , category
    , subcategory
order by Month;