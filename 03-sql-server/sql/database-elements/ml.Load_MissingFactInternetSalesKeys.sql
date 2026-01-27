create or alter procedure ml.Load_MissingFactInternetSalesKeys
as
begin
    set nocount on;

    -------------------------------------------------------------------------
    -- 1. Create staging table if not exists (with identity column)
    -------------------------------------------------------------------------
    if not exists
    (
        select 1
        from sys.tables t
        join sys.schemas s on s.schema_id = t.schema_id
        where s.name = 'ml'
          and t.name = 'MissingKeys'
    )
    begin
        create table ml.MissingKeys
        (
              MissingKeyID       int identity(1,1) not null
            , SalesOrderID       int
            , ProductID          int
            , SalesOrderNumber   nvarchar(25)
        );
    end;

    -------------------------------------------------------------------------
    -- 2. Clear staging table
    -------------------------------------------------------------------------
    truncate table ml.MissingKeys;

    -------------------------------------------------------------------------
    -- 3. Reset identity seed
    -------------------------------------------------------------------------
    dbcc checkident ('ml.MissingKeys', reseed, 0);

    -------------------------------------------------------------------------
    -- 4. Insert rows (replace this with your real source)
    -------------------------------------------------------------------------
    insert into ml.MissingKeys
    (
          SalesOrderID
        , ProductID
        , SalesOrderNumber
    )
    select
          m.SalesOrderID
        , m.ProductID
        , m.SalesOrderNumber
    from stg.MissingKeys m;

end;
go

select * from ml.MissingKeys
select * from stg.MissingKeys

exec ml.Load_MissingFactInternetSalesKeys

