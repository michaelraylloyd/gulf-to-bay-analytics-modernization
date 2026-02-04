select
    p.ProductID          as 'product_id'
  , p.Name               as 'product_name'
  , p.ProductNumber      as 'product_number'
  , p.Color              as 'color'
  , p.StandardCost       as 'standard_cost'
  , p.ListPrice          as 'list_price'
  , p.Size               as 'size'
  , p.Weight             as 'weight'
  , pc.Name              as 'category'
  , ps.Name              as 'subcategory'
from Production.Product p
left join Production.ProductSubcategory ps
  on ps.ProductSubcategoryID = p.ProductSubcategoryID
left join Production.ProductCategory pc
  on pc.ProductCategoryID = ps.ProductCategoryID
order by
    p.ProductID;