select
      count(*) as missing_customers
from  silver_sales          s
left  join dim_customers    c on c.customer_id = s.customer_id
where c.customer_id is null