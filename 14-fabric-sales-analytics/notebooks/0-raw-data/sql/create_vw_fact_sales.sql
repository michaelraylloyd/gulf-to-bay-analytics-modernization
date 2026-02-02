CREATE OR ALTER VIEW [dbo].[vw_fact_sales] AS (SELECT
      f.sales_sk         AS sales_key
    , f.order_id         AS order_id
    , f.order_date       AS order_date
    , f.customer_sk      AS customer_key
    , f.product_sk       AS product_key
    , f.quantity         AS quantity
    , f.unit_price       AS unit_price
    , f.discount         AS discount
    , f.line_total       AS line_total
FROM fact_sales f)