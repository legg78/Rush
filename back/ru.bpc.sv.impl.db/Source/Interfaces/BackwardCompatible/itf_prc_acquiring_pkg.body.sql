create or replace package body itf_prc_acquiring_pkg is
/************************************************************
 * API for process files <br />
 * Created by Fomicnev A. (fomichev@bpcbt.com)  at 07.05.2018 <br />
 * Last changed by $Author: truschelev $ <br />
 * $LastChangedDate:: <br />
 * Revision: $LastChangedRevision: $ <br />
 * Module: itf_prc_card_export_pkg <br />
 * @headcom
 ***********************************************************/


CRLF                  constant  com_api_type_pkg.t_name := chr(13) || chr(10);

procedure process_merchant(
    i_inst_id                     in     com_api_type_pkg.t_inst_id
    , i_agent_id                  in     com_api_type_pkg.t_agent_id     default null
    , i_full_export               in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
    , i_unload_limits             in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
    , i_unload_accounts           in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
    , i_include_service           in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
    , i_count                     in     com_api_type_pkg.t_medium_id    default null
    , i_lang                      in     com_api_type_pkg.t_dict_value   default null
    , i_replace_inst_id_by_number in     com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
) is
    l_session_file_id      com_api_type_pkg.t_long_id;
    l_file                 clob;
    l_file_type            com_api_type_pkg.t_dict_value;
    l_container_id         com_api_type_pkg.t_long_id :=  prc_api_session_pkg.get_container_id;
    l_unload_limits        com_api_type_pkg.t_boolean;
    l_full_export          com_api_type_pkg.t_boolean;
    l_estimated_count      com_api_type_pkg.t_long_id := 0;
    l_lang                 com_api_type_pkg.t_dict_value;
    l_params               com_api_type_pkg.t_param_tab;

    l_event_tab            num_tab_tpt := num_tab_tpt();
    l_object_ids_tab       num_tab_tpt := num_tab_tpt();
    l_merchant_id_tab      num_tab_tpt := num_tab_tpt();
    l_bulk_limit           com_api_type_pkg.t_count := 2000;
    l_sysdate              date;
    l_unload_accounts      com_api_type_pkg.t_boolean;
    
    l_data_cur             sys_refcursor;

    l_include_service      com_api_type_pkg.t_boolean;
    l_service_id_tab       prd_service_tpt;
    l_eff_date             date;
    l_thread               com_api_type_pkg.t_tiny_id;
    l_inst_number          com_api_type_pkg.t_mcc;

    cursor all_merchant_cur(i_current_inst_id in    com_api_type_pkg.t_inst_id) is
        select m.id
          from acq_merchant m
             , prd_contract c
             , prd_customer s
         where m.split_hash in (select split_hash from com_api_split_map_vw)
           and (m.inst_id   = i_current_inst_id)
           and c.id         = m.contract_id
           and s.id         = c.customer_id
           and (c.agent_id  = i_agent_id or i_agent_id is null)
        ;

    cursor evt_objects_merchant_cur(i_current_inst_id in com_api_type_pkg.t_inst_id) is
        select o.id
             , m.id
          from evt_event_object o
             , acq_merchant m
             , prd_contract c
             , prd_customer s
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_PRC_ACQUIRING_PKG.PROCESS_MERCHANT'
           and m.split_hash in (select split_hash from com_api_split_map_vw)
           and o.eff_date     <= l_sysdate
           and (o.inst_id      = i_current_inst_id)
           and o.entity_type   = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
           and o.object_id     = m.id
           and m.inst_id       = o.inst_id
           and c.id            = m.contract_id
           and s.id            = c.customer_id
           and (c.agent_id     = i_agent_id or i_agent_id is null)
           and (o.container_id is null or o.container_id = l_container_id)      
    union all
        select o.id
             , m.id
          from evt_event_object o
             , acc_account_object ao
             , acq_merchant m
             , acc_account a
         where o.split_hash in (select split_hash from com_api_split_map_vw)
           and decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_PRC_ACQUIRING_PKG.PROCESS_MERCHANT'
           and o.eff_date      <= l_sysdate
           and (o.inst_id       = i_current_inst_id)
           and o.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
           and o.object_id      = ao.account_id
           and ao.entity_type   = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
           and ao.object_id     = m.id
           and ao.split_hash    = o.split_hash
           and m.inst_id        = o.inst_id
           and a.split_hash     = o.split_hash
           and a.id             = ao.account_id
           and (a.agent_id      = i_agent_id or i_agent_id is null)
           and (o.container_id is null or o.container_id = l_container_id)
    union all
        select case
                   when l_thread in (1, prc_api_const_pkg.DEFAULT_THREAD)
                   then o.id
                   else null
               end as event_object_id
             , m.id
          from evt_event_object o
             , evt_event e
             , prd_product p
             , prd_contract ct
             , acq_merchant m
         where l_unload_limits = com_api_type_pkg.TRUE
           and decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_PRC_ACQUIRING_PKG.PROCESS_MERCHANT'
           and o.entity_type  = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
           and o.eff_date     <= l_sysdate
           and e.id           = o.event_id
           and e.event_type  in (prd_api_const_pkg.EVENT_ATTRIBUTE_CHANGE_PRODUCT
                               , prd_api_const_pkg.EVENT_PRODUCT_ATTR_END_CHANGE)
           and p.id           = o.object_id
           and p.product_type = prd_api_const_pkg.PRODUCT_TYPE_ACQ
           and ct.product_id  = o.object_id
           and m.contract_id  = ct.id
           and ct.split_hash in (select split_hash from com_api_split_map_vw)
           and (o.inst_id      = i_current_inst_id)
           and (ct.agent_id    = i_agent_id or i_agent_id is null)
           and (o.container_id is null or o.container_id = l_container_id);

    cursor main_xml_cur(i_current_inst_id in    com_api_type_pkg.t_inst_id) is
        with products as (
            select connect_by_root id product_id
                 , level level_priority
                 , id parent_id
                 , product_type
                 , case when parent_id is null then 1 else 0 end top_flag
              from prd_product
           connect by prior parent_id = id
           --start with id = i_product_id
        )
        select
            xmlelement("applications", xmlattributes('http://sv.bpc.in/SVAP' as "xmlns")
              , xmlagg(xmlelement("application"
                  , xmlelement("application_date",    to_char(get_sysdate, com_api_const_pkg.XML_DATE_FORMAT))
                  , xmlelement("application_type",    app_api_const_pkg.APPL_TYPE_ACQUIRING)
                  , xmlelement("application_flow_id", 2003)
                  , xmlelement("application_status",  app_api_const_pkg.APPL_STATUS_PROC_READY)
                  , xmlelement("institution_id",      case nvl(i_replace_inst_id_by_number, com_api_const_pkg.FALSE)
                                                      when com_api_const_pkg.TRUE
                                                      then l_inst_number
                                                      else to_char(i_current_inst_id, com_api_const_pkg.XML_NUMBER_FORMAT)
                                                      end)
                  , xmlelement("agent_id",            m.agent_id)
                  , xmlelement("agent_number",        m.agent_number)
                  , xmlelement("agent_name",          get_text(
                                                          i_table_name  => 'ost_agent'
                                                        , i_column_name => 'name'
                                                        , i_object_id   => m.agent_id
                                                        , i_lang        => com_api_const_pkg.DEFAULT_LANGUAGE
                                                      ))
                  , xmlelement("customer", xmlattributes(m.customer_id as "id")
                      , xmlelement("command", app_api_const_pkg.COMMAND_CREATE_OR_UPDATE)
                      , xmlelement("customer_number", m.customer_number)
                      , xmlelement("contract", xmlattributes(m.contract_id as "id")
                          , xmlelement("command", app_api_const_pkg.COMMAND_CREATE_OR_UPDATE)
                          , xmlelement("contract_number", m.contract_number)
                          , xmlagg(xmlelement("merchant", xmlattributes(m.merchant_id as "id")
                              , xmlelement("command"        , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE)
                              , xmlelement("merchant_number", m.merchant_number)
                              , xmlelement("merchant_name"  , m.merchant_name)
                              , xmlelement("merchant_type"  , m.merchant_type)
                              , xmlelement("mcc"            , m.mcc)
                              , xmlelement("merchant_status", m.merchant_status)
                              , xmlelement("status_reason",
                                    evt_api_status_pkg.get_status_reason(
                                        i_entity_type   => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                      , i_object_id     => m.merchant_id
                                      , i_raise_error   => com_api_const_pkg.FALSE
                                    )
                                )
                              , xmlelement("risk_indicator" , m.risk_indicator)
                              , xmlelement("partner_id_code", m.partner_id_code)
                              , xmlelement("mc_assigned_id" , m.mc_assigned_id)
                              , (select xmlagg(
                                            xmlelement("merchant_card"
                                              , xmlelement("card_number",       iss_api_token_pkg.decode_card_number(i_card_number => min(n.card_number)))
                                              , xmlelement("sequential_number", max(i.seq_number))
                                              , xmlelement("is_active",         case max(i.state) when iss_api_const_pkg.CARD_STATE_ACTIVE then com_api_const_pkg.TRUE else com_api_const_pkg.FALSE end)
                                            )
                                        )
                                   from acc_account_object a
                                      , acc_account_object o
                                      , iss_card           c
                                      , iss_card_number    n
                                      , iss_card_instance  i
                                      , prd_contract       p
                                  where a.object_id   = m.merchant_id
                                    and a.split_hash  = m.split_hash
                                    and a.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                    and a.account_id  = o.account_id
                                    and o.split_hash  = m.split_hash
                                    and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                                    and o.object_id   = c.id
                                    and c.id          = n.card_id
                                    and c.id          = i.card_id
                                    and c.contract_id = p.id
                               group by n.card_number
                                ) -- end of cards
                              , (select xmlagg(
                                            xmlelement("contact"
                                              , xmlelement("command",        app_api_const_pkg.COMMAND_CREATE_OR_UPDATE)
                                              , xmlelement("contact_type",   min(o.contact_type))
                                              , xmlforest(
                                                    min(c.job_title)         as "job_title"
                                                  , min(c.preferred_lang)    as "preferred_lang"
                                                )
                                              , xmlagg(
                                                    xmlelement("contact_data"
                                                      , xmlelement("commun_method",  d.commun_method)
                                                      , xmlelement("commun_address", d.commun_address)
                                                    )
                                                )
                                            )
                                        )
                                   from com_contact_object o
                                      , com_contact_data d
                                      , com_contact c
                                  where entity_type  = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                    and object_id    = m.merchant_id
                                    and d.contact_id = o.contact_id
                                    and c.id         = d.contact_id
                               group by o.contact_type
                                      , c.preferred_lang
                                      , c.job_title
                                ) -- end of contact
                              , (select xmlagg(
                                            xmlelement("address", xmlattributes(a.id as "id")
                                              , xmlelement("command",      app_api_const_pkg.COMMAND_CREATE_OR_UPDATE)
                                              , xmlelement("address_type", a.address_type)
                                              , xmlelement("country",      com_api_country_pkg.get_external_country_code(
                                                                               i_internal_country_code => a.country
                                                                           )
                                                )
                                              , xmlelement("address_name"
                                                  , xmlelement("region",   a.region)
                                                  , xmlelement("city",     a.city)
                                                  , xmlelement("street",   a.street)
                                                )
                                              , xmlelement("house",        a.house)
                                              , xmlelement("apartment",    a.apartment)
                                              , xmlelement("postal_code",  a.postal_code)
                                              , xmlelement("place_code",   a.place_code)
                                              , xmlelement("region_code",  a.region_code)
                                              , com_api_flexible_data_pkg.generate_xml(
                                                    i_entity_type => com_api_const_pkg.ENTITY_TYPE_ADDRESS
                                                  , i_standard_id => cmn_api_const_pkg.STANDARD_ID_SV_FRONTEND
                                                  , i_object_id   => a.id
                                                )
                                            )
                                        )
                                   from (select a.id
                                              , o.address_type
                                              , a.country
                                              , a.region
                                              , a.city
                                              , a.street
                                              , a.house
                                              , a.apartment
                                              , a.postal_code
                                              , a.place_code
                                              , a.region_code
                                              , a.lang
                                              , o.object_id
                                              , row_number() over (partition by o.object_id, o.address_type
                                                                       order by decode(a.lang
                                                                                     , l_lang, -1
                                                                                     , com_api_const_pkg.DEFAULT_LANGUAGE, 0
                                                                                     , o.address_id)
                                                                  ) rn
                                           from com_address_object o
                                              , com_address a
                                          where o.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                            and a.id          = o.address_id
                                   ) a
                                  where a.rn        = 1
                                    and a.object_id = m.merchant_id
                                ) -- end of address
                                 -- services
                              , case when l_include_service = com_api_const_pkg.TRUE then
                                    case when l_full_export = com_api_const_pkg.TRUE then (
                                        select xmlagg(xmlelement("service"
                                                 , xmlattributes(s.service_type_id as "value")
                                                 , xmlelement("service_type",          s.service_type_id)
                                                 , xmlelement("service_type_name",     s.service_type_name)
                                                 , xmlelement("service_external_code", s.external_code)
                                                 , xmlelement("service_number",        s.service_number)
                                                 , xmlelement("is_active",             s.is_active)
                                                 , (select xmlagg(
                                                               xmlelement("service_attribute"
                                                                 , xmlelement("service_attribute_name",  attr.attr_name)
                                                                 , xmlelement("service_attribute_value", attr.attr_value)
                                                               )
                                                           )
                                                      from (
                                                          select attr_value
                                                               , row_number() over (partition by merchant_id, attr_name
                                                                                        order by decode(level_priority, 0, 0, 1)
                                                                                                      , level_priority
                                                                                                      , start_date desc
                                                                                                      , register_timestamp desc
                                                                                   ) rn
                                                               , merchant_id
                                                               , split_hash
                                                               , attr_name
                                                               , service_id
                                                            from (
                                                                select v.attr_value
                                                                     , 0 level_priority
                                                                     , a.object_type
                                                                     , v.register_timestamp
                                                                     , v.start_date
                                                                     , v.object_id  merchant_id
                                                                     , v.split_hash
                                                                     , a.attr_name
                                                                     , v.service_id
                                                                  from prd_attribute_value v
                                                                     , prd_attribute a
                                                                 where v.entity_type  = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                                                   and a.entity_type  is null
                                                                   and a.data_type    = com_api_const_pkg.DATA_TYPE_CHAR
                                                                   and a.id           = v.attr_id
                                                                   and v.service_id in (select id from table(cast(l_service_id_tab as prd_service_tpt)))
                                                                   and l_eff_date between nvl(v.start_date, l_eff_date)
                                                                                      and nvl(v.end_date, trunc(l_eff_date) + 1)
                                                             union all
                                                                select v.attr_value
                                                                     , p.level_priority
                                                                     , a.object_type
                                                                     , v.register_timestamp
                                                                     , v.start_date
                                                                     , r.id  merchant_id
                                                                     , r.split_hash
                                                                     , a.attr_name
                                                                     , v.service_id
                                                                  from products p
                                                                     , prd_attribute_value v
                                                                     , prd_attribute a
                                                                     , (select id, service_type_id from table(cast(l_service_id_tab as prd_service_tpt))) srv
                                                                     , prd_product_service ps
                                                                     , prd_contract c
                                                                     , acq_merchant r
                                                                 where v.service_id      = srv.id
                                                                   and v.object_id       = decode(a.definition_level, 'SADLSRVC', srv.id, p.parent_id)
                                                                   and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                                                   and v.attr_id         = a.id
                                                                   and a.service_type_id = srv.service_type_id
                                                                   and l_eff_date between nvl(v.start_date, l_eff_date)
                                                                                      and nvl(v.end_date, trunc(l_eff_date) + 1)
                                                                   and a.entity_type  is null
                                                                   and a.data_type       = com_api_const_pkg.DATA_TYPE_CHAR
                                                                   and ps.service_id     = srv.id
                                                                   and ps.service_id     = v.service_id
                                                                   and p.product_id      = ps.product_id
                                                                   and ps.product_id     = c.product_id
                                                                   and c.id              = r.contract_id
                                                                   and c.split_hash      = r.split_hash
                                                            ) tt
                                                      ) attr
                                                     where attr.rn          = 1
                                                       and attr.service_id  = s.id
                                                       and attr.merchant_id = b.object_id
                                                       and attr.split_hash  = b.split_hash
                                                   ) -- end of service_attribute
                                               )) -- xmlagg(xmlelement(...
                                          from table(cast(l_service_id_tab as prd_service_tpt)) s
                                             , prd_service_object b
                                         where b.service_id = s.id
                                           and b.object_id  = m.merchant_id
                                           and b.split_hash = m.split_hash
                                    ) else (
                                        select xmlagg(xmlelement("service"
                                                 , xmlattributes(s.service_type_id as "value")
                                                 , xmlelement("service_type",          s.service_type_id)
                                                 , xmlelement("service_type_name",     s.service_type_name)
                                                 , xmlelement("service_external_code", s.external_code)
                                                 , xmlelement("service_number",        s.service_number)
                                                 , xmlelement("is_active",             s.is_active)
                                                 , (select xmlagg(
                                                               xmlelement("service_attribute"
                                                                 , xmlelement("service_attribute_name",  attr.attr_name)
                                                                 , xmlelement("service_attribute_value", attr.attr_value)
                                                               )
                                                           )
                                                      from (
                                                          select attr_value
                                                               , row_number() over (partition by merchant_id, attr_name
                                                                                        order by decode(level_priority, 0, 0, 1)
                                                                                                      , level_priority
                                                                                                      , start_date desc
                                                                                                      , register_timestamp desc
                                                                                   ) rn
                                                               , merchant_id
                                                               , split_hash
                                                               , attr_name
                                                               , service_id
                                                            from (
                                                                select v.attr_value
                                                                     , 0 level_priority
                                                                     , a.object_type
                                                                     , v.register_timestamp
                                                                     , v.start_date
                                                                     , v.object_id  merchant_id
                                                                     , v.split_hash
                                                                     , a.attr_name
                                                                     , v.service_id
                                                                  from prd_attribute_value v
                                                                     , prd_attribute a
                                                                 where v.entity_type  = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                                                   and a.entity_type  is null
                                                                   and a.data_type    = com_api_const_pkg.DATA_TYPE_CHAR
                                                                   and a.id           = v.attr_id
                                                                   and v.service_id in (select id from table(cast(l_service_id_tab as prd_service_tpt)))
                                                                   and l_eff_date between nvl(v.start_date, l_eff_date)
                                                                                      and nvl(v.end_date, trunc(l_eff_date) + 1)
                                                             union all
                                                                select v.attr_value
                                                                     , p.level_priority
                                                                     , a.object_type
                                                                     , v.register_timestamp
                                                                     , v.start_date
                                                                     , r.id  merchant_id
                                                                     , r.split_hash
                                                                     , a.attr_name
                                                                     , v.service_id
                                                                  from products p
                                                                     , prd_attribute_value v
                                                                     , prd_attribute a
                                                                     , (select id, service_type_id from table(cast(l_service_id_tab as prd_service_tpt))) srv                                                                                        -- , prd_service_type st
                                                                     , prd_product_service ps
                                                                     , prd_contract c
                                                                     , acq_merchant r
                                                                 where v.service_id      = srv.id
                                                                   and v.object_id       = decode(a.definition_level, 'SADLSRVC', srv.id, p.parent_id)
                                                                   and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                                                   and v.attr_id         = a.id
                                                                   and a.service_type_id = srv.service_type_id
                                                                   and l_eff_date between nvl(v.start_date, l_eff_date)
                                                                                      and nvl(v.end_date, trunc(l_eff_date) + 1)
                                                                   and a.entity_type  is null
                                                                   and a.data_type       = com_api_const_pkg.DATA_TYPE_CHAR
                                                                   and ps.service_id     = srv.id
                                                                   and ps.service_id     = v.service_id
                                                                   and p.product_id      = ps.product_id
                                                                   and ps.product_id     = c.product_id
                                                                   and c.id              = r.contract_id
                                                                   and c.split_hash      = r.split_hash
                                                            ) tt
                                                      ) attr
                                                     where attr.rn          = 1
                                                       and attr.service_id  = s.id
                                                       and attr.merchant_id = b.object_id
                                                       and attr.split_hash  = b.split_hash
                                                   ) -- end of service_attribute
                                               )) -- xmlagg(xmlelement("service"...
                                          from evt_event_object o
                                             , evt_event e
                                             , table(cast(l_service_id_tab as prd_service_tpt)) s
                                             , prd_service_object b
                                         where o.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                           and decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_PRC_ACQUIRING_PKG.PROCESS_MERCHANT'
                                           and o.object_id    = m.merchant_id
                                           and o.split_hash   = m.split_hash
                                           and o.eff_date    <= l_sysdate
                                           and e.id           = o.event_id
                                           and s.event_type   = e.event_type
                                           and s.id           = b.service_id
                                           and o.object_id    = b.object_id
                                           and o.entity_type  = b.entity_type
                                           and o.split_hash   = b.split_hash
                                    )
                                    end
                                end
                              , com_api_flexible_data_pkg.generate_xml(
                                    i_entity_type => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                  , i_standard_id => cmn_api_const_pkg.STANDARD_ID_SV_FRONTEND
                                  , i_object_id   => m.merchant_id) -- merchant flexible fileds
                            )) --xmlagg(xmlelement("merchant"
                          , case when l_unload_limits = com_api_const_pkg.TRUE then (
                                select xmlelement("service"
                                         , xmlelement("service_object", xmlattributes(x.merchant_id as "id")
                                             , xmlagg(xmlelement("attribute_limit"
                                                 , xmlelement("limit_type",        l.limit_type)
                                                 , xmlelement("limit_sum_value",   nvl(l.sum_limit, 0))
                                                 , xmlelement("limit_count_value", nvl(l.count_limit, 0))
                                                 , xmlelement("sum_current",       nvl(fcl_api_limit_pkg.get_limit_sum_curr(
                                                                                           i_limit_type  => l.limit_type
                                                                                         , i_entity_type => x.entity_type
                                                                                         , i_object_id   => x.object_id
                                                                                         , i_limit_id    => l.id
                                                                                       )
                                                                                     , 0))
                                                 , xmlelement("currency",          l.currency)
                                                 , xmlelement("length_type",       c.length_type)
                                                 , xmlelement("cycle_length",      c.cycle_length)
                                               ))
                                           )
                                       )
                                  from (
                                           select ao.object_id as merchant_id
                                                , x.limit_type
                                                , ao.split_hash
                                                , ao.account_id as object_id
                                                , x.entity_type
                                             from acc_account_object ao
                                                , (
                                                   select distinct
                                                          a.object_type limit_type
                                                        , t.entity_type
                                                     from prd_attribute a
                                                        , prd_service_type t
                                                    where t.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                      and a.service_type_id = t.id
                                                      and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                                                  ) x
                                             where ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                               union all
                                             select m.id as merchant_id
                                                  , x.limit_type
                                                  , m.split_hash
                                                  , m.id as object_id
                                                  , x.entity_type
                                               from acq_merchant m
                                                  , (
                                                       select distinct
                                                              a.object_type limit_type
                                                            , t.entity_type
                                                         from prd_attribute a
                                                            , prd_service_type t
                                                        where t.entity_type     = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                                          and a.service_type_id = t.id
                                                          and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                                                    ) x
                                       ) x
                                     , fcl_limit l
                                     , fcl_cycle c
                                 where x.merchant_id  = m.merchant_id
                                   and l.id           = prd_api_product_pkg.get_limit_id(
                                                            i_entity_type => x.entity_type
                                                          , i_object_id   => x.object_id
                                                          , i_limit_type  => x.limit_type
                                                          , i_split_hash  => x.split_hash
                                                          , i_mask_error  => com_api_const_pkg.TRUE
                                                        )
                                   and c.id(+)       =  l.cycle_id
                              group by x.merchant_id
                            )
                            end
                          , case when l_unload_accounts = com_api_const_pkg.TRUE then (
                                select xmlagg(xmlelement("account"
                                         , xmlforest(
                                               app_api_const_pkg.COMMAND_CREATE_OR_UPDATE as "command"
                                             , ac.account_number                          as "account_number"
                                             , ac.currency                                as "currency"
                                             , ac.account_type                            as "account_type"
                                             , ac.status                                  as "account_status"
                                           )
                                         , com_api_flexible_data_pkg.generate_xml(
                                               i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                             , i_standard_id => cmn_api_const_pkg.STANDARD_ID_SV_FRONTEND
                                             , i_object_id   => ac.id
                                           )
                                       ))
                                  from acc_account ac
                                     , acc_account_object ao
                                 where ao.split_hash  = m.split_hash
                                   and ac.split_hash  = ao.split_hash
                                   and ac.id          = ao.account_id
                                   and ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                   and ao.object_id   = m.merchant_id
                            )
                            end
                          , com_api_flexible_data_pkg.generate_xml(
                                i_entity_type => com_api_const_pkg.ENTITY_TYPE_CONTRACT
                              , i_standard_id => cmn_api_const_pkg.STANDARD_ID_SV_FRONTEND
                              , i_object_id   => m.contract_id
                            )
                        ) -- xmlelement("contract"...
                      , com_api_flexible_data_pkg.generate_xml(
                            i_entity_type => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                          , i_standard_id => cmn_api_const_pkg.STANDARD_ID_SV_FRONTEND
                          , i_object_id   => m.customer_id
                        )
                    ) -- xmlelement("customer"...
                )) -- xmlagg(xmlelement("application"...
            ).getclobval()
        from (
            select m.id as merchant_id
                 , m.inst_id
                 , m.merchant_name
                 , m.merchant_number
                 , m.status as merchant_status
                 , m.mcc
                 , m.merchant_type
                 , m.split_hash
                 , m.risk_indicator
                 , c.id as contract_id
                 , c.contract_number
                 , s.id as customer_id
                 , s.customer_number
                 , c.agent_id
                 , a.agent_number
                 , m.partner_id_code
                 , m.mc_assigned_id
              from acq_merchant m
                 , prd_contract c
                 , prd_customer s
                 , ost_agent    a
             where m.id in (select column_value from table(cast(l_merchant_id_tab as num_tab_tpt)))
               and c.id = m.contract_id
               and s.id = c.customer_id
               and a.id = c.agent_id
        ) m
    group by
        m.customer_number
      , m.customer_id
      , m.contract_number
      , m.contract_id
      , m.merchant_id
      , m.agent_id
      , m.agent_number
      , m.split_hash
      , m.partner_id_code
    ;

    procedure save_file(i_current_inst_id in    com_api_type_pkg.t_inst_id) is
        l_cnt   pls_integer;
    begin
        rul_api_param_pkg.set_param (
            i_name       => 'INST_ID'
            , i_value    => i_current_inst_id
            , io_params  => l_params
        );

        prc_api_file_pkg.open_file(
            o_sess_file_id => l_session_file_id
          , i_file_type    => l_file_type
          , io_params      => l_params
        );

        l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

        prc_api_file_pkg.put_file(
            i_sess_file_id  => l_session_file_id
          , i_clob_content  => l_file
        );

        l_cnt := l_merchant_id_tab.count;

        prc_api_file_pkg.close_file(
            i_sess_file_id   => l_session_file_id
          , i_status         => prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count   => l_cnt
        );

        trc_log_pkg.debug('file saved, cnt=' || l_cnt || ', length=' || length(l_file));

        prc_api_stat_pkg.log_current(
            i_current_count  => l_cnt
          , i_excepted_count => 0
        );
    end save_file;

begin
    trc_log_pkg.debug('process_merchant - Start, inst_id = ' || i_inst_id);

    prc_api_stat_pkg.log_start;
    savepoint sp_merchant_export;

    l_estimated_count := 0;

    if i_full_export = com_api_const_pkg.TRUE then
      
          select l_estimated_count + count(1)
          into l_estimated_count
          from acq_merchant m
             , prd_contract c
             , prd_customer s
         where m.split_hash in (select x.split_hash from com_api_split_map_vw x)
           and (m.inst_id    = i_inst_id or i_inst_id is null or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
           and c.id          = m.contract_id
           and s.id          = c.customer_id
           and (c.agent_id   = i_agent_id or i_agent_id is null)
        ;

        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_estimated_count
          , i_measure         => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
        );
    end if;
    for inst in (
            select i.id 
              from ost_institution_vw i
             where (i.id = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST or i_inst_id is null)
               and i.id != ost_api_const_pkg.UNIDENTIFIED_INST
        ) loop
  
        l_inst_number := ost_api_institution_pkg.get_inst_number(
                             i_inst_id => inst.id
                         );

        select min(file_type)
          into l_file_type
          from prc_file_attribute a
             , prc_file f
         where a.container_id = l_container_id
           and a.file_id      = f.id
           and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

        l_unload_limits   := nvl(i_unload_limits, com_api_type_pkg.FALSE);
        l_full_export     := nvl(i_full_export, com_api_type_pkg.FALSE);
        l_lang            := nvl(i_lang, com_ui_user_env_pkg.get_user_lang());
        l_bulk_limit      := nvl(i_count, l_bulk_limit);
        l_sysdate         := get_sysdate;
        l_unload_accounts := nvl(i_unload_accounts, com_api_type_pkg.FALSE);
        l_include_service := nvl(i_include_service, com_api_type_pkg.FALSE);
        l_eff_date        := com_api_sttl_day_pkg.get_calc_date(i_inst_id => inst.id);
        l_thread          := prc_api_session_pkg.get_thread_number();

        trc_log_pkg.debug(
            i_text       =>'process_merchant, container_id=#1, inst=#2, agent=#3, full_export=#4, unload_limits=#5, thread_number=#6'
          , i_env_param1 => l_container_id
          , i_env_param2 => inst.id
          , i_env_param3 => i_agent_id
          , i_env_param4 => l_full_export
          , i_env_param5 => l_unload_limits
          , i_env_param6 => get_thread_number
        );

        trc_log_pkg.debug(
            i_text       =>'l_unload_accounts=#1, l_include_service=#2'
          , i_env_param1 => l_unload_accounts
          , i_env_param2 => l_include_service
        );

        if l_include_service = com_api_type_pkg.TRUE then
            if l_full_export = com_api_type_pkg.FALSE then
                select prd_service_tpr(
                           s.id
                         , t.id
                         , t.service_type_name
                         , t.external_code
                         , s.service_number
                         , t.is_active
                         , t.event_type
                     )
                  bulk collect into l_service_id_tab
                  from prd_service s
                 , (
                    select id
                         , enable_event_type event_type
                         , get_text ('prd_service_type', 'label', id, l_lang) service_type_name
                         , external_code
                         , 1 is_active
                      from prd_service_type
                     where entity_type  = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       and product_type = prd_api_const_pkg.PRODUCT_TYPE_ACQ
                    union
                    select id
                         , disable_event_type event_type
                         , get_text ('prd_service_type', 'label', id, l_lang) service_type_name
                         , external_code
                         , 0 is_active
                      from prd_service_type
                     where entity_type  = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       and product_type = prd_api_const_pkg.PRODUCT_TYPE_ACQ
                   ) t
               where s.service_type_id = t.id;

            else
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
                  bulk collect into l_service_id_tab
                  from prd_service_type t
                     , prd_service s
                 where entity_type  = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   and product_type = prd_api_const_pkg.PRODUCT_TYPE_ACQ
                   and s.service_type_id = t.id;
            end if;
        end if;

        if l_full_export = com_api_type_pkg.TRUE then
            trc_log_pkg.debug(
                i_text => 'Process Institution ' || inst.id
            );

            open all_merchant_cur(i_current_inst_id => inst.id);

            loop
                fetch all_merchant_cur bulk collect into
                      l_merchant_id_tab
                limit l_bulk_limit;

                -- generate xml
                if l_merchant_id_tab.count > 0 then
                    open  main_xml_cur(i_current_inst_id => inst.id);
                    fetch main_xml_cur into l_file;
                    close main_xml_cur;

                    save_file(i_current_inst_id => inst.id);
                end if;

                exit when all_merchant_cur%notfound;
            end loop;

            close all_merchant_cur;

        else
            l_estimated_count := 0;

            open evt_objects_merchant_cur(i_current_inst_id => inst.id);

            fetch evt_objects_merchant_cur
                bulk collect
                into l_event_tab
                   , l_object_ids_tab;

            close evt_objects_merchant_cur;
                
            -- Decrease operation count
            l_object_ids_tab := set(l_object_ids_tab);
                
            -- Get estimated count
            l_estimated_count := l_estimated_count + l_object_ids_tab.count;

            trc_log_pkg.debug(
                i_text => 'Process Institution ' || inst.id ||', Estimate count = [' || l_estimated_count || ']'
            );

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
              , i_measure         => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
            );

            open l_data_cur for
                select column_value
                  from table(cast(l_object_ids_tab as num_tab_tpt));

            loop
                fetch l_data_cur
                    bulk collect
                    into l_merchant_id_tab
                   limit l_bulk_limit;

                -- generate xml
                if l_merchant_id_tab.count > 0 then
                    open  main_xml_cur(i_current_inst_id => inst.id);
                    fetch main_xml_cur into l_file;
                    close main_xml_cur;

                    save_file(i_current_inst_id => inst.id);
                end if;

                exit when l_data_cur%notfound;
            end loop;
            close l_data_cur;

            -- Mark processed event object
            evt_api_event_pkg.process_event_object (
                i_event_object_id_tab  => l_event_tab
            );
            l_event_tab.delete;
        end if;

        prc_api_stat_pkg.log_end(
            i_processed_total   => l_estimated_count
          , i_excepted_total    => 0
          , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
    end loop;
    trc_log_pkg.debug('process_merchant - End');

exception
    when others then
        rollback to sp_merchant_export;

        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        
        if l_data_cur%isopen then
            close l_data_cur;
        end if;

        if evt_objects_merchant_cur%isopen then
            close evt_objects_merchant_cur;
        end if;

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
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
end process_merchant;

procedure process_terminal(
    i_inst_id                   in     com_api_type_pkg.t_inst_id
  , i_agent_id                  in     com_api_type_pkg.t_agent_id     default null
  , i_full_export               in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits             in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service           in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count                     in     com_api_type_pkg.t_medium_id    default null
  , i_lang                      in     com_api_type_pkg.t_dict_value   default null
  , i_replace_inst_id_by_number in     com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
) is
    l_session_file_id      com_api_type_pkg.t_long_id;
    l_file                 clob;
    l_file_type            com_api_type_pkg.t_dict_value;
    l_container_id         com_api_type_pkg.t_long_id :=  prc_api_session_pkg.get_container_id;
    l_unload_limits        com_api_type_pkg.t_boolean;
    l_full_export          com_api_type_pkg.t_boolean;
    l_estimated_count      com_api_type_pkg.t_long_id := 0;
    l_lang                 com_api_type_pkg.t_dict_value;
    l_params               com_api_type_pkg.t_param_tab;

    l_event_tab            num_tab_tpt := num_tab_tpt();
    l_object_ids_tab       num_tab_tpt := num_tab_tpt();
    l_terminal_id_tab      num_tab_tpt := num_tab_tpt();
    l_bulk_limit           com_api_type_pkg.t_count := 2000;
    l_sysdate              date;
    l_data_cur             sys_refcursor;
    l_include_service      com_api_type_pkg.t_boolean;
    l_service_id_tab       prd_service_tpt;
    l_eff_date             date;
    l_thread               com_api_type_pkg.t_tiny_id;
    l_inst_number          com_api_type_pkg.t_mcc;

    cursor all_terminal_cur(i_current_inst_id in     com_api_type_pkg.t_inst_id) is
        select t.id
          from acq_terminal t
             , prd_contract c
         where t.split_hash in (select split_hash from com_api_split_map_vw)
           and (t.inst_id       = i_current_inst_id)
           and c.id             = t.contract_id
           and (c.agent_id      = i_agent_id or i_agent_id is null)
           and t.is_template    = com_api_type_pkg.FALSE
        ;

    cursor evt_objects_terminal_cur(i_current_inst_id in    com_api_type_pkg.t_inst_id) is
        select o.id
             , t.id
          from evt_event_object o
             , acq_terminal t
             , prd_contract c
         where o.split_hash in (select split_hash from com_api_split_map_vw)
           and decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_PRC_ACQUIRING_PKG.PROCESS_TERMINAL'
           and o.eff_date      <= l_sysdate
           and (t.inst_id       = i_current_inst_id)
           and o.entity_type    = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
           and o.object_id      = t.id
           and o.split_hash     = t.split_hash
           and t.inst_id        = o.inst_id
           and c.id             = t.contract_id
           and (c.agent_id      = i_agent_id or i_agent_id is null)
           and t.is_template    = com_api_type_pkg.FALSE
           and (o.container_id is null or o.container_id = l_container_id)      
     union all
        select o.id
             , t.id
          from evt_event_object o
             , acc_account_object ao
             , acq_terminal t
             , prd_contract c
         where o.split_hash in (select split_hash from com_api_split_map_vw)
           and decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_PRC_ACQUIRING_PKG.PROCESS_TERMINAL'
           and o.eff_date      <= l_sysdate
           and (o.inst_id       = i_current_inst_id)
           and o.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
           and o.object_id      = ao.account_id
           and ao.split_hash    = o.split_hash
           and t.split_hash     = o.split_hash
           and ao.entity_type   = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
           and ao.object_id     = t.id
           and t.inst_id        = o.inst_id
           and c.id             = t.contract_id
           and (c.agent_id      = i_agent_id or i_agent_id is null)
           and t.is_template    = com_api_type_pkg.FALSE
           and (o.container_id is null or o.container_id = l_container_id)
     union all
        select case
                   when l_thread in (1, prc_api_const_pkg.DEFAULT_THREAD)
                   then o.id
                   else null
               end as event_object_id
             , t.id
          from evt_event_object o
             , evt_event e
             , prd_product p
             , prd_contract ct
             , acq_terminal t
         where l_unload_limits = com_api_type_pkg.TRUE
           and decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_PRC_ACQUIRING_PKG.PROCESS_TERMINAL'
           and o.entity_type  = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
           and o.eff_date     <= l_sysdate
           and e.id           = o.event_id
           and e.event_type  in (prd_api_const_pkg.EVENT_ATTRIBUTE_CHANGE_PRODUCT
                               , prd_api_const_pkg.EVENT_PRODUCT_ATTR_END_CHANGE)
           and p.id           = o.object_id
           and p.product_type = prd_api_const_pkg.PRODUCT_TYPE_ACQ
           and ct.product_id  = o.object_id
           and t.contract_id  = ct.id
           and ct.split_hash in (select split_hash from com_api_split_map_vw)
           and (o.inst_id     = i_current_inst_id)
           and (ct.agent_id   = i_agent_id or i_agent_id is null)
           and (o.container_id is null or o.container_id = l_container_id);

    cursor main_xml_cur(i_current_inst_id   in   com_api_type_pkg.t_inst_id) is
        select
            xmlelement("applications", xmlattributes('http://sv.bpc.in/SVAP' as "xmlns")
              , xmlagg(xmlelement("application"
                  , xmlelement("application_date",    to_char(get_sysdate, com_api_const_pkg.XML_DATE_FORMAT))
                  , xmlelement("application_type",    app_api_const_pkg.APPL_TYPE_ACQUIRING)
                  , xmlelement("application_flow_id", 2003)
                  , xmlelement("application_status",  app_api_const_pkg.APPL_STATUS_PROC_READY)
                  , xmlelement("institution_id",      case nvl(i_replace_inst_id_by_number, com_api_const_pkg.FALSE)
                                                      when com_api_const_pkg.TRUE
                                                      then l_inst_number
                                                      else to_char(i_current_inst_id, com_api_const_pkg.XML_NUMBER_FORMAT)
                                                      end)
                  , xmlelement("agent_id",            t.agent_id)
                  , xmlelement("agent_number",        t.agent_number)
                  , xmlelement("agent_name",          get_text(
                                                          i_table_name  => 'ost_agent'
                                                        , i_column_name => 'name'
                                                        , i_object_id   => t.agent_id
                                                        , i_lang        => com_api_const_pkg.DEFAULT_LANGUAGE
                                                      ))
                  , xmlelement("customer", xmlattributes(t.customer_id as "id")
                      , xmlelement("command",     app_api_const_pkg.COMMAND_CREATE_OR_UPDATE)
                      , xmlelement("customer_number",     t.customer_number)
                      , xmlelement("contract",  xmlattributes(t.contract_id as "id")
                          , xmlelement("command",     app_api_const_pkg.COMMAND_CREATE_OR_UPDATE)
                          , xmlelement("contract_number",     t.contract_number)
                          , xmlelement("merchant",  xmlattributes(t.merchant_id as "id")
                              , xmlelement("command",     app_api_const_pkg.COMMAND_CREATE_OR_UPDATE)
                              , xmlelement("merchant_number",     t.merchant_number)
                              , xmlagg(xmlelement("terminal", xmlattributes(t.terminal_id as "id")
                                  , xmlforest(
                                        app_api_const_pkg.COMMAND_CREATE_OR_UPDATE as "command"
                                      , t.terminal_number                          as "terminal_number"
                                      , t.terminal_type                            as "terminal_type"
                                      , t.mcc                                      as "mcc"
                                      , t.plastic_number                           as "plastic_number"
                                      , t.card_data_input_cap                      as "card_data_input_cap"
                                      , t.crdh_auth_cap                            as "crdh_auth_cap"
                                      , t.card_capture_cap                         as "card_capture_cap"
                                      , t.term_operating_env                       as "term_operating_env"
                                      , t.crdh_data_present                        as "crdh_data_present"
                                      , t.card_data_present                        as "card_data_present"
                                      , t.card_data_input_mode                     as "card_data_input_mode"
                                      , t.crdh_auth_method                         as "crdh_auth_method"
                                      , t.crdh_auth_entity                         as "crdh_auth_entity"
                                      , t.card_data_output_cap                     as "card_data_output_cap"
                                      , t.term_data_output_cap                     as "term_data_output_cap"
                                      , t.pin_capture_cap                          as "pin_capture_cap"
                                      , t.cat_level                                as "cat_level"
                                      , t.terminal_status                          as "terminal_status"
                                      , evt_api_status_pkg.get_status_reason(
                                            i_entity_type   => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                          , i_object_id     => t.terminal_id
                                          , i_raise_error   => com_api_const_pkg.FALSE
                                        )                                          as "status_reason"
                                      , t.device_id                                as "device_id"
                                      , t.gmt_offset                               as "gmt_offset"
                                      , t.is_mac                                   as "is_mac"
                                      , t.cash_dispenser_present                   as "cash_dispenser_present"
                                      , t.payment_possibility                      as "payment_possibility"
                                      , t.use_card_possibility                     as "use_card_possibility"
                                      , t.cash_in_present                          as "cash_in_present"
                                      , t.available_network                        as "available_network"
                                      , t.available_operation                      as "available_operation"
                                      , t.available_currency                       as "available_currency"
                                      , t.terminal_quantity                        as "terminal_quantity"
                                      , t.instalment_support                       as "instalment_support"
                                      , t.terminal_profile                         as "terminal_profile"
--                                      , t.pin_block_format                         as "pin_block_format"
                                    )
--                                  , xmlelement("tcp_ip"
--                                      , xmlelement("remote_address",         t.remote_address)
--                                      , xmlelement("local_port",             t.local_port)
--                                      , xmlelement("remote_port",            t.remote_port)
--                                      , xmlelement("initiator",              t.initiator)
--                                      , xmlelement("format",                 t.format)
--                                      , xmlelement("keep_alive",             t.keep_alive)
--                                      , xmlelement("monitor_connection",     t.monitor_connection)
--                                      , xmlelement("multiple_connection",    t.multiple_connection)
--                                    )
                                  , case -- check all mandatory fileds in according to XSD-scheme
                                        when t.remote_address is not null
                                         and t.initiator      is not null
                                         and t.format         is not null
                                        then
                                        xmlelement("tcp_ip"
                                          , xmlforest(
                                                t.remote_address                   as "remote_address"
                                              , t.local_port                       as "local_port"
                                              , t.remote_port                      as "remote_port"
                                              , t.initiator                        as "initiator"
                                              , t.format                           as "format"
                                              , t.keep_alive                       as "keep_alive"
                                              , t.monitor_connection               as "monitor_connection"
                                              , t.multiple_connection              as "multiple_connection"
                                            )
                                        )
                                    end -- enf of tcp_ip
                                  , (select xmlagg(
                                                xmlelement("contact"
                                                  , xmlelement("command",          app_api_const_pkg.COMMAND_CREATE_OR_UPDATE)
                                                  , xmlelement("contact_type",     min(o.contact_type))
                                                  , xmlforest(
                                                        min(c.job_title)         as "job_title"
                                                      , min(c.preferred_lang)    as "preferred_lang"
                                                    )
                                                  , xmlagg(
                                                        xmlelement("contact_data"
                                                          , xmlelement("commun_method",  d.commun_method)
                                                          , xmlelement("commun_address", d.commun_address)
                                                        )
                                                    )
                                                )
                                            )
                                       from com_contact_object o
                                          , com_contact_data d
                                          , com_contact c
                                      where entity_type  = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                        and object_id    = t.terminal_id
                                        and d.contact_id = o.contact_id
                                        and c.id         = d.contact_id
                                   group by o.contact_type
                                          , c.preferred_lang
                                          , c.job_title
                                    )
                                  , (select xmlagg(
                                                xmlelement("encryption"
                                                  , xmlelement("encryption_key_type",        e.key_type)
                                                  , xmlelement("encryption_key_prefix",      e.key_prefix)
                                                  , xmlelement("encryption_key",             e.key_value)
                                                  , xmlelement("encryption_key_length",      e.key_length)
                                                  , xmlelement("encryption_key_check_value", e.check_value)
                                                  , case
                                                        when e.key_type = sec_api_const_pkg.SECURITY_DES_KEY_TMKP
                                                         and t.pin_block_format is not null
                                                        then xmlelement("pin_block_format", t.pin_block_format)
                                                        else null
                                                    end
                                                )
                                            )
                                       from sec_des_key e
                                      where entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                        and object_id   = t.terminal_id
                                        and e.key_type in (sec_api_const_pkg.SECURITY_DES_KEY_TMKA
                                                         , sec_api_const_pkg.SECURITY_DES_KEY_TMKP)
                                        and e.key_index = (select max(key_index)
                                                             from sec_des_key k
                                                            where k.entity_type = e.entity_type
                                                              and k.object_id   = e.object_id
                                                              and k.key_type    = e.key_type)
                                    )
                                  , case when t.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM then (
                                        select xmlelement("atm_terminal"
                                                 , xmlforest(
                                                       t.atm_type               as "atm_type"
                                                     , t.atm_model              as "atm_model"
                                                     , t.serial_number          as "serial_number"
                                                     , t.placement_type         as "placement_type"
                                                     , t.availability_type      as "availability_type"
                                                     , t.operating_hours        as "operating_hours"
                                                     , t.local_date_gap         as "local_date_gap"
                                                     , t.cassette_count         as "cassette_count"
                                                     , t.hopper_count           as "hopper_count"
                                                     , t.key_change_algo        as "key_change_algorithm"
                                                     , t.counter_sync_cond      as "counter_sync_cond"
                                                     , t.reject_disp_warn       as "reject_disp_warn"
                                                     , t.reject_disp_min_warn   as "reject_disp_min_warn"
                                                     , t.disp_rest_warn         as "disp_rest_warn"
                                                     , t.receipt_warn           as "receipt_warn"
                                                     , t.card_capture_warn      as "card_capture_warn"
                                                     , t.note_max_count         as "note_max_count"
                                                     , t.scenario_id            as "scenario_id"
                                                     , t.manual_synch           as "manual_synch"
                                                     , t.establ_conn_synch      as "establ_conn_synch"
                                                     , t.counter_mismatch_synch as "counter_mismatch_synch"
                                                     , t.online_in_synch        as "online_in_synch"
                                                     , t.online_out_synch       as "online_out_synch"
                                                     , t.safe_close_synch       as "safe_close_synch"
                                                     , t.disp_error_synch       as "disp_error_synch"
                                                     , t.periodic_synch         as "periodic_synch"
                                                     , t.periodic_all_oper      as "periodic_all_oper"
                                                     , t.periodic_oper_count    as "periodic_oper_count"
                                                     , t.cash_in_min_warn       as "cash_in_min_warn"
                                                     , t.cash_in_max_warn       as "cash_in_max_warn"
                                                   )
                                                   --atm_dispenser
                                                 , (select xmlagg(
                                                               xmlelement("atm_dispenser"
                                                                 , xmlattributes(d.id as "id")
                                                                 , xmlelement("disp_number",     d.disp_number)
                                                                 , xmlelement("face_value",      d.face_value)
                                                                 , xmlelement("currency",        d.currency)
                                                                 , xmlelement("denomination_id", d.denomination_id)
                                                                 , xmlelement("dispenser_type",  d.dispenser_type)
                                                               )
                                                           )
                                                      from atm_dispenser d
                                                     where terminal_id = t.id
                                                   ) -- end of atm_dispenser
                                               ) -- xmlelement("atm_terminal"...
                                          from atm_terminal t
                                         where id = t.terminal_id
                                    )
                                    end
                                  , (select xmlagg(
                                                xmlelement("address",         xmlattributes(a.id as "id")
                                              , xmlelement("command",         app_api_const_pkg.COMMAND_CREATE_OR_UPDATE)
                                              , xmlelement("address_type",    o.address_type)
                                              , xmlelement("country",         com_api_country_pkg.get_external_country_code(
                                                                                  i_internal_country_code => a.country
                                                                              )
                                                )
                                              , xmlelement("house",           a.house)
                                              , xmlelement("apartment",       a.apartment)
                                              , xmlelement("postal_code",     a.postal_code)
                                              , xmlelement("place_code",      a.place_code)
                                              , xmlelement("region_code",     a.region_code)
                                              , (select xmlagg(
                                                            xmlelement("address_name"
                                                          , xmlelement("language",    a.lang)
                                                          , xmlelement("comment",     a.comments)
                                                          , xmlelement("region",      a.region)
                                                          , xmlelement("city",        a.city)
                                                          , xmlelement("street",      a.street)
                                                          )
                                                          order by decode(a.lang, l_lang, 1, 'LANGENG', 2, 3)
                                                        )
                                                   from com_address_object o
                                                      , com_address a
                                                  where a.id = o.address_id
                                                    and (o.object_id, o.entity_type) in ((t.terminal_id, acq_api_const_pkg.ENTITY_TYPE_TERMINAL)
                                                                                        ,(t.merchant_id, acq_api_const_pkg.ENTITY_TYPE_MERCHANT))
                                                    and not exists (select 1
                                                                      from com_address_object ao
                                                                     where ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                                                       and ao.object_id   = t.terminal_id
                                                                       and o.entity_type  = acq_api_const_pkg.ENTITY_TYPE_MERCHANT)
                                                )
                                              , com_api_flexible_data_pkg.generate_xml(
                                                    i_entity_type => com_api_const_pkg.ENTITY_TYPE_ADDRESS
                                                  , i_standard_id => cmn_api_const_pkg.STANDARD_ID_SV_FRONTEND
                                                  , i_object_id   => a.id
                                                )
                                              )
                                            )
                                       from com_address_object o
                                          , com_address a
                                      where a.id = o.address_id
                                        and (o.object_id, o.entity_type) in ((t.terminal_id, acq_api_const_pkg.ENTITY_TYPE_TERMINAL)
                                                                            ,(t.merchant_id, acq_api_const_pkg.ENTITY_TYPE_MERCHANT))
                                        and (select min(ca.lang) keep (dense_rank first 
                                                                       order by decode(ca.lang, l_lang, 1, 'LANGENG', 2, 3))
                                               from com_address ca
                                              where ca.id = a.id
                                            ) = a.lang
                                        and not exists (select 1
                                                          from com_address_object ao
                                                         where ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                                           and ao.object_id   = t.terminal_id
                                                           and o.entity_type  = acq_api_const_pkg.ENTITY_TYPE_MERCHANT)
                                    )
                                  , case when l_include_service = com_api_type_pkg.TRUE then
                                        case when l_full_export = com_api_type_pkg.TRUE then (
                                            select xmlagg(xmlelement("service"
                                                     , xmlattributes(s.service_type_id as "value")
                                                     , xmlelement("service_type",          s.service_type_id)
                                                     , xmlelement("service_type_name",     s.service_type_name)
                                                     , xmlelement("service_external_code", s.external_code)
                                                     , xmlelement("service_number",        s.service_number)
                                                     , xmlelement("is_active",             s.is_active)
                                                     , (select xmlagg(
                                                                   xmlelement("service_attribute"
                                                                     , xmlelement("service_attribute_name",  attr.attr_name)
                                                                     , xmlelement("service_attribute_value", attr.attr_value)
                                                                   )
                                                               )
                                                          from (
                                                              select decode(data_type, com_api_const_pkg.DATA_TYPE_NUMBER, to_char(to_number(attr_value, com_api_const_pkg.NUMBER_FORMAT)), attr_value) attr_value
                                                                   , row_number() over (partition by terminal_id, attr_name
                                                                                            order by decode(level_priority, 0, 0, 1)
                                                                                                   , level_priority
                                                                                                   , start_date desc
                                                                                                   , register_timestamp desc
                                                                                       ) rn
                                                                   , terminal_id
                                                                   , split_hash
                                                                   , attr_name
                                                                   , service_id
                                                                from (
                                                                    select v.attr_value
                                                                         , 0 level_priority
                                                                         , a.object_type
                                                                         , v.register_timestamp
                                                                         , v.start_date
                                                                         , v.object_id  terminal_id
                                                                         , v.split_hash
                                                                         , a.attr_name
                                                                         , v.service_id
                                                                         , a.data_type
                                                                      from prd_attribute_value v
                                                                         , prd_attribute a
                                                                     where v.entity_type  = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                                                       and a.entity_type  is null
                                                                       and a.data_type    in (com_api_const_pkg.DATA_TYPE_CHAR, com_api_const_pkg.DATA_TYPE_NUMBER)
                                                                       and a.id           = v.attr_id
                                                                       and v.service_id in (select id from table(cast(l_service_id_tab as prd_service_tpt)))
                                                                       and l_eff_date between nvl(v.start_date, l_eff_date)
                                                                                          and nvl(v.end_date, trunc(l_eff_date) + 1)
                                                                 union all
                                                                    select v.attr_value
                                                                         , p.level_priority
                                                                         , a.object_type
                                                                         , v.register_timestamp
                                                                         , v.start_date
                                                                         , r.id  terminal_id
                                                                         , r.split_hash
                                                                         , a.attr_name
                                                                         , v.service_id
                                                                         , a.data_type
                                                                      from (select connect_by_root
                                                                                   id product_id
                                                                                 , level level_priority
                                                                                 , id parent_id
                                                                                 , product_type
                                                                                 , case when parent_id is null then 1 else 0 end top_flag
                                                                              from prd_product
                                                                           connect by prior parent_id = id
                                                                           ) p
                                                                         , prd_attribute_value v
                                                                         , prd_attribute a
                                                                         , (select id
                                                                                 , service_type_id
                                                                              from table(cast(l_service_id_tab as prd_service_tpt))
                                                                           ) srv
                                                                         , prd_product_service ps
                                                                         , prd_contract c
                                                                         , acq_terminal r
                                                                     where v.service_id      = srv.id --s.id
                                                                       and v.object_id       = decode(a.definition_level, 'SADLSRVC', srv.id, p.parent_id)
                                                                       and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                                                       and v.attr_id         = a.id
                                                                       and a.service_type_id = srv.service_type_id
                                                                       and l_eff_date between nvl(v.start_date, l_eff_date)
                                                                                          and nvl(v.end_date, trunc(l_eff_date) + 1)
                                                                       and a.entity_type  is null
                                                                       and a.data_type    in (com_api_const_pkg.DATA_TYPE_CHAR, com_api_const_pkg.DATA_TYPE_NUMBER)
                                                                       and ps.service_id     = srv.id
                                                                       and ps.service_id     = v.service_id
                                                                       and p.product_id      = ps.product_id
                                                                       and ps.product_id     = c.product_id
                                                                       and c.id              = r.contract_id
                                                                       and c.split_hash      = r.split_hash
                                                                ) tt
                                                          ) attr
                                                         where attr.rn = 1
                                                           and attr.service_id  = s.id --out
                                                           and attr.terminal_id = b.object_id--out
                                                           and attr.split_hash  = b.split_hash --out
                                                       ) -- xmlagg(xmlelement("service_attribute"...
                                                   )) -- xmlagg(xmlelement("service"
                                              from table(cast(l_service_id_tab as prd_service_tpt)) s
                                                 , prd_service_object b
                                             where b.service_id = s.id
                                               and b.object_id  = t.terminal_id
                                               and b.split_hash = t.split_hash
                                        ) else (
                                            select xmlagg(xmlelement("service"
                                                     , xmlattributes(s.service_type_id as "value")
                                                     , xmlelement("service_type",          s.service_type_id)
                                                     , xmlelement("service_type_name",     s.service_type_name)
                                                     , xmlelement("service_external_code", s.external_code)
                                                     , xmlelement("service_number",        s.service_number)
                                                     , xmlelement("is_active",             s.is_active)
                                                     , (select xmlagg(
                                                                   xmlelement("service_attribute"
                                                                     , xmlelement("service_attribute_name",   attr.attr_name)
                                                                     , xmlelement("service_attribute_value",  attr.attr_value)
                                                                   )
                                                               )
                                                          from (
                                                              select decode(data_type, com_api_const_pkg.DATA_TYPE_NUMBER, to_char(to_number(attr_value, com_api_const_pkg.NUMBER_FORMAT)), attr_value) attr_value
                                                                   , row_number() over (partition by terminal_id, attr_name
                                                                                            order by decode(level_priority, 0, 0, 1)
                                                                                                          , level_priority
                                                                                                          , start_date desc
                                                                                                          , register_timestamp desc
                                                                                       ) rn
                                                                   , terminal_id
                                                                   , split_hash
                                                                   , attr_name
                                                                   , service_id
                                                                from (
                                                                    select v.attr_value
                                                                         , 0 level_priority
                                                                         , a.object_type
                                                                         , v.register_timestamp
                                                                         , v.start_date
                                                                         , v.object_id  terminal_id
                                                                         , v.split_hash
                                                                         , a.attr_name
                                                                         , v.service_id
                                                                         , a.data_type
                                                                      from prd_attribute_value v
                                                                         , prd_attribute a
                                                                     where v.entity_type  = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                                                       and a.entity_type  is null
                                                                       and a.data_type    in (com_api_const_pkg.DATA_TYPE_CHAR, com_api_const_pkg.DATA_TYPE_NUMBER)
                                                                       and a.id           = v.attr_id
                                                                       and v.service_id in (select id from table(cast(l_service_id_tab as prd_service_tpt)))
                                                                       and l_eff_date between nvl(v.start_date, l_eff_date)
                                                                                          and nvl(v.end_date, trunc(l_eff_date) + 1)
                                                                 union all
                                                                    select v.attr_value
                                                                         , p.level_priority
                                                                         , a.object_type
                                                                         , v.register_timestamp
                                                                         , v.start_date
                                                                         , r.id  terminal_id
                                                                         , r.split_hash
                                                                         , a.attr_name
                                                                         , v.service_id
                                                                         , a.data_type
                                                                      from (select connect_by_root
                                                                                   id product_id
                                                                                 , level level_priority
                                                                                 , id parent_id
                                                                                 , product_type
                                                                                 , case when parent_id is null then 1 else 0 end top_flag
                                                                              from prd_product
                                                                           connect by prior parent_id = id
                                                                           ) p
                                                                         , prd_attribute_value v
                                                                         , prd_attribute a
                                                                         , (select id
                                                                                 , service_type_id
                                                                              from table(cast(l_service_id_tab as prd_service_tpt))
                                                                           ) srv
                                                                         , prd_product_service ps
                                                                         , prd_contract c
                                                                         , acq_terminal r
                                                                     where v.service_id      = srv.id
                                                                       and v.object_id       = decode(a.definition_level, 'SADLSRVC', srv.id, p.parent_id)
                                                                       and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                                                       and v.attr_id         = a.id
                                                                       and a.service_type_id = srv.service_type_id
                                                                       and l_eff_date between nvl(v.start_date, l_eff_date)
                                                                                          and nvl(v.end_date, trunc(l_eff_date) + 1)
                                                                       and a.entity_type  is null
                                                                       and a.data_type    in (com_api_const_pkg.DATA_TYPE_CHAR, com_api_const_pkg.DATA_TYPE_NUMBER)
                                                                       and ps.service_id     = srv.id
                                                                       and ps.service_id     = v.service_id
                                                                       and p.product_id      = ps.product_id
                                                                       and ps.product_id     = c.product_id
                                                                       and c.id              = r.contract_id
                                                                       and c.split_hash      = r.split_hash
                                                                ) tt
                                                          ) attr
                                                         where attr.rn = 1
                                                           and attr.service_id  = s.id         --out
                                                           and attr.terminal_id = b.object_id  --out
                                                           and attr.split_hash  = b.split_hash --out
                                                       ) -- xmlagg(xmlelement("service_attribute"...
                                                   )) -- xmlagg(xmlelement("service"
                                              from evt_event_object o
                                                 , evt_event e
                                                 , table(cast(l_service_id_tab as prd_service_tpt)) s
                                                 , prd_service_object b
                                             where o.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                               and decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_PRC_ACQUIRING_PKG.PROCESS_TERMINAL'
                                               and o.object_id   = t.terminal_id
                                               and o.split_hash  = t.split_hash
                                               and o.eff_date   <= l_sysdate
                                               and e.id          = o.event_id
                                               and s.event_type  = e.event_type
                                               and s.id          = b.service_id
                                               and o.object_id   = b.object_id
                                               and o.entity_type = b.entity_type
                                               and o.split_hash  = b.split_hash
                                        )
                                        end -- case when l_full_export = com_api_type_pkg.TRUE
                                    end -- case when l_include_service = com_api_type_pkg.TRUE
                                  , case when t.mcc_template_id is not null then (
                                        select xmlagg(xmlelement("acquiring_redefinition"
                                                 , xmlelement("purpose_number",  p.purpose_number)
                                                 , xmlelement("oper_type",       s.oper_type)
                                                 , xmlelement("oper_reason",     s.oper_reason)
                                                 , xmlelement("mcc",             s.mcc)
                                                 , xmlelement("terminal_number", r.terminal_number)
                                               ))
                                          from acq_mcc_selection s
                                             , pmo_purpose p
                                             , acq_terminal r
                                         where s.mcc_template_id = t.mcc_template_id
                                           and s.purpose_id      = p.id(+)
                                           and s.terminal_id     = r.id
                                    )
                                    end
                                  , com_api_flexible_data_pkg.generate_xml(
                                        i_entity_type => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                      , i_standard_id => cmn_api_const_pkg.STANDARD_ID_SV_FRONTEND
                                      , i_object_id   => t.terminal_id
                                    ) -- terminal flexible fileds
                                )) -- xmlagg(xmlelement("terminal"...
                            ) -- xmlelement("merchant"...
                          , case when l_unload_limits = com_api_const_pkg.TRUE then (
                                select xmlelement("service"
                                         , xmlelement("service_object", xmlattributes(x.terminal_id as "id")
                                             , xmlagg(xmlelement("attribute_limit"
                                                 , xmlelement("limit_type",        l.limit_type)
                                                 , xmlelement("limit_sum_value",   nvl(l.sum_limit, 0))
                                                 , xmlelement("limit_count_value", nvl(l.count_limit, 0))
                                                 , xmlelement("sum_current",       nvl(fcl_api_limit_pkg.get_limit_sum_curr(
                                                                                           i_limit_type  => l.limit_type
                                                                                         , i_entity_type => x.entity_type
                                                                                         , i_object_id   => x.object_id
                                                                                         , i_limit_id    => l.id
                                                                                       )
                                                                                     , 0))
                                                 , xmlelement("currency",          l.currency)
                                                 , xmlelement("length_type",       c.length_type)
                                                 , xmlelement("cycle_length",      c.cycle_length)
                                               ))
                                           )
                                       )
                                  from (
                                        select ao.object_id as terminal_id
                                             , x.limit_type
                                             , ao.split_hash
                                             , ao.account_id as object_id
                                             , x.entity_type
                                          from acc_account_object ao
                                             , (select distinct
                                                       a.object_type limit_type
                                                     , t.entity_type
                                                  from prd_attribute a
                                                     , prd_service_type t
                                                 where t.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                   and a.service_type_id = t.id
                                                   and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                                               ) x
                                         where ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                           union all
                                        select t.id as terminal_id
                                             , x.limit_type
                                             , t.split_hash
                                             , t.id as object_id
                                             , x.entity_type
                                          from acq_terminal t
                                             , (
                                                  select distinct
                                                         a.object_type limit_type
                                                       , t.entity_type
                                                    from prd_attribute a
                                                       , prd_service_type t
                                                   where t.entity_type     = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                                     and a.service_type_id = t.id
                                                     and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                                               ) x
                                       ) x
                                     , fcl_limit l
                                     , fcl_cycle c
                                 where x.terminal_id  = t.terminal_id
                                   and l.id           = prd_api_product_pkg.get_limit_id(
                                                            i_entity_type => x.entity_type
                                                          , i_object_id   => x.object_id
                                                          , i_limit_type  => x.limit_type
                                                          , i_split_hash  => x.split_hash
                                                          , i_mask_error  => com_api_const_pkg.TRUE
                                                        )
                                   and c.id(+)        = l.cycle_id
                              group by x.terminal_id
                            )
                            end
                          , (select xmlagg(xmlelement("account"
                                      , xmlelement("command",        app_api_const_pkg.COMMAND_CREATE_OR_UPDATE)
                                      , xmlelement("account_number", a.account_number)
                                      , xmlelement("currency",       a.currency)
                                      , xmlelement("account_status", a.status)
                                      , com_api_flexible_data_pkg.generate_xml(
                                            i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                          , i_standard_id => cmn_api_const_pkg.STANDARD_ID_SV_FRONTEND
                                          , i_object_id   => a.id
                                        )
                                    ))
                               from acc_account_object ao
                                  , acc_account a
                              where ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                and ao.object_id   = t.terminal_id
                                and ao.account_id  = a.id
                            )
                          , com_api_flexible_data_pkg.generate_xml(
                                i_entity_type => com_api_const_pkg.ENTITY_TYPE_CONTRACT
                              , i_standard_id => cmn_api_const_pkg.STANDARD_ID_SV_FRONTEND
                              , i_object_id   => t.contract_id
                            )
                        ) -- xmlelement("contract"...
                      , com_api_flexible_data_pkg.generate_xml(
                            i_entity_type => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                          , i_standard_id => cmn_api_const_pkg.STANDARD_ID_SV_FRONTEND
                          , i_object_id   => t.customer_id
                        )
                    ) -- xmlelement("customer"...
                )) -- xmlagg(xmlelement("application"
            ).getclobval() -- xmlelement("applications"
          from (
              select t.id as terminal_id
                   , t.split_hash
                   , t.merchant_id
                   , t.inst_id --addition element
                   , c.agent_id
                   , a.agent_number
                   -- terminal detail
                   , t.terminal_number
                   , t.terminal_type
                   , t.mcc
                   , t.plastic_number
                   , t.card_data_input_cap
                   , t.crdh_auth_cap
                   , t.card_capture_cap
                   , t.term_operating_env
                   , t.crdh_data_present
                   , t.card_data_present
                   , t.card_data_input_mode
                   , t.crdh_auth_method
                   , t.crdh_auth_entity
                   , t.card_data_output_cap
                   , t.term_data_output_cap
                   , t.pin_capture_cap
                   , t.cat_level
                   , t.status terminal_status
                   , t.gmt_offset
                   , t.is_mac
                   , t.cash_dispenser_present
                   , t.payment_possibility
                   , t.use_card_possibility
                   , t.cash_in_present
                   , t.available_network
                   , t.available_operation
                   , t.available_currency
                   , 1 as terminal_quantity
                   , nvl(p.instalment_support, com_api_type_pkg.FALSE) as instalment_support
                   , t.terminal_profile
                   , t.pin_block_format
                   , t.mcc_template_id as mcc_template_id
                   --device
                   , t.device_id
                   , i.remote_address
                   , i.local_port
                   , i.remote_port
                   , i.initiator
                   , i.format
                   , i.keep_alive
                   , i.monitor_connection
                   , i.multiple_connection
                   , c.id contract_id
                   , c.contract_number
                   , s.id customer_id
                   , s.customer_number
                   , m.merchant_number
                from acq_terminal t
                   , cmn_device   d
                   , cmn_tcp_ip   i
                   , prd_contract c
                   , prd_customer s
                   , acq_merchant m
                   , pos_terminal p
                   , ost_agent    a
               where t.id in (select column_value from table(cast(l_terminal_id_tab as num_tab_tpt)))
                 and d.id(+) = t.device_id
                 and d.id    = i.id(+)
                 and c.id    = t.contract_id
                 and s.id    = c.customer_id
                 and m.id    = t.merchant_id
                 and t.id    = p.id(+)
                 and a.id    = c.agent_id
          ) t
   group by t.customer_number
          , t.customer_id
          , t.contract_number
          , t.contract_id
          , t.merchant_id
          , t.merchant_number
          , t.terminal_id
          , t.split_hash
          , t.agent_id
          , t.agent_number
          , t.mcc_template_id
    ;

    procedure save_file(i_current_inst_id in    com_api_type_pkg.t_inst_id) is
        l_cnt   pls_integer;
    begin
        rul_api_param_pkg.set_param (
            i_name       => 'INST_ID'
            , i_value    => i_current_inst_id
            , io_params  => l_params
        );

        prc_api_file_pkg.open_file(
            o_sess_file_id => l_session_file_id
          , i_file_type    => l_file_type
          , io_params      => l_params
        );

        l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

        prc_api_file_pkg.put_file(
            i_sess_file_id  => l_session_file_id
          , i_clob_content  => l_file
        );

        l_cnt := l_terminal_id_tab.count;        

        prc_api_file_pkg.close_file(
            i_sess_file_id   => l_session_file_id
          , i_status         => prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count   => l_cnt
        );

        trc_log_pkg.debug('file saved, inst=' || i_current_inst_id ||', cnt=' 
                        || l_cnt || ', length=' || length(l_file));

        prc_api_stat_pkg.log_current(
            i_current_count  => l_cnt
          , i_excepted_count => 0
        );
    end save_file;

begin
    trc_log_pkg.debug('process_terminal - Start');

    prc_api_stat_pkg.log_start;
    l_estimated_count := 0;
    
    if i_full_export = com_api_const_pkg.TRUE then
        select count(1)
        into l_estimated_count
        from acq_terminal t
           , prd_contract c
       where t.split_hash in (select split_hash from com_api_split_map_vw)
         and (t.inst_id    = i_inst_id or i_inst_id is null or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
         and c.id          = t.contract_id
         and (c.agent_id   = i_agent_id or i_agent_id is null)
         and t.is_template = com_api_type_pkg.FALSE
      ;

      trc_log_pkg.debug(
          i_text => 'Estimate count = [' || l_estimated_count || ']'
      );

      prc_api_stat_pkg.log_estimation(
          i_estimated_count => l_estimated_count
        , i_measure         => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
      );
    end if;
    
    savepoint sp_terminal_export;
    for inst in (
        select i.id 
          from ost_institution_vw i
         where (i.id = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST or i_inst_id is null)
           and i.id != ost_api_const_pkg.UNIDENTIFIED_INST
    ) loop
    
        l_inst_number := ost_api_institution_pkg.get_inst_number(
                             i_inst_id => inst.id
                         );

        select min(file_type)
          into l_file_type
          from prc_file_attribute a
             , prc_file f
         where a.container_id = l_container_id
           and a.file_id      = f.id
           and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

        l_unload_limits   := nvl(i_unload_limits, com_api_type_pkg.FALSE);
        l_full_export     := nvl(i_full_export, com_api_type_pkg.FALSE);
        l_lang            := nvl(i_lang, com_ui_user_env_pkg.get_user_lang());
        l_bulk_limit      := nvl(i_count, l_bulk_limit);
        l_sysdate         := get_sysdate;
        l_include_service := nvl(i_include_service, com_api_type_pkg.FALSE);
        l_eff_date        := com_api_sttl_day_pkg.get_calc_date(i_inst_id => inst.id);
        l_thread          := prc_api_session_pkg.get_thread_number();

        trc_log_pkg.debug(
            i_text       =>'process_terminal, container_id=#1, inst=#2, agent=#3, full_export=#4, unload_limits=#5, thread_number=#6'
          , i_env_param1 => l_container_id
          , i_env_param2 => inst.id
          , i_env_param3 => i_agent_id
          , i_env_param4 => l_full_export
          , i_env_param5 => l_unload_limits
          , i_env_param6 => get_thread_number
        );

        trc_log_pkg.debug(
            i_text       =>'l_include_service=#1, l_eff_date=#2'
          , i_env_param1 => l_include_service
          , i_env_param2 => l_eff_date
        );

        if l_include_service = com_api_type_pkg.TRUE then
            if l_full_export = com_api_type_pkg.FALSE then
                select prd_service_tpr(
                           s.id
                         , t.id
                         , t.service_type_name
                         , t.external_code
                         , s.service_number
                         , t.is_active
                         , t.event_type
                       )
                  bulk collect into l_service_id_tab
                  from prd_service s
                     , (select id
                             , enable_event_type event_type
                             , get_text ('prd_service_type', 'label', id, l_lang) service_type_name
                             , external_code
                             , 1 is_active
                          from prd_service_type
                         where entity_type  = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                           and product_type = prd_api_const_pkg.PRODUCT_TYPE_ACQ
                        union
                        select id
                             , disable_event_type event_type
                             , get_text ('prd_service_type', 'label', id, l_lang) service_type_name
                             , external_code
                             , 0 is_active
                          from prd_service_type
                         where entity_type  = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                           and product_type = prd_api_const_pkg.PRODUCT_TYPE_ACQ
                       ) t
               where s.service_type_id = t.id;

            else
                select prd_service_tpr(
                           s.id
                         , t.id
                         , get_text ('prd_service_type', 'label', t.id, l_lang)
                         , t.external_code
                         , s.service_number
                         , 1
                         , null
                       )
                  bulk collect into l_service_id_tab
                  from prd_service_type t
                     , prd_service s
                 where entity_type  = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                   and product_type = prd_api_const_pkg.PRODUCT_TYPE_ACQ
                   and s.service_type_id = t.id;
            end if;
        end if;

        if l_full_export = com_api_type_pkg.TRUE then

            open all_terminal_cur(i_current_inst_id => inst.id);

            loop
                fetch all_terminal_cur bulk collect into
                      l_terminal_id_tab
                limit l_bulk_limit;

                -- generate xml
                if l_terminal_id_tab.count > 0 then
                    open  main_xml_cur(i_current_inst_id => inst.id);
                    fetch main_xml_cur into l_file;
                    close main_xml_cur;

                    save_file(i_current_inst_id => inst.id);
                end if;

                exit when all_terminal_cur%notfound;
            end loop;

            close all_terminal_cur;

        else
            open evt_objects_terminal_cur(i_current_inst_id => inst.id);

            fetch evt_objects_terminal_cur
                bulk collect
                into l_event_tab
                    , l_object_ids_tab;

            close evt_objects_terminal_cur;
            
            -- Decrease operation count
            l_object_ids_tab := set(l_object_ids_tab);
            
            -- Get estimated count
            l_estimated_count := l_estimated_count + l_object_ids_tab.count;

            trc_log_pkg.debug(
                i_text => 'Estimate count = [' || l_estimated_count || ']'
            );

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
              , i_measure         => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
            );

            open l_data_cur for
                select column_value
                  from table(cast(l_object_ids_tab as num_tab_tpt));

            loop
                fetch l_data_cur bulk collect into 
                    l_terminal_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug(
                    i_text => 'l_terminal_id_tab.count = [' || l_terminal_id_tab.count || ']'
                );
                --generate xml
                if l_terminal_id_tab.count > 0 then
                    open  main_xml_cur(i_current_inst_id => inst.id);
                    fetch main_xml_cur into l_file;
                    close main_xml_cur;

                    save_file(i_current_inst_id => inst.id);
                end if;

                exit when l_data_cur%notfound;
            end loop;
            close l_data_cur;

            -- Mark processed event object
            evt_api_event_pkg.process_event_object (
                i_event_object_id_tab  => l_event_tab
            );
            l_event_tab.delete;
        end if;

        prc_api_stat_pkg.log_end(
            i_processed_total   => l_estimated_count
          , i_excepted_total    => 0
          , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );

        trc_log_pkg.debug('process_terminal - End');
    end loop;
exception
    when others then
        rollback to sp_terminal_export;

        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        if l_data_cur%isopen then
            close l_data_cur;
        end if;

        if evt_objects_terminal_cur%isopen then
            close evt_objects_terminal_cur;
        end if;

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file(
                i_sess_file_id  => l_session_file_id
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
end process_terminal;

end itf_prc_acquiring_pkg;
/
