CREATE OR ALTER VIEW vw_sales_model AS
SELECT
      f.sales_key
    , f.order_id
    , f.order_date
    , c.customer_key
    , c.first_name
    , c.last_name
    , c.city
    , c.state_province
    , p.product_key
    , p.product_name
    , p.category
    , p.subcategory
    , f.quantity
    , f.unit_price
    , f.discount
    , f.line_total
FROM vw_fact_sales f
JOIN vw_dim_customer c ON f.customer_key = c.customer_key
JOIN vw_dim_product  p ON f.product_key  = p.product_key;
