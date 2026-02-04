/*==============================================================
    INDEXING STRATEGY — ML.FactInternetSalesFixed
    -------------------------------------------------------------
    GOALS:
      1. Preserve identical query behavior to dbo.FactInternetSales
      2. Maintain uniqueness on the natural business key
      3. Support star-schema joins for Power BI performance
      4. Keep surrogate PK for warehouse mechanics
==============================================================*/

---------------------------------------------------------------
-- 1. PRIMARY KEY (Nonclustered)
--    Surrogate key for DW mechanics. Not used for joins.
---------------------------------------------------------------
alter table ML.FactInternetSalesFixed
add constraint PK_FactInternetSalesFixed
primary key nonclustered (FactSalesFixedKey);


---------------------------------------------------------------
-- 2. CLUSTERED INDEX (Recommended)
--    Match original table behavior:
--    Cluster on the natural business key:
--       SalesOrderNumber + SalesOrderLineNumber
--    This preserves downstream expectations and query plans.
---------------------------------------------------------------
create unique clustered index CIX_FactInternetSalesFixed_SON_SOLN
on ML.FactInternetSalesFixed (
      SalesOrderNumber
    , SalesOrderLineNumber
);


---------------------------------------------------------------
-- 3. NONCLUSTERED INDEXES FOR STAR-SCHEMA JOINS
--    These accelerate Power BI queries that join on dimension keys.
---------------------------------------------------------------

-- Product dimension join
create nonclustered index NCI_FactInternetSalesFixed_ProductKey
on ML.FactInternetSalesFixed (ProductKey);

-- Customer dimension join
create nonclustered index NCI_FactInternetSalesFixed_CustomerKey
on ML.FactInternetSalesFixed (CustomerKey);

---------------------------------------------------------------
-- 4. OPTIONAL: Date dimension join support
--    Only add these if your model frequently filters by date keys.
---------------------------------------------------------------

-- OrderDateKey
create nonclustered index NCI_FactInternetSalesFixed_OrderDateKey
on ML.FactInternetSalesFixed (OrderDateKey);

-- DueDateKey
create nonclustered index NCI_FactInternetSalesFixed_DueDateKey
on ML.FactInternetSalesFixed (DueDateKey);

-- ShipDateKey
create nonclustered index NCI_FactInternetSalesFixed_ShipDateKey
on ML.FactInternetSalesFixed (ShipDateKey);