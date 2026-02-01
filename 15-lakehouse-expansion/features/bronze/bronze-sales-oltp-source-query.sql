-- GTB_BronzeSales_OLTPSource.sql
-- Source query for Bronze ingestion (OLTP → Lakehouse)

select
      sod.SalesOrderID              as 'order_id'
    , soh.CustomerID                as 'customer_id'
    , sod.ProductID                 as 'product_id'
    , sod.OrderQty                  as 'quantity'
    , sod.UnitPrice                 as 'unit_price'
    , soh.OrderDate                 as 'order_timestamp'
from Sales.SalesOrderDetail sod
join Sales.SalesOrderHeader soh on soh.SalesOrderID = sod.SalesOrderID