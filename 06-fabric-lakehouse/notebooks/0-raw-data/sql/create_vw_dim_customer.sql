CREATE OR ALTER VIEW [dbo].[vw_dim_customer] AS (SELECT
      customer_sk        AS customer_key
    , customer_id        AS customer_id
    , first_name         AS first_name
    , last_name          AS last_name
    , address1           AS address_line_1
    , address2           AS address_line_2
    , city               AS city
    , state_province     AS state_province
    , country            AS country
    , postal_code        AS postal_code
FROM dim_customer)