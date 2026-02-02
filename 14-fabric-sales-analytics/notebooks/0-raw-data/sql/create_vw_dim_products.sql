CREATE OR ALTER VIEW [dbo].[vw_dim_product] AS (SELECT
      product_sk         AS product_key
    , product_id         AS product_id
    , product_name       AS product_name
    , product_number     AS product_number
    , color              AS color
    , standard_cost      AS standard_cost
    , list_price         AS list_price
    , size               AS size
    , weight             AS weight
    , category           AS category
    , subcategory        AS subcategory
FROM dim_product)