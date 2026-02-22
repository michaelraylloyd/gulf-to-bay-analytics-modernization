select
      count(*) as missing_products
from  silver_sales         s
left  join dim_products    p on p.product_id = s.product_id
where p.product_id is null