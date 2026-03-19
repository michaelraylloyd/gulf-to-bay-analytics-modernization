create or alter procedure ml.usp_BuildSilverLayer
as
begin
    set nocount on;

    -------------------------------------------------------------------------
    -- 1. create silver tables (typed, cleaned, relationally aligned)
    -------------------------------------------------------------------------

    if object_id('mlsilver.customer') is null
    begin
        create table mlsilver.customer
        (
              CustomerSK                    int identity(1,1) primary key
            , CS_Unique_ID                  varchar(100)
            , CS_Govt_ID                    varchar(100)
            , CS_Govt_ID_Type               varchar(50)
            , CS_Type                       varchar(50)
            , CS_First_Name                 varchar(100)
            , CS_Middle_Name                varchar(100)
            , CS_Last_Name                  varchar(100)
            , CS_Name_Suffix                varchar(50)
            , CS_Entity_Name                varchar(200)
            , CS_Street_Add_Ln1             varchar(200)
            , CS_Street_Add_Ln2             varchar(200)
            , CS_Street_Add_Ln3             varchar(200)
            , CS_City                       varchar(100)
            , CS_State                      varchar(50)
            , CS_ZIP                        varchar(20)
            , CS_Country                    varchar(100)
            , CS_Telephone                  varchar(50)
            , CS_Email                      varchar(200)
            , CS_Outstanding_Debt_Flag      bit
            , CS_Security_Pledge_Flag       bit
            , Account_Holder_Status         varchar(50)
            , Date_Of_Status_Change         date
            , Record_Complete_Data_Flag     bit
        );
    end;


    if object_id('mlsilver.account') is null
    begin
        create table mlsilver.account
        (
              AccountSK                 int identity(1,1) primary key
            , CS_Unique_ID              varchar(100)
            , CustomerSK                int null
            , DP_Acct_Identifier        varchar(100)
            , DP_Right_Capacity         varchar(100)
            , DP_Prod_Cat               varchar(100)
            , DP_Allocated_Amt          decimal(18,2)
            , DP_Acc_Int                decimal(18,2)
            , DP_Total_PI               decimal(18,2)
            , DP_Hold_Amount            decimal(18,2)
            , DP_Insured_Amount         decimal(18,2)
            , DP_Uninsured_Amount       decimal(18,2)
            , DP_Prepaid_Account_Flag   bit
            , DP_PT_Account_Flag        bit
            , DP_PT_Trans_Flag          bit
        );
    end;


    -------------------------------------------------------------------------
    -- 2. truncate + reseed silver tables
    -------------------------------------------------------------------------

    truncate table mlsilver.customer;
    dbcc checkident ('mlsilver.customer', reseed, 0);

    truncate table mlsilver.account;
    dbcc checkident ('mlsilver.account', reseed, 0);


    -------------------------------------------------------------------------
    -- 3. populate mlsilver.customer
    -------------------------------------------------------------------------

    insert into mlsilver.customer
    (
          CS_Unique_ID
        , CS_Govt_ID
        , CS_Govt_ID_Type
        , CS_Type
        , CS_First_Name
        , CS_Middle_Name
        , CS_Last_Name
        , CS_Name_Suffix
        , CS_Entity_Name
        , CS_Street_Add_Ln1
        , CS_Street_Add_Ln2
        , CS_Street_Add_Ln3
        , CS_City
        , CS_State
        , CS_ZIP
        , CS_Country
        , CS_Telephone
        , CS_Email
        , CS_Outstanding_Debt_Flag
        , CS_Security_Pledge_Flag
        , Account_Holder_Status
        , Date_Of_Status_Change
        , Record_Complete_Data_Flag
    )
    select
          ltrim(rtrim(CS_Unique_ID))
        , ltrim(rtrim(CS_Govt_ID))
        , upper(ltrim(rtrim(CS_Govt_ID_Type)))
        , upper(ltrim(rtrim(CS_Type)))
        , ltrim(rtrim(CS_First_Name))
        , ltrim(rtrim(CS_Middle_Name))
        , ltrim(rtrim(CS_Last_Name))
        , ltrim(rtrim(CS_Name_Suffix))
        , ltrim(rtrim(CS_Entity_Name))
        , ltrim(rtrim(CS_Street_Add_Ln1))
        , ltrim(rtrim(CS_Street_Add_Ln2))
        , ltrim(rtrim(CS_Street_Add_Ln3))
        , ltrim(rtrim(CS_City))
        , upper(ltrim(rtrim(CS_State)))
        , ltrim(rtrim(CS_ZIP))
        , upper(ltrim(rtrim(CS_Country)))
        , ltrim(rtrim(CS_Telephone))
        , lower(ltrim(rtrim(CS_Email)))
        , case when CS_Outstanding_Debt_Flag = 'Y' then 1 else 0 end
        , case when CS_Security_Pledge_Flag  = 'Y' then 1 else 0 end
        , ltrim(rtrim(Account_Holder_Status))
        , try_convert(date, Date_Of_Status_Change)
        , case when Record_Complete_Data_Flag = 'Y' then 1 else 0 end
    from mlbronze.customer;


    -------------------------------------------------------------------------
    -- 4. populate mlsilver.account
    -------------------------------------------------------------------------

    insert into mlsilver.account
    (
          CS_Unique_ID
        , CustomerSK
        , DP_Acct_Identifier
        , DP_Right_Capacity
        , DP_Prod_Cat
        , DP_Allocated_Amt
        , DP_Acc_Int
        , DP_Total_PI
        , DP_Hold_Amount
        , DP_Insured_Amount
        , DP_Uninsured_Amount
        , DP_Prepaid_Account_Flag
        , DP_PT_Account_Flag
        , DP_PT_Trans_Flag
    )
    select
          a.CS_Unique_ID
        , c.CustomerSK
        , ltrim(rtrim(a.DP_Acct_Identifier))
        , upper(ltrim(rtrim(a.DP_Right_Capacity)))
        , upper(ltrim(rtrim(a.DP_Prod_Cat)))
        , try_convert(decimal(18,2), a.DP_Allocated_Amt)
        , try_convert(decimal(18,2), a.DP_Acc_Int)
        , try_convert(decimal(18,2), a.DP_Total_PI)
        , try_convert(decimal(18,2), a.DP_Hold_Amount)
        , try_convert(decimal(18,2), a.DP_Insured_Amount)
        , try_convert(decimal(18,2), a.DP_Uninsured_Amount)
        , case when a.DP_Prepaid_Account_Flag = 'Y' then 1 else 0 end
        , case when a.DP_PT_Account_Flag     = 'Y' then 1 else 0 end
        , case when a.DP_PT_Trans_Flag       = 'Y' then 1 else 0 end
    from mlbronze.account a
    left join mlsilver.customer c on c.CS_Unique_ID = a.CS_Unique_ID;


    -------------------------------------------------------------------------
    -- 5. validation (comment out later)
    -------------------------------------------------------------------------

    print 'row counts (silver):';

    select 'mlsilver.customer' as table_name, count(*) as row_count
    from mlsilver.customer;

    select 'mlsilver.account' as table_name, count(*) as row_count
    from mlsilver.account;

    print 'orphan accounts (should be zero):';

    select *
    from mlsilver.account
    where CustomerSK is null;

end;
go

--exec ml.usp_BuildSilverLayer

go

exec ml.usp_BuildSilverLayer