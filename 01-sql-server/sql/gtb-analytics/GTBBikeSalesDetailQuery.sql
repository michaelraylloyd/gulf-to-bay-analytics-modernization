select
    soh.SalesOrderID
    , soh.OrderDate
    , c.CustomerID
    , p.ProductID
    , p.Name                as 'ProductName'
    , sod.OrderQty
    , sod.UnitPrice
    , sod.LineTotal
from
    Sales.SalesOrderHeader      soh
    join Sales.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
                                        and 1 = 1
                                        and 1 = 1
    join Production.Product     p   on sod.ProductID     = p.ProductID
    join Sales.Customer         c   on soh.CustomerID    = c.CustomerID
where
    soh.OrderDate >= '2013-01-01'
    and p.Name like '%Bike%'
order by
    soh.OrderDate
    , sod.LineTotal desc;