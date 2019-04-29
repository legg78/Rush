create or replace package body cln_api_report_pkg
/*********************************************************
*  Collectors reports <br />
*  Created by Nick (shalnov@bpcbt.com)  at 09.11.2018 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: cln_api_report_pkg <br />
*  @headcom
**********************************************************/
as
    procedure collector_performance(
        o_xml                  out clob
      , i_start_date        in     date                          default null
      , i_end_date          in     date                          default null
      , i_lang              in     com_api_type_pkg.t_dict_value default null
    ) is
        LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.collector_performance ';
        l_header                    xmltype;
        l_detail                    xmltype;

        l_lang                      com_api_type_pkg.t_dict_value := nvl(i_lang, get_user_lang);
        l_start_date                date;
        l_end_date                  date;
    begin
        trc_log_pkg.debug (
            i_text       => LOG_PREFIX || ' i_start_date [#1], i_end_date [#2]'
          , i_env_param1 => i_start_date
          , i_env_param2 => i_end_date
        );
        l_start_date := trunc(nvl(i_start_date, get_sysdate - 7));
        l_end_date   := trunc(nvl(i_end_date  , get_sysdate));

        select xmlelement("header"
                 , xmlelement("start_date", to_char(l_start_date, com_api_const_pkg.XML_DATE_FORMAT))
                 , xmlelement("end_date"  , to_char(l_end_date  , com_api_const_pkg.XML_DATE_FORMAT))
               )
        into l_header from dual;

        select xmlelement("collectors"
                 , xmlagg(
                       xmlelement("record"
                         , xmlelement("collector" , user_name)
                         , xmlelement("group"     , group_name)
                         , xmlelement("person"    , person_name)
                         , xmlelement("resolved"  , resolved_cnt)
                         , xmlelement("reopened"  , reopened_cnt)
                         , xmlelement("unresolved", unresolv_cnt)
                       )
                   )
               )
        into l_detail
        from (select au.name                              as user_name
                   , ag.id                                as group_id
                   , get_text(
                         i_table_name  => 'ACM_GROUP'
                       , i_column_name => 'NAME'
                       , i_object_id   => ag.id
                       , i_lang        => l_lang
                     )                                    as group_name
                   , acm_ui_user_pkg.get_person_name_by_user(
                         i_user_id     => au.id
                     )                                    as person_name
                   , (select count(distinct case_id)
                        from cln_action ca
                       where ca.status  = cln_api_const_pkg.COLLECTION_CASE_STATUS_RESOLVD
                         and ca.user_id = au.id
                         and action_date between l_start_date and l_end_date
                     )                                    as resolved_cnt
                   , (select count(distinct case_id)
                        from (select case_id
                                   , status
                                   , lead(ca.status, 1) over (partition by ca.case_id order by ca.id) lead_status
                                   , user_id
                                from cln_action ca
                               where ca.status    in (cln_api_const_pkg.COLLECTION_CASE_STATUS_OPENED
                                                    , cln_api_const_pkg.COLLECTION_CASE_STATUS_RESOLVD)
                               and ca.action_date >= l_start_date
                             )
                       where status      = cln_api_const_pkg.COLLECTION_CASE_STATUS_RESOLVD
                         and lead_status = cln_api_const_pkg.COLLECTION_CASE_STATUS_OPENED
                         and user_id     = au.id
                     )                                    as reopened_cnt
                   , (select count(id)
                        from cln_case c
                       where c.status  = cln_api_const_pkg.COLLECTION_CASE_STATUS_OPENED
                         and c.user_id = au.id
                     )                                    as unresolv_cnt
                from acm_user au
                   , acm_user_group aug
                   , acm_group ag
               where au.id = aug.user_id
                 and aug.group_id = ag.id
               order by group_name
                      , user_name
             );

        if l_detail.getclobval() = '<collectors></collectors>' then
            com_api_error_pkg.raise_error(
                i_error => 'USER_DOES_NOT_EXIST_IN_GROUP'
            );
        end if;

        select xmlelement("report"
             , l_header
             , l_detail
               ).getclobval()
          into o_xml
          from dual;

        trc_log_pkg.debug (
            i_text       => LOG_PREFIX || 'end for ([#1] - [#2])'
          , i_env_param1 => l_start_date
          , i_env_param2 => l_end_date
        );
    exception
        when com_api_error_pkg.e_application_error
          or com_api_error_pkg.e_fatal_error
        then
            raise;
        when others then
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || '>> FAILED ' || sqlerrm
            );
            raise;
    end collector_performance;

    procedure collector_activities(
        o_xml                  out clob
      , i_start_date        in     date                          default null
      , i_lang              in     com_api_type_pkg.t_dict_value default null
    ) is
        LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.collector_activities ';
        l_header                    xmltype;
        l_detail                    xmltype;

        l_lang                      com_api_type_pkg.t_dict_value := nvl(i_lang, get_user_lang);
        l_start_date                date;
    begin
        trc_log_pkg.debug (
            i_text       => LOG_PREFIX || ' i_start_date [#1]'
          , i_env_param1 => i_start_date
        );
        l_start_date := trunc(nvl(i_start_date, get_sysdate - 7));

        select xmlelement("header"
                 , xmlelement("start_date", to_char(l_start_date, com_api_const_pkg.XML_DATE_FORMAT))
               )
        into l_header from dual;

        with rawdata as (
            select au.name                              as user_name
                 , au.id                                as user_id
                 , ag.id                                as group_id
                 , get_text(
                       i_table_name  => 'ACM_GROUP'
                     , i_column_name => 'NAME'
                     , i_object_id   => ag.id
                     , i_lang        => l_lang
                   )                                    as group_name
                 , acm_ui_user_pkg.get_person_name_by_user(
                       i_user_id => au.id
                   )                                    as person_name
                 , (select count(1)
                      from cln_case cc
                     where cc.user_id = au.id
                       and cc.creation_date >= l_start_date
                       and cc.status not in (cln_api_const_pkg.COLLECTION_CASE_STATUS_RESOLVD, cln_api_const_pkg.COLLECTION_CASE_STATUS_CLOSED)
                   )                                    as assigned
                 , (select count(1)
                      from cln_case cc
                     where cc.user_id = au.id
                       and cc.status = cln_api_const_pkg.COLLECTION_CASE_STATUS_OPENED
                   )                                    as unresolved
              from acm_user au
              join acm_user_group aug on au.id = aug.user_id
              join acm_group ag on aug.group_id = ag.id
             order by group_name
                 , user_name
        )
        select xmlelement("collectors"
                 , xmlagg(
                       xmlelement("record"
                         , xmlelement("collector" , user_name)
                         , xmlelement("group"     , group_name)
                         , xmlelement("person"    , person_name)
                         , xmlelement("assigned"  , assigned)
                         , xmlelement("unresolved", unresolved)
                         , xmlelement("resolved"
                             , (select xmlagg(
                                          xmlelement("case"
                                            , xmlelement("case_number"      , cc.case_number)
                                            , xmlelement("creation_date"    , cc.creation_date)
                                            , xmlelement("resolution"       
                                                       , get_article_text(decode(cc.status
                                                                               , cln_api_const_pkg.COLLECTION_CASE_STATUS_RESOLVD
                                                                               , cc.resolution
                                                                               , ca.resolution)
                                                                        , l_lang))
                                            , xmlelement("customer_number"  , pc.customer_number)
                                            , xmlelement("customer_person"  , prd_ui_customer_pkg.get_customer_name(pc.id, l_lang))
                                            , xmlelement("activity_category"
                                                       , get_article_text(decode(cc.status
                                                                               , cln_api_const_pkg.COLLECTION_CASE_STATUS_RESOLVD
                                                                               , ca.activity_category
                                                                               , ca.lag_activity_category)
                                                                        , l_lang))
                                            , xmlelement("activity_type"
                                                       , get_article_text(decode(cc.status
                                                                               , cln_api_const_pkg.COLLECTION_CASE_STATUS_RESOLVD
                                                                               , ca.activity_type
                                                                               , ca.lag_activity_type)
                                                                        , l_lang))
                                            , xmlelement("action_date"
                                                       , decode(cc.status
                                                              , cln_api_const_pkg.COLLECTION_CASE_STATUS_RESOLVD
                                                              , ca.action_date
                                                              , ca.lag_action_date))
                                            , xmlelement("commentary"
                                                       , decode(cc.status
                                                              , cln_api_const_pkg.COLLECTION_CASE_STATUS_RESOLVD
                                                              , ca.commentary
                                                              , ca.lag_commentary))
                                            , xmlelement("dummy"            , null)
                                          )
                                       )
                                  from cln_case cc
                                     , prd_customer pc
                                     , (select case_id
                                             , activity_category
                                             , activity_type
                                             , action_date
                                             , commentary
                                             , lag_activity_category
                                             , lag_activity_type
                                             , lag_action_date
                                             , lag_commentary
                                             , lag_status
                                             , resolution
                                          from (select ac.case_id
                                                     , ac.activity_category
                                                     , ac.activity_type
                                                     , to_char(ac.action_date, com_api_const_pkg.XML_DATE_FORMAT) action_date
                                                     , ac.commentary
                                                     , lag(ac.activity_category, 1) over (partition by ac.case_id order by ac.id) lag_activity_category
                                                     , lag(ac.activity_type, 1) over (partition by ac.case_id order by ac.id) lag_activity_type
                                                     , to_char(lag(ac.action_date, 1) over (partition by ac.case_id order by ac.id), com_api_const_pkg.XML_DATE_FORMAT) lag_action_date
                                                     , lag(ac.commentary, 1) over (partition by ac.case_id order by ac.id) lag_commentary
                                                     , lag(ac.resolution, 1) over (partition by ac.case_id order by ac.id) resolution
                                                     , lag(ac.status, 1) over (partition by ac.case_id order by ac.id) lag_status
                                                     , row_number() over (partition by ac.case_id order by ac.action_date desc) rn
                                                  from cln_action ac
                                                 where nvl(ac.activity_category, cln_api_const_pkg.COLL_ACTIVITY_CATEG_COLLECTOR) != cln_api_const_pkg.COLL_ACTIVITY_CATEG_SYSTEM
                                                   and ac.action_date >= l_start_date)
                                         where rn = 1
                                       ) ca 
                                 where cc.customer_id    = pc.id
                                   and cc.user_id        = r.user_id
                                   and ca.case_id        = cc.id
                                   and (cc.status        = cln_api_const_pkg.COLLECTION_CASE_STATUS_RESOLVD
                                        or
                                        ca.lag_status    = cln_api_const_pkg.COLLECTION_CASE_STATUS_RESOLVD
                                        and cc.status    = cln_api_const_pkg.COLLECTION_CASE_STATUS_CLOSED
                                       )
                                   and cc.creation_date >= l_start_date
                               )
                           )
                       )
                   )
               )
          into l_detail
          from rawdata r;

        if l_detail.getclobval() = '<collectors></collectors>' then
            com_api_error_pkg.raise_error(
                i_error => 'USER_DOES_NOT_EXIST_IN_GROUP'
            );
        end if;

        select xmlelement("report"
             , l_header
             , l_detail
               ).getclobval()
          into o_xml
          from dual;

        trc_log_pkg.debug (
            i_text       => LOG_PREFIX || 'end for [#1]'
          , i_env_param1 => l_start_date
        );
    exception
        when com_api_error_pkg.e_application_error
          or com_api_error_pkg.e_fatal_error
        then
            raise;
        when others then
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || '>> FAILED ' || sqlerrm
            );
            raise;
    end collector_activities;

end cln_api_report_pkg;
/
