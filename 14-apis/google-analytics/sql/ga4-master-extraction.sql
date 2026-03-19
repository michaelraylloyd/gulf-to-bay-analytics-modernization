/* ============================================================
   1. Event Summary
   ------------------------------------------------------------
   Basic count of all events by date and event_name.
   Useful for understanding overall event volume and activity.
   ============================================================ */
select
    event_date
  , event_name
  , count(*) as event_count
from
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
group by
    event_date
  , event_name
order by
    event_date
  , event_name
;



/* ============================================================
   2. Users & Sessions
   ------------------------------------------------------------
   GA4 stores session_id inside event_params.
   We extract it inline and count distinct user/session combos.
   ============================================================ */
select
    event_date
  , count(distinct user_pseudo_id) as users
  , count(
        distinct concat(
              user_pseudo_id
            , (
                  select value.int_value
                  from unnest(event_params)
                  where key = 'ga_session_id'
              )
        )
    ) as sessions
from
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
group by
    event_date
order by
    event_date
;



/* ============================================================
   3. Landing Pages (Sessions by Page Location)
   ------------------------------------------------------------
   Extracts page_location from event_params for page_view events.
   Counts distinct sessions per landing page.
   ============================================================ */
select
    event_date
  , (
        select value.string_value
        from unnest(event_params)
        where key = 'page_location'
    ) as page_location
  , count(
        distinct concat(
              user_pseudo_id
            , (
                  select value.int_value
                  from unnest(event_params)
                  where key = 'ga_session_id'
              )
        )
    ) as sessions
from
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
where
    event_name = 'page_view'
group by
    event_date
  , page_location
order by
    event_date
  , sessions desc
;



/* ============================================================
   4. Traffic Source (Source / Medium / Campaign)
   ------------------------------------------------------------
   Uses the traffic_source struct available on session_start events.
   ============================================================ */
select
    event_date
  , traffic_source.source  as source
  , traffic_source.medium  as medium
  , traffic_source.name    as campaign
  , count(
        distinct concat(
              user_pseudo_id
            , (
                  select value.int_value
                  from unnest(event_params)
                  where key = 'ga_session_id'
              )
        )
    ) as sessions
from
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
where
    event_name = 'session_start'
group by
    event_date
  , source
  , medium
  , campaign
order by
    event_date
  , sessions desc
;



/* ============================================================
   5. Device Category (Mobile / Desktop / Tablet)
   ------------------------------------------------------------
   Device information is stored in the device struct.
   ============================================================ */
select
    event_date
  , device.category          as device_category
  , device.operating_system  as os
  , count(
        distinct concat(
              user_pseudo_id
            , (
                  select value.int_value
                  from unnest(event_params)
                  where key = 'ga_session_id'
              )
        )
    ) as sessions
from
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
where
    event_name = 'session_start'
group by
    event_date
  , device_category
  , os
order by
    event_date
  , sessions desc
;



/* ============================================================
   6. Conversions (Purchase Events)
   ------------------------------------------------------------
   GA4 purchase events include a "value" parameter for revenue.
   ============================================================ */
select
    event_date
  , count(*) as purchase_events
  , sum(
        (
            select value.int_value
            from unnest(event_params)
            where key = 'value'
        )
    ) as total_value
from
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
where
    event_name = 'purchase'
group by
    event_date
order by
    event_date
;



/* ============================================================
   7. Top Events (Event Stream)
   ------------------------------------------------------------
   High-level event frequency and distinct user count.
   ============================================================ */
select
    event_name
  , count(*)                       as event_count
  , count(distinct user_pseudo_id) as users
from
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
group by
    event_name
order by
    event_count desc
;



/* ============================================================
   8. Pageviews (Content Performance)
   ------------------------------------------------------------
   Counts page_view events and extracts page_location.
   ============================================================ */
select
    event_date
  , (
        select value.string_value
        from unnest(event_params)
        where key = 'page_location'
    ) as page_location
  , count(*) as pageviews
from
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
where
    event_name = 'page_view'
group by
    event_date
  , page_location
order by
    event_date
  , pageviews desc
;



/* ============================================================
   9. Engagement Time (User Engagement Events)
   ------------------------------------------------------------
   Extracts engagement_time_msec from event_params.
   ============================================================ */
select
    event_date
  , user_pseudo_id-- ============================================================
-- BRONZE: Unified Flattened GA4 Events Extraction
-- One row per event, all required fields explicitly flattened.
-- ============================================================

with base as (
    select
          -- Core event fields
          event_date
        , event_timestamp
        , event_name
        , event_previous_timestamp
        , event_bundle_sequence_id
        , event_server_timestamp_offset

        -- User fields
        , user_pseudo_id
        , user_first_touch_timestamp

        -- Traffic source fields
        , traffic_source.source   as `traffic_source_source`
        , traffic_source.medium   as `traffic_source_medium`
        , traffic_source.name     as `traffic_source_campaign`

        -- Device fields (full set, corrected)
        , device.category                 as `device_category`
        , device.operating_system         as `device_operating_system`
        , device.mobile_brand_name        as `device_mobile_brand_name`
        , device.mobile_model_name        as `device_mobile_model_name`
        , device.language                 as `device_language`

        -- Browser fields from nested struct
        , device.web_info.browser         as `device_browser`
        , device.web_info.browser_version as `device_browser_version`

        -- Flattened event parameters (critical GA4 params)
        , (
            select value.int_value
            from unnest(event_params)
            where key = 'ga_session_id'
          ) as `ga_session_id`

        , (
            select value.int_value
            from unnest(event_params)
            where key = 'ga_session_number'
          ) as `ga_session_number`

        , (
            select value.string_value
            from unnest(event_params)
            where key = 'page_location'
          ) as `page_location`

        , (
            select value.string_value
            from unnest(event_params)
            where key = 'page_referrer'
          ) as `page_referrer`

        , (
            select value.int_value
            from unnest(event_params)
            where key = 'engagement_time_msec'
          ) as `engagement_time_msec`

        , (
            select value.int_value
            from unnest(event_params)
            where key = 'value'
          ) as `purchase_value`

        , (
            select value.string_value
            from unnest(event_params)
            where key = 'currency'
          ) as `purchase_currency`

        , (
            select value.int_value
            from unnest(event_params)
            where key = 'session_engaged'
          ) as `session_engaged`

        -- Event type flags (derived)
        , case when event_name = 'session_start'    then 1 else 0 end as `is_session_start`
        , case when event_name = 'page_view'        then 1 else 0 end as `is_page_view`
        , case when event_name = 'user_engagement'  then 1 else 0 end as `is_user_engagement`
        , case when event_name = 'first_visit'      then 1 else 0 end as `is_first_visit`
        , case when event_name = 'purchase'         then 1 else 0 end as `is_purchase`

    from
        `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
)

select
    *
from
    base
order by
      event_date
    , event_timestamp;
  , (
        select value.int_value
        from unnest(event_params)
        where key = 'engagement_time_msec'
    ) as engagement_time_msec
from
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
where
    event_name = 'user_engagement'
order by
    event_date
;



/* ============================================================
   10. Landing Page Sessions (Duplicate of #3 for Reference)
   ------------------------------------------------------------
   Included again for completeness in the master script.
   ============================================================ */
select
    event_date
  , (
        select value.string_value
        from unnest(event_params)
        where key = 'page_location'
    ) as page_location
  , count(
        distinct concat(
              user_pseudo_id
            , (
                  select value.int_value
                  from unnest(event_params)
                  where key = 'ga_session_id'
              )
        )
    ) as sessions
from
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
where
    event_name = 'page_view'
group by
    event_date
  , page_location
order by
    event_date
  , sessions desc
;