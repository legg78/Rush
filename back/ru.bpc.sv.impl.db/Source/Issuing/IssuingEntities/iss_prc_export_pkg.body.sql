create or replace package body iss_prc_export_pkg as
/************************************************************
 * API for process files <br />
 * Created by Necheukhin I. (necheukhin@bpcbt.com)  at 18.11.2009 <br />
 * Module: ISS_PRC_EXPORT_PKG <br />
 * @headcom
 ***********************************************************/

CRLF                     constant com_api_type_pkg.t_name     := chr(13) || chr(10);

g_service_id_tab           prd_service_tpt;
g_product_tab              prd_product_tpt;
g_card_limit_map_tab       prd_product_attr_map_tpt;
g_customer_limit_map_tab   prd_product_attr_map_tpt;
g_scheme_id_tab            com_api_type_pkg.t_tiny_tab;

procedure export_cards_status(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_start_date          in     date                             default null
  , i_end_date            in     date                             default null
  , i_card_status         in     com_api_type_pkg.t_dict_value    default null
  , i_export_state        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_event_type          in     com_api_type_pkg.t_dict_value    default null
  , i_type_of_date_range  in     com_api_type_pkg.t_dict_value    default null
) is
    l_sess_file_id               com_api_type_pkg.t_long_id;
    l_file                       clob;
    l_card                       clob;
    l_count                      com_api_type_pkg.t_count := 0;
    l_start_date                 date;
    l_end_date                   date;
    l_default_start_date         date;
begin
    trc_log_pkg.debug(
        i_text          => 'iss_prc_export_pkg.export_cards_status: i_inst_id [#1], i_start_date [#2], i_end_date [#3], i_export_state [#4]'
      , i_env_param1    => i_inst_id
      , i_env_param2    => i_start_date
      , i_env_param3    => i_end_date
      , i_env_param4    => i_export_state
    );

    l_default_start_date := com_api_sttl_day_pkg.get_calc_date(
                                i_inst_id   => i_inst_id
                              , i_date_type => nvl(i_type_of_date_range, fcl_api_const_pkg.DATE_TYPE_SYSTEM_DATE)
                            );

    l_start_date := trunc(coalesce(i_start_date, l_default_start_date), 'DD');
    l_end_date   := trunc(coalesce(i_end_date, com_api_sttl_day_pkg.get_sysdate), 'DD') + 1 - com_api_const_pkg.ONE_SECOND;

    prc_api_stat_pkg.log_start;

    savepoint sp_cards_export;

    for cards in (
        select cn.card_number
             , ci.card_uid      card_id
             , ci.expir_date
             , ci.seq_number
             , s.change_date
             , sta.status
             , ste.status state
             , s.initiator
             , s.event_type
             , row_number() over (order by s.id) rn
             , count(s.id)  over () cnt
          from iss_card             c
             , iss_card_instance    ci
             , iss_card_number      cn
             , evt_status_log       s
             , (select id
                     , object_id
                     , event_type
                     , status
                     , session_id
                     , row_number() over (partition by object_id, event_type, session_id
                                              order by change_date
                                         ) rn
                  from evt_status_log sl
                 where sl.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                   and sl.change_date between l_start_date and l_end_date
                   and (sl.status = i_card_status
                        or i_card_status is null)
                   and (i_event_type is null
                        or sl.event_type = i_event_type)
                   and sl.status like 'CSTS%') sta
             , (select id
                     , object_id
                     , event_type
                     , status
                     , session_id
                     , row_number() over (partition by object_id, event_type, session_id
                                              order by change_date
                                         ) rn
                  from evt_status_log sl
                 where sl.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                   and sl.change_date between l_start_date and l_end_date
                   and (i_event_type is null
                        or sl.event_type = i_event_type)
                   and sl.status like 'CSTE%') ste
         where ci.card_id    = c.id
           and cn.card_id    = c.id
           and s.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
           and s.object_id   = ci.id
           and s.change_date between l_start_date and l_end_date
           and (s.status = i_card_status
                or i_card_status is null)
           and s.status like 'CSTS%'
           and (i_event_type is null
                or s.event_type = i_event_type)
           and (
                (s.status like 'CSTS%'
                 and s.id = sta.id)
                or
                (s.status like 'CSTE%'
                 and s.id = ste.id)
               )
           and sta.object_id  = ste.object_id(+)
           and sta.event_type = ste.event_type(+)
           and sta.session_id = ste.session_id(+)
           and sta.rn         = ste.rn(+)
    ) loop
        if cards.rn = 1 then
            prc_api_stat_pkg.log_estimation (
                i_estimated_count  => cards.cnt
            );
        end if;

        trc_log_pkg.debug(
            i_text          => 'export card [#1] status'
          , i_env_param1    => iss_api_card_pkg.get_card_mask(cards.card_number)
        );

        select xmlelement("card_status",
                   xmlforest(
                       cards.card_number   as "card_number"
                     , cards.card_id       as "card_id"
                     , to_char(cards.expir_date, com_api_const_pkg.XML_DATE_FORMAT)
                                           as "expiration_date"
                     , cards.seq_number    as "seq_number"
                     , to_char(cards.change_date, com_api_const_pkg.XML_DATETIME_FORMAT)
                                           as "change_date"
                     , cards.status        as "status"
                     , cards.state         as "state"
                     , cards.initiator     as "initiator"
                     , cards.event_type    as "status_reason"
                   )
               ).getclobval()
          into l_card
          from dual;

        l_file  := l_file || l_card;
        l_count := l_count + 1;

        prc_api_stat_pkg.log_current(
            i_current_count   => cards.rn
          , i_excepted_count  => 0
        );

    end loop;

    if l_count = 0 then
        prc_api_stat_pkg.log_estimation (
            i_estimated_count => 0
        );
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );

    else
        prc_api_file_pkg.open_file(
            o_sess_file_id  => l_sess_file_id
        );

        trc_log_pkg.debug(
            i_text          => 'l_sess_file_id [#1]'
          , i_env_param1    => l_sess_file_id
        );

        l_file := com_api_const_pkg.XML_HEADER || CRLF
                    || '<card_statuses xmlns="http://sv.bpc.in/SVXP">'
                    || l_file || CRLF
                    || '</card_statuses>';

        prc_api_file_pkg.put_file(
            i_sess_file_id  => l_sess_file_id
          , i_clob_content  => l_file
        );
        trc_log_pkg.debug(
            i_text          => 'file length [#1], cards status exported [#2]'
          , i_env_param1    => length(l_file)
          , i_env_param2    => l_count
        );
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_sess_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );

    end if;

    trc_log_pkg.debug('Cards status exporting finished');

exception
    when others then
        rollback to sp_cards_export;
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        if l_sess_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_sess_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;

end export_cards_status;

procedure generate_customer(
    i_inst_id              in     com_api_type_pkg.t_inst_id
  , i_card_id              in     com_api_type_pkg.t_medium_id
  , i_customer_id          in     com_api_type_pkg.t_medium_id
  , i_split_hash           in     com_api_type_pkg.t_tiny_id
  , i_product_id           in     com_api_type_pkg.t_short_id
  , i_customer_value_type  in     com_api_type_pkg.t_boolean
  , i_sysdate              in     date
  , o_xml_block               out nocopy com_api_type_pkg.t_lob_data
)
is
    l_method_name          com_api_type_pkg.t_name := 'generate_customer';
    l_label_name           com_api_type_pkg.t_name := 'xml_block';

    l_service_id           com_api_type_pkg.t_short_id;

    l_limit_type_tab       com_api_type_pkg.t_dict_tab;
    l_limit_base_tab       com_api_type_pkg.t_dict_tab;
    l_limit_rate_tab       com_api_type_pkg.t_money_tab;
    l_currency_tab         com_api_type_pkg.t_curr_code_tab;
    l_sum_limit_tab        com_api_type_pkg.t_money_tab;
    l_count_limit_tab      com_api_type_pkg.t_long_tab;
    l_id_tab               com_api_type_pkg.t_long_tab;
    l_next_date_tab        com_api_type_pkg.t_date_tab;
    l_cycle_type_tab       com_api_type_pkg.t_dict_tab;
    l_length_type_tab      com_api_type_pkg.t_dict_tab;
    l_cycle_length_tab     com_api_type_pkg.t_tiny_tab;
    l_start_date_tab       com_api_type_pkg.t_date_tab;
    l_end_date_tab         com_api_type_pkg.t_date_tab;

    l_sum_limit            com_api_type_pkg.t_money;
    l_count_limit          com_api_type_pkg.t_long_id;
    l_sum_current          com_api_type_pkg.t_money;
    l_next_date            date;
    l_limit_usage          com_api_type_pkg.t_dict_value;
    l_flex_data_xml_block  com_api_type_pkg.t_lob_data;
begin
    prc_api_performance_pkg.start_performance_metric(
        i_method_name => l_method_name
      , i_label_name  => l_label_name
    );

    select
        xmlelement("customer"
          , xmlforest(
                case
                    when i_customer_value_type = com_api_type_pkg.TRUE
                    then to_char(m.id)
                    else m.customer_number
                end                       as "customer_number"
              , m.category                as "customer_category"
              , m.relation                as "customer_relation"
              , m.resident                as "resident"
              , m.nationality             as "nationality"
              , m.credit_rating           as "credit_rating"
              , m.money_laundry_risk      as "money_laundry_risk"
              , m.money_laundry_reason    as "money_laundry_reason"
              , m.entity_type             as "entity_type"
              , m.object_id               as "object_id"
            )
        ).getclobval()
      into o_xml_block
      from prd_customer m
     where m.id         = i_customer_id
       and m.split_hash = i_split_hash;

    -- customer flexible fields
    com_api_flexible_data_pkg.generate_xml(
        i_entity_type => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
      , i_standard_id => cmn_api_const_pkg.STANDARD_ID_SV_FRONTEND
      , i_object_id   => i_customer_id
      , o_xml_block   => l_flex_data_xml_block
    );

    o_xml_block := o_xml_block || l_flex_data_xml_block;

    -- customer limits
    l_service_id := prd_api_service_pkg.get_active_service_id(
                       i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                     , i_object_id           => i_customer_id
                     , i_attr_name           => null
                     , i_service_type_id     => prd_api_const_pkg.CUSTOMER_MAINTENANCE_SERVICE
                     , i_split_hash          => i_split_hash
                     , i_eff_date            => i_sysdate
                     , i_mask_error          => com_api_type_pkg.TRUE
                     , i_inst_id             => i_inst_id
                   );

    if l_service_id is not null then

        o_xml_block := substr(o_xml_block, 1, length(o_xml_block) - length('</customer>'));

        select l.limit_type
             , l.limit_base
             , l.limit_rate
             , l.currency
             , l.sum_limit
             , l.count_limit
             , l.id
             , b.next_date
             , b.cycle_type
             , c.length_type
             , c.cycle_length
             , limits.start_date
             , limits.end_date
          bulk collect
          into l_limit_type_tab
             , l_limit_base_tab
             , l_limit_rate_tab
             , l_currency_tab
             , l_sum_limit_tab
             , l_count_limit_tab
             , l_id_tab
             , l_next_date_tab
             , l_cycle_type_tab
             , l_length_type_tab
             , l_cycle_length_tab
             , l_start_date_tab
             , l_end_date_tab
          from (select to_number(limit_id, com_api_const_pkg.NUMBER_FORMAT) limit_id
                     , row_number() over (partition by limit_type order by decode(level_priority, 0, 0, 1)
                                                                                , level_priority
                                                                                , start_date desc
                                                                                , register_timestamp desc) rn
                     , start_date
                     , end_date
                  from (
                        select v.attr_value    as limit_id
                             , 0               as level_priority
                             , a.object_type   as limit_type
                             , v.register_timestamp
                             , v.start_date
                             , v.end_date
                          from prd_attribute_value v
                             , prd_attribute a
                         where v.object_id    = i_customer_id
                           and v.split_hash   = i_split_hash
                           and v.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                           and i_sysdate between nvl(v.start_date, i_sysdate) and nvl(v.end_date, trunc(i_sysdate)+1)
                           and a.id           = v.attr_id
                           and a.entity_type  = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                     union all
                        select attr_value
                             , level_priority
                             , object_type     as limit_type
                             , register_timestamp
                             , start_date
                             , end_date
                          from (select * from table(cast(g_customer_limit_map_tab as prd_product_attr_map_tpt)) where product_id = i_product_id) p
                    ) tt
               ) limits
             , fcl_limit l
             , fcl_cycle c
             , fcl_cycle_counter b
         where limits.rn          = 1
           and l.id               = limits.limit_id
           and c.id(+)            = l.cycle_id
           and b.cycle_type(+)    = c.cycle_type
           and b.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
           and b.object_id(+)     = i_card_id
           and b.split_hash(+)    = i_split_hash;

        o_xml_block := o_xml_block || '<limits>';

        for i in 1 .. l_limit_type_tab.count loop

            if l_limit_base_tab(i) is not null and l_limit_rate_tab(i) is not null then
                fcl_api_limit_pkg.get_limit_border(
                    i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
                  , i_object_id     => i_card_id
                  , i_limit_type    => l_limit_type_tab(i)
                  , i_limit_base    => l_limit_base_tab(i)
                  , i_limit_rate    => l_limit_rate_tab(i)
                  , i_currency      => l_currency_tab(i)
                  , i_inst_id       => i_inst_id
                  , i_product_id    => i_product_id
                  , i_split_hash    => i_split_hash
                  , i_lock_balance  => com_api_type_pkg.FALSE
                  , i_mask_error    => com_api_const_pkg.TRUE
                  , o_border_sum    => l_sum_limit
                  , o_border_cnt    => l_count_limit
                );

                l_sum_limit   := nvl(l_sum_limit,   0);
                l_count_limit := nvl(l_count_limit, 0);
            else
                l_sum_limit   := nvl(l_sum_limit_tab(i),   0);
                l_count_limit := nvl(l_count_limit_tab(i), 0);
            end if;

            l_sum_current := nvl(fcl_api_limit_pkg.get_limit_sum_curr(
                                     i_limit_type  => l_limit_type_tab(i)
                                   , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                   , i_object_id   => i_customer_id
                                   , i_product_id  => i_product_id
                                   , i_limit_id    => l_id_tab(i)
                                   , i_split_hash  => i_split_hash
                                   , i_mask_error  => com_api_const_pkg.TRUE 
                                 ), 0);

            if l_next_date_tab(i) > i_sysdate or l_next_date_tab(i) is null then
                l_next_date := l_next_date_tab(i);
            else
                l_next_date := fcl_api_cycle_pkg.calc_next_date(
                                   i_cycle_type  => l_cycle_type_tab(i)
                                 , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                 , i_object_id   => i_customer_id
                                 , i_split_hash  => i_split_hash
                                 , i_start_date  => i_sysdate
                                 , i_inst_id     => i_inst_id
                                 , i_product_id  => i_product_id
                               );
            end if;

            select nvl(max(t.limit_usage), fcl_api_const_pkg.LIMIT_USAGE_SUM_COUNT)
              into l_limit_usage
              from fcl_limit_type t
             where t.limit_type = l_limit_type_tab(i);

            o_xml_block := o_xml_block
                        || '<limit>'
                        || '<limit_type>'   || l_limit_type_tab(i)              || '</limit_type>'
                        || '<limit_usage>'  || l_limit_usage                    || '</limit_usage>'
                        || '<sum_limit>'    || l_sum_limit                      || '</sum_limit>'
                        || '<count_limit>'  || l_count_limit                    || '</count_limit>'
                        || '<sum_current>'  || l_sum_current                    || '</sum_current>'
                        || '<currency>'     || l_currency_tab(i)                || '</currency>'
                        || '<next_date>'    || to_char(l_next_date, com_api_const_pkg.XML_DATETIME_FORMAT)         || '</next_date>'
                        || '<length_type>'  || l_length_type_tab(i)             || '</length_type>'
                        || '<cycle_length>' || nvl(l_cycle_length_tab(i), 999)  || '</cycle_length>'
                        || '<start_date>'   || to_char(l_start_date_tab(i), com_api_const_pkg.XML_DATETIME_FORMAT) || '</start_date>'
                        || '<end_date>'     || to_char(l_end_date_tab(i),   com_api_const_pkg.XML_DATETIME_FORMAT) || '</end_date>'
                        || '</limit>';

        end loop;

        o_xml_block := o_xml_block || '</limits></customer>';
    end if;

    prc_api_performance_pkg.finish_performance_metric(
        i_method_name => l_method_name
      , i_label_name  => l_label_name
    );

end generate_customer;

procedure generate_card_limits(
    i_inst_id       in     com_api_type_pkg.t_inst_id
  , i_card_id       in     com_api_type_pkg.t_medium_id
  , i_split_hash    in     com_api_type_pkg.t_tiny_id
  , i_product_id    in     com_api_type_pkg.t_short_id
  , i_sysdate       in     date
  , o_xml_block        out nocopy com_api_type_pkg.t_lob_data
)
is
    l_method_name          com_api_type_pkg.t_name := 'generate_card_limits';
    l_label_name           com_api_type_pkg.t_name := 'xml_block';

    l_limit_type_tab       com_api_type_pkg.t_dict_tab;
    l_limit_base_tab       com_api_type_pkg.t_dict_tab;
    l_limit_rate_tab       com_api_type_pkg.t_money_tab;
    l_currency_tab         com_api_type_pkg.t_curr_code_tab;
    l_sum_limit_tab        com_api_type_pkg.t_money_tab;
    l_count_limit_tab      com_api_type_pkg.t_long_tab;
    l_id_tab               com_api_type_pkg.t_long_tab;
    l_next_date_tab        com_api_type_pkg.t_date_tab;
    l_cycle_type_tab       com_api_type_pkg.t_dict_tab;
    l_length_type_tab      com_api_type_pkg.t_dict_tab;
    l_cycle_length_tab     com_api_type_pkg.t_tiny_tab;
    l_start_date_tab       com_api_type_pkg.t_date_tab;
    l_end_date_tab         com_api_type_pkg.t_date_tab;

    l_sum_limit            com_api_type_pkg.t_money;
    l_count_limit          com_api_type_pkg.t_long_id;
    l_sum_current          com_api_type_pkg.t_money;
    l_next_date            date;
    l_limit_usage          com_api_type_pkg.t_dict_value;
begin
    prc_api_performance_pkg.start_performance_metric(
        i_method_name => l_method_name
      , i_label_name  => l_label_name
    );

    select l.limit_type
         , l.limit_base
         , l.limit_rate
         , l.currency
         , l.sum_limit
         , l.count_limit
         , l.id
         , b.next_date
         , b.cycle_type
         , c.length_type
         , c.cycle_length
         , limits.start_date
         , limits.end_date
      bulk collect
      into l_limit_type_tab
         , l_limit_base_tab
         , l_limit_rate_tab
         , l_currency_tab
         , l_sum_limit_tab
         , l_count_limit_tab
         , l_id_tab
         , l_next_date_tab
         , l_cycle_type_tab
         , l_length_type_tab
         , l_cycle_length_tab
         , l_start_date_tab
         , l_end_date_tab
      from (select to_number(limit_id, com_api_const_pkg.NUMBER_FORMAT) limit_id
                 , row_number() over (partition by limit_type order by decode(level_priority, 0, 0, 1)
                                                                            , level_priority
                                                                            , start_date desc
                                                                            , register_timestamp desc) rn
                 , start_date
                 , end_date
              from (
                    select v.attr_value    as limit_id
                         , 0               as level_priority
                         , a.object_type   as limit_type
                         , v.register_timestamp
                         , v.start_date
                         , v.end_date
                      from prd_attribute_value v
                         , prd_attribute a
                     where v.object_id    = i_card_id
                       and v.split_hash   = i_split_hash
                       and v.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
                       and i_sysdate between nvl(v.start_date, i_sysdate) and nvl(v.end_date, trunc(i_sysdate)+1)
                       and a.id           = v.attr_id
                       and a.entity_type  = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                 union all
                    select attr_value
                         , level_priority
                         , object_type     as limit_type
                         , register_timestamp
                         , start_date
                         , end_date
                      from (select * from table(cast(g_card_limit_map_tab as prd_product_attr_map_tpt)) where product_id = i_product_id) p
                ) tt
           ) limits
         , fcl_limit l
         , fcl_cycle c
         , fcl_cycle_counter b
     where limits.rn         = 1
       and l.id              = limits.limit_id
       and c.id(+)           = l.cycle_id
       and b.cycle_type(+)   = c.cycle_type
       and b.entity_type(+)  = iss_api_const_pkg.ENTITY_TYPE_CARD
       and b.object_id(+)    = i_card_id
       and b.split_hash(+)   = i_split_hash;

    o_xml_block := '<limits>';

    for i in 1 .. l_limit_type_tab.count loop

        if l_limit_base_tab(i) is not null and l_limit_rate_tab(i) is not null then
            fcl_api_limit_pkg.get_limit_border(
                i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id     => i_card_id
              , i_limit_type    => l_limit_type_tab(i)
              , i_limit_base    => l_limit_base_tab(i)
              , i_limit_rate    => l_limit_rate_tab(i)
              , i_currency      => l_currency_tab(i)
              , i_inst_id       => i_inst_id
              , i_product_id    => i_product_id
              , i_split_hash    => i_split_hash
              , i_lock_balance  => com_api_type_pkg.FALSE
              , i_mask_error    => com_api_const_pkg.TRUE
              , o_border_sum    => l_sum_limit
              , o_border_cnt    => l_count_limit
            );

            l_sum_limit   := nvl(l_sum_limit,   0);
            l_count_limit := nvl(l_count_limit, 0);
        else
            l_sum_limit   := nvl(l_sum_limit_tab(i),   0);
            l_count_limit := nvl(l_count_limit_tab(i), 0);
        end if;

        l_sum_current := nvl(fcl_api_limit_pkg.get_limit_sum_curr(
                                 i_limit_type  => l_limit_type_tab(i)
                               , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
                               , i_object_id   => i_card_id
                               , i_product_id  => i_product_id
                               , i_limit_id    => l_id_tab(i)
                               , i_split_hash  => i_split_hash
                             ), 0);

        if l_next_date_tab(i) > i_sysdate or l_next_date_tab(i) is null then
            l_next_date := l_next_date_tab(i);
        else
            l_next_date := fcl_api_cycle_pkg.calc_next_date(
                               i_cycle_type  => l_cycle_type_tab(i)
                             , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
                             , i_object_id   => i_card_id
                             , i_split_hash  => i_split_hash
                             , i_start_date  => i_sysdate
                             , i_inst_id     => i_inst_id
                             , i_product_id  => i_product_id
                           );
        end if;

        select nvl(max(t.limit_usage), fcl_api_const_pkg.LIMIT_USAGE_SUM_COUNT)
          into l_limit_usage
          from fcl_limit_type t
         where t.limit_type = l_limit_type_tab(i);

        o_xml_block := o_xml_block
                    || '<limit>'
                    || '<limit_type>'   || l_limit_type_tab(i)              || '</limit_type>'
                    || '<limit_usage>'  || l_limit_usage                    || '</limit_usage>'
                    || '<sum_limit>'    || l_sum_limit                      || '</sum_limit>'
                    || '<count_limit>'  || l_count_limit                    || '</count_limit>'
                    || '<sum_current>'  || l_sum_current                    || '</sum_current>'
                    || '<currency>'     || l_currency_tab(i)                || '</currency>'
                    || '<next_date>'    || to_char(l_next_date, com_api_const_pkg.XML_DATETIME_FORMAT)         || '</next_date>'
                    || '<length_type>'  || l_length_type_tab(i)             || '</length_type>'
                    || '<cycle_length>' || nvl(l_cycle_length_tab(i), 999)  || '</cycle_length>'
                    || '<start_date>'   || to_char(l_start_date_tab(i), com_api_const_pkg.XML_DATETIME_FORMAT) || '</start_date>'
                    || '<end_date>'     || to_char(l_end_date_tab(i),   com_api_const_pkg.XML_DATETIME_FORMAT) || '</end_date>'
                    || '</limit>';

    end loop;

    o_xml_block := o_xml_block || '</limits>';

    prc_api_performance_pkg.finish_performance_metric(
        i_method_name => l_method_name
      , i_label_name  => l_label_name
    );

end generate_card_limits;

procedure generate_services(
    i_full_export     in     com_api_type_pkg.t_boolean
  , i_card_id         in     com_api_type_pkg.t_medium_id
  , i_split_hash      in     com_api_type_pkg.t_tiny_id
  , i_product_id      in     com_api_type_pkg.t_short_id
  , i_sysdate         in     date
  , o_xml_block          out nocopy com_api_type_pkg.t_lob_data
)
is
    l_method_name          com_api_type_pkg.t_name := 'generate_services';
    l_label_name           com_api_type_pkg.t_name := 'xml_block';
begin
    prc_api_performance_pkg.start_performance_metric(
        i_method_name => l_method_name
      , i_label_name  => l_label_name
    );

    if i_full_export = com_api_type_pkg.TRUE then

        select xmlagg(
               xmlelement("service"
                 , xmlelement("service_type",          s.service_type_id)
                 , xmlelement("service_type_name",     s.service_type_name)
                 , xmlelement("service_external_code", nvl(s.external_code, s.service_type_id))
                 , xmlelement("service_number",        s.service_number)
                 , xmlelement("is_active",             s.is_active)
                 , (
                       select xmlagg(
                                  xmlelement("service_attribute"
                                    , xmlelement("service_attribute_name",  attr.attr_name)
                                    , xmlelement("service_attribute_value", attr.attr_value)
                                  )
                              )
                         from (
                             select attr_value
                                  , row_number() over (partition by card_id, attr_name
                                                           order by decode(level_priority, 0, 0, 1)
                                                                  , level_priority
                                                                  , start_date desc
                                                                  , register_timestamp desc) rn
                                  , card_id
                                  , split_hash
                                  , attr_name
                                  , service_id
                               from (
                                   select v.attr_value
                                        , 0 level_priority
                                        , a.object_type
                                        , v.register_timestamp
                                        , v.start_date
                                        , v.object_id as card_id
                                        , v.split_hash
                                        , a.attr_name
                                        , v.service_id
                                     from prd_attribute_value v
                                        , prd_attribute a
                                    where v.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
                                      and a.id           = v.attr_id
                                      and a.entity_type  is null
                                      and a.data_type    = com_api_const_pkg.DATA_TYPE_CHAR
                                      and i_sysdate between nvl(v.start_date, i_sysdate)
                                                        and nvl(v.end_date,   trunc(i_sysdate)+1)
                                      and v.service_id in (select id from table(cast(g_service_id_tab as prd_service_tpt)))
                                union all
                                   select v.attr_value
                                        , p.level_priority
                                        , a.object_type
                                        , v.register_timestamp
                                        , v.start_date
                                        , ac.id  card_id
                                        , ac.split_hash
                                        , a.attr_name
                                        , v.service_id
                                     from (select * from table(cast(g_product_tab as prd_product_tpt)) where product_id = i_product_id) p
                                        , prd_attribute_value v
                                        , prd_attribute a
                                        , (select distinct id, service_type_id
                                             from table(cast(g_service_id_tab as prd_service_tpt))
                                          ) srv
                                        , prd_product_service ps
                                        , prd_contract c
                                        , iss_card ac
                                    where v.service_id      = srv.id
                                      and v.object_id       = decode(a.definition_level, 'SADLSRVC', srv.id, p.parent_id)
                                      and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(p.top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                      and v.attr_id         = a.id
                                      and i_sysdate between nvl(v.start_date, i_sysdate) and nvl(v.end_date, trunc(i_sysdate)+1)
                                      and a.service_type_id = srv.service_type_id
                                      and a.entity_type    is null
                                      and a.data_type       = com_api_const_pkg.DATA_TYPE_CHAR
                                      and p.product_id      = ps.product_id
                                      and ps.service_id     = v.service_id
                                      and srv.id            = ps.service_id
                                      and ps.product_id     = c.product_id
                                      and c.id              = ac.contract_id
                                      and c.split_hash      = ac.split_hash
                               ) tt
                         ) attr
                        where attr.rn         = 1
                          and attr.service_id = s.id
                          and attr.card_id    = b.object_id
                          and attr.split_hash = b.split_hash
                   )
               ) -- xmlelement("service", ...
               ).getclobval() -- xmlagg
              into o_xml_block
              from table(cast(g_service_id_tab as prd_service_tpt)) s
                 , prd_service_object b
             where b.service_id    = s.id
               and b.object_id     = i_card_id
               and b.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD
               and b.split_hash    = i_split_hash;

    else

        select xmlagg(
               xmlelement("service"
                 , xmlelement("service_type",          s.service_type_id)
                 , xmlelement("service_type_name",     s.service_type_name)
                 , xmlelement("service_external_code", nvl(s.external_code, s.service_type_id))
                 , xmlelement("service_number",        s.service_number)
                 , xmlelement("is_active",             s.is_active)
                 , (
                       select xmlagg(
                                  xmlelement("service_attribute"
                                    , xmlelement("service_attribute_name",   attr.attr_name)
                                    , xmlelement("service_attribute_value",  attr.attr_value)
                                  )
                              )
                         from (
                             select attr_value
                                  , row_number() over (partition by card_id, attr_name
                                                           order by decode(level_priority, 0, 0, 1)
                                                                         , level_priority
                                                                         , start_date desc
                                                                         , register_timestamp desc) rn
                                  , card_id
                                  , split_hash
                                  , attr_name
                                  , service_id
                               from (
                                   select v.attr_value
                                        , 0 level_priority
                                        , a.object_type
                                        , v.register_timestamp
                                        , v.start_date
                                        , v.object_id  card_id
                                        , v.split_hash
                                        , a.attr_name
                                        , v.service_id
                                     from prd_attribute_value v
                                        , prd_attribute a
                                    where v.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
                                      and a.id           = v.attr_id
                                      and a.entity_type  is null
                                      and a.data_type    = com_api_const_pkg.DATA_TYPE_CHAR --'DTTPCHAR'
                                      and i_sysdate between nvl(v.start_date, i_sysdate) and nvl(v.end_date, trunc(i_sysdate)+1)
                                      and v.service_id in (select id from table(cast(g_service_id_tab as prd_service_tpt)))
                                union all
                                   select v.attr_value
                                        , p.level_priority
                                        , a.object_type
                                        , v.register_timestamp
                                        , v.start_date
                                        , ac.id  card_id
                                        , ac.split_hash
                                        , a.attr_name
                                        , v.service_id
                                     from (select * from table(cast(g_product_tab as prd_product_tpt)) where product_id = i_product_id) p
                                        , prd_attribute_value v
                                        , prd_attribute a
                                        , (select distinct id, service_type_id
                                             from table(cast(g_service_id_tab as prd_service_tpt))
                                          ) srv
                                        , prd_product_service ps
                                        , prd_contract c
                                        , iss_card ac
                                    where v.service_id      = srv.id
                                      and v.object_id       = decode(a.definition_level, 'SADLSRVC', srv.id, p.parent_id)
                                      and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(p.top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                      and v.attr_id         = a.id
                                      and i_sysdate between nvl(v.start_date, i_sysdate) and nvl(v.end_date, trunc(i_sysdate)+1)
                                      and a.service_type_id = srv.service_type_id
                                      and a.entity_type    is null
                                      and a.data_type       = com_api_const_pkg.DATA_TYPE_CHAR --'DTTPCHAR'
                                      and p.product_id      = ps.product_id
                                      and ps.service_id     = v.service_id
                                      and srv.id            = ps.service_id
                                      and ps.product_id     = c.product_id
                                      and c.id              = ac.contract_id
                                      and c.split_hash      = ac.split_hash
                               ) tt
                         ) attr
                        where attr.rn         = 1
                          and attr.service_id = s.id
                          and attr.card_id    = b.object_id
                          and attr.split_hash = b.split_hash
                   )
               ) -- xmlelement("service", ...
               ).getclobval() -- xmlagg
              into o_xml_block
              from evt_event_object o
                 , table(cast(g_service_id_tab as prd_service_tpt)) s
                 , prd_service_object b
             where o.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD
               and o.object_id     = i_card_id
               and o.split_hash    = i_split_hash
               and o.eff_date     <= i_sysdate
               and o.status        = evt_api_const_pkg.EVENT_STATUS_READY
               and s.event_type    = o.event_type
               and s.id            = b.service_id
               and o.object_id     = b.object_id
               and o.entity_type   = b.entity_type
               and o.split_hash    = b.split_hash;

    end if;

    prc_api_performance_pkg.finish_performance_metric(
        i_method_name => l_method_name
      , i_label_name  => l_label_name
    );

end generate_services;

procedure generate_notifications(
    i_subscriber_name  in     com_api_type_pkg.t_name
  , i_inst_id          in     com_api_type_pkg.t_inst_id
  , i_card_id          in     com_api_type_pkg.t_medium_id
  , i_cardholder_id    in     com_api_type_pkg.t_medium_id
  , i_split_hash       in     com_api_type_pkg.t_tiny_id
  , i_sysdate          in     date
  , o_xml_block           out nocopy com_api_type_pkg.t_lob_data
)
is
    l_method_name             com_api_type_pkg.t_name := 'generate_notifications';
    l_label_name              com_api_type_pkg.t_name := 'xml_block';

    l_service_id              com_api_type_pkg.t_short_id;
    l_service_number          com_api_type_pkg.t_name;
    l_is_active_service       com_api_type_pkg.t_boolean    := com_api_type_pkg.FALSE;
    l_is_notification         com_api_type_pkg.t_boolean    := com_api_type_pkg.FALSE;

    l_start_date_tab          com_api_type_pkg.t_date_tab;
    l_end_date_tab            com_api_type_pkg.t_date_tab;
    l_notification_event_tab  com_api_type_pkg.t_dict_tab;
    l_delivery_channel_tab    com_api_type_pkg.t_tiny_tab;
    l_delivery_address_tab    com_api_type_pkg.t_desc_tab;
    l_is_active_tab           com_api_type_pkg.t_boolean_tab;
begin
    prc_api_performance_pkg.start_performance_metric(
        i_method_name => l_method_name
      , i_label_name  => l_label_name
    );

    l_service_id := prd_api_service_pkg.get_active_service_id(
                        i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CARD
                      , i_object_id           => i_card_id
                      , i_attr_name           => ntf_api_const_pkg.NOTIFICATION_SERVICE_USE_FEE
                      , i_service_type_id     => ntf_api_const_pkg.NOTIFICATION_CARD_SERVICE
                      , i_split_hash          => i_split_hash
                      , i_eff_date            => i_sysdate
                      , i_mask_error          => com_api_type_pkg.TRUE
                      , i_inst_id             => i_inst_id
                    );

    if l_service_id is not null then
        l_is_active_service := com_api_type_pkg.TRUE;
        l_is_notification   := com_api_type_pkg.TRUE;

    else

        l_service_id := prd_api_service_pkg.get_active_service_id(
                            i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CARD
                          , i_object_id           => i_card_id
                          , i_attr_name           => ntf_api_const_pkg.NOTIFICATION_SERVICE_USE_FEE
                          , i_service_type_id     => ntf_api_const_pkg.NOTIFICATION_CARD_SERVICE
                          , i_split_hash          => i_split_hash
                          , i_eff_date            => i_sysdate
                          , i_last_active         => com_api_type_pkg.TRUE
                          , i_mask_error          => com_api_type_pkg.TRUE
                          , i_inst_id             => i_inst_id
                        );

        select count(*)
          into l_is_notification
          from evt_event_object  eo
         where eo.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
           and eo.object_id       = i_card_id
           and eo.split_hash      = i_split_hash
           and eo.procedure_name  = i_subscriber_name
           and eo.status          = evt_api_const_pkg.EVENT_STATUS_READY
           and eo.eff_date       <= i_sysdate
           and eo.event_type      = iss_api_const_pkg.EVENT_NOTIF_DEACTIVATION   -- close notification service
           and rownum             = 1;

    end if;

    if l_is_notification = com_api_type_pkg.TRUE then

        select case
                   when l_is_active_service = com_api_type_pkg.TRUE
                   then nvl(n.event_type, aut_api_const_pkg.EVENT_AUTH_BY_CARD)
                   else iss_api_const_pkg.EVENT_NOTIF_DEACTIVATION   -- close notification service
               end
             , n.start_date
             , n.end_date
             , n.channel_id
             , n.delivery_address
             , case
                   when l_is_active_service = com_api_type_pkg.TRUE
                   then coalesce(
                            co.is_active
                          , case
                                when n.status = ntf_api_const_pkg.STATUS_DO_NOT_SEND
                                then com_api_type_pkg.FALSE
                                else com_api_type_pkg.TRUE
                            end
                        )
                   else com_api_type_pkg.FALSE
               end
          bulk collect
          into l_notification_event_tab
             , l_start_date_tab
             , l_end_date_tab
             , l_delivery_channel_tab
             , l_delivery_address_tab
             , l_is_active_tab
          from ntf_custom_event  n
             , ntf_custom_object co
         where n.entity_type       = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
           and n.object_id         = i_cardholder_id
           and (n.event_type      is null or n.event_type != iss_api_const_pkg.EVENT_3D_SECURE_AUTH_REQUEST)
           and co.custom_event_id  = n.id
           and co.entity_type      = iss_api_const_pkg.ENTITY_TYPE_CARD
           and co.object_id        = i_card_id;

        if l_notification_event_tab.count = 0 then
            select case
                       when l_is_active_service = com_api_type_pkg.TRUE
                       then aut_api_const_pkg.EVENT_AUTH_BY_CARD
                       else iss_api_const_pkg.EVENT_NOTIF_DEACTIVATION   -- close notification service
                   end
                 , d.start_date
                 , d.end_date
                 , null
                 , d.commun_address
                 , l_is_active_service
              bulk collect
              into l_notification_event_tab
                 , l_start_date_tab
                 , l_end_date_tab
                 , l_delivery_channel_tab
                 , l_delivery_address_tab
                 , l_is_active_tab
              from com_contact_object o
                 , com_contact_data   d
             where o.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
               and o.object_id      = i_cardholder_id
               and o.contact_type   = com_api_const_pkg.CONTACT_TYPE_NOTIFICATION
               and d.contact_id     = o.contact_id
               and d.commun_method  = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
               and (d.end_date     is null or d.end_date > i_sysdate);

        end if;

        if l_notification_event_tab.count > 0 then

            select s.service_number
              into l_service_number
              from prd_service s
             where s.id = l_service_id;

            o_xml_block := '<notification>';

            for i in 1 .. l_notification_event_tab.count loop
                o_xml_block := o_xml_block || '<service_id>'         || l_service_id                || '</service_id>'
                                           || '<service_number>'     || l_service_number            || '</service_number>'
                                           || '<start_date>' || to_char(l_start_date_tab(i), com_api_const_pkg.XML_DATE_FORMAT) || '</start_date>'
                                           || '<end_date>'   || to_char(l_end_date_tab(i),   com_api_const_pkg.XML_DATE_FORMAT) || '</end_date>'
                                           || '<notification_event>' || l_notification_event_tab(i) || '</notification_event>'
                                           || '<delivery_channel>'   || l_delivery_channel_tab(i)   || '</delivery_channel>'
                                           || '<delivery_address>'   || l_delivery_address_tab(i)   || '</delivery_address>'
                                           || '<is_active>'          || l_is_active_tab(i)          || '</is_active>';
            end loop;

            o_xml_block := o_xml_block || '</notification>';

        end if;
    end if;

    prc_api_performance_pkg.finish_performance_metric(
        i_method_name => l_method_name
      , i_label_name  => l_label_name
    );

end generate_notifications;

procedure generate_3d_secure(
    i_subscriber_name  in     com_api_type_pkg.t_name
  , i_inst_id          in     com_api_type_pkg.t_inst_id
  , i_card_id          in     com_api_type_pkg.t_medium_id
  , i_cardholder_id    in     com_api_type_pkg.t_medium_id
  , i_customer_id      in     com_api_type_pkg.t_medium_id
  , i_product_id       in     com_api_type_pkg.t_short_id
  , i_split_hash       in     com_api_type_pkg.t_tiny_id
  , i_sysdate          in     date
  , o_xml_block           out nocopy com_api_type_pkg.t_lob_data
)
is
    l_method_name             com_api_type_pkg.t_name := 'generate_3d_secure';
    l_label_name              com_api_type_pkg.t_name := 'xml_block';

    l_service_id              com_api_type_pkg.t_short_id;
    l_service_number          com_api_type_pkg.t_name;
    l_scheme_id               com_api_type_pkg.t_tiny_id;
    l_is_active_service       com_api_type_pkg.t_boolean    := com_api_type_pkg.FALSE;
    l_is_notification         com_api_type_pkg.t_boolean    := com_api_type_pkg.FALSE;
    l_exists_scheme_id        com_api_type_pkg.t_boolean    := com_api_type_pkg.FALSE;

    l_start_date_tab          com_api_type_pkg.t_date_tab;
    l_end_date_tab            com_api_type_pkg.t_date_tab;
    l_notification_event_tab  com_api_type_pkg.t_dict_tab;
    l_delivery_channel_tab    com_api_type_pkg.t_tiny_tab;
    l_delivery_address_tab    com_api_type_pkg.t_desc_tab;
    l_is_active_tab           com_api_type_pkg.t_boolean_tab;
begin
    prc_api_performance_pkg.start_performance_metric(
        i_method_name => l_method_name
      , i_label_name  => l_label_name
    );

    l_scheme_id  := prd_api_product_pkg.get_attr_value_number(
                        i_entity_type     => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                      , i_object_id       => i_customer_id
                      , i_attr_name       => 'NOTIFICATION_SCHEME'
                      , i_split_hash      => i_split_hash
                      , i_inst_id         => i_inst_id
                      , i_product_id      => i_product_id
                      , i_mask_error      => com_api_type_pkg.TRUE
                    );

    if l_scheme_id is not null then
        if g_scheme_id_tab.exists(l_scheme_id) then
            l_exists_scheme_id := g_scheme_id_tab(l_scheme_id);
        else
            select nvl(max(com_api_type_pkg.TRUE), com_api_type_pkg.FALSE)
              into l_exists_scheme_id
              from ntf_scheme_event e
             where e.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
               and e.event_type  = iss_api_const_pkg.EVENT_3D_SECURE_AUTH_REQUEST
               and e.scheme_id   = l_scheme_id;

            g_scheme_id_tab(l_scheme_id) := l_exists_scheme_id;
        end if;
    end if;

    if l_exists_scheme_id = com_api_type_pkg.TRUE then

        l_service_id := prd_api_service_pkg.get_active_service_id(
                            i_entity_type     => iss_api_const_pkg.ENTITY_TYPE_CARD
                          , i_object_id       => i_card_id
                          , i_attr_name       => null
                          , i_service_type_id => ntf_api_const_pkg.THREE_D_SECURE_CARD_SERVICE
                          , i_split_hash      => i_split_hash
                          , i_eff_date        => i_sysdate
                          , i_mask_error      => com_api_type_pkg.TRUE
                          , i_inst_id         => i_inst_id
                        );

        if l_service_id is not null then
            l_is_active_service := com_api_type_pkg.TRUE;
            l_is_notification   := com_api_type_pkg.TRUE;

        else

            l_service_id := prd_api_service_pkg.get_active_service_id(
                                i_entity_type     => iss_api_const_pkg.ENTITY_TYPE_CARD
                              , i_object_id       => i_card_id
                              , i_attr_name       => null
                              , i_service_type_id => ntf_api_const_pkg.THREE_D_SECURE_CARD_SERVICE
                              , i_split_hash      => i_split_hash
                              , i_eff_date        => i_sysdate
                              , i_last_active     => com_api_type_pkg.TRUE
                              , i_mask_error      => com_api_type_pkg.TRUE
                              , i_inst_id         => i_inst_id
                            );

            select count(*)
              into l_is_notification
              from evt_event_object  eo
             where eo.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
               and eo.object_id       = i_card_id
               and eo.split_hash      = i_split_hash
               and eo.procedure_name  = i_subscriber_name
               and eo.status          = evt_api_const_pkg.EVENT_STATUS_READY
               and eo.eff_date       <= i_sysdate
               and eo.event_type      = iss_api_const_pkg.EVENT_3D_SECURE_DEACTIVATION  -- close 3d secure service
               and rownum             = 1;

        end if;

        if l_is_notification = com_api_type_pkg.TRUE then

            select case
                       when l_is_active_service = com_api_type_pkg.TRUE
                       then iss_api_const_pkg.EVENT_3D_SECURE_AUTH_REQUEST
                       else iss_api_const_pkg.EVENT_3D_SECURE_DEACTIVATION  -- close 3d secure service
                   end
                 , n.start_date
                 , n.end_date
                 , n.channel_id
                 , n.delivery_address
                 , case
                       when l_is_active_service = com_api_type_pkg.TRUE
                       then coalesce(
                                co.is_active
                              , case
                                    when n.status = ntf_api_const_pkg.STATUS_DO_NOT_SEND
                                    then com_api_type_pkg.FALSE
                                    else com_api_type_pkg.TRUE
                                end
                            )
                       else com_api_type_pkg.FALSE
                   end
              bulk collect
              into l_notification_event_tab
                 , l_start_date_tab
                 , l_end_date_tab
                 , l_delivery_channel_tab
                 , l_delivery_address_tab
                 , l_is_active_tab
              from ntf_custom_event  n
                 , ntf_custom_object co
             where n.entity_type       = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
               and n.object_id         = i_cardholder_id
               and (n.event_type      is null or n.event_type = iss_api_const_pkg.EVENT_3D_SECURE_AUTH_REQUEST)
               and co.custom_event_id  = n.id
               and co.entity_type      = iss_api_const_pkg.ENTITY_TYPE_CARD
               and co.object_id        = i_card_id;

            if l_notification_event_tab.count = 0 then
                select case
                           when l_is_active_service = com_api_type_pkg.TRUE
                           then iss_api_const_pkg.EVENT_3D_SECURE_AUTH_REQUEST
                           else iss_api_const_pkg.EVENT_3D_SECURE_DEACTIVATION  -- close 3d secure service
                       end
                     , d.start_date
                     , d.end_date
                     , null
                     , d.commun_address
                     , l_is_active_service
                  bulk collect
                  into l_notification_event_tab
                     , l_start_date_tab
                     , l_end_date_tab
                     , l_delivery_channel_tab
                     , l_delivery_address_tab
                     , l_is_active_tab
                  from com_contact_object o
                     , com_contact_data   d
                 where o.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                   and o.object_id      = i_cardholder_id
                   and o.contact_type   = com_api_const_pkg.CONTACT_TYPE_NOTIFICATION
                   and d.contact_id     = o.contact_id
                   and d.commun_method  = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                   and (d.end_date     is null or d.end_date > i_sysdate);

            end if;

            if l_notification_event_tab.count > 0 then

                select s.service_number
                  into l_service_number
                  from prd_service s
                 where s.id = l_service_id;

                o_xml_block := '<notification>';

                for i in 1 .. l_notification_event_tab.count loop
                    o_xml_block := o_xml_block || '<service_id>'         || l_service_id                || '</service_id>'
                                               || '<service_number>'     || l_service_number            || '</service_number>'
                                               || '<start_date>' || to_char(l_start_date_tab(i), com_api_const_pkg.XML_DATE_FORMAT) || '</start_date>'
                                               || '<end_date>'   || to_char(l_end_date_tab(i),   com_api_const_pkg.XML_DATE_FORMAT) || '</end_date>'
                                               || '<notification_event>' || l_notification_event_tab(i) || '</notification_event>'
                                               || '<delivery_channel>'   || l_delivery_channel_tab(i)   || '</delivery_channel>'
                                               || '<delivery_address>'   || l_delivery_address_tab(i)   || '</delivery_address>'
                                               || '<is_active>'          || l_is_active_tab(i)          || '</is_active>';
                end loop;

                o_xml_block := o_xml_block || '</notification>';

            end if;
        end if;
    end if;

    prc_api_performance_pkg.finish_performance_metric(
        i_method_name => l_method_name
      , i_label_name  => l_label_name
    );

end generate_3d_secure;

procedure generate_account(
    i_subscriber_name       in     com_api_type_pkg.t_name
  , i_card_id               in     com_api_type_pkg.t_medium_id
  , i_split_hash            in     com_api_type_pkg.t_tiny_id
  , i_array_account_type    in     com_api_type_pkg.t_dict_value
  , i_sysdate               in     date
  , o_xml_block                out nocopy com_api_type_pkg.t_lob_data
)
is
    l_method_name          com_api_type_pkg.t_name := 'generate_account';
    l_label_name           com_api_type_pkg.t_name := 'xml_block';
begin
    prc_api_performance_pkg.start_performance_metric(
        i_method_name => l_method_name
      , i_label_name  => l_label_name
    );

    select xmlagg(
               xmlelement("account",
                   xmlforest(
                       ac.account_number      as "account_number"
                     , ac.currency            as "currency"
                     , ac.account_type        as "account_type"
                     , ac.status              as "account_status"
                     , ac.is_pos_default      as "is_pos_default"
                     , ac.is_atm_default      as "is_atm_default"
                     , ac.is_atm_currency     as "is_atm_currency"
                     , ac.is_pos_currency     as "is_pos_currency"
                     , ac.account_seq_number  as "account_seq_number"
                     , ac.link_flag           as "link_flag"
                   )
               )
               order by link_flag
           ).getclobval()
      into o_xml_block
      from (
              select a.account_number
                   , a.currency
                   , a.account_type
                   , a.status
                   , ao.is_pos_default
                   , ao.is_atm_default
                   , ao.is_atm_currency
                   , ao.is_pos_currency
                   , ao.account_seq_number
                   , 1 as link_flag
                from acc_account_object ao
                   , acc_account a
               where ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                 and ao.object_id   = i_card_id
                 and ao.split_hash  = i_split_hash
                 and a.id           = ao.account_id
                 and a.split_hash   = ao.split_hash
                 and (i_array_account_type is null
                      or
                      a.account_type in (select element_value from com_array_element el where el.array_id = i_array_account_type))
              union all
              select distinct
                     a.account_number
                   , a.currency
                   , a.account_type
                   , a.status
                   , u.is_pos_default
                   , u.is_atm_default
                   , u.is_atm_currency
                   , u.is_pos_currency
                   , null as account_seq_number
                   , 0    as link_flag
                from acc_unlink_account u
                   , acc_account a
               where u.object_id       = i_card_id
                 and u.split_hash      = i_split_hash
                 and a.id              = u.account_id
                 and a.split_hash      = u.split_hash
                 and (i_array_account_type is null
                      or
                      a.account_type in (select element_value from com_array_element el where el.array_id = i_array_account_type))
                 and not exists (
                         select 1
                           from acc_account_object ao
                          where ao.entity_type = u.entity_type
                            and ao.object_id   = u.object_id
                            and ao.account_id  = u.account_id
                            and ao.split_hash  = u.split_hash
                     )
                 and nvl(u.unlink_date, i_sysdate) >= (
                         select min(eo.eff_date)
                           from evt_event_object eo
                          where eo.object_id      = i_card_id
                            and eo.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
                            and eo.split_hash     = i_split_hash
                            and eo.procedure_name = i_subscriber_name
                            and eo.status         = evt_api_const_pkg.EVENT_STATUS_READY
                            and eo.event_type     = iss_api_const_pkg.EVENT_UNLINK_ACCOUNT_FROM_CARD
                     ) 
           ) ac;

    prc_api_performance_pkg.finish_performance_metric(
        i_method_name => l_method_name
      , i_label_name  => l_label_name
    );

end generate_account;

-- get all object limits for all products
procedure get_object_limit_list(
    i_object_type          in     com_api_type_pkg.t_dict_value
  , i_inst_id              in     com_api_type_pkg.t_inst_id
  , i_sysdate              in     date
  , o_object_attr_map_tab     out nocopy prd_product_attr_map_tpt
) is
begin
      select prd_product_attr_map_tpr(
                 p.product_id
               , v.attr_value
               , p.level_priority
               , a.object_type
               , v.register_timestamp
               , v.start_date
               , v.end_date
             )
        bulk collect into o_object_attr_map_tab
        from (
              select connect_by_root id as product_id
                   , level              as level_priority
                   , pr.id              as parent_id
                   , split_hash
                   , case when pr.parent_id is null then 1 else 0 end as top_flag
                from prd_product pr
               where pr.inst_id = i_inst_id
               connect by prior pr.parent_id = pr.id
             ) p
           , prd_product_service ps
           , prd_service s
           , prd_service_type st
           , prd_attribute a
           , prd_attribute_value v
       where ps.product_id     = p.product_id
         and s.id              = ps.service_id
         and st.id             = s.service_type_id
         and st.entity_type    = i_object_type
         and a.service_type_id = s.service_type_id
         and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
         and v.entity_type     = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
         and v.object_id       = p.parent_id
         and v.attr_id         = a.id
         and v.service_id      = s.id
         and v.split_hash      = p.split_hash
         and i_sysdate between nvl(v.start_date, i_sysdate) and nvl(v.end_date, trunc(i_sysdate)+1);

end get_object_limit_list;

/*
 * It returns XML structure with card limits, it is for using in SQL-query.
 */
procedure export_cards_numbers(
    i_full_export                in     com_api_type_pkg.t_boolean       default null
  , i_event_type                 in     com_api_type_pkg.t_dict_value    default null
  , i_include_address            in     com_api_type_pkg.t_boolean       default null
  , i_include_limits             in     com_api_type_pkg.t_boolean       default null
  , i_export_clear_pan           in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_inst_id                    in     com_api_type_pkg.t_inst_id
  , i_count                      in     com_api_type_pkg.t_count
  , i_include_notif              in     com_api_type_pkg.t_boolean       default null
  , i_subscriber_name            in     com_api_type_pkg.t_name          default null
  , i_include_contact            in     com_api_type_pkg.t_boolean       default null
  , i_lang                       in     com_api_type_pkg.t_dict_value    default null
  , i_ids_type                   in     com_api_type_pkg.t_dict_value    default null
  , i_exclude_npz_cards          in     com_api_type_pkg.t_boolean       default null
  , i_include_service            in     com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
  , i_array_account_type         in     com_api_type_pkg.t_dict_value    default null
  , i_replace_inst_id_by_number  in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) is
    DEFAULT_PROCEDURE_NAME         constant com_api_type_pkg.t_name  := 'ISS_PRC_EXPORT_PKG.EXPORT_CARDS_NUMBERS';

    -- Default bulk size for <card_info> blocks per a file if <i_count> parameter is not specified
    DEFAULT_BULK_LIMIT             constant com_api_type_pkg.t_count := 2000;
    l_bulk_limit                   com_api_type_pkg.t_count          := nvl(i_count, DEFAULT_BULK_LIMIT);
    l_estimated_count              com_api_type_pkg.t_long_id;
    l_processed_count              com_api_type_pkg.t_count          := 0;
    l_file_count                   com_api_type_pkg.t_count          := 0;
    l_file                         clob;

    l_subscriber_name              com_api_type_pkg.t_name           := upper(nvl(i_subscriber_name, DEFAULT_PROCEDURE_NAME));
    l_full_export                  com_api_type_pkg.t_boolean        := nvl(i_full_export,           com_api_type_pkg.FALSE);
    l_export_clear_pan             com_api_type_pkg.t_boolean        := nvl(i_export_clear_pan,      com_api_type_pkg.TRUE);
    l_exclude_npz_cards            com_api_type_pkg.t_boolean        := nvl(i_exclude_npz_cards,     com_api_type_pkg.FALSE);

    l_include_limits               com_api_type_pkg.t_boolean        := nvl(i_include_limits,        com_api_type_pkg.FALSE);
    l_include_service              com_api_type_pkg.t_boolean        := nvl(i_include_service,       com_api_type_pkg.FALSE);
    l_include_notif                com_api_type_pkg.t_boolean        := nvl(i_include_notif,         com_api_type_pkg.FALSE);

    l_customer_value_type          com_api_type_pkg.t_boolean        := com_api_type_pkg.FALSE;

    l_fetched_event_object_id_tab  com_api_type_pkg.t_number_tab;
    l_fetched_instance_id_tab      num_tab_tpt                       := num_tab_tpt();
    l_fetched_split_hash_tab       com_api_type_pkg.t_number_tab;

    l_event_object_id_tab          com_api_type_pkg.t_number_tab;
    l_instance_id_tab              num_tab_tpt                       := num_tab_tpt();
    l_notif_event_tab              com_api_type_pkg.t_number_tab;

    l_fetched_product_event_id_tab num_tab_tpt                       := num_tab_tpt();
    l_fetched_product_id_tab       num_tab_tpt                       := num_tab_tpt();

    l_saved_product_event_id_tab   num_tab_tpt                       := num_tab_tpt();
    l_saved_product_id_tab         num_tab_tpt                       := num_tab_tpt();

    l_instance_id                  com_api_type_pkg.t_medium_id;
    l_sysdate                      date;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_thread_number                com_api_type_pkg.t_tiny_id;

    cursor cur_xml is
        select crd.inst_id           as inst_id
             , crd.id                as card_id
             , crd.customer_id       as customer_id
             , crd.split_hash        as split_hash
             , pr.id                 as product_id
             , crd.cardholder_id     as cardholder_id
             , ci.is_last_seq_number
             , ci.state              as card_state
             , xmlconcat(
                    xmlforest(
                        case l_export_clear_pan
                            when com_api_const_pkg.FALSE
                            then crd.card_number
                            else iss_api_token_pkg.decode_card_number(i_card_number => crd.card_number)
                        end as "card_number"
                      , crd.card_mask                 as "card_mask"
                      , ci.card_uid                   as "card_id"
                      , to_char(ci.start_date, com_api_const_pkg.XML_DATE_FORMAT) as "card_iss_date"
                      , to_char(ci.start_date, com_api_const_pkg.XML_DATE_FORMAT) as "card_start_date"
                      , to_char(ci.expir_date, com_api_const_pkg.XML_DATE_FORMAT) as "expiration_date"
                      , ci.id                         as "instance_id"
                      , ci.preceding_card_instance_id as "preceding_instance_id"
                        -- Card's sequential number (for block FF41 of CREF)
                      , ci.seq_number                 as "sequential_number"
                      , ci.status                     as "card_status"
                      , evt_api_status_pkg.get_status_reason(
                            i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                          , i_object_id     => ci.id
                          , i_raise_error   => com_api_const_pkg.FALSE
                        )                             as "status_reason"
                      , ci.state                      as "card_state"
                      , crd.category                  as "category"
                        -- DF8013 - Security ID (FF3F) in CREF; use security word of card, if it is null then use word for cardholder
                      , coalesce(
                            (
                                select xmlforest(
                                           qwc.question as "secret_question"
                                         , qwc.word     as "secret_answer"
                                       )
                                  from sec_question_word_vw qwc
                                 where qwc.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
                                   and qwc.object_id    = crd.id
                                   and qwc.question     = sec_api_const_pkg.DEFAULT_SECURITY_QUESTION
                            )
                          , (
                                select xmlforest(
                                           qwc.question as "secret_question"
                                         , qwc.word     as "secret_answer"
                                       )
                                  from sec_question_word_vw qwc
                                 where qwc.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                   and qwc.object_id    = crd.cardholder_id
                                   and qwc.question     = sec_api_const_pkg.DEFAULT_SECURITY_QUESTION
                            )
                        )                             as "sec_word"
                        -- DF8103 in block FF41 of CREF
                      , cd.pvv as "pvv"
                        -- DF8077 in block FF41 of CREF
                      , cd.pin_offset as "pin_offset"
                        -- DF8163
                      , case
                            when l_full_export = com_api_type_pkg.TRUE
                            then 0
                            else coalesce(
                                     (select 1
                                        from evt_event_object o
                                       where (o.object_id, o.entity_type) in (
                                                 (ci.card_id, iss_api_const_pkg.ENTITY_TYPE_CARD)
                                               , (ci.id,      iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE)
                                             )
                                         and o.split_hash     = ci.split_hash
                                         and o.status         = evt_api_const_pkg.EVENT_STATUS_READY
                                         and o.procedure_name = l_subscriber_name
                                         and o.event_type     = iss_api_const_pkg.EVENT_TYPE_UPD_SENSITIVE_DATA
                                         and rownum           = 1
                                     ) --select
                                   , 0
                                 )
                        end                           as "pin_update_flag"
                      , crd.card_type_id              as "card_type_id" -- DF802F in block FF41 of CREF
                         -- DF862E in block FF41 of CREF
                      , case l_export_clear_pan
                            when com_api_const_pkg.FALSE
                            then cnp.card_number
                            else iss_api_token_pkg.decode_card_number(i_card_number => cnp.card_number)
                        end as "prev_card_number"
                      , cip.card_uid                  as "prev_card_id"
                        -- DF807A - Agent Code (FF3F) in CREF
                      , a.agent_number                as "agent_number"
                      , get_text(
                            i_table_name  => 'ost_agent'
                          , i_column_name => 'name'
                          , i_object_id   => a.id
                          , i_lang        => com_api_const_pkg.DEFAULT_LANGUAGE
                        )                             as "agent_name"
                      , nvl(pr.product_number, pr.id) as "product_number"
                      , get_text(
                            i_table_name  => 'prd_product'
                          , i_column_name => 'label'
                          , i_object_id   => pr.id
                          , i_lang        => com_api_const_pkg.DEFAULT_LANGUAGE
                        )                             as "product_name"
                    )
                  , xmlelement("cardholder"
                      , xmlforest(
                            h.cardholder_number       as "cardholder_number"
                          , ci.cardholder_name        as "cardholder_name"
                        )
                      , (select
                             xmlagg(
                                 xmlelement("person"
                                   , xmlforest(p.id        as "person_id")
                                   , xmlforest(p.title     as "person_title")
                                   , xmlelement("person_name"
                                       , xmlattributes(nvl(p.lang, com_api_const_pkg.DEFAULT_LANGUAGE) as "language")
                                       , xmlforest(
                                             p.surname     as "surname"
                                           , p.first_name  as "first_name"
                                           , p.second_name as "second_name"
                                         )
                                     )
                                   , xmlforest(
                                         p.suffix          as "suffix"
                                       , to_char(p.birthday, com_api_const_pkg.XML_DATE_FORMAT) as "birthday"
                                       , p.place_of_birth  as "place_of_birth"
                                       , p.gender          as "gender"
                                     )
                                   , (select xmlagg(xmlelement("identity_card"
                                               , xmlforest(
                                                     io.id_type        as "id_type"
                                                   , io.id_series      as "id_series"
                                                   , io.id_number      as "id_number"
                                                   , io.country        as "country"
                                                   , io.id_issuer      as "id_issuer"
                                                   , to_char(io.id_issue_date, com_api_const_pkg.XML_DATE_FORMAT)  as "id_issue_date"
                                                   , to_char(io.id_expire_date, com_api_const_pkg.XML_DATE_FORMAT)  as "id_expire_date"
                                                   , com_ui_id_object_pkg.get_id_card_desc(
                                                         i_entity_type     => com_api_const_pkg.ENTITY_TYPE_PERSON
                                                       , i_object_id       => p.id
                                                       , i_lang            => p.lang
                                                     )                 as "id_desc"
                                                 )
                                               , com_api_flexible_data_pkg.generate_xml(
                                                     i_entity_type => com_api_const_pkg.ENTITY_TYPE_IDENTIFY_OBJECT
                                                   , i_standard_id => cmn_api_const_pkg.STANDARD_ID_SV_FRONTEND
                                                   , i_object_id   => io.id
                                                 )
                                                    )
                                             )
                                        from com_id_object io
                                       where io.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
                                         and io.object_id = p.id
                                         and (i_ids_type is null or i_ids_type = io.id_type)
                                     ) --identity_card
                                   , com_api_flexible_data_pkg.generate_xml(
                                         i_entity_type => com_api_const_pkg.ENTITY_TYPE_PERSON
                                       , i_standard_id => cmn_api_const_pkg.STANDARD_ID_SV_FRONTEND
                                       , i_object_id   => p.id
                                     )
                                 ) --person
                             )
                           from (select id, min(lang) keep(dense_rank first order by decode(lang, l_lang, 1, com_api_const_pkg.LANGUAGE_ENGLISH, 2, 3)) lang from com_person group by id) p2
                              , com_person p          -- Select single record with prioritized language for every person
                          where p2.id  = h.person_id
                            and p.id   = p2.id
                            and p.lang = p2.lang
                            and (p.surname is not null
                                 or p.first_name is not null
                                 or p.second_name is not null
                            )
                        )
                      , case
                            when nvl(i_include_address, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then (
                                     select xmlagg(
                                                xmlelement("address"
                                                  , xmlelement("address_type", o.address_type)
                                                  , xmlelement("country", a.country)
                                                  , xmlelement("address_name"
                                                      , xmlattributes(a.lang as "language")
                                                      , xmlforest(
                                                            a.region as "region"
                                                          , a.city   as "city"
                                                          , a.street as "street"
                                                        )
                                                    )
                                                  , xmlforest(
                                                        a.house       as "house"
                                                      , a.apartment   as "apartment"
                                                      , a.postal_code as "postal_code"
                                                      , a.place_code  as "place_code"
                                                      , a.region_code as "region_code"
                                                      , a.latitude    as "latitude"
                                                      , a.longitude   as "longitude"
                                                    )
                                                  , com_api_flexible_data_pkg.generate_xml(
                                                        i_entity_type => com_api_const_pkg.ENTITY_TYPE_ADDRESS
                                                      , i_standard_id => cmn_api_const_pkg.STANDARD_ID_SV_FRONTEND
                                                      , i_object_id   => a.id
                                                    )
                                                ) --xmlelement
                                            )
                                       from com_address_object o
                                          , com_address a
                                      where a.id = o.address_id
                                        and (o.object_id, o.entity_type) in ((crd.cardholder_id, iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER)
                                                                           , (crd.customer_id,   iss_api_const_pkg.ENTITY_TYPE_CUSTOMER))
                                        and (select min(ca.lang) keep (
                                                        dense_rank first
                                                        order by decode(ca.lang, l_lang, 1,  com_api_const_pkg.DEFAULT_LANGUAGE, 2, 3)
                                                    )
                                               from com_address ca
                                              where ca.id = a.id
                                            ) = a.lang
                                        and o.entity_type = (
                                                                select nvl(max(iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER)
                                                                         , iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                                                       )
                                                                  from com_address_object fo
                                                                 where (fo.object_id, fo.entity_type) in ((o.object_id, iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER))
                                                            )
                            )
                        end
                      -- Cardholder primary contact data
                      , case
                            when nvl(i_include_contact, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then (
                                select xmlagg(
                                           xmlelement("contact"
                                             , xmlelement("contact_type", o.contact_type)
                                             , xmlelement("commun_method", d.commun_method)
                                             , xmlelement("commun_address", d.commun_address)
                                           )
                                       )
                                  from iss_cardholder h
                                     , com_contact_object o
                                     , com_contact_data d
                                 where h.id               = crd.cardholder_id
                                   and o.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                   and o.object_id(+)     = h.id
                                   and d.contact_id(+)    = o.contact_id
                                   and (d.end_date is null or d.end_date > l_sysdate)
                            )
                        end
                      , com_api_flexible_data_pkg.generate_xml(
                            i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                          , i_standard_id => cmn_api_const_pkg.STANDARD_ID_SV_FRONTEND
                          , i_object_id   => h.id
                        )
                    ) --cardholder
                  , xmlelement("preceding_instance"
                      , xmlforest(
                            case l_export_clear_pan
                                when com_api_const_pkg.FALSE
                                then cnp.card_number
                                else iss_api_token_pkg.decode_card_number(i_card_number => cnp.card_number)
                            end as "card_number"
                          --, .card_mask        as "card_mask"
                          , cnp.card_id         as "card_id"
                          , cip.expir_date      as "expiration_date"
                          , cip.id              as "instance_id"
                          --, .preceding_card_instance_id as "preceding_instance_id"
                          , cip.reissue_reason  as "reissue_reason"
                        )
                    ) --preceding instance
                  , com_api_flexible_data_pkg.generate_xml(
                        i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
                      , i_standard_id => cmn_api_const_pkg.STANDARD_ID_SV_FRONTEND
                      , i_object_id   => crd.id
                    ) -- card flexible fields
                  , (select xmlagg(
                                xmlelement("stop_list_event"
                                  , xmlforest(
                                        eo.event_type                 as "event_type"
                                      , sl.stop_list_type             as "stop_list_type"
                                      , to_char(sl.purge_date, com_api_const_pkg.XML_DATE_FORMAT) as "purge_date"
                                      , sl.region_list                as "region_list"
                                      , sl.product                    as "product"
                                    )
                                )
                            )
                       from csm_stop_list    sl
                          , evt_event_object eo
                      where eo.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                        and eo.object_id      = ci.id
                        and eo.split_hash     = ci.split_hash
                        and eo.procedure_name = l_subscriber_name
                        and eo.status         = evt_api_const_pkg.EVENT_STATUS_READY
                        and sl.id             = eo.id
                    ) -- stop list events
            ).getclobval()  --xml root element
        from iss_card_vw crd
           , prd_contract ct
           , prd_product pr
           , prd_customer m
           , iss_cardholder h
           , iss_card_instance ci
           , iss_card_instance_data cd
           , iss_card_instance cip -- for preceding card instance
           , iss_card_number cnp
           , ost_agent a
        where ci.id in (select/*+ cardinality(ids 10) */  column_value from table(cast(l_instance_id_tab as num_tab_tpt)) ids)
          and crd.id                 = ci.card_id
          and crd.split_hash         = ci.split_hash
          and ct.id                  = crd.contract_id
          and ct.split_hash          = crd.split_hash
          and pr.id                  = ct.product_id
          and m.id                   = crd.customer_id
          and m.split_hash           = crd.split_hash
          and h.id(+)                = crd.cardholder_id
          and cd.card_instance_id(+) = ci.id
          and cip.id(+)              = ci.preceding_card_instance_id
          and cip.split_hash(+)      = ci.split_hash
          and cnp.card_id(+)         = cip.card_id
          and a.id                   = ci.agent_id
    ;

    cur_objects             sys_refcursor;

    l_container_id         com_api_type_pkg.t_long_id;

    -- Function returns a reference for a cursor with card instances being processed.
    -- In case of incremental unloading it also returns event objects' identifiers.
    procedure open_cur_objects(
        o_cursor               out sys_refcursor
      , i_full_export       in     com_api_type_pkg.t_boolean
      , i_current_inst_id   in     com_api_type_pkg.t_inst_id
    ) is
    begin
        trc_log_pkg.debug('Opening a cursor, inst_id='||i_inst_id||',  for all card instances those are processed...');

        if i_full_export = com_api_type_pkg.TRUE then
            -- Get current instances for all available cards
            open o_cursor for
                select /*+ ordered use_hash(sm, ci) full(sm) full(ci) */
                       ci.id
                  from com_split_map sm
                     , iss_card_instance ci
                 where ci.split_hash       = sm.split_hash
                   and l_thread_number    in (sm.thread_number, prc_api_const_pkg.DEFAULT_THREAD)
                   and ci.is_last_seq_number = com_api_type_pkg.TRUE
                   and (ci.inst_id = i_current_inst_id);

        else
            -- Get current cards' instances by events
            open o_cursor for
                select /*+ ordered use_nl(sm, eo, ci) full(sm) index(eo evt_event_object_status) index(ci iss_card_instance_uk) */
                       eo.id  as event_object_id
                     , ci.id  as card_instance_id
                     , ci.split_hash
                  from com_split_map sm
                     , evt_event_object eo
                     , iss_card_instance ci
                 where l_thread_number in (sm.thread_number, prc_api_const_pkg.DEFAULT_THREAD)
                   and decode(eo.status, 'EVST0001', eo.procedure_name, null) = l_subscriber_name
                   and decode(eo.status, 'EVST0001', eo.split_hash,     null) = sm.split_hash
                   and eo.eff_date              <= l_sysdate
                   and eo.entity_type            = iss_api_const_pkg.ENTITY_TYPE_CARD
                   and eo.inst_id                = i_current_inst_id
                   and (eo.container_id          = l_container_id  or eo.container_id is null)      
                   and (eo.event_type            = i_event_type    or i_event_type    is null)
                   and ci.card_id                = eo.object_id
                   and ci.split_hash             = eo.split_hash
                   and ci.is_last_seq_number     = com_api_type_pkg.TRUE
                   and (l_exclude_npz_cards      = com_api_type_pkg.FALSE
                        or
                        ci.state                != iss_api_const_pkg.CARD_STATE_PERSONALIZATION)
                union all
                select /*+ ordered use_nl(sm, eo, ci) full(sm) index(eo evt_event_object_status) index(ci iss_plastic_pk) */
                       eo.id  as event_object_id
                     , ci.id  as card_instance_id
                     , ci.split_hash
                  from com_split_map sm
                     , evt_event_object eo
                     , iss_card_instance ci
                 where l_thread_number          in (sm.thread_number, prc_api_const_pkg.DEFAULT_THREAD)
                   and decode(eo.status, 'EVST0001', eo.procedure_name, null) = l_subscriber_name
                   and decode(eo.status, 'EVST0001', eo.split_hash,     null) = sm.split_hash
                   and eo.eff_date              <= l_sysdate
                   and eo.entity_type            = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                   and eo.inst_id                = i_current_inst_id
                   and (eo.container_id          = l_container_id  or eo.container_id is null)      
                   and (eo.event_type            = i_event_type    or i_event_type    is null)
                   and ci.id                     = eo.object_id
                   and ci.split_hash             = eo.split_hash
                   and ci.is_last_seq_number     = com_api_type_pkg.TRUE
                   and (l_exclude_npz_cards      = com_api_type_pkg.FALSE
                        or
                        ci.state                != iss_api_const_pkg.CARD_STATE_PERSONALIZATION)
                union all
                select /*+ ordered use_nl(sm, eo, c, ci) full(sm) index(eo evt_event_object_status) index(c iss_card_cardholder_ndx) index(ci iss_card_instance_uk) */
                       eo.id  as event_object_id
                     , ci.id  as card_instance_id
                     , ci.split_hash
                  from com_split_map sm
                     , evt_event_object eo
                     , iss_card c
                     , iss_card_instance ci
                 where l_thread_number          in (sm.thread_number, prc_api_const_pkg.DEFAULT_THREAD)
                   and decode(eo.status, 'EVST0001', eo.procedure_name, null) = l_subscriber_name
                   and decode(eo.status, 'EVST0001', eo.split_hash,     null) = sm.split_hash
                   and eo.eff_date              <= l_sysdate
                   and eo.entity_type            = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                   and eo.inst_id                = i_current_inst_id
                   and (eo.container_id          = l_container_id or eo.container_id is null)      
                   and (eo.event_type            = i_event_type   or i_event_type    is null)
                   and c.cardholder_id           = eo.object_id
                   and c.split_hash              = eo.split_hash
                   and ci.card_id                = c.id
                   and ci.split_hash             = c.split_hash
                   and ci.is_last_seq_number     = com_api_type_pkg.TRUE
                   and (l_exclude_npz_cards      = com_api_type_pkg.FALSE
                        or
                        ci.state                != iss_api_const_pkg.CARD_STATE_PERSONALIZATION)
                -- Also it is necessary to select all cards which products' attributes have been changed.
                -- Also it is necessary to select all cards which product_id have been changed in contract
                -- Only not closed cards are processed.
                union all
                select to_number(null)   as event_object_id
                     , ci.id as card_instance_id
                     , ci.split_hash
                  from com_split_map sm
                     , prd_contract ct
                     , iss_card c
                     , iss_card_instance ci
                 where l_include_limits       = com_api_type_pkg.TRUE
                   and l_thread_number       in (sm.thread_number, prc_api_const_pkg.DEFAULT_THREAD)
                   and ct.product_id         in (select/*+ cardinality(ids 10) */ column_value from table(cast(l_saved_product_id_tab as num_tab_tpt)) ids)
                   and ct.split_hash          = sm.split_hash
                   and c.contract_id          = ct.id
                   and c.split_hash           = ct.split_hash
                   and ci.card_id             = c.id
                   and ci.split_hash          = c.split_hash
                   and ci.is_last_seq_number  = com_api_type_pkg.TRUE
                   and ci.state              != iss_api_const_pkg.CARD_STATE_CLOSED
                   and (l_exclude_npz_cards   = com_api_type_pkg.FALSE
                        or
                        ci.state             != iss_api_const_pkg.CARD_STATE_PERSONALIZATION)
                union all
                select /*+ ordered use_nl(sm, eo, c, ci) full(sm) index(eo evt_event_object_status) index(c iss_card_contract) index(ci iss_card_instance_uk) */
                       eo.id  as event_object_id
                     , ci.id  as card_instance_id
                     , ci.split_hash
                  from com_split_map sm
                     , evt_event_object eo
                     , iss_card c
                     , iss_card_instance ci
                 where l_include_limits          = com_api_type_pkg.TRUE
                   and l_thread_number          in (sm.thread_number, prc_api_const_pkg.DEFAULT_THREAD)
                   and decode(eo.status, 'EVST0001', eo.procedure_name, null) = l_subscriber_name
                   and decode(eo.status, 'EVST0001', eo.split_hash,     null) = sm.split_hash
                   and eo.eff_date              <= l_sysdate
                   and eo.entity_type            = prd_api_const_pkg.ENTITY_TYPE_CONTRACT
                   and eo.inst_id                = i_current_inst_id
                   and (eo.container_id          = l_container_id or eo.container_id is null)      
                   and eo.event_type             = prd_api_const_pkg.EVENT_PRODUCT_CHANGE
                   and c.contract_id             = eo.object_id
                   and c.split_hash              = eo.split_hash
                   and ci.card_id                = c.id
                   and ci.split_hash             = c.split_hash
                   and ci.is_last_seq_number     = com_api_type_pkg.TRUE
                   and (l_exclude_npz_cards      = com_api_type_pkg.FALSE
                        or 
                        ci.state                != iss_api_const_pkg.CARD_STATE_PERSONALIZATION)
                union all
                select /*+ ordered use_nl(sm, eo, p, ci) full(sm) index(eo evt_event_object_status) index(p opr_participant_pk) index(ci iss_plastic_pk) */
                       eo.id as event_object_id
                     , p.card_instance_id
                     , p.split_hash
                  from com_split_map sm
                     , evt_event_object eo
                     , opr_participant p
                     , iss_card_instance ci
                 where l_include_limits          = com_api_type_pkg.TRUE
                   and l_thread_number          in (sm.thread_number, prc_api_const_pkg.DEFAULT_THREAD)
                   and decode(eo.status, 'EVST0001', eo.procedure_name, null) = l_subscriber_name
                   and decode(eo.status, 'EVST0001', eo.split_hash,     null) = sm.split_hash
                   and eo.eff_date              <= l_sysdate
                   and eo.entity_type            = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                   and (eo.container_id          = l_container_id or eo.container_id is null)
                   and eo.event_type             = opr_api_const_pkg.EVENT_PROCESSED_SUCCESSFULLY
                   and p.oper_id                 = eo.object_id
                   and p.participant_type        = com_api_const_pkg.PARTICIPANT_ISSUER
                   and p.split_hash              = eo.split_hash
                   and p.inst_id                 = i_current_inst_id
                   and ci.id                     = p.card_instance_id
                   and ci.split_hash             = p.split_hash
                   and ci.is_last_seq_number     = com_api_type_pkg.TRUE
                   and (l_exclude_npz_cards      = com_api_type_pkg.FALSE
                        or 
                        ci.state                != iss_api_const_pkg.CARD_STATE_PERSONALIZATION)
          order by 3  -- split_hash
                 , 2  -- card_instance_id
          ;

        end if;
        trc_log_pkg.debug('Cursor was opened...');
    end open_cur_objects;

    procedure save_file(
        i_counter           in     com_api_type_pkg.t_count
      , i_current_inst_id   in     com_api_type_pkg.t_inst_id
    ) is
        l_params                   com_api_type_pkg.t_param_tab;
        l_report_id                com_api_type_pkg.t_short_id;
        l_report_template_id       com_api_type_pkg.t_short_id;
    begin
        trc_log_pkg.debug('Creating a new XML file, count=' || i_counter);

        rul_api_param_pkg.set_param (
            i_name          => 'INST_ID'
          , i_value         => i_current_inst_id
          , io_params       => l_params
        );

        l_file_count := l_file_count + 1;

        rul_api_param_pkg.set_param(
            i_name    => 'FILE_NUMBER'
          , i_value   => l_file_count
          , io_params => l_params
        );

        prc_api_file_pkg.save_file (
            i_file_type             => null
          , i_file_purpose          => prc_api_const_pkg.FILE_PURPOSE_OUT
          , io_params               => l_params
          , o_report_id             => l_report_id
          , o_report_template_id    => l_report_template_id
          , i_clob_content          => l_file
          , i_status                => prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count          => i_counter
        );

        trc_log_pkg.debug('file saved, count=' || i_counter || ', length=' || length(l_file));
    end save_file;

    -- Generate XML file
    procedure generate_xml(
        i_current_inst_id in com_api_type_pkg.t_inst_id
    ) is
        l_fetched_count           com_api_type_pkg.t_count    := 0;

        l_inst_id_tab             com_api_type_pkg.t_inst_id_tab;
        l_card_id_tab             com_api_type_pkg.t_medium_tab;
        l_customer_id_tab         com_api_type_pkg.t_medium_tab;
        l_split_hash_tab          com_api_type_pkg.t_tiny_tab;
        l_product_id_tab          com_api_type_pkg.t_short_tab;
        l_cardholder_id_tab       com_api_type_pkg.t_medium_tab;
        l_is_last_seq_number_tab  com_api_type_pkg.t_boolean_tab;
        l_card_state_tab          com_api_type_pkg.t_dict_tab;
        l_xml_block_tab           com_api_type_pkg.t_lob_tab;
        l_xml_block               com_api_type_pkg.t_lob_data;

        l_xml_customer            com_api_type_pkg.t_lob_data;
        l_xml_notification        com_api_type_pkg.t_lob_data;
        l_xml_3d_secure           com_api_type_pkg.t_lob_data;
        l_xml_account             com_api_type_pkg.t_lob_data;
        l_xml_card_limits         com_api_type_pkg.t_lob_data;
        l_xml_services            com_api_type_pkg.t_lob_data;
        l_xml_add_data            com_api_type_pkg.t_lob_data;

        l_add_data_xmltype        xmltype;
    begin
        if l_instance_id_tab.count() > 0 then

            l_estimated_count := nvl(l_estimated_count, 0) + l_instance_id_tab.count();

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
              , i_measure         => iss_api_const_pkg.ENTITY_TYPE_CARD
            );

            trc_log_pkg.debug('Estimated count of cards is [' || l_estimated_count || ']');

            -- Create temporary LOB
            dbms_lob.createtemporary(lob_loc => l_file,
                                     cache   => true,
                                     dur     => dbms_lob.session);
          
            if dbms_lob.isopen(l_file) = 0 then
              dbms_lob.open(l_file, dbms_lob.lob_readwrite);
            end if;

            l_xml_block := com_api_const_pkg.XML_HEADER || CRLF
                        || '<cards_info xmlns="http://bpc.ru/sv/SVXP/card_info">'
                        || '<file_type>' || iss_api_const_pkg.FILE_TYPE_CARD_INFO || '</file_type>'
                        || '<inst_id>'
                        || case nvl(i_replace_inst_id_by_number, com_api_const_pkg.FALSE)
                               when com_api_const_pkg.TRUE
                               then ost_api_institution_pkg.get_inst_number(i_inst_id => i_current_inst_id)
                               else to_char(i_current_inst_id, com_api_const_pkg.XML_NUMBER_FORMAT)
                           end
                        || '</inst_id>'
                        || '<tokenized_pan>'
                        || case l_export_clear_pan
                               when com_api_const_pkg.FALSE
                               then com_api_const_pkg.TRUE
                               else com_api_const_pkg.FALSE
                           end
                        || '</tokenized_pan>';

            if l_xml_block is not null then
                dbms_lob.writeappend(l_file, dbms_lob.getlength(l_xml_block), l_xml_block);
            end if;

            prc_api_performance_pkg.start_performance_metric(
                i_method_name => 'generate_xml'
              , i_label_name  => 'open cur_xml'
            );

            -- For every processing batch of card instances we fetch data and save it in a separate file
            open cur_xml;

            prc_api_performance_pkg.finish_performance_metric(
                i_method_name   => 'generate_xml'
              , i_label_name    => 'open cur_xml'
            );

            prc_api_performance_pkg.start_performance_metric(
                i_method_name   => 'generate_xml'
              , i_label_name    => 'fetch cur_xml'
            );

            fetch cur_xml
               bulk collect
               into l_inst_id_tab
                  , l_card_id_tab
                  , l_customer_id_tab
                  , l_split_hash_tab
                  , l_product_id_tab
                  , l_cardholder_id_tab
                  , l_is_last_seq_number_tab
                  , l_card_state_tab
                  , l_xml_block_tab;

            l_fetched_count := l_card_id_tab.count;

            prc_api_performance_pkg.finish_performance_metric(
                i_method_name   => 'generate_xml'
              , i_label_name    => 'fetch cur_xml'
              , i_fetched_count => l_fetched_count
            );

            close cur_xml;

            prc_api_performance_pkg.start_performance_metric(
                i_method_name   => 'generate_xml'
              , i_label_name    => 'for loop'
            );

            for i in 1 .. l_card_id_tab.count loop

                generate_customer(
                    i_inst_id                => l_inst_id_tab(i)
                  , i_card_id                => l_card_id_tab(i)
                  , i_customer_id            => l_customer_id_tab(i)
                  , i_split_hash             => l_split_hash_tab(i)
                  , i_product_id             => l_product_id_tab(i)
                  , i_customer_value_type    => l_customer_value_type
                  , i_sysdate                => l_sysdate
                  , o_xml_block              => l_xml_customer
                );

                -- notification
                if l_include_notif = com_api_type_pkg.TRUE
                   and l_is_last_seq_number_tab(i) = com_api_type_pkg.TRUE
                then
                    generate_notifications(
                        i_subscriber_name    => l_subscriber_name
                      , i_inst_id            => l_inst_id_tab(i)
                      , i_card_id            => l_card_id_tab(i)
                      , i_cardholder_id      => l_cardholder_id_tab(i)
                      , i_split_hash         => l_split_hash_tab(i)
                      , i_sysdate            => l_sysdate
                      , o_xml_block          => l_xml_notification
                    );

                end if;

                -- 3D secure
                if l_include_notif = com_api_type_pkg.TRUE
                   and l_is_last_seq_number_tab(i) = com_api_type_pkg.TRUE
                then
                    generate_3d_secure(
                        i_subscriber_name    => l_subscriber_name
                      , i_inst_id            => l_inst_id_tab(i)
                      , i_card_id            => l_card_id_tab(i)
                      , i_cardholder_id      => l_cardholder_id_tab(i)
                      , i_customer_id        => l_customer_id_tab(i)
                      , i_product_id         => l_product_id_tab(i)
                      , i_split_hash         => l_split_hash_tab(i)
                      , i_sysdate            => l_sysdate
                      , o_xml_block          => l_xml_3d_secure
                    );

                end if;

                if l_card_state_tab(i) != iss_api_const_pkg.CARD_STATE_CLOSED then
                    generate_account(
                        i_subscriber_name    => l_subscriber_name
                      , i_card_id            => l_card_id_tab(i)
                      , i_split_hash         => l_split_hash_tab(i)
                      , i_array_account_type => i_array_account_type
                      , i_sysdate            => l_sysdate
                      , o_xml_block          => l_xml_account
                    );

                end if;

                -- card limits
                if l_include_limits = com_api_type_pkg.TRUE then
                    generate_card_limits(
                        i_inst_id      => l_inst_id_tab(i)
                      , i_card_id      => l_card_id_tab(i)
                      , i_split_hash   => l_split_hash_tab(i)
                      , i_product_id   => l_product_id_tab(i)
                      , i_sysdate      => l_sysdate
                      , o_xml_block    => l_xml_card_limits
                    );

                end if;

                -- services
                if l_include_service = com_api_type_pkg.TRUE then
                    generate_services(
                        i_full_export  => l_full_export
                      , i_card_id      => l_card_id_tab(i)
                      , i_split_hash   => l_split_hash_tab(i)
                      , i_product_id   => l_product_id_tab(i)
                      , i_sysdate      => l_sysdate
                      , o_xml_block    => l_xml_services
                    );

                end if;

                prc_api_performance_pkg.start_performance_metric(
                    i_method_name   => 'generate_xml'
                  , i_label_name    => 'add_data'
                );

                l_add_data_xmltype := iss_cst_export_pkg.generate_add_data(
                                          i_card_id => l_card_id_tab(i)
                                      );

                if l_add_data_xmltype is not null then
                    l_xml_add_data := cast(l_add_data_xmltype.getclobval() as varchar2);
                end if;

                prc_api_performance_pkg.finish_performance_metric(
                    i_method_name   => 'generate_xml'
                  , i_label_name    => 'add_data'
                );

                prc_api_performance_pkg.start_performance_metric(
                    i_method_name   => 'generate_xml'
                  , i_label_name    => 'build_xml'
                );

                l_xml_block := '<card_info>'
                            || replace(l_xml_block_tab(i), '</cardholder>', l_xml_notification || l_xml_3d_secure || '</cardholder>')
                            || l_xml_customer
                            || l_xml_account
                            || l_xml_card_limits
                            || l_xml_services
                            || l_xml_add_data
                            || '</card_info>';

                if l_xml_block is not null then
                    dbms_lob.writeappend(l_file, dbms_lob.getlength(l_xml_block), l_xml_block);
                end if;

                prc_api_performance_pkg.finish_performance_metric(
                    i_method_name   => 'generate_xml'
                  , i_label_name    => 'build_xml'
                );
                
                -- Clear xml blocks
                l_xml_notification := null;
                l_xml_3d_secure    := null;
                l_xml_customer     := null;
                l_xml_account      := null;
                l_xml_card_limits  := null;
                l_xml_services     := null;
                l_xml_add_data     := null;

            end loop;

            prc_api_performance_pkg.finish_performance_metric(
                i_method_name   => 'generate_xml'
              , i_label_name    => 'for loop'
              , i_fetched_count => l_fetched_count
            );


            l_xml_block := '</cards_info>';

            if l_xml_block is not null then
                dbms_lob.writeappend(l_file, dbms_lob.getlength(l_xml_block), l_xml_block);
            end if;

            prc_api_performance_pkg.start_performance_metric(
                i_method_name   => 'generate_xml'
              , i_label_name    => 'save_file'
            );

            save_file(
                i_counter         => l_fetched_count
              , i_current_inst_id => i_current_inst_id
            );

            if dbms_lob.isopen(l_file) = 1 then
              dbms_lob.close(l_file);
            end if;

            dbms_lob.freetemporary(lob_loc => l_file);

            prc_api_performance_pkg.finish_performance_metric(
                i_method_name   => 'generate_xml'
              , i_label_name    => 'save_file'
              , i_fetched_count => l_fetched_count
            );

            l_processed_count := l_processed_count + l_fetched_count;

            prc_api_stat_pkg.log_current(
                i_current_count  => l_processed_count
              , i_excepted_count => 0
            );
        end if;
    end generate_xml;

begin
    trc_log_pkg.debug(
        i_text       => 'export_cards_numbers: START with l_full_export [#1], i_include_address [#2]'
                     || ', i_include_limits [#3], i_inst_id [#4], i_count [#5], i_include_service [#6]'
      , i_env_param1 => l_full_export
      , i_env_param2 => i_include_address
      , i_env_param3 => i_include_limits
      , i_env_param4 => i_inst_id
      , i_env_param5 => i_count
      , i_env_param6 => i_include_service
    );

    prc_api_performance_pkg.reset_performance_metrics;

    l_lang           := coalesce(i_lang, com_ui_user_env_pkg.get_user_lang());
    l_sysdate        := com_api_sttl_day_pkg.get_sysdate;
    l_thread_number  := prc_api_session_pkg.get_thread_number();

    -- If tokenization isn't used then there is no sense to call decoding function
    -- in then select section to reduce count of SQL-PLSQL context switches
    l_export_clear_pan :=
        case
            when iss_api_token_pkg.is_token_enabled() = com_api_const_pkg.TRUE
            then nvl(i_export_clear_pan, com_api_const_pkg.TRUE)
            else com_api_const_pkg.FALSE
        end;

    l_customer_value_type := iss_cst_export_pkg.get_customer_value_type;
    l_container_id        :=  prc_api_session_pkg.get_container_id;

    trc_log_pkg.debug(
        i_text       => 'l_export_clear_pan [#1] l_lang [#2] l_customer_value_type [#3] l_container_id [#4] l_thread_number [#5]'
      , i_env_param1 => l_export_clear_pan
      , i_env_param2 => l_lang
      , i_env_param3 => l_customer_value_type
      , i_env_param4 => l_container_id
      , i_env_param5 => l_thread_number
    );

    prc_api_stat_pkg.log_start;

    for inst in(
        select i.id 
          from ost_institution i
         where (i.id = i_inst_id
             or i_inst_id = ost_api_const_pkg.DEFAULT_INST
             or i_inst_id is null
               )
           and i.id != ost_api_const_pkg.UNIDENTIFIED_INST
    ) loop

        prc_api_performance_pkg.start_performance_metric(
            i_method_name => 'export_cards_numbers'
          , i_label_name  => 'init_variables'
        );

        -- get full product list
        select prd_product_tpr(
                   connect_by_root id
                 , level
                 , p.id
                 , case
                       when p.parent_id is null
                       then 1
                       else 0
                   end
               )
          bulk collect into g_product_tab
          from prd_product p
         where p.inst_id = inst.id
          connect by prior p.parent_id = p.id;

          -- get all card limits for all products
          get_object_limit_list(
              i_object_type          => iss_api_const_pkg.ENTITY_TYPE_CARD
            , i_inst_id              => inst.id
            , i_sysdate              => l_sysdate
            , o_object_attr_map_tab  => g_card_limit_map_tab
          );

          -- get all customer limits for all products
          get_object_limit_list(
              i_object_type          => iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
            , i_inst_id              => inst.id
            , i_sysdate              => l_sysdate
            , o_object_attr_map_tab  => g_customer_limit_map_tab
          );

        if l_include_service = com_api_type_pkg.TRUE then

            trc_log_pkg.debug(
                i_text => 'Get collection of services'
            );

            if l_full_export = com_api_type_pkg.TRUE then
                -- full export
                select prd_service_tpr(
                           s.id
                         , t.id
                         , get_text ('prd_service_type', 'label', t.id, l_lang)
                         , t.external_code
                         , s.service_number
                         , 1
                         , null
                       )
                  bulk collect into g_service_id_tab
                  from prd_service_type t
                     , prd_service s
                 where t.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
                   and t.product_type    = prd_api_const_pkg.PRODUCT_TYPE_ISS --'PRDT0100'
                   and t.id         not in (ntf_api_const_pkg.NOTIFICATION_CARD_SERVICE
                                          , ntf_api_const_pkg.THREE_D_SECURE_CARD_SERVICE)
                   and s.service_type_id = t.id
                   and s.inst_id         = inst.id;

            else
                select prd_service_tpr(
                           s.id
                         , t.id
                         , t.service_type_name
                         , t.external_code
                         , s.service_number
                         , t.is_active
                         , t.event_type
                       )
                  bulk collect into g_service_id_tab
                  from prd_service s
                     , (
                        select id
                             , enable_event_type event_type
                             , get_text ('prd_service_type', 'label', id, l_lang) service_type_name
                             , external_code
                             , 1 is_active
                          from prd_service_type
                         where entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
                           and product_type = prd_api_const_pkg.PRODUCT_TYPE_ISS --'PRDT0100'
                           and id not in (ntf_api_const_pkg.NOTIFICATION_CARD_SERVICE
                                        , ntf_api_const_pkg.THREE_D_SECURE_CARD_SERVICE)
                        union
                        select id
                             , disable_event_type event_type
                             , get_text ('prd_service_type', 'label', id, l_lang) service_type_name
                             , external_code
                             , 0 is_active
                          from prd_service_type
                         where entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
                           and product_type = prd_api_const_pkg.PRODUCT_TYPE_ISS --'PRDT0100'
                           and id not in (ntf_api_const_pkg.NOTIFICATION_CARD_SERVICE
                                        , ntf_api_const_pkg.THREE_D_SECURE_CARD_SERVICE)
                    ) t
                 where s.service_type_id = t.id
                   and s.inst_id         = inst.id;

            end if;

            trc_log_pkg.debug(
                i_text => 'Collection created. Count = ' || g_service_id_tab.count
            );
        end if;

        -- Get events for entity_type = "Product"
        if l_include_limits = com_api_type_pkg.TRUE then
            select (
                       select eo.id
                         from com_split_map sm
                        where sm.split_hash    = eo.split_hash
                          and l_thread_number in (sm.thread_number, prc_api_const_pkg.DEFAULT_THREAD)
                   )             as product_event_id
                 , eo.object_id  as product_id
              bulk collect into
                   l_fetched_product_event_id_tab
                 , l_fetched_product_id_tab
              from evt_event_object eo
             where  decode(eo.status, 'EVST0001', eo.procedure_name, null) = l_subscriber_name
               and eo.eff_date        <= l_sysdate
               and eo.inst_id          = inst.id
               and eo.entity_type      = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
               and (eo.container_id    = l_container_id or eo.container_id is null)   
               and eo.event_type      in (prd_api_const_pkg.EVENT_ATTRIBUTE_CHANGE_PRODUCT
                                        , prd_api_const_pkg.EVENT_PRODUCT_ATTR_END_CHANGE);

            l_saved_product_event_id_tab := set(l_fetched_product_event_id_tab);
            l_saved_product_id_tab       := set(l_fetched_product_id_tab);

            select p.id as product_id
              bulk collect into l_fetched_product_id_tab
              from (select/*+ cardinality(ids 10) */ column_value as product_id from table(cast(l_saved_product_id_tab as num_tab_tpt)) ids) o
                  , prd_product p
              where p.product_type   = prd_api_const_pkg.PRODUCT_TYPE_ISS
                and p.inst_id        = inst.id
              connect by p.parent_id = prior p.id
              start with p.id        = o.product_id;

            l_saved_product_id_tab       := set(l_fetched_product_id_tab);

            l_fetched_product_event_id_tab.delete;
            l_fetched_product_id_tab.delete;

        end if;

        prc_api_performance_pkg.finish_performance_metric(
            i_method_name => 'export_cards_numbers'
          , i_label_name  => 'init_variables'
        );

        prc_api_performance_pkg.start_performance_metric(
            i_method_name => 'export_cards_numbers'
          , i_label_name  => 'open_cur_objects'
        );

        open_cur_objects(
            o_cursor          => cur_objects
          , i_full_export     => l_full_export
          , i_current_inst_id => inst.id
        );

        prc_api_performance_pkg.finish_performance_metric(
            i_method_name => 'export_cards_numbers'
          , i_label_name  => 'open_cur_objects'
        );

        loop
            begin
                savepoint sp_before_iteration;

                if l_full_export = com_api_type_pkg.TRUE then

                    prc_api_performance_pkg.start_performance_metric(
                        i_method_name   => 'export_cards_numbers'
                      , i_label_name    => 'fetch full export'
                    );

                    fetch cur_objects
                     bulk collect into
                          l_instance_id_tab
                    limit l_bulk_limit;

                    prc_api_performance_pkg.finish_performance_metric(
                        i_method_name   => 'export_cards_numbers'
                      , i_label_name    => 'fetch full export'
                      , i_fetched_count => l_instance_id_tab.count
                    );

                    if l_instance_id_tab.count > 0 then
                        trc_log_pkg.debug(
                            i_text         =>  'inst_id [#1], l_instance_id_tab.count = [#2]'
                          , i_env_param1   => inst.id
                          , i_env_param2   => l_instance_id_tab.count
                        );
                    end if;

                    -- Generate XML file
                    generate_xml(i_current_inst_id => inst.id);

                else  -- l_full_export = com_api_type_pkg.FALSE

                    prc_api_performance_pkg.start_performance_metric(
                        i_method_name   => 'export_cards_numbers'
                      , i_label_name    => 'fetch events'
                    );

                    fetch cur_objects
                     bulk collect into
                          l_fetched_event_object_id_tab
                        , l_fetched_instance_id_tab
                        , l_fetched_split_hash_tab
                    limit l_bulk_limit;

                    prc_api_performance_pkg.finish_performance_metric(
                        i_method_name   => 'export_cards_numbers'
                      , i_label_name    => 'fetch events'
                      , i_fetched_count => l_instance_id_tab.count
                    );

                    trc_log_pkg.debug('l_fetched_instance_id_tab.count = ' || l_fetched_instance_id_tab.count);

                    for i in 1 .. l_fetched_instance_id_tab.count loop
                        -- All events for every single card instance should be marked as processed
                        if l_fetched_event_object_id_tab(i) is not null then
                            l_event_object_id_tab(l_event_object_id_tab.count + 1) := l_fetched_event_object_id_tab(i);
                        end if;

                        -- Decrease card instance count and remove the last card instance id from previous iteration
                        if (l_fetched_instance_id_tab(i) != l_instance_id or l_instance_id is null)
                           and l_fetched_instance_id_tab(i) is not null
                        then
                            l_instance_id := l_fetched_instance_id_tab(i);

                            l_instance_id_tab.extend;
                            l_instance_id_tab(l_instance_id_tab.count) := l_fetched_instance_id_tab(i);

                            if l_instance_id_tab.count >= l_bulk_limit then
                                -- Generate XML file for current portion of the "l_bulk_limit" records
                                generate_xml(i_current_inst_id => inst.id);

                                evt_api_event_pkg.process_event_object(
                                    i_event_object_id_tab => l_event_object_id_tab
                                );

                                l_instance_id_tab.delete;
                                l_event_object_id_tab.delete;
                            end if;
                        end if;
                    end loop;

                    trc_log_pkg.debug('events were processed, cnt = ' || l_fetched_event_object_id_tab.count);
                end if;

                -- Commit the current iteration which is needed for FileSaver for best performance (do not remove this commit)
                commit;

                exit when cur_objects%notfound;

            exception
                when others then
                    rollback to sp_before_iteration;
                    raise;
            end;
        end loop;

        if l_full_export = com_api_type_pkg.FALSE then
            -- Generate XML file for last portion of records
            generate_xml(i_current_inst_id => inst.id);

            evt_api_event_pkg.process_event_object(
                i_event_object_id_tab => l_event_object_id_tab
            );

            if l_saved_product_event_id_tab.count > 0 then
                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab => l_saved_product_event_id_tab
                );
            end if;
        end if;

        close cur_objects;

        if l_full_export = com_api_type_pkg.TRUE and l_include_notif = com_api_type_pkg.TRUE then
            -- Process event objects for event close 3d secure service or close notification service
            select eo.id
              bulk collect
              into l_notif_event_tab
              from evt_event_object eo
             where decode(eo.status, 'EVST0001', eo.procedure_name, null) = l_subscriber_name
               and eo.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
               and eo.eff_date       <= l_sysdate
               and eo.split_hash      in (select split_hash from com_api_split_map_vw)
               and eo.event_type      in (iss_api_const_pkg.EVENT_3D_SECURE_DEACTIVATION  -- close 3d secure service
                                        , iss_api_const_pkg.EVENT_NOTIF_DEACTIVATION)     -- or notification service
            ;
            evt_api_event_pkg.process_event_object(
                i_event_object_id_tab => l_notif_event_tab
            );
        end if;
    end loop;

    if l_estimated_count is null then
        prc_api_stat_pkg.log_estimation(
            i_estimated_count => 0
          , i_measure         => iss_api_const_pkg.ENTITY_TYPE_CARD
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total  => l_processed_count
      , i_excepted_total   => l_estimated_count - l_processed_count
      , i_rejected_total   => 0
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug('export_cards_numbers: FINISH: l_processed_count [' || l_processed_count || ']');

    -- Commit the last process changes before exit
    commit;

    prc_api_performance_pkg.print_performance_metrics(
        i_processed_count => l_processed_count
    );

exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        -- Commit the last process changes before exit
        commit;

        prc_api_performance_pkg.print_performance_metrics(
            i_processed_count => l_processed_count
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;
end export_cards_numbers;

procedure export_persons(
    i_inst_id                    in     com_api_type_pkg.t_inst_id
  , i_count                      in     com_api_type_pkg.t_count
  , i_full_export                in     com_api_type_pkg.t_boolean    default null
  , i_lang                       in     com_api_type_pkg.t_dict_value default null
) is
    DEFAULT_PROCEDURE_NAME         constant com_api_type_pkg.t_name  := 'ISS_PRC_EXPORT_PKG.EXPORT_PERSONS';

    -- Default bulk size for persons blocks per a file if <i_count> parameter is not specified
    DEFAULT_BULK_LIMIT             constant com_api_type_pkg.t_count := 2000;
    l_bulk_limit                   com_api_type_pkg.t_count          := nvl(i_count, DEFAULT_BULK_LIMIT);
    l_estimated_count              com_api_type_pkg.t_long_id        := 0;
    l_processed_count              com_api_type_pkg.t_count          := 0;
    l_file_count                   com_api_type_pkg.t_count          := 0;
    l_file                         clob;
    l_full_export                  com_api_type_pkg.t_boolean        := nvl(i_full_export, com_api_type_pkg.FALSE);

    l_fetched_event_object_id_tab  com_api_type_pkg.t_number_tab;
    l_fetched_person_id_tab        num_tab_tpt                       := num_tab_tpt();

    l_person_id_tab                num_tab_tpt                       := num_tab_tpt();
    l_person_id                    com_api_type_pkg.t_medium_id;
    l_sysdate                      date;
    l_lang                         com_api_type_pkg.t_dict_value;

    cursor cur_xml is
        select xmlconcat(
                   xmlelement("person"
                     , xmlforest(p.id        as "person_id")
                     , xmlforest(p.title     as "person_title")
                     , xmlelement("person_name"
                         , xmlattributes(nvl(p.lang, com_api_const_pkg.DEFAULT_LANGUAGE) as "language")
                         , xmlforest(
                               p.surname     as "surname"
                             , p.first_name  as "first_name"
                             , p.second_name as "second_name"
                           )
                       )
                     , xmlforest(
                           p.suffix          as "suffix"
                         , to_char(p.birthday, com_api_const_pkg.XML_DATE_FORMAT) as "birthday"
                         , p.place_of_birth  as "place_of_birth"
                         , p.gender          as "gender"
                       )
                     , (select xmlagg(xmlelement("identity_card"
                                 , xmlforest(
                                       o.id_type        as "id_type"
                                     , o.id_series      as "id_series"
                                     , o.id_number      as "id_number"
                                     , o.country        as "country"
                                     , o.id_issuer      as "id_issuer"
                                     , to_char(o.id_issue_date, com_api_const_pkg.XML_DATE_FORMAT)   as "id_issue_date"
                                     , to_char(o.id_expire_date, com_api_const_pkg.XML_DATE_FORMAT)  as "id_expire_date"
                                     , com_ui_id_object_pkg.get_id_card_desc(
                                           i_entity_type     => com_api_const_pkg.ENTITY_TYPE_PERSON
                                         , i_object_id       => p.id
                                         , i_lang            => p.lang
                                       )                as "id_desc"
                                   )
                                      )
                               )
                          from com_id_object o
                         where o.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
                           and o.object_id = p.id
                       ) --identity_card
                   )
               ).getclobval()
          from com_person p
             , (select id, min(lang) keep(dense_rank first order by decode(lang, l_lang, 1, com_api_const_pkg.LANGUAGE_ENGLISH, 2, 3)) lang from com_person group by id) l
         where p.id   in (select/*+ cardinality(ids 10) */  column_value from table(cast(l_person_id_tab as num_tab_tpt)) ids)
           and p.id    = l.id
           and p.lang  = l.lang;

    cur_objects             sys_refcursor;

    l_container_id         com_api_type_pkg.t_long_id;

    procedure open_cur_objects(
        o_cursor               out sys_refcursor
      , i_full_export       in     com_api_type_pkg.t_boolean
      , i_inst_id           in     com_api_type_pkg.t_inst_id
    ) is
    begin
        trc_log_pkg.debug('Opening a cursor for all persons processed...');

        if i_full_export = com_api_type_pkg.TRUE then
            -- Get all persons
            open o_cursor for
                select s.object_id
                  from prd_customer  s
                 where (s.inst_id = i_inst_id or i_inst_id is null)
                   and s.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON;

        else
            -- Get persons by events
            open o_cursor for
                select o.id         as event_object_id
                     , s.object_id  as person_id
                  from evt_event_object o
                     , prd_customer     s
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = DEFAULT_PROCEDURE_NAME
                   and o.eff_date              <= l_sysdate
                   and o.entity_type            = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                   and (o.inst_id               = i_inst_id       or i_inst_id       is null)
                   and (o.container_id          = l_container_id  or o.container_id  is null)
                   and o.object_id              = s.id
                   and s.entity_type            = com_api_const_pkg.ENTITY_TYPE_PERSON
                 union all
                select o.id         as event_object_id
                     , h.person_id  as person_id
                  from evt_event_object o
                     , iss_cardholder   h
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = DEFAULT_PROCEDURE_NAME
                   and o.eff_date              <= l_sysdate
                   and o.entity_type            = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                   and (o.inst_id               = i_inst_id       or i_inst_id       is null)
                   and (o.container_id          = l_container_id  or o.container_id  is null)
                   and o.object_id              = h.id
                 order by person_id;

        end if;

        trc_log_pkg.debug('Cursor was opened...');

    end open_cur_objects;

    procedure save_file(
        i_counter           in     com_api_type_pkg.t_count
    ) is
        l_params                   com_api_type_pkg.t_param_tab;
        l_report_id                com_api_type_pkg.t_short_id;
        l_report_template_id       com_api_type_pkg.t_short_id;
    begin
        trc_log_pkg.debug('Creating a new XML file, count=' || i_counter);

        rul_api_param_pkg.set_param (
            i_name          => 'INST_ID'
          , i_value         => i_inst_id
          , io_params       => l_params
        );

        l_file_count := l_file_count + 1;

        rul_api_param_pkg.set_param(
            i_name    => 'FILE_NUMBER'
          , i_value   => l_file_count
          , io_params => l_params
        );

        prc_api_file_pkg.save_file (
            i_file_type             => null
          , i_file_purpose          => prc_api_const_pkg.FILE_PURPOSE_OUT
          , io_params               => l_params
          , o_report_id             => l_report_id
          , o_report_template_id    => l_report_template_id
          , i_clob_content          => l_file
          , i_status                => prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count          => i_counter
        );

        trc_log_pkg.debug('file saved, count=' || i_counter || ', length=' || length(l_file));
    end save_file;

    -- Generate XML file
    procedure generate_xml is
        l_fetched_count           com_api_type_pkg.t_count    := 0;

        l_xml_block_tab           com_api_type_pkg.t_lob_tab;
        l_xml_block               com_api_type_pkg.t_lob_data;
    begin
        if l_person_id_tab.count() > 0 then

            l_estimated_count := nvl(l_estimated_count, 0) + l_person_id_tab.count;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
              , i_measure         => com_api_const_pkg.ENTITY_TYPE_PERSON
            );

            trc_log_pkg.debug('Estimated count of persons is [' || l_estimated_count || ']');

            -- Create temporary LOB
            dbms_lob.createtemporary(lob_loc => l_file,
                                     cache   => true,
                                     dur     => dbms_lob.session);

            if dbms_lob.isopen(l_file) = 0 then
                dbms_lob.open(l_file, dbms_lob.lob_readwrite);
            end if;

            l_xml_block := com_api_const_pkg.XML_HEADER || CRLF
                        || '<persons xmlns="http://bpc.ru/sv/SVXP/persons">'
                        || '<file_type>' || iss_api_const_pkg.FILE_TYPE_PERS_INFO || '</file_type>'
                        || '<inst_id>'   || i_inst_id || '</inst_id>';

            if l_xml_block is not null then
                dbms_lob.writeappend(l_file, dbms_lob.getlength(l_xml_block), l_xml_block);
            end if;

            prc_api_performance_pkg.start_performance_metric(
                i_method_name => 'generate_xml'
              , i_label_name  => 'open cur_xml'
            );

            -- For every processing batch of persons we fetch data and save it in a separate file
            open cur_xml;

            prc_api_performance_pkg.finish_performance_metric(
                i_method_name   => 'generate_xml'
              , i_label_name    => 'open cur_xml'
            );

            prc_api_performance_pkg.start_performance_metric(
                i_method_name   => 'generate_xml'
              , i_label_name    => 'fetch cur_xml'
            );

            fetch cur_xml
               bulk collect
               into l_xml_block_tab;

            l_fetched_count := l_xml_block_tab.count;

            prc_api_performance_pkg.finish_performance_metric(
                i_method_name   => 'generate_xml'
              , i_label_name    => 'fetch cur_xml'
              , i_fetched_count => l_fetched_count
            );

            close cur_xml;

            prc_api_performance_pkg.start_performance_metric(
                i_method_name   => 'generate_xml'
              , i_label_name    => 'for loop'
            );

            for i in 1 .. l_xml_block_tab.count
            loop

                l_xml_block := l_xml_block_tab(i);

                if l_xml_block is not null then
                    dbms_lob.writeappend(l_file, dbms_lob.getlength(l_xml_block), l_xml_block);
                end if;

            end loop;

            prc_api_performance_pkg.finish_performance_metric(
                i_method_name   => 'generate_xml'
              , i_label_name    => 'for loop'
              , i_fetched_count => l_fetched_count
            );

            l_xml_block := '</persons>';

            if l_xml_block is not null then
                dbms_lob.writeappend(l_file, dbms_lob.getlength(l_xml_block), l_xml_block);
            end if;

            prc_api_performance_pkg.start_performance_metric(
                i_method_name   => 'generate_xml'
              , i_label_name    => 'save_file'
            );

            save_file(
                i_counter  => l_fetched_count
            );

            if dbms_lob.isopen(l_file) = 1 then
                dbms_lob.close(l_file);
            end if;

            dbms_lob.freetemporary(lob_loc => l_file);

            prc_api_performance_pkg.finish_performance_metric(
                i_method_name   => 'generate_xml'
              , i_label_name    => 'save_file'
              , i_fetched_count => l_fetched_count
            );

            l_processed_count := l_processed_count + l_fetched_count;

            prc_api_stat_pkg.log_current(
                i_current_count  => l_processed_count
              , i_excepted_count => 0
            );
        end if;
    end generate_xml;

begin
    trc_log_pkg.debug(
        i_text       => 'export_persons: START with i_inst_id [#1], i_count [#2], l_full_export [#3]'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_count
      , i_env_param3 => l_full_export
    );

    prc_api_performance_pkg.reset_performance_metrics;

    l_lang           := coalesce(i_lang, com_ui_user_env_pkg.get_user_lang());
    l_sysdate        := com_api_sttl_day_pkg.get_sysdate;
    l_container_id   := prc_api_session_pkg.get_container_id;

    trc_log_pkg.debug(
        i_text       => 'l_lang [#1] l_container_id [#2]'
      , i_env_param1 => l_lang
      , i_env_param2 => l_container_id
    );

    prc_api_stat_pkg.log_start;

    prc_api_performance_pkg.start_performance_metric(
        i_method_name => 'export_persons'
      , i_label_name  => 'open_cur_objects'
    );

    open_cur_objects(
        o_cursor      => cur_objects
      , i_full_export => l_full_export
      , i_inst_id     => i_inst_id
    );

    prc_api_performance_pkg.finish_performance_metric(
        i_method_name => 'export_persons'
      , i_label_name  => 'open_cur_objects'
    );

    loop
        begin
            savepoint sp_before_iteration;

            if l_full_export = com_api_type_pkg.TRUE then

                prc_api_performance_pkg.start_performance_metric(
                    i_method_name   => 'export_persons'
                  , i_label_name    => 'fetch full export'
                );

                fetch cur_objects
                 bulk collect into
                      l_person_id_tab
                limit l_bulk_limit;

                prc_api_performance_pkg.finish_performance_metric(
                    i_method_name   => 'export_persons'
                  , i_label_name    => 'fetch full export'
                  , i_fetched_count => l_person_id_tab.count
                );

                trc_log_pkg.debug('l_person_id_tab.count = ' || l_person_id_tab.count);

                -- Generate XML file
                generate_xml;

            else

                prc_api_performance_pkg.start_performance_metric(
                    i_method_name   => 'export_persons'
                  , i_label_name    => 'fetch events'
                );

                fetch cur_objects
                 bulk collect into
                      l_fetched_event_object_id_tab
                    , l_fetched_person_id_tab
                limit l_bulk_limit;

                prc_api_performance_pkg.finish_performance_metric(
                    i_method_name   => 'export_persons'
                  , i_label_name    => 'fetch events'
                  , i_fetched_count => l_fetched_person_id_tab.count
                );

                trc_log_pkg.debug('l_fetched_person_id_tab.count = ' || l_fetched_person_id_tab.count || ', l_person_id = ' || l_person_id);

                l_person_id_tab := set(l_fetched_person_id_tab);

                if l_person_id is not null and l_person_id_tab.count > 0 and l_person_id = l_person_id_tab(l_person_id_tab.first) then
                    l_person_id_tab.delete(l_person_id_tab.first);
                end if;

                if l_person_id_tab.count > 0 then
                    l_person_id := l_person_id_tab(l_person_id_tab.last);
                    trc_log_pkg.debug('l_person_id_tab.count = ' || l_person_id_tab.count || ', l_person_id = ' || l_person_id);
                    -- Generate XML file for current portion of the "l_bulk_limit" records
                    generate_xml;
                end if;

                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab => l_fetched_event_object_id_tab
                );

                trc_log_pkg.debug('events were processed, cnt = ' || l_fetched_event_object_id_tab.count);

            end if;

            -- Commit the current iteration
            commit;

            exit when cur_objects%notfound;

        exception
            when others then
                rollback to sp_before_iteration;
                raise;
        end;
    end loop;

    close cur_objects;

    prc_api_stat_pkg.log_end(
        i_processed_total  => l_processed_count
      , i_excepted_total   => 0
      , i_rejected_total   => 0
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug('export_persons: FINISH: l_processed_count [' || l_processed_count || ']');

    -- Commit the last process changes before exit
    commit;

    prc_api_performance_pkg.print_performance_metrics(
        i_processed_count => l_processed_count
    );

exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        -- Commit the last process changes before exit
        commit;

        prc_api_performance_pkg.print_performance_metrics(
            i_processed_count => l_processed_count
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;
end export_persons;

procedure export_companies(
    i_inst_id                    in     com_api_type_pkg.t_inst_id
  , i_full_export                in     com_api_type_pkg.t_boolean    default null
  , i_lang                       in     com_api_type_pkg.t_dict_value default null
) is
    DEFAULT_PROCEDURE_NAME         constant com_api_type_pkg.t_name  := 'ISS_PRC_EXPORT_PKG.EXPORT_COMPANIES';

    l_estimated_count              com_api_type_pkg.t_long_id        := 0;
    l_processed_count              com_api_type_pkg.t_count          := 0;
    l_file_count                   com_api_type_pkg.t_count          := 0;
    l_file                         clob;
    l_full_export                  com_api_type_pkg.t_boolean        := nvl(i_full_export, com_api_type_pkg.FALSE);

    l_fetched_event_object_id_tab  com_api_type_pkg.t_number_tab;
    l_fetched_company_id_tab       num_tab_tpt                       := num_tab_tpt();

    l_company_id_tab               num_tab_tpt                       := num_tab_tpt();
    l_sysdate                      date;
    l_lang                         com_api_type_pkg.t_dict_value;

    cursor cur_xml is
        select xmlconcat(
                   xmlelement("company"
                     , xmlforest(c.id            as "company_id")
                     , xmlforest(c.incorp_form   as "incorp_form")
                     , (select xmlagg(
                                   xmlelement("company_name"
                                     , xmlattributes(nvl(l.lang, com_api_const_pkg.DEFAULT_LANGUAGE) as "language")
                                     , xmlforest(max(decode(i.column_name, 'LABEL', i.text, null)) as "company_short_name")
                                     , xmlforest(max(decode(i.column_name, 'DESCRIPTION', i.text, null)) as "company_full_name")
                                   )
                               )
                          from com_i18n  i
                         where i.table_name  = 'COM_COMPANY'
                           and i.object_id   = l.object_id
                           and i.lang       in (l.lang, com_api_const_pkg.DEFAULT_LANGUAGE)
                         group by 1
                       )
                     , (select xmlagg(xmlelement("identity_card"
                                 , xmlforest(
                                       o.id_type        as "id_type"
                                     , o.id_series      as "id_series"
                                     , o.id_number      as "id_number"
                                     , o.country        as "country"
                                     , o.id_issuer      as "id_issuer"
                                     , to_char(o.id_issue_date, com_api_const_pkg.XML_DATE_FORMAT)   as "id_issue_date"
                                     , to_char(o.id_expire_date, com_api_const_pkg.XML_DATE_FORMAT)  as "id_expire_date"
                                     , com_ui_id_object_pkg.get_id_card_desc(
                                           i_entity_type     => com_api_const_pkg.ENTITY_TYPE_COMPANY
                                         , i_object_id       => c.id
                                         , i_lang            => l.lang
                                       )                as "id_desc"
                                   )
                                      )
                               )
                          from com_id_object o
                         where o.entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY
                           and o.object_id = c.id
                       ) --identity_card
                   )
               ).getclobval()
          from com_company c
             , (select object_id, min(lang) keep(dense_rank first order by decode(lang, l_lang, 1, com_api_const_pkg.LANGUAGE_ENGLISH, 2, 3)) lang from com_i18n where table_name = 'COM_COMPANY' group by object_id) l
         where c.id   in (select/*+ cardinality(ids 10) */  column_value from table(cast(l_company_id_tab as num_tab_tpt)) ids)
           and c.id    = l.object_id;

    cur_objects             sys_refcursor;

    l_container_id         com_api_type_pkg.t_long_id;

    procedure open_cur_objects(
        o_cursor               out sys_refcursor
      , i_full_export       in     com_api_type_pkg.t_boolean
      , i_inst_id           in     com_api_type_pkg.t_inst_id
    ) is
    begin
        trc_log_pkg.debug('Opening a cursor for all persons processed...');

        if i_full_export = com_api_type_pkg.TRUE then
            -- Get all companies
            open o_cursor for
                select s.object_id
                  from prd_customer  s
                 where (s.inst_id = i_inst_id or i_inst_id is null)
                   and s.entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY;

        else
            -- Get current companies by events
            open o_cursor for
                select o.id         as event_object_id
                     , s.object_id  as company_id
                  from evt_event_object o
                     , prd_customer     s
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = DEFAULT_PROCEDURE_NAME
                   and o.eff_date              <= l_sysdate
                   and o.entity_type            = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                   and (o.inst_id               = i_inst_id       or i_inst_id       is null)
                   and (o.container_id          = l_container_id  or o.container_id  is null)
                   and o.object_id              = s.id
                   and s.entity_type            = com_api_const_pkg.ENTITY_TYPE_COMPANY
                 order by company_id;

        end if;

        trc_log_pkg.debug('Cursor was opened...');

    end open_cur_objects;

    procedure save_file(
        i_counter           in     com_api_type_pkg.t_count
    ) is
        l_params                   com_api_type_pkg.t_param_tab;
        l_report_id                com_api_type_pkg.t_short_id;
        l_report_template_id       com_api_type_pkg.t_short_id;
    begin
        trc_log_pkg.debug('Creating a new XML file, count=' || i_counter);

        rul_api_param_pkg.set_param (
            i_name          => 'INST_ID'
          , i_value         => i_inst_id
          , io_params       => l_params
        );

        l_file_count := l_file_count + 1;

        rul_api_param_pkg.set_param(
            i_name    => 'FILE_NUMBER'
          , i_value   => l_file_count
          , io_params => l_params
        );

        prc_api_file_pkg.save_file (
            i_file_type             => null
          , i_file_purpose          => prc_api_const_pkg.FILE_PURPOSE_OUT
          , io_params               => l_params
          , o_report_id             => l_report_id
          , o_report_template_id    => l_report_template_id
          , i_clob_content          => l_file
          , i_status                => prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count          => i_counter
        );

        trc_log_pkg.debug('file saved, count=' || i_counter || ', length=' || length(l_file));
    end save_file;

    -- Generate XML file
    procedure generate_xml is
        l_fetched_count           com_api_type_pkg.t_count    := 0;

        l_xml_block_tab           com_api_type_pkg.t_lob_tab;
        l_xml_block               com_api_type_pkg.t_lob_data;
    begin
        if l_company_id_tab.count() > 0 then

            l_estimated_count := nvl(l_estimated_count, 0) + l_company_id_tab.count;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
              , i_measure         => com_api_const_pkg.ENTITY_TYPE_COMPANY
            );

            trc_log_pkg.debug('Estimated count of companies is [' || l_estimated_count || ']');

            -- Create temporary LOB
            dbms_lob.createtemporary(lob_loc => l_file,
                                     cache   => true,
                                     dur     => dbms_lob.session);

            if dbms_lob.isopen(l_file) = 0 then
                dbms_lob.open(l_file, dbms_lob.lob_readwrite);
            end if;

            l_xml_block := com_api_const_pkg.XML_HEADER || CRLF
                        || '<companies xmlns="http://bpc.ru/sv/SVXP/companies">'
                        || '<file_type>' || iss_api_const_pkg.FILE_TYPE_COMP_INFO || '</file_type>'
                        || '<inst_id>'   || i_inst_id || '</inst_id>';

            if l_xml_block is not null then
                dbms_lob.writeappend(l_file, dbms_lob.getlength(l_xml_block), l_xml_block);
            end if;
            -- For every processing batch of persons we fetch data and save it in a separate file
            open cur_xml;

            fetch cur_xml
               bulk collect
               into l_xml_block_tab;

            l_fetched_count := l_xml_block_tab.count;

            close cur_xml;

            for i in 1 .. l_xml_block_tab.count
            loop

                l_xml_block := l_xml_block_tab(i);

                if l_xml_block is not null then
                    dbms_lob.writeappend(l_file, dbms_lob.getlength(l_xml_block), l_xml_block);
                end if;

            end loop;

            l_xml_block := '</companies>';

            if l_xml_block is not null then
                dbms_lob.writeappend(l_file, dbms_lob.getlength(l_xml_block), l_xml_block);
            end if;

            save_file(
                i_counter  => l_fetched_count
            );

            if dbms_lob.isopen(l_file) = 1 then
                dbms_lob.close(l_file);
            end if;

            dbms_lob.freetemporary(lob_loc => l_file);

            l_processed_count := l_processed_count + l_fetched_count;

            prc_api_stat_pkg.log_current(
                i_current_count  => l_processed_count
              , i_excepted_count => 0
            );
        end if;
    end generate_xml;

begin
    trc_log_pkg.debug(
        i_text       => 'export_companies: START with i_inst_id [#1], l_full_export [#2]'
      , i_env_param1 => i_inst_id
      , i_env_param2 => l_full_export
    );

    l_lang           := coalesce(i_lang, com_ui_user_env_pkg.get_user_lang());
    l_sysdate        := com_api_sttl_day_pkg.get_sysdate;
    l_container_id   := prc_api_session_pkg.get_container_id;

    trc_log_pkg.debug(
        i_text       => 'l_lang [#1] l_container_id [#2]'
      , i_env_param1 => l_lang
      , i_env_param2 => l_container_id
    );

    open_cur_objects(
        o_cursor      => cur_objects
      , i_full_export => l_full_export
      , i_inst_id     => i_inst_id
    );

    if l_full_export = com_api_type_pkg.TRUE then

        fetch cur_objects
         bulk collect into
              l_company_id_tab;

        trc_log_pkg.debug('l_company_id_tab.count = ' || l_company_id_tab.count);
        -- Generate XML file
        generate_xml;

    else

        fetch cur_objects
         bulk collect into
              l_fetched_event_object_id_tab
            , l_fetched_company_id_tab;

        trc_log_pkg.debug('l_fetched_company_id_tab.count = ' || l_fetched_company_id_tab.count);

        l_company_id_tab := set(l_fetched_company_id_tab);

        trc_log_pkg.debug('l_company_id_tab.count = ' || l_company_id_tab.count);

        generate_xml;

        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab => l_fetched_event_object_id_tab
        );

        trc_log_pkg.debug('events were processed, cnt = ' || l_fetched_event_object_id_tab.count);
    end if;

    close cur_objects;

    trc_log_pkg.debug('export_companies: FINISH: l_processed_count [' || l_processed_count || ']');
    -- Commit the last process changes before exit
    commit;

exception
    when others then
        -- Commit the last process changes before exit
        commit;

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;
end export_companies;

end iss_prc_export_pkg;
/
