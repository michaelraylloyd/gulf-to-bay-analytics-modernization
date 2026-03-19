create or alter procedure ml.usp_InitBronzeIngestion
as
begin
    set nocount on;

    -------------------------------------------------------------------------
    -- 1. create schemas if they don't exist
    -------------------------------------------------------------------------
    if not exists (select 1 from sys.schemas where name = 'mlbronze')
        exec ('create schema mlbronze');

    if not exists (select 1 from sys.schemas where name = 'mlsilver')
        exec ('create schema mlsilver');

    if not exists (select 1 from sys.schemas where name = 'mlgold')
        exec ('create schema mlgold');


    -------------------------------------------------------------------------
    -- 2. create bronze tables (raw landing tables)
    --    all varchar to preserve raw data
    -------------------------------------------------------------------------

    if object_id('mlbronze.account') is null
    begin
        create table mlbronze.account
        (
              CS_Unique_ID                varchar(100)
            , DP_Acct_Identifier          varchar(100)
            , DP_Right_Capacity           varchar(100)
            , DP_Prod_Cat                 varchar(100)
            , DP_Allocated_Amt            varchar(100)
            , DP_Acc_Int                  varchar(100)
            , DP_Total_PI                 varchar(100)
            , DP_Hold_Amount              varchar(100)
            , DP_Insured_Amount           varchar(100)
            , DP_Uninsured_Amount         varchar(100)
            , DP_Prepaid_Account_Flag     varchar(10)
            , DP_PT_Account_Flag          varchar(10)
            , DP_PT_Trans_Flag            varchar(10)
        );
    end;


    if object_id('mlbronze.customer') is null
    begin
        create table mlbronze.customer
        (
              CS_Unique_ID                    varchar(100)
            , CS_Govt_ID                      varchar(100)
            , CS_Govt_ID_Type                 varchar(100)
            , CS_Type                         varchar(100)
            , CS_First_Name                   varchar(100)
            , CS_Middle_Name                  varchar(100)
            , CS_Last_Name                    varchar(100)
            , CS_Name_Suffix                  varchar(100)
            , CS_Entity_Name                  varchar(200)
            , CS_Street_Add_Ln1               varchar(200)
            , CS_Street_Add_Ln2               varchar(200)
            , CS_Street_Add_Ln3               varchar(200)
            , CS_City                         varchar(100)
            , CS_State                        varchar(50)
            , CS_ZIP                          varchar(20)
            , CS_Country                      varchar(100)
            , CS_Telephone                    varchar(50)
            , CS_Email                        varchar(200)
            , CS_Outstanding_Debt_Flag        varchar(10)
            , CS_Security_Pledge_Flag         varchar(10)
            , Account_Holder_Status           varchar(50)
            , Date_Of_Status_Change           varchar(50)
            , Record_Complete_Data_Flag       varchar(10)
        );
    end;


    -------------------------------------------------------------------------
    -- 3. bulk ingest csv files into bronze
    -------------------------------------------------------------------------

    begin try
        bulk insert mlbronze.account
        from 'C:\Repos\Dev\gulf-to-bay-analytics-modernization-dev\01-sql-server\csv\370-account.csv'
        with
        (
              firstrow        = 2
            , fieldterminator = '|'
            , rowterminator   = '\n'
            , tablock
        );
    end try
    begin catch
        print 'error loading mlbronze.account: ' + error_message();
    end catch;


    begin try
        bulk insert mlbronze.customer
        from 'C:\Repos\Dev\gulf-to-bay-analytics-modernization-dev\01-sql-server\csv\370-customer.csv'
        with
        (
              firstrow        = 2
            , fieldterminator = '|'
            , rowterminator   = '\n'
            , tablock
        );
    end try
    begin catch
        print 'error loading mlbronze.customer: ' + error_message();
    end catch;


    -------------------------------------------------------------------------
    -- 4. validation queries (comment out after initial run)
    -------------------------------------------------------------------------

    --print 'row counts after ingestion:';

    --select
    --      'mlbronze.account'  as table_name
    --    , count(*)            as row_count
    --from mlbronze.account;

    --select
    --      'mlbronze.customer' as table_name
    --    , count(*)            as row_count
    --from mlbronze.customer;


    --print 'sample data from mlbronze.account:';
    --select top (25) *
    --from mlbronze.account;


    --print 'sample data from mlbronze.customer:';
    --select top (25) *
    --from mlbronze.customer;

end;

--exec ml.usp_InitBronzeIngestion

go

--exec ml.usp_InitBronzeIngestion