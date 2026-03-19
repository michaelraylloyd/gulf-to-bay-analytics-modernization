/* ============================================================
   Stored Procedure: silver.usp_build_silver_layer
   ------------------------------------------------------------
   Purpose:
       Build the Silver layer for the GA4Analytics medallion
       architecture by creating typed, cleaned, conformed tables
       sourced from the unified Bronze ingestion layer.

   Pattern:
       • Bronze  = raw ingestion (varchar, untyped)
       • Silver  = typed, cleaned, normalized physical tables
       • Gold    = business‑ready dimensional layer (next step)

   Notes:
       • This procedure is safe to re-run.
       • All Silver tables are dropped and recreated.
       • TRY_CONVERT is used to prevent load failures.
       • This aligns with Fabric / Databricks medallion best practices.

   Author:
       Michael Lloyd — Gulf to Bay Analytics Modernization Toolkit
   ============================================================ */

create or alter procedure silver.usp_build_silver_layer
as
begin
    set nocount on;

    -----------------------------------------------------------
    -- 1. silver.events (typed event-level table)
    -----------------------------------------------------------
    drop table if exists silver.events;

    create table silver.events
    (
          event_date                     date
        , event_timestamp                bigint
        , event_name                     varchar(200)
        , user_pseudo_id                 varchar(200)
        , ga_session_id                  bigint
        , ga_session_number              int
        , page_location                  varchar(max)
        , page_referrer                  varchar(max)
        , engagement_time_msec           int
        , is_session_start               bit
        , is_page_view                   bit
        , is_user_engagement             bit
        , is_first_visit                 bit
        , is_purchase                    bit
    );

    insert into silver.events
    select
          try_convert(date, event_date)
        , try_convert(bigint, event_timestamp)
        , event_name
        , user_pseudo_id
        , try_convert(bigint, ga_session_id)
        , try_convert(int, ga_session_number)
        , page_location
        , page_referrer
        , try_convert(int, engagement_time_msec)
        , try_convert(bit, is_session_start)
        , try_convert(bit, is_page_view)
        , try_convert(bit, is_user_engagement)
        , try_convert(bit, is_first_visit)
        , try_convert(bit, is_purchase)
    from bronze_events;


    -----------------------------------------------------------
    -- 2. silver.sessions (session-level rollup)
    -----------------------------------------------------------
    drop table if exists silver.sessions;

    create table silver.sessions
    (
          session_id             bigint
        , user_pseudo_id         varchar(200)
        , session_date           date
        , session_number         int
        , pageviews              int
        , events                 int
        , engaged_session        bit
        , engagement_time_msec   int
    );

    insert into silver.sessions
    select
          try_convert(bigint, ga_session_id)                     as session_id
        , user_pseudo_id
        , try_convert(date, event_date)                          as session_date
        , try_convert(int, ga_session_number)                    as session_number
        , sum(try_convert(int, is_page_view))                    as pageviews
        , count(*)                                               as events
        , max(try_convert(int, session_engaged))                 as engaged_session   -- FIX APPLIED
        , sum(try_convert(int, engagement_time_msec))            as engagement_time_msec
    from bronze_events
    group by
          try_convert(bigint, ga_session_id)
        , user_pseudo_id
        , try_convert(date, event_date)
        , try_convert(int, ga_session_number);


    -----------------------------------------------------------
    -- 3. silver.users (user-level rollup)
    -----------------------------------------------------------
    drop table if exists silver.users;

    create table silver.users
    (
          user_pseudo_id         varchar(200)
        , first_seen_date        date
        , sessions               int
        , pageviews              int
        , events                 int
    );

    insert into silver.users
    select
          user_pseudo_id
        , min(try_convert(date, event_date))                     as first_seen_date
        , count(distinct try_convert(bigint, ga_session_id))     as sessions
        , sum(try_convert(int, is_page_view))                    as pageviews
        , count(*)                                               as events
    from bronze_events
    group by user_pseudo_id;


    -----------------------------------------------------------
    -- 4. silver.pageviews (page-level rollup)
    -----------------------------------------------------------
    drop table if exists silver.pageviews;

    create table silver.pageviews
    (
          page_location          varchar(max)
        , event_date             date
        , pageviews              int
        , sessions               int
    );

    insert into silver.pageviews
    select
          page_location
        , try_convert(date, event_date)
        , sum(try_convert(int, is_page_view))                    as pageviews
        , count(distinct try_convert(bigint, ga_session_id))     as sessions
    from bronze_events
    where page_location is not null
    group by
          page_location
        , try_convert(date, event_date);

end;

--exec silver.usp_build_silver_layer;

go

exec silver.usp_build_silver_layer;