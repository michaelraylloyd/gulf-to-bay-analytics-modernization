

    -------------------------------------------------------------------------
    -- 1. create or replace semantic views for Power BI
    --    these views provide a clean, business-friendly layer on top of gold
    -------------------------------------------------------------------------


    -------------------------------------------------------------------------
    -- vw_dimCustomer
    -------------------------------------------------------------------------
    create or alter view mlgold.vw_dimCustomer
    as
    select
      c.CustomerSK              as CustomerSK
    , c.CS_Unique_ID            as CustomerID
    , c.CS_Type                 as CustomerType
    , c.CS_First_Name           as FirstName
    , c.CS_Last_Name            as LastName
    , c.CS_Entity_Name          as EntityName
    , c.CS_State                as State
    , c.CS_ZIP                  as ZIP
    , case
      when CS_Entity_Name is not null and CS_Entity_Name <> ''
          then CS_Entity_Name
      when CS_Last_Name is not null and CS_Last_Name <> ''
           and CS_First_Name is not null and CS_First_Name <> ''
          then CS_Last_Name + ', ' + CS_First_Name
      when CS_Last_Name is not null and CS_Last_Name <> ''
          then CS_Last_Name
      when CS_First_Name is not null and CS_First_Name <> ''
          then CS_First_Name
      else null
  end                           as _CustomerDisplayName
from mlgold.dimCustomer c;
    go


    -------------------------------------------------------------------------
    -- vw_dimRightCapacity
    -------------------------------------------------------------------------
    create or alter view mlgold.vw_dimRightCapacity
    as
    select
          rc.RightCapacitySK        as RightCapacitySK
        , rc.DP_Right_Capacity      as RightCapacity
    from mlgold.dimRightCapacity rc;
    go


    -------------------------------------------------------------------------
    -- vw_dimProductCategory
    -------------------------------------------------------------------------
    create or alter view mlgold.vw_dimProductCategory
    as
    select
          pc.ProdCatSK              as ProductCategorySK
        , pc.DP_Prod_Cat            as ProductCategory
    from mlgold.dimProductCategory pc;
    go


    -------------------------------------------------------------------------
    -- vw_factAccount
    -- this is the primary fact view for Power BI
    -- includes optional computed insured/uninsured logic
    -------------------------------------------------------------------------
    create or alter view mlgold.vw_factAccount
    as
    select
          fa.AccountSK                  as AccountSK
        , fa.CustomerSK                 as CustomerSK
        , fa.RightCapacitySK            as RightCapacitySK
        , fa.ProdCatSK                  as ProductCategorySK

        -- business fields
        , fa.DP_Total_PI                as TotalBalance
        , fa.DP_Allocated_Amt           as AllocatedAmount
        , fa.DP_Acc_Int                 as AccruedInterest
        , fa.DP_Hold_Amount             as HoldAmount
        , fa.DP_Insured_Amount          as InsuredAmount
        , fa.DP_Uninsured_Amount        as UninsuredAmount

        -- optional computed logic for FDIC Part 370
        , case
              when fa.DP_Total_PI <= 250000 then fa.DP_Total_PI
              else 250000
          end                            as ComputedInsured

        , case
              when fa.DP_Total_PI <= 250000 then 0
              else fa.DP_Total_PI - 250000
          end                            as ComputedUninsured

    from mlgold.factAccount fa;
    go

--exec ml.usp_InitGoldViews