create or alter procedure ml.usp_BuildGoldLayer
as
begin
    set nocount on;

    -------------------------------------------------------------------------
    -- 1. create gold dimensions
    -------------------------------------------------------------------------

    if object_id('mlgold.dimCustomer') is null
    begin
        create table mlgold.dimCustomer
        (
              CustomerSK                int primary key      -- not identity
            , CS_Unique_ID              varchar(100)
            , CS_Type                   varchar(50)
            , CS_First_Name             varchar(100)
            , CS_Last_Name              varchar(100)
            , CS_Entity_Name            varchar(200)
            , CS_State                  varchar(50)
            , CS_ZIP                    varchar(20)
        );
    end;


    if object_id('mlgold.dimRightCapacity') is null
    begin
        create table mlgold.dimRightCapacity
        (
              RightCapacitySK           int identity(1,1) primary key
            , DP_Right_Capacity         varchar(100)
        );
    end;


    if object_id('mlgold.dimProductCategory') is null
    begin
        create table mlgold.dimProductCategory
        (
              ProdCatSK                 int identity(1,1) primary key
            , DP_Prod_Cat               varchar(100)
        );
    end;


    if object_id('mlgold.dimDate') is null
    begin
        create table mlgold.dimDate
        (
              DateSK                    int primary key      -- not identity
            , FullDate                  date
            , YearNum                   int
            , MonthNum                  int
            , DayNum                    int
            , MonthName                 varchar(20)
        );
    end;


    -------------------------------------------------------------------------
    -- 2. create factAccount
    -------------------------------------------------------------------------

    if object_id('mlgold.factAccount') is null
    begin
        create table mlgold.factAccount
        (
              AccountSK                 int primary key      -- not identity
            , CustomerSK                int
            , RightCapacitySK           int
            , ProdCatSK                 int
            , DP_Total_PI               decimal(18,2)
            , DP_Allocated_Amt          decimal(18,2)
            , DP_Acc_Int                decimal(18,2)
            , DP_Hold_Amount            decimal(18,2)
            , DP_Insured_Amount         decimal(18,2)
            , DP_Uninsured_Amount       decimal(18,2)
        );
    end;


    -------------------------------------------------------------------------
    -- 3. truncate gold tables
    -------------------------------------------------------------------------

    truncate table mlgold.dimCustomer;

    truncate table mlgold.dimRightCapacity;
    dbcc checkident ('mlgold.dimRightCapacity', reseed, 0);

    truncate table mlgold.dimProductCategory;
    dbcc checkident ('mlgold.dimProductCategory', reseed, 0);

    truncate table mlgold.dimDate;

    truncate table mlgold.factAccount;
    -- no reseed: AccountSK is not identity


    -------------------------------------------------------------------------
    -- 4. populate dimCustomer
    -------------------------------------------------------------------------

    insert into mlgold.dimCustomer
    (
          CustomerSK
        , CS_Unique_ID
        , CS_Type
        , CS_First_Name
        , CS_Last_Name
        , CS_Entity_Name
        , CS_State
        , CS_ZIP
    )
    select
          CustomerSK
        , CS_Unique_ID
        , CS_Type
        , CS_First_Name
        , CS_Last_Name
        , CS_Entity_Name
        , CS_State
        , CS_ZIP
    from mlsilver.customer;


    -------------------------------------------------------------------------
    -- 5. populate dimRightCapacity
    -------------------------------------------------------------------------

    insert into mlgold.dimRightCapacity
    (
          DP_Right_Capacity
    )
    select distinct
          DP_Right_Capacity
    from mlsilver.account
    where DP_Right_Capacity is not null;


    -------------------------------------------------------------------------
    -- 6. populate dimProductCategory
    -------------------------------------------------------------------------

    insert into mlgold.dimProductCategory
    (
          DP_Prod_Cat
    )
    select distinct
          DP_Prod_Cat
    from mlsilver.account
    where DP_Prod_Cat is not null;


    -------------------------------------------------------------------------
    -- 7. populate dimDate
    -------------------------------------------------------------------------

    ;with d as
    (
        select cast('2020-01-01' as date) as dt
        union all
        select dateadd(day, 1, dt)
        from d
        where dt < '2030-12-31'
    )
    insert into mlgold.dimDate
    (
          DateSK
        , FullDate
        , YearNum
        , MonthNum
        , DayNum
        , MonthName
    )
    select
          convert(int, format(dt, 'yyyyMMdd'))
        , dt
        , year(dt)
        , month(dt)
        , day(dt)
        , datename(month, dt)
    from d
    option (maxrecursion 0);


    -------------------------------------------------------------------------
    -- 8. populate factAccount
    -------------------------------------------------------------------------

    insert into mlgold.factAccount
    (
          AccountSK
        , CustomerSK
        , RightCapacitySK
        , ProdCatSK
        , DP_Total_PI
        , DP_Allocated_Amt
        , DP_Acc_Int
        , DP_Hold_Amount
        , DP_Insured_Amount
        , DP_Uninsured_Amount
    )
    select
          a.AccountSK
        , a.CustomerSK
        , rc.RightCapacitySK
        , pc.ProdCatSK
        , a.DP_Total_PI
        , a.DP_Allocated_Amt
        , a.DP_Acc_Int
        , a.DP_Hold_Amount
        , a.DP_Insured_Amount
        , a.DP_Uninsured_Amount
    from mlsilver.account a
    left join mlgold.dimRightCapacity rc on rc.DP_Right_Capacity = a.DP_Right_Capacity
    left join mlgold.dimProductCategory pc on pc.DP_Prod_Cat = a.DP_Prod_Cat;


    -------------------------------------------------------------------------
    -- 9. validation (comment out later)
    -------------------------------------------------------------------------

    --print 'row counts (gold):';

    --select 'mlgold.dimCustomer'        as table_name, count(*) as row_count from mlgold.dimCustomer;
    --select 'mlgold.dimRightCapacity'   as table_name, count(*) as row_count from mlgold.dimRightCapacity;
    --select 'mlgold.dimProductCategory' as table_name, count(*) as row_count from mlgold.dimProductCategory;
    --select 'mlgold.dimDate'            as table_name, count(*) as row_count from mlgold.dimDate;
    --select 'mlgold.factAccount'        as table_name, count(*) as row_count from mlgold.factAccount;

end;

--exec ml.usp_BuildGoldLayer

go

--exec ml.usp_BuildGoldLayer