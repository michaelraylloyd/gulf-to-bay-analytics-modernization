/* ============================================================
   Stored Procedure: gold.usp_build_gold_layer
   ------------------------------------------------------------
   Purpose:
       Build the Gold (Dimensional) layer for the
       GA4Analytics medallion architecture using the new
       unified Silver layer.

       Includes:
         • Dimension tables with surrogate keys
         • Fact tables referencing dimensions
         • Deterministic rebuild (drop → recreate)

   Pattern:
       • Bronze  = raw ingestion (varchar, untyped)
       • Silver  = typed, cleaned, normalized physical tables
       • Gold    = business‑ready dimensional layer

   Notes:
       • Safe to re-run.
       • Drops fact tables first (FK‑safe).
       • DateSK uses yyyymmdd integer pattern.

   Author:
       Michael Lloyd — Gulf to Bay Analytics Modernization Toolkit
   ============================================================ */

use ga4analytics;
go

set ansi_nulls on;
go
set quoted_identifier on;
go

create or alter procedure gold.usp_build_gold_layer
as
begin
    set nocount on;

    -----------------------------------------------------------
    -- DROP FACT TABLES FIRST (FK‑SAFE)
    -----------------------------------------------------------
    drop table if exists gold.fact_top_events;
    drop table if exists gold.fact_content_performance;
    drop table if exists gold.fact_daily_kpis;

    -----------------------------------------------------------
    -- DROP DIMENSIONS SECOND
    -----------------------------------------------------------
    drop table if exists gold.dim_event;
    drop table if exists gold.dim_page;
    drop table if exists gold.dim_date;

    -----------------------------------------------------------
    -- 1. DIMENSIONS
    -----------------------------------------------------------

    -----------------------------------------------------------
    -- dim_date
    -----------------------------------------------------------
    create table gold.dim_date
    (
          date_sk     int         not null primary key
        , full_date   date        not null
        , year_num    int
        , month_num   int
        , day_num     int
        , month_name  varchar(20)
    );

    ;with d as
    (
        select cast('2020-01-01' as date) as dt
        union all
        select dateadd(day, 1, dt)
        from d
        where dt < '2030-12-31'
    )
    insert into gold.dim_date
    (
          date_sk
        , full_date
        , year_num
        , month_num
        , day_num
        , month_name
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


    -----------------------------------------------------------
    -- dim_page (base table)
    -----------------------------------------------------------
    create table gold.dim_page
    (
          page_sk                 int identity(1,1) primary key
        , page_location           varchar(max)          not null
        , page_section            varchar(200)          null
        , page_subsection         varchar(200)          null
        , page_subsubsection      varchar(200)          null
        , section_fallback        varchar(200)          null
        , subsection_fallback     varchar(200)          null
        , subsubsection_fallback  varchar(200)          null
        , page_depth              int                   null
        , page_type               varchar(50)           null
        , product_name            varchar(300)          null
        , clean_category          varchar(200)          null
        , is_product_page         bit                   null
        , is_category_page        bit                   null
        , is_quickview            bit                   null
        , is_extension_page       bit                   null
        , page_slug               varchar(300)          null
        , page_hierarchy          varchar(600)          null
        , page_group              varchar(100)          null
        , page_key                varchar(600)          null
    );

    insert into gold.dim_page (page_location)
    select distinct page_location
    from silver.pageviews
    where page_location is not null;


    -----------------------------------------------------------
    -- ENRICH dim_page (dynamic SQL to avoid compile‑time errors)
    -----------------------------------------------------------
    declare @sql nvarchar(max) = N'
    ;with cleaned as (
        select
              p.page_sk
            , p.page_location
            , lower(
                replace(
                    replace(
                        replace(
                            replace(p.page_location, ''https://'', ''''),
                        ''http://'', ''''),
                    ''+'', '' ''),
                ''//'', ''/'')
              ) as url_norm
        from gold.dim_page p
    ),
    path_only as (
        select
              page_sk
            , page_location
            , url_norm
            , case
                when charindex(''/'', url_norm) > 0
                    then substring(url_norm, charindex(''/'', url_norm) + 1, len(url_norm))
                else url_norm
              end as path_raw
        from cleaned
    ),
    path_clean as (
        select
              page_sk
            , page_location
            , replace(
                replace(
                    replace(
                        rtrim(ltrim(path_raw)),
                    ''quickview'', ''''),
                ''.axd'', ''''),
            ''.html'', '''') as path_cleaned
        from path_only
    ),
    split as (
        select
              page_sk
            , page_location
            , value as segment
            , row_number() over (partition by page_sk order by (select null)) as rn
        from path_clean
        cross apply string_split(path_cleaned, ''/'')
    ),
    pivoted as (
        select
              page_sk
            , page_location
            , max(case when rn = 1 then segment end) as lvl1
            , max(case when rn = 2 then segment end) as lvl2
            , max(case when rn = 3 then segment end) as lvl3
            , max(case when rn = 4 then segment end) as lvl4
            , max(case when rn = 5 then segment end) as lvl5
        from split
        group by page_sk, page_location
    ),
    shaped as (
        select
              p.page_sk
            , p.page_location

            , s.page_section
            , s.page_subsection
            , s.page_subsubsection

            , s.section_fallback
            , s.subsection_fallback
            , s.subsubsection_fallback

            , s.page_depth
            , s.page_type
            , s.product_name
            , s.clean_category
            , s.is_product_page
            , s.is_category_page
            , s.is_quickview
            , s.is_extension_page
            , s.page_slug
            , s.page_hierarchy
            , s.page_group
            , s.page_key

        from pivoted p
        cross apply (
            select
                  lvl1 as page_section
                , lvl2 as page_subsection
                , lvl3 as page_subsubsection

                , coalesce(lvl1, lvl2, lvl3, lvl4, lvl5) as section_fallback
                , coalesce(lvl2, lvl3, lvl4, lvl5) as subsection_fallback
                , coalesce(lvl3, lvl4, lvl5) as subsubsection_fallback

                , case
                    when lvl5 is not null then 5
                    when lvl4 is not null then 4
                    when lvl3 is not null then 3
                    when lvl2 is not null then 2
                    when lvl1 is not null then 1
                    else 0
                  end as page_depth

                , case
                    when lvl1 like ''%search%'' then ''search''
                    when lvl1 like ''%basket%'' or lvl1 like ''%cart%'' then ''cart''
                    when lvl1 like ''%checkout%'' then ''checkout''
                    when lvl1 like ''%forgot%'' or lvl1 like ''%login%'' then ''auth''
                    when (case
                            when lvl5 is not null then 5
                            when lvl4 is not null then 4
                            when lvl3 is not null then 3
                            when lvl2 is not null then 2
                            when lvl1 is not null then 1
                            else 0
                          end) = 2 then ''category''
                    when (case
                            when lvl5 is not null then 5
                            when lvl4 is not null then 4
                            when lvl3 is not null then 3
                            when lvl2 is not null then 2
                            when lvl1 is not null then 1
                            else 0
                          end) >= 3 then ''product''
                    else ''misc''
                  end as page_type

                , case when lvl3 is not null then lvl3 end as product_name

                , case
                    when lvl1 like ''%google redesign%'' then ''google redesign''
                    when lvl1 like ''%google greenesign%'' then ''google greenesign''
                    when lvl1 like ''%eco%'' then ''eco''
                    else lvl1
                  end as clean_category

                , case when lvl3 is not null then 1 else 0 end as is_product_page
                , case when lvl2 is not null and lvl3 is null then 1 else 0 end as is_category_page
                , case when p.page_location like ''%quickview%'' then 1 else 0 end as is_quickview
                , case when p.page_location like ''%.axd%'' or p.page_location like ''%.html%'' then 1 else 0 end as is_extension_page

                , replace(replace(lower(lvl3), '' '', ''-''), ''+'', ''-'') as page_slug

                , case
                      when lvl1 is null or ltrim(rtrim(lvl1)) = ''''
                          then ''Home''
                      else concat_ws('' > '', lvl1, lvl2, lvl3)
                  end as page_hierarchy

                , case
                    when (case
                            when lvl5 is not null then 5
                            when lvl4 is not null then 4
                            when lvl3 is not null then 3
                            when lvl2 is not null then 2
                            when lvl1 is not null then 1
                            else 0
                          end) >= 3 then ''Product Pages''
                    when lvl2 is not null and lvl3 is null then ''Category Pages''
                    when lvl1 like ''%search%'' then ''Search Pages''
                    when lvl1 like ''%basket%'' or lvl1 like ''%checkout%'' then ''Transaction Pages''
                    when lvl1 like ''%forgot%'' or lvl1 like ''%login%'' then ''Authentication Pages''
                    else ''Other Pages''
                  end as page_group

                , concat(
                    coalesce(lvl1, ''''),
                    ''|'',
                    coalesce(lvl2, ''''),
                    ''|'',
                    coalesce(lvl3, '''')
                  ) as page_key
        ) s
    )
    update dp
    set      dp.page_section           = sh.page_section
           , dp.page_subsection        = sh.page_subsection
           , dp.page_subsubsection     = sh.page_subsubsection
           , dp.section_fallback       = sh.section_fallback
           , dp.subsection_fallback    = sh.subsection_fallback
           , dp.subsubsection_fallback = sh.subsubsection_fallback
           , dp.page_depth             = sh.page_depth
           , dp.page_type              = sh.page_type
           , dp.product_name           = sh.product_name
           , dp.clean_category         = sh.clean_category
           , dp.is_product_page        = sh.is_product_page
           , dp.is_category_page       = sh.is_category_page
           , dp.is_quickview           = sh.is_quickview
           , dp.is_extension_page      = sh.is_extension_page
           , dp.page_slug              = sh.page_slug
           , dp.page_hierarchy         = sh.page_hierarchy
           , dp.page_group             = sh.page_group
           , dp.page_key               = sh.page_key
    from gold.dim_page dp
    join shaped sh
      on dp.page_sk = sh.page_sk;
    ';

    exec(@sql);


    -----------------------------------------------------------
    -- dim_event
    -----------------------------------------------------------
    create table gold.dim_event
    (
          event_sk    int identity(1,1) primary key
        , event_name  varchar(200)
    );

    insert into gold.dim_event
    (
        event_name
    )
    select distinct
        event_name
    from silver.events
    where event_name is not null;


    -----------------------------------------------------------
    -- 2. FACT TABLES
    -----------------------------------------------------------

    -----------------------------------------------------------
    -- fact_daily_kpis
    -----------------------------------------------------------
    create table gold.fact_daily_kpis
    (
          date_sk           int not null
        , users             int
        , sessions          int
        , pageviews         int
        , events            int
        , engaged_sessions  int
        , foreign key (date_sk) references gold.dim_date(date_sk)
    );

    insert into gold.fact_daily_kpis
    (
          date_sk
        , users
        , sessions
        , pageviews
        , events
        , engaged_sessions
    )
    select
          convert(int, format(e.event_date, 'yyyyMMdd'))          as date_sk
        , count(distinct e.user_pseudo_id)                        as users
        , count(distinct s.session_id)                            as sessions
        , sum(try_convert(int, e.is_page_view))                   as pageviews
        , count(*)                                                as events
        , sum(try_convert(int, s.engaged_session))                as engaged_sessions
    from silver.events e
    left join silver.sessions s
      on s.session_id    = e.ga_session_id
     and s.session_date  = e.event_date
    group by
        convert(int, format(e.event_date, 'yyyyMMdd'));


    -----------------------------------------------------------
    -- fact_content_performance
    -----------------------------------------------------------
    create table gold.fact_content_performance
    (
          date_sk    int not null
        , page_sk    int not null
        , pageviews  int
        , sessions   int
        , foreign key (date_sk) references gold.dim_date(date_sk)
        , foreign key (page_sk) references gold.dim_page(page_sk)
    );

    insert into gold.fact_content_performance
    (
          date_sk
        , page_sk
        , pageviews
        , sessions
    )
    select
          convert(int, format(p.event_date, 'yyyyMMdd'))  as date_sk
        , dp.page_sk
        , p.pageviews
        , p.sessions
    from silver.pageviews p
    join gold.dim_page dp
      on dp.page_location = p.page_location;


    -----------------------------------------------------------
    -- fact_top_events
    -----------------------------------------------------------
    create table gold.fact_top_events
    (
          event_sk     int not null
        , event_count  int
        , users        int
        , foreign key (event_sk) references gold.dim_event(event_sk)
    );

    insert into gold.fact_top_events
    (
          event_sk
        , event_count
        , users
    )
    select
          de.event_sk
        , count(*)                                   as event_count
        , count(distinct e.user_pseudo_id)          as users
    from silver.events e
    join gold.dim_event de
      on de.event_name = e.event_name
    group by
        de.event_sk;

end;

--exec gold.usp_build_gold_layer;

go

exec gold.usp_build_gold_layer;