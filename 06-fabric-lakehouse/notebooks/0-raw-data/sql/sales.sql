select
    soh.SalesOrderID        as 'order_id'
  , soh.OrderDate           as 'order_date'
  , soh.CustomerID          as 'customer_id'
  , sod.ProductID           as 'product_id'
  , sod.OrderQty            as 'quantity'
  , sod.UnitPrice           as 'unit_price'
  , sod.UnitPriceDiscount   as 'discount'
  , sod.LineTotal           as 'line_total'
from Sales.SalesOrderHeader soh
join Sales.SalesOrderDetail sod
  on sod.SalesOrderID = soh.SalesOrderID
order by
    soh.SalesOrderID
  , sod.SalesOrderDetailID;