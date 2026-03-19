/* ============================================================
   Stored Procedure: bronze.usp_load_ga4
   ------------------------------------------------------------
   Purpose:
       Rebuild and load the unified flattened GA4 Bronze dataset
       into the bronze_events table. This replaces all legacy
       Bronze ingestion patterns (event_summary, users_and_sessions,
       landing_pages, traffic_source, device_category, etc.).

   Pattern:
       • Bronze  = raw ingestion (flattened CSV, untyped)
       • Silver  = typed, cleaned, normalized physical tables
       • Gold    = business‑ready dimensional layer

   Notes:
       • This script is safe to re-run.
       • bronze_events is dropped, recreated, and fully reloaded.
       • CSV is expected to be pre-flattened from BigQuery.
       • All Bronze columns are VARCHAR to support scientific
         notation, floats, empty strings, and malformed values.
       • Silver will perform all type conversions.
       • This aligns with Fabric / Databricks medallion best practices.

   Author:
       Michael Lloyd — Gulf to Bay Analytics Modernization Toolkit
   ============================================================ */

use ga4analytics;
go

-----------------------------------------------------------
-- drop bronze table if exists
-----------------------------------------------------------
if object_id('bronze_events', 'U') is not null
    drop table bronze_events;
go

-----------------------------------------------------------
-- recreate bronze table (varchar-only)
-----------------------------------------------------------
create table bronze_events
(
      event_date                     varchar(50)
    , event_timestamp                varchar(50)
    , event_name                     varchar(200)
    , event_previous_timestamp       varchar(50)
    , event_bundle_sequence_id       varchar(50)
    , event_server_timestamp_offset  varchar(50)

    , user_pseudo_id                 varchar(200)
    , user_first_touch_timestamp     varchar(50)

    , traffic_source_source          varchar(200)
    , traffic_source_medium          varchar(200)
    , traffic_source_campaign        varchar(200)

    , device_category                varchar(100)
    , device_operating_system        varchar(100)
    , device_mobile_brand_name       varchar(200)
    , device_mobile_model_name       varchar(200)
    , device_language                varchar(50)
    , device_browser                 varchar(200)
    , device_browser_version         varchar(200)

    , ga_session_id                  varchar(50)
    , ga_session_number              varchar(50)
    , page_location                  varchar(max)
    , page_referrer                  varchar(max)
    , engagement_time_msec           varchar(50)
    , purchase_value                 varchar(50)
    , purchase_currency              varchar(20)
    , session_engaged                varchar(10)

    , is_session_start               varchar(10)
    , is_page_view                   varchar(10)
    , is_user_engagement             varchar(10)
    , is_first_visit                 varchar(10)
    , is_purchase                    varchar(10)
);
go

-----------------------------------------------------------
-- recreate bronze loader procedure
-----------------------------------------------------------
set ansi_nulls on;
go
set quoted_identifier on;
go

alter procedure bronze.usp_load_ga4
as
begin
    set nocount on;

    -----------------------------------------------------------
    -- reset bronze table
    -----------------------------------------------------------
    truncate table bronze_events;

    -----------------------------------------------------------
    -- load unified flattened ga4 csv
    -----------------------------------------------------------
    bulk insert bronze_events
    from 'F:\Repos\Dev\gulf-to-bay-analytics-modernization-dev\14-apis\google-analytics\csv\bronze_events.csv'
    with (
          firstrow        = 2
        , fieldterminator = ','
        , rowterminator   = '\n'
        , tablock
    );
end;

--exec bronze.usp_load_ga4;

go

exec bronze.usp_load_ga4;