create or replace package body itf_api_fraud_mon_version_pkg is
/**********************************************************
 * Versions of interface between SVBO and Fraud Monitoring
 *
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 17.11.2016
 *
 * Module: ITF_API_FRAUD_MON_VERSION_PKG
 **********************************************************/

CRLF                  constant com_api_type_pkg.t_name := chr(13) || chr(10);

procedure export_cards_data_10(
    i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_event_type          in     com_api_type_pkg.t_dict_value    default null
  , i_include_address     in     com_api_type_pkg.t_boolean       default null
  , i_include_limits      in     com_api_type_pkg.t_boolean       default null
  , i_export_clear_pan    in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_count               in     com_api_type_pkg.t_count
  , i_include_notif       in     com_api_type_pkg.t_boolean       default null
  , i_subscriber_name     in     com_api_type_pkg.t_name          default null
  , i_include_contact     in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_ids_type            in     com_api_type_pkg.t_dict_value    default null
  , i_exclude_npz_cards   in     com_api_type_pkg.t_boolean       default null
  , i_include_service     in     com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := $$PLSQL_UNIT || '.EXPORT_CARDS_DATA_10';

    -- Default bulk size for <card_info> blocks per a file if <i_count> parameter is not specified
    DEFAULT_BULK_LIMIT      constant com_api_type_pkg.t_count := 2000;
    l_bulk_limit            com_api_type_pkg.t_count          := nvl(i_count, DEFAULT_BULK_LIMIT);
    l_subscriber_name       com_api_type_pkg.t_name           := upper(nvl(i_subscriber_name, DEFAULT_PROCEDURE_NAME));
    l_full_export           com_api_type_pkg.t_boolean        := nvl(i_full_export, com_api_type_pkg.FALSE);
    l_export_clear_pan      com_api_type_pkg.t_boolean        := nvl(i_export_clear_pan, com_api_const_pkg.TRUE);
    l_customer_value_type   com_api_type_pkg.t_boolean        := com_api_type_pkg.FALSE;
    l_file                  clob;
    l_total_count           com_api_type_pkg.t_count          := 0;
    l_counter               com_api_type_pkg.t_count          := 0;

    l_event_tab             com_api_type_pkg.t_number_tab;
    l_incr_event_tab        com_api_type_pkg.t_number_tab;
    l_instance_id_tab       num_tab_tpt                       := num_tab_tpt();
    l_incr_instance_id_tab  num_tab_tpt                       := num_tab_tpt();
    l_instance_id           com_api_type_pkg.t_medium_id;
    l_notif_event_tab       com_api_type_pkg.t_number_tab;
    l_estimated_count       com_api_type_pkg.t_count          := 0;
    l_current_count         com_api_type_pkg.t_count          := 0;

    l_lang                  com_api_type_pkg.t_dict_value;
    l_service_id_tab        prd_service_tpt;
    l_sysdate               date;

    cursor cur_xml is
        with ids as (
                select column_value from table(cast(l_instance_id_tab as num_tab_tpt))
             )
           , products as (
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
            xmlelement("cards_info"
              , xmlattributes('http://bpc.ru/sv/SVXP/card_info' as "xmlns")
              , xmlelement("file_type", iss_api_const_pkg.FILE_TYPE_CARD_INFO)
              , xmlelement("inst_id", i_inst_id)
              , xmlelement("tokenized_pan"
                         , case l_export_clear_pan
                               when com_api_const_pkg.FALSE
                               then com_api_const_pkg.TRUE
                               else com_api_const_pkg.FALSE
                           end
                )
              , xmlagg(xmlelement("card_info"
                  , xmlforest(
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
                            else nvl(
                                     (select 1
                                        from evt_event_object o
                                           , evt_event e
                                       where decode(o.status, 'EVST0001', o.procedure_name, null) = l_subscriber_name
                                         and e.id = o.event_id
                                         and e.event_type = iss_api_const_pkg.EVENT_TYPE_UPD_SENSITIVE_DATA
                                         and (o.object_id, o.entity_type) in (
                                                 (ci.card_id, iss_api_const_pkg.ENTITY_TYPE_CARD)
                                               , (ci.id,      iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE)
                                             )
                                         and o.split_hash = ci.split_hash
                                         and rownum = 1
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
                      , case when cip.id is not null then iss_api_card_instance_pkg.get_card_uid(i_card_instance_id => cip.id) else null end as "prev_card_id"
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
                    ) -- xmlforest
                  , xmlelement("customer"
                      , xmlforest(
                            case
                                when l_customer_value_type = com_api_type_pkg.TRUE
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
                        )
                      , (select xmlagg(
                                    xmlelement("flexible_data"
                                      , xmlelement("field_name",  ff.name)
                                      , xmlelement("field_value"
                                          , case ff.data_type
                                                when com_api_const_pkg.DATA_TYPE_NUMBER then
                                                    to_char(
                                                        to_number(
                                                            fd.field_value
                                                          , nvl(ff.data_format, com_api_const_pkg.NUMBER_FORMAT)
                                                        )
                                                      , com_api_const_pkg.XML_NUMBER_FORMAT
                                                    )
                                                when com_api_const_pkg.DATA_TYPE_DATE   then
                                                    to_char(
                                                        to_date(
                                                            fd.field_value
                                                          , nvl(ff.data_format, com_api_const_pkg.DATE_FORMAT)
                                                        )
                                                      , com_api_const_pkg.XML_DATE_FORMAT
                                                    )
                                                else
                                                    fd.field_value
                                            end
                                        )
                                    )
                                )
                           from com_flexible_field ff
                              , com_flexible_data  fd
                          where ff.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                            and fd.field_id    = ff.id
                            and fd.object_id   = m.id
                        ) -- customer flexible fields
                    )
                  , xmlelement("cardholder"
                      , xmlforest(
                            h.cardholder_number       as "cardholder_number"
                          , h.cardholder_name         as "cardholder_name"
                        )
                      , (select
                             xmlagg(
                                 xmlelement("person"
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
                                                   , io.id_issuer      as "id_issuer"
                                                   , to_char(io.id_issue_date, com_api_const_pkg.XML_DATE_FORMAT)  as "id_issue_date"
                                                   , to_char(io.id_expire_date, com_api_const_pkg.XML_DATE_FORMAT)  as "id_expire_date"
                                                   , com_ui_id_object_pkg.get_id_card_desc(
                                                         i_entity_type     => com_api_const_pkg.ENTITY_TYPE_PERSON
                                                       , i_object_id       => p.id
                                                       , i_lang            => p.lang
                                                     )                 as "id_desc"
                                                 )
                                             ))
                                        from com_id_object io
                                       where io.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
                                         and io.object_id = p.id
                                         and (i_ids_type is null or i_ids_type = io.id_type)
                                     ) --identity_card
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
                      -- notification
                      , case when nvl(i_include_notif, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE
                                  and ci.state != iss_api_const_pkg.CARD_STATE_CLOSED then

                            case
                                when prd_api_service_pkg.get_active_service_id(
                                         i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CARD
                                       , i_object_id           => ci.card_id
                                       , i_attr_name           => ntf_api_const_pkg.NOTIFICATION_SERVICE_USE_FEE
                                       , i_service_type_id     => ntf_api_const_pkg.NOTIFICATION_CARD_SERVICE
                                       , i_split_hash          => crd.split_hash
                                       , i_eff_date            => l_sysdate
                                       , i_mask_error          => com_api_type_pkg.TRUE
                                       , i_inst_id             => i_inst_id
                                     ) is not null
                                then (
                                    select
                                        xmlagg(
                                            xmlelement("notification"
                                              , xmlelement("service_id"
                                                  , (select prd_api_service_pkg.get_active_service_id(
                                                                i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CARD
                                                              , i_object_id           => ci.card_id
                                                              , i_attr_name           => ntf_api_const_pkg.NOTIFICATION_SERVICE_USE_FEE
                                                              , i_service_type_id     => ntf_api_const_pkg.NOTIFICATION_CARD_SERVICE
                                                              , i_split_hash          => crd.split_hash
                                                              , i_eff_date            => l_sysdate
                                                              , i_mask_error          => com_api_type_pkg.TRUE
                                                              , i_inst_id             => i_inst_id
                                                            ) service_id
                                                       from dual)
                                                )
                                              , xmlelement("notification_event", nvl(n.event_type, aut_api_const_pkg.EVENT_AUTH_BY_CARD))
                                              , xmlelement("delivery_channel", n.channel_id)
                                              , xmlelement("delivery_address", nvl(n.delivery_address, d.commun_address))
                                              , xmlelement("is_active"
                                                  , case
                                                        when co.is_active is not null then
                                                            co.is_active
                                                        when n.status = ntf_api_const_pkg.STATUS_DO_NOT_SEND then
                                                            com_api_type_pkg.FALSE
                                                        else
                                                            com_api_type_pkg.TRUE
                                                    end
                                                )
                                            )
                                        )
                                      from iss_cardholder h
                                         , ntf_custom_event n
                                         , ntf_custom_object co
                                         , com_contact_object o
                                         , com_contact_data d
                                     where h.id               = crd.cardholder_id
                                       and n.object_id(+)     = h.id
                                       and n.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                       and co.custom_event_id(+) = n.id
                                       and co.object_id(+)    = crd.id
                                       and o.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                       and o.object_id(+)     = h.id
                                       and o.contact_type(+)  = com_api_const_pkg.CONTACT_TYPE_NOTIFICATION
                                       and d.contact_id(+)    = o.contact_id
                                       and d.commun_method(+) = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                                       and (d.end_date(+) is null or d.end_date(+) > l_sysdate)
                                       and (n.event_type is null or n.event_type != iss_api_const_pkg.EVENT_3D_SECURE_AUTH_REQUEST)
                                )
                                else (
                                    select
                                        xmlagg(
                                            xmlelement("notification"
                                              , xmlelement("service_id"
                                                  , (select prd_api_service_pkg.get_active_service_id(
                                                                i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CARD
                                                              , i_object_id           => ci.card_id
                                                              , i_attr_name           => ntf_api_const_pkg.NOTIFICATION_SERVICE_USE_FEE
                                                              , i_service_type_id     => ntf_api_const_pkg.NOTIFICATION_CARD_SERVICE
                                                              , i_split_hash          => crd.split_hash
                                                              , i_eff_date            => l_sysdate
                                                              , i_last_active         => com_api_type_pkg.TRUE
                                                              , i_mask_error          => com_api_type_pkg.TRUE
                                                              , i_inst_id             => i_inst_id
                                                        ) service_id
                                                   from dual)
                                                )
                                              , xmlelement("notification_event", nvl(e.event_type, aut_api_const_pkg.EVENT_AUTH_BY_CARD))
                                              , xmlelement("delivery_channel", n.channel_id)
                                              , xmlelement("delivery_address", nvl(n.delivery_address, d.commun_address))
                                              , xmlelement("is_active", 0) --inactive
                                            )
                                        )
                                      from iss_cardholder h
                                         , ntf_custom_event n
                                         , ntf_custom_object co
                                         , com_contact_object o
                                         , com_contact_data d
                                         , evt_event_object eo
                                         , evt_event e
                                     where h.id               = crd.cardholder_id
                                       and decode(eo.status, 'EVST0001', eo.procedure_name, null) = l_subscriber_name
                                       and eo.object_id       = crd.id
                                       and eo.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
                                       and eo.eff_date       <= l_sysdate
                                       and eo.split_hash      = ci.split_hash
                                       and eo.event_id        = e.id
                                       and e.event_type       = iss_api_const_pkg.EVENT_NOTIF_DEACTIVATION   -- close notification service
                                       and n.object_id(+)     = h.id
                                       and n.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                       and co.custom_event_id(+) = n.id
                                       and co.object_id(+)       = crd.id
                                       and o.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                       and o.object_id(+)     = h.id
                                       and o.contact_type(+)  = com_api_const_pkg.CONTACT_TYPE_NOTIFICATION
                                       and d.contact_id(+)    = o.contact_id
                                       and d.commun_method(+) = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                                       and (d.end_date(+) is null or d.end_date(+) > l_sysdate)
                                       and (n.event_type is null or n.event_type != iss_api_const_pkg.EVENT_3D_SECURE_AUTH_REQUEST)
                                )
                            end
                        end
                      -- 3D secure
                      , case when nvl(i_include_notif, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE
                                  and ci.state != iss_api_const_pkg.CARD_STATE_CLOSED then

                            case
                                when prd_api_service_pkg.get_active_service_id(
                                         i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CARD
                                       , i_object_id           => ci.card_id
                                       , i_attr_name           => null
                                       , i_service_type_id     => ntf_api_const_pkg.THREE_D_SECURE_CARD_SERVICE
                                       , i_split_hash          => crd.split_hash
                                       , i_eff_date            => l_sysdate
                                       , i_mask_error          => com_api_type_pkg.TRUE
                                       , i_inst_id             => i_inst_id
                                     ) is not null
                                then (
                                    select
                                        xmlagg(
                                            xmlelement("notification"
                                              , xmlelement("service_id"
                                                  , (select prd_api_service_pkg.get_active_service_id(
                                                                i_entity_type     => iss_api_const_pkg.ENTITY_TYPE_CARD
                                                              , i_object_id       => ci.card_id
                                                              , i_attr_name       => null
                                                              , i_service_type_id => ntf_api_const_pkg.THREE_D_SECURE_CARD_SERVICE
                                                              , i_split_hash      => crd.split_hash
                                                              , i_eff_date        => l_sysdate
                                                              , i_mask_error      => com_api_type_pkg.TRUE
                                                              , i_inst_id         => i_inst_id
                                                            ) as service_id
                                                       from dual)
                                                )
                                              , xmlelement("notification_event", e.event_type)
                                              , xmlelement("delivery_channel", dc.channel_id)
                                              , xmlelement("delivery_address", nvl(dc.delivery_address, d.commun_address))
                                              , xmlelement("is_active"
                                                  , case
                                                        when dc.is_active is not null then
                                                            dc.is_active
                                                        when dc.status = ntf_api_const_pkg.STATUS_DO_NOT_SEND then
                                                            com_api_type_pkg.FALSE
                                                        else
                                                            com_api_type_pkg.TRUE
                                                    end
                                                )
                                            )
                                        )
                                      from iss_cardholder h
                                         , ntf_scheme_event e
                                         , com_contact_object o
                                         , com_contact_data d
                                         , (select n.id
                                                 , n.channel_id 
                                                 , n.delivery_address
                                                 , co.is_active
                                                 , n.status
                                                 , n.object_id
                                                 , co.object_id   card_id
                                                 , case when co.is_active = com_api_type_pkg.FALSE then 1 else row_number() over (partition by n.scheme_event_id, n.entity_type, n.object_id, co.is_active order by n.id desc) end rn
                                              from ntf_custom_event  n
                                                 , ntf_custom_object co
                                             where n.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                               and (n.event_type is null
                                                    or n.event_type = iss_api_const_pkg.EVENT_3D_SECURE_AUTH_REQUEST
                                                   )
                                               and co.custom_event_id(+) = n.id
                                            ) dc
                                     where h.id               = crd.cardholder_id
                                       and dc.object_id(+)    = h.id
                                       and dc.card_id(+)      = crd.id
                                       and dc.rn              = 1
                                       and e.entity_type      = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                       and e.event_type       = iss_api_const_pkg.EVENT_3D_SECURE_AUTH_REQUEST
                                       and e.scheme_id        = prd_api_product_pkg.get_attr_value_number(
                                                                     i_entity_type     => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                                                   , i_object_id       => crd.customer_id
                                                                   , i_attr_name       => 'NOTIFICATION_SCHEME'
                                                                   , i_mask_error      => com_api_type_pkg.TRUE
                                                                 )
                                       and o.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                       and o.object_id(+)     = h.id
                                       and o.contact_type(+)  = com_api_const_pkg.CONTACT_TYPE_NOTIFICATION
                                       and d.contact_id(+)    = o.contact_id
                                       and d.commun_method(+) = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                                       and (d.end_date(+) is null or d.end_date(+) > l_sysdate)
                                )
                                else (
                                    select
                                        xmlagg(
                                            xmlelement("notification"
                                              , xmlelement("service_id"
                                                  , (select prd_api_service_pkg.get_active_service_id(
                                                                i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CARD
                                                              , i_object_id           => ci.card_id
                                                              , i_attr_name           => null
                                                              , i_service_type_id     => ntf_api_const_pkg.THREE_D_SECURE_CARD_SERVICE
                                                              , i_split_hash          => crd.split_hash
                                                              , i_eff_date            => l_sysdate
                                                              , i_last_active         => com_api_type_pkg.TRUE
                                                              , i_mask_error          => com_api_type_pkg.TRUE
                                                              , i_inst_id             => i_inst_id
                                                            ) service_id
                                                       from dual)
                                                )
                                              , xmlelement("notification_event", e.event_type)
                                              , xmlelement("delivery_channel", dc.channel_id)
                                              , xmlelement("delivery_address", nvl(dc.delivery_address, d.commun_address))
                                              , xmlelement("is_active", com_api_type_pkg.FALSE) --inactive
                                            )
                                        )
                                      from iss_cardholder h
                                         , ntf_scheme_event e
                                         , com_contact_object o
                                         , com_contact_data d
                                         , evt_event_object eo
                                         , evt_event ev
                                         , (select n.id
                                                 , n.channel_id 
                                                 , n.delivery_address
                                                 , co.is_active
                                                 , n.status
                                                 , n.object_id
                                                 , co.object_id   card_id
                                                 , case when co.is_active = com_api_type_pkg.FALSE then 1 else row_number() over (partition by n.scheme_event_id, n.entity_type, n.object_id, co.is_active order by n.id desc) end rn
                                              from ntf_custom_event n
                                                 , ntf_custom_object co
                                             where n.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                               and (n.event_type is null
                                                    or n.event_type = iss_api_const_pkg.EVENT_3D_SECURE_AUTH_REQUEST
                                                   )
                                               and co.custom_event_id(+) = n.id
                                            ) dc
                                     where h.id               = crd.cardholder_id
                                       and dc.object_id(+)    = h.id
                                       and dc.card_id(+)      = crd.id
                                       and dc.rn              = 1
                                       and e.entity_type      = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                       and e.event_type       = iss_api_const_pkg.EVENT_3D_SECURE_AUTH_REQUEST
                                       and e.scheme_id        = prd_api_product_pkg.get_attr_value_number(
                                                                     i_entity_type     => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                                                   , i_object_id       => crd.customer_id
                                                                   , i_attr_name       => 'NOTIFICATION_SCHEME'
                                                                   , i_mask_error      => com_api_type_pkg.TRUE
                                                                 )
                                       and o.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                       and o.object_id(+)     = h.id
                                       and o.contact_type(+)  = com_api_const_pkg.CONTACT_TYPE_NOTIFICATION
                                       and d.contact_id(+)    = o.contact_id
                                       and d.commun_method(+) = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                                       and (d.end_date(+) is null or d.end_date(+) > l_sysdate)
                                       and decode(eo.status, 'EVST0001', eo.procedure_name, null) = l_subscriber_name
                                       and eo.object_id       = crd.id
                                       and eo.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
                                       and eo.eff_date       <= l_sysdate
                                       and eo.split_hash      = ci.split_hash
                                       and eo.event_id        = ev.id
                                       and ev.event_type      = iss_api_const_pkg.EVENT_3D_SECURE_DEACTIVATION -- close 3d secure service
                                )
                            end
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
                    ) --cardholder
                  , (select xmlagg(xmlelement("account"
                              , xmlforest(
                                    ac.account_number   as "account_number"
                                  , ac.currency         as "currency"
                                  , ac.account_type     as "account_type"
                                  , ac.status           as "account_status"
                                  , ao.is_pos_default   as "is_pos_default"
                                  , ao.is_atm_default   as "is_atm_default"
                                )
                            ))
                       from acc_account ac
                          , acc_account_object ao
                      where ac.id = ao.account_id
                        and ac.split_hash  = ci.split_hash
                        and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                        and ao.object_id   = crd.id
                        and ao.split_hash  = ci.split_hash
                    ) --account
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
                  , case when nvl(i_include_limits, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then (
                        select xmlelement("limits",
                                   xmlagg(
                                       xmlelement("limit"
                                         , xmlelement("limit_type",   l.limit_type)
                                         , xmlelement("sum_limit",    nvl(l.sum_limit, 0))
                                         , xmlelement("count_limit",  nvl(l.count_limit, 0))
                                         , xmlelement("sum_current",  nvl(fcl_api_limit_pkg.get_limit_sum_curr(
                                                                              i_limit_type  => l.limit_type
                                                                            , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
                                                                            , i_object_id   => crd.id
                                                                            , i_limit_id    => l.id
                                                                            , i_split_hash  => crd.split_hash
                                                                          )
                                                                        , 0))
                                         , xmlelement("currency",     l.currency)
                                         , xmlelement("next_date",    case
                                                                          when b.next_date > l_sysdate or b.next_date is null
                                                                          then b.next_date
                                                                          else fcl_api_cycle_pkg.calc_next_date(
                                                                                   i_cycle_type  => b.cycle_type
                                                                                 , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
                                                                                 , i_object_id   => crd.id
                                                                                 , i_split_hash  => crd.split_hash
                                                                                 , i_start_date  => l_sysdate
                                                                                 , i_inst_id     => crd.inst_id
                                                                               )
                                                                      end)
                                         , xmlelement("length_type",  c.length_type)
                                         , xmlelement("cycle_length", nvl(c.cycle_length, 999))
                                       )
                                   )
                               )
                          from fcl_limit l
                             , (select to_number(limit_id, com_api_const_pkg.NUMBER_FORMAT) limit_id
                                     , row_number() over (partition by card_id, limit_type order by decode(level_priority, 0, 0, 1)
                                                                                                         , level_priority
                                                                                                         , start_date desc
                                                                                                         , register_timestamp desc) rn
                                     , card_id
                                     , split_hash
                                  from (
                                        select v.attr_value limit_id
                                             , 0 level_priority
                                             , a.object_type limit_type
                                             , v.register_timestamp
                                             , v.start_date
                                             , v.object_id  card_id
                                             , v.split_hash
                                          from prd_attribute_value v
                                             , prd_attribute a
                                         where v.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
                                           and a.entity_type  = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                                           and a.id           = v.attr_id
                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                     union all
                                        select v.attr_value
                                             , p.level_priority
                                             , a.object_type as limit_type
                                             , v.register_timestamp
                                             , v.start_date
                                             , ac.id as card_id
                                             , ac.split_hash
                                          from products p
                                             , prd_attribute_value v
                                             , prd_attribute a
                                             , prd_service_type st
                                             , prd_service s
                                             , prd_product_service ps
                                             , prd_contract c
                                             , iss_card ac
                                         where v.service_id      = s.id
                                           and v.object_id       = decode(a.definition_level, 'SADLSRVC', s.id, p.parent_id)
                                           and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                           and v.attr_id         = a.id
                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                           and a.service_type_id = s.service_type_id
                                           and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT  --'ENTTLIMT'
                                           and st.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
                                           and st.id             = s.service_type_id
                                           and p.product_id      = ps.product_id
                                           and s.id              = ps.service_id
                                           and ps.product_id     = c.product_id
                                           and c.id              = ac.contract_id
                                           and c.split_hash      = ac.split_hash
                                    ) tt
                               ) limits
                             , fcl_cycle c
                             , fcl_cycle_counter b
                         where limits.card_id    = crd.id
                           and limits.split_hash = crd.split_hash
                           and limits.rn         = 1
                           and l.id              = limits.limit_id
                           and c.id(+)           = l.cycle_id
                           and b.cycle_type(+)   = c.cycle_type
                           and b.entity_type(+)  = iss_api_const_pkg.ENTITY_TYPE_CARD
                           and b.object_id(+)    = crd.id
                           and b.split_hash(+)   = crd.split_hash
                    )
                    end --case (limits)
                    --services
                  , case when nvl(i_include_service, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
                        case when l_full_export = com_api_type_pkg.TRUE then (
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
                                                          and a.data_type    = com_api_const_pkg.DATA_TYPE_CHAR --'DTTPCHAR'
                                                          and l_sysdate between nvl(v.start_date, l_sysdate)
                                                                             and nvl(v.end_date,   trunc(l_sysdate)+1)
                                                          and v.service_id in (select id from table(cast(l_service_id_tab as prd_service_tpt)))
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
                                                         from products p
                                                            , prd_attribute_value v
                                                            , prd_attribute a
                                                            , (select distinct id, service_type_id
                                                                 from table(cast(l_service_id_tab as prd_service_tpt))
                                                              ) srv
                                                            , prd_product_service ps
                                                            , prd_contract c
                                                            , iss_card ac
                                                        where v.service_id      = srv.id
                                                          and v.object_id       = decode(a.definition_level, 'SADLSRVC', srv.id, p.parent_id)
                                                          and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                                          and v.attr_id         = a.id
                                                          and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                          and a.service_type_id = srv.service_type_id
                                                          and a.entity_type is null
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
                                   ) -- xmlagg
                              from table(cast(l_service_id_tab as prd_service_tpt)) s
                                 , prd_service_object b
                             where b.service_id    = s.id
                               and b.object_id     = crd.id
                               and b.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD
                               and b.split_hash    = crd.split_hash
                        ) else (
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
                                                          and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                          and v.service_id in (select id from table(cast(l_service_id_tab as prd_service_tpt)))
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
                                                         from products p
                                                            , prd_attribute_value v
                                                            , prd_attribute a
                                                            , (select distinct id, service_type_id
                                                                 from table(cast(l_service_id_tab as prd_service_tpt))
                                                              ) srv
                                                            , prd_product_service ps
                                                            , prd_contract c
                                                            , iss_card ac
                                                        where v.service_id      = srv.id
                                                          and v.object_id       = decode(a.definition_level, 'SADLSRVC', srv.id, p.parent_id)
                                                          and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                                          and v.attr_id         = a.id
                                                          and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                          and a.service_type_id = srv.service_type_id
                                                          and a.entity_type  is null
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
                                   ) -- xmlagg
                              from evt_event_object o
                                 , evt_event e
                                 , table(cast(l_service_id_tab as prd_service_tpt)) s
                                 , prd_service_object b
                             where o.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD
                               and o.object_id     = crd.id
                               and o.split_hash    = crd.split_hash
                               and o.eff_date      <= l_sysdate
                               and e.id            = o.event_id
                               and s.event_type    = e.event_type
                               and s.id            = b.service_id
                               and o.object_id     = b.object_id
                               and o.entity_type   = b.entity_type
                               and o.split_hash    = b.split_hash
                        )
                        end
                    end --case (services)
                  , (select xmlagg(
                                xmlelement("flexible_data"
                                  , xmlelement("field_name", ff.name)
                                  , xmlelement("field_value"
                                      , case ff.data_type
                                            when com_api_const_pkg.DATA_TYPE_NUMBER then
                                                to_char(
                                                    to_number(
                                                        fd.field_value
                                                      , nvl(ff.data_format, com_api_const_pkg.NUMBER_FORMAT)
                                                    )
                                                  , com_api_const_pkg.XML_NUMBER_FORMAT
                                                )
                                            when com_api_const_pkg.DATA_TYPE_DATE   then
                                                to_char(
                                                    to_date(
                                                        fd.field_value
                                                      , nvl(ff.data_format, com_api_const_pkg.DATE_FORMAT)
                                                    )
                                                  , com_api_const_pkg.XML_DATE_FORMAT
                                                )
                                            else
                                                fd.field_value
                                        end
                                    )
                                )
                            )
                       from com_flexible_field ff
                          , com_flexible_data  fd
                      where ff.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                        and fd.field_id    = ff.id
                        and fd.object_id   = crd.id
                    ) -- card flexible fields
                  , iss_cst_export_pkg.generate_add_data(
                        i_card_id => crd.id
                    )
                ))  --xmlagg(<card_info>)
            ).getclobval()  --xml root element
          , count(1)
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
        where ci.id in (select column_value from ids)
          and ci.split_hash in (select split_hash from com_api_split_map_vw)
          and crd.id              = ci.card_id
          and crd.split_hash      = ci.split_hash
          and ct.id               = crd.contract_id
          and ct.split_hash       = ci.split_hash
          and pr.id               = ct.product_id
          and m.id                = crd.customer_id
          and m.split_hash        = ci.split_hash
          and crd.cardholder_id   = h.id(+)
          and cd.card_instance_id(+) = ci.id
          and cip.id(+)           = ci.preceding_card_instance_id
          and cip.split_hash(+)   = ci.split_hash
          and cnp.card_id(+)      = cip.card_id
          and a.id                = ci.agent_id
    ;

    cur_objects             sys_refcursor;

    l_container_id         com_api_type_pkg.t_long_id;

    -- Function returns a reference for a cursor with card instances being processed.
    -- In case of incremental unloading it also returns event objects' identifiers.
    procedure open_cur_objects(
        o_cursor               out sys_refcursor
      , i_full_export       in     com_api_type_pkg.t_boolean
      , i_inst_id           in     com_api_type_pkg.t_inst_id
    ) is
    begin
        trc_log_pkg.debug('Opening a cursor for all card instances those are processed...');

        if i_full_export = com_api_type_pkg.TRUE then
            -- Get current instances for all available cards
            open o_cursor for
                select max(ci.id)
                  from iss_card_instance ci
                 where ci.split_hash in (select split_hash from com_api_split_map_vw)
                   and (i_inst_id is null or ci.inst_id = i_inst_id)
              group by ci.card_id;
        else
            -- Get current cards' instances by events
            open o_cursor for
                select v.event_object_id
                     , max(v.card_instance_id)
                  from (
                        select a.id  as event_object_id
                             , ci.id as card_instance_id
                             , ci.card_id
                          from evt_event_object a
                             , iss_card_instance ci
                             , evt_event e
                         where decode(a.status, 'EVST0001', a.procedure_name, null) = l_subscriber_name
                           and a.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                           and a.object_id   = ci.card_id
                           and a.split_hash  = ci.split_hash
                           and a.eff_date   <= l_sysdate
                           and ci.split_hash in (select split_hash from com_api_split_map_vw)
                           and (i_inst_id is null or ci.inst_id = i_inst_id)
                           and e.id          = a.event_id
                           and (i_event_type is null or i_event_type = e.event_type)
                           and (nvl(i_exclude_npz_cards, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE
                                or
                                i_exclude_npz_cards = com_api_type_pkg.TRUE
                                and ci.state != iss_api_const_pkg.CARD_STATE_PERSONALIZATION)
                           and (a.container_id is null or a.container_id = l_container_id)      
                        union all
                        select a.id  as event_object_id
                             , ci.id as card_instance_id
                             , ci.card_id
                          from evt_event_object a
                             , iss_card_instance ci
                             , evt_event e
                         where decode(a.status, 'EVST0001', a.procedure_name, null) = l_subscriber_name
                           and a.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                           and a.object_id   = ci.id
                           and a.split_hash  = ci.split_hash
                           and a.eff_date   <= l_sysdate
                           and ci.split_hash in (select split_hash from com_api_split_map_vw)
                           and (i_inst_id is null or ci.inst_id = i_inst_id)
                           and e.id          = a.event_id
                           and (i_event_type is null or i_event_type = e.event_type)
                           and (nvl(i_exclude_npz_cards, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE
                                or
                                i_exclude_npz_cards = com_api_type_pkg.TRUE
                                and ci.state != iss_api_const_pkg.CARD_STATE_PERSONALIZATION)
                           and (a.container_id is null or a.container_id = l_container_id)      
                        union all
                        select a.id  as event_object_id
                             , ci.id as card_instance_id
                             , ci.card_id
                          from evt_event_object a
                             , iss_card c
                             , iss_card_instance ci
                             , evt_event e
                         where decode(a.status, 'EVST0001', a.procedure_name, null) = l_subscriber_name
                           and a.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                           and a.object_id   = c.cardholder_id
                           and a.split_hash  = ci.split_hash
                           and a.eff_date   <= l_sysdate
                           and ci.split_hash in (select split_hash from com_api_split_map_vw)
                           and ci.card_id    = c.id
                           and ci.seq_number = (select max(t.seq_number) from iss_card_instance t where t.card_id = c.id)
                           and (i_inst_id is null or ci.inst_id = i_inst_id)
                           and e.id          = a.event_id
                           and (i_event_type is null or i_event_type = e.event_type)
                           and (nvl(i_exclude_npz_cards, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE
                                or
                                i_exclude_npz_cards = com_api_type_pkg.TRUE
                                and ci.state != iss_api_const_pkg.CARD_STATE_PERSONALIZATION)
                           and (a.container_id is null or a.container_id = l_container_id)      
                        -- Also it is necessary to select all cards which products' attributes have been changed
                        -- only not closed cards are processed
                        union all
                        select a.id  as event_object_id
                             , ci.id as card_instance_id
                             , ci.card_id
                          from evt_event_object a
                             , evt_event e
                             , prd_product p
                             , prd_contract ct
                             , iss_card c
                             , iss_card_instance ci
                         where i_include_limits = com_api_type_pkg.TRUE
                           and decode(a.status, 'EVST0001', a.procedure_name, null) = l_subscriber_name
                           and a.entity_type  = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
                           and a.eff_date    <= l_sysdate
                           and e.id           = a.event_id
                           and e.event_type   = prd_api_const_pkg.EVENT_ATTRIBUTE_CHANGE_PRODUCT
                           and p.id           = a.object_id
                           and p.product_type = prd_api_const_pkg.PRODUCT_TYPE_ISS
                           and ct.product_id  = a.object_id
                           and c.contract_id  = ct.id
                           and ci.card_id     = c.id
                           and ci.split_hash in (select split_hash from com_api_split_map_vw)
                           and ct.split_hash  = ci.split_hash
                           and c.split_hash   = ci.split_hash
                           and (nvl(i_exclude_npz_cards, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE
                                or
                                i_exclude_npz_cards = com_api_type_pkg.TRUE
                                and ci.state != iss_api_const_pkg.CARD_STATE_PERSONALIZATION)
                           and ci.state != iss_api_const_pkg.CARD_STATE_CLOSED
                        -- Also it is necessary to select all cards which product_id have been changed in contract
                           and (a.container_id is null or a.container_id = l_container_id)      
                        union all
                        select a.id  as event_object_id
                             , ci.id as card_instance_id
                             , ci.card_id
                          from evt_event_object a
                             , evt_event e
                             , iss_card c
                             , iss_card_instance ci
                         where i_include_limits = com_api_type_pkg.TRUE
                           and decode(a.status, 'EVST0001', a.procedure_name, null) = l_subscriber_name
                           and a.entity_type  = prd_api_const_pkg.ENTITY_TYPE_CONTRACT
                           and a.eff_date    <= l_sysdate
                           and e.id           = a.event_id
                           and e.event_type   = prd_api_const_pkg.EVENT_PRODUCT_CHANGE
                           and c.contract_id  = a.object_id
                           and ci.card_id     = c.id
                           and ci.split_hash in (select split_hash from com_api_split_map_vw)
                           and c.split_hash   = ci.split_hash
                           and (nvl(i_exclude_npz_cards, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE
                                or 
                                i_exclude_npz_cards = com_api_type_pkg.TRUE
                                and ci.state != iss_api_const_pkg.CARD_STATE_PERSONALIZATION)
                           and (a.container_id is null or a.container_id = l_container_id)      
                       ) v
              group by v.card_id
                     , v.event_object_id
              order by 2 asc -- card_instance_id
            ;
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
        trc_log_pkg.debug('Creating a new XML file...');

        l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

        rul_api_param_pkg.set_param (
            i_name          => 'INST_ID'
          , i_value         => i_inst_id
          , io_params       => l_params
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

        trc_log_pkg.debug('file saved, count='||i_counter||', length='||length(l_file));
    end save_file;

    -- Generate XML file
    procedure generate_xml is
        l_fetched_count        com_api_type_pkg.t_count    := 0;
    begin
        if l_instance_id_tab.count() > 0 then
            -- For every processing batch of card instances we fetch data and save it in a separate file
            open cur_xml;
            fetch cur_xml into l_file, l_fetched_count;
            close cur_xml;

            l_counter := l_counter + 1;

            save_file(
                i_counter        => l_fetched_count
            );

            l_total_count := l_total_count + l_current_count;

            prc_api_stat_pkg.log_current(
                i_current_count  => l_total_count
              , i_excepted_count => 0
            );
        end if;
    end generate_xml;

    procedure save_estimation is
    begin
        l_estimated_count := l_estimated_count + l_current_count;

        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_estimated_count
        );
        trc_log_pkg.debug('Estimated count of cards is [' || l_estimated_count || ']');
    end save_estimation;

begin
    trc_log_pkg.debug(
        i_text       => 'export_cards_numbers: START with l_full_export [#1], i_include_address [#2]'
                        || ', i_include_limits [#3], i_inst_id [#4], i_count [#5]'
      , i_env_param1 => l_full_export
      , i_env_param2 => i_include_address
      , i_env_param3 => i_include_limits
      , i_env_param4 => i_inst_id
      , i_env_param5 => i_count
      , i_env_param6 => i_include_service
    );

    l_lang      := nvl(i_lang, com_ui_user_env_pkg.get_user_lang());
    l_sysdate   := com_api_sttl_day_pkg.get_sysdate;

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
        i_text       => 'l_export_clear_pan [#1] l_lang [#2] l_customer_value_type [#3] l_container_id [#4]'
      , i_env_param1 => l_export_clear_pan
      , i_env_param2 => l_lang
      , i_env_param3 => l_customer_value_type
      , i_env_param4 => l_container_id
    );

    prc_api_stat_pkg.log_start;

    if nvl(i_include_service, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then

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
              bulk collect into l_service_id_tab
              from prd_service_type t
                 , prd_service s
             where entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
               and product_type = prd_api_const_pkg.PRODUCT_TYPE_ISS --'PRDT0100'
               and t.id not in (ntf_api_const_pkg.NOTIFICATION_CARD_SERVICE, ntf_api_const_pkg.THREE_D_SECURE_CARD_SERVICE)
               and s.service_type_id = t.id;

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
              bulk collect into l_service_id_tab
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
                       and id not in (ntf_api_const_pkg.NOTIFICATION_CARD_SERVICE, ntf_api_const_pkg.THREE_D_SECURE_CARD_SERVICE)
                    union
                    select id
                         , disable_event_type event_type
                         , get_text ('prd_service_type', 'label', id, l_lang) service_type_name
                         , external_code
                         , 0 is_active
                      from prd_service_type
                     where entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
                       and product_type = prd_api_const_pkg.PRODUCT_TYPE_ISS --'PRDT0100'
                       and id not in (ntf_api_const_pkg.NOTIFICATION_CARD_SERVICE, ntf_api_const_pkg.THREE_D_SECURE_CARD_SERVICE)
                ) t
            where s.service_type_id = t.id;

        end if;

        trc_log_pkg.debug(
            i_text => 'Collection created. Count = ' || l_service_id_tab.count
        );

    end if;

    open_cur_objects(
        o_cursor      => cur_objects
      , i_full_export => l_full_export
      , i_inst_id     => i_inst_id
    );

    loop
        begin
            savepoint sp_before_iteration;

            if l_full_export = com_api_type_pkg.TRUE then
                fetch cur_objects
                 bulk collect into
                      l_instance_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                l_current_count := l_instance_id_tab.count;

                save_estimation;

                -- Generate XML file
                generate_xml;

            else  -- l_full_export = com_api_type_pkg.FALSE
                fetch cur_objects
                 bulk collect into
                      l_event_tab
                    , l_incr_instance_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                l_current_count := l_incr_instance_id_tab.count;

                save_estimation;

                for i in 1 .. l_incr_instance_id_tab.count loop
                    -- Decrease card instance count and remove the last card instance id from previous iteration
                    if (l_incr_instance_id_tab(i) != l_instance_id or l_instance_id is null)
                       and l_incr_instance_id_tab(i) is not null
                    then
                        l_instance_id_tab.extend;
                        l_instance_id_tab(l_instance_id_tab.count)   := l_incr_instance_id_tab(i);
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);

                        if l_instance_id_tab.count > l_bulk_limit then
                            -- Generate XML file for current portion of the "l_bulk_limit" records
                            generate_xml;

                            -- In case of full export mode all elements of collection <l_event_tab> are null
                            evt_api_event_pkg.process_event_object(
                                i_event_object_id_tab => l_incr_event_tab
                            );

                            -- Save last element of the array on a current iteration to use it for the next one
                            l_instance_id := l_incr_instance_id_tab(i);
                            l_instance_id_tab.delete;
                            l_incr_event_tab.delete;
                        end if;
                    end if;
                end loop;

            end if;

            -- Commit the current iteration in autonomous transaction.
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
        generate_xml;

        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab => l_incr_event_tab
        );
    end if;

    close cur_objects;

    if l_full_export = com_api_type_pkg.TRUE and nvl(i_include_notif, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
        -- Process event objects for event close 3d secure service or close notification service
        select eo.id
          bulk collect
          into l_notif_event_tab
          from evt_event_object eo
             , evt_event ev
         where decode(eo.status, 'EVST0001', eo.procedure_name, null) = l_subscriber_name
           and eo.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
           and eo.eff_date       <= l_sysdate
           and eo.split_hash      in (select split_hash from com_api_split_map_vw)
           and eo.event_id        = ev.id
           and ev.event_type      in (iss_api_const_pkg.EVENT_3D_SECURE_DEACTIVATION  -- close 3d secure service
                                    , iss_api_const_pkg.EVENT_NOTIF_DEACTIVATION)     -- or notification service
        ;
        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab => l_notif_event_tab
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_excepted_total  => 0
      , i_processed_total => l_total_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug('export_cards_numbers: FINISH');

    commit; -- Commit the last process changes in autonomous transaction before exit
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        commit; -- Commit the last process changes in autonomous transaction before exit

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;
end export_cards_data_10;

procedure export_cards_data_11(
    i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_event_type          in     com_api_type_pkg.t_dict_value    default null
  , i_include_address     in     com_api_type_pkg.t_boolean       default null
  , i_include_limits      in     com_api_type_pkg.t_boolean       default null
  , i_export_clear_pan    in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_count               in     com_api_type_pkg.t_count
  , i_include_notif       in     com_api_type_pkg.t_boolean       default null
  , i_subscriber_name     in     com_api_type_pkg.t_name          default null
  , i_include_contact     in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_ids_type            in     com_api_type_pkg.t_dict_value    default null
  , i_exclude_npz_cards   in     com_api_type_pkg.t_boolean       default null
  , i_include_service     in     com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
  , i_include_note        in     com_api_type_pkg.t_boolean       default null
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := $$PLSQL_UNIT || '.EXPORT_CARDS_DATA_11';

    -- Default bulk size for <card_info> blocks per a file if <i_count> parameter is not specified
    DEFAULT_BULK_LIMIT      constant com_api_type_pkg.t_count := 2000;
    l_bulk_limit            com_api_type_pkg.t_count          := nvl(i_count, DEFAULT_BULK_LIMIT);
    l_subscriber_name       com_api_type_pkg.t_name           := upper(nvl(i_subscriber_name, DEFAULT_PROCEDURE_NAME));
    l_full_export           com_api_type_pkg.t_boolean        := nvl(i_full_export, com_api_type_pkg.FALSE);
    l_export_clear_pan      com_api_type_pkg.t_boolean        := nvl(i_export_clear_pan, com_api_const_pkg.TRUE);
    l_customer_value_type   com_api_type_pkg.t_boolean        := com_api_type_pkg.FALSE;
    l_file                  clob;
    l_total_count           com_api_type_pkg.t_count          := 0;
    l_counter               com_api_type_pkg.t_count          := 0;

    l_event_tab             com_api_type_pkg.t_number_tab;
    l_incr_event_tab        com_api_type_pkg.t_number_tab;
    l_instance_id_tab       num_tab_tpt                       := num_tab_tpt();
    l_incr_instance_id_tab  num_tab_tpt                       := num_tab_tpt();
    l_instance_id           com_api_type_pkg.t_medium_id;
    l_notif_event_tab       com_api_type_pkg.t_number_tab;
    l_estimated_count       com_api_type_pkg.t_count          := 0;
    l_current_count         com_api_type_pkg.t_count          := 0;

    l_lang                  com_api_type_pkg.t_dict_value;
    l_service_id_tab        prd_service_tpt;
    l_sysdate               date;

    cursor cur_xml is
        with ids as (
                select column_value from table(cast(l_instance_id_tab as num_tab_tpt))
             )
           , products as (
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
            xmlelement("cards_info"
              , xmlattributes('http://bpc.ru/sv/SVXP/card_info' as "xmlns")
              , xmlelement("file_type", iss_api_const_pkg.FILE_TYPE_CARD_INFO)
              , xmlelement("inst_id", i_inst_id)
              , xmlelement("tokenized_pan"
                         , case l_export_clear_pan
                               when com_api_const_pkg.FALSE
                               then com_api_const_pkg.TRUE
                               else com_api_const_pkg.FALSE
                           end
                )
              , xmlagg(xmlelement("card_info"
                  , xmlforest(
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
                            else nvl(
                                     (select 1
                                        from evt_event_object o
                                           , evt_event e
                                       where decode(o.status, 'EVST0001', o.procedure_name, null) = l_subscriber_name
                                         and e.id = o.event_id
                                         and e.event_type = iss_api_const_pkg.EVENT_TYPE_UPD_SENSITIVE_DATA
                                         and (o.object_id, o.entity_type) in (
                                                 (ci.card_id, iss_api_const_pkg.ENTITY_TYPE_CARD)
                                               , (ci.id,      iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE)
                                             )
                                         and o.split_hash = ci.split_hash
                                         and rownum = 1
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
                      , case when cip.id is not null then iss_api_card_instance_pkg.get_card_uid(i_card_instance_id => cip.id) else null end as "prev_card_id"
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
                    ) -- xmlforest
                  , xmlelement("customer"
                      , xmlforest(
                            case
                                when l_customer_value_type = com_api_type_pkg.TRUE
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
                        )
                      , (select xmlagg(
                                    xmlelement("flexible_data"
                                      , xmlelement("field_name",  ff.name)
                                      , xmlelement("field_value"
                                          , case ff.data_type
                                                when com_api_const_pkg.DATA_TYPE_NUMBER then
                                                    to_char(
                                                        to_number(
                                                            fd.field_value
                                                          , nvl(ff.data_format, com_api_const_pkg.NUMBER_FORMAT)
                                                        )
                                                      , com_api_const_pkg.XML_NUMBER_FORMAT
                                                    )
                                                when com_api_const_pkg.DATA_TYPE_DATE   then
                                                    to_char(
                                                        to_date(
                                                            fd.field_value
                                                          , nvl(ff.data_format, com_api_const_pkg.DATE_FORMAT)
                                                        )
                                                      , com_api_const_pkg.XML_DATE_FORMAT
                                                    )
                                                else
                                                    fd.field_value
                                            end
                                        )
                                    )
                                )
                           from com_flexible_field ff
                              , com_flexible_data  fd
                          where ff.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                            and fd.field_id    = ff.id
                            and fd.object_id   = m.id
                        ) -- customer flexible fields
                    )
                  , xmlelement("cardholder"
                      , xmlforest(
                            h.cardholder_number       as "cardholder_number"
                          , h.cardholder_name         as "cardholder_name"
                        )
                      , (select
                             xmlagg(
                                 xmlelement("person"
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
                                                   , io.id_issuer      as "id_issuer"
                                                   , to_char(io.id_issue_date, com_api_const_pkg.XML_DATE_FORMAT)  as "id_issue_date"
                                                   , to_char(io.id_expire_date, com_api_const_pkg.XML_DATE_FORMAT)  as "id_expire_date"
                                                   , com_ui_id_object_pkg.get_id_card_desc(
                                                         i_entity_type     => com_api_const_pkg.ENTITY_TYPE_PERSON
                                                       , i_object_id       => p.id
                                                       , i_lang            => p.lang
                                                     )                 as "id_desc"
                                                 )
                                             ))
                                        from com_id_object io
                                       where io.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
                                         and io.object_id = p.id
                                         and (i_ids_type is null or i_ids_type = io.id_type)
                                     ) --identity_card
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
                      -- notification
                      , case when nvl(i_include_notif, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE
                                  and ci.state != iss_api_const_pkg.CARD_STATE_CLOSED then

                            case
                                when prd_api_service_pkg.get_active_service_id(
                                         i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CARD
                                       , i_object_id           => ci.card_id
                                       , i_attr_name           => ntf_api_const_pkg.NOTIFICATION_SERVICE_USE_FEE
                                       , i_service_type_id     => ntf_api_const_pkg.NOTIFICATION_CARD_SERVICE
                                       , i_split_hash          => crd.split_hash
                                       , i_eff_date            => l_sysdate
                                       , i_mask_error          => com_api_type_pkg.TRUE
                                       , i_inst_id             => i_inst_id
                                     ) is not null
                                then (
                                    select
                                        xmlagg(
                                            xmlelement("notification"
                                              , xmlelement("service_id"
                                                  , (select prd_api_service_pkg.get_active_service_id(
                                                                i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CARD
                                                              , i_object_id           => ci.card_id
                                                              , i_attr_name           => ntf_api_const_pkg.NOTIFICATION_SERVICE_USE_FEE
                                                              , i_service_type_id     => ntf_api_const_pkg.NOTIFICATION_CARD_SERVICE
                                                              , i_split_hash          => crd.split_hash
                                                              , i_eff_date            => l_sysdate
                                                              , i_mask_error          => com_api_type_pkg.TRUE
                                                              , i_inst_id             => i_inst_id
                                                            ) service_id
                                                       from dual)
                                                )
                                              , xmlelement("notification_event", nvl(n.event_type, aut_api_const_pkg.EVENT_AUTH_BY_CARD))
                                              , xmlelement("delivery_channel", n.channel_id)
                                              , xmlelement("delivery_address", nvl(n.delivery_address, d.commun_address))
                                              , xmlelement("is_active"
                                                  , case
                                                        when co.is_active is not null then
                                                            co.is_active
                                                        when n.status = ntf_api_const_pkg.STATUS_DO_NOT_SEND then
                                                            com_api_type_pkg.FALSE
                                                        else
                                                            com_api_type_pkg.TRUE
                                                    end
                                                )
                                            )
                                        )
                                      from iss_cardholder h
                                         , ntf_custom_event n
                                         , ntf_custom_object co
                                         , com_contact_object o
                                         , com_contact_data d
                                     where h.id               = crd.cardholder_id
                                       and n.object_id(+)     = h.id
                                       and n.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                       and co.custom_event_id(+) = n.id
                                       and co.object_id(+)    = crd.id
                                       and o.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                       and o.object_id(+)     = h.id
                                       and o.contact_type(+)  = com_api_const_pkg.CONTACT_TYPE_NOTIFICATION
                                       and d.contact_id(+)    = o.contact_id
                                       and d.commun_method(+) = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                                       and (d.end_date(+) is null or d.end_date(+) > l_sysdate)
                                       and (n.event_type is null or n.event_type != iss_api_const_pkg.EVENT_3D_SECURE_AUTH_REQUEST)
                                )
                                else (
                                    select
                                        xmlagg(
                                            xmlelement("notification"
                                              , xmlelement("service_id"
                                                  , (select prd_api_service_pkg.get_active_service_id(
                                                                i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CARD
                                                              , i_object_id           => ci.card_id
                                                              , i_attr_name           => ntf_api_const_pkg.NOTIFICATION_SERVICE_USE_FEE
                                                              , i_service_type_id     => ntf_api_const_pkg.NOTIFICATION_CARD_SERVICE
                                                              , i_split_hash          => crd.split_hash
                                                              , i_eff_date            => l_sysdate
                                                              , i_last_active         => com_api_type_pkg.TRUE
                                                              , i_mask_error          => com_api_type_pkg.TRUE
                                                              , i_inst_id             => i_inst_id
                                                        ) service_id
                                                   from dual)
                                                )
                                              , xmlelement("notification_event", nvl(e.event_type, aut_api_const_pkg.EVENT_AUTH_BY_CARD))
                                              , xmlelement("delivery_channel", n.channel_id)
                                              , xmlelement("delivery_address", nvl(n.delivery_address, d.commun_address))
                                              , xmlelement("is_active", 0) --inactive
                                            )
                                        )
                                      from iss_cardholder h
                                         , ntf_custom_event n
                                         , ntf_custom_object co
                                         , com_contact_object o
                                         , com_contact_data d
                                         , evt_event_object eo
                                         , evt_event e
                                     where h.id               = crd.cardholder_id
                                       and decode(eo.status, 'EVST0001', eo.procedure_name, null) = l_subscriber_name
                                       and eo.object_id       = crd.id
                                       and eo.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
                                       and eo.eff_date       <= l_sysdate
                                       and eo.split_hash      = ci.split_hash
                                       and eo.event_id        = e.id
                                       and e.event_type       = iss_api_const_pkg.EVENT_NOTIF_DEACTIVATION   -- close notification service
                                       and n.object_id(+)     = h.id
                                       and n.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                       and co.custom_event_id(+) = n.id
                                       and co.object_id(+)       = crd.id
                                       and o.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                       and o.object_id(+)     = h.id
                                       and o.contact_type(+)  = com_api_const_pkg.CONTACT_TYPE_NOTIFICATION
                                       and d.contact_id(+)    = o.contact_id
                                       and d.commun_method(+) = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                                       and (d.end_date(+) is null or d.end_date(+) > l_sysdate)
                                       and (n.event_type is null or n.event_type != iss_api_const_pkg.EVENT_3D_SECURE_AUTH_REQUEST)
                                )
                            end
                        end
                      -- 3D secure
                      , case when nvl(i_include_notif, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE
                                  and ci.state != iss_api_const_pkg.CARD_STATE_CLOSED then

                            case
                                when prd_api_service_pkg.get_active_service_id(
                                         i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CARD
                                       , i_object_id           => ci.card_id
                                       , i_attr_name           => null
                                       , i_service_type_id     => ntf_api_const_pkg.THREE_D_SECURE_CARD_SERVICE
                                       , i_split_hash          => crd.split_hash
                                       , i_eff_date            => l_sysdate
                                       , i_mask_error          => com_api_type_pkg.TRUE
                                       , i_inst_id             => i_inst_id
                                     ) is not null
                                then (
                                    select
                                        xmlagg(
                                            xmlelement("notification"
                                              , xmlelement("service_id"
                                                  , (select prd_api_service_pkg.get_active_service_id(
                                                                i_entity_type     => iss_api_const_pkg.ENTITY_TYPE_CARD
                                                              , i_object_id       => ci.card_id
                                                              , i_attr_name       => null
                                                              , i_service_type_id => ntf_api_const_pkg.THREE_D_SECURE_CARD_SERVICE
                                                              , i_split_hash      => crd.split_hash
                                                              , i_eff_date        => l_sysdate
                                                              , i_mask_error      => com_api_type_pkg.TRUE
                                                              , i_inst_id         => i_inst_id
                                                            ) as service_id
                                                       from dual)
                                                )
                                              , xmlelement("notification_event", e.event_type)
                                              , xmlelement("delivery_channel", dc.channel_id)
                                              , xmlelement("delivery_address", nvl(dc.delivery_address, d.commun_address))
                                              , xmlelement("is_active"
                                                  , case
                                                        when dc.is_active is not null then
                                                            dc.is_active
                                                        when dc.status = ntf_api_const_pkg.STATUS_DO_NOT_SEND then
                                                            com_api_type_pkg.FALSE
                                                        else
                                                            com_api_type_pkg.TRUE
                                                    end
                                                )
                                            )
                                        )
                                      from iss_cardholder h
                                         , ntf_scheme_event e
                                         , com_contact_object o
                                         , com_contact_data d
                                         , (select n.id
                                                 , n.channel_id 
                                                 , n.delivery_address
                                                 , co.is_active
                                                 , n.status
                                                 , n.object_id
                                                 , co.object_id   card_id
                                                 , case when co.is_active = com_api_type_pkg.FALSE then 1 else row_number() over (partition by n.scheme_event_id, n.entity_type, n.object_id, co.is_active order by n.id desc) end rn
                                              from ntf_custom_event  n
                                                 , ntf_custom_object co
                                             where n.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                               and (n.event_type is null
                                                    or n.event_type = iss_api_const_pkg.EVENT_3D_SECURE_AUTH_REQUEST
                                                   )
                                               and co.custom_event_id(+) = n.id
                                            ) dc
                                     where h.id               = crd.cardholder_id
                                       and dc.object_id(+)    = h.id
                                       and dc.card_id(+)      = crd.id
                                       and dc.rn              = 1
                                       and e.entity_type      = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                       and e.event_type       = iss_api_const_pkg.EVENT_3D_SECURE_AUTH_REQUEST
                                       and e.scheme_id        = prd_api_product_pkg.get_attr_value_number(
                                                                     i_entity_type     => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                                                   , i_object_id       => crd.customer_id
                                                                   , i_attr_name       => 'NOTIFICATION_SCHEME'
                                                                   , i_mask_error      => com_api_type_pkg.TRUE
                                                                 )
                                       and o.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                       and o.object_id(+)     = h.id
                                       and o.contact_type(+)  = com_api_const_pkg.CONTACT_TYPE_NOTIFICATION
                                       and d.contact_id(+)    = o.contact_id
                                       and d.commun_method(+) = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                                       and (d.end_date(+) is null or d.end_date(+) > l_sysdate)
                                )
                                else (
                                    select
                                        xmlagg(
                                            xmlelement("notification"
                                              , xmlelement("service_id"
                                                  , (select prd_api_service_pkg.get_active_service_id(
                                                                i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CARD
                                                              , i_object_id           => ci.card_id
                                                              , i_attr_name           => null
                                                              , i_service_type_id     => ntf_api_const_pkg.THREE_D_SECURE_CARD_SERVICE
                                                              , i_split_hash          => crd.split_hash
                                                              , i_eff_date            => l_sysdate
                                                              , i_last_active         => com_api_type_pkg.TRUE
                                                              , i_mask_error          => com_api_type_pkg.TRUE
                                                              , i_inst_id             => i_inst_id
                                                            ) service_id
                                                       from dual)
                                                )
                                              , xmlelement("notification_event", e.event_type)
                                              , xmlelement("delivery_channel", dc.channel_id)
                                              , xmlelement("delivery_address", nvl(dc.delivery_address, d.commun_address))
                                              , xmlelement("is_active", com_api_type_pkg.FALSE) --inactive
                                            )
                                        )
                                      from iss_cardholder h
                                         , ntf_scheme_event e
                                         , com_contact_object o
                                         , com_contact_data d
                                         , evt_event_object eo
                                         , evt_event ev
                                         , (select n.id
                                                 , n.channel_id 
                                                 , n.delivery_address
                                                 , co.is_active
                                                 , n.status
                                                 , n.object_id
                                                 , co.object_id   card_id
                                                 , case when co.is_active = com_api_type_pkg.FALSE then 1 else row_number() over (partition by n.scheme_event_id, n.entity_type, n.object_id, co.is_active order by n.id desc) end rn
                                              from ntf_custom_event n
                                                 , ntf_custom_object co
                                             where n.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                               and (n.event_type is null
                                                    or n.event_type = iss_api_const_pkg.EVENT_3D_SECURE_AUTH_REQUEST
                                                   )
                                               and co.custom_event_id(+) = n.id
                                            ) dc
                                     where h.id               = crd.cardholder_id
                                       and dc.object_id(+)    = h.id
                                       and dc.card_id(+)      = crd.id
                                       and dc.rn              = 1
                                       and e.entity_type      = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                       and e.event_type       = iss_api_const_pkg.EVENT_3D_SECURE_AUTH_REQUEST
                                       and e.scheme_id        = prd_api_product_pkg.get_attr_value_number(
                                                                     i_entity_type     => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                                                   , i_object_id       => crd.customer_id
                                                                   , i_attr_name       => 'NOTIFICATION_SCHEME'
                                                                   , i_mask_error      => com_api_type_pkg.TRUE
                                                                 )
                                       and o.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                       and o.object_id(+)     = h.id
                                       and o.contact_type(+)  = com_api_const_pkg.CONTACT_TYPE_NOTIFICATION
                                       and d.contact_id(+)    = o.contact_id
                                       and d.commun_method(+) = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                                       and (d.end_date(+) is null or d.end_date(+) > l_sysdate)
                                       and decode(eo.status, 'EVST0001', eo.procedure_name, null) = l_subscriber_name
                                       and eo.object_id       = crd.id
                                       and eo.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
                                       and eo.eff_date       <= l_sysdate
                                       and eo.split_hash      = ci.split_hash
                                       and eo.event_id        = ev.id
                                       and ev.event_type      = iss_api_const_pkg.EVENT_3D_SECURE_DEACTIVATION -- close 3d secure service
                                )
                            end
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
                    ) --cardholder
                  , (select xmlagg(xmlelement("account"
                              , xmlforest(
                                    ac.account_number   as "account_number"
                                  , ac.currency         as "currency"
                                  , ac.account_type     as "account_type"
                                  , ac.status           as "account_status"
                                  , ao.is_pos_default   as "is_pos_default"
                                  , ao.is_atm_default   as "is_atm_default"
                                )
                            ))
                       from acc_account ac
                          , acc_account_object ao
                      where ac.id = ao.account_id
                        and ac.split_hash  = ci.split_hash
                        and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                        and ao.object_id   = crd.id
                        and ao.split_hash  = ci.split_hash
                    ) --account
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
                  , case when nvl(i_include_limits, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then (
                        select xmlelement("limits",
                                   xmlagg(
                                       xmlelement("limit"
                                         , xmlelement("limit_type",   l.limit_type)
                                         , xmlelement("sum_limit",    nvl(l.sum_limit, 0))
                                         , xmlelement("count_limit",  nvl(l.count_limit, 0))
                                         , xmlelement("sum_current",  nvl(fcl_api_limit_pkg.get_limit_sum_curr(
                                                                              i_limit_type  => l.limit_type
                                                                            , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
                                                                            , i_object_id   => crd.id
                                                                            , i_limit_id    => l.id
                                                                            , i_split_hash  => crd.split_hash
                                                                          )
                                                                        , 0))
                                         , xmlelement("currency",     l.currency)
                                         , xmlelement("next_date",    case
                                                                          when b.next_date > l_sysdate or b.next_date is null
                                                                          then b.next_date
                                                                          else fcl_api_cycle_pkg.calc_next_date(
                                                                                   i_cycle_type  => b.cycle_type
                                                                                 , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
                                                                                 , i_object_id   => crd.id
                                                                                 , i_split_hash  => crd.split_hash
                                                                                 , i_start_date  => l_sysdate
                                                                                 , i_inst_id     => crd.inst_id
                                                                               )
                                                                      end)
                                         , xmlelement("length_type",  c.length_type)
                                         , xmlelement("cycle_length", nvl(c.cycle_length, 999))
                                       )
                                   )
                               )
                          from fcl_limit l
                             , (select to_number(limit_id, com_api_const_pkg.NUMBER_FORMAT) limit_id
                                     , row_number() over (partition by card_id, limit_type order by decode(level_priority, 0, 0, 1)
                                                                                                         , level_priority
                                                                                                         , start_date desc
                                                                                                         , register_timestamp desc) rn
                                     , card_id
                                     , split_hash
                                  from (
                                        select v.attr_value limit_id
                                             , 0 level_priority
                                             , a.object_type limit_type
                                             , v.register_timestamp
                                             , v.start_date
                                             , v.object_id  card_id
                                             , v.split_hash
                                          from prd_attribute_value v
                                             , prd_attribute a
                                         where v.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
                                           and a.entity_type  = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                                           and a.id           = v.attr_id
                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                     union all
                                        select v.attr_value
                                             , p.level_priority
                                             , a.object_type as limit_type
                                             , v.register_timestamp
                                             , v.start_date
                                             , ac.id as card_id
                                             , ac.split_hash
                                          from products p
                                             , prd_attribute_value v
                                             , prd_attribute a
                                             , prd_service_type st
                                             , prd_service s
                                             , prd_product_service ps
                                             , prd_contract c
                                             , iss_card ac
                                         where v.service_id      = s.id
                                           and v.object_id       = decode(a.definition_level, 'SADLSRVC', s.id, p.parent_id)
                                           and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                           and v.attr_id         = a.id
                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                           and a.service_type_id = s.service_type_id
                                           and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT  --'ENTTLIMT'
                                           and st.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
                                           and st.id             = s.service_type_id
                                           and p.product_id      = ps.product_id
                                           and s.id              = ps.service_id
                                           and ps.product_id     = c.product_id
                                           and c.id              = ac.contract_id
                                           and c.split_hash      = ac.split_hash
                                    ) tt
                               ) limits
                             , fcl_cycle c
                             , fcl_cycle_counter b
                         where limits.card_id    = crd.id
                           and limits.split_hash = crd.split_hash
                           and limits.rn         = 1
                           and l.id              = limits.limit_id
                           and c.id(+)           = l.cycle_id
                           and b.cycle_type(+)   = c.cycle_type
                           and b.entity_type(+)  = iss_api_const_pkg.ENTITY_TYPE_CARD
                           and b.object_id(+)    = crd.id
                           and b.split_hash(+)   = crd.split_hash
                    )
                    end --case (limits)
                    --services
                  , case when nvl(i_include_service, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
                        case when l_full_export = com_api_type_pkg.TRUE then (
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
                                                          and a.data_type    = com_api_const_pkg.DATA_TYPE_CHAR --'DTTPCHAR'
                                                          and l_sysdate between nvl(v.start_date, l_sysdate)
                                                                             and nvl(v.end_date,   trunc(l_sysdate)+1)
                                                          and v.service_id in (select id from table(cast(l_service_id_tab as prd_service_tpt)))
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
                                                         from products p
                                                            , prd_attribute_value v
                                                            , prd_attribute a
                                                            , (select distinct id, service_type_id
                                                                 from table(cast(l_service_id_tab as prd_service_tpt))
                                                              ) srv
                                                            , prd_product_service ps
                                                            , prd_contract c
                                                            , iss_card ac
                                                        where v.service_id      = srv.id
                                                          and v.object_id       = decode(a.definition_level, 'SADLSRVC', srv.id, p.parent_id)
                                                          and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                                          and v.attr_id         = a.id
                                                          and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                          and a.service_type_id = srv.service_type_id
                                                          and a.entity_type is null
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
                                   ) -- xmlagg
                              from table(cast(l_service_id_tab as prd_service_tpt)) s
                                 , prd_service_object b
                             where b.service_id    = s.id
                               and b.object_id     = crd.id
                               and b.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD
                               and b.split_hash    = crd.split_hash
                        ) else (
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
                                                          and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                          and v.service_id in (select id from table(cast(l_service_id_tab as prd_service_tpt)))
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
                                                         from products p
                                                            , prd_attribute_value v
                                                            , prd_attribute a
                                                            , (select distinct id, service_type_id
                                                                 from table(cast(l_service_id_tab as prd_service_tpt))
                                                              ) srv
                                                            , prd_product_service ps
                                                            , prd_contract c
                                                            , iss_card ac
                                                        where v.service_id      = srv.id
                                                          and v.object_id       = decode(a.definition_level, 'SADLSRVC', srv.id, p.parent_id)
                                                          and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                                          and v.attr_id         = a.id
                                                          and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                          and a.service_type_id = srv.service_type_id
                                                          and a.entity_type  is null
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
                                   ) -- xmlagg
                              from evt_event_object o
                                 , evt_event e
                                 , table(cast(l_service_id_tab as prd_service_tpt)) s
                                 , prd_service_object b
                             where o.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD
                               and o.object_id     = crd.id
                               and o.split_hash    = crd.split_hash
                               and o.eff_date      <= l_sysdate
                               and e.id            = o.event_id
                               and s.event_type    = e.event_type
                               and s.id            = b.service_id
                               and o.object_id     = b.object_id
                               and o.entity_type   = b.entity_type
                               and o.split_hash    = b.split_hash
                        )
                        end
                    end --case (services)
                    --note
                  , case when nvl(i_include_note, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
                        (select xmlagg(
                                    xmlelement("note"
                                      , xmlelement("note_type", n.note_type)
                                      , xmlagg(
                                            xmlelement("note_content"
                                              , xmlattributes(l_lang as "language")
                                              , xmlforest(
                                                    com_api_i18n_pkg.get_text(
                                                        i_table_name  => 'ntb_note'
                                                      , i_column_name => 'header'
                                                      , i_object_id   => n.id
                                                      , i_lang        => l_lang
                                                    ) as "note_header"
                                                  , com_api_i18n_pkg.get_text(
                                                        i_table_name  => 'ntb_note'
                                                      , i_column_name => 'text'
                                                      , i_object_id   => n.id
                                                      , i_lang        => l_lang
                                                    ) as "note_text"
                                                )
                                            )
                                        )
                                      , xmlelement("start_date", to_char(n.start_date, com_api_const_pkg.XML_DATE_FORMAT))
                                      , xmlelement("end_date", to_char(n.end_date, com_api_const_pkg.XML_DATE_FORMAT))
                                    )
                                )
                           from ntb_note n
                          where n.object_id = crd.id
                            and n.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                            and ((n.start_date is null and l_sysdate <= nvl(n.end_date, l_sysdate))
                                 or
                                 (n.end_date is null and l_sysdate >= nvl(n.start_date, l_sysdate))
                                 or
                                 (l_sysdate between n.start_date and n.end_date)
                                )
                          group by
                                n.note_type, n.start_date, n.end_date
                        )
                    end --case (note)   
                  , (select xmlagg(
                                xmlelement("flexible_data"
                                  , xmlelement("field_name", ff.name)
                                  , xmlelement("field_value"
                                      , case ff.data_type
                                            when com_api_const_pkg.DATA_TYPE_NUMBER then
                                                to_char(
                                                    to_number(
                                                        fd.field_value
                                                      , nvl(ff.data_format, com_api_const_pkg.NUMBER_FORMAT)
                                                    )
                                                  , com_api_const_pkg.XML_NUMBER_FORMAT
                                                )
                                            when com_api_const_pkg.DATA_TYPE_DATE   then
                                                to_char(
                                                    to_date(
                                                        fd.field_value
                                                      , nvl(ff.data_format, com_api_const_pkg.DATE_FORMAT)
                                                    )
                                                  , com_api_const_pkg.XML_DATE_FORMAT
                                                )
                                            else
                                                fd.field_value
                                        end
                                    )
                                )
                            )
                       from com_flexible_field ff
                          , com_flexible_data  fd
                      where ff.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                        and fd.field_id    = ff.id
                        and fd.object_id   = crd.id
                    ) -- card flexible fields
                  , iss_cst_export_pkg.generate_add_data(
                        i_card_id => crd.id
                    )
                ))  --xmlagg(<card_info>)
            ).getclobval()  --xml root element
          , count(1)
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
        where ci.id in (select column_value from ids)
          and ci.split_hash in (select split_hash from com_api_split_map_vw)
          and crd.id              = ci.card_id
          and crd.split_hash      = ci.split_hash
          and ct.id               = crd.contract_id
          and ct.split_hash       = ci.split_hash
          and pr.id               = ct.product_id
          and m.id                = crd.customer_id
          and m.split_hash        = ci.split_hash
          and crd.cardholder_id   = h.id(+)
          and cd.card_instance_id(+) = ci.id
          and cip.id(+)           = ci.preceding_card_instance_id
          and cip.split_hash(+)   = ci.split_hash
          and cnp.card_id(+)      = cip.card_id
          and a.id                = ci.agent_id
    ;

    cur_objects             sys_refcursor;

    l_container_id         com_api_type_pkg.t_long_id;

    -- Function returns a reference for a cursor with card instances being processed.
    -- In case of incremental unloading it also returns event objects' identifiers.
    procedure open_cur_objects(
        o_cursor               out sys_refcursor
      , i_full_export       in     com_api_type_pkg.t_boolean
      , i_inst_id           in     com_api_type_pkg.t_inst_id
    ) is
    begin
        trc_log_pkg.debug('Opening a cursor for all card instances those are processed...');

        if i_full_export = com_api_type_pkg.TRUE then
            -- Get current instances for all available cards
            open o_cursor for
                select max(ci.id)
                  from iss_card_instance ci
                 where ci.split_hash in (select split_hash from com_api_split_map_vw)
                   and (i_inst_id is null or ci.inst_id = i_inst_id)
              group by ci.card_id;
        else
            -- Get current cards' instances by events
            open o_cursor for
                select v.event_object_id
                     , max(v.card_instance_id)
                  from (
                        select a.id  as event_object_id
                             , ci.id as card_instance_id
                             , ci.card_id
                          from evt_event_object a
                             , iss_card_instance ci
                             , evt_event e
                         where decode(a.status, 'EVST0001', a.procedure_name, null) = l_subscriber_name
                           and a.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                           and a.object_id   = ci.card_id
                           and a.split_hash  = ci.split_hash
                           and a.eff_date   <= l_sysdate
                           and ci.split_hash in (select split_hash from com_api_split_map_vw)
                           and (i_inst_id is null or ci.inst_id = i_inst_id)
                           and e.id          = a.event_id
                           and (i_event_type is null or i_event_type = e.event_type)
                           and (nvl(i_exclude_npz_cards, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE
                                or
                                i_exclude_npz_cards = com_api_type_pkg.TRUE
                                and ci.state != iss_api_const_pkg.CARD_STATE_PERSONALIZATION)
                           and (a.container_id is null or a.container_id = l_container_id)      
                        union all
                        select a.id  as event_object_id
                             , ci.id as card_instance_id
                             , ci.card_id
                          from evt_event_object a
                             , iss_card_instance ci
                             , evt_event e
                         where decode(a.status, 'EVST0001', a.procedure_name, null) = l_subscriber_name
                           and a.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                           and a.object_id   = ci.id
                           and a.split_hash  = ci.split_hash
                           and a.eff_date   <= l_sysdate
                           and ci.split_hash in (select split_hash from com_api_split_map_vw)
                           and (i_inst_id is null or ci.inst_id = i_inst_id)
                           and e.id          = a.event_id
                           and (i_event_type is null or i_event_type = e.event_type)
                           and (nvl(i_exclude_npz_cards, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE
                                or
                                i_exclude_npz_cards = com_api_type_pkg.TRUE
                                and ci.state != iss_api_const_pkg.CARD_STATE_PERSONALIZATION)
                           and (a.container_id is null or a.container_id = l_container_id)      
                        union all
                        select a.id  as event_object_id
                             , ci.id as card_instance_id
                             , ci.card_id
                          from evt_event_object a
                             , iss_card c
                             , iss_card_instance ci
                             , evt_event e
                         where decode(a.status, 'EVST0001', a.procedure_name, null) = l_subscriber_name
                           and a.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                           and a.object_id   = c.cardholder_id
                           and a.split_hash  = ci.split_hash
                           and a.eff_date   <= l_sysdate
                           and ci.split_hash in (select split_hash from com_api_split_map_vw)
                           and ci.card_id    = c.id
                           and ci.seq_number = (select max(t.seq_number) from iss_card_instance t where t.card_id = c.id)
                           and (i_inst_id is null or ci.inst_id = i_inst_id)
                           and e.id          = a.event_id
                           and (i_event_type is null or i_event_type = e.event_type)
                           and (nvl(i_exclude_npz_cards, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE
                                or
                                i_exclude_npz_cards = com_api_type_pkg.TRUE
                                and ci.state != iss_api_const_pkg.CARD_STATE_PERSONALIZATION)
                           and (a.container_id is null or a.container_id = l_container_id)      
                        -- Also it is necessary to select all cards which products' attributes have been changed
                        -- only not closed cards are processed
                        union all
                        select a.id  as event_object_id
                             , ci.id as card_instance_id
                             , ci.card_id
                          from evt_event_object a
                             , evt_event e
                             , prd_product p
                             , prd_contract ct
                             , iss_card c
                             , iss_card_instance ci
                         where i_include_limits = com_api_type_pkg.TRUE
                           and decode(a.status, 'EVST0001', a.procedure_name, null) = l_subscriber_name
                           and a.entity_type  = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
                           and a.eff_date    <= l_sysdate
                           and e.id           = a.event_id
                           and e.event_type   = prd_api_const_pkg.EVENT_ATTRIBUTE_CHANGE_PRODUCT
                           and p.id           = a.object_id
                           and p.product_type = prd_api_const_pkg.PRODUCT_TYPE_ISS
                           and ct.product_id  = a.object_id
                           and c.contract_id  = ct.id
                           and ci.card_id     = c.id
                           and ci.split_hash in (select split_hash from com_api_split_map_vw)
                           and ct.split_hash  = ci.split_hash
                           and c.split_hash   = ci.split_hash
                           and (nvl(i_exclude_npz_cards, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE
                                or
                                i_exclude_npz_cards = com_api_type_pkg.TRUE
                                and ci.state != iss_api_const_pkg.CARD_STATE_PERSONALIZATION)
                           and ci.state != iss_api_const_pkg.CARD_STATE_CLOSED
                        -- Also it is necessary to select all cards which product_id have been changed in contract
                           and (a.container_id is null or a.container_id = l_container_id)      
                        union all
                        select a.id  as event_object_id
                             , ci.id as card_instance_id
                             , ci.card_id
                          from evt_event_object a
                             , evt_event e
                             , iss_card c
                             , iss_card_instance ci
                         where i_include_limits = com_api_type_pkg.TRUE
                           and decode(a.status, 'EVST0001', a.procedure_name, null) = l_subscriber_name
                           and a.entity_type  = prd_api_const_pkg.ENTITY_TYPE_CONTRACT
                           and a.eff_date    <= l_sysdate
                           and e.id           = a.event_id
                           and e.event_type   = prd_api_const_pkg.EVENT_PRODUCT_CHANGE
                           and c.contract_id  = a.object_id
                           and ci.card_id     = c.id
                           and ci.split_hash in (select split_hash from com_api_split_map_vw)
                           and c.split_hash   = ci.split_hash
                           and (nvl(i_exclude_npz_cards, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE
                                or 
                                i_exclude_npz_cards = com_api_type_pkg.TRUE
                                and ci.state != iss_api_const_pkg.CARD_STATE_PERSONALIZATION)
                           and (a.container_id is null or a.container_id = l_container_id)      
                       ) v
              group by v.card_id
                     , v.event_object_id
              order by 2 asc -- card_instance_id
            ;
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
        trc_log_pkg.debug('Creating a new XML file...');

        l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

        rul_api_param_pkg.set_param (
            i_name          => 'INST_ID'
          , i_value         => i_inst_id
          , io_params       => l_params
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

        trc_log_pkg.debug('file saved, count='||i_counter||', length='||length(l_file));
    end save_file;

    -- Generate XML file
    procedure generate_xml is
        l_fetched_count        com_api_type_pkg.t_count    := 0;
    begin
        if l_instance_id_tab.count() > 0 then
            -- For every processing batch of card instances we fetch data and save it in a separate file
            open cur_xml;
            fetch cur_xml into l_file, l_fetched_count;
            close cur_xml;

            l_counter := l_counter + 1;

            save_file(
                i_counter        => l_fetched_count
            );

            l_total_count := l_total_count + l_current_count;

            prc_api_stat_pkg.log_current(
                i_current_count  => l_total_count
              , i_excepted_count => 0
            );
        end if;
    end generate_xml;

    procedure save_estimation is
    begin
        l_estimated_count := l_estimated_count + l_current_count;

        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_estimated_count
        );
        trc_log_pkg.debug('Estimated count of cards is [' || l_estimated_count || ']');
    end save_estimation;

begin
    trc_log_pkg.debug(
        i_text       => 'export_cards_numbers: START with l_full_export [#1], i_include_address [#2]'
                        || ', i_include_limits [#3], i_inst_id [#4], i_count [#5]'
      , i_env_param1 => l_full_export
      , i_env_param2 => i_include_address
      , i_env_param3 => i_include_limits
      , i_env_param4 => i_inst_id
      , i_env_param5 => i_count
      , i_env_param6 => i_include_service
    );

    l_lang      := nvl(i_lang, com_ui_user_env_pkg.get_user_lang());
    l_sysdate   := com_api_sttl_day_pkg.get_sysdate;

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
        i_text       => 'l_export_clear_pan [#1] l_lang [#2] l_customer_value_type [#3] l_container_id [#4]'
      , i_env_param1 => l_export_clear_pan
      , i_env_param2 => l_lang
      , i_env_param3 => l_customer_value_type
      , i_env_param4 => l_container_id
    );

    prc_api_stat_pkg.log_start;

    if nvl(i_include_service, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then

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
              bulk collect into l_service_id_tab
              from prd_service_type t
                 , prd_service s
             where entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
               and product_type = prd_api_const_pkg.PRODUCT_TYPE_ISS --'PRDT0100'
               and t.id not in (ntf_api_const_pkg.NOTIFICATION_CARD_SERVICE, ntf_api_const_pkg.THREE_D_SECURE_CARD_SERVICE)
               and s.service_type_id = t.id;

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
              bulk collect into l_service_id_tab
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
                       and id not in (ntf_api_const_pkg.NOTIFICATION_CARD_SERVICE, ntf_api_const_pkg.THREE_D_SECURE_CARD_SERVICE)
                    union
                    select id
                         , disable_event_type event_type
                         , get_text ('prd_service_type', 'label', id, l_lang) service_type_name
                         , external_code
                         , 0 is_active
                      from prd_service_type
                     where entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
                       and product_type = prd_api_const_pkg.PRODUCT_TYPE_ISS --'PRDT0100'
                       and id not in (ntf_api_const_pkg.NOTIFICATION_CARD_SERVICE, ntf_api_const_pkg.THREE_D_SECURE_CARD_SERVICE)
                ) t
            where s.service_type_id = t.id;

        end if;

        trc_log_pkg.debug(
            i_text => 'Collection created. Count = ' || l_service_id_tab.count
        );

    end if;

    open_cur_objects(
        o_cursor      => cur_objects
      , i_full_export => l_full_export
      , i_inst_id     => i_inst_id
    );

    loop
        begin
            savepoint sp_before_iteration;

            if l_full_export = com_api_type_pkg.TRUE then
                fetch cur_objects
                 bulk collect into
                      l_instance_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                l_current_count := l_instance_id_tab.count;

                save_estimation;

                -- Generate XML file
                generate_xml;

            else  -- l_full_export = com_api_type_pkg.FALSE
                fetch cur_objects
                 bulk collect into
                      l_event_tab
                    , l_incr_instance_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                l_current_count := l_incr_instance_id_tab.count;

                save_estimation;

                for i in 1 .. l_incr_instance_id_tab.count loop
                    -- Decrease card instance count and remove the last card instance id from previous iteration
                    if (l_incr_instance_id_tab(i) != l_instance_id or l_instance_id is null)
                       and l_incr_instance_id_tab(i) is not null
                    then
                        l_instance_id_tab.extend;
                        l_instance_id_tab(l_instance_id_tab.count)   := l_incr_instance_id_tab(i);
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);

                        if l_instance_id_tab.count > l_bulk_limit then
                            -- Generate XML file for current portion of the "l_bulk_limit" records
                            generate_xml;

                            -- In case of full export mode all elements of collection <l_event_tab> are null
                            evt_api_event_pkg.process_event_object(
                                i_event_object_id_tab => l_incr_event_tab
                            );

                            -- Save last element of the array on a current iteration to use it for the next one
                            l_instance_id := l_incr_instance_id_tab(i);
                            l_instance_id_tab.delete;
                            l_incr_event_tab.delete;
                        end if;
                    end if;
                end loop;

            end if;

            -- Commit the current iteration in autonomous transaction.
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
        generate_xml;

        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab => l_incr_event_tab
        );
    end if;

    close cur_objects;

    if l_full_export = com_api_type_pkg.TRUE and nvl(i_include_notif, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
        -- Process event objects for event close 3d secure service or close notification service
        select eo.id
          bulk collect
          into l_notif_event_tab
          from evt_event_object eo
             , evt_event ev
         where decode(eo.status, 'EVST0001', eo.procedure_name, null) = l_subscriber_name
           and eo.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
           and eo.eff_date       <= l_sysdate
           and eo.split_hash      in (select split_hash from com_api_split_map_vw)
           and eo.event_id        = ev.id
           and ev.event_type      in (iss_api_const_pkg.EVENT_3D_SECURE_DEACTIVATION  -- close 3d secure service
                                    , iss_api_const_pkg.EVENT_NOTIF_DEACTIVATION)     -- or notification service
        ;
        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab => l_notif_event_tab
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_excepted_total  => 0
      , i_processed_total => l_total_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug('export_cards_numbers: FINISH');

    commit; -- Commit the last process changes in autonomous transaction before exit
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        commit; -- Commit the last process changes in autonomous transaction before exit

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;
end export_cards_data_11;

procedure export_cards_data_12(
    i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_event_type          in     com_api_type_pkg.t_dict_value    default null
  , i_include_address     in     com_api_type_pkg.t_boolean       default null
  , i_include_limits      in     com_api_type_pkg.t_boolean       default null
  , i_export_clear_pan    in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_count               in     com_api_type_pkg.t_count
  , i_include_notif       in     com_api_type_pkg.t_boolean       default null
  , i_subscriber_name     in     com_api_type_pkg.t_name          default null
  , i_include_contact     in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_ids_type            in     com_api_type_pkg.t_dict_value    default null
  , i_exclude_npz_cards   in     com_api_type_pkg.t_boolean       default null
  , i_include_service     in     com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
  , i_include_note        in     com_api_type_pkg.t_boolean       default null
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := $$PLSQL_UNIT || '.EXPORT_CARDS_DATA_12';
begin

    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': start'
    );

    export_cards_data_11(
        i_full_export       => i_full_export
      , i_event_type          => i_event_type
      , i_include_address     => i_include_address
      , i_include_limits      => i_include_limits
      , i_export_clear_pan    => i_export_clear_pan
      , i_inst_id             => i_inst_id
      , i_count               => i_count
      , i_include_notif       => i_include_notif
      , i_subscriber_name     => i_subscriber_name
      , i_include_contact     => i_include_contact
      , i_lang                => i_lang
      , i_ids_type            => i_ids_type
      , i_exclude_npz_cards   => i_exclude_npz_cards
      , i_include_service     => i_include_service
      , i_include_note        => i_include_note
    );

    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': finish success'
    );

end export_cards_data_12;

procedure export_cards_data_13(
    i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_event_type          in     com_api_type_pkg.t_dict_value    default null
  , i_include_address     in     com_api_type_pkg.t_boolean       default null
  , i_include_limits      in     com_api_type_pkg.t_boolean       default null
  , i_export_clear_pan    in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_count               in     com_api_type_pkg.t_count
  , i_include_notif       in     com_api_type_pkg.t_boolean       default null
  , i_subscriber_name     in     com_api_type_pkg.t_name          default null
  , i_include_contact     in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_ids_type            in     com_api_type_pkg.t_dict_value    default null
  , i_exclude_npz_cards   in     com_api_type_pkg.t_boolean       default null
  , i_include_service     in     com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
  , i_include_note        in     com_api_type_pkg.t_boolean       default null
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := $$PLSQL_UNIT || '.EXPORT_CARDS_DATA_13';
begin

    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': start'
    );

    export_cards_data_11(
        i_full_export       => i_full_export
      , i_event_type          => i_event_type
      , i_include_address     => i_include_address
      , i_include_limits      => i_include_limits
      , i_export_clear_pan    => i_export_clear_pan
      , i_inst_id             => i_inst_id
      , i_count               => i_count
      , i_include_notif       => i_include_notif
      , i_subscriber_name     => i_subscriber_name
      , i_include_contact     => i_include_contact
      , i_lang                => i_lang
      , i_ids_type            => i_ids_type
      , i_exclude_npz_cards   => i_exclude_npz_cards
      , i_include_service     => i_include_service
      , i_include_note        => i_include_note
    );

    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': finish success'
    );

end export_cards_data_13;

procedure export_cards_data_14(
    i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_event_type          in     com_api_type_pkg.t_dict_value    default null
  , i_include_address     in     com_api_type_pkg.t_boolean       default null
  , i_include_limits      in     com_api_type_pkg.t_boolean       default null
  , i_export_clear_pan    in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_count               in     com_api_type_pkg.t_count
  , i_include_notif       in     com_api_type_pkg.t_boolean       default null
  , i_subscriber_name     in     com_api_type_pkg.t_name          default null
  , i_include_contact     in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_ids_type            in     com_api_type_pkg.t_dict_value    default null
  , i_exclude_npz_cards   in     com_api_type_pkg.t_boolean       default null
  , i_include_service     in     com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
  , i_include_note        in     com_api_type_pkg.t_boolean       default null
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := $$PLSQL_UNIT || '.EXPORT_CARDS_DATA_14';
begin

    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': start'
    );

    export_cards_data_11(
        i_full_export       => i_full_export
      , i_event_type          => i_event_type
      , i_include_address     => i_include_address
      , i_include_limits      => i_include_limits
      , i_export_clear_pan    => i_export_clear_pan
      , i_inst_id             => i_inst_id
      , i_count               => i_count
      , i_include_notif       => i_include_notif
      , i_subscriber_name     => i_subscriber_name
      , i_include_contact     => i_include_contact
      , i_lang                => i_lang
      , i_ids_type            => i_ids_type
      , i_exclude_npz_cards   => i_exclude_npz_cards
      , i_include_service     => i_include_service
      , i_include_note        => i_include_note
    );

    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': finish success'
    );

end export_cards_data_14;

procedure export_cards_data_15(
    i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_event_type          in     com_api_type_pkg.t_dict_value    default null
  , i_include_address     in     com_api_type_pkg.t_boolean       default null
  , i_include_limits      in     com_api_type_pkg.t_boolean       default null
  , i_export_clear_pan    in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_count               in     com_api_type_pkg.t_count
  , i_include_notif       in     com_api_type_pkg.t_boolean       default null
  , i_subscriber_name     in     com_api_type_pkg.t_name          default null
  , i_include_contact     in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_ids_type            in     com_api_type_pkg.t_dict_value    default null
  , i_exclude_npz_cards   in     com_api_type_pkg.t_boolean       default null
  , i_include_service     in     com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
  , i_include_note        in     com_api_type_pkg.t_boolean       default null
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := $$PLSQL_UNIT || '.EXPORT_CARDS_DATA_15';
begin

    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': start'
    );

    export_cards_data_11(
        i_full_export       => i_full_export
      , i_event_type          => i_event_type
      , i_include_address     => i_include_address
      , i_include_limits      => i_include_limits
      , i_export_clear_pan    => i_export_clear_pan
      , i_inst_id             => i_inst_id
      , i_count               => i_count
      , i_include_notif       => i_include_notif
      , i_subscriber_name     => i_subscriber_name
      , i_include_contact     => i_include_contact
      , i_lang                => i_lang
      , i_ids_type            => i_ids_type
      , i_exclude_npz_cards   => i_exclude_npz_cards
      , i_include_service     => i_include_service
      , i_include_note        => i_include_note
    );

    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': finish success'
    );

end export_cards_data_15;

procedure export_merchant_data_10(
    i_inst_id             in     com_api_type_pkg.t_inst_id      
  , i_agent_id            in     com_api_type_pkg.t_agent_id     default null
  , i_full_export         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits       in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_accounts     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count               in     com_api_type_pkg.t_medium_id    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name         default null
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
) is
    DEFAULT_PROCEDURE_NAME constant com_api_type_pkg.t_name  := $$PLSQL_UNIT || '.EXPORT_MERCHANT_DATA_10';
    
    l_session_file_id      com_api_type_pkg.t_long_id;
    l_file                 clob;
    l_file_type            com_api_type_pkg.t_dict_value;
    l_subscriber_name      com_api_type_pkg.t_name           := upper(nvl(i_subscriber_name, DEFAULT_PROCEDURE_NAME));
    l_container_id         com_api_type_pkg.t_long_id        :=  prc_api_session_pkg.get_container_id;
    l_unload_limits        com_api_type_pkg.t_boolean;
    l_full_export          com_api_type_pkg.t_boolean;
    l_estimated_count      com_api_type_pkg.t_long_id := 0;
    l_lang                 com_api_type_pkg.t_dict_value;
    l_params               com_api_type_pkg.t_param_tab;

    l_event_tab            com_api_type_pkg.t_number_tab;
    l_merchant_id_tab      num_tab_tpt;
    l_bulk_limit           com_api_type_pkg.t_count := 2000;
    l_sysdate              date;
    l_unload_accounts      com_api_type_pkg.t_boolean;
    l_include_service      com_api_type_pkg.t_boolean;
    l_service_id_tab       prd_service_tpt;
    l_eff_date             date;

    cursor all_merchant_cur is
        select m.id
          from acq_merchant m
             , prd_contract c
             , prd_customer s
         where m.split_hash in (select split_hash from com_api_split_map_vw)
           and (i_inst_id   = ost_api_const_pkg.DEFAULT_INST or m.inst_id = i_inst_id)
           and c.id         = m.contract_id
           and s.id         = c.customer_id
           and (c.agent_id  = i_agent_id or i_agent_id is null)
        ;

    cursor evt_objects_merchant_cur is
        select o.id
             , m.id
          from evt_event_object o
             , acq_merchant m
             , prd_contract c
             , prd_customer s
         where decode(o.status, 'EVST0001', o.procedure_name, null) = l_subscriber_name
           and m.split_hash in (select split_hash from com_api_split_map_vw)
           and o.eff_date     <= l_sysdate
           and (i_inst_id      = ost_api_const_pkg.DEFAULT_INST or o.inst_id = i_inst_id)
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
           and decode(o.status, 'EVST0001', o.procedure_name, null) = l_subscriber_name
           and o.eff_date      <= l_sysdate
           and (i_inst_id       = ost_api_const_pkg.DEFAULT_INST or o.inst_id = i_inst_id)
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
        ;

    cursor main_xml_cur is
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
                  , xmlelement("institution_id",      i_inst_id)
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
                                              , xmlelement("country",      a.country)
                                              , xmlelement("address_name"
                                                  , xmlelement("region", a.region)
                                                  , xmlelement("city",   a.city)
                                                  , xmlelement("street", a.street)
                                                )
                                              , xmlelement("house",        a.house)
                                              , xmlelement("apartment",    a.apartment)
                                              , xmlelement("postal_code",  a.postal_code)
                                              , xmlelement("place_code",   a.place_code)
                                              , xmlelement("region_code",  a.region_code)
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
                                           and decode(o.status, 'EVST0001', o.procedure_name, null) = l_subscriber_name
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
                              , (-- merchant flexible fileds
                                 select xmlagg(
                                            xmlelement(
                                                evalname(lower(ff.name))
                                              , case ff.data_type
                                                    when com_api_const_pkg.DATA_TYPE_NUMBER then
                                                        to_char(
                                                            to_number(
                                                                fd.field_value
                                                              , nvl(ff.data_format, com_api_const_pkg.NUMBER_FORMAT)
                                                            )
                                                          , com_api_const_pkg.XML_NUMBER_FORMAT
                                                        )
                                                    when com_api_const_pkg.DATA_TYPE_DATE   then
                                                        to_char(
                                                            to_date(
                                                                fd.field_value
                                                              , nvl(ff.data_format, com_api_const_pkg.DATE_FORMAT)
                                                            )
                                                          , com_api_const_pkg.XML_DATE_FORMAT
                                                        )
                                                    else
                                                        fd.field_value
                                                end
                                            )
                                        )
                                   from com_flexible_field ff
                                      , com_flexible_data  fd
                                  where ff.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                    and fd.field_id    = ff.id
                                    and fd.object_id   = m.merchant_id
                                ) -- merchant flexible fileds
                            )) --xmlagg(xmlelement("merchant"
                          , case when l_unload_limits = com_api_const_pkg.TRUE then (
                                select xmlelement("service"
                                         , xmlelement("service_object", xmlattributes(ao.object_id as "id")
                                             , xmlagg(xmlelement("attribute_limit"
                                                 , xmlelement("limit_type",        l.limit_type)
                                                 , xmlelement("limit_sum_value",   nvl(l.sum_limit, 0))
                                                 , xmlelement("limit_count_value", nvl(l.count_limit, 0))
                                                 , xmlelement("sum_current",       nvl(fcl_api_limit_pkg.get_limit_sum_curr(
                                                                                           i_limit_type  => l.limit_type
                                                                                         , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                                                         , i_object_id   => ao.account_id
                                                                                         , i_limit_id    => l.id
                                                                                       )
                                                                                     , 0))
                                                 , xmlelement("currency",          l.currency)
                                                 , xmlelement("length_type",       c.length_type)
                                                 , xmlelement("cycle_length",      c.cycle_length)
                                               ))
                                           )
                                       )
                                  from acc_account_object ao
                                     , (
                                        select distinct
                                               a.object_type limit_type
                                          from prd_attribute a
                                             , prd_service_type t
                                         where t.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                           and a.service_type_id = t.id
                                           and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                                       ) x
                                     , fcl_limit l
                                     , fcl_cycle c
                                 where ao.object_id   = m.merchant_id
                                   and ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                   and l.id           = prd_api_product_pkg.get_limit_id(
                                                            i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                          , i_object_id   => ao.account_id
                                                          , i_limit_type  => x.limit_type
                                                          , i_split_hash  => ao.split_hash
                                                          , i_mask_error  => com_api_const_pkg.TRUE
                                                        )
                                   and c.id(+)       = l.cycle_id
                              group by ao.object_id
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
                        ) -- xmlelement("contract"...
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
                 , c.id as contract_id
                 , c.contract_number
                 , s.id as customer_id
                 , s.customer_number
                 , c.agent_id
                 , a.agent_number
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
    ;

    procedure save_file is
        l_cnt   pls_integer;
    begin
        rul_api_param_pkg.set_param (
            i_name       => 'INST_ID'
            , i_value    => i_inst_id
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
        -- grouping id when events more that one for some merchants
        if l_full_export = com_api_type_pkg.FALSE then

            select count(1)
              into l_cnt
              from (
                select column_value
                  from table(cast(l_merchant_id_tab as num_tab_tpt))
                 group by column_value
              );
        end if;

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
    trc_log_pkg.debug(DEFAULT_PROCEDURE_NAME || ' - Start');

    prc_api_stat_pkg.log_start;

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
    l_eff_date        := com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id);

    trc_log_pkg.debug(
        i_text       =>'container_id=#1, inst=#2, agent=#3, full_export=#4, unload_limits=#5, thread_number=#6'
      , i_env_param1 => l_container_id
      , i_env_param2 => i_inst_id
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

    savepoint sp_merchant_export;

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

        select count(1)
          into l_estimated_count
          from acq_merchant m
             , prd_contract c
             , prd_customer s
         where m.split_hash in (select split_hash from com_api_split_map_vw)
           and (i_inst_id    = ost_api_const_pkg.DEFAULT_INST or m.inst_id = i_inst_id)
           and c.id          = m.contract_id
           and s.id          = c.customer_id
           and (c.agent_id   = i_agent_id or i_agent_id is null)
        ;

        trc_log_pkg.debug(
            i_text => 'Estimate count = [' || l_estimated_count || ']'
        );

        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_estimated_count
        );

        open all_merchant_cur;

        loop
            fetch all_merchant_cur bulk collect into
                  l_merchant_id_tab
            limit l_bulk_limit;

            -- generate xml
            if l_merchant_id_tab.count > 0 then
                open  main_xml_cur;
                fetch main_xml_cur into l_file;
                close main_xml_cur;

                save_file;
            end if;

            exit when all_merchant_cur%notfound;
        end loop;

        close all_merchant_cur;

    else
        select count(distinct merchant_id)
          into l_estimated_count
          from (
              select o.id
                   , m.id as merchant_id
                from evt_event_object o
                   , acq_merchant m
                   , prd_contract c
                   , prd_customer s
               where decode(o.status, 'EVST0001', o.procedure_name, null) = l_subscriber_name
                 and m.split_hash in (select split_hash from com_api_split_map_vw)
                 and o.eff_date      <= l_sysdate
                 and (i_inst_id       = ost_api_const_pkg.DEFAULT_INST or o.inst_id = i_inst_id)
                 and o.entity_type    = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                 and o.object_id      = m.id
                 and m.inst_id        = o.inst_id
                 and c.id             = m.contract_id
                 and s.id             = c.customer_id
                 and (c.agent_id      = i_agent_id or i_agent_id is null)
           union all
              select o.id
                   , m.id as merchant_id
                from evt_event_object o
                   , acc_account_object ao
                   , acq_merchant m
                   , acc_account a
               where o.split_hash in (select split_hash from com_api_split_map_vw)
                 and decode(o.status, 'EVST0001', o.procedure_name, null) = l_subscriber_name
                 and o.eff_date      <= l_sysdate
                 and (i_inst_id       = ost_api_const_pkg.DEFAULT_INST or o.inst_id = i_inst_id)
                 and o.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                 and o.object_id      = ao.account_id
                 and ao.entity_type   = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                 and ao.object_id     = m.id
                 and ao.split_hash    = o.split_hash
                 and m.inst_id        = o.inst_id
                 and a.split_hash     = o.split_hash
                 and a.id             = ao.account_id
                 and (a.agent_id      = i_agent_id or i_agent_id is null)
        );

        trc_log_pkg.debug(
            i_text => 'Estimate count = [' || l_estimated_count || ']'
        );

        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_estimated_count
        );

        open evt_objects_merchant_cur;

        loop
            fetch evt_objects_merchant_cur bulk collect into
                  l_event_tab
                , l_merchant_id_tab
            limit l_bulk_limit;

            -- generate xml
            if l_merchant_id_tab.count > 0 then
                open  main_xml_cur;
                fetch main_xml_cur into l_file;
                close main_xml_cur;

                save_file;

                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab    => l_event_tab
                );
            end if;

            exit when evt_objects_merchant_cur%notfound;
        end loop;

        close evt_objects_merchant_cur;
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_estimated_count
      , i_excepted_total    => 0
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(DEFAULT_PROCEDURE_NAME || ' - End');

exception
    when others then
        rollback to sp_merchant_export;

        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

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
        
end export_merchant_data_10;

procedure export_merchant_data_11(
    i_inst_id             in     com_api_type_pkg.t_inst_id      
  , i_agent_id            in     com_api_type_pkg.t_agent_id     default null
  , i_full_export         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits       in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_accounts     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count               in     com_api_type_pkg.t_medium_id    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name         default null
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
) is

    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := $$PLSQL_UNIT || '.EXPORT_MERCHANT_DATA_11';
    
begin
    
    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': start'
    );
    
    export_merchant_data_10(
        i_inst_id         =>     i_inst_id
      , i_agent_id        =>     i_agent_id
      , i_full_export     =>     i_full_export
      , i_unload_limits   =>     i_unload_limits
      , i_unload_accounts =>     i_unload_accounts
      , i_include_service =>     i_include_service
      , i_count           =>     i_count
      , i_subscriber_name =>     i_subscriber_name
      , i_lang            =>     i_lang
    );
    
    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': finish success'
    );
    
end export_merchant_data_11;

procedure export_merchant_data_12(
    i_inst_id             in     com_api_type_pkg.t_inst_id      
  , i_agent_id            in     com_api_type_pkg.t_agent_id     default null
  , i_full_export         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits       in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_accounts     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count               in     com_api_type_pkg.t_medium_id    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name         default null
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
  , i_ver                 in     com_api_type_pkg.t_dict_value   default null
) is
    DEFAULT_PROCEDURE_NAME constant com_api_type_pkg.t_name  := $$PLSQL_UNIT || '.EXPORT_MERCHANT_DATA_12';
    
    l_session_file_id      com_api_type_pkg.t_long_id;
    l_file                 clob;
    l_file_type            com_api_type_pkg.t_dict_value;
    l_subscriber_name      com_api_type_pkg.t_name           := upper(nvl(i_subscriber_name, DEFAULT_PROCEDURE_NAME));
    l_container_id         com_api_type_pkg.t_long_id        :=  prc_api_session_pkg.get_container_id;
    l_unload_limits        com_api_type_pkg.t_boolean;
    l_full_export          com_api_type_pkg.t_boolean;
    l_estimated_count      com_api_type_pkg.t_long_id := 0;
    l_lang                 com_api_type_pkg.t_dict_value;
    l_params               com_api_type_pkg.t_param_tab;

    l_event_tab            com_api_type_pkg.t_number_tab;
    l_merchant_id_tab      num_tab_tpt;
    l_bulk_limit           com_api_type_pkg.t_count := 2000;
    l_sysdate              date;
    l_unload_accounts      com_api_type_pkg.t_boolean;
    l_include_service      com_api_type_pkg.t_boolean;
    l_service_id_tab       prd_service_tpt;
    l_eff_date             date;

    l_show_merch_card      com_api_type_pkg.t_boolean;
    l_show_risk_indicator  com_api_type_pkg.t_boolean;

    cursor all_merchant_cur is
        select m.id
          from acq_merchant m
             , prd_contract c
             , prd_customer s
         where m.split_hash in (select split_hash from com_api_split_map_vw)
           and (i_inst_id   = ost_api_const_pkg.DEFAULT_INST or m.inst_id = i_inst_id)
           and c.id         = m.contract_id
           and s.id         = c.customer_id
           and (c.agent_id  = i_agent_id or i_agent_id is null)
        ;

    cursor evt_objects_merchant_cur is
        select o.id
             , m.id
          from evt_event_object o
             , acq_merchant m
             , prd_contract c
             , prd_customer s
         where decode(o.status, 'EVST0001', o.procedure_name, null) = l_subscriber_name
           and m.split_hash in (select split_hash from com_api_split_map_vw)
           and o.eff_date     <= l_sysdate
           and (i_inst_id      = ost_api_const_pkg.DEFAULT_INST or o.inst_id = i_inst_id)
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
           and decode(o.status, 'EVST0001', o.procedure_name, null) = l_subscriber_name
           and o.eff_date      <= l_sysdate
           and (i_inst_id       = ost_api_const_pkg.DEFAULT_INST or o.inst_id = i_inst_id)
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
        ;

    cursor main_xml_cur is
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
                  , xmlelement("application_flow_id", 1)
                  , xmlelement("application_status",  app_api_const_pkg.APPL_STATUS_PROC_READY)
                  , xmlelement("institution_id",      i_inst_id)
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
                      , (select xmlagg(
                                    xmlelement("company", xmlattributes(cc.id as "id")
                                      , xmlelement("command", app_api_const_pkg.COMMAND_CREATE_OR_UPDATE)
                                      , xmlelement("company_name"
                                          , xmlelement("company_short_name", cc.label)
                                          , xmlforest(cc.description as "company_full_name")
                                        )
                                    )
                                )
                           from com_ui_company_vw cc
                          where cc.id         = m.object_id  
                            and m.entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY
                            and cc.lang       = com_api_const_pkg.DEFAULT_LANGUAGE
                       group by cc.id
                        )     -- end of company
                      , xmlelement("contract", xmlattributes(m.contract_id as "id")
                          , xmlelement("command", app_api_const_pkg.COMMAND_CREATE_OR_UPDATE)
                          , xmlelement("contract_number", m.contract_number)
                          , xmlagg(xmlelement("merchant", xmlattributes(m.merchant_id as "id")
                              , xmlelement("command"        , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE)
                              , xmlelement("merchant_number", m.merchant_number)
                              , xmlelement("merchant_name"  , m.merchant_name)
                              , xmlelement("merchant_label" , get_text(
                                                                  i_table_name  => 'acq_merchant'
                                                                , i_column_name => 'label'
                                                                , i_object_id   =>  m.merchant_id
                                                                , i_lang        => com_api_const_pkg.DEFAULT_LANGUAGE
                                                                ))
                              , xmlelement("merchant_type"  , m.merchant_type)
                              , xmlelement("mcc"            , m.mcc)
                              , xmlelement("merchant_status", m.merchant_status)
                              , case when l_show_merch_card = com_api_const_pkg.TRUE then
                                     (select xmlagg(
                                                 xmlelement("merchant_card"
                                                   , xmlelement("card_product_id", min(p.product_id))
                                                   , xmlelement("card_type",       min(c.card_type_id))
                                                   , xmlelement("card_number",     iss_api_token_pkg.decode_card_number(i_card_number => min(n.card_number)))
                                                 )
                                             )
                                        from acc_account_object a
                                           , acc_account_object o
                                           , iss_card           c
                                           , iss_card_number    n
                                           , prd_contract       p
                                       where a.object_id   = m.merchant_id
                                         and a.split_hash  = m.split_hash
                                         and a.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                         and a.account_id  = o.account_id
                                         and o.split_hash  = m.split_hash
                                         and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                                         and o.object_id   = c.id
                                         and c.id          = n.card_id
                                         and c.contract_id = p.id
                                    group by n.card_number
                                    )
                                end
                              , case when l_show_risk_indicator = com_api_const_pkg.TRUE then 
                                     xmlelement("risk_indicator" , m.risk_indicator)
                                end
                              , (select xmlagg(xmlelement("creation_date", max(b.start_date)))
                                   from prd_service s
                                      , prd_service_object b
                                  where b.service_id      = s.id
                                    and b.object_id       = m.merchant_id
                                    and b.split_hash      = m.split_hash
                                    and b.status          = prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE
                                    and s.service_type_id = acq_api_const_pkg.MERCHANT_MAINT_SRV_TYPE_ID
                                    and l_eff_date between nvl(b.start_date, l_eff_date)
                                                       and nvl(b.end_date, trunc(l_eff_date) + 1)
                                  group by m.merchant_id
                                )  -- end of creation_date
                              , (select xmlagg(
                                            xmlelement("contact", xmlattributes(c.id as "id")
                                              , xmlelement("command",        app_api_const_pkg.COMMAND_CREATE_OR_UPDATE)
                                              , xmlelement("contact_type",   min(o.contact_type))
                                              , xmlforest(
                                                    min(c.job_title)         as "job_title"
                                                  , min(c.preferred_lang)    as "preferred_lang"
                                                )
                                              , (select xmlagg(
                                                            xmlelement("person", xmlattributes(p.id as "id")
                                                              , xmlelement("command", app_api_const_pkg.COMMAND_CREATE_OR_UPDATE)
                                                              , xmlelement("person_title",    p.title)
                                                              , xmlelement("person_name", xmlattributes(p.lang as "language")
                                                                  , xmlelement("surname",     p.surname)
                                                                  , xmlelement("first_name",  p.first_name)
                                                                  , xmlelement("second_name", p.second_name)
                                                                )
                                                              , xmlelement("suffix",         p.suffix)
                                                              , xmlelement("birthday",       to_char(p.birthday
                                                                                            , com_api_const_pkg.XML_DATE_FORMAT))
                                                              , xmlelement("place_of_birth", p.place_of_birth)
                                                              , xmlelement("gender",         p.gender)
                                                            )
                                                        )
                                                from  COM_PERSON p where p.id = c.person_id
                                                group by p.id
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
                                      , c.person_id
                                      , c.id
                                ) -- end of contact
                              , (select xmlagg(
                                            xmlelement("address", xmlattributes(a.id as "id")
                                              , xmlelement("command",      app_api_const_pkg.COMMAND_CREATE_OR_UPDATE)
                                              , xmlelement("address_type", a.address_type)
                                              , xmlelement("country",      a.country)
                                              , xmlelement("address_name"
                                                  , xmlelement("region", a.region)
                                                  , xmlelement("city",   a.city)
                                                  , xmlelement("street", a.street)
                                                )
                                              , xmlelement("house",        a.house)
                                              , xmlelement("apartment",    a.apartment)
                                              , xmlelement("postal_code",  a.postal_code)
                                              , xmlelement("place_code",   a.place_code)
                                              , xmlelement("region_code",  a.region_code)
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
                                           and decode(o.status, 'EVST0001', o.procedure_name, null) = l_subscriber_name
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
                              , (-- merchant flexible fileds
                                 select xmlagg(
                                            xmlelement(
                                                evalname(lower(ff.name))
                                              , case ff.data_type
                                                    when com_api_const_pkg.DATA_TYPE_NUMBER then
                                                        to_char(
                                                            to_number(
                                                                fd.field_value
                                                              , nvl(ff.data_format, com_api_const_pkg.NUMBER_FORMAT)
                                                            )
                                                          , com_api_const_pkg.XML_NUMBER_FORMAT
                                                        )
                                                    when com_api_const_pkg.DATA_TYPE_DATE   then
                                                        to_char(
                                                            to_date(
                                                                fd.field_value
                                                              , nvl(ff.data_format, com_api_const_pkg.DATE_FORMAT)
                                                            )
                                                          , com_api_const_pkg.XML_DATE_FORMAT
                                                        )
                                                    else
                                                        fd.field_value
                                                end
                                            )
                                        )
                                   from com_flexible_field ff
                                      , com_flexible_data  fd
                                  where ff.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                    and fd.field_id    = ff.id
                                    and fd.object_id   = m.merchant_id
                                ) -- merchant flexible fileds
                            )) --xmlagg(xmlelement("merchant"
                          , case when l_unload_limits = com_api_const_pkg.TRUE then (
                                select xmlelement("service"
                                         , xmlelement("service_object", xmlattributes(ao.object_id as "id")
                                             , xmlagg(xmlelement("attribute_limit"
                                                 , xmlelement("limit_type",        l.limit_type)
                                                 , xmlelement("limit_sum_value",   nvl(l.sum_limit, 0))
                                                 , xmlelement("limit_count_value", nvl(l.count_limit, 0))
                                                 , xmlelement("sum_current",       nvl(fcl_api_limit_pkg.get_limit_sum_curr(
                                                                                           i_limit_type  => l.limit_type
                                                                                         , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                                                         , i_object_id   => ao.account_id
                                                                                         , i_limit_id    => l.id
                                                                                       )
                                                                                     , 0))
                                                 , xmlelement("currency",          l.currency)
                                                 , xmlelement("length_type",       c.length_type)
                                                 , xmlelement("cycle_length",      c.cycle_length)
                                               ))
                                           )
                                       )
                                  from acc_account_object ao
                                     , (
                                        select distinct
                                               a.object_type limit_type
                                          from prd_attribute a
                                             , prd_service_type t
                                         where t.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                           and a.service_type_id = t.id
                                           and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                                       ) x
                                     , fcl_limit l
                                     , fcl_cycle c
                                 where ao.object_id   = m.merchant_id
                                   and ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                   and l.id           = prd_api_product_pkg.get_limit_id(
                                                            i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                          , i_object_id   => ao.account_id
                                                          , i_limit_type  => x.limit_type
                                                          , i_split_hash  => ao.split_hash
                                                          , i_mask_error  => com_api_const_pkg.TRUE
                                                        )
                                   and c.id(+)       = l.cycle_id
                              group by ao.object_id
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
                        ) -- xmlelement("contract"...
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
                 , s.object_id
                 , s.entity_type
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
      , m.object_id
      , m.entity_type
    ;

    procedure save_file is
        l_cnt   pls_integer;
    begin
        rul_api_param_pkg.set_param (
            i_name       => 'INST_ID'
            , i_value    => i_inst_id
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
        -- grouping id when events more that one for some merchants
        if l_full_export = com_api_type_pkg.FALSE then

            select count(1)
              into l_cnt
              from (
                select column_value
                  from table(cast(l_merchant_id_tab as num_tab_tpt))
                 group by column_value
              );
        end if;

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
    trc_log_pkg.debug(
        i_text => DEFAULT_PROCEDURE_NAME || ' - Start'
    );

    prc_api_stat_pkg.log_start;

    -- switches
    if i_ver = '1.4' then
        l_show_merch_card := com_api_type_pkg.TRUE;
    else
        l_show_merch_card := com_api_type_pkg.FALSE;
    end if;

    if to_number(nvl(i_ver, '1.2'), '9999.999') >= 1.3 then
        l_show_risk_indicator := com_api_type_pkg.TRUE;
    else
        l_show_risk_indicator := com_api_type_pkg.FALSE;
    end if;

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
    l_eff_date        := com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id);

    trc_log_pkg.debug(
        i_text       =>'container_id=#1, inst=#2, agent=#3, full_export=#4, unload_limits=#5, thread_number=#6'
      , i_env_param1 => l_container_id
      , i_env_param2 => i_inst_id
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

    savepoint sp_merchant_export;

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

        select count(1)
          into l_estimated_count
          from acq_merchant m
             , prd_contract c
             , prd_customer s
         where m.split_hash in (select split_hash from com_api_split_map_vw)
           and (i_inst_id    = ost_api_const_pkg.DEFAULT_INST or m.inst_id = i_inst_id)
           and c.id          = m.contract_id
           and s.id          = c.customer_id
           and (c.agent_id   = i_agent_id or i_agent_id is null)
        ;

        trc_log_pkg.debug(
            i_text => 'Estimate count = [' || l_estimated_count || ']'
        );

        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_estimated_count
        );

        open all_merchant_cur;

        loop
            fetch all_merchant_cur bulk collect into
                  l_merchant_id_tab
            limit l_bulk_limit;

            -- generate xml
            if l_merchant_id_tab.count > 0 then
                open  main_xml_cur;
                fetch main_xml_cur into l_file;
                close main_xml_cur;

                save_file;
            end if;

            exit when all_merchant_cur%notfound;
        end loop;

        close all_merchant_cur;

    else
        select count(distinct merchant_id)
          into l_estimated_count
          from (
              select o.id
                   , m.id as merchant_id
                from evt_event_object o
                   , acq_merchant m
                   , prd_contract c
                   , prd_customer s
               where decode(o.status, 'EVST0001', o.procedure_name, null) = l_subscriber_name
                 and m.split_hash in (select split_hash from com_api_split_map_vw)
                 and o.eff_date      <= l_sysdate
                 and (i_inst_id       = ost_api_const_pkg.DEFAULT_INST or o.inst_id = i_inst_id)
                 and o.entity_type    = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                 and o.object_id      = m.id
                 and m.inst_id        = o.inst_id
                 and c.id             = m.contract_id
                 and s.id             = c.customer_id
                 and (c.agent_id      = i_agent_id or i_agent_id is null)
           union all
              select o.id
                   , m.id as merchant_id
                from evt_event_object o
                   , acc_account_object ao
                   , acq_merchant m
                   , acc_account a
               where o.split_hash in (select split_hash from com_api_split_map_vw)
                 and decode(o.status, 'EVST0001', o.procedure_name, null) = l_subscriber_name
                 and o.eff_date      <= l_sysdate
                 and (i_inst_id       = ost_api_const_pkg.DEFAULT_INST or o.inst_id = i_inst_id)
                 and o.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                 and o.object_id      = ao.account_id
                 and ao.entity_type   = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                 and ao.object_id     = m.id
                 and ao.split_hash    = o.split_hash
                 and m.inst_id        = o.inst_id
                 and a.split_hash     = o.split_hash
                 and a.id             = ao.account_id
                 and (a.agent_id      = i_agent_id or i_agent_id is null)
        );

        trc_log_pkg.debug(
            i_text => 'Estimate count = [' || l_estimated_count || ']'
        );

        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_estimated_count
        );

        open evt_objects_merchant_cur;

        loop
            fetch evt_objects_merchant_cur bulk collect into
                  l_event_tab
                , l_merchant_id_tab
            limit l_bulk_limit;

            -- generate xml
            if l_merchant_id_tab.count > 0 then
                open  main_xml_cur;
                fetch main_xml_cur into l_file;
                close main_xml_cur;

                save_file;

                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab    => l_event_tab
                );
            end if;

            exit when evt_objects_merchant_cur%notfound;
        end loop;

        close evt_objects_merchant_cur;
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_estimated_count
      , i_excepted_total    => 0
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(DEFAULT_PROCEDURE_NAME || ' - End');

exception
    when others then
        rollback to sp_merchant_export;

        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

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
        
end export_merchant_data_12;

procedure export_merchant_data_13(
    i_inst_id             in     com_api_type_pkg.t_inst_id      
  , i_agent_id            in     com_api_type_pkg.t_agent_id     default null
  , i_full_export         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits       in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_accounts     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count               in     com_api_type_pkg.t_medium_id    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name         default null
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
) is

    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := $$PLSQL_UNIT || '.EXPORT_MERCHANT_DATA_13';
    
begin
    
    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': start'
    );
    
    export_merchant_data_12(
        i_inst_id         =>     i_inst_id
      , i_agent_id        =>     i_agent_id
      , i_full_export     =>     i_full_export
      , i_unload_limits   =>     i_unload_limits
      , i_unload_accounts =>     i_unload_accounts
      , i_include_service =>     i_include_service
      , i_count           =>     i_count
      , i_subscriber_name =>     i_subscriber_name
      , i_lang            =>     i_lang
      , i_ver             =>     '1.3'
    );
    
    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': finish success'
    );
    
end export_merchant_data_13;

procedure export_merchant_data_14(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_agent_id            in     com_api_type_pkg.t_agent_id     default null
  , i_full_export         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits       in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_accounts     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count               in     com_api_type_pkg.t_medium_id    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name         default null
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name := $$PLSQL_UNIT || '.export_merchant_data_14';
    LOG_PREFIX              constant com_api_type_pkg.t_name := lower(DEFAULT_PROCEDURE_NAME) || ': ';
begin
    trc_log_pkg.debug(
        i_text          => LOG_PREFIX || 'start'
    );

    -- use 1.2 as engine, so pass i_ver here
    export_merchant_data_12(
        i_inst_id         =>     i_inst_id
      , i_agent_id        =>     i_agent_id
      , i_full_export     =>     i_full_export
      , i_unload_limits   =>     i_unload_limits
      , i_unload_accounts =>     i_unload_accounts
      , i_include_service =>     i_include_service
      , i_count           =>     i_count
      , i_subscriber_name =>     i_subscriber_name
      , i_lang            =>     i_lang
      , i_ver             =>     '1.4'
    );

    trc_log_pkg.debug(
        i_text          => LOG_PREFIX || 'finish success'
    );
exception
    when others then
        trc_log_pkg.debug(
            i_text          => LOG_PREFIX || sqlerrm
        );
        raise;
end export_merchant_data_14;

procedure export_merchant_data_15(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_agent_id            in     com_api_type_pkg.t_agent_id     default null
  , i_full_export         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits       in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_accounts     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count               in     com_api_type_pkg.t_medium_id    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name         default null
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name := $$PLSQL_UNIT || '.export_merchant_data_15';
    LOG_PREFIX              constant com_api_type_pkg.t_name := lower(DEFAULT_PROCEDURE_NAME) || ': ';
begin
    trc_log_pkg.debug(
        i_text          => LOG_PREFIX || 'start'
    );

    -- use 1.2 as engine, so pass i_ver here
    export_merchant_data_12(
        i_inst_id         =>     i_inst_id
      , i_agent_id        =>     i_agent_id
      , i_full_export     =>     i_full_export
      , i_unload_limits   =>     i_unload_limits
      , i_unload_accounts =>     i_unload_accounts
      , i_include_service =>     i_include_service
      , i_count           =>     i_count
      , i_subscriber_name =>     i_subscriber_name
      , i_lang            =>     i_lang
      , i_ver             =>     '1.5'
    );

    trc_log_pkg.debug(
        i_text          => LOG_PREFIX || 'finish success'
    );
exception
    when others then
        trc_log_pkg.debug(
            i_text          => LOG_PREFIX || sqlerrm
        );
        raise;
end export_merchant_data_15;

procedure export_terminal_data_10(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_agent_id            in     com_api_type_pkg.t_agent_id     default null
  , i_full_export         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits       in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count               in     com_api_type_pkg.t_medium_id    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name         default null
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
) is
    DEFAULT_PROCEDURE_NAME constant com_api_type_pkg.t_name  := $$PLSQL_UNIT || '.EXPORT_TERMINAL_DATA_10';
    
    l_session_file_id      com_api_type_pkg.t_long_id;
    l_file                 clob;
    l_file_type            com_api_type_pkg.t_dict_value;
    l_subscriber_name      com_api_type_pkg.t_name           := upper(nvl(i_subscriber_name, DEFAULT_PROCEDURE_NAME));
    l_container_id         com_api_type_pkg.t_long_id        :=  prc_api_session_pkg.get_container_id;
    l_unload_limits        com_api_type_pkg.t_boolean;
    l_full_export          com_api_type_pkg.t_boolean;
    l_estimated_count      com_api_type_pkg.t_long_id := 0;
    l_lang                 com_api_type_pkg.t_dict_value;
    l_params               com_api_type_pkg.t_param_tab;

    l_event_tab            com_api_type_pkg.t_number_tab;
    l_terminal_id_tab      num_tab_tpt;
    l_bulk_limit           com_api_type_pkg.t_count := 2000;
    l_sysdate              date;
    l_include_service      com_api_type_pkg.t_boolean;
    l_service_id_tab       prd_service_tpt;
    l_eff_date             date;

    cursor all_terminal_cur is
        select t.id
          from acq_terminal t
             , prd_contract c
         where t.split_hash in (select split_hash from com_api_split_map_vw)
           and (i_inst_id       = ost_api_const_pkg.DEFAULT_INST or t.inst_id = i_inst_id)
           and c.id             = t.contract_id
           and (c.agent_id      = i_agent_id or i_agent_id is null)
           and t.is_template    = com_api_type_pkg.FALSE
        ;

    cursor evt_objects_terminal_cur is
        select o.id
             , t.id
          from evt_event_object o
             , acq_terminal t
             , prd_contract c
         where o.split_hash in (select split_hash from com_api_split_map_vw)
           and decode(o.status, 'EVST0001', o.procedure_name, null) = l_subscriber_name
           and o.eff_date      <= l_sysdate
           and (i_inst_id       = ost_api_const_pkg.DEFAULT_INST or o.inst_id = i_inst_id)
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
           and decode(o.status, 'EVST0001', o.procedure_name, null) = l_subscriber_name
           and o.eff_date      <= l_sysdate
           and (i_inst_id       = ost_api_const_pkg.DEFAULT_INST or o.inst_id = i_inst_id)
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
        ;

    cursor main_xml_cur is
        select
            xmlelement("applications", xmlattributes('http://sv.bpc.in/SVAP' as "xmlns")
              , xmlagg(xmlelement("application"
                  , xmlelement("application_date",    to_char(get_sysdate, com_api_const_pkg.XML_DATE_FORMAT))
                  , xmlelement("application_type",    app_api_const_pkg.APPL_TYPE_ACQUIRING)
                  , xmlelement("application_flow_id", 2003)
                  , xmlelement("application_status",  app_api_const_pkg.APPL_STATUS_PROC_READY)
                  , xmlelement("institution_id",      i_inst_id)
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
                                                xmlelement("address", xmlattributes(a.id as "id")
                                                  , xmlelement("command", app_api_const_pkg.COMMAND_CREATE_OR_UPDATE)
--                                                                   , xmlelement("address_id",      a.id)
                                                  , xmlelement("address_type",    o.address_type)
                                                  , xmlelement("country",         a.country)
                                                  , xmlelement("address_name"
                                                      , xmlelement("region",      a.region)
                                                      , xmlelement("city",        a.city)
                                                      , xmlelement("street",      a.street)
                                                    )
                                                  , xmlelement("house",           a.house)
                                                  , xmlelement("apartment",       a.apartment)
                                                  , xmlelement("postal_code",     a.postal_code)
                                                  , xmlelement("place_code",      a.place_code)
                                                  , xmlelement("region_code",     a.region_code)
                                                )
                                            )
                                       from com_address_object o
                                          , com_address a
                                      where a.id = o.address_id
                                        and (o.object_id, o.entity_type) in ((t.terminal_id, acq_api_const_pkg.ENTITY_TYPE_TERMINAL)
                                                                           , (t.merchant_id, acq_api_const_pkg.ENTITY_TYPE_MERCHANT))
                                        and (select min(ca.lang) keep (
                                                        dense_rank first
                                                        order by decode(ca.lang, l_lang, 1, 'LANGENG', 2, 3)
                                                    )
                                               from com_address ca
                                              where ca.id = a.id
                                            ) = a.lang
                                        and not exists (select 1
                                                          from com_address_object ao
                                                         where ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                                           and ao.object_id   = t.terminal_id
                                                           and o.entity_type  = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                            )
                                    ) -- xmlagg(xmlelement("address"...
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
                                                              select attr_value
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
                                                                      from prd_attribute_value v
                                                                         , prd_attribute a
                                                                     where v.entity_type  = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
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
                                                                         , r.id  terminal_id
                                                                         , r.split_hash
                                                                         , a.attr_name
                                                                         , v.service_id
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
                                                                       and a.data_type       = com_api_const_pkg.DATA_TYPE_CHAR
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
                                                              select attr_value
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
                                                                      from prd_attribute_value v
                                                                         , prd_attribute a
                                                                     where v.entity_type  = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
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
                                                                         , r.id  terminal_id
                                                                         , r.split_hash
                                                                         , a.attr_name
                                                                         , v.service_id
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
                                                                       and a.data_type       = com_api_const_pkg.DATA_TYPE_CHAR
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
                                               and decode(o.status, 'EVST0001', o.procedure_name, null) = l_subscriber_name
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
                                  , (-- terminal flexible fileds
                                     select xmlagg(
                                                xmlelement(
                                                    evalname(lower(ff.name))
                                                  , case ff.data_type
                                                        when com_api_const_pkg.DATA_TYPE_NUMBER then
                                                            to_char(
                                                                to_number(
                                                                    fd.field_value
                                                                  , nvl(ff.data_format, com_api_const_pkg.NUMBER_FORMAT)
                                                                )
                                                              , com_api_const_pkg.XML_NUMBER_FORMAT
                                                            )
                                                        when com_api_const_pkg.DATA_TYPE_DATE   then
                                                            to_char(
                                                                to_date(
                                                                    fd.field_value
                                                                  , nvl(ff.data_format, com_api_const_pkg.DATE_FORMAT)
                                                                )
                                                              , com_api_const_pkg.XML_DATE_FORMAT
                                                            )
                                                        else
                                                            fd.field_value
                                                    end
                                                )
                                            )
                                       from com_flexible_field ff
                                          , com_flexible_data  fd
                                      where ff.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                        and fd.field_id    = ff.id
                                        and fd.object_id   = t.terminal_id
                                    ) -- merchant flexible fileds
                                  , case when t.mcc_template_id is not null then (
                                        select xmlagg(xmlelement("acquiring_redefinition"
                                                 , xmlelement("purpose_number",  p.purpose_number)
                                                 , xmlelement("oper_type",       s.oper_type)
                                                 , xmlelement("oper_reason",     s.oper_reason)
                                                 , xmlelement("mcc",             s.mcc)
                                                 , xmlelement(
                                                       "terminal_number"
                                                     , case when length(r.terminal_number) >= 8 
                                                           then substr(r.terminal_number, -8)
                                                           else r.terminal_number
                                                       end
                                                   )
                                               ))
                                          from acq_mcc_selection s
                                             , pmo_purpose p
                                             , acq_terminal r
                                         where s.mcc_template_id = t.mcc_template_id
                                           and s.purpose_id      = p.id(+)
                                           and s.terminal_id     = r.id
                                    )
                                    end
                                )) -- xmlagg(xmlelement("terminal"...
                            ) -- xmlelement("merchant"...
                          , case when l_unload_limits = com_api_const_pkg.TRUE then (
                                select xmlelement("service"
                                         , xmlelement("service_object", xmlattributes(ao.object_id as "id")
                                             , xmlagg(xmlelement("attribute_limit"
                                                 , xmlelement("limit_type",        l.limit_type)
                                                 , xmlelement("limit_sum_value",   nvl(l.sum_limit, 0))
                                                 , xmlelement("limit_count_value", nvl(l.count_limit, 0))
                                                 , xmlelement("sum_current",       nvl(fcl_api_limit_pkg.get_limit_sum_curr(
                                                                                           i_limit_type  => l.limit_type
                                                                                         , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                                                         , i_object_id   => ao.account_id
                                                                                         , i_limit_id    => l.id
                                                                                       )
                                                                                     , 0))
                                                 , xmlelement("currency",          l.currency)
                                                 , xmlelement("length_type",       c.length_type)
                                                 , xmlelement("cycle_length",      c.cycle_length)
                                               ))
                                           )
                                       )
                                  from acc_account_object ao
                                     , (select distinct
                                               a.object_type limit_type
                                          from prd_attribute a
                                             , prd_service_type t
                                         where t.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                           and a.service_type_id = t.id
                                           and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                                       ) x
                                     , fcl_limit l
                                     , fcl_cycle c
                                 where ao.object_id   = t.terminal_id
                                   and ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                   and l.id           = prd_api_product_pkg.get_limit_id(
                                                            i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                          , i_object_id   => ao.account_id
                                                          , i_limit_type  => x.limit_type
                                                          , i_split_hash  => ao.split_hash
                                                          , i_mask_error  => com_api_const_pkg.TRUE
                                                        )
                                   and c.id(+)        = l.cycle_id
                              group by ao.object_id
                            )
                            end
                          , (select xmlagg(xmlelement("account"
                                      , xmlelement("command",        app_api_const_pkg.COMMAND_CREATE_OR_UPDATE)
                                      , xmlelement("account_number", a.account_number)
                                      , xmlelement("currency",       a.currency)
                                      , xmlelement("account_status", a.status)
                                    ))
                               from acc_account_object ao
                                  , acc_account a
                              where ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                and ao.object_id   = t.terminal_id
                                and ao.account_id  = a.id
                            )
                        ) -- xmlelement("contract"...
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
                   , case when length(t.terminal_number) >= 8 
                         then substr(t.terminal_number, -8)
                         else t.terminal_number
                     end as terminal_number
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

    procedure save_file is
        l_cnt   pls_integer;
    begin
        rul_api_param_pkg.set_param (
            i_name       => 'INST_ID'
            , i_value    => i_inst_id
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
        -- grouping id when events more that one for some merchants
        if l_full_export = com_api_type_pkg.FALSE then
            select count(1)
              into l_cnt
              from (
                  select column_value
                    from table(cast(l_terminal_id_tab as num_tab_tpt))
                   group by column_value
              );
        end if;

        prc_api_file_pkg.close_file(
            i_sess_file_id   => l_session_file_id
          , i_status         => prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count   => l_cnt
        );

        trc_log_pkg.debug('file saved, cnt='||l_cnt||', length='||length(l_file));

        prc_api_stat_pkg.log_current(
            i_current_count  => l_cnt
          , i_excepted_count => 0
        );
    end save_file;

begin
    trc_log_pkg.debug(DEFAULT_PROCEDURE_NAME || ' - Start');

    prc_api_stat_pkg.log_start;

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
    l_eff_date        := com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id);

    trc_log_pkg.debug(
        i_text       =>'container_id=#1, inst=#2, agent=#3, full_export=#4, unload_limits=#5, thread_number=#6'
      , i_env_param1 => l_container_id
      , i_env_param2 => i_inst_id
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

    savepoint sp_terminal_export;

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

        select count(1)
          into l_estimated_count
          from acq_terminal t
             , prd_contract c
         where t.split_hash in (select split_hash from com_api_split_map_vw)
           and (i_inst_id    = ost_api_const_pkg.DEFAULT_INST or t.inst_id = i_inst_id)
           and c.id          = t.contract_id
           and (c.agent_id   = i_agent_id or i_agent_id is null)
           and t.is_template = com_api_type_pkg.FALSE
        ;

        trc_log_pkg.debug(
            i_text => 'Estimate count = [' || l_estimated_count || ']'
        );

        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_estimated_count
        );

        open all_terminal_cur;

        loop
            fetch all_terminal_cur bulk collect into
                  l_terminal_id_tab
            limit l_bulk_limit;

            -- generate xml
            if l_terminal_id_tab.count > 0 then
                open  main_xml_cur;
                fetch main_xml_cur into l_file;
                close main_xml_cur;

                save_file;
            end if;

            exit when all_terminal_cur%notfound;
        end loop;

        close all_terminal_cur;

    else
        select count(distinct terminal_id)
          into l_estimated_count
          from (
              select o.id
                   , t.id as terminal_id
                from evt_event_object o
                   , acq_terminal t
                   , prd_contract c
               where t.split_hash in (select split_hash from com_api_split_map_vw)
                 and decode(o.status, 'EVST0001', o.procedure_name, null) = l_subscriber_name
                 and o.eff_date      <= l_sysdate
                 and (i_inst_id       = ost_api_const_pkg.DEFAULT_INST or o.inst_id = i_inst_id)
                 and o.entity_type    = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                 and o.object_id      = t.id
                 and o.split_hash     = t.split_hash
                 and t.inst_id        = o.inst_id
                 and c.id             = t.contract_id
                 and (c.agent_id      = i_agent_id or i_agent_id is null)
                 and t.is_template    = com_api_type_pkg.FALSE
           union all
              select o.id
                   , t.id as terminal_id
                from evt_event_object o
                   , acc_account_object ao
                   , acq_terminal t
                   , prd_contract c
               where o.split_hash in (select split_hash from com_api_split_map_vw)
                 and decode(o.status, 'EVST0001', o.procedure_name, null) = l_subscriber_name
                 and o.eff_date      <= l_sysdate
                 and (i_inst_id       = ost_api_const_pkg.DEFAULT_INST or o.inst_id = i_inst_id)
                 and o.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                 and o.object_id      = ao.account_id
                 and ao.entity_type   = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                 and ao.object_id     = t.id
                 and ao.split_hash    = o.split_hash
                 and t.split_hash     = o.split_hash
                 and t.inst_id        = o.inst_id
                 and c.id             = t.contract_id
                 and (c.agent_id      = i_agent_id or i_agent_id is null)
                 and t.is_template    = com_api_type_pkg.FALSE
          );

        trc_log_pkg.debug(
            i_text => 'Estimate count = [' || l_estimated_count || ']'
        );

        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_estimated_count
        );

        open evt_objects_terminal_cur;
        loop
            fetch evt_objects_terminal_cur bulk collect into
                  l_event_tab
                , l_terminal_id_tab
            limit l_bulk_limit;

            trc_log_pkg.debug(
                i_text => 'l_terminal_id_tab.count = [' || l_terminal_id_tab.count || ']'
            );
            --generate xml
            if l_terminal_id_tab.count > 0 then
                open  main_xml_cur;
                fetch main_xml_cur into l_file;
                close main_xml_cur;

                save_file;

                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab    => l_event_tab
                );
            end if;

            exit when evt_objects_terminal_cur%notfound;
        end loop;

        close evt_objects_terminal_cur;
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_estimated_count
      , i_excepted_total    => 0
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(DEFAULT_PROCEDURE_NAME || ' - End');

exception
    when others then
        rollback to sp_terminal_export;

        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

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
        
end export_terminal_data_10;

procedure export_terminal_data_11(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_agent_id            in     com_api_type_pkg.t_agent_id     default null
  , i_full_export         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits       in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count               in     com_api_type_pkg.t_medium_id    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name         default null
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
) is

    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := $$PLSQL_UNIT || '.EXPORT_TERMINAL_DATA_11';
    
begin
    
    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': start'
    );
    
    export_terminal_data_10(
        i_inst_id         =>     i_inst_id
      , i_agent_id        =>     i_agent_id
      , i_full_export     =>     i_full_export
      , i_unload_limits   =>     i_unload_limits
      , i_include_service =>     i_include_service
      , i_count           =>     i_count
      , i_subscriber_name =>     i_subscriber_name
      , i_lang            =>     i_lang
    );
    
    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': finish success'
    );
    
end ;

procedure export_terminal_data_12(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_agent_id            in     com_api_type_pkg.t_agent_id     default null
  , i_full_export         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits       in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count               in     com_api_type_pkg.t_medium_id    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name         default null
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
) is

    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := $$PLSQL_UNIT || '.EXPORT_TERMINAL_DATA_12';

begin

    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': start'
    );

    export_terminal_data_11(
        i_inst_id         =>     i_inst_id
      , i_agent_id        =>     i_agent_id
      , i_full_export     =>     i_full_export
      , i_unload_limits   =>     i_unload_limits
      , i_include_service =>     i_include_service
      , i_count           =>     i_count
      , i_subscriber_name =>     i_subscriber_name
      , i_lang            =>     i_lang
    );

    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': finish success'
    );

end export_terminal_data_12;

procedure export_terminal_data_13(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_agent_id            in     com_api_type_pkg.t_agent_id     default null
  , i_full_export         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits       in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count               in     com_api_type_pkg.t_medium_id    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name         default null
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
) is
    DEFAULT_PROCEDURE_NAME constant com_api_type_pkg.t_name  := $$PLSQL_UNIT || '.EXPORT_TERMINAL_DATA_13';
    
    l_session_file_id      com_api_type_pkg.t_long_id;
    l_file                 clob;
    l_file_type            com_api_type_pkg.t_dict_value;
    l_subscriber_name      com_api_type_pkg.t_name           := upper(nvl(i_subscriber_name, DEFAULT_PROCEDURE_NAME));
    l_container_id         com_api_type_pkg.t_long_id        :=  prc_api_session_pkg.get_container_id;
    l_unload_limits        com_api_type_pkg.t_boolean;
    l_full_export          com_api_type_pkg.t_boolean;
    l_estimated_count      com_api_type_pkg.t_long_id := 0;
    l_lang                 com_api_type_pkg.t_dict_value;
    l_params               com_api_type_pkg.t_param_tab;

    l_event_tab            com_api_type_pkg.t_number_tab;
    l_terminal_id_tab      num_tab_tpt;
    l_bulk_limit           com_api_type_pkg.t_count := 2000;
    l_sysdate              date;
    l_include_service      com_api_type_pkg.t_boolean;
    l_service_id_tab       prd_service_tpt;
    l_eff_date             date;

    cursor all_terminal_cur is
        select t.id
          from acq_terminal t
             , prd_contract c
         where t.split_hash in (select split_hash from com_api_split_map_vw)
           and (i_inst_id       = ost_api_const_pkg.DEFAULT_INST or t.inst_id = i_inst_id)
           and c.id             = t.contract_id
           and (c.agent_id      = i_agent_id or i_agent_id is null)
           and t.is_template    = com_api_type_pkg.FALSE
        ;

    cursor evt_objects_terminal_cur is
        select o.id
             , t.id
          from evt_event_object o
             , acq_terminal t
             , prd_contract c
         where o.split_hash in (select split_hash from com_api_split_map_vw)
           and decode(o.status, 'EVST0001', o.procedure_name, null) = l_subscriber_name
           and o.eff_date      <= l_sysdate
           and (i_inst_id       = ost_api_const_pkg.DEFAULT_INST or o.inst_id = i_inst_id)
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
           and decode(o.status, 'EVST0001', o.procedure_name, null) = l_subscriber_name
           and o.eff_date      <= l_sysdate
           and (i_inst_id       = ost_api_const_pkg.DEFAULT_INST or o.inst_id = i_inst_id)
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
        ;

    cursor main_xml_cur is
        select
            xmlelement("applications", xmlattributes('http://sv.bpc.in/SVAP' as "xmlns")
              , xmlagg(xmlelement("application"
                  , xmlelement("application_date",    to_char(get_sysdate, com_api_const_pkg.XML_DATE_FORMAT))
                  , xmlelement("application_type",    app_api_const_pkg.APPL_TYPE_ACQUIRING)
                  , xmlelement("application_flow_id", 2003)
                  , xmlelement("application_status",  app_api_const_pkg.APPL_STATUS_PROC_READY)
                  , xmlelement("institution_id",      i_inst_id)
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
                                    )
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
                                                xmlelement("address", xmlattributes(a.id as "id")
                                                  , xmlelement("command", app_api_const_pkg.COMMAND_CREATE_OR_UPDATE)
--                                                                   , xmlelement("address_id",      a.id)
                                                  , xmlelement("address_type",    o.address_type)
                                                  , xmlelement("country",         a.country)
                                                  , xmlelement("address_name"
                                                      , xmlelement("region",      a.region)
                                                      , xmlelement("city",        a.city)
                                                      , xmlelement("street",      a.street)
                                                    )
                                                  , xmlelement("house",           a.house)
                                                  , xmlelement("apartment",       a.apartment)
                                                  , xmlelement("postal_code",     a.postal_code)
                                                  , xmlelement("place_code",      a.place_code)
                                                  , xmlelement("region_code",     a.region_code)
                                                )
                                            )
                                       from com_address_object o
                                          , com_address a
                                      where a.id = o.address_id
                                        and (o.object_id, o.entity_type) in ((t.terminal_id, acq_api_const_pkg.ENTITY_TYPE_TERMINAL)
                                                                           , (t.merchant_id, acq_api_const_pkg.ENTITY_TYPE_MERCHANT))
                                        and (select min(ca.lang) keep (
                                                        dense_rank first
                                                        order by decode(ca.lang, l_lang, 1, 'LANGENG', 2, 3)
                                                    )
                                               from com_address ca
                                              where ca.id = a.id
                                            ) = a.lang
                                        and not exists (select 1
                                                          from com_address_object ao
                                                         where ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                                           and ao.object_id   = t.terminal_id
                                                           and o.entity_type  = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                            )
                                    ) -- xmlagg(xmlelement("address"...
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
                                                              select attr_value
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
                                                                      from prd_attribute_value v
                                                                         , prd_attribute a
                                                                     where v.entity_type  = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
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
                                                                         , r.id  terminal_id
                                                                         , r.split_hash
                                                                         , a.attr_name
                                                                         , v.service_id
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
                                                                       and a.data_type       = com_api_const_pkg.DATA_TYPE_CHAR
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
                                                              select attr_value
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
                                                                      from prd_attribute_value v
                                                                         , prd_attribute a
                                                                     where v.entity_type  = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
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
                                                                         , r.id  terminal_id
                                                                         , r.split_hash
                                                                         , a.attr_name
                                                                         , v.service_id
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
                                                                       and a.data_type       = com_api_const_pkg.DATA_TYPE_CHAR
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
                                               and decode(o.status, 'EVST0001', o.procedure_name, null) = l_subscriber_name
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
                                  , (-- terminal flexible fileds
                                     select xmlagg(
                                                xmlelement(
                                                    evalname(lower(ff.name))
                                                  , case ff.data_type
                                                        when com_api_const_pkg.DATA_TYPE_NUMBER then
                                                            to_char(
                                                                to_number(
                                                                    fd.field_value
                                                                  , nvl(ff.data_format, com_api_const_pkg.NUMBER_FORMAT)
                                                                )
                                                              , com_api_const_pkg.XML_NUMBER_FORMAT
                                                            )
                                                        when com_api_const_pkg.DATA_TYPE_DATE   then
                                                            to_char(
                                                                to_date(
                                                                    fd.field_value
                                                                  , nvl(ff.data_format, com_api_const_pkg.DATE_FORMAT)
                                                                )
                                                              , com_api_const_pkg.XML_DATE_FORMAT
                                                            )
                                                        else
                                                            fd.field_value
                                                    end
                                                )
                                            )
                                       from com_flexible_field ff
                                          , com_flexible_data  fd
                                      where ff.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                        and fd.field_id    = ff.id
                                        and fd.object_id   = t.terminal_id
                                    ) -- merchant flexible fileds
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
                                )) -- xmlagg(xmlelement("terminal"...
                            ) -- xmlelement("merchant"...
                          , case when l_unload_limits = com_api_const_pkg.TRUE then (
                                select xmlelement("service"
                                         , xmlelement("service_object", xmlattributes(ao.object_id as "id")
                                             , xmlagg(xmlelement("attribute_limit"
                                                 , xmlelement("limit_type",        l.limit_type)
                                                 , xmlelement("limit_sum_value",   nvl(l.sum_limit, 0))
                                                 , xmlelement("limit_count_value", nvl(l.count_limit, 0))
                                                 , xmlelement("sum_current",       nvl(fcl_api_limit_pkg.get_limit_sum_curr(
                                                                                           i_limit_type  => l.limit_type
                                                                                         , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                                                         , i_object_id   => ao.account_id
                                                                                         , i_limit_id    => l.id
                                                                                       )
                                                                                     , 0))
                                                 , xmlelement("currency",          l.currency)
                                                 , xmlelement("length_type",       c.length_type)
                                                 , xmlelement("cycle_length",      c.cycle_length)
                                               ))
                                           )
                                       )
                                  from acc_account_object ao
                                     , (select distinct
                                               a.object_type limit_type
                                          from prd_attribute a
                                             , prd_service_type t
                                         where t.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                           and a.service_type_id = t.id
                                           and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                                       ) x
                                     , fcl_limit l
                                     , fcl_cycle c
                                 where ao.object_id   = t.terminal_id
                                   and ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                   and l.id           = prd_api_product_pkg.get_limit_id(
                                                            i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                          , i_object_id   => ao.account_id
                                                          , i_limit_type  => x.limit_type
                                                          , i_split_hash  => ao.split_hash
                                                          , i_mask_error  => com_api_const_pkg.TRUE
                                                        )
                                   and c.id(+)        = l.cycle_id
                              group by ao.object_id
                            )
                            end
                          , (select xmlagg(xmlelement("account"
                                      , xmlelement("command",        app_api_const_pkg.COMMAND_CREATE_OR_UPDATE)
                                      , xmlelement("account_number", a.account_number)
                                      , xmlelement("currency",       a.currency)
                                      , xmlelement("account_status", a.status)
                                    ))
                               from acc_account_object ao
                                  , acc_account a
                              where ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                and ao.object_id   = t.terminal_id
                                and ao.account_id  = a.id
                            )
                        ) -- xmlelement("contract"...
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

    procedure save_file is
        l_cnt   pls_integer;
    begin
        rul_api_param_pkg.set_param (
            i_name       => 'INST_ID'
            , i_value    => i_inst_id
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
        -- grouping id when events more that one for some merchants
        if l_full_export = com_api_type_pkg.FALSE then
            select count(1)
              into l_cnt
              from (
                  select column_value
                    from table(cast(l_terminal_id_tab as num_tab_tpt))
                   group by column_value
              );
        end if;

        prc_api_file_pkg.close_file(
            i_sess_file_id   => l_session_file_id
          , i_status         => prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count   => l_cnt
        );

        trc_log_pkg.debug('file saved, cnt='||l_cnt||', length='||length(l_file));

        prc_api_stat_pkg.log_current(
            i_current_count  => l_cnt
          , i_excepted_count => 0
        );
    end save_file;

begin
    trc_log_pkg.debug(DEFAULT_PROCEDURE_NAME || ' - Start');

    prc_api_stat_pkg.log_start;

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
    l_eff_date        := com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id);

    trc_log_pkg.debug(
        i_text       =>'container_id=#1, inst=#2, agent=#3, full_export=#4, unload_limits=#5, thread_number=#6'
      , i_env_param1 => l_container_id
      , i_env_param2 => i_inst_id
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

    savepoint sp_terminal_export;

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

        select count(1)
          into l_estimated_count
          from acq_terminal t
             , prd_contract c
         where t.split_hash in (select split_hash from com_api_split_map_vw)
           and (i_inst_id    = ost_api_const_pkg.DEFAULT_INST or t.inst_id = i_inst_id)
           and c.id          = t.contract_id
           and (c.agent_id   = i_agent_id or i_agent_id is null)
           and t.is_template = com_api_type_pkg.FALSE
        ;

        trc_log_pkg.debug(
            i_text => 'Estimate count = [' || l_estimated_count || ']'
        );

        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_estimated_count
        );

        open all_terminal_cur;

        loop
            fetch all_terminal_cur bulk collect into
                  l_terminal_id_tab
            limit l_bulk_limit;

            -- generate xml
            if l_terminal_id_tab.count > 0 then
                open  main_xml_cur;
                fetch main_xml_cur into l_file;
                close main_xml_cur;

                save_file;
            end if;

            exit when all_terminal_cur%notfound;
        end loop;

        close all_terminal_cur;

    else
        select count(distinct terminal_id)
          into l_estimated_count
          from (
              select o.id
                   , t.id as terminal_id
                from evt_event_object o
                   , acq_terminal t
                   , prd_contract c
               where t.split_hash in (select split_hash from com_api_split_map_vw)
                 and decode(o.status, 'EVST0001', o.procedure_name, null) = l_subscriber_name
                 and o.eff_date      <= l_sysdate
                 and (i_inst_id       = ost_api_const_pkg.DEFAULT_INST or o.inst_id = i_inst_id)
                 and o.entity_type    = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                 and o.object_id      = t.id
                 and o.split_hash     = t.split_hash
                 and t.inst_id        = o.inst_id
                 and c.id             = t.contract_id
                 and (c.agent_id      = i_agent_id or i_agent_id is null)
                 and t.is_template    = com_api_type_pkg.FALSE
           union all
              select o.id
                   , t.id as terminal_id
                from evt_event_object o
                   , acc_account_object ao
                   , acq_terminal t
                   , prd_contract c
               where o.split_hash in (select split_hash from com_api_split_map_vw)
                 and decode(o.status, 'EVST0001', o.procedure_name, null) = l_subscriber_name
                 and o.eff_date      <= l_sysdate
                 and (i_inst_id       = ost_api_const_pkg.DEFAULT_INST or o.inst_id = i_inst_id)
                 and o.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                 and o.object_id      = ao.account_id
                 and ao.entity_type   = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                 and ao.object_id     = t.id
                 and ao.split_hash    = o.split_hash
                 and t.split_hash     = o.split_hash
                 and t.inst_id        = o.inst_id
                 and c.id             = t.contract_id
                 and (c.agent_id      = i_agent_id or i_agent_id is null)
                 and t.is_template    = com_api_type_pkg.FALSE
          );

        trc_log_pkg.debug(
            i_text => 'Estimate count = [' || l_estimated_count || ']'
        );

        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_estimated_count
        );

        open evt_objects_terminal_cur;
        loop
            fetch evt_objects_terminal_cur bulk collect into
                  l_event_tab
                , l_terminal_id_tab
            limit l_bulk_limit;

            trc_log_pkg.debug(
                i_text => 'l_terminal_id_tab.count = [' || l_terminal_id_tab.count || ']'
            );
            --generate xml
            if l_terminal_id_tab.count > 0 then
                open  main_xml_cur;
                fetch main_xml_cur into l_file;
                close main_xml_cur;

                save_file;

                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab    => l_event_tab
                );
            end if;

            exit when evt_objects_terminal_cur%notfound;
        end loop;

        close evt_objects_terminal_cur;
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_estimated_count
      , i_excepted_total    => 0
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(DEFAULT_PROCEDURE_NAME || ' - End');

exception
    when others then
        rollback to sp_terminal_export;

        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

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
        
end;

procedure export_terminal_data_14(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_agent_id            in     com_api_type_pkg.t_agent_id     default null
  , i_full_export         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits       in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count               in     com_api_type_pkg.t_medium_id    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name         default null
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
) is

    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := $$PLSQL_UNIT || '.EXPORT_TERMINAL_DATA_14';

begin

    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': start'
    );

    export_terminal_data_13(
        i_inst_id         =>     i_inst_id
      , i_agent_id        =>     i_agent_id
      , i_full_export     =>     i_full_export
      , i_unload_limits   =>     i_unload_limits
      , i_include_service =>     i_include_service
      , i_count           =>     i_count
      , i_subscriber_name =>     i_subscriber_name
      , i_lang            =>     i_lang
    );

    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': finish success'
    );

end export_terminal_data_14;

procedure export_terminal_data_15(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_agent_id            in     com_api_type_pkg.t_agent_id     default null
  , i_full_export         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_unload_limits       in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_include_service     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_count               in     com_api_type_pkg.t_medium_id    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name         default null
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
) is

    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := $$PLSQL_UNIT || '.EXPORT_TERMINAL_DATA_15';

begin

    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': start'
    );

    export_terminal_data_13(
        i_inst_id         =>     i_inst_id
      , i_agent_id        =>     i_agent_id
      , i_full_export     =>     i_full_export
      , i_unload_limits   =>     i_unload_limits
      , i_include_service =>     i_include_service
      , i_count           =>     i_count
      , i_subscriber_name =>     i_subscriber_name
      , i_lang            =>     i_lang
    );

    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': finish success'
    );

end export_terminal_data_15;

function execute_rate_query(
    i_count_query_only   in com_api_type_pkg.t_boolean
  , io_file              in out nocopy clob
  , io_rate_id_tab       in out nocopy num_tab_tpt
  , i_base_rate_export   in com_api_type_pkg.t_boolean  default null
) return com_api_type_pkg.t_count
is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := $$PLSQL_UNIT || '.EXECUTE_RATE_QUERY';
    l_count                 com_api_type_pkg.t_count := 0;
begin
    trc_log_pkg.debug(
        i_text        => DEFAULT_PROCEDURE_NAME || ': start with i_count_query_only [#1]'
      , i_env_param1  => i_count_query_only
    );

    select
        count(1)
      , case when i_count_query_only = com_api_type_pkg.FALSE then
            xmlelement("currency_rates", xmlattributes('http://sv.bpc.in/SVXP' as "xmlns"),
                xmlagg(
                    xmlelement("currency_rate",
                        xmlelement("inst_id",   r.inst_id),
                        xmlelement("rate_type",   r.rate_type),
                        xmlelement("effective_date", r.eff_date),
                        xmlelement("expiration_date", r.exp_date),
                        xmlelement("src_currency",
                            xmlelement("scale", r.src_scale),
                            xmlelement("currency", r.src_currency),
                            xmlelement("exponent_scale", r.src_exponent_scale)),
                        xmlelement("dst_currency",
                            xmlelement("scale", r.dst_scale),
                            xmlelement("currency", r.dst_currency),
                            xmlelement("exponent_scale", r.dst_exponent_scale)),
                        xmlelement("rate", com_cst_rate_pkg.get_rate(r.rate, r.eff_rate)),
                        xmlelement("inverted", r.inverted)
                    )
                )
            ).getclobval()
        end
      into l_count
         , io_file
      from (
            select r.inst_id
                 , r.rate_type
                 , to_char(r.eff_date, com_api_const_pkg.XML_DATETIME_FORMAT) as eff_date
                 , to_char(r.exp_date, com_api_const_pkg.XML_DATETIME_FORMAT) as exp_date
                 , r.src_scale
                 , r.src_currency
                 , r.src_exponent_scale
                 , r.dst_scale
                 , r.dst_currency
                 , r.dst_exponent_scale
                 , r.rate
                 , r.inverted
                 , r.eff_rate
              from com_rate r
             where r.id in (select column_value from table(cast(io_rate_id_tab as num_tab_tpt)))
            union  -- The subqueries can contains the duplicated records, therefore need "union".
            select inst_id
                 , rate_type
                 , to_char(eff_date, com_api_const_pkg.XML_DATETIME_FORMAT) as eff_date
                 , to_char(exp_date, com_api_const_pkg.XML_DATETIME_FORMAT) as exp_date
                 , src_scale
                 , src_currency
                 , src_exponent_scale
                 , dst_scale
                 , dst_currency
                 , dst_exponent_scale
                 , rate
                 , inverted 
                 , case
                       when inverted = com_api_type_pkg.TRUE then dst_scale * dst_exponent_scale / rate / src_scale / src_exponent_scale
                       else rate * dst_scale * dst_exponent_scale / src_scale / src_exponent_scale
                   end eff_rate
              from (               
                        select r.inst_id
                             , r.rate_type
                             , r.eff_date
                             , r.exp_date
                             , r.src_scale
                             , r.src_currency
                             , r.src_exponent_scale
                             , 1 dst_scale
                             , f.dst_currency
                             , 1 dst_exponent_scale
                             , com_api_rate_pkg.get_rate (
                                      i_src_currency        => r.src_currency
                                    , i_dst_currency        => f.dst_currency
                                    , i_rate_type           => r.rate_type
                                    , i_inst_id             => r.inst_id
                                    , i_eff_date            => r.eff_date
                                    , i_mask_exception      => com_api_type_pkg.TRUE
                                    , i_exception_value     => null
                                ) rate
                             , r.inverted
                             , r.eff_rate
                          from com_rate r
                             , (
                                    select distinct rs.src_currency, rd.dst_currency, rs.rate_type, rs.inst_id, t.base_currency
                                      from com_rate rs
                                         , com_rate_type t
                                         , com_rate rd
                                     where rs.id in (select column_value from table(cast(io_rate_id_tab as num_tab_tpt)))
                                       and t.base_currency is not null
                                       and rs.rate_type = t.rate_type
                                       and rs.inst_id   = t.inst_id
                                       and t.base_currency = rs.dst_currency
                                       and rd.rate_type = t.rate_type
                                       and rd.inst_id   = t.inst_id
                                       and t.base_currency = rd.src_currency
                           ) f
                     where r.id in (select column_value from table(cast(io_rate_id_tab as num_tab_tpt)))
                       and r.rate_type     = f.rate_type
                       and r.inst_id       = f.inst_id
                       and f.base_currency = r.dst_currency
                       and r.src_currency  = f.src_currency
                       and nvl(i_base_rate_export, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE
                   )
             where rate is not null              
    ) r;

    trc_log_pkg.debug (
        i_text        => DEFAULT_PROCEDURE_NAME || ': finish with l_count [#1]'
      , i_env_param1  => l_count
    );
    
    return l_count;
    
end execute_rate_query;

procedure export_clearing_data_10(
    i_inst_id                  in     com_api_type_pkg.t_inst_id    default null
  , i_start_date               in     date                          default null
  , i_end_date                 in     date                          default null
  , i_upl_oper_event_type      in     com_api_type_pkg.t_dict_value default null
  , i_terminal_type            in     com_api_type_pkg.t_dict_value default null
  , i_load_state               in     com_api_type_pkg.t_dict_value default null
  , i_load_successfull         in     com_api_type_pkg.t_dict_value default null
  , i_include_auth             in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_include_clearing         in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_masking_card             in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE  
  , i_process_container        in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_session_id               in     com_api_type_pkg.t_long_id    default null
  , i_split_files              in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_reversal_upload_type     in     com_api_type_pkg.t_dict_value default null
  , i_subscriber_name          in     com_api_type_pkg.t_name       default null
) is
    DEFAULT_PROCEDURE_NAME     constant com_api_type_pkg.t_name := $$PLSQL_UNIT || '.EXPORT_CLEARING_DATA_10';
    LOG_PREFIX                 constant com_api_type_pkg.t_name := DEFAULT_PROCEDURE_NAME;
    DATETIME_FORMAT            constant com_api_type_pkg.t_name := 'dd.mm.yyyy hh24:mi:ss';

    l_session_file_id           com_api_type_pkg.t_long_id;
    l_file                      clob;
    l_subscriber_name           com_api_type_pkg.t_name         := upper(nvl(i_subscriber_name, DEFAULT_PROCEDURE_NAME));
    l_sysdate                   date;
    l_params                    com_api_type_pkg.t_param_tab;
    l_lang                      com_api_type_pkg.t_dict_value;
    l_min_date                  date;
    l_max_date                  date;
    l_load_events_with_status   com_api_type_pkg.t_dict_value;
    l_load_successfull          com_api_type_pkg.t_dict_value;
    l_include_auth              com_api_type_pkg.t_boolean;
    l_include_clearing          com_api_type_pkg.t_boolean;
    l_evt_objects_tab           num_tab_tpt := num_tab_tpt();
    l_oper_ids_tab              num_tab_tpt := num_tab_tpt();
    l_oper_tab                  num_tab_tpt := num_tab_tpt();
    l_estimated_count           com_api_type_pkg.t_long_id      := 0;
    l_session_id_tab            num_tab_tpt := num_tab_tpt();
    l_process_session_id        com_api_type_pkg.t_long_id;
    l_use_session_id            com_api_type_pkg.t_boolean      := com_api_const_pkg.FALSE;
    l_incom_sess_file_id_tab    num_tab_tpt := num_tab_tpt();
    l_incom_sess_file_id        com_api_type_pkg.t_long_id;
    l_original_file_name        com_api_type_pkg.t_name;
    l_split_files               com_api_type_pkg.t_boolean      := com_api_const_pkg.FALSE;
    l_reversal_upload_type      com_api_type_pkg.t_dict_value;
    
begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug (
        i_text       => LOG_PREFIX || ': inst_id [' || nvl(to_char(i_inst_id), 'NULL') ||
                        '], upl_oper_event_type [' || nvl(i_upl_oper_event_type, 'NULL') || '], ' ||
                        'terminal_type [#1], start_date [#2], end_date [#3], already_loaded [#4], reversal_upload_type [#5], ' ||
                        'load_successfull [#6], ' ||
                        'include_auth [' ||
                        case i_include_auth when 0 then 'no' when 1 then 'yes' else to_char(i_include_auth) end || '], ' ||
                        'include_clearing [' ||
                        case i_include_clearing when 0 then 'no' when 1 then 'yes' else to_char(i_include_clearing) end || ']'
      , i_env_param1 => i_terminal_type
      , i_env_param2 => to_char(i_start_date, DATETIME_FORMAT)
      , i_env_param3 => to_char(i_end_date, DATETIME_FORMAT)
      , i_env_param4 => i_load_state
      , i_env_param5 => i_reversal_upload_type
      , i_env_param6 => i_load_successfull
    );

    trc_log_pkg.debug (
        i_text       => LOG_PREFIX || ': i_process_container [#1] i_session_id [#2] i_split_files [#3]'
      , i_env_param1 => i_process_container
      , i_env_param2 => i_session_id
      , i_env_param3 => i_split_files
    );

    l_sysdate := get_sysdate();
    l_lang := get_user_lang();
    trc_log_pkg.debug (
        i_text       => 'sysdate [#1], user_lang [#2]'
      , i_env_param1 => to_char(l_sysdate, DATETIME_FORMAT)
      , i_env_param2 => l_lang
    );

    -- Set default values for parameters
    l_load_events_with_status := nvl(i_load_state, evt_api_const_pkg.EVENT_OBJ_LOAD_ST_NOT_LOADED);
    l_load_successfull := nvl(i_load_successfull, opr_api_const_pkg.UNLOADING_OPER_STATUS_ALL);
    l_include_auth := nvl(i_include_auth, com_api_const_pkg.TRUE);
    l_include_clearing := nvl(i_include_clearing, com_api_const_pkg.TRUE);
    l_reversal_upload_type := nvl(i_reversal_upload_type, opr_api_const_pkg.REVERSAL_UPLOAD_ALL);

    -- Check for the case when end date less than start date
    if nvl(i_end_date, date '9999-12-31') < nvl(i_start_date, date '0001-01-01') then
        com_api_error_pkg.raise_error (
            i_error      => 'END_DATE_LESS_THAN_START_DATE'
          , i_env_param1 => com_api_type_pkg.convert_to_char(i_end_date)
          , i_env_param2 => com_api_type_pkg.convert_to_char(i_start_date)
        );
    end if;

    l_min_date := nvl(i_start_date, date '0001-01-01');
    l_max_date := nvl(i_end_date, trunc(get_sysdate) + 1 - com_api_const_pkg.ONE_SECOND);

    trc_log_pkg.debug (
        i_text       => 'min_date [#1], max_date [#2]'
      , i_env_param1 => to_char(l_min_date, DATETIME_FORMAT)
      , i_env_param2 => to_char(l_max_date, DATETIME_FORMAT)
    );

    -- Get session list
    l_process_session_id := get_session_id;
    if nvl(i_process_container, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE and i_session_id is not null then
        select id
          bulk collect into l_session_id_tab
          from prc_session
          connect by parent_id = prior id
          start with id        = i_session_id
        intersect
          select id
            from prc_session
            start with id = (
                               select max(id) keep (dense_rank last order by level)
                                 from prc_session
                                 start with id = l_process_session_id
                                 connect by id = prior parent_id
                            )
            connect by prior id = parent_id;

    elsif nvl(i_process_container, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
          select id
            bulk collect into l_session_id_tab
            from prc_session
            start with id = (
                               select max(id) keep (dense_rank last order by level)
                                 from prc_session
                                 start with id = l_process_session_id
                                 connect by id = prior parent_id
                            )
            connect by prior id = parent_id;

    elsif i_session_id is not null then
        select id
          bulk collect into l_session_id_tab
          from prc_session
          connect by parent_id = prior id
          start with id        = i_session_id;

    end if;

    if l_session_id_tab.count > 0 then
      l_use_session_id := com_api_const_pkg.TRUE;
    end if;

    trc_log_pkg.debug (
        i_text       => 'l_use_session_id [#1] l_session_id_tab.count [#2]'
      , i_env_param1 => l_use_session_id
      , i_env_param2 => l_session_id_tab.count
    );

    if i_split_files = com_api_const_pkg.TRUE and l_use_session_id = com_api_const_pkg.TRUE then
        l_split_files := com_api_const_pkg.TRUE;
    end if;

    -- Get session list for incoming files
    if l_split_files = com_api_const_pkg.TRUE then
        select s.id
          bulk collect into l_incom_sess_file_id_tab
          from prc_session_file s
             , prc_file_attribute a
             , prc_file f
         where s.session_id in (
                                   select column_value
                                     from table(cast(l_session_id_tab as num_tab_tpt))
                               )
           and s.file_attr_id   = a.id
           and f.id             = a.file_id
           and f.file_purpose   = prc_api_const_pkg.FILE_PURPOSE_IN
           and f.file_type      = opr_api_const_pkg.FILE_TYPE_LOADING;

    end if;

    trc_log_pkg.debug (
        i_text       => 'l_split_files [#1] l_incom_sess_file_id_tab.count [#2]'
      , i_env_param1 => l_split_files
      , i_env_param2 => l_incom_sess_file_id_tab.count
    );

    -- Select IDs of all event objects need to proceed
    select
        v.id                 as evt_id
      , v.object_id          as evt_obj_id
    bulk collect into
        l_evt_objects_tab
      , l_oper_ids_tab
    from
        (
            select eo.entity_type, eo.object_id, eo.inst_id, eo.eff_date, eo.event_id, eo.id, eo.split_hash
              from evt_event_object eo
             where l_load_events_with_status = evt_api_const_pkg.EVENT_OBJ_LOAD_ST_NOT_LOADED
               and decode(eo.status, 'EVST0001', eo.procedure_name, null) = l_subscriber_name
               and eo.split_hash in (select split_hash from com_api_split_map_vw)
            union all
            select eo.entity_type, eo.object_id, eo.inst_id, eo.eff_date, eo.event_id, eo.id, eo.split_hash
              from evt_event_object eo
             where eo.split_hash in (select split_hash from com_api_split_map_vw)
               and ((l_load_events_with_status = evt_api_const_pkg.EVENT_OBJ_LOAD_ST_ALL          
                       and (decode(eo.status, 'EVST0001', eo.procedure_name, null) = l_subscriber_name 
                            or decode(eo.status, 'EVST0002', eo.procedure_name, null) = l_subscriber_name
                       )
                   )
                   or (l_load_events_with_status = evt_api_const_pkg.EVENT_OBJ_LOAD_ST_ALREADY_LOAD
                       and decode(eo.status, 'EVST0002', eo.procedure_name, null) = l_subscriber_name
                   )
               )
        ) v
      , evt_event e
      , opr_operation o
      , aut_auth a
    where
        e.id = v.event_id
        and v.eff_date <= l_sysdate
        and (v.inst_id = i_inst_id
            or i_inst_id is null
            or i_inst_id = ost_api_const_pkg.DEFAULT_INST
        )
        and (o.terminal_type = i_terminal_type
            or i_terminal_type is null
        )
        and (e.event_type = i_upl_oper_event_type
            or i_upl_oper_event_type is null
        )
        and v.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
        and o.id    = v.object_id
        and o.host_date between l_min_date and l_max_date
        and a.id(+) = o.id
        and (l_load_successfull != opr_api_const_pkg.UNLOADING_OPER_STATUS_SUCCESS or o.status in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES))
        and (l_load_successfull != opr_api_const_pkg.UNLOADING_OPER_STATUS_DECLINE or o.status not in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES))
        and (l_load_successfull != opr_api_const_pkg.UNLOADING_OPER_STATUS_SUCCESS or a.resp_code is null or a.resp_code = aup_api_const_pkg.RESP_CODE_OK)
        and (l_load_successfull != opr_api_const_pkg.UNLOADING_OPER_STATUS_DECLINE or a.resp_code is null or a.resp_code <> aup_api_const_pkg.RESP_CODE_OK)
        and (o.is_reversal = com_api_const_pkg.FALSE or l_reversal_upload_type in (opr_api_const_pkg.REVERSAL_UPLOAD_ALL, opr_api_const_pkg.REVERSAL_UPLOAD_WITHOUT_MERGED))
        and (l_use_session_id = com_api_const_pkg.FALSE
             or (l_use_session_id = com_api_const_pkg.TRUE
                 and o.session_id in (select column_value from table(cast(l_session_id_tab as num_tab_tpt)))
             )
        )
        and (l_split_files = com_api_const_pkg.FALSE
             or (l_split_files = com_api_const_pkg.TRUE
                 and o.incom_sess_file_id in (select column_value from table(cast(l_incom_sess_file_id_tab as num_tab_tpt)))
             )
        )
        and (case
                 when l_reversal_upload_type = opr_api_const_pkg.REVERSAL_UPLOAD_ALL
                    or (l_reversal_upload_type = opr_api_const_pkg.REVERSAL_UPLOAD_ORIGINAL
                        and o.is_reversal = com_api_const_pkg.FALSE)
                 then com_api_const_pkg.FALSE

                 when l_reversal_upload_type = opr_api_const_pkg.REVERSAL_UPLOAD_WITHOUT_MERGED
                      and o.is_reversal = com_api_const_pkg.TRUE
                      and o.status in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES)
                 then (
                          select nvl(max(com_api_const_pkg.TRUE), com_api_const_pkg.FALSE)
                            from opr_operation orig, evt_event_object eo_orig, evt_event ev_orig
                           where orig.id                = o.original_id
                             and orig.is_reversal       = com_api_const_pkg.FALSE
                             and (l_load_successfull   != opr_api_const_pkg.UNLOADING_OPER_STATUS_SUCCESS or orig.status in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES))
                             and (l_load_successfull   != opr_api_const_pkg.UNLOADING_OPER_STATUS_DECLINE or orig.status not in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES))
                             and (orig.oper_amount - o.oper_amount) = 0
                             and o.oper_currency        = orig.oper_currency
                             and eo_orig.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                             and eo_orig.object_id      = orig.id
                             and eo_orig.split_hash     = v.split_hash
                             and eo_orig.procedure_name = l_subscriber_name
                             and (
                                   ( eo_orig.status  = evt_api_const_pkg.EVENT_STATUS_READY
                                     and l_load_events_with_status in (evt_api_const_pkg.EVENT_OBJ_LOAD_ST_NOT_LOADED, evt_api_const_pkg.EVENT_OBJ_LOAD_ST_ALL)
                                   )
                                   or
                                   ( eo_orig.status  = evt_api_const_pkg.EVENT_STATUS_PROCESSED
                                     and l_load_events_with_status in (evt_api_const_pkg.EVENT_OBJ_LOAD_ST_ALREADY_LOAD, evt_api_const_pkg.EVENT_OBJ_LOAD_ST_ALL)
                                   )
                             )
                             and ev_orig.id          = eo_orig.event_id
                             and (ev_orig.event_type = i_upl_oper_event_type or i_upl_oper_event_type is null)
                 )

                 when l_reversal_upload_type = opr_api_const_pkg.REVERSAL_UPLOAD_WITHOUT_MERGED
                      and o.is_reversal = com_api_const_pkg.FALSE
                 then (
                          select nvl(max(com_api_const_pkg.TRUE), com_api_const_pkg.FALSE)
                            from opr_operation rev, evt_event_object eo_rev, evt_event ev_rev
                           where rev.original_id       = o.id
                             and rev.is_reversal       = com_api_const_pkg.TRUE
                             and rev.status in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES)
                             and (rev.oper_amount - o.oper_amount) = 0
                             and o.oper_currency       = rev.oper_currency
                             and eo_rev.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                             and eo_rev.object_id      = rev.id
                             and eo_rev.split_hash     = v.split_hash
                             and eo_rev.procedure_name = l_subscriber_name
                             and (
                                   ( eo_rev.status  = evt_api_const_pkg.EVENT_STATUS_READY
                                     and l_load_events_with_status in (evt_api_const_pkg.EVENT_OBJ_LOAD_ST_NOT_LOADED, evt_api_const_pkg.EVENT_OBJ_LOAD_ST_ALL)
                                   )
                                   or
                                   ( eo_rev.status  = evt_api_const_pkg.EVENT_STATUS_PROCESSED
                                     and l_load_events_with_status in (evt_api_const_pkg.EVENT_OBJ_LOAD_ST_ALREADY_LOAD, evt_api_const_pkg.EVENT_OBJ_LOAD_ST_ALL)
                                   )
                             )
                             and ev_rev.id          = eo_rev.event_id
                             and (ev_rev.event_type = i_upl_oper_event_type or i_upl_oper_event_type is null)
                 )

                 else com_api_const_pkg.FALSE
             end
        ) = com_api_const_pkg.FALSE;

    -- Decrease operation count
    select distinct column_value
      bulk collect into l_oper_tab
      from table(cast(l_oper_ids_tab as num_tab_tpt));

    -- Get estimated count
    l_estimated_count := l_oper_tab.count;

    trc_log_pkg.debug (
        i_text       => 'Operations to go count: [#1]'
      , i_env_param1 => l_estimated_count
    );

    prc_api_stat_pkg.log_estimation (
        i_estimated_count => l_estimated_count
    );

    if l_estimated_count > 0 then
        -- Preparing for passing into <prc_api_file_pkg.open_file> Id of the institute
        l_params:= evt_api_shared_data_pkg.g_params;
        rul_api_param_pkg.set_param (
            i_name    => 'INST_ID'
          , i_value   => i_inst_id
          , io_params => l_params
        );


        for r_xml in (
            -- Make XML
            select
                x.incom_sess_file_id
              , count(distinct x.id) as current_count
              , com_api_const_pkg.XML_HEADER ||
                xmlelement("clearing"
                  , xmlattributes('http://bpc.ru/sv/SVXP/clearing' as "xmlns")
                  , xmlforest(
                        to_char(l_session_file_id, 'TM9')                                   as "file_id"
                      , opr_api_const_pkg.FILE_TYPE_UNLOADING                               as "file_type"
                      , to_char(i_start_date, com_api_const_pkg.XML_DATE_FORMAT)            as "start_date"
                      , to_char(i_end_date, com_api_const_pkg.XML_DATE_FORMAT)              as "end_date"
                      , i_inst_id                                                           as "inst_id"
                    )
                  , xmlagg(
                        xmlelement("operation"
                          , xmlforest(
                                to_char(x.id, com_api_const_pkg.XML_NUMBER_FORMAT)          as "oper_id"
                              , x.oper_type                                                 as "oper_type"
                              , x.msg_type                                                  as "msg_type"
                              , x.sttl_type                                                 as "sttl_type"
                              , to_char(x.oper_date, com_api_const_pkg.XML_DATETIME_FORMAT) as "oper_date"
                              , to_char(x.host_date, com_api_const_pkg.XML_DATETIME_FORMAT) as "host_date"
                              , to_char(x.oper_count, com_api_const_pkg.XML_NUMBER_FORMAT)  as "oper_count"
                              , case when x.oper_amount is not null then
                                     xmlforest(
                                         x.oper_amount           as "amount_value"
                                       , x.oper_currency         as "currency"
                                     )
                                end                                                         as "oper_amount"
                              , case when x.oper_request_amount is not null then
                                     xmlforest(
                                         x.oper_request_amount   as "amount_value"
                                       , x.oper_currency         as "currency"
                                     )
                                end                                                         as "oper_request_amount"
                              , case when x.oper_surcharge_amount is not null then
                                     xmlforest(
                                         x.oper_surcharge_amount as "amount_value"
                                       , x.oper_currency         as "currency"
                                     )
                                end                                                         as "oper_surcharge_amount"
                              , case when x.oper_cashback_amount is not null then
                                     xmlforest(
                                         x.oper_cashback_amount   as "amount_value"
                                       , x.oper_currency          as "currency"
                                     )
                                end                                                         as "oper_cashback_amount"
                              , case when x.sttl_amount is not null then
                                     xmlforest(
                                         x.sttl_amount            as "amount_value"
                                       , x.sttl_currency          as "currency"
                                     )
                                end                                                         as "sttl_amount"
                              , case when x.fee_amount is not null then
                                     xmlforest(
                                         x.fee_amount            as "amount_value"
                                       , x.fee_currency          as "currency"
                                     )
                                end                                                         as "interchange_fee"
                              , x.originator_refnum                                         as "originator_refnum"
                              , x.network_refnum                                            as "network_refnum"
                              , x.acq_inst_bin                                              as "acq_inst_bin"
                              , x.status_reason                                             as "response_code"
                              , x.oper_reason                                               as "oper_reason"
                              , x.status                                                    as "status"
                              , x.is_reversal                                               as "is_reversal"
                              , x.merchant_number                                           as "merchant_number"
                              , x.mcc                                                       as "mcc"
                              , x.merchant_name                                             as "merchant_name"
                              , x.merchant_street                                           as "merchant_street"
                              , x.merchant_city                                             as "merchant_city"
                              , x.merchant_region                                           as "merchant_region"
                              , x.merchant_country                                          as "merchant_country"
                              , x.merchant_postcode                                         as "merchant_postcode"
                              , x.terminal_type                                             as "terminal_type"
                              , x.terminal_number                                           as "terminal_number"
                              , to_char(x.sttl_date, com_api_const_pkg.XML_DATETIME_FORMAT) as "sttl_date"
                            ) -- xmlforest
                            --
                          , (select
                                 xmlelement("payment_order"
                                   , xmlforest(
                                         po.id                as "payment_order_id"
                                       , po.status            as "payment_order_status"
                                       , po.purpose_id        as "purpose_id"
                                       , pp.purpose_number    as "purpose_number"
                                       , xmlforest(
                                             po.amount            as "amount_value"
                                           , po.currency          as "currency"
                                         ) as "payment_amount"
                                     )
                                   , (select xmlagg(
                                                 xmlelement("payment_parameter"
                                                   , xmlforest(
                                                         xp.param_name    as "payment_parameter_name"
                                                       , xod.param_value  as "payment_parameter_value"
                                                     )
                                                 ) 
                                             )
                                        from pmo_parameter xp
                                        join pmo_order_data xod on xod.param_id = xp.id
                                       where xod.order_id = po.id
                                     ) -- payment_parameter
                                   , (select xmlagg(
                                                 xmlelement("document"
                                                   , d.id                 as "document_id"
                                                   , d.document_type      as "document_type"
                                                   , to_char(d.document_date, com_api_const_pkg.XML_DATETIME_FORMAT) as "document_date"
                                                   , d.document_number    as "document_number"
                                                   , xmlagg(
                                                         case when dc.document_content is not null then
                                                             xmlelement("document_content"
                                                               , xmlforest(
                                                                     dc.content_type                                     as "content_type"
                                                                   , com_api_hash_pkg.base64_encode(dc.document_content) as "content"
                                                                 )
                                                             )
                                                         end
                                                     )
                                                 ) -- document
                                             )
                                        from rpt_document d
                                        left join rpt_document_content dc on dc.document_id = d.id
                                       where d.object_id = po.id
                                         and d.entity_type = pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
                                       group by
                                             d.id
                                           , d.document_type
                                           , d.document_date
                                           , d.document_number
                                     ) -- document
                                 ) -- payment_order
                              from pmo_order po
                              left join pmo_purpose pp on pp.id = po.purpose_id
                             where po.id = x.payment_order_id
                            )
                            --
                          , (select
                                 xmlagg(
                                     xmlelement("transaction"
                                       , xmlelement("transaction_id", ae.transaction_id)
                                       , xmlelement("transaction_type", ae.transaction_type)
                                       , xmlelement("posting_date", to_char(min(ae.posting_date), com_api_const_pkg.XML_DATETIME_FORMAT))
                                       , (select xmlagg(
                                                     xmlelement("debit_entry"
                                                       , xmlelement("entry_id", dae.id)
                                                       , xmlelement("account"
                                                           , xmlelement("account_number", da.account_number)
                                                           , xmlelement("currency", da.currency)
                                                           , xmlelement("agent_number", doa.agent_number)
                                                         )
                                                       , xmlelement("amount"
                                                           , xmlelement("amount_value", dae.amount)
                                                           , xmlelement("currency", dae.currency)
                                                         )
                                                     )
                                                 )
                                            from acc_entry dae
                                            join acc_account da on da.id = dae.account_id
                                            left join ost_agent doa on doa.id = da.agent_id
                                           where dae.transaction_id = ae.transaction_id
                                             and dae.balance_impact = com_api_const_pkg.DEBIT
                                         ) -- debit entry
                                       , (select xmlagg(
                                                     xmlelement("credit_entry"
                                                       , xmlelement("entry_id", cae.id)
                                                       , xmlelement("account"
                                                           , xmlelement("account_number", ca.account_number)
                                                           , xmlelement("currency", ca.currency)
                                                           , xmlelement("agent_number", coa.agent_number)
                                                         )
                                                       , xmlelement("amount"
                                                           , xmlelement("amount_value", cae.amount)
                                                           , xmlelement("currency", cae.currency)
                                                         )
                                                     )
                                                 )
                                            from acc_entry cae
                                            join acc_account ca on ca.id = cae.account_id
                                            left join ost_agent coa on coa.id = ca.agent_id
                                           where cae.transaction_id = ae.transaction_id
                                             and cae.balance_impact = com_api_const_pkg.CREDIT
                                         ) -- credit entry
                                       , (select
                                              xmlagg(
                                                  xmlelement("document"
                                                    , xmlelement("document_id", d.id)
                                                    , xmlelement("document_type", d.document_type)
                                                    , xmlelement("document_date", to_char(d.document_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                                    , xmlelement("document_number", d.document_number)
                                                    , xmlagg(
                                                          xmlelement("document_content"
                                                              , xmlelement("content_type", dc.content_type)
                                                              , xmlelement("content", com_api_hash_pkg.base64_encode(dc.document_content))
                                                          )
                                                      )
                                                  )
                                              )
                                            from rpt_document d
                                            left join rpt_document_content dc on dc.document_id = d.id
                                           where d.object_id = ae.transaction_id
                                             and d.entity_type = acc_api_const_pkg.ENTITY_TYPE_TRANSACTION
                                           group by d.id, d.document_type, d.document_date, d.document_number
                                         ) -- document
                                       , xmlelement("conversion_rate", nvl(am.conversion_rate, 1))
                                       , xmlelement("amount_purpose", am.amount_purpose)
                                     ) -- xmlelement transaction
                                 ) -- xmlagg
                               from acc_macros am
                               join acc_entry ae on ae.macros_id = am.id
                              where am.object_id = x.id -- opr_operation.id
                                and am.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                              group by
                                    ae.transaction_id
                                  , ae.transaction_type
                                  , am.conversion_rate
                                  , am.amount_purpose
                            ) -- transaction
                            --
                          , (select xmlagg(
                                        xmlelement("document"
                                          , xmlelement("document_id", d.id)
                                          , xmlelement("document_type", d.document_type)
                                          , xmlelement("document_date", to_char(d.document_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                          , xmlelement("document_number", d.document_number)
                                          , xmlagg(
                                                case when dc.document_content is not null then
                                                    xmlelement("document_content"
                                                      , xmlelement("content_type", dc.content_type)
                                                      , xmlelement("content", com_api_hash_pkg.base64_encode(dc.document_content))
                                                    )
                                                end
                                            )
                                        )
                                    )
                               from rpt_document d
                               left join rpt_document_content dc on dc.document_id = d.id
                              where d.object_id = x.id
                                and d.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                              group by
                                    d.id
                                  , d.document_type
                                  , d.document_date
                                  , d.document_number
                            ) as document
                            --
                          , (select xmlforest(
                                        xmlforest(
                                            p.client_id_type      as "client_id_type" 
                                          , p.client_id_value     as "client_id_value"
                                          , case nvl(i_masking_card, com_api_const_pkg.TRUE)
                                                when com_api_const_pkg.TRUE
                                                then iss_api_card_pkg.get_card_mask(i_card_number => c.card_number)
                                                else c.card_number
                                            end as "card_number"
                                          , case
                                                when p.card_id is not null
                                                then iss_api_card_instance_pkg.get_card_uid(
                                                         i_card_instance_id => iss_api_card_instance_pkg.get_card_instance_id(
                                                                                   i_card_id => p.card_id
                                                                               )
                                                     )
                                                else null
                                            end                   as "card_id"
                                          , p.card_instance_id    as "card_instance_id"
                                          , p.card_seq_number     as "card_seq_number"
                                          , to_char(p.card_expir_date, com_api_const_pkg.XML_DATE_FORMAT) as "card_expir_date"
                                          , p.card_country        as "card_country"                                      
                                          , p.inst_id             as "inst_id"
                                          , p.network_id          as "network_id"
                                          , p.auth_code           as "auth_code"
                                          , p.account_number      as "account_number"
                                          , p.account_amount      as "account_amount"
                                          , p.account_currency    as "account_currency"
                                        ) as "issuer"
                                    )
                               from opr_participant p
                               left join opr_card c on c.oper_id = p.oper_id
                              where p.oper_id = x.id
                                and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                            ) as issuer
                            --
                          , (select xmlforest(
                                        xmlforest(
                                            p.inst_id             as "inst_id"
                                          , p.network_id          as "network_id"
                                          , p.auth_code           as "auth_code"
                                          , p.account_number      as "account_number"
                                          , p.account_amount      as "account_amount"
                                          , p.account_currency    as "account_currency"
                                        ) as "acquirer"
                                    )
                               from opr_participant p
                              where p.oper_id = x.id
                                and p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                            ) as acquier
                            --
                          , (select xmlforest(
                                        xmlforest(
                                            p.client_id_type          as "client_id_type"
                                          , p.client_id_value         as "client_id_value"
                                          , p.inst_id                 as "inst_id"
                                        ) as "destination"
                                    )
                               from opr_participant p
                              where p.oper_id = x.id
                                and p.participant_type = com_api_const_pkg.PARTICIPANT_DEST
                            ) as destination
                            --
                          , (select xmlforest(
                                        xmlforest(
                                            p.client_id_type          as "client_id_type"
                                          , p.client_id_value         as "client_id_value"
                                          , p.inst_id                 as "inst_id"
                                        ) as "aggregator"
                                    )
                               from opr_participant p
                              where p.oper_id = x.id
                                and p.participant_type = com_api_const_pkg.PARTICIPANT_AGGREGATOR
                            ) as aggregator
                            --
                          , (select xmlforest(
                                        xmlforest(
                                            p.client_id_type          as "client_id_type"
                                          , p.client_id_value         as "client_id_value"
                                          , p.inst_id                 as "inst_id"
                                        ) as "service_provider"
                                    )
                               from opr_participant p
                              where p.oper_id = x.id
                                and p.participant_type = com_api_const_pkg.PARTICIPANT_SERVICE_PROVIDER
                            ) as service_provider
                            --
                          , (select xmlagg(
                                        xmlelement("note"
                                          , xmlelement("note_type", n.note_type)
                                          , xmlagg(
                                                xmlelement("note_content"
                                                  , xmlattributes(l_lang as "language")
                                                  , xmlforest(
                                                        com_api_i18n_pkg.get_text(
                                                            i_table_name  => 'ntb_note'
                                                          , i_column_name => 'header'
                                                          , i_object_id   => n.id
                                                          , i_lang        => l_lang
                                                        ) as "note_header"
                                                      , com_api_i18n_pkg.get_text(
                                                            i_table_name  => 'ntb_note'
                                                          , i_column_name => 'text'
                                                          , i_object_id   => n.id
                                                          , i_lang        => l_lang
                                                        ) as "note_text"
                                                    )
                                                )
                                            )
                                        )
                                    )
                               from ntb_note n
                              where n.object_id = x.id
                                and n.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                              group by
                                    n.note_type
                            ) as note
                            --
                          , case when x.au_id is not null
                                  and nvl(l_include_auth, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE
                                 then
                                     (select
                                          xmlagg(
                                              xmlelement("auth_data"
                                                , xmlforest(
                                                      x.au_resp_code                             as "resp_code"
                                                    , x.au_proc_type                             as "proc_type"
                                                    , x.au_proc_mode                             as "proc_mode"
                                                    , to_char(x.au_is_advice, com_api_const_pkg.XML_NUMBER_FORMAT)           as "is_advice"
                                                    , to_char(x.au_is_repeat, com_api_const_pkg.XML_NUMBER_FORMAT)           as "is_repeat"
                                                    , to_char(x.au_bin_amount, com_api_const_pkg.XML_NUMBER_FORMAT)          as "bin_amount"
                                                    , x.au_bin_currency                          as "bin_currency"
                                                    , to_char(x.au_bin_cnvt_rate, com_api_const_pkg.XML_NUMBER_FORMAT)       as "bin_cnvt_rate"
                                                    , to_char(x.au_network_amount, com_api_const_pkg.XML_NUMBER_FORMAT)      as "network_amount"
                                                    , x.au_network_currency                      as "network_currency"
                                                    , to_char(x.au_network_cnvt_date, com_api_const_pkg.XML_DATETIME_FORMAT) as "network_cnvt_date"
                                                    , to_char(x.au_account_cnvt_rate, com_api_const_pkg.XML_NUMBER_FORMAT)   as "account_cnvt_rate"
                                                    , x.au_addr_verif_result                     as "addr_verif_result"
                                                    , x.au_acq_resp_code                         as "acq_resp_code"
                                                    , x.au_acq_device_proc_result                as "acq_device_proc_result"
                                                    , x.au_cat_level                             as "cat_level"
                                                    , x.au_card_data_input_cap                   as "card_data_input_cap"
                                                    , x.au_crdh_auth_cap                         as "crdh_auth_cap"
                                                    , x.au_card_capture_cap                      as "card_capture_cap"
                                                    , x.au_terminal_operating_env                as "terminal_operating_env"
                                                    , x.au_crdh_presence                         as "crdh_presence"
                                                    , x.au_card_presence                         as "card_presence"
                                                    , x.au_card_data_input_mode                  as "card_data_input_mode"
                                                    , x.au_crdh_auth_method                      as "crdh_auth_method"
                                                    , x.au_crdh_auth_entity                      as "crdh_auth_entity"
                                                    , x.au_card_data_output_cap                  as "card_data_output_cap"
                                                    , x.au_terminal_output_cap                   as "terminal_output_cap"
                                                    , x.au_pin_capture_cap                       as "pin_capture_cap"
                                                    , x.au_pin_presence                          as "pin_presence"
                                                    , x.au_cvv2_presence                         as "cvv2_presence"
                                                    , x.au_cvc_indicator                         as "cvc_indicator"
                                                    , x.au_pos_entry_mode                        as "pos_entry_mode"
                                                    , x.au_pos_cond_code                         as "pos_cond_code"
                                                    , x.au_emv_data                              as "emv_data"
                                                    , x.au_atc                                   as "atc"
                                                    , x.au_tvr                                   as "tvr"
                                                    , x.au_cvr                                   as "cvr"
                                                    , x.au_addl_data                             as "addl_data"
                                                    , x.au_service_code                          as "service_code"
                                                    , x.au_device_date                           as "device_date"
                                                    , x.au_cvv2_result                           as "cvv2_result"
                                                    , x.au_certificate_method                    as "certificate_method"
                                                    , x.au_merchant_certif                       as "merchant_certif"
                                                    , x.au_cardholder_certif                     as "cardholder_certif"
                                                    , x.au_ucaf_indicator                        as "ucaf_indicator"
                                                    , to_char(x.au_is_early_emv, com_api_const_pkg.XML_NUMBER_FORMAT)        as "is_early_emv"
                                                    , x.au_is_completed                          as "is_completed"
                                                    , x.au_amounts                               as "amounts"
                                                    , x.au_agent_unique_id                       as "agent_unique_id"
                                                    , x.external_auth_id                         as "external_auth_id"
                                                    , x.external_orig_id                         as "external_orig_id"
                                                    , x.auth_purpose_id                          as "auth_purpose_id"
                                                  )
                                                , (select
                                                       xmlagg(
                                                           xmlelement("auth_tag"
                                                             , xmlelement("tag_id", t.tag)
                                                             , xmlelement("tag_value", v.tag_value)
                                                             , xmlelement("tag_name", t.reference)
                                                           )
                                                       )
                                                     from
                                                         aup_tag t
                                                       , aup_tag_value v
                                                    where
                                                         v.tag_id  = t.tag and v.auth_id = x.id
                                                  )
                                              )
                                          )
                                       from
                                           dual
                                     )
                            end as auth_data
                            --
                          , case when x.mc_id is not null
                                  and nvl(l_include_clearing, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE
                                 then
                                 xmlforest(
                                     xmlforest(
                                         to_char(x.mc_is_incoming, com_api_const_pkg.XML_NUMBER_FORMAT) as "is_incoming"
                                       , to_char(x.mc_is_reversal, com_api_const_pkg.XML_NUMBER_FORMAT) as "is_reversal"
                                       , to_char(x.mc_is_rejected, com_api_const_pkg.XML_NUMBER_FORMAT) as "is_rejected"
                                       , to_char(x.mc_impact, com_api_const_pkg.XML_NUMBER_FORMAT)      as "impact"
                                       , x.mc_mti              as "mti"
                                       , x.mc_de024            as "de024"
                                       , x.mc_de002            as "de002"
                                       , x.mc_de003_1          as "de003_1"
                                       , x.mc_de003_2          as "de003_2"
                                       , x.mc_de003_3          as "de003_3"
                                       , to_char(x.mc_de004, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de004"
                                       , to_char(x.mc_de005, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de005"
                                       , to_char(x.mc_de006, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de006"
                                       , x.mc_de009            as "de009"
                                       , x.mc_de010            as "de010"
                                       , to_char(x.mc_de012, com_api_const_pkg.XML_DATETIME_FORMAT)     as "de012"
                                       , to_char(x.mc_de014, com_api_const_pkg.XML_DATETIME_FORMAT)     as "de014" 
                                       , x.mc_de022_1          as "de022_1"
                                       , x.mc_de022_2          as "de022_2"
                                       , x.mc_de022_3          as "de022_3"
                                       , x.mc_de022_4          as "de022_4"     
                                       , x.mc_de022_5          as "de022_5"
                                       , x.mc_de022_6          as "de022_6"
                                       , x.mc_de022_7          as "de022_7"
                                       , x.mc_de022_8          as "de022_8"
                                       , x.mc_de022_9          as "de022_9" 
                                       , x.mc_de022_10         as "de022_10"
                                       , x.mc_de022_11         as "de022_11"
                                       , x.mc_de022_12         as "de022_12"
                                       , to_char(x.mc_de023, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de023"
                                       , x.mc_de025            as "de025"
                                       , x.mc_de026            as "de026"
                                       , to_char(x.mc_de030_1, com_api_const_pkg.XML_NUMBER_FORMAT)     as "de030_1"
                                       , to_char(x.mc_de030_2, com_api_const_pkg.XML_NUMBER_FORMAT)     as "de030_2"
                                       , x.mc_de031            as "de031"
                                       , x.mc_de032            as "de032"
                                       , x.mc_de033            as "de033"
                                       , x.mc_de037            as "de037"
                                       , x.mc_de038            as "de038"
                                       , x.mc_de040            as "de040"
                                       , x.mc_de041            as "de041"
                                       , x.mc_de042            as "de042"
                                       , x.mc_de043_1          as "de043_1"
                                       , x.mc_de043_2          as "de043_2"
                                       , x.mc_de043_3          as "de043_3"
                                       , x.mc_de043_4          as "de043_4"
                                       , x.mc_de043_5          as "de043_5"
                                       , x.mc_de043_6          as "de043_6"
                                       , x.mc_de049            as "de049"
                                       , x.mc_de050            as "de050"
                                       , x.mc_de051            as "de051"
                                       , x.mc_de054            as "de054"
                                       , x.mc_de055            as "de055"
                                       , x.mc_de063            as "de063"
                                       , to_char(x.mc_de071, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de071"
                                       , regexp_replace(x.mc_de072, '[[:cntrl:]]', null)                as "de072"
                                       , to_char(x.mc_de073, com_api_const_pkg.XML_DATETIME_FORMAT)     as "de073"
                                       , x.mc_de093            as "de093"
                                       , x.mc_de094            as "de094"
                                       , x.mc_de095            as "de095"
                                       , x.mc_de100            as "de100"
                                       , to_char(x.mc_de111, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de111"
                                       , x.mc_p0002            as "p0002"
                                       , x.mc_p0023            as "p0023"
                                       , x.mc_p0025_1          as "p0025_1"
                                       , to_char(x.mc_p0025_2, com_api_const_pkg.XML_DATETIME_FORMAT)   as "p0025_2"
                                       , x.mc_p0043            as "p0043"
                                       , x.mc_p0052            as "p0052"
                                       , x.mc_p0137            as "p0137"
                                       , x.mc_p0148            as "p0148"
                                       , x.mc_p0146            as "p0146"
                                       , to_char(x.mc_p0146_net, com_api_const_pkg.XML_NUMBER_FORMAT)   as "p0146_net"
                                       , x.mc_p0147            as "p0147"
                                       , x.mc_p0149_1          as "p0149_1"
                                       , x.mc_p0149_2          as "p0149_2"
                                       , x.mc_p0158_1          as "p0158_1"
                                       , x.mc_p0158_2          as "p0158_2"
                                       , x.mc_p0158_3          as "p0158_3"           
                                       , x.mc_p0158_4          as "p0158_4"
                                       , to_char(x.mc_p0158_5, com_api_const_pkg.XML_DATETIME_FORMAT)   as "p0158_5"
                                       , to_char(x.mc_p0158_6, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0158_6"
                                       , x.mc_p0158_7          as "p0158_7"
                                       , x.mc_p0158_8          as "p0158_8"
                                       , x.mc_p0158_9          as "p0158_9"
                                       , x.mc_p0158_10         as "p0158_10"
                                       , x.mc_p0159_1          as "p0159_1"
                                       , x.mc_p0159_2          as "p0159_2"
                                       , to_char(x.mc_p0159_3, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0159_3"
                                       , x.mc_p0159_4          as "p0159_4"
                                       , x.mc_p0159_5          as "p0159_5"
                                       , to_char(x.mc_p0159_6, com_api_const_pkg.XML_DATETIME_FORMAT)   as "p0159_6"
                                       , to_char(x.mc_p0159_7, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0159_7"
                                       , to_char(x.mc_p0159_8, com_api_const_pkg.XML_DATETIME_FORMAT)   as "p0159_8"
                                       , to_char(x.mc_p0159_9, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0159_9"
                                       , x.mc_p0165            as "p0165"
                                       , x.mc_p0176            as "p0176"
                                       , to_char(x.mc_p0228, com_api_const_pkg.XML_NUMBER_FORMAT)       as "p0228" 
                                       , to_char(x.mc_p0230, com_api_const_pkg.XML_NUMBER_FORMAT)       as "p0230"
                                       , x.mc_p0241            as "p0241"
                                       , x.mc_p0243            as "p0243"
                                       , x.mc_p0244            as "p0244"
                                       , x.mc_p0260            as "p0260"
                                       , to_char(x.mc_p0261, com_api_const_pkg.XML_NUMBER_FORMAT)       as "p0261"
                                       , to_char(x.mc_p0262, com_api_const_pkg.XML_NUMBER_FORMAT)       as "p0262"
                                       , to_char(x.mc_p0264, com_api_const_pkg.XML_NUMBER_FORMAT)       as "p0264"
                                       , x.mc_p0265            as "p0265"
                                       , x.mc_p0266            as "p0266"
                                       , x.mc_p0267            as "p0267"
                                       , to_char(x.mc_p0268_1, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0268_1"
                                       , x.mc_p0268_2          as "p0268_2"
                                       , x.mc_p0375            as "p0375"
                                       , x.mc_emv_9f26         as "emv_9f26"
                                       , to_char(x.mc_emv_9f02, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_9f02"
                                       , x.mc_emv_9f27         as "emv_9f27"
                                       , x.mc_emv_9f10         as "emv_9f10"
                                       , x.mc_emv_9f36         as "emv_9f36"
                                       , x.mc_emv_95           as "emv_95"
                                       , x.mc_emv_82           as "emv_82"
                                       , to_char(x.mc_emv_9a, com_api_const_pkg.XML_DATETIME_FORMAT)    as "emv_9a"
                                       , to_char(x.mc_emv_9c, com_api_const_pkg.XML_NUMBER_FORMAT)      as "emv_9c"
                                       , x.mc_emv_9f37         as "emv_9f37"
                                       , to_char(x.mc_emv_5f2a, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_5f2a"
                                       , x.mc_emv_9f33         as "emv_9f33"
                                       , x.mc_emv_9f34         as "emv_9f34"
                                       , to_char(x.mc_emv_9f1a, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_9f1a"
                                       , to_char(x.mc_emv_9f35, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_9f35"
                                       , x.mc_emv_9f53         as "emv_9f53"
                                       , x.mc_emv_84           as "emv_84"
                                       , x.mc_emv_9f09         as "emv_9f09"
                                       , to_char(x.mc_emv_9f03, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_9f03"
                                       , x.mc_emv_9f1e         as "emv_9f1e"
                                       , to_char(x.mc_emv_9f41, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_9f41"
                                       , x.mc_p0042            as "p0042"
                                       , x.mc_p0158_11         as "p0158_11"
                                       , x.mc_p0158_12         as "p0158_12"
                                       , x.mc_p0158_13         as "p0158_13"
                                       , x.mc_p0158_14         as "p0158_14"
                                       , x.mc_p0198            as "p0198"
                                       , to_char(x.mc_p0200_1, com_api_const_pkg.XML_DATETIME_FORMAT)   as "p0200_1"
                                       , to_char(x.mc_p0200_2, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0200_2"
                                       , x.mc_p0210_1          as "p0210_1"
                                       , x.mc_p0210_2          as "p0210_2"                                   
                                     ) as "ipm_data" -- xmlforest
                                 ) -- xmlforest
                            end
                            --
                          , case when x.vi_id is not null
                                  and nvl(l_include_clearing, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE
                                 then
                                 xmlforest(
                                     xmlforest(
                                         to_char(x.vi_is_reversal, com_api_const_pkg.XML_NUMBER_FORMAT)    as "is_reversal"
                                       , to_char(x.vi_is_incoming, com_api_const_pkg.XML_NUMBER_FORMAT)    as "is_incoming"
                                       , to_char(x.vi_is_returned, com_api_const_pkg.XML_NUMBER_FORMAT)    as "is_returned"
                                       , to_char(x.vi_is_invalid, com_api_const_pkg.XML_NUMBER_FORMAT)     as "is_invalid"
                                       , x.vi_rrn                    as "rrn"
                                       , x.vi_trans_code             as "trans_code"
                                       , x.vi_trans_code_qualifier   as "trans_code_qualifier"
                                       , x.vi_card_mask              as "card_mask"
                                       , to_char(x.vi_oper_amount, com_api_const_pkg.XML_NUMBER_FORMAT)    as "oper_amount"
                                       , x.vi_oper_currency          as "oper_currency"
                                       , to_char(x.vi_oper_date, com_api_const_pkg.XML_DATETIME_FORMAT)    as "oper_date"
                                       , to_char(x.vi_sttl_amount, com_api_const_pkg.XML_NUMBER_FORMAT)    as "sttl_amount"
                                       , x.vi_sttl_currency          as "sttl_currency"
                                       , to_char(x.vi_network_amount, com_api_const_pkg.XML_NUMBER_FORMAT) as "network_amount"
                                       , x.vi_network_currency       as "network_currency"
                                       , x.vi_floor_limit_ind        as "floor_limit_ind"
                                       , x.vi_exept_file_ind         as "exept_file_ind"
                                       , x.vi_pcas_ind               as "pcas_ind"
                                       , x.vi_arn                    as "arn"
                                       , x.vi_acquirer_bin           as "acquirer_bin"
                                       , x.vi_acq_business_id        as "acq_business_id"
                                       , x.vi_merchant_name          as "merchant_name"
                                       , x.vi_merchant_city          as "merchant_city"
                                       , x.vi_merchant_country       as "merchant_country"
                                       , x.vi_merchant_postal_code   as "merchant_postal_code"
                                       , x.vi_merchant_region        as "merchant_region"
                                       , x.vi_merchant_street        as "merchant_street"
                                       , x.vi_mcc                    as "mcc"
                                       , x.vi_req_pay_service        as "req_pay_service"
                                       , x.vi_usage_code             as "usage_code"
                                       , x.vi_reason_code            as "reason_code"
                                       , x.vi_settlement_flag        as "settlement_flag"
                                       , x.vi_auth_char_ind          as "auth_char_ind"
                                       , x.vi_auth_code              as "auth_code"
                                       , x.vi_pos_terminal_cap       as "pos_terminal_cap"
                                       , x.vi_inter_fee_ind          as "inter_fee_ind"
                                       , x.vi_crdh_id_method         as "crdh_id_method"
                                       , x.vi_collect_only_flag      as "collect_only_flag"
                                       , x.vi_pos_entry_mode         as "pos_entry_mode"
                                       , x.vi_central_proc_date      as "central_proc_date"
                                       , x.vi_reimburst_attr         as "reimburst_attr"
                                       , x.vi_iss_workst_bin         as "iss_workst_bin"
                                       , x.vi_acq_workst_bin         as "acq_workst_bin"
                                       , x.vi_chargeback_ref_num     as "chargeback_ref_num"
                                       , x.vi_docum_ind              as "docum_ind"
                                       , x.vi_member_msg_text        as "member_msg_text"
                                       , x.vi_spec_cond_ind          as "spec_cond_ind"
                                       , x.vi_fee_program_ind        as "fee_program_ind"
                                       , x.vi_issuer_charge          as "issuer_charge"
                                       , x.vi_merchant_number        as "merchant_number"
                                       , x.vi_terminal_number        as "terminal_number"
                                       , x.vi_national_reimb_fee     as "national_reimb_fee"
                                       , x.vi_electr_comm_ind        as "electr_comm_ind"
                                       , x.vi_spec_chargeback_ind    as "spec_chargeback_ind"
                                       , x.vi_interface_trace_num    as "interface_trace_num"
                                       , x.vi_unatt_accept_term_ind  as "unatt_accept_term_ind"
                                       , x.vi_prepaid_card_ind       as "prepaid_card_ind"
                                       , x.vi_service_development    as "service_development"
                                       , x.vi_avs_resp_code          as "avs_resp_code"
                                       , x.vi_auth_source_code       as "auth_source_code"
                                       , x.vi_purch_id_format        as "purch_id_format"
                                       , x.vi_account_selection      as "account_selection"
                                       , x.vi_installment_pay_count  as "installment_pay_count"
                                       , x.vi_purch_id               as "purch_id"
                                       , x.vi_cashback               as "cashback"
                                       , x.vi_chip_cond_code         as "chip_cond_code"
                                       , x.vi_pos_environment        as "pos_environment"
                                       , x.vi_transaction_type       as "transaction_type"
                                       , x.vi_card_seq_number        as "card_seq_number"
                                       , x.vi_terminal_profile       as "terminal_profile"
                                       , x.vi_unpredict_number       as "unpredict_number"
                                       , x.vi_appl_trans_counter     as "appl_trans_counter"
                                       , x.vi_appl_interch_profile   as "appl_interch_profile"
                                       , x.vi_cryptogram             as "cryptogram"
                                       , x.vi_term_verif_result      as "term_verif_result"
                                       , x.vi_cryptogram_amount      as "cryptogram_amount"
                                       , x.vi_card_verif_result      as "card_verif_result"
                                       , x.vi_issuer_appl_data       as "issuer_appl_data"
                                       , x.vi_issuer_script_result   as "issuer_script_result"
                                       , x.vi_card_expir_date        as "card_expir_date"
                                       , x.vi_cryptogram_version     as "cryptogram_version"
                                       , x.vi_cvv2_result_code       as "cvv2_result_code"
                                       , x.vi_auth_resp_code         as "auth_resp_code"
                                       , x.vi_cryptogram_info_data   as "cryptogram_info_data"
                                       , x.vi_transaction_id         as "transaction_id"
                                       , x.vi_merchant_verif_value   as "merchant_verif_value"
                                       , x.vi_proc_bin               as "proc_bin"
                                       , x.vi_chargeback_reason_code as "chargeback_reason_code"
                                       , x.vi_destination_channel    as "destination_channel"
                                       , x.vi_source_channel         as "source_channel"
                                       , x.vi_acq_inst_bin           as "acq_inst_bin"
                                       , x.vi_spend_qualified_ind    as "spend_qualified_ind"
                                       , x.vi_service_code           as "service_code"
                                     ) as "baseII_data" -- xmlforest
                                 ) -- xmlforest
                            end
                            --
                          , (select xmlagg(
                                        xmlelement("additional_amount"
                                          , xmlelement("amount_value", a.amount)
                                          , xmlelement("currency",     a.currency)
                                          , xmlelement("amount_type",  a.amount_type)
                                        )
                                    )
                               from opr_additional_amount a
                              where a.oper_id = x.id
                                and a.amount is not null
                            ) as additional_amount
                        ) -- xmlelement("operation"
                    ) -- xmlagg (for <operation>)
                ).getClobVal()  xml_file
            from (
                select
                    o.id
                    , o.oper_type
                    , o.msg_type
                    , o.sttl_type
                    , o.oper_date
                    , o.host_date
                    , o.oper_count
                    , o.oper_amount
                    , o.oper_currency
                    , o.oper_request_amount
                    , o.oper_surcharge_amount
                    , o.oper_cashback_amount
                    , o.sttl_amount
                    , o.sttl_currency
                    , o.fee_amount
                    , o.fee_currency  
                    , o.originator_refnum
                    , o.network_refnum
                    , o.acq_inst_bin
                    , case o.status_reason
                          when aut_api_const_pkg.AUTH_REASON_DUE_TO_RESP_CODE   then t.resp_code
                          when aut_api_const_pkg.AUTH_REASON_DUE_TO_COMPLT_FLAG then t.is_completed
                                                                                else o.status_reason
                      end as status_reason
                    , o.oper_reason
                    , o.status
                    , o.is_reversal
                    , o.merchant_number
                    , o.mcc
                    , o.merchant_name
                    , o.merchant_street
                    , o.merchant_city
                    , o.merchant_region
                    , o.merchant_country
                    , o.merchant_postcode
                    , case o.terminal_type
                          when acq_api_const_pkg.TERMINAL_TYPE_MOBILE_POS
                          then acq_api_const_pkg.TERMINAL_TYPE_POS
                          else o.terminal_type
                      end as terminal_type
                    , case when length(o.terminal_number) >= 8 
                          then substr(o.terminal_number, -8)
                          else o.terminal_number
                      end as terminal_number
                    , o.payment_order_id
                    , decode(l_split_files, com_api_const_pkg.TRUE, o.incom_sess_file_id, null) as incom_sess_file_id
                    , o.sttl_date as sttl_date                     
                    , t.id as au_id
                    , t.resp_code as au_resp_code
                    , t.proc_type as au_proc_type
                    , t.proc_mode as au_proc_mode
                    , t.is_advice as au_is_advice
                    , t.is_repeat as au_is_repeat
                    , t.bin_amount as au_bin_amount
                    , t.bin_currency as au_bin_currency
                    , t.bin_cnvt_rate as au_bin_cnvt_rate
                    , t.network_amount as au_network_amount
                    , t.network_currency as au_network_currency
                    , t.network_cnvt_date as au_network_cnvt_date
                    , t.network_cnvt_rate as au_network_cnvt_rate
                    , t.account_cnvt_rate as au_account_cnvt_rate
                    , t.parent_id as au_parent_id
                    , t.addr_verif_result as au_addr_verif_result
                    , t.iss_network_device_id as au_iss_network_device_id
                    , t.acq_device_id as au_acq_device_id
                    , t.acq_resp_code as au_acq_resp_code
                    , t.acq_device_proc_result as au_acq_device_proc_result
                    , t.cat_level as au_cat_level
                    , t.card_data_input_cap as au_card_data_input_cap
                    , t.crdh_auth_cap as au_crdh_auth_cap
                    , t.card_capture_cap as au_card_capture_cap
                    , t.terminal_operating_env as au_terminal_operating_env
                    , t.crdh_presence as au_crdh_presence
                    , t.card_presence as au_card_presence
                    , t.card_data_input_mode as au_card_data_input_mode
                    , t.crdh_auth_method as au_crdh_auth_method
                    , t.crdh_auth_entity as au_crdh_auth_entity
                    , t.card_data_output_cap as au_card_data_output_cap
                    , t.terminal_output_cap as au_terminal_output_cap
                    , t.pin_capture_cap as au_pin_capture_cap
                    , t.pin_presence as au_pin_presence
                    , t.cvv2_presence as au_cvv2_presence
                    , t.cvc_indicator as au_cvc_indicator
                    , t.pos_entry_mode as au_pos_entry_mode
                    , t.pos_cond_code as au_pos_cond_code
                    , t.emv_data as au_emv_data
                    , t.atc as au_atc
                    , t.tvr as au_tvr
                    , t.cvr as au_cvr
                    , t.addl_data as au_addl_data
                    , t.service_code as au_service_code
                    , t.device_date as au_device_date
                    , t.cvv2_result as au_cvv2_result
                    , t.certificate_method as au_certificate_method
                    , t.certificate_type as au_certificate_type
                    , t.merchant_certif as au_merchant_certif
                    , t.cardholder_certif as au_cardholder_certif
                    , t.ucaf_indicator as au_ucaf_indicator
                    , t.is_early_emv as au_is_early_emv
                    , t.is_completed as au_is_completed
                    , t.amounts as au_amounts
                    , t.agent_unique_id as au_agent_unique_id
                    , t.external_auth_id as external_auth_id
                    , t.external_orig_id as external_orig_id
                    , t.auth_purpose_id  as auth_purpose_id
                    , m.id as mc_id
                    , m.is_incoming as mc_is_incoming
                    , m.is_reversal as mc_is_reversal
                    , m.is_rejected as mc_is_rejected
                    , m.impact as mc_impact
                    , m.mti as mc_mti
                    , m.de024 as mc_de024
                    , m.de002 as mc_de002
                    , m.de003_1 as mc_de003_1
                    , m.de003_2 as mc_de003_2
                    , m.de003_3 as mc_de003_3
                    , m.de004 as mc_de004
                    , m.de005 as mc_de005
                    , m.de006 as mc_de006
                    , m.de009 as mc_de009
                    , m.de010 as mc_de010
                    , m.de012 as mc_de012
                    , m.de014 as mc_de014
                    , m.de022_1 as mc_de022_1
                    , m.de022_2 as mc_de022_2
                    , m.de022_3 as mc_de022_3
                    , m.de022_4 as mc_de022_4
                    , m.de022_5 as mc_de022_5
                    , m.de022_6 as mc_de022_6
                    , m.de022_7 as mc_de022_7
                    , m.de022_8 as mc_de022_8
                    , m.de022_9 as mc_de022_9
                    , m.de022_10 as mc_de022_10
                    , m.de022_11 as mc_de022_11
                    , m.de022_12 as mc_de022_12
                    , m.de023 as mc_de023
                    , m.de025 as mc_de025
                    , m.de026 as mc_de026
                    , m.de030_1 as mc_de030_1
                    , m.de030_2 as mc_de030_2
                    , m.de031 as mc_de031
                    , m.de032 as mc_de032
                    , m.de033 as mc_de033
                    , m.de037 as mc_de037
                    , m.de038 as mc_de038
                    , m.de040 as mc_de040
                    , m.de041 as mc_de041
                    , m.de042 as mc_de042
                    , m.de043_1 as mc_de043_1
                    , m.de043_2 as mc_de043_2
                    , m.de043_3 as mc_de043_3
                    , m.de043_4 as mc_de043_4
                    , m.de043_5 as mc_de043_5
                    , m.de043_6 as mc_de043_6
                    , m.de049 as mc_de049
                    , m.de050 as mc_de050
                    , m.de051 as mc_de051
                    , m.de054 as mc_de054
                    , m.de055 as mc_de055
                    , m.de063 as mc_de063
                    , m.de071 as mc_de071
                    , m.de072 as mc_de072
                    , m.de073 as mc_de073
                    , m.de093 as mc_de093
                    , m.de094 as mc_de094
                    , m.de095 as mc_de095
                    , m.de100 as mc_de100
                    , m.de111 as mc_de111
                    , m.p0002 as mc_p0002
                    , m.p0023 as mc_p0023
                    , m.p0025_1 as mc_p0025_1
                    , m.p0025_2 as mc_p0025_2
                    , m.p0043 as mc_p0043
                    , m.p0052 as mc_p0052
                    , m.p0137 as mc_p0137
                    , m.p0148 as mc_p0148
                    , m.p0146 as mc_p0146
                    , m.p0146_net as mc_p0146_net
                    , m.p0147 as mc_p0147
                    , m.p0149_1 as mc_p0149_1
                    , lpad(m.p0149_2, 3, '0') as mc_p0149_2
                    , m.p0158_1 as mc_p0158_1
                    , m.p0158_2 as mc_p0158_2
                    , m.p0158_3 as mc_p0158_3
                    , m.p0158_4 as mc_p0158_4
                    , m.p0158_5 as mc_p0158_5
                    , m.p0158_6 as mc_p0158_6
                    , m.p0158_7 as mc_p0158_7
                    , m.p0158_8 as mc_p0158_8
                    , m.p0158_9 as mc_p0158_9
                    , m.p0158_10 as mc_p0158_10
                    , m.p0159_1 as mc_p0159_1
                    , m.p0159_2 as mc_p0159_2
                    , m.p0159_3 as mc_p0159_3
                    , m.p0159_4 as mc_p0159_4
                    , m.p0159_5 as mc_p0159_5
                    , m.p0159_6 as mc_p0159_6
                    , m.p0159_7 as mc_p0159_7
                    , m.p0159_8 as mc_p0159_8
                    , m.p0159_9 as mc_p0159_9
                    , m.p0165 as mc_p0165
                    , m.p0176 as mc_p0176
                    , m.p0228 as mc_p0228
                    , m.p0230 as mc_p0230
                    , m.p0241 as mc_p0241
                    , m.p0243 as mc_p0243
                    , m.p0244 as mc_p0244
                    , m.p0260 as mc_p0260
                    , m.p0261 as mc_p0261
                    , m.p0262 as mc_p0262
                    , m.p0264 as mc_p0264
                    , m.p0265 as mc_p0265
                    , m.p0266 as mc_p0266
                    , m.p0267 as mc_p0267
                    , m.p0268_1 as mc_p0268_1
                    , m.p0268_2 as mc_p0268_2
                    , m.p0375 as mc_p0375
                    , m.emv_9f26 as mc_emv_9f26
                    , m.emv_9f02 as mc_emv_9f02
                    , m.emv_9f27 as mc_emv_9f27
                    , m.emv_9f10 as mc_emv_9f10
                    , m.emv_9f36 as mc_emv_9f36
                    , m.emv_95 as mc_emv_95
                    , m.emv_82 as mc_emv_82
                    , m.emv_9a as mc_emv_9a
                    , m.emv_9c as mc_emv_9c
                    , m.emv_9f37 as mc_emv_9f37
                    , m.emv_5f2a as mc_emv_5f2a
                    , m.emv_9f33 as mc_emv_9f33
                    , m.emv_9f34 as mc_emv_9f34
                    , m.emv_9f1a as mc_emv_9f1a
                    , m.emv_9f35 as mc_emv_9f35
                    , m.emv_9f53 as mc_emv_9f53
                    , m.emv_84 as mc_emv_84
                    , m.emv_9f09 as mc_emv_9f09
                    , m.emv_9f03 as mc_emv_9f03
                    , m.emv_9f1e as mc_emv_9f1e
                    , m.emv_9f41 as mc_emv_9f41
                    , m.p0042 as mc_p0042
                    , m.p0158_11 as mc_p0158_11
                    , m.p0158_12 as mc_p0158_12
                    , m.p0158_13 as mc_p0158_13
                    , m.p0158_14 as mc_p0158_14
                    , m.p0198 as mc_p0198
                    , m.p0200_1 as mc_p0200_1
                    , m.p0200_2 as mc_p0200_2
                    , m.p0210_1 as mc_p0210_1
                    , m.p0210_2 as mc_p0210_2
                    , v.id as vi_id
                    , v.is_reversal as vi_is_reversal
                    , v.is_incoming as vi_is_incoming
                    , v.is_returned as vi_is_returned
                    , v.is_invalid as vi_is_invalid
                    , v.rrn as vi_rrn
                    , v.trans_code as vi_trans_code
                    , v.trans_code_qualifier as vi_trans_code_qualifier
                    , v.card_mask as vi_card_mask
                    , v.oper_amount as vi_oper_amount
                    , v.oper_currency as vi_oper_currency
                    , v.oper_date as vi_oper_date
                    , v.sttl_amount as vi_sttl_amount
                    , v.sttl_currency as vi_sttl_currency
                    , v.network_amount as vi_network_amount
                    , v.network_currency as vi_network_currency
                    , v.floor_limit_ind as vi_floor_limit_ind
                    , v.exept_file_ind as vi_exept_file_ind
                    , v.pcas_ind as vi_pcas_ind
                    , v.arn as vi_arn
                    , v.acquirer_bin as vi_acquirer_bin
                    , v.acq_business_id as vi_acq_business_id
                    , v.merchant_name as vi_merchant_name
                    , v.merchant_city as vi_merchant_city
                    , v.merchant_country as vi_merchant_country
                    , v.merchant_postal_code as vi_merchant_postal_code
                    , v.merchant_region as vi_merchant_region
                    , v.merchant_street as vi_merchant_street
                    , v.mcc as vi_mcc
                    , v.req_pay_service as vi_req_pay_service
                    , v.usage_code as vi_usage_code
                    , v.reason_code as vi_reason_code
                    , v.settlement_flag as vi_settlement_flag
                    , v.auth_char_ind as vi_auth_char_ind
                    , v.auth_code as vi_auth_code
                    , v.pos_terminal_cap as vi_pos_terminal_cap
                    , v.inter_fee_ind as vi_inter_fee_ind
                    , v.crdh_id_method as vi_crdh_id_method
                    , v.collect_only_flag as vi_collect_only_flag
                    , v.pos_entry_mode as vi_pos_entry_mode
                    , v.central_proc_date as vi_central_proc_date
                    , v.reimburst_attr as vi_reimburst_attr
                    , v.iss_workst_bin as vi_iss_workst_bin
                    , v.acq_workst_bin as vi_acq_workst_bin
                    , v.chargeback_ref_num as vi_chargeback_ref_num
                    , v.docum_ind as vi_docum_ind
                    , v.member_msg_text as vi_member_msg_text
                    , v.spec_cond_ind as vi_spec_cond_ind
                    , v.fee_program_ind as vi_fee_program_ind
                    , v.issuer_charge as vi_issuer_charge
                    , v.merchant_number as vi_merchant_number
                    , v.terminal_number as vi_terminal_number
                    , v.national_reimb_fee as vi_national_reimb_fee
                    , v.electr_comm_ind as vi_electr_comm_ind
                    , v.spec_chargeback_ind as vi_spec_chargeback_ind
                    , v.interface_trace_num as vi_interface_trace_num
                    , v.unatt_accept_term_ind as vi_unatt_accept_term_ind
                    , v.prepaid_card_ind as vi_prepaid_card_ind
                    , v.service_development as vi_service_development
                    , v.avs_resp_code as vi_avs_resp_code
                    , v.auth_source_code as vi_auth_source_code
                    , v.purch_id_format as vi_purch_id_format
                    , v.account_selection as vi_account_selection
                    , v.installment_pay_count as vi_installment_pay_count
                    , v.purch_id as vi_purch_id
                    , v.cashback as vi_cashback
                    , v.chip_cond_code as vi_chip_cond_code
                    , v.pos_environment as vi_pos_environment
                    , v.transaction_type as vi_transaction_type
                    , v.card_seq_number as vi_card_seq_number
                    , v.terminal_profile as vi_terminal_profile
                    , v.unpredict_number as vi_unpredict_number
                    , v.appl_trans_counter as vi_appl_trans_counter
                    , v.appl_interch_profile as vi_appl_interch_profile
                    , v.cryptogram as vi_cryptogram
                    , v.term_verif_result as vi_term_verif_result
                    , v.cryptogram_amount as vi_cryptogram_amount
                    , v.card_verif_result as vi_card_verif_result
                    , v.issuer_appl_data as vi_issuer_appl_data
                    , v.issuer_script_result as vi_issuer_script_result
                    , v.card_expir_date as vi_card_expir_date
                    , v.cryptogram_version as vi_cryptogram_version
                    , v.cvv2_result_code as vi_cvv2_result_code
                    , v.auth_resp_code as vi_auth_resp_code
                    , v.cryptogram_info_data as vi_cryptogram_info_data
                    , v.transaction_id as vi_transaction_id
                    , v.merchant_verif_value as vi_merchant_verif_value
                    , v.proc_bin as vi_proc_bin
                    , v.chargeback_reason_code as vi_chargeback_reason_code
                    , v.destination_channel as vi_destination_channel
                    , v.source_channel as vi_source_channel
                    , v.acq_inst_bin as vi_acq_inst_bin
                    , v.spend_qualified_ind as vi_spend_qualified_ind
                    , v.service_code as vi_service_code
                from
                      opr_operation o
                    , aut_auth t
                    , mcw_fin m
                    , vis_fin_message v
                where
                    o.id in (select column_value from table(cast(l_oper_tab as num_tab_tpt)))
                    and t.id(+) = o.id
                    and m.id(+) = o.id
                    and v.id(+) = o.id
            ) x
            group by x.incom_sess_file_id
        )
        loop

            l_incom_sess_file_id := r_xml.incom_sess_file_id;
            l_file               := r_xml.xml_file;

            trc_log_pkg.debug (
                i_text       => 'XML CLOB was successfully created. l_incom_sess_file_id [#1]'
              , i_env_param1 => l_incom_sess_file_id
            );

            if l_incom_sess_file_id is not null then
                select file_name
                  into l_original_file_name
                  from prc_session_file
                 where id = l_incom_sess_file_id;

                rul_api_param_pkg.set_param( 
                    i_name    => 'ORIGINAL_FILE_NAME' 
                  , i_value   => l_original_file_name
                  , io_params => l_params 
                );
            end if;

            prc_api_file_pkg.open_file (
                o_sess_file_id  => l_session_file_id
              , io_params       => l_params
            );

            -- Put file record
            prc_api_file_pkg.put_file (
                i_sess_file_id  => l_session_file_id
              , i_clob_content  => l_file
            );

            trc_log_pkg.debug ('XML was put to the file.');

            prc_api_stat_pkg.log_current (
                i_current_count   => r_xml.current_count
              , i_excepted_count  => 0
            );

            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );

        end loop;  -- Make XML

    end if;  -- if l_estimated_count.count > 0

    -- Mark processed event object
    evt_api_event_pkg.process_event_object (
        i_event_object_id_tab  => l_evt_objects_tab
    );

    trc_log_pkg.debug (
        i_text       => '[#1] event objects marked as PROCESSED.'
      , i_env_param1 => l_evt_objects_tab.count
    );

    trc_log_pkg.debug(LOG_PREFIX || ' was successfully completed.');

    prc_api_stat_pkg.log_end (
        i_result_code => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
exception
    when others then
        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

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
        
end export_clearing_data_10;

procedure export_clearing_data_11(
    i_inst_id                  in     com_api_type_pkg.t_inst_id    default null
  , i_start_date               in     date                          default null
  , i_end_date                 in     date                          default null
  , i_upl_oper_event_type      in     com_api_type_pkg.t_dict_value default null
  , i_terminal_type            in     com_api_type_pkg.t_dict_value default null
  , i_load_state               in     com_api_type_pkg.t_dict_value default null
  , i_load_successfull         in     com_api_type_pkg.t_dict_value default null
  , i_include_auth             in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_include_clearing         in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_masking_card             in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE  
  , i_process_container        in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_session_id               in     com_api_type_pkg.t_long_id    default null
  , i_split_files              in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_reversal_upload_type     in     com_api_type_pkg.t_dict_value default null
  , i_subscriber_name          in     com_api_type_pkg.t_name       default null
) is

    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := $$PLSQL_UNIT || '.EXPORT_CLEARING_DATA_11';
    
begin
    
    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': start'
    );
    
    export_clearing_data_10(
        i_inst_id              =>     i_inst_id
      , i_start_date           =>     i_start_date
      , i_end_date             =>     i_end_date
      , i_upl_oper_event_type  =>     i_upl_oper_event_type
      , i_terminal_type        =>     i_terminal_type
      , i_load_state           =>     i_load_state
      , i_load_successfull     =>     i_load_successfull
      , i_include_auth         =>     i_include_auth
      , i_include_clearing     =>     i_include_clearing
      , i_masking_card         =>     i_masking_card
      , i_process_container    =>     i_process_container
      , i_session_id           =>     i_session_id
      , i_split_files          =>     i_split_files
      , i_reversal_upload_type =>     i_reversal_upload_type
      , i_subscriber_name      =>     i_subscriber_name
    );
    
    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': finish success'
    );
    
end export_clearing_data_11;

procedure export_clearing_data_12(
    i_inst_id                  in     com_api_type_pkg.t_inst_id    default null
  , i_start_date               in     date                          default null
  , i_end_date                 in     date                          default null
  , i_upl_oper_event_type      in     com_api_type_pkg.t_dict_value default null
  , i_terminal_type            in     com_api_type_pkg.t_dict_value default null
  , i_load_state               in     com_api_type_pkg.t_dict_value default null
  , i_load_successfull         in     com_api_type_pkg.t_dict_value default null
  , i_include_auth             in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_include_clearing         in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_masking_card             in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE  
  , i_process_container        in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_session_id               in     com_api_type_pkg.t_long_id    default null
  , i_split_files              in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_reversal_upload_type     in     com_api_type_pkg.t_dict_value default null
  , i_subscriber_name          in     com_api_type_pkg.t_name       default null
) is

    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := $$PLSQL_UNIT || '.EXPORT_CLEARING_DATA_12';
    
begin
    
    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': start'
    );
    
    export_clearing_data_11(
        i_inst_id              =>     i_inst_id
      , i_start_date           =>     i_start_date
      , i_end_date             =>     i_end_date
      , i_upl_oper_event_type  =>     i_upl_oper_event_type
      , i_terminal_type        =>     i_terminal_type
      , i_load_state           =>     i_load_state
      , i_load_successfull     =>     i_load_successfull
      , i_include_auth         =>     i_include_auth
      , i_include_clearing     =>     i_include_clearing
      , i_masking_card         =>     i_masking_card
      , i_process_container    =>     i_process_container
      , i_session_id           =>     i_session_id
      , i_split_files          =>     i_split_files
      , i_reversal_upload_type =>     i_reversal_upload_type
      , i_subscriber_name      =>     i_subscriber_name
    );
    
    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': finish success'
    );
    
end export_clearing_data_12;

procedure export_clearing_data_13(
    i_inst_id                  in     com_api_type_pkg.t_inst_id    default null
  , i_start_date               in     date                          default null
  , i_end_date                 in     date                          default null
  , i_upl_oper_event_type      in     com_api_type_pkg.t_dict_value default null
  , i_terminal_type            in     com_api_type_pkg.t_dict_value default null
  , i_load_state               in     com_api_type_pkg.t_dict_value default null
  , i_load_successfull         in     com_api_type_pkg.t_dict_value default null
  , i_include_auth             in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_include_clearing         in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_masking_card             in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE  
  , i_process_container        in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_session_id               in     com_api_type_pkg.t_long_id    default null
  , i_split_files              in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_reversal_upload_type     in     com_api_type_pkg.t_dict_value default null
  , i_subscriber_name          in     com_api_type_pkg.t_name       default null
) is
    DEFAULT_PROCEDURE_NAME     constant com_api_type_pkg.t_name := $$PLSQL_UNIT || '.EXPORT_CLEARING_DATA_13';
    LOG_PREFIX                 constant com_api_type_pkg.t_name := DEFAULT_PROCEDURE_NAME;
    DATETIME_FORMAT            constant com_api_type_pkg.t_name := 'dd.mm.yyyy hh24:mi:ss';

    l_session_file_id           com_api_type_pkg.t_long_id;
    l_file                      clob;
    l_subscriber_name           com_api_type_pkg.t_name         := upper(nvl(i_subscriber_name, DEFAULT_PROCEDURE_NAME));
    l_sysdate                   date;
    l_params                    com_api_type_pkg.t_param_tab;
    l_lang                      com_api_type_pkg.t_dict_value;
    l_min_date                  date;
    l_max_date                  date;
    l_load_events_with_status   com_api_type_pkg.t_dict_value;
    l_load_successfull          com_api_type_pkg.t_dict_value;
    l_include_auth              com_api_type_pkg.t_boolean;
    l_include_clearing          com_api_type_pkg.t_boolean;
    l_evt_objects_tab           num_tab_tpt := num_tab_tpt();
    l_oper_ids_tab              num_tab_tpt := num_tab_tpt();
    l_oper_tab                  num_tab_tpt := num_tab_tpt();
    l_estimated_count           com_api_type_pkg.t_long_id      := 0;
    l_session_id_tab            num_tab_tpt := num_tab_tpt();
    l_process_session_id        com_api_type_pkg.t_long_id;
    l_use_session_id            com_api_type_pkg.t_boolean      := com_api_const_pkg.FALSE;
    l_incom_sess_file_id_tab    num_tab_tpt := num_tab_tpt();
    l_incom_sess_file_id        com_api_type_pkg.t_long_id;
    l_original_file_name        com_api_type_pkg.t_name;
    l_split_files               com_api_type_pkg.t_boolean      := com_api_const_pkg.FALSE;
    l_reversal_upload_type      com_api_type_pkg.t_dict_value;
    
begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug (
        i_text       => LOG_PREFIX || ': inst_id [' || nvl(to_char(i_inst_id), 'NULL') ||
                        '], upl_oper_event_type [' || nvl(i_upl_oper_event_type, 'NULL') || '], ' ||
                        'terminal_type [#1], start_date [#2], end_date [#3], already_loaded [#4], reversal_upload_type [#5], ' ||
                        'load_successfull [#6], ' ||
                        'include_auth [' ||
                        case i_include_auth when 0 then 'no' when 1 then 'yes' else to_char(i_include_auth) end || '], ' ||
                        'include_clearing [' ||
                        case i_include_clearing when 0 then 'no' when 1 then 'yes' else to_char(i_include_clearing) end || ']'
      , i_env_param1 => i_terminal_type
      , i_env_param2 => to_char(i_start_date, DATETIME_FORMAT)
      , i_env_param3 => to_char(i_end_date, DATETIME_FORMAT)
      , i_env_param4 => i_load_state
      , i_env_param5 => i_reversal_upload_type
      , i_env_param6 => i_load_successfull
    );

    trc_log_pkg.debug (
        i_text       => LOG_PREFIX || ': i_process_container [#1] i_session_id [#2] i_split_files [#3]'
      , i_env_param1 => i_process_container
      , i_env_param2 => i_session_id
      , i_env_param3 => i_split_files
    );

    l_sysdate := get_sysdate();
    l_lang := get_user_lang();
    trc_log_pkg.debug (
        i_text       => 'sysdate [#1], user_lang [#2]'
      , i_env_param1 => to_char(l_sysdate, DATETIME_FORMAT)
      , i_env_param2 => l_lang
    );

    -- Set default values for parameters
    l_load_events_with_status := nvl(i_load_state, evt_api_const_pkg.EVENT_OBJ_LOAD_ST_NOT_LOADED);
    l_load_successfull := nvl(i_load_successfull, opr_api_const_pkg.UNLOADING_OPER_STATUS_ALL);
    l_include_auth := nvl(i_include_auth, com_api_const_pkg.TRUE);
    l_include_clearing := nvl(i_include_clearing, com_api_const_pkg.TRUE);
    l_reversal_upload_type := nvl(i_reversal_upload_type, opr_api_const_pkg.REVERSAL_UPLOAD_ALL);

    -- Check for the case when end date less than start date
    if nvl(i_end_date, date '9999-12-31') < nvl(i_start_date, date '0001-01-01') then
        com_api_error_pkg.raise_error (
            i_error      => 'END_DATE_LESS_THAN_START_DATE'
          , i_env_param1 => com_api_type_pkg.convert_to_char(i_end_date)
          , i_env_param2 => com_api_type_pkg.convert_to_char(i_start_date)
        );
    end if;

    l_min_date := nvl(i_start_date, date '0001-01-01');
    l_max_date := nvl(i_end_date, trunc(get_sysdate) + 1 - com_api_const_pkg.ONE_SECOND);

    trc_log_pkg.debug (
        i_text       => 'min_date [#1], max_date [#2]'
      , i_env_param1 => to_char(l_min_date, DATETIME_FORMAT)
      , i_env_param2 => to_char(l_max_date, DATETIME_FORMAT)
    );

    -- Get session list
    l_process_session_id := get_session_id;
    if nvl(i_process_container, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE and i_session_id is not null then
        select id
          bulk collect into l_session_id_tab
          from prc_session
          connect by parent_id = prior id
          start with id        = i_session_id
        intersect
          select id
            from prc_session
            start with id = (
                               select max(id) keep (dense_rank last order by level)
                                 from prc_session
                                 start with id = l_process_session_id
                                 connect by id = prior parent_id
                            )
            connect by prior id = parent_id;

    elsif nvl(i_process_container, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
          select id
            bulk collect into l_session_id_tab
            from prc_session
            start with id = (
                               select max(id) keep (dense_rank last order by level)
                                 from prc_session
                                 start with id = l_process_session_id
                                 connect by id = prior parent_id
                            )
            connect by prior id = parent_id;

    elsif i_session_id is not null then
        select id
          bulk collect into l_session_id_tab
          from prc_session
          connect by parent_id = prior id
          start with id        = i_session_id;

    end if;

    if l_session_id_tab.count > 0 then
      l_use_session_id := com_api_const_pkg.TRUE;
    end if;

    trc_log_pkg.debug (
        i_text       => 'l_use_session_id [#1] l_session_id_tab.count [#2]'
      , i_env_param1 => l_use_session_id
      , i_env_param2 => l_session_id_tab.count
    );

    if i_split_files = com_api_const_pkg.TRUE and l_use_session_id = com_api_const_pkg.TRUE then
        l_split_files := com_api_const_pkg.TRUE;
    end if;

    -- Get session list for incoming files
    if l_split_files = com_api_const_pkg.TRUE then
        select s.id
          bulk collect into l_incom_sess_file_id_tab
          from prc_session_file s
             , prc_file_attribute a
             , prc_file f
         where s.session_id in (
                                   select column_value
                                     from table(cast(l_session_id_tab as num_tab_tpt))
                               )
           and s.file_attr_id   = a.id
           and f.id             = a.file_id
           and f.file_purpose   = prc_api_const_pkg.FILE_PURPOSE_IN
           and f.file_type      = opr_api_const_pkg.FILE_TYPE_LOADING;

    end if;

    trc_log_pkg.debug (
        i_text       => 'l_split_files [#1] l_incom_sess_file_id_tab.count [#2]'
      , i_env_param1 => l_split_files
      , i_env_param2 => l_incom_sess_file_id_tab.count
    );

    -- Select IDs of all event objects need to proceed
    select
        v.id                 as evt_id
      , v.object_id          as evt_obj_id
    bulk collect into
        l_evt_objects_tab
      , l_oper_ids_tab
    from
        (
            select eo.entity_type, eo.object_id, eo.inst_id, eo.eff_date, eo.event_id, eo.id, eo.split_hash
              from evt_event_object eo
             where l_load_events_with_status = evt_api_const_pkg.EVENT_OBJ_LOAD_ST_NOT_LOADED
               and decode(eo.status, 'EVST0001', eo.procedure_name, null) = l_subscriber_name
               and eo.split_hash in (select split_hash from com_api_split_map_vw)
            union all
            select eo.entity_type, eo.object_id, eo.inst_id, eo.eff_date, eo.event_id, eo.id, eo.split_hash
              from evt_event_object eo
             where eo.split_hash in (select split_hash from com_api_split_map_vw)
               and ((l_load_events_with_status = evt_api_const_pkg.EVENT_OBJ_LOAD_ST_ALL          
                       and (decode(eo.status, 'EVST0001', eo.procedure_name, null) = l_subscriber_name 
                            or decode(eo.status, 'EVST0002', eo.procedure_name, null) = l_subscriber_name
                       )
                   )
                   or (l_load_events_with_status = evt_api_const_pkg.EVENT_OBJ_LOAD_ST_ALREADY_LOAD
                       and decode(eo.status, 'EVST0002', eo.procedure_name, null) = l_subscriber_name
                   )
               )
        ) v
      , evt_event e
      , opr_operation o
      , aut_auth a
    where
        e.id = v.event_id
        and v.eff_date <= l_sysdate
        and (v.inst_id = i_inst_id
            or i_inst_id is null
            or i_inst_id = ost_api_const_pkg.DEFAULT_INST
        )
        and (o.terminal_type = i_terminal_type
            or i_terminal_type is null
        )
        and (e.event_type = i_upl_oper_event_type
            or i_upl_oper_event_type is null
        )
        and v.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
        and o.id    = v.object_id
        and o.host_date between l_min_date and l_max_date
        and a.id(+) = o.id
        and (l_load_successfull != opr_api_const_pkg.UNLOADING_OPER_STATUS_SUCCESS or o.status in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES))
        and (l_load_successfull != opr_api_const_pkg.UNLOADING_OPER_STATUS_DECLINE or o.status not in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES))
        and (l_load_successfull != opr_api_const_pkg.UNLOADING_OPER_STATUS_SUCCESS or a.resp_code is null or a.resp_code = aup_api_const_pkg.RESP_CODE_OK)
        and (l_load_successfull != opr_api_const_pkg.UNLOADING_OPER_STATUS_DECLINE or a.resp_code is null or a.resp_code <> aup_api_const_pkg.RESP_CODE_OK)
        and (o.is_reversal = com_api_const_pkg.FALSE or l_reversal_upload_type in (opr_api_const_pkg.REVERSAL_UPLOAD_ALL, opr_api_const_pkg.REVERSAL_UPLOAD_WITHOUT_MERGED))
        and (l_use_session_id = com_api_const_pkg.FALSE
             or (l_use_session_id = com_api_const_pkg.TRUE
                 and o.session_id in (select column_value from table(cast(l_session_id_tab as num_tab_tpt)))
             )
        )
        and (l_split_files = com_api_const_pkg.FALSE
             or (l_split_files = com_api_const_pkg.TRUE
                 and o.incom_sess_file_id in (select column_value from table(cast(l_incom_sess_file_id_tab as num_tab_tpt)))
             )
        )
        and (case
                 when l_reversal_upload_type = opr_api_const_pkg.REVERSAL_UPLOAD_ALL
                    or (l_reversal_upload_type = opr_api_const_pkg.REVERSAL_UPLOAD_ORIGINAL
                        and o.is_reversal = com_api_const_pkg.FALSE)
                 then com_api_const_pkg.FALSE

                 when l_reversal_upload_type = opr_api_const_pkg.REVERSAL_UPLOAD_WITHOUT_MERGED
                      and o.is_reversal = com_api_const_pkg.TRUE
                      and o.status in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES)
                 then (
                          select nvl(max(com_api_const_pkg.TRUE), com_api_const_pkg.FALSE)
                            from opr_operation orig, evt_event_object eo_orig, evt_event ev_orig
                           where orig.id                = o.original_id
                             and orig.is_reversal       = com_api_const_pkg.FALSE
                             and (l_load_successfull   != opr_api_const_pkg.UNLOADING_OPER_STATUS_SUCCESS or orig.status in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES))
                             and (l_load_successfull   != opr_api_const_pkg.UNLOADING_OPER_STATUS_DECLINE or orig.status not in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES))
                             and (orig.oper_amount - o.oper_amount) = 0
                             and o.oper_currency        = orig.oper_currency
                             and eo_orig.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                             and eo_orig.object_id      = orig.id
                             and eo_orig.split_hash     = v.split_hash
                             and eo_orig.procedure_name = l_subscriber_name
                             and (
                                   ( eo_orig.status  = evt_api_const_pkg.EVENT_STATUS_READY
                                     and l_load_events_with_status in (evt_api_const_pkg.EVENT_OBJ_LOAD_ST_NOT_LOADED, evt_api_const_pkg.EVENT_OBJ_LOAD_ST_ALL)
                                   )
                                   or
                                   ( eo_orig.status  = evt_api_const_pkg.EVENT_STATUS_PROCESSED
                                     and l_load_events_with_status in (evt_api_const_pkg.EVENT_OBJ_LOAD_ST_ALREADY_LOAD, evt_api_const_pkg.EVENT_OBJ_LOAD_ST_ALL)
                                   )
                             )
                             and ev_orig.id          = eo_orig.event_id
                             and (ev_orig.event_type = i_upl_oper_event_type or i_upl_oper_event_type is null)
                 )

                 when l_reversal_upload_type = opr_api_const_pkg.REVERSAL_UPLOAD_WITHOUT_MERGED
                      and o.is_reversal = com_api_const_pkg.FALSE
                 then (
                          select nvl(max(com_api_const_pkg.TRUE), com_api_const_pkg.FALSE)
                            from opr_operation rev, evt_event_object eo_rev, evt_event ev_rev
                           where rev.original_id       = o.id
                             and rev.is_reversal       = com_api_const_pkg.TRUE
                             and rev.status in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES)
                             and (rev.oper_amount - o.oper_amount) = 0
                             and o.oper_currency       = rev.oper_currency
                             and eo_rev.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                             and eo_rev.object_id      = rev.id
                             and eo_rev.split_hash     = v.split_hash
                             and eo_rev.procedure_name = l_subscriber_name
                             and (
                                   ( eo_rev.status  = evt_api_const_pkg.EVENT_STATUS_READY
                                     and l_load_events_with_status in (evt_api_const_pkg.EVENT_OBJ_LOAD_ST_NOT_LOADED, evt_api_const_pkg.EVENT_OBJ_LOAD_ST_ALL)
                                   )
                                   or
                                   ( eo_rev.status  = evt_api_const_pkg.EVENT_STATUS_PROCESSED
                                     and l_load_events_with_status in (evt_api_const_pkg.EVENT_OBJ_LOAD_ST_ALREADY_LOAD, evt_api_const_pkg.EVENT_OBJ_LOAD_ST_ALL)
                                   )
                             )
                             and ev_rev.id          = eo_rev.event_id
                             and (ev_rev.event_type = i_upl_oper_event_type or i_upl_oper_event_type is null)
                 )

                 else com_api_const_pkg.FALSE
             end
        ) = com_api_const_pkg.FALSE;

    -- Decrease operation count
    select distinct column_value
      bulk collect into l_oper_tab
      from table(cast(l_oper_ids_tab as num_tab_tpt));

    -- Get estimated count
    l_estimated_count := l_oper_tab.count;

    trc_log_pkg.debug (
        i_text       => 'Operations to go count: [#1]'
      , i_env_param1 => l_estimated_count
    );

    prc_api_stat_pkg.log_estimation (
        i_estimated_count => l_estimated_count
    );

    if l_estimated_count > 0 then
        -- Preparing for passing into <prc_api_file_pkg.open_file> Id of the institute
        l_params:= evt_api_shared_data_pkg.g_params;
        rul_api_param_pkg.set_param (
            i_name    => 'INST_ID'
          , i_value   => i_inst_id
          , io_params => l_params
        );


        for r_xml in (
            -- Make XML
            select
                x.incom_sess_file_id
              , count(distinct x.id) as current_count
              , com_api_const_pkg.XML_HEADER ||
                xmlelement("clearing"
                  , xmlattributes('http://bpc.ru/sv/SVXP/clearing' as "xmlns")
                  , xmlforest(
                        to_char(l_session_file_id, 'TM9')                                   as "file_id"
                      , opr_api_const_pkg.FILE_TYPE_UNLOADING                               as "file_type"
                      , to_char(i_start_date, com_api_const_pkg.XML_DATE_FORMAT)            as "start_date"
                      , to_char(i_end_date, com_api_const_pkg.XML_DATE_FORMAT)              as "end_date"
                      , i_inst_id                                                           as "inst_id"
                    )
                  , xmlagg(
                        xmlelement("operation"
                          , xmlforest(
                                to_char(x.id, com_api_const_pkg.XML_NUMBER_FORMAT)          as "oper_id"
                              , x.oper_type                                                 as "oper_type"
                              , x.msg_type                                                  as "msg_type"
                              , x.sttl_type                                                 as "sttl_type"
                              , to_char(x.oper_date, com_api_const_pkg.XML_DATETIME_FORMAT) as "oper_date"
                              , to_char(x.host_date, com_api_const_pkg.XML_DATETIME_FORMAT) as "host_date"
                              , to_char(x.oper_count, com_api_const_pkg.XML_NUMBER_FORMAT)  as "oper_count"
                              , case when x.oper_amount is not null then
                                     xmlforest(
                                         x.oper_amount           as "amount_value"
                                       , x.oper_currency         as "currency"
                                     )
                                end                                                         as "oper_amount"
                              , case when x.oper_request_amount is not null then
                                     xmlforest(
                                         x.oper_request_amount   as "amount_value"
                                       , x.oper_currency         as "currency"
                                     )
                                end                                                         as "oper_request_amount"
                              , case when x.oper_surcharge_amount is not null then
                                     xmlforest(
                                         x.oper_surcharge_amount as "amount_value"
                                       , x.oper_currency         as "currency"
                                     )
                                end                                                         as "oper_surcharge_amount"
                              , case when x.oper_cashback_amount is not null then
                                     xmlforest(
                                         x.oper_cashback_amount   as "amount_value"
                                       , x.oper_currency          as "currency"
                                     )
                                end                                                         as "oper_cashback_amount"
                              , case when x.sttl_amount is not null then
                                     xmlforest(
                                         x.sttl_amount            as "amount_value"
                                       , x.sttl_currency          as "currency"
                                     )
                                end                                                         as "sttl_amount"
                              , case when x.fee_amount is not null then
                                     xmlforest(
                                         x.fee_amount            as "amount_value"
                                       , x.fee_currency          as "currency"
                                     )
                                end                                                         as "interchange_fee"
                              , x.originator_refnum                                         as "originator_refnum"
                              , x.network_refnum                                            as "network_refnum"
                              , x.acq_inst_bin                                              as "acq_inst_bin"
                              , x.status_reason                                             as "response_code"
                              , x.oper_reason                                               as "oper_reason"
                              , x.status                                                    as "status"
                              , x.is_reversal                                               as "is_reversal"
                              , x.merchant_number                                           as "merchant_number"
                              , x.mcc                                                       as "mcc"
                              , x.merchant_name                                             as "merchant_name"
                              , x.merchant_street                                           as "merchant_street"
                              , x.merchant_city                                             as "merchant_city"
                              , x.merchant_region                                           as "merchant_region"
                              , x.merchant_country                                          as "merchant_country"
                              , x.merchant_postcode                                         as "merchant_postcode"
                              , x.terminal_type                                             as "terminal_type"
                              , x.terminal_number                                           as "terminal_number"
                              , to_char(x.sttl_date, com_api_const_pkg.XML_DATETIME_FORMAT) as "sttl_date"
                            ) -- xmlforest
                            --
                          , (select
                                 xmlelement("payment_order"
                                   , xmlforest(
                                         po.id                as "payment_order_id"
                                       , po.status            as "payment_order_status"
                                       , po.purpose_id        as "purpose_id"
                                       , pp.purpose_number    as "purpose_number"
                                       , xmlforest(
                                             po.amount            as "amount_value"
                                           , po.currency          as "currency"
                                         ) as "payment_amount"
                                     )
                                   , (select xmlagg(
                                                 xmlelement("payment_parameter"
                                                   , xmlforest(
                                                         xp.param_name    as "payment_parameter_name"
                                                       , xod.param_value  as "payment_parameter_value"
                                                     )
                                                 ) 
                                             )
                                        from pmo_parameter xp
                                        join pmo_order_data xod on xod.param_id = xp.id
                                       where xod.order_id = po.id
                                     ) -- payment_parameter
                                   , (select xmlagg(
                                                 xmlelement("document"
                                                   , d.id                 as "document_id"
                                                   , d.document_type      as "document_type"
                                                   , to_char(d.document_date, com_api_const_pkg.XML_DATETIME_FORMAT) as "document_date"
                                                   , d.document_number    as "document_number"
                                                   , xmlagg(
                                                         case when dc.document_content is not null then
                                                             xmlelement("document_content"
                                                               , xmlforest(
                                                                     dc.content_type                                     as "content_type"
                                                                   , com_api_hash_pkg.base64_encode(dc.document_content) as "content"
                                                                 )
                                                             )
                                                         end
                                                     )
                                                 ) -- document
                                             )
                                        from rpt_document d
                                        left join rpt_document_content dc on dc.document_id = d.id
                                       where d.object_id = po.id
                                         and d.entity_type = pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
                                       group by
                                             d.id
                                           , d.document_type
                                           , d.document_date
                                           , d.document_number
                                     ) -- document
                                 ) -- payment_order
                              from pmo_order po
                              left join pmo_purpose pp on pp.id = po.purpose_id
                             where po.id = x.payment_order_id
                            )
                            --
                          , (select
                                 xmlagg(
                                     xmlelement("transaction"
                                       , xmlelement("transaction_id", ae.transaction_id)
                                       , xmlelement("transaction_type", ae.transaction_type)
                                       , xmlelement("posting_date", to_char(min(ae.posting_date), com_api_const_pkg.XML_DATETIME_FORMAT))
                                       , (select xmlagg(
                                                     xmlelement("debit_entry"
                                                       , xmlelement("entry_id", dae.id)
                                                       , xmlelement("account"
                                                           , xmlelement("account_number", da.account_number)
                                                           , xmlelement("currency", da.currency)
                                                           , xmlelement("agent_number", doa.agent_number)
                                                         )
                                                       , xmlelement("amount"
                                                           , xmlelement("amount_value", dae.amount)
                                                           , xmlelement("currency", dae.currency)
                                                         )
                                                     )
                                                 )
                                            from acc_entry dae
                                            join acc_account da on da.id = dae.account_id
                                            left join ost_agent doa on doa.id = da.agent_id
                                           where dae.transaction_id = ae.transaction_id
                                             and dae.balance_impact = com_api_const_pkg.DEBIT
                                         ) -- debit entry
                                       , (select xmlagg(
                                                     xmlelement("credit_entry"
                                                       , xmlelement("entry_id", cae.id)
                                                       , xmlelement("account"
                                                           , xmlelement("account_number", ca.account_number)
                                                           , xmlelement("currency", ca.currency)
                                                           , xmlelement("agent_number", coa.agent_number)
                                                         )
                                                       , xmlelement("amount"
                                                           , xmlelement("amount_value", cae.amount)
                                                           , xmlelement("currency", cae.currency)
                                                         )
                                                     )
                                                 )
                                            from acc_entry cae
                                            join acc_account ca on ca.id = cae.account_id
                                            left join ost_agent coa on coa.id = ca.agent_id
                                           where cae.transaction_id = ae.transaction_id
                                             and cae.balance_impact = com_api_const_pkg.CREDIT
                                         ) -- credit entry
                                       , (select
                                              xmlagg(
                                                  xmlelement("document"
                                                    , xmlelement("document_id", d.id)
                                                    , xmlelement("document_type", d.document_type)
                                                    , xmlelement("document_date", to_char(d.document_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                                    , xmlelement("document_number", d.document_number)
                                                    , xmlagg(
                                                          xmlelement("document_content"
                                                              , xmlelement("content_type", dc.content_type)
                                                              , xmlelement("content", com_api_hash_pkg.base64_encode(dc.document_content))
                                                          )
                                                      )
                                                  )
                                              )
                                            from rpt_document d
                                            left join rpt_document_content dc on dc.document_id = d.id
                                           where d.object_id = ae.transaction_id
                                             and d.entity_type = acc_api_const_pkg.ENTITY_TYPE_TRANSACTION
                                           group by d.id, d.document_type, d.document_date, d.document_number
                                         ) -- document
                                       , xmlelement("conversion_rate", nvl(am.conversion_rate, 1))
                                       , xmlelement("amount_purpose", am.amount_purpose)
                                     ) -- xmlelement transaction
                                 ) -- xmlagg
                               from acc_macros am
                               join acc_entry ae on ae.macros_id = am.id
                              where am.object_id = x.id -- opr_operation.id
                                and am.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                              group by
                                    ae.transaction_id
                                  , ae.transaction_type
                                  , am.conversion_rate
                                  , am.amount_purpose
                            ) -- transaction
                            --
                          , (select xmlagg(
                                        xmlelement("document"
                                          , xmlelement("document_id", d.id)
                                          , xmlelement("document_type", d.document_type)
                                          , xmlelement("document_date", to_char(d.document_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                          , xmlelement("document_number", d.document_number)
                                          , xmlagg(
                                                case when dc.document_content is not null then
                                                    xmlelement("document_content"
                                                      , xmlelement("content_type", dc.content_type)
                                                      , xmlelement("content", com_api_hash_pkg.base64_encode(dc.document_content))
                                                    )
                                                end
                                            )
                                        )
                                    )
                               from rpt_document d
                               left join rpt_document_content dc on dc.document_id = d.id
                              where d.object_id = x.id
                                and d.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                              group by
                                    d.id
                                  , d.document_type
                                  , d.document_date
                                  , d.document_number
                            ) as document
                            --
                          , (select xmlforest(
                                        xmlforest(
                                            p.client_id_type      as "client_id_type" 
                                          , p.client_id_value     as "client_id_value"
                                          , case nvl(i_masking_card, com_api_const_pkg.TRUE)
                                                when com_api_const_pkg.TRUE
                                                then iss_api_card_pkg.get_card_mask(i_card_number => c.card_number)
                                                else c.card_number
                                            end as "card_number"
                                          , case
                                                when p.card_id is not null
                                                then iss_api_card_instance_pkg.get_card_uid(
                                                         i_card_instance_id => iss_api_card_instance_pkg.get_card_instance_id(
                                                                                   i_card_id => p.card_id
                                                                               )
                                                     )
                                                else null
                                            end                   as "card_id"
                                          , p.card_instance_id    as "card_instance_id"
                                          , p.card_seq_number     as "card_seq_number"
                                          , to_char(p.card_expir_date, com_api_const_pkg.XML_DATE_FORMAT) as "card_expir_date"
                                          , p.card_country        as "card_country"                                      
                                          , p.inst_id             as "inst_id"
                                          , p.network_id          as "network_id"
                                          , p.auth_code           as "auth_code"
                                          , p.account_number      as "account_number"
                                          , p.account_amount      as "account_amount"
                                          , p.account_currency    as "account_currency"
                                        ) as "issuer"
                                    )
                               from opr_participant p
                               left join opr_card c on c.oper_id = p.oper_id
                              where p.oper_id = x.id
                                and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                            ) as issuer
                            --
                          , (select xmlforest(
                                        xmlforest(
                                            p.inst_id             as "inst_id"
                                          , p.network_id          as "network_id"
                                          , p.auth_code           as "auth_code"
                                          , p.account_number      as "account_number"
                                          , p.account_amount      as "account_amount"
                                          , p.account_currency    as "account_currency"
                                        ) as "acquirer"
                                    )
                               from opr_participant p
                              where p.oper_id = x.id
                                and p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                            ) as acquier
                            --
                          , (select xmlforest(
                                        xmlforest(
                                            p.client_id_type          as "client_id_type"
                                          , p.client_id_value         as "client_id_value"
                                          , p.inst_id                 as "inst_id"
                                        ) as "destination"
                                    )
                               from opr_participant p
                              where p.oper_id = x.id
                                and p.participant_type = com_api_const_pkg.PARTICIPANT_DEST
                            ) as destination
                            --
                          , (select xmlforest(
                                        xmlforest(
                                            p.client_id_type          as "client_id_type"
                                          , p.client_id_value         as "client_id_value"
                                          , p.inst_id                 as "inst_id"
                                        ) as "aggregator"
                                    )
                               from opr_participant p
                              where p.oper_id = x.id
                                and p.participant_type = com_api_const_pkg.PARTICIPANT_AGGREGATOR
                            ) as aggregator
                            --
                          , (select xmlforest(
                                        xmlforest(
                                            p.client_id_type          as "client_id_type"
                                          , p.client_id_value         as "client_id_value"
                                          , p.inst_id                 as "inst_id"
                                        ) as "service_provider"
                                    )
                               from opr_participant p
                              where p.oper_id = x.id
                                and p.participant_type = com_api_const_pkg.PARTICIPANT_SERVICE_PROVIDER
                            ) as service_provider
                            --
                          , (select xmlagg(
                                        xmlelement("note"
                                          , xmlelement("note_type", n.note_type)
                                          , xmlagg(
                                                xmlelement("note_content"
                                                  , xmlattributes(l_lang as "language")
                                                  , xmlforest(
                                                        com_api_i18n_pkg.get_text(
                                                            i_table_name  => 'ntb_note'
                                                          , i_column_name => 'header'
                                                          , i_object_id   => n.id
                                                          , i_lang        => l_lang
                                                        ) as "note_header"
                                                      , com_api_i18n_pkg.get_text(
                                                            i_table_name  => 'ntb_note'
                                                          , i_column_name => 'text'
                                                          , i_object_id   => n.id
                                                          , i_lang        => l_lang
                                                        ) as "note_text"
                                                    )
                                                )
                                            )
                                        )
                                    )
                               from ntb_note n
                              where n.object_id = x.id
                                and n.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                              group by
                                    n.note_type
                            ) as note
                            --
                          , case when x.au_id is not null
                                  and nvl(l_include_auth, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE
                                 then
                                     (select
                                          xmlagg(
                                              xmlelement("auth_data"
                                                , xmlforest(
                                                      x.au_resp_code                             as "resp_code"
                                                    , x.au_proc_type                             as "proc_type"
                                                    , x.au_proc_mode                             as "proc_mode"
                                                    , to_char(x.au_is_advice, com_api_const_pkg.XML_NUMBER_FORMAT)           as "is_advice"
                                                    , to_char(x.au_is_repeat, com_api_const_pkg.XML_NUMBER_FORMAT)           as "is_repeat"
                                                    , to_char(x.au_bin_amount, com_api_const_pkg.XML_NUMBER_FORMAT)          as "bin_amount"
                                                    , x.au_bin_currency                          as "bin_currency"
                                                    , to_char(x.au_bin_cnvt_rate, com_api_const_pkg.XML_NUMBER_FORMAT)       as "bin_cnvt_rate"
                                                    , to_char(x.au_network_amount, com_api_const_pkg.XML_NUMBER_FORMAT)      as "network_amount"
                                                    , x.au_network_currency                      as "network_currency"
                                                    , to_char(x.au_network_cnvt_date, com_api_const_pkg.XML_DATETIME_FORMAT) as "network_cnvt_date"
                                                    , to_char(x.au_account_cnvt_rate, com_api_const_pkg.XML_NUMBER_FORMAT)   as "account_cnvt_rate"
                                                    , x.au_addr_verif_result                     as "addr_verif_result"
                                                    , x.au_acq_resp_code                         as "acq_resp_code"
                                                    , x.au_acq_device_proc_result                as "acq_device_proc_result"
                                                    , x.au_cat_level                             as "cat_level"
                                                    , x.au_card_data_input_cap                   as "card_data_input_cap"
                                                    , x.au_crdh_auth_cap                         as "crdh_auth_cap"
                                                    , x.au_card_capture_cap                      as "card_capture_cap"
                                                    , x.au_terminal_operating_env                as "terminal_operating_env"
                                                    , x.au_crdh_presence                         as "crdh_presence"
                                                    , x.au_card_presence                         as "card_presence"
                                                    , x.au_card_data_input_mode                  as "card_data_input_mode"
                                                    , x.au_crdh_auth_method                      as "crdh_auth_method"
                                                    , x.au_crdh_auth_entity                      as "crdh_auth_entity"
                                                    , x.au_card_data_output_cap                  as "card_data_output_cap"
                                                    , x.au_terminal_output_cap                   as "terminal_output_cap"
                                                    , x.au_pin_capture_cap                       as "pin_capture_cap"
                                                    , x.au_pin_presence                          as "pin_presence"
                                                    , x.au_cvv2_presence                         as "cvv2_presence"
                                                    , x.au_cvc_indicator                         as "cvc_indicator"
                                                    , x.au_pos_entry_mode                        as "pos_entry_mode"
                                                    , x.au_pos_cond_code                         as "pos_cond_code"
                                                    , x.au_emv_data                              as "emv_data"
                                                    , x.au_atc                                   as "atc"
                                                    , x.au_tvr                                   as "tvr"
                                                    , x.au_cvr                                   as "cvr"
                                                    , x.au_addl_data                             as "addl_data"
                                                    , x.au_service_code                          as "service_code"
                                                    , x.au_device_date                           as "device_date"
                                                    , x.au_cvv2_result                           as "cvv2_result"
                                                    , x.au_certificate_method                    as "certificate_method"
                                                    , x.au_merchant_certif                       as "merchant_certif"
                                                    , x.au_cardholder_certif                     as "cardholder_certif"
                                                    , x.au_ucaf_indicator                        as "ucaf_indicator"
                                                    , to_char(x.au_is_early_emv, com_api_const_pkg.XML_NUMBER_FORMAT)        as "is_early_emv"
                                                    , x.au_is_completed                          as "is_completed"
                                                    , x.au_amounts                               as "amounts"
                                                    , x.au_agent_unique_id                       as "agent_unique_id"
                                                    , x.external_auth_id                         as "external_auth_id"
                                                    , x.external_orig_id                         as "external_orig_id"
                                                    , x.auth_purpose_id                          as "auth_purpose_id"
                                                  )
                                                , (select
                                                       xmlagg(
                                                           xmlelement("auth_tag"
                                                             , xmlelement("tag_id", t.tag)
                                                             , xmlelement("tag_value", v.tag_value)
                                                             , xmlelement("tag_name", t.reference)
                                                           )
                                                       )
                                                     from
                                                         aup_tag t
                                                       , aup_tag_value v
                                                    where
                                                         v.tag_id  = t.tag and v.auth_id = x.id
                                                  )
                                              )
                                          )
                                       from
                                           dual
                                     )
                            end as auth_data
                            --
                          , case when x.mc_id is not null
                                  and nvl(l_include_clearing, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE
                                 then
                                 xmlforest(
                                     xmlforest(
                                         to_char(x.mc_is_incoming, com_api_const_pkg.XML_NUMBER_FORMAT) as "is_incoming"
                                       , to_char(x.mc_is_reversal, com_api_const_pkg.XML_NUMBER_FORMAT) as "is_reversal"
                                       , to_char(x.mc_is_rejected, com_api_const_pkg.XML_NUMBER_FORMAT) as "is_rejected"
                                       , to_char(x.mc_impact, com_api_const_pkg.XML_NUMBER_FORMAT)      as "impact"
                                       , x.mc_mti              as "mti"
                                       , x.mc_de024            as "de024"
                                       , x.mc_de002            as "de002"
                                       , x.mc_de003_1          as "de003_1"
                                       , x.mc_de003_2          as "de003_2"
                                       , x.mc_de003_3          as "de003_3"
                                       , to_char(x.mc_de004, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de004"
                                       , to_char(x.mc_de005, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de005"
                                       , to_char(x.mc_de006, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de006"
                                       , x.mc_de009            as "de009"
                                       , x.mc_de010            as "de010"
                                       , to_char(x.mc_de012, com_api_const_pkg.XML_DATETIME_FORMAT)     as "de012"
                                       , to_char(x.mc_de014, com_api_const_pkg.XML_DATETIME_FORMAT)     as "de014" 
                                       , x.mc_de022_1          as "de022_1"
                                       , x.mc_de022_2          as "de022_2"
                                       , x.mc_de022_3          as "de022_3"
                                       , x.mc_de022_4          as "de022_4"     
                                       , x.mc_de022_5          as "de022_5"
                                       , x.mc_de022_6          as "de022_6"
                                       , x.mc_de022_7          as "de022_7"
                                       , x.mc_de022_8          as "de022_8"
                                       , x.mc_de022_9          as "de022_9" 
                                       , x.mc_de022_10         as "de022_10"
                                       , x.mc_de022_11         as "de022_11"
                                       , x.mc_de022_12         as "de022_12"
                                       , to_char(x.mc_de023, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de023"
                                       , x.mc_de025            as "de025"
                                       , x.mc_de026            as "de026"
                                       , to_char(x.mc_de030_1, com_api_const_pkg.XML_NUMBER_FORMAT)     as "de030_1"
                                       , to_char(x.mc_de030_2, com_api_const_pkg.XML_NUMBER_FORMAT)     as "de030_2"
                                       , x.mc_de031            as "de031"
                                       , x.mc_de032            as "de032"
                                       , x.mc_de033            as "de033"
                                       , x.mc_de037            as "de037"
                                       , x.mc_de038            as "de038"
                                       , x.mc_de040            as "de040"
                                       , x.mc_de041            as "de041"
                                       , x.mc_de042            as "de042"
                                       , x.mc_de043_1          as "de043_1"
                                       , x.mc_de043_2          as "de043_2"
                                       , x.mc_de043_3          as "de043_3"
                                       , x.mc_de043_4          as "de043_4"
                                       , x.mc_de043_5          as "de043_5"
                                       , x.mc_de043_6          as "de043_6"
                                       , x.mc_de049            as "de049"
                                       , x.mc_de050            as "de050"
                                       , x.mc_de051            as "de051"
                                       , x.mc_de054            as "de054"
                                       , x.mc_de055            as "de055"
                                       , x.mc_de063            as "de063"
                                       , to_char(x.mc_de071, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de071"
                                       , regexp_replace(x.mc_de072, '[[:cntrl:]]', null)                as "de072"
                                       , to_char(x.mc_de073, com_api_const_pkg.XML_DATETIME_FORMAT)     as "de073"
                                       , x.mc_de093            as "de093"
                                       , x.mc_de094            as "de094"
                                       , x.mc_de095            as "de095"
                                       , x.mc_de100            as "de100"
                                       , to_char(x.mc_de111, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de111"
                                       , x.mc_p0002            as "p0002"
                                       , x.mc_p0023            as "p0023"
                                       , x.mc_p0025_1          as "p0025_1"
                                       , to_char(x.mc_p0025_2, com_api_const_pkg.XML_DATETIME_FORMAT)   as "p0025_2"
                                       , x.mc_p0043            as "p0043"
                                       , x.mc_p0052            as "p0052"
                                       , x.mc_p0137            as "p0137"
                                       , x.mc_p0148            as "p0148"
                                       , x.mc_p0146            as "p0146"
                                       , to_char(x.mc_p0146_net, com_api_const_pkg.XML_NUMBER_FORMAT)   as "p0146_net"
                                       , x.mc_p0147            as "p0147"
                                       , x.mc_p0149_1          as "p0149_1"
                                       , x.mc_p0149_2          as "p0149_2"
                                       , x.mc_p0158_1          as "p0158_1"
                                       , x.mc_p0158_2          as "p0158_2"
                                       , x.mc_p0158_3          as "p0158_3"           
                                       , x.mc_p0158_4          as "p0158_4"
                                       , to_char(x.mc_p0158_5, com_api_const_pkg.XML_DATETIME_FORMAT)   as "p0158_5"
                                       , to_char(x.mc_p0158_6, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0158_6"
                                       , x.mc_p0158_7          as "p0158_7"
                                       , x.mc_p0158_8          as "p0158_8"
                                       , x.mc_p0158_9          as "p0158_9"
                                       , x.mc_p0158_10         as "p0158_10"
                                       , x.mc_p0159_1          as "p0159_1"
                                       , x.mc_p0159_2          as "p0159_2"
                                       , to_char(x.mc_p0159_3, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0159_3"
                                       , x.mc_p0159_4          as "p0159_4"
                                       , x.mc_p0159_5          as "p0159_5"
                                       , to_char(x.mc_p0159_6, com_api_const_pkg.XML_DATETIME_FORMAT)   as "p0159_6"
                                       , to_char(x.mc_p0159_7, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0159_7"
                                       , to_char(x.mc_p0159_8, com_api_const_pkg.XML_DATETIME_FORMAT)   as "p0159_8"
                                       , to_char(x.mc_p0159_9, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0159_9"
                                       , x.mc_p0165            as "p0165"
                                       , x.mc_p0176            as "p0176"
                                       , to_char(x.mc_p0228, com_api_const_pkg.XML_NUMBER_FORMAT)       as "p0228" 
                                       , to_char(x.mc_p0230, com_api_const_pkg.XML_NUMBER_FORMAT)       as "p0230"
                                       , x.mc_p0241            as "p0241"
                                       , x.mc_p0243            as "p0243"
                                       , x.mc_p0244            as "p0244"
                                       , x.mc_p0260            as "p0260"
                                       , to_char(x.mc_p0261, com_api_const_pkg.XML_NUMBER_FORMAT)       as "p0261"
                                       , to_char(x.mc_p0262, com_api_const_pkg.XML_NUMBER_FORMAT)       as "p0262"
                                       , to_char(x.mc_p0264, com_api_const_pkg.XML_NUMBER_FORMAT)       as "p0264"
                                       , x.mc_p0265            as "p0265"
                                       , x.mc_p0266            as "p0266"
                                       , x.mc_p0267            as "p0267"
                                       , to_char(x.mc_p0268_1, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0268_1"
                                       , x.mc_p0268_2          as "p0268_2"
                                       , x.mc_p0375            as "p0375"
                                       , x.mc_emv_9f26         as "emv_9f26"
                                       , to_char(x.mc_emv_9f02, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_9f02"
                                       , x.mc_emv_9f27         as "emv_9f27"
                                       , x.mc_emv_9f10         as "emv_9f10"
                                       , x.mc_emv_9f36         as "emv_9f36"
                                       , x.mc_emv_95           as "emv_95"
                                       , x.mc_emv_82           as "emv_82"
                                       , to_char(x.mc_emv_9a, com_api_const_pkg.XML_DATETIME_FORMAT)    as "emv_9a"
                                       , to_char(x.mc_emv_9c, com_api_const_pkg.XML_NUMBER_FORMAT)      as "emv_9c"
                                       , x.mc_emv_9f37         as "emv_9f37"
                                       , to_char(x.mc_emv_5f2a, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_5f2a"
                                       , x.mc_emv_9f33         as "emv_9f33"
                                       , x.mc_emv_9f34         as "emv_9f34"
                                       , to_char(x.mc_emv_9f1a, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_9f1a"
                                       , to_char(x.mc_emv_9f35, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_9f35"
                                       , x.mc_emv_9f53         as "emv_9f53"
                                       , x.mc_emv_84           as "emv_84"
                                       , x.mc_emv_9f09         as "emv_9f09"
                                       , to_char(x.mc_emv_9f03, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_9f03"
                                       , x.mc_emv_9f1e         as "emv_9f1e"
                                       , to_char(x.mc_emv_9f41, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_9f41"
                                       , x.mc_p0042            as "p0042"
                                       , x.mc_p0158_11         as "p0158_11"
                                       , x.mc_p0158_12         as "p0158_12"
                                       , x.mc_p0158_13         as "p0158_13"
                                       , x.mc_p0158_14         as "p0158_14"
                                       , x.mc_p0198            as "p0198"
                                       , to_char(x.mc_p0200_1, com_api_const_pkg.XML_DATETIME_FORMAT)   as "p0200_1"
                                       , to_char(x.mc_p0200_2, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0200_2"
                                       , x.mc_p0210_1          as "p0210_1"
                                       , x.mc_p0210_2          as "p0210_2"                                   
                                     ) as "ipm_data" -- xmlforest
                                 ) -- xmlforest
                            end
                            --
                          , case when x.vi_id is not null
                                  and nvl(l_include_clearing, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE
                                 then
                                 xmlforest(
                                     xmlforest(
                                         to_char(x.vi_is_reversal, com_api_const_pkg.XML_NUMBER_FORMAT)    as "is_reversal"
                                       , to_char(x.vi_is_incoming, com_api_const_pkg.XML_NUMBER_FORMAT)    as "is_incoming"
                                       , to_char(x.vi_is_returned, com_api_const_pkg.XML_NUMBER_FORMAT)    as "is_returned"
                                       , to_char(x.vi_is_invalid, com_api_const_pkg.XML_NUMBER_FORMAT)     as "is_invalid"
                                       , x.vi_rrn                    as "rrn"
                                       , x.vi_trans_code             as "trans_code"
                                       , x.vi_trans_code_qualifier   as "trans_code_qualifier"
                                       , x.vi_card_mask              as "card_mask"
                                       , to_char(x.vi_oper_amount, com_api_const_pkg.XML_NUMBER_FORMAT)    as "oper_amount"
                                       , x.vi_oper_currency          as "oper_currency"
                                       , to_char(x.vi_oper_date, com_api_const_pkg.XML_DATETIME_FORMAT)    as "oper_date"
                                       , to_char(x.vi_sttl_amount, com_api_const_pkg.XML_NUMBER_FORMAT)    as "sttl_amount"
                                       , x.vi_sttl_currency          as "sttl_currency"
                                       , to_char(x.vi_network_amount, com_api_const_pkg.XML_NUMBER_FORMAT) as "network_amount"
                                       , x.vi_network_currency       as "network_currency"
                                       , x.vi_floor_limit_ind        as "floor_limit_ind"
                                       , x.vi_exept_file_ind         as "exept_file_ind"
                                       , x.vi_pcas_ind               as "pcas_ind"
                                       , x.vi_arn                    as "arn"
                                       , x.vi_acquirer_bin           as "acquirer_bin"
                                       , x.vi_acq_business_id        as "acq_business_id"
                                       , x.vi_merchant_name          as "merchant_name"
                                       , x.vi_merchant_city          as "merchant_city"
                                       , x.vi_merchant_country       as "merchant_country"
                                       , x.vi_merchant_postal_code   as "merchant_postal_code"
                                       , x.vi_merchant_region        as "merchant_region"
                                       , x.vi_merchant_street        as "merchant_street"
                                       , x.vi_mcc                    as "mcc"
                                       , x.vi_req_pay_service        as "req_pay_service"
                                       , x.vi_usage_code             as "usage_code"
                                       , x.vi_reason_code            as "reason_code"
                                       , x.vi_settlement_flag        as "settlement_flag"
                                       , x.vi_auth_char_ind          as "auth_char_ind"
                                       , x.vi_auth_code              as "auth_code"
                                       , x.vi_pos_terminal_cap       as "pos_terminal_cap"
                                       , x.vi_inter_fee_ind          as "inter_fee_ind"
                                       , x.vi_crdh_id_method         as "crdh_id_method"
                                       , x.vi_collect_only_flag      as "collect_only_flag"
                                       , x.vi_pos_entry_mode         as "pos_entry_mode"
                                       , x.vi_central_proc_date      as "central_proc_date"
                                       , x.vi_reimburst_attr         as "reimburst_attr"
                                       , x.vi_iss_workst_bin         as "iss_workst_bin"
                                       , x.vi_acq_workst_bin         as "acq_workst_bin"
                                       , x.vi_chargeback_ref_num     as "chargeback_ref_num"
                                       , x.vi_docum_ind              as "docum_ind"
                                       , x.vi_member_msg_text        as "member_msg_text"
                                       , x.vi_spec_cond_ind          as "spec_cond_ind"
                                       , x.vi_fee_program_ind        as "fee_program_ind"
                                       , x.vi_issuer_charge          as "issuer_charge"
                                       , x.vi_merchant_number        as "merchant_number"
                                       , x.vi_terminal_number        as "terminal_number"
                                       , x.vi_national_reimb_fee     as "national_reimb_fee"
                                       , x.vi_electr_comm_ind        as "electr_comm_ind"
                                       , x.vi_spec_chargeback_ind    as "spec_chargeback_ind"
                                       , x.vi_interface_trace_num    as "interface_trace_num"
                                       , x.vi_unatt_accept_term_ind  as "unatt_accept_term_ind"
                                       , x.vi_prepaid_card_ind       as "prepaid_card_ind"
                                       , x.vi_service_development    as "service_development"
                                       , x.vi_avs_resp_code          as "avs_resp_code"
                                       , x.vi_auth_source_code       as "auth_source_code"
                                       , x.vi_purch_id_format        as "purch_id_format"
                                       , x.vi_account_selection      as "account_selection"
                                       , x.vi_installment_pay_count  as "installment_pay_count"
                                       , x.vi_purch_id               as "purch_id"
                                       , x.vi_cashback               as "cashback"
                                       , x.vi_chip_cond_code         as "chip_cond_code"
                                       , x.vi_pos_environment        as "pos_environment"
                                       , x.vi_transaction_type       as "transaction_type"
                                       , x.vi_card_seq_number        as "card_seq_number"
                                       , x.vi_terminal_profile       as "terminal_profile"
                                       , x.vi_unpredict_number       as "unpredict_number"
                                       , x.vi_appl_trans_counter     as "appl_trans_counter"
                                       , x.vi_appl_interch_profile   as "appl_interch_profile"
                                       , x.vi_cryptogram             as "cryptogram"
                                       , x.vi_term_verif_result      as "term_verif_result"
                                       , x.vi_cryptogram_amount      as "cryptogram_amount"
                                       , x.vi_card_verif_result      as "card_verif_result"
                                       , x.vi_issuer_appl_data       as "issuer_appl_data"
                                       , x.vi_issuer_script_result   as "issuer_script_result"
                                       , x.vi_card_expir_date        as "card_expir_date"
                                       , x.vi_cryptogram_version     as "cryptogram_version"
                                       , x.vi_cvv2_result_code       as "cvv2_result_code"
                                       , x.vi_auth_resp_code         as "auth_resp_code"
                                       , x.vi_cryptogram_info_data   as "cryptogram_info_data"
                                       , x.vi_transaction_id         as "transaction_id"
                                       , x.vi_merchant_verif_value   as "merchant_verif_value"
                                       , x.vi_proc_bin               as "proc_bin"
                                       , x.vi_chargeback_reason_code as "chargeback_reason_code"
                                       , x.vi_destination_channel    as "destination_channel"
                                       , x.vi_source_channel         as "source_channel"
                                       , x.vi_acq_inst_bin           as "acq_inst_bin"
                                       , x.vi_spend_qualified_ind    as "spend_qualified_ind"
                                       , x.vi_service_code           as "service_code"
                                     ) as "baseII_data" -- xmlforest
                                 ) -- xmlforest
                            end
                            --
                          , (select xmlagg(
                                        xmlelement("additional_amount"
                                          , xmlelement("amount_value", a.amount)
                                          , xmlelement("currency",     a.currency)
                                          , xmlelement("amount_type",  a.amount_type)
                                        )
                                    )
                               from opr_additional_amount a
                              where a.oper_id = x.id
                                and a.amount is not null
                            ) as additional_amount
                        ) -- xmlelement("operation"
                    ) -- xmlagg (for <operation>)
                ).getClobVal()  xml_file
            from (
                select
                    o.id
                    , o.oper_type
                    , o.msg_type
                    , o.sttl_type
                    , o.oper_date
                    , o.host_date
                    , o.oper_count
                    , o.oper_amount
                    , o.oper_currency
                    , o.oper_request_amount
                    , o.oper_surcharge_amount
                    , o.oper_cashback_amount
                    , o.sttl_amount
                    , o.sttl_currency
                    , o.fee_amount
                    , o.fee_currency  
                    , o.originator_refnum
                    , o.network_refnum
                    , o.acq_inst_bin
                    , case o.status_reason
                          when aut_api_const_pkg.AUTH_REASON_DUE_TO_RESP_CODE   then t.resp_code
                          when aut_api_const_pkg.AUTH_REASON_DUE_TO_COMPLT_FLAG then t.is_completed
                                                                                else o.status_reason
                      end as status_reason
                    , o.oper_reason
                    , o.status
                    , o.is_reversal
                    , o.merchant_number
                    , o.mcc
                    , o.merchant_name
                    , o.merchant_street
                    , o.merchant_city
                    , o.merchant_region
                    , o.merchant_country
                    , o.merchant_postcode
                    , case o.terminal_type
                          when acq_api_const_pkg.TERMINAL_TYPE_MOBILE_POS
                          then acq_api_const_pkg.TERMINAL_TYPE_POS
                          else o.terminal_type
                      end as terminal_type
                    , o.terminal_number
                    , o.payment_order_id
                    , decode(l_split_files, com_api_const_pkg.TRUE, o.incom_sess_file_id, null) as incom_sess_file_id
                    , o.sttl_date as sttl_date                     
                    , t.id as au_id
                    , t.resp_code as au_resp_code
                    , t.proc_type as au_proc_type
                    , t.proc_mode as au_proc_mode
                    , t.is_advice as au_is_advice
                    , t.is_repeat as au_is_repeat
                    , t.bin_amount as au_bin_amount
                    , t.bin_currency as au_bin_currency
                    , t.bin_cnvt_rate as au_bin_cnvt_rate
                    , t.network_amount as au_network_amount
                    , t.network_currency as au_network_currency
                    , t.network_cnvt_date as au_network_cnvt_date
                    , t.network_cnvt_rate as au_network_cnvt_rate
                    , t.account_cnvt_rate as au_account_cnvt_rate
                    , t.parent_id as au_parent_id
                    , t.addr_verif_result as au_addr_verif_result
                    , t.iss_network_device_id as au_iss_network_device_id
                    , t.acq_device_id as au_acq_device_id
                    , t.acq_resp_code as au_acq_resp_code
                    , t.acq_device_proc_result as au_acq_device_proc_result
                    , t.cat_level as au_cat_level
                    , t.card_data_input_cap as au_card_data_input_cap
                    , t.crdh_auth_cap as au_crdh_auth_cap
                    , t.card_capture_cap as au_card_capture_cap
                    , t.terminal_operating_env as au_terminal_operating_env
                    , t.crdh_presence as au_crdh_presence
                    , t.card_presence as au_card_presence
                    , t.card_data_input_mode as au_card_data_input_mode
                    , t.crdh_auth_method as au_crdh_auth_method
                    , t.crdh_auth_entity as au_crdh_auth_entity
                    , t.card_data_output_cap as au_card_data_output_cap
                    , t.terminal_output_cap as au_terminal_output_cap
                    , t.pin_capture_cap as au_pin_capture_cap
                    , t.pin_presence as au_pin_presence
                    , t.cvv2_presence as au_cvv2_presence
                    , t.cvc_indicator as au_cvc_indicator
                    , t.pos_entry_mode as au_pos_entry_mode
                    , t.pos_cond_code as au_pos_cond_code
                    , t.emv_data as au_emv_data
                    , t.atc as au_atc
                    , t.tvr as au_tvr
                    , t.cvr as au_cvr
                    , t.addl_data as au_addl_data
                    , t.service_code as au_service_code
                    , t.device_date as au_device_date
                    , t.cvv2_result as au_cvv2_result
                    , t.certificate_method as au_certificate_method
                    , t.certificate_type as au_certificate_type
                    , t.merchant_certif as au_merchant_certif
                    , t.cardholder_certif as au_cardholder_certif
                    , t.ucaf_indicator as au_ucaf_indicator
                    , t.is_early_emv as au_is_early_emv
                    , t.is_completed as au_is_completed
                    , t.amounts as au_amounts
                    , t.agent_unique_id as au_agent_unique_id
                    , t.external_auth_id as external_auth_id
                    , t.external_orig_id as external_orig_id
                    , t.auth_purpose_id  as auth_purpose_id
                    , m.id as mc_id
                    , m.is_incoming as mc_is_incoming
                    , m.is_reversal as mc_is_reversal
                    , m.is_rejected as mc_is_rejected
                    , m.impact as mc_impact
                    , m.mti as mc_mti
                    , m.de024 as mc_de024
                    , m.de002 as mc_de002
                    , m.de003_1 as mc_de003_1
                    , m.de003_2 as mc_de003_2
                    , m.de003_3 as mc_de003_3
                    , m.de004 as mc_de004
                    , m.de005 as mc_de005
                    , m.de006 as mc_de006
                    , m.de009 as mc_de009
                    , m.de010 as mc_de010
                    , m.de012 as mc_de012
                    , m.de014 as mc_de014
                    , m.de022_1 as mc_de022_1
                    , m.de022_2 as mc_de022_2
                    , m.de022_3 as mc_de022_3
                    , m.de022_4 as mc_de022_4
                    , m.de022_5 as mc_de022_5
                    , m.de022_6 as mc_de022_6
                    , m.de022_7 as mc_de022_7
                    , m.de022_8 as mc_de022_8
                    , m.de022_9 as mc_de022_9
                    , m.de022_10 as mc_de022_10
                    , m.de022_11 as mc_de022_11
                    , m.de022_12 as mc_de022_12
                    , m.de023 as mc_de023
                    , m.de025 as mc_de025
                    , m.de026 as mc_de026
                    , m.de030_1 as mc_de030_1
                    , m.de030_2 as mc_de030_2
                    , m.de031 as mc_de031
                    , m.de032 as mc_de032
                    , m.de033 as mc_de033
                    , m.de037 as mc_de037
                    , m.de038 as mc_de038
                    , m.de040 as mc_de040
                    , m.de041 as mc_de041
                    , m.de042 as mc_de042
                    , m.de043_1 as mc_de043_1
                    , m.de043_2 as mc_de043_2
                    , m.de043_3 as mc_de043_3
                    , m.de043_4 as mc_de043_4
                    , m.de043_5 as mc_de043_5
                    , m.de043_6 as mc_de043_6
                    , m.de049 as mc_de049
                    , m.de050 as mc_de050
                    , m.de051 as mc_de051
                    , m.de054 as mc_de054
                    , m.de055 as mc_de055
                    , m.de063 as mc_de063
                    , m.de071 as mc_de071
                    , m.de072 as mc_de072
                    , m.de073 as mc_de073
                    , m.de093 as mc_de093
                    , m.de094 as mc_de094
                    , m.de095 as mc_de095
                    , m.de100 as mc_de100
                    , m.de111 as mc_de111
                    , m.p0002 as mc_p0002
                    , m.p0023 as mc_p0023
                    , m.p0025_1 as mc_p0025_1
                    , m.p0025_2 as mc_p0025_2
                    , m.p0043 as mc_p0043
                    , m.p0052 as mc_p0052
                    , m.p0137 as mc_p0137
                    , m.p0148 as mc_p0148
                    , m.p0146 as mc_p0146
                    , m.p0146_net as mc_p0146_net
                    , m.p0147 as mc_p0147
                    , m.p0149_1 as mc_p0149_1
                    , lpad(m.p0149_2, 3, '0') as mc_p0149_2
                    , m.p0158_1 as mc_p0158_1
                    , m.p0158_2 as mc_p0158_2
                    , m.p0158_3 as mc_p0158_3
                    , m.p0158_4 as mc_p0158_4
                    , m.p0158_5 as mc_p0158_5
                    , m.p0158_6 as mc_p0158_6
                    , m.p0158_7 as mc_p0158_7
                    , m.p0158_8 as mc_p0158_8
                    , m.p0158_9 as mc_p0158_9
                    , m.p0158_10 as mc_p0158_10
                    , m.p0159_1 as mc_p0159_1
                    , m.p0159_2 as mc_p0159_2
                    , m.p0159_3 as mc_p0159_3
                    , m.p0159_4 as mc_p0159_4
                    , m.p0159_5 as mc_p0159_5
                    , m.p0159_6 as mc_p0159_6
                    , m.p0159_7 as mc_p0159_7
                    , m.p0159_8 as mc_p0159_8
                    , m.p0159_9 as mc_p0159_9
                    , m.p0165 as mc_p0165
                    , m.p0176 as mc_p0176
                    , m.p0228 as mc_p0228
                    , m.p0230 as mc_p0230
                    , m.p0241 as mc_p0241
                    , m.p0243 as mc_p0243
                    , m.p0244 as mc_p0244
                    , m.p0260 as mc_p0260
                    , m.p0261 as mc_p0261
                    , m.p0262 as mc_p0262
                    , m.p0264 as mc_p0264
                    , m.p0265 as mc_p0265
                    , m.p0266 as mc_p0266
                    , m.p0267 as mc_p0267
                    , m.p0268_1 as mc_p0268_1
                    , m.p0268_2 as mc_p0268_2
                    , m.p0375 as mc_p0375
                    , m.emv_9f26 as mc_emv_9f26
                    , m.emv_9f02 as mc_emv_9f02
                    , m.emv_9f27 as mc_emv_9f27
                    , m.emv_9f10 as mc_emv_9f10
                    , m.emv_9f36 as mc_emv_9f36
                    , m.emv_95 as mc_emv_95
                    , m.emv_82 as mc_emv_82
                    , m.emv_9a as mc_emv_9a
                    , m.emv_9c as mc_emv_9c
                    , m.emv_9f37 as mc_emv_9f37
                    , m.emv_5f2a as mc_emv_5f2a
                    , m.emv_9f33 as mc_emv_9f33
                    , m.emv_9f34 as mc_emv_9f34
                    , m.emv_9f1a as mc_emv_9f1a
                    , m.emv_9f35 as mc_emv_9f35
                    , m.emv_9f53 as mc_emv_9f53
                    , m.emv_84 as mc_emv_84
                    , m.emv_9f09 as mc_emv_9f09
                    , m.emv_9f03 as mc_emv_9f03
                    , m.emv_9f1e as mc_emv_9f1e
                    , m.emv_9f41 as mc_emv_9f41
                    , m.p0042 as mc_p0042
                    , m.p0158_11 as mc_p0158_11
                    , m.p0158_12 as mc_p0158_12
                    , m.p0158_13 as mc_p0158_13
                    , m.p0158_14 as mc_p0158_14
                    , m.p0198 as mc_p0198
                    , m.p0200_1 as mc_p0200_1
                    , m.p0200_2 as mc_p0200_2
                    , m.p0210_1 as mc_p0210_1
                    , m.p0210_2 as mc_p0210_2
                    , v.id as vi_id
                    , v.is_reversal as vi_is_reversal
                    , v.is_incoming as vi_is_incoming
                    , v.is_returned as vi_is_returned
                    , v.is_invalid as vi_is_invalid
                    , v.rrn as vi_rrn
                    , v.trans_code as vi_trans_code
                    , v.trans_code_qualifier as vi_trans_code_qualifier
                    , v.card_mask as vi_card_mask
                    , v.oper_amount as vi_oper_amount
                    , v.oper_currency as vi_oper_currency
                    , v.oper_date as vi_oper_date
                    , v.sttl_amount as vi_sttl_amount
                    , v.sttl_currency as vi_sttl_currency
                    , v.network_amount as vi_network_amount
                    , v.network_currency as vi_network_currency
                    , v.floor_limit_ind as vi_floor_limit_ind
                    , v.exept_file_ind as vi_exept_file_ind
                    , v.pcas_ind as vi_pcas_ind
                    , v.arn as vi_arn
                    , v.acquirer_bin as vi_acquirer_bin
                    , v.acq_business_id as vi_acq_business_id
                    , v.merchant_name as vi_merchant_name
                    , v.merchant_city as vi_merchant_city
                    , v.merchant_country as vi_merchant_country
                    , v.merchant_postal_code as vi_merchant_postal_code
                    , v.merchant_region as vi_merchant_region
                    , v.merchant_street as vi_merchant_street
                    , v.mcc as vi_mcc
                    , v.req_pay_service as vi_req_pay_service
                    , v.usage_code as vi_usage_code
                    , v.reason_code as vi_reason_code
                    , v.settlement_flag as vi_settlement_flag
                    , v.auth_char_ind as vi_auth_char_ind
                    , v.auth_code as vi_auth_code
                    , v.pos_terminal_cap as vi_pos_terminal_cap
                    , v.inter_fee_ind as vi_inter_fee_ind
                    , v.crdh_id_method as vi_crdh_id_method
                    , v.collect_only_flag as vi_collect_only_flag
                    , v.pos_entry_mode as vi_pos_entry_mode
                    , v.central_proc_date as vi_central_proc_date
                    , v.reimburst_attr as vi_reimburst_attr
                    , v.iss_workst_bin as vi_iss_workst_bin
                    , v.acq_workst_bin as vi_acq_workst_bin
                    , v.chargeback_ref_num as vi_chargeback_ref_num
                    , v.docum_ind as vi_docum_ind
                    , v.member_msg_text as vi_member_msg_text
                    , v.spec_cond_ind as vi_spec_cond_ind
                    , v.fee_program_ind as vi_fee_program_ind
                    , v.issuer_charge as vi_issuer_charge
                    , v.merchant_number as vi_merchant_number
                    , v.terminal_number as vi_terminal_number
                    , v.national_reimb_fee as vi_national_reimb_fee
                    , v.electr_comm_ind as vi_electr_comm_ind
                    , v.spec_chargeback_ind as vi_spec_chargeback_ind
                    , v.interface_trace_num as vi_interface_trace_num
                    , v.unatt_accept_term_ind as vi_unatt_accept_term_ind
                    , v.prepaid_card_ind as vi_prepaid_card_ind
                    , v.service_development as vi_service_development
                    , v.avs_resp_code as vi_avs_resp_code
                    , v.auth_source_code as vi_auth_source_code
                    , v.purch_id_format as vi_purch_id_format
                    , v.account_selection as vi_account_selection
                    , v.installment_pay_count as vi_installment_pay_count
                    , v.purch_id as vi_purch_id
                    , v.cashback as vi_cashback
                    , v.chip_cond_code as vi_chip_cond_code
                    , v.pos_environment as vi_pos_environment
                    , v.transaction_type as vi_transaction_type
                    , v.card_seq_number as vi_card_seq_number
                    , v.terminal_profile as vi_terminal_profile
                    , v.unpredict_number as vi_unpredict_number
                    , v.appl_trans_counter as vi_appl_trans_counter
                    , v.appl_interch_profile as vi_appl_interch_profile
                    , v.cryptogram as vi_cryptogram
                    , v.term_verif_result as vi_term_verif_result
                    , v.cryptogram_amount as vi_cryptogram_amount
                    , v.card_verif_result as vi_card_verif_result
                    , v.issuer_appl_data as vi_issuer_appl_data
                    , v.issuer_script_result as vi_issuer_script_result
                    , v.card_expir_date as vi_card_expir_date
                    , v.cryptogram_version as vi_cryptogram_version
                    , v.cvv2_result_code as vi_cvv2_result_code
                    , v.auth_resp_code as vi_auth_resp_code
                    , v.cryptogram_info_data as vi_cryptogram_info_data
                    , v.transaction_id as vi_transaction_id
                    , v.merchant_verif_value as vi_merchant_verif_value
                    , v.proc_bin as vi_proc_bin
                    , v.chargeback_reason_code as vi_chargeback_reason_code
                    , v.destination_channel as vi_destination_channel
                    , v.source_channel as vi_source_channel
                    , v.acq_inst_bin as vi_acq_inst_bin
                    , v.spend_qualified_ind as vi_spend_qualified_ind
                    , v.service_code as vi_service_code
                from
                      opr_operation o
                    , aut_auth t
                    , mcw_fin m
                    , vis_fin_message v
                where
                    o.id in (select column_value from table(cast(l_oper_tab as num_tab_tpt)))
                    and t.id(+) = o.id
                    and m.id(+) = o.id
                    and v.id(+) = o.id
            ) x
            group by x.incom_sess_file_id
        )
        loop

            l_incom_sess_file_id := r_xml.incom_sess_file_id;
            l_file               := r_xml.xml_file;

            trc_log_pkg.debug (
                i_text       => 'XML CLOB was successfully created. l_incom_sess_file_id [#1]'
              , i_env_param1 => l_incom_sess_file_id
            );

            if l_incom_sess_file_id is not null then
                select file_name
                  into l_original_file_name
                  from prc_session_file
                 where id = l_incom_sess_file_id;

                rul_api_param_pkg.set_param( 
                    i_name    => 'ORIGINAL_FILE_NAME' 
                  , i_value   => l_original_file_name
                  , io_params => l_params 
                );
            end if;

            prc_api_file_pkg.open_file (
                o_sess_file_id  => l_session_file_id
              , io_params       => l_params
            );

            -- Put file record
            prc_api_file_pkg.put_file (
                i_sess_file_id  => l_session_file_id
              , i_clob_content  => l_file
            );

            trc_log_pkg.debug ('XML was put to the file.');

            prc_api_stat_pkg.log_current (
                i_current_count   => r_xml.current_count
              , i_excepted_count  => 0
            );

            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );

        end loop;  -- Make XML

    end if;  -- if l_estimated_count.count > 0

    -- Mark processed event object
    evt_api_event_pkg.process_event_object (
        i_event_object_id_tab  => l_evt_objects_tab
    );

    trc_log_pkg.debug (
        i_text       => '[#1] event objects marked as PROCESSED.'
      , i_env_param1 => l_evt_objects_tab.count
    );

    trc_log_pkg.debug(LOG_PREFIX || ' was successfully completed.');

    prc_api_stat_pkg.log_end (
        i_result_code => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
exception
    when others then
        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

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
        
end export_clearing_data_13;

procedure export_clearing_data_14(
    i_inst_id                  in     com_api_type_pkg.t_inst_id    default null
  , i_start_date               in     date                          default null
  , i_end_date                 in     date                          default null
  , i_upl_oper_event_type      in     com_api_type_pkg.t_dict_value default null
  , i_terminal_type            in     com_api_type_pkg.t_dict_value default null
  , i_load_state               in     com_api_type_pkg.t_dict_value default null
  , i_load_successfull         in     com_api_type_pkg.t_dict_value default null
  , i_include_auth             in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_include_clearing         in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_masking_card             in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE  
  , i_process_container        in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_session_id               in     com_api_type_pkg.t_long_id    default null
  , i_split_files              in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_reversal_upload_type     in     com_api_type_pkg.t_dict_value default null
  , i_subscriber_name          in     com_api_type_pkg.t_name       default null
) is

    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := $$PLSQL_UNIT || '.EXPORT_CLEARING_DATA_14';
    
begin
    
    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': start'
    );
    
    export_clearing_data_13(
        i_inst_id              =>     i_inst_id
      , i_start_date           =>     i_start_date
      , i_end_date             =>     i_end_date
      , i_upl_oper_event_type  =>     i_upl_oper_event_type
      , i_terminal_type        =>     i_terminal_type
      , i_load_state           =>     i_load_state
      , i_load_successfull     =>     i_load_successfull
      , i_include_auth         =>     i_include_auth
      , i_include_clearing     =>     i_include_clearing
      , i_masking_card         =>     i_masking_card
      , i_process_container    =>     i_process_container
      , i_session_id           =>     i_session_id
      , i_split_files          =>     i_split_files
      , i_reversal_upload_type =>     i_reversal_upload_type
      , i_subscriber_name      =>     i_subscriber_name
    );
    
    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': finish success'
    );
    
end export_clearing_data_14;

procedure export_clearing_data_15(
    i_inst_id                  in     com_api_type_pkg.t_inst_id    default null
  , i_start_date               in     date                          default null
  , i_end_date                 in     date                          default null
  , i_upl_oper_event_type      in     com_api_type_pkg.t_dict_value default null
  , i_terminal_type            in     com_api_type_pkg.t_dict_value default null
  , i_load_state               in     com_api_type_pkg.t_dict_value default null
  , i_load_successfull         in     com_api_type_pkg.t_dict_value default null
  , i_include_auth             in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_include_clearing         in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_masking_card             in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_process_container        in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_session_id               in     com_api_type_pkg.t_long_id    default null
  , i_split_files              in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_reversal_upload_type     in     com_api_type_pkg.t_dict_value default null
  , i_subscriber_name          in     com_api_type_pkg.t_name       default null
) is
    DEFAULT_PROCEDURE_NAME     constant com_api_type_pkg.t_name := $$PLSQL_UNIT || '.EXPORT_CLEARING_DATA_15';
    LOG_PREFIX                 constant com_api_type_pkg.t_name := DEFAULT_PROCEDURE_NAME;
    DATETIME_FORMAT            constant com_api_type_pkg.t_name := 'dd.mm.yyyy hh24:mi:ss';

    l_session_file_id           com_api_type_pkg.t_long_id;
    l_file                      clob;
    l_subscriber_name           com_api_type_pkg.t_name         := upper(nvl(i_subscriber_name, DEFAULT_PROCEDURE_NAME));
    l_sysdate                   date;
    l_params                    com_api_type_pkg.t_param_tab;
    l_lang                      com_api_type_pkg.t_dict_value;
    l_min_date                  date;
    l_max_date                  date;
    l_load_events_with_status   com_api_type_pkg.t_dict_value;
    l_load_successfull          com_api_type_pkg.t_dict_value;
    l_include_auth              com_api_type_pkg.t_boolean;
    l_include_clearing          com_api_type_pkg.t_boolean;
    l_evt_objects_tab           num_tab_tpt := num_tab_tpt();
    l_oper_ids_tab              num_tab_tpt := num_tab_tpt();
    l_oper_tab                  num_tab_tpt := num_tab_tpt();
    l_estimated_count           com_api_type_pkg.t_long_id      := 0;
    l_session_id_tab            num_tab_tpt := num_tab_tpt();
    l_process_session_id        com_api_type_pkg.t_long_id;
    l_use_session_id            com_api_type_pkg.t_boolean      := com_api_const_pkg.FALSE;
    l_incom_sess_file_id_tab    num_tab_tpt := num_tab_tpt();
    l_incom_sess_file_id        com_api_type_pkg.t_long_id;
    l_original_file_name        com_api_type_pkg.t_name;
    l_split_files               com_api_type_pkg.t_boolean      := com_api_const_pkg.FALSE;
    l_reversal_upload_type      com_api_type_pkg.t_dict_value;
    
begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug (
        i_text       => LOG_PREFIX || ': inst_id [' || nvl(to_char(i_inst_id), 'NULL') ||
                        '], upl_oper_event_type [' || nvl(i_upl_oper_event_type, 'NULL') || '], ' ||
                        'terminal_type [#1], start_date [#2], end_date [#3], already_loaded [#4], reversal_upload_type [#5], ' ||
                        'load_successfull [#6], ' ||
                        'include_auth [' ||
                        case i_include_auth when 0 then 'no' when 1 then 'yes' else to_char(i_include_auth) end || '], ' ||
                        'include_clearing [' ||
                        case i_include_clearing when 0 then 'no' when 1 then 'yes' else to_char(i_include_clearing) end || ']'
      , i_env_param1 => i_terminal_type
      , i_env_param2 => to_char(i_start_date, DATETIME_FORMAT)
      , i_env_param3 => to_char(i_end_date, DATETIME_FORMAT)
      , i_env_param4 => i_load_state
      , i_env_param5 => i_reversal_upload_type
      , i_env_param6 => i_load_successfull
    );

    trc_log_pkg.debug (
        i_text       => LOG_PREFIX || ': i_process_container [#1] i_session_id [#2] i_split_files [#3]'
      , i_env_param1 => i_process_container
      , i_env_param2 => i_session_id
      , i_env_param3 => i_split_files
    );

    l_sysdate := get_sysdate();
    l_lang := get_user_lang();
    trc_log_pkg.debug (
        i_text       => 'sysdate [#1], user_lang [#2]'
      , i_env_param1 => to_char(l_sysdate, DATETIME_FORMAT)
      , i_env_param2 => l_lang
    );

    -- Set default values for parameters
    l_load_events_with_status := nvl(i_load_state, evt_api_const_pkg.EVENT_OBJ_LOAD_ST_NOT_LOADED);
    l_load_successfull := nvl(i_load_successfull, opr_api_const_pkg.UNLOADING_OPER_STATUS_ALL);
    l_include_auth := nvl(i_include_auth, com_api_const_pkg.TRUE);
    l_include_clearing := nvl(i_include_clearing, com_api_const_pkg.TRUE);
    l_reversal_upload_type := nvl(i_reversal_upload_type, opr_api_const_pkg.REVERSAL_UPLOAD_ALL);

    -- Check for the case when end date less than start date
    if nvl(i_end_date, date '9999-12-31') < nvl(i_start_date, date '0001-01-01') then
        com_api_error_pkg.raise_error (
            i_error      => 'END_DATE_LESS_THAN_START_DATE'
          , i_env_param1 => com_api_type_pkg.convert_to_char(i_end_date)
          , i_env_param2 => com_api_type_pkg.convert_to_char(i_start_date)
        );
    end if;

    l_min_date := nvl(i_start_date, date '0001-01-01');
    l_max_date := nvl(i_end_date, trunc(get_sysdate) + 1 - com_api_const_pkg.ONE_SECOND);

    trc_log_pkg.debug (
        i_text       => 'min_date [#1], max_date [#2]'
      , i_env_param1 => to_char(l_min_date, DATETIME_FORMAT)
      , i_env_param2 => to_char(l_max_date, DATETIME_FORMAT)
    );

    -- Get session list
    l_process_session_id := get_session_id;
    if nvl(i_process_container, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE and i_session_id is not null then
        select id
          bulk collect into l_session_id_tab
          from prc_session
          connect by parent_id = prior id
          start with id        = i_session_id
        intersect
          select id
            from prc_session
            start with id = (
                               select max(id) keep (dense_rank last order by level)
                                 from prc_session
                                 start with id = l_process_session_id
                                 connect by id = prior parent_id
                            )
            connect by prior id = parent_id;

    elsif nvl(i_process_container, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
          select id
            bulk collect into l_session_id_tab
            from prc_session
            start with id = (
                               select max(id) keep (dense_rank last order by level)
                                 from prc_session
                                 start with id = l_process_session_id
                                 connect by id = prior parent_id
                            )
            connect by prior id = parent_id;

    elsif i_session_id is not null then
        select id
          bulk collect into l_session_id_tab
          from prc_session
          connect by parent_id = prior id
          start with id        = i_session_id;

    end if;

    if l_session_id_tab.count > 0 then
      l_use_session_id := com_api_const_pkg.TRUE;
    end if;

    trc_log_pkg.debug (
        i_text       => 'l_use_session_id [#1] l_session_id_tab.count [#2]'
      , i_env_param1 => l_use_session_id
      , i_env_param2 => l_session_id_tab.count
    );

    if i_split_files = com_api_const_pkg.TRUE and l_use_session_id = com_api_const_pkg.TRUE then
        l_split_files := com_api_const_pkg.TRUE;
    end if;

    -- Get session list for incoming files
    if l_split_files = com_api_const_pkg.TRUE then
        select s.id
          bulk collect into l_incom_sess_file_id_tab
          from prc_session_file s
             , prc_file_attribute a
             , prc_file f
         where s.session_id in (
                                   select column_value
                                     from table(cast(l_session_id_tab as num_tab_tpt))
                               )
           and s.file_attr_id   = a.id
           and f.id             = a.file_id
           and f.file_purpose   = prc_api_const_pkg.FILE_PURPOSE_IN
           and f.file_type      = opr_api_const_pkg.FILE_TYPE_LOADING;

    end if;

    trc_log_pkg.debug (
        i_text       => 'l_split_files [#1] l_incom_sess_file_id_tab.count [#2]'
      , i_env_param1 => l_split_files
      , i_env_param2 => l_incom_sess_file_id_tab.count
    );

    -- Select IDs of all event objects need to proceed
    select
        v.id                 as evt_id
      , v.object_id          as evt_obj_id
    bulk collect into
        l_evt_objects_tab
      , l_oper_ids_tab
    from
        (
            select eo.entity_type, eo.object_id, eo.inst_id, eo.eff_date, eo.event_id, eo.id, eo.split_hash
              from evt_event_object eo
             where l_load_events_with_status = evt_api_const_pkg.EVENT_OBJ_LOAD_ST_NOT_LOADED
               and decode(eo.status, 'EVST0001', eo.procedure_name, null) = l_subscriber_name
               and eo.split_hash in (select split_hash from com_api_split_map_vw)
            union all
            select eo.entity_type, eo.object_id, eo.inst_id, eo.eff_date, eo.event_id, eo.id, eo.split_hash
              from evt_event_object eo
             where eo.split_hash in (select split_hash from com_api_split_map_vw)
               and ((l_load_events_with_status = evt_api_const_pkg.EVENT_OBJ_LOAD_ST_ALL          
                       and (decode(eo.status, 'EVST0001', eo.procedure_name, null) = l_subscriber_name 
                            or decode(eo.status, 'EVST0002', eo.procedure_name, null) = l_subscriber_name
                       )
                   )
                   or (l_load_events_with_status = evt_api_const_pkg.EVENT_OBJ_LOAD_ST_ALREADY_LOAD
                       and decode(eo.status, 'EVST0002', eo.procedure_name, null) = l_subscriber_name
                   )
               )
        ) v
      , evt_event e
      , opr_operation o
      , aut_auth a
    where
        e.id = v.event_id
        and v.eff_date <= l_sysdate
        and (v.inst_id = i_inst_id
            or i_inst_id is null
            or i_inst_id = ost_api_const_pkg.DEFAULT_INST
        )
        and (o.terminal_type = i_terminal_type
            or i_terminal_type is null
        )
        and (e.event_type = i_upl_oper_event_type
            or i_upl_oper_event_type is null
        )
        and v.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
        and o.id    = v.object_id
        and o.host_date between l_min_date and l_max_date
        and a.id(+) = o.id
        and (l_load_successfull != opr_api_const_pkg.UNLOADING_OPER_STATUS_SUCCESS or o.status in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES))
        and (l_load_successfull != opr_api_const_pkg.UNLOADING_OPER_STATUS_DECLINE or o.status not in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES))
        and (l_load_successfull != opr_api_const_pkg.UNLOADING_OPER_STATUS_SUCCESS or a.resp_code is null or a.resp_code = aup_api_const_pkg.RESP_CODE_OK)
        and (l_load_successfull != opr_api_const_pkg.UNLOADING_OPER_STATUS_DECLINE or a.resp_code is null or a.resp_code <> aup_api_const_pkg.RESP_CODE_OK)
        and (o.is_reversal = com_api_const_pkg.FALSE or l_reversal_upload_type in (opr_api_const_pkg.REVERSAL_UPLOAD_ALL, opr_api_const_pkg.REVERSAL_UPLOAD_WITHOUT_MERGED))
        and (l_use_session_id = com_api_const_pkg.FALSE
             or (l_use_session_id = com_api_const_pkg.TRUE
                 and o.session_id in (select column_value from table(cast(l_session_id_tab as num_tab_tpt)))
             )
        )
        and (l_split_files = com_api_const_pkg.FALSE
             or (l_split_files = com_api_const_pkg.TRUE
                 and o.incom_sess_file_id in (select column_value from table(cast(l_incom_sess_file_id_tab as num_tab_tpt)))
             )
        )
        and (case
                 when l_reversal_upload_type = opr_api_const_pkg.REVERSAL_UPLOAD_ALL
                    or (l_reversal_upload_type = opr_api_const_pkg.REVERSAL_UPLOAD_ORIGINAL
                        and o.is_reversal = com_api_const_pkg.FALSE)
                 then com_api_const_pkg.FALSE

                 when l_reversal_upload_type = opr_api_const_pkg.REVERSAL_UPLOAD_WITHOUT_MERGED
                      and o.is_reversal = com_api_const_pkg.TRUE
                      and o.status in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES)
                 then (
                          select nvl(max(com_api_const_pkg.TRUE), com_api_const_pkg.FALSE)
                            from opr_operation orig, evt_event_object eo_orig, evt_event ev_orig
                           where orig.id                = o.original_id
                             and orig.is_reversal       = com_api_const_pkg.FALSE
                             and (l_load_successfull   != opr_api_const_pkg.UNLOADING_OPER_STATUS_SUCCESS or orig.status in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES))
                             and (l_load_successfull   != opr_api_const_pkg.UNLOADING_OPER_STATUS_DECLINE or orig.status not in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES))
                             and (orig.oper_amount - o.oper_amount) = 0
                             and o.oper_currency        = orig.oper_currency
                             and eo_orig.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                             and eo_orig.object_id      = orig.id
                             and eo_orig.split_hash     = v.split_hash
                             and eo_orig.procedure_name = l_subscriber_name
                             and (
                                   ( eo_orig.status  = evt_api_const_pkg.EVENT_STATUS_READY
                                     and l_load_events_with_status in (evt_api_const_pkg.EVENT_OBJ_LOAD_ST_NOT_LOADED, evt_api_const_pkg.EVENT_OBJ_LOAD_ST_ALL)
                                   )
                                   or
                                   ( eo_orig.status  = evt_api_const_pkg.EVENT_STATUS_PROCESSED
                                     and l_load_events_with_status in (evt_api_const_pkg.EVENT_OBJ_LOAD_ST_ALREADY_LOAD, evt_api_const_pkg.EVENT_OBJ_LOAD_ST_ALL)
                                   )
                             )
                             and ev_orig.id          = eo_orig.event_id
                             and (ev_orig.event_type = i_upl_oper_event_type or i_upl_oper_event_type is null)
                 )

                 when l_reversal_upload_type = opr_api_const_pkg.REVERSAL_UPLOAD_WITHOUT_MERGED
                      and o.is_reversal = com_api_const_pkg.FALSE
                 then (
                          select nvl(max(com_api_const_pkg.TRUE), com_api_const_pkg.FALSE)
                            from opr_operation rev, evt_event_object eo_rev, evt_event ev_rev
                           where rev.original_id       = o.id
                             and rev.is_reversal       = com_api_const_pkg.TRUE
                             and rev.status in (opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES)
                             and (rev.oper_amount - o.oper_amount) = 0
                             and o.oper_currency       = rev.oper_currency
                             and eo_rev.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                             and eo_rev.object_id      = rev.id
                             and eo_rev.split_hash     = v.split_hash
                             and eo_rev.procedure_name = l_subscriber_name
                             and (
                                   ( eo_rev.status  = evt_api_const_pkg.EVENT_STATUS_READY
                                     and l_load_events_with_status in (evt_api_const_pkg.EVENT_OBJ_LOAD_ST_NOT_LOADED, evt_api_const_pkg.EVENT_OBJ_LOAD_ST_ALL)
                                   )
                                   or
                                   ( eo_rev.status  = evt_api_const_pkg.EVENT_STATUS_PROCESSED
                                     and l_load_events_with_status in (evt_api_const_pkg.EVENT_OBJ_LOAD_ST_ALREADY_LOAD, evt_api_const_pkg.EVENT_OBJ_LOAD_ST_ALL)
                                   )
                             )
                             and ev_rev.id          = eo_rev.event_id
                             and (ev_rev.event_type = i_upl_oper_event_type or i_upl_oper_event_type is null)
                 )

                 else com_api_const_pkg.FALSE
             end
        ) = com_api_const_pkg.FALSE;

    -- Decrease operation count
    select distinct column_value
      bulk collect into l_oper_tab
      from table(cast(l_oper_ids_tab as num_tab_tpt));

    -- Get estimated count
    l_estimated_count := l_oper_tab.count;

    trc_log_pkg.debug (
        i_text       => 'Operations to go count: [#1]'
      , i_env_param1 => l_estimated_count
    );

    prc_api_stat_pkg.log_estimation (
        i_estimated_count => l_estimated_count
    );

    if l_estimated_count > 0 then
        -- Preparing for passing into <prc_api_file_pkg.open_file> Id of the institute
        l_params:= evt_api_shared_data_pkg.g_params;
        rul_api_param_pkg.set_param (
            i_name    => 'INST_ID'
          , i_value   => i_inst_id
          , io_params => l_params
        );


        for r_xml in (
            -- Make XML
            select
                x.incom_sess_file_id
              , count(distinct x.id) as current_count
              , com_api_const_pkg.XML_HEADER ||
                xmlelement("clearing"
                  , xmlattributes('http://bpc.ru/sv/SVXP/clearing' as "xmlns")
                  , xmlforest(
                        to_char(l_session_file_id, 'TM9')                                   as "file_id"
                      , opr_api_const_pkg.FILE_TYPE_UNLOADING                               as "file_type"
                      , to_char(i_start_date, com_api_const_pkg.XML_DATE_FORMAT)            as "start_date"
                      , to_char(i_end_date, com_api_const_pkg.XML_DATE_FORMAT)              as "end_date"
                      , i_inst_id                                                           as "inst_id"
                    )
                  , xmlagg(
                        xmlelement("operation"
                          , xmlforest(
                                to_char(x.id, com_api_const_pkg.XML_NUMBER_FORMAT)          as "oper_id"
                              , x.oper_type                                                 as "oper_type"
                              , x.msg_type                                                  as "msg_type"
                              , x.sttl_type                                                 as "sttl_type"
                              , to_char(x.oper_date, com_api_const_pkg.XML_DATETIME_FORMAT) as "oper_date"
                              , to_char(x.host_date, com_api_const_pkg.XML_DATETIME_FORMAT) as "host_date"
                              , to_char(x.oper_count, com_api_const_pkg.XML_NUMBER_FORMAT)  as "oper_count"
                              , case when x.oper_amount is not null then
                                     xmlforest(
                                         x.oper_amount           as "amount_value"
                                       , x.oper_currency         as "currency"
                                     )
                                end                                                         as "oper_amount"
                              , case when x.oper_request_amount is not null then
                                     xmlforest(
                                         x.oper_request_amount   as "amount_value"
                                       , x.oper_currency         as "currency"
                                     )
                                end                                                         as "oper_request_amount"
                              , case when x.oper_surcharge_amount is not null then
                                     xmlforest(
                                         x.oper_surcharge_amount as "amount_value"
                                       , x.oper_currency         as "currency"
                                     )
                                end                                                         as "oper_surcharge_amount"
                              , case when x.oper_cashback_amount is not null then
                                     xmlforest(
                                         x.oper_cashback_amount   as "amount_value"
                                       , x.oper_currency          as "currency"
                                     )
                                end                                                         as "oper_cashback_amount"
                              , case when x.sttl_amount is not null then
                                     xmlforest(
                                         x.sttl_amount            as "amount_value"
                                       , x.sttl_currency          as "currency"
                                     )
                                end                                                         as "sttl_amount"
                              , case when x.fee_amount is not null then
                                     xmlforest(
                                         x.fee_amount            as "amount_value"
                                       , x.fee_currency          as "currency"
                                     )
                                end                                                         as "interchange_fee"
                              , x.originator_refnum                                         as "originator_refnum"
                              , x.network_refnum                                            as "network_refnum"
                              , x.acq_inst_bin                                              as "acq_inst_bin"
                              , x.status_reason                                             as "response_code"
                              , x.oper_reason                                               as "oper_reason"
                              , x.status                                                    as "status"
                              , x.is_reversal                                               as "is_reversal"
                              , x.merchant_number                                           as "merchant_number"
                              , x.mcc                                                       as "mcc"
                              , x.merchant_name                                             as "merchant_name"
                              , x.merchant_street                                           as "merchant_street"
                              , x.merchant_city                                             as "merchant_city"
                              , x.merchant_region                                           as "merchant_region"
                              , x.merchant_country                                          as "merchant_country"
                              , x.merchant_postcode                                         as "merchant_postcode"
                              , x.terminal_type                                             as "terminal_type"
                              , x.terminal_number                                           as "terminal_number"
                              , to_char(x.sttl_date, com_api_const_pkg.XML_DATETIME_FORMAT) as "sttl_date"
                            ) -- xmlforest
                            --
                          , (select
                                 xmlelement("payment_order"
                                   , xmlforest(
                                         po.id                as "payment_order_id"
                                       , po.status            as "payment_order_status"
                                       , po.purpose_id        as "purpose_id"
                                       , pp.purpose_number    as "purpose_number"
                                       , xmlforest(
                                             po.amount            as "amount_value"
                                           , po.currency          as "currency"
                                         ) as "payment_amount"
                                     )
                                   , (select xmlagg(
                                                 xmlelement("payment_parameter"
                                                   , xmlforest(
                                                         xp.param_name    as "payment_parameter_name"
                                                       , xod.param_value  as "payment_parameter_value"
                                                     )
                                                 ) 
                                             )
                                        from pmo_parameter xp
                                        join pmo_order_data xod on xod.param_id = xp.id
                                       where xod.order_id = po.id
                                     ) -- payment_parameter
                                   , (select xmlagg(
                                                 xmlelement("document"
                                                   , d.id                 as "document_id"
                                                   , d.document_type      as "document_type"
                                                   , to_char(d.document_date, com_api_const_pkg.XML_DATETIME_FORMAT) as "document_date"
                                                   , d.document_number    as "document_number"
                                                   , xmlagg(
                                                         case when dc.document_content is not null then
                                                             xmlelement("document_content"
                                                               , xmlforest(
                                                                     dc.content_type                                     as "content_type"
                                                                   , com_api_hash_pkg.base64_encode(dc.document_content) as "content"
                                                                 )
                                                             )
                                                         end
                                                     )
                                                 ) -- document
                                             )
                                        from rpt_document d
                                        left join rpt_document_content dc on dc.document_id = d.id
                                       where d.object_id = po.id
                                         and d.entity_type = pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
                                       group by
                                             d.id
                                           , d.document_type
                                           , d.document_date
                                           , d.document_number
                                     ) -- document
                                 ) -- payment_order
                              from pmo_order po
                              left join pmo_purpose pp on pp.id = po.purpose_id
                             where po.id = x.payment_order_id
                            )
                            --
                          , (select
                                 xmlagg(
                                     xmlelement("transaction"
                                       , xmlelement("transaction_id", ae.transaction_id)
                                       , xmlelement("transaction_type", ae.transaction_type)
                                       , xmlelement("posting_date", to_char(min(ae.posting_date), com_api_const_pkg.XML_DATETIME_FORMAT))
                                       , (select xmlagg(
                                                     xmlelement("debit_entry"
                                                       , xmlelement("entry_id", dae.id)
                                                       , xmlelement("account"
                                                           , xmlelement("account_number", da.account_number)
                                                           , xmlelement("currency", da.currency)
                                                           , xmlelement("agent_number", doa.agent_number)
                                                         )
                                                       , xmlelement("amount"
                                                           , xmlelement("amount_value", dae.amount)
                                                           , xmlelement("currency", dae.currency)
                                                         )
                                                     )
                                                 )
                                            from acc_entry dae
                                            join acc_account da on da.id = dae.account_id
                                            left join ost_agent doa on doa.id = da.agent_id
                                           where dae.transaction_id = ae.transaction_id
                                             and dae.balance_impact = com_api_const_pkg.DEBIT
                                         ) -- debit entry
                                       , (select xmlagg(
                                                     xmlelement("credit_entry"
                                                       , xmlelement("entry_id", cae.id)
                                                       , xmlelement("account"
                                                           , xmlelement("account_number", ca.account_number)
                                                           , xmlelement("currency", ca.currency)
                                                           , xmlelement("agent_number", coa.agent_number)
                                                         )
                                                       , xmlelement("amount"
                                                           , xmlelement("amount_value", cae.amount)
                                                           , xmlelement("currency", cae.currency)
                                                         )
                                                     )
                                                 )
                                            from acc_entry cae
                                            join acc_account ca on ca.id = cae.account_id
                                            left join ost_agent coa on coa.id = ca.agent_id
                                           where cae.transaction_id = ae.transaction_id
                                             and cae.balance_impact = com_api_const_pkg.CREDIT
                                         ) -- credit entry
                                       , (select
                                              xmlagg(
                                                  xmlelement("document"
                                                    , xmlelement("document_id", d.id)
                                                    , xmlelement("document_type", d.document_type)
                                                    , xmlelement("document_date", to_char(d.document_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                                    , xmlelement("document_number", d.document_number)
                                                    , xmlagg(
                                                          xmlelement("document_content"
                                                              , xmlelement("content_type", dc.content_type)
                                                              , xmlelement("content", com_api_hash_pkg.base64_encode(dc.document_content))
                                                          )
                                                      )
                                                  )
                                              )
                                            from rpt_document d
                                            left join rpt_document_content dc on dc.document_id = d.id
                                           where d.object_id = ae.transaction_id
                                             and d.entity_type = acc_api_const_pkg.ENTITY_TYPE_TRANSACTION
                                           group by d.id, d.document_type, d.document_date, d.document_number
                                         ) -- document
                                       , xmlelement("conversion_rate", nvl(am.conversion_rate, 1))
                                       , xmlelement("amount_purpose", am.amount_purpose)
                                     ) -- xmlelement transaction
                                 ) -- xmlagg
                               from acc_macros am
                               join acc_entry ae on ae.macros_id = am.id
                              where am.object_id = x.id -- opr_operation.id
                                and am.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                              group by
                                    ae.transaction_id
                                  , ae.transaction_type
                                  , am.conversion_rate
                                  , am.amount_purpose
                            ) -- transaction
                            --
                          , (select xmlagg(
                                        xmlelement("document"
                                          , xmlelement("document_id", d.id)
                                          , xmlelement("document_type", d.document_type)
                                          , xmlelement("document_date", to_char(d.document_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                          , xmlelement("document_number", d.document_number)
                                          , xmlagg(
                                                case when dc.document_content is not null then
                                                    xmlelement("document_content"
                                                      , xmlelement("content_type", dc.content_type)
                                                      , xmlelement("content", com_api_hash_pkg.base64_encode(dc.document_content))
                                                    )
                                                end
                                            )
                                        )
                                    )
                               from rpt_document d
                               left join rpt_document_content dc on dc.document_id = d.id
                              where d.object_id = x.id
                                and d.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                              group by
                                    d.id
                                  , d.document_type
                                  , d.document_date
                                  , d.document_number
                            ) as document
                            --
                          , (select xmlforest(
                                        xmlforest(
                                            p.client_id_type      as "client_id_type" 
                                          , p.client_id_value     as "client_id_value"
                                          , case nvl(i_masking_card, com_api_const_pkg.TRUE)
                                                when com_api_const_pkg.TRUE
                                                then iss_api_card_pkg.get_card_mask(i_card_number => c.card_number)
                                                else c.card_number
                                            end as "card_number"
                                          , case
                                                when p.card_id is not null
                                                then iss_api_card_instance_pkg.get_card_uid(
                                                         i_card_instance_id => iss_api_card_instance_pkg.get_card_instance_id(
                                                                                   i_card_id => p.card_id
                                                                               )
                                                     )
                                                else null
                                            end                   as "card_id"
                                          , p.card_instance_id    as "card_instance_id"
                                          , p.card_seq_number     as "card_seq_number"
                                          , to_char(p.card_expir_date, com_api_const_pkg.XML_DATE_FORMAT) as "card_expir_date"
                                          , p.card_country        as "card_country"                                      
                                          , p.inst_id             as "inst_id"
                                          , p.network_id          as "network_id"
                                          , p.auth_code           as "auth_code"
                                          , p.account_number      as "account_number"
                                          , p.account_amount      as "account_amount"
                                          , p.account_currency    as "account_currency"
                                        ) as "issuer"
                                    )
                               from opr_participant p
                               left join opr_card c on c.oper_id = p.oper_id
                              where p.oper_id = x.id
                                and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                            ) as issuer
                            --
                          , (select xmlforest(
                                        xmlforest(
                                            p.inst_id             as "inst_id"
                                          , p.network_id          as "network_id"
                                          , p.auth_code           as "auth_code"
                                          , p.account_number      as "account_number"
                                          , p.account_amount      as "account_amount"
                                          , p.account_currency    as "account_currency"
                                        ) as "acquirer"
                                    )
                               from opr_participant p
                              where p.oper_id = x.id
                                and p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                            ) as acquier
                            --
                          , (select xmlforest(
                                        xmlforest(
                                            p.client_id_type          as "client_id_type"
                                          , p.client_id_value         as "client_id_value"
                                          , p.inst_id                 as "inst_id"
                                        ) as "destination"
                                    )
                               from opr_participant p
                              where p.oper_id = x.id
                                and p.participant_type = com_api_const_pkg.PARTICIPANT_DEST
                            ) as destination
                            --
                          , (select xmlforest(
                                        xmlforest(
                                            p.client_id_type          as "client_id_type"
                                          , p.client_id_value         as "client_id_value"
                                          , p.inst_id                 as "inst_id"
                                        ) as "aggregator"
                                    )
                               from opr_participant p
                              where p.oper_id = x.id
                                and p.participant_type = com_api_const_pkg.PARTICIPANT_AGGREGATOR
                            ) as aggregator
                            --
                          , (select xmlforest(
                                        xmlforest(
                                            p.client_id_type          as "client_id_type"
                                          , p.client_id_value         as "client_id_value"
                                          , p.inst_id                 as "inst_id"
                                        ) as "service_provider"
                                    )
                               from opr_participant p
                              where p.oper_id = x.id
                                and p.participant_type = com_api_const_pkg.PARTICIPANT_SERVICE_PROVIDER
                            ) as service_provider
                            --
                          , (select xmlagg(
                                        xmlelement("note"
                                          , xmlelement("note_type", n.note_type)
                                          , xmlagg(
                                                xmlelement("note_content"
                                                  , xmlattributes(l_lang as "language")
                                                  , xmlforest(
                                                        com_api_i18n_pkg.get_text(
                                                            i_table_name  => 'ntb_note'
                                                          , i_column_name => 'header'
                                                          , i_object_id   => n.id
                                                          , i_lang        => l_lang
                                                        ) as "note_header"
                                                      , com_api_i18n_pkg.get_text(
                                                            i_table_name  => 'ntb_note'
                                                          , i_column_name => 'text'
                                                          , i_object_id   => n.id
                                                          , i_lang        => l_lang
                                                        ) as "note_text"
                                                    )
                                                )
                                            )
                                        )
                                    )
                               from ntb_note n
                              where n.object_id = x.id
                                and n.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                              group by
                                    n.note_type
                            ) as note
                            --
                          , case when x.au_id is not null
                                  and nvl(l_include_auth, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE
                                 then
                                     (select
                                          xmlagg(
                                              xmlelement("auth_data"
                                                , xmlforest(
                                                      x.au_resp_code                             as "resp_code"
                                                    , x.au_proc_type                             as "proc_type"
                                                    , x.au_proc_mode                             as "proc_mode"
                                                    , to_char(x.au_is_advice, com_api_const_pkg.XML_NUMBER_FORMAT)           as "is_advice"
                                                    , to_char(x.au_is_repeat, com_api_const_pkg.XML_NUMBER_FORMAT)           as "is_repeat"
                                                    , to_char(x.au_bin_amount, com_api_const_pkg.XML_NUMBER_FORMAT)          as "bin_amount"
                                                    , x.au_bin_currency                          as "bin_currency"
                                                    , to_char(x.au_bin_cnvt_rate, com_api_const_pkg.XML_NUMBER_FORMAT)       as "bin_cnvt_rate"
                                                    , to_char(x.au_network_amount, com_api_const_pkg.XML_NUMBER_FORMAT)      as "network_amount"
                                                    , x.au_network_currency                      as "network_currency"
                                                    , to_char(x.au_network_cnvt_date, com_api_const_pkg.XML_DATETIME_FORMAT) as "network_cnvt_date"
                                                    , to_char(x.au_account_cnvt_rate, com_api_const_pkg.XML_NUMBER_FORMAT)   as "account_cnvt_rate"
                                                    , x.au_addr_verif_result                     as "addr_verif_result"
                                                    , x.au_acq_resp_code                         as "acq_resp_code"
                                                    , x.au_acq_device_proc_result                as "acq_device_proc_result"
                                                    , x.au_cat_level                             as "cat_level"
                                                    , x.au_card_data_input_cap                   as "card_data_input_cap"
                                                    , x.au_crdh_auth_cap                         as "crdh_auth_cap"
                                                    , x.au_card_capture_cap                      as "card_capture_cap"
                                                    , x.au_terminal_operating_env                as "terminal_operating_env"
                                                    , x.au_crdh_presence                         as "crdh_presence"
                                                    , x.au_card_presence                         as "card_presence"
                                                    , x.au_card_data_input_mode                  as "card_data_input_mode"
                                                    , x.au_crdh_auth_method                      as "crdh_auth_method"
                                                    , x.au_crdh_auth_entity                      as "crdh_auth_entity"
                                                    , x.au_card_data_output_cap                  as "card_data_output_cap"
                                                    , x.au_terminal_output_cap                   as "terminal_output_cap"
                                                    , x.au_pin_capture_cap                       as "pin_capture_cap"
                                                    , x.au_pin_presence                          as "pin_presence"
                                                    , x.au_cvv2_presence                         as "cvv2_presence"
                                                    , x.au_cvc_indicator                         as "cvc_indicator"
                                                    , x.au_pos_entry_mode                        as "pos_entry_mode"
                                                    , x.au_pos_cond_code                         as "pos_cond_code"
                                                    , x.au_emv_data                              as "emv_data"
                                                    , x.au_atc                                   as "atc"
                                                    , x.au_tvr                                   as "tvr"
                                                    , x.au_cvr                                   as "cvr"
                                                    , x.au_addl_data                             as "addl_data"
                                                    , x.au_service_code                          as "service_code"
                                                    , x.au_device_date                           as "device_date"
                                                    , x.au_cvv2_result                           as "cvv2_result"
                                                    , x.au_certificate_method                    as "certificate_method"
                                                    , x.au_merchant_certif                       as "merchant_certif"
                                                    , x.au_cardholder_certif                     as "cardholder_certif"
                                                    , x.au_ucaf_indicator                        as "ucaf_indicator"
                                                    , to_char(x.au_is_early_emv, com_api_const_pkg.XML_NUMBER_FORMAT)        as "is_early_emv"
                                                    , x.au_is_completed                          as "is_completed"
                                                    , x.au_amounts                               as "amounts"
                                                    , x.au_agent_unique_id                       as "agent_unique_id"
                                                    , x.external_auth_id                         as "external_auth_id"
                                                    , x.external_orig_id                         as "external_orig_id"
                                                    , x.auth_purpose_id                          as "auth_purpose_id"
                                                  )
                                                , (select
                                                       xmlagg(
                                                           xmlelement("auth_tag"
                                                             , xmlelement("tag_id", t.tag)
                                                             , xmlelement("tag_value", v.tag_value)
                                                             , xmlelement("tag_name", t.reference)
                                                             , xmlelement("seq_number", v.seq_number)
                                                           )
                                                       )
                                                     from
                                                         aup_tag t
                                                       , aup_tag_value v
                                                    where
                                                         v.tag_id  = t.tag and v.auth_id = x.id
                                                  )
                                              )
                                          )
                                       from
                                           dual
                                     )
                            end as auth_data
                            --
                          , case when x.mc_id is not null
                                  and nvl(l_include_clearing, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE
                                 then
                                 xmlforest(
                                     xmlforest(
                                         to_char(x.mc_is_incoming, com_api_const_pkg.XML_NUMBER_FORMAT) as "is_incoming"
                                       , to_char(x.mc_is_reversal, com_api_const_pkg.XML_NUMBER_FORMAT) as "is_reversal"
                                       , to_char(x.mc_is_rejected, com_api_const_pkg.XML_NUMBER_FORMAT) as "is_rejected"
                                       , to_char(x.mc_impact, com_api_const_pkg.XML_NUMBER_FORMAT)      as "impact"
                                       , x.mc_mti              as "mti"
                                       , x.mc_de024            as "de024"
                                       , x.mc_de002            as "de002"
                                       , x.mc_de003_1          as "de003_1"
                                       , x.mc_de003_2          as "de003_2"
                                       , x.mc_de003_3          as "de003_3"
                                       , to_char(x.mc_de004, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de004"
                                       , to_char(x.mc_de005, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de005"
                                       , to_char(x.mc_de006, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de006"
                                       , x.mc_de009            as "de009"
                                       , x.mc_de010            as "de010"
                                       , to_char(x.mc_de012, com_api_const_pkg.XML_DATETIME_FORMAT)     as "de012"
                                       , to_char(x.mc_de014, com_api_const_pkg.XML_DATETIME_FORMAT)     as "de014" 
                                       , x.mc_de022_1          as "de022_1"
                                       , x.mc_de022_2          as "de022_2"
                                       , x.mc_de022_3          as "de022_3"
                                       , x.mc_de022_4          as "de022_4"     
                                       , x.mc_de022_5          as "de022_5"
                                       , x.mc_de022_6          as "de022_6"
                                       , x.mc_de022_7          as "de022_7"
                                       , x.mc_de022_8          as "de022_8"
                                       , x.mc_de022_9          as "de022_9" 
                                       , x.mc_de022_10         as "de022_10"
                                       , x.mc_de022_11         as "de022_11"
                                       , x.mc_de022_12         as "de022_12"
                                       , to_char(x.mc_de023, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de023"
                                       , x.mc_de025            as "de025"
                                       , x.mc_de026            as "de026"
                                       , to_char(x.mc_de030_1, com_api_const_pkg.XML_NUMBER_FORMAT)     as "de030_1"
                                       , to_char(x.mc_de030_2, com_api_const_pkg.XML_NUMBER_FORMAT)     as "de030_2"
                                       , x.mc_de031            as "de031"
                                       , x.mc_de032            as "de032"
                                       , x.mc_de033            as "de033"
                                       , x.mc_de037            as "de037"
                                       , x.mc_de038            as "de038"
                                       , x.mc_de040            as "de040"
                                       , x.mc_de041            as "de041"
                                       , x.mc_de042            as "de042"
                                       , x.mc_de043_1          as "de043_1"
                                       , x.mc_de043_2          as "de043_2"
                                       , x.mc_de043_3          as "de043_3"
                                       , x.mc_de043_4          as "de043_4"
                                       , x.mc_de043_5          as "de043_5"
                                       , x.mc_de043_6          as "de043_6"
                                       , x.mc_de049            as "de049"
                                       , x.mc_de050            as "de050"
                                       , x.mc_de051            as "de051"
                                       , x.mc_de054            as "de054"
                                       , x.mc_de055            as "de055"
                                       , x.mc_de063            as "de063"
                                       , to_char(x.mc_de071, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de071"
                                       , regexp_replace(x.mc_de072, '[[:cntrl:]]', null)                as "de072"
                                       , to_char(x.mc_de073, com_api_const_pkg.XML_DATETIME_FORMAT)     as "de073"
                                       , x.mc_de093            as "de093"
                                       , x.mc_de094            as "de094"
                                       , x.mc_de095            as "de095"
                                       , x.mc_de100            as "de100"
                                       , to_char(x.mc_de111, com_api_const_pkg.XML_NUMBER_FORMAT)       as "de111"
                                       , x.mc_p0002            as "p0002"
                                       , x.mc_p0023            as "p0023"
                                       , x.mc_p0025_1          as "p0025_1"
                                       , to_char(x.mc_p0025_2, com_api_const_pkg.XML_DATETIME_FORMAT)   as "p0025_2"
                                       , x.mc_p0043            as "p0043"
                                       , x.mc_p0052            as "p0052"
                                       , x.mc_p0137            as "p0137"
                                       , x.mc_p0148            as "p0148"
                                       , x.mc_p0146            as "p0146"
                                       , to_char(x.mc_p0146_net, com_api_const_pkg.XML_NUMBER_FORMAT)   as "p0146_net"
                                       , x.mc_p0147            as "p0147"
                                       , x.mc_p0149_1          as "p0149_1"
                                       , x.mc_p0149_2          as "p0149_2"
                                       , x.mc_p0158_1          as "p0158_1"
                                       , x.mc_p0158_2          as "p0158_2"
                                       , x.mc_p0158_3          as "p0158_3"           
                                       , x.mc_p0158_4          as "p0158_4"
                                       , to_char(x.mc_p0158_5, com_api_const_pkg.XML_DATETIME_FORMAT)   as "p0158_5"
                                       , to_char(x.mc_p0158_6, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0158_6"
                                       , x.mc_p0158_7          as "p0158_7"
                                       , x.mc_p0158_8          as "p0158_8"
                                       , x.mc_p0158_9          as "p0158_9"
                                       , x.mc_p0158_10         as "p0158_10"
                                       , x.mc_p0159_1          as "p0159_1"
                                       , x.mc_p0159_2          as "p0159_2"
                                       , to_char(x.mc_p0159_3, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0159_3"
                                       , x.mc_p0159_4          as "p0159_4"
                                       , x.mc_p0159_5          as "p0159_5"
                                       , to_char(x.mc_p0159_6, com_api_const_pkg.XML_DATETIME_FORMAT)   as "p0159_6"
                                       , to_char(x.mc_p0159_7, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0159_7"
                                       , to_char(x.mc_p0159_8, com_api_const_pkg.XML_DATETIME_FORMAT)   as "p0159_8"
                                       , to_char(x.mc_p0159_9, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0159_9"
                                       , x.mc_p0165            as "p0165"
                                       , x.mc_p0176            as "p0176"
                                       , to_char(x.mc_p0228, com_api_const_pkg.XML_NUMBER_FORMAT)       as "p0228" 
                                       , to_char(x.mc_p0230, com_api_const_pkg.XML_NUMBER_FORMAT)       as "p0230"
                                       , x.mc_p0241            as "p0241"
                                       , x.mc_p0243            as "p0243"
                                       , x.mc_p0244            as "p0244"
                                       , x.mc_p0260            as "p0260"
                                       , to_char(x.mc_p0261, com_api_const_pkg.XML_NUMBER_FORMAT)       as "p0261"
                                       , to_char(x.mc_p0262, com_api_const_pkg.XML_NUMBER_FORMAT)       as "p0262"
                                       , to_char(x.mc_p0264, com_api_const_pkg.XML_NUMBER_FORMAT)       as "p0264"
                                       , x.mc_p0265            as "p0265"
                                       , x.mc_p0266            as "p0266"
                                       , x.mc_p0267            as "p0267"
                                       , to_char(x.mc_p0268_1, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0268_1"
                                       , x.mc_p0268_2          as "p0268_2"
                                       , x.mc_p0375            as "p0375"
                                       , x.mc_emv_9f26         as "emv_9f26"
                                       , to_char(x.mc_emv_9f02, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_9f02"
                                       , x.mc_emv_9f27         as "emv_9f27"
                                       , x.mc_emv_9f10         as "emv_9f10"
                                       , x.mc_emv_9f36         as "emv_9f36"
                                       , x.mc_emv_95           as "emv_95"
                                       , x.mc_emv_82           as "emv_82"
                                       , to_char(x.mc_emv_9a, com_api_const_pkg.XML_DATETIME_FORMAT)    as "emv_9a"
                                       , to_char(x.mc_emv_9c, com_api_const_pkg.XML_NUMBER_FORMAT)      as "emv_9c"
                                       , x.mc_emv_9f37         as "emv_9f37"
                                       , to_char(x.mc_emv_5f2a, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_5f2a"
                                       , x.mc_emv_9f33         as "emv_9f33"
                                       , x.mc_emv_9f34         as "emv_9f34"
                                       , to_char(x.mc_emv_9f1a, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_9f1a"
                                       , to_char(x.mc_emv_9f35, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_9f35"
                                       , x.mc_emv_9f53         as "emv_9f53"
                                       , x.mc_emv_84           as "emv_84"
                                       , x.mc_emv_9f09         as "emv_9f09"
                                       , to_char(x.mc_emv_9f03, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_9f03"
                                       , x.mc_emv_9f1e         as "emv_9f1e"
                                       , to_char(x.mc_emv_9f41, com_api_const_pkg.XML_NUMBER_FORMAT)    as "emv_9f41"
                                       , x.mc_p0042            as "p0042"
                                       , x.mc_p0158_11         as "p0158_11"
                                       , x.mc_p0158_12         as "p0158_12"
                                       , x.mc_p0158_13         as "p0158_13"
                                       , x.mc_p0158_14         as "p0158_14"
                                       , x.mc_p0198            as "p0198"
                                       , to_char(x.mc_p0200_1, com_api_const_pkg.XML_DATETIME_FORMAT)   as "p0200_1"
                                       , to_char(x.mc_p0200_2, com_api_const_pkg.XML_NUMBER_FORMAT)     as "p0200_2"
                                       , x.mc_p0210_1          as "p0210_1"
                                       , x.mc_p0210_2          as "p0210_2"                                   
                                     ) as "ipm_data" -- xmlforest
                                 ) -- xmlforest
                            end
                            --
                          , case when x.vi_id is not null
                                  and nvl(l_include_clearing, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE
                                 then
                                 xmlforest(
                                     xmlforest(
                                         to_char(x.vi_is_reversal, com_api_const_pkg.XML_NUMBER_FORMAT)    as "is_reversal"
                                       , to_char(x.vi_is_incoming, com_api_const_pkg.XML_NUMBER_FORMAT)    as "is_incoming"
                                       , to_char(x.vi_is_returned, com_api_const_pkg.XML_NUMBER_FORMAT)    as "is_returned"
                                       , to_char(x.vi_is_invalid, com_api_const_pkg.XML_NUMBER_FORMAT)     as "is_invalid"
                                       , x.vi_rrn                    as "rrn"
                                       , x.vi_trans_code             as "trans_code"
                                       , x.vi_trans_code_qualifier   as "trans_code_qualifier"
                                       , x.vi_card_mask              as "card_mask"
                                       , to_char(x.vi_oper_amount, com_api_const_pkg.XML_NUMBER_FORMAT)    as "oper_amount"
                                       , x.vi_oper_currency          as "oper_currency"
                                       , to_char(x.vi_oper_date, com_api_const_pkg.XML_DATETIME_FORMAT)    as "oper_date"
                                       , to_char(x.vi_sttl_amount, com_api_const_pkg.XML_NUMBER_FORMAT)    as "sttl_amount"
                                       , x.vi_sttl_currency          as "sttl_currency"
                                       , to_char(x.vi_network_amount, com_api_const_pkg.XML_NUMBER_FORMAT) as "network_amount"
                                       , x.vi_network_currency       as "network_currency"
                                       , x.vi_floor_limit_ind        as "floor_limit_ind"
                                       , x.vi_exept_file_ind         as "exept_file_ind"
                                       , x.vi_pcas_ind               as "pcas_ind"
                                       , x.vi_arn                    as "arn"
                                       , x.vi_acquirer_bin           as "acquirer_bin"
                                       , x.vi_acq_business_id        as "acq_business_id"
                                       , x.vi_merchant_name          as "merchant_name"
                                       , x.vi_merchant_city          as "merchant_city"
                                       , x.vi_merchant_country       as "merchant_country"
                                       , x.vi_merchant_postal_code   as "merchant_postal_code"
                                       , x.vi_merchant_region        as "merchant_region"
                                       , x.vi_merchant_street        as "merchant_street"
                                       , x.vi_mcc                    as "mcc"
                                       , x.vi_req_pay_service        as "req_pay_service"
                                       , x.vi_usage_code             as "usage_code"
                                       , x.vi_reason_code            as "reason_code"
                                       , x.vi_settlement_flag        as "settlement_flag"
                                       , x.vi_auth_char_ind          as "auth_char_ind"
                                       , x.vi_auth_code              as "auth_code"
                                       , x.vi_pos_terminal_cap       as "pos_terminal_cap"
                                       , x.vi_inter_fee_ind          as "inter_fee_ind"
                                       , x.vi_crdh_id_method         as "crdh_id_method"
                                       , x.vi_collect_only_flag      as "collect_only_flag"
                                       , x.vi_pos_entry_mode         as "pos_entry_mode"
                                       , x.vi_central_proc_date      as "central_proc_date"
                                       , x.vi_reimburst_attr         as "reimburst_attr"
                                       , x.vi_iss_workst_bin         as "iss_workst_bin"
                                       , x.vi_acq_workst_bin         as "acq_workst_bin"
                                       , x.vi_chargeback_ref_num     as "chargeback_ref_num"
                                       , x.vi_docum_ind              as "docum_ind"
                                       , x.vi_member_msg_text        as "member_msg_text"
                                       , x.vi_spec_cond_ind          as "spec_cond_ind"
                                       , x.vi_fee_program_ind        as "fee_program_ind"
                                       , x.vi_issuer_charge          as "issuer_charge"
                                       , x.vi_merchant_number        as "merchant_number"
                                       , x.vi_terminal_number        as "terminal_number"
                                       , x.vi_national_reimb_fee     as "national_reimb_fee"
                                       , x.vi_electr_comm_ind        as "electr_comm_ind"
                                       , x.vi_spec_chargeback_ind    as "spec_chargeback_ind"
                                       , x.vi_interface_trace_num    as "interface_trace_num"
                                       , x.vi_unatt_accept_term_ind  as "unatt_accept_term_ind"
                                       , x.vi_prepaid_card_ind       as "prepaid_card_ind"
                                       , x.vi_service_development    as "service_development"
                                       , x.vi_avs_resp_code          as "avs_resp_code"
                                       , x.vi_auth_source_code       as "auth_source_code"
                                       , x.vi_purch_id_format        as "purch_id_format"
                                       , x.vi_account_selection      as "account_selection"
                                       , x.vi_installment_pay_count  as "installment_pay_count"
                                       , x.vi_purch_id               as "purch_id"
                                       , x.vi_cashback               as "cashback"
                                       , x.vi_chip_cond_code         as "chip_cond_code"
                                       , x.vi_pos_environment        as "pos_environment"
                                       , x.vi_transaction_type       as "transaction_type"
                                       , x.vi_card_seq_number        as "card_seq_number"
                                       , x.vi_terminal_profile       as "terminal_profile"
                                       , x.vi_unpredict_number       as "unpredict_number"
                                       , x.vi_appl_trans_counter     as "appl_trans_counter"
                                       , x.vi_appl_interch_profile   as "appl_interch_profile"
                                       , x.vi_cryptogram             as "cryptogram"
                                       , x.vi_term_verif_result      as "term_verif_result"
                                       , x.vi_cryptogram_amount      as "cryptogram_amount"
                                       , x.vi_card_verif_result      as "card_verif_result"
                                       , x.vi_issuer_appl_data       as "issuer_appl_data"
                                       , x.vi_issuer_script_result   as "issuer_script_result"
                                       , x.vi_card_expir_date        as "card_expir_date"
                                       , x.vi_cryptogram_version     as "cryptogram_version"
                                       , x.vi_cvv2_result_code       as "cvv2_result_code"
                                       , x.vi_auth_resp_code         as "auth_resp_code"
                                       , x.vi_cryptogram_info_data   as "cryptogram_info_data"
                                       , x.vi_transaction_id         as "transaction_id"
                                       , x.vi_merchant_verif_value   as "merchant_verif_value"
                                       , x.vi_proc_bin               as "proc_bin"
                                       , x.vi_chargeback_reason_code as "chargeback_reason_code"
                                       , x.vi_destination_channel    as "destination_channel"
                                       , x.vi_source_channel         as "source_channel"
                                       , x.vi_acq_inst_bin           as "acq_inst_bin"
                                       , x.vi_spend_qualified_ind    as "spend_qualified_ind"
                                       , x.vi_service_code           as "service_code"
                                     ) as "baseII_data" -- xmlforest
                                 ) -- xmlforest
                            end
                            --
                          , (select xmlagg(
                                        xmlelement("additional_amount"
                                          , xmlelement("amount_value", a.amount)
                                          , xmlelement("currency",     a.currency)
                                          , xmlelement("amount_type",  a.amount_type)
                                        )
                                    )
                               from opr_additional_amount a
                              where a.oper_id = x.id
                                and a.amount is not null
                            ) as additional_amount
                        ) -- xmlelement("operation"
                    ) -- xmlagg (for <operation>)
                ).getClobVal()  xml_file
            from (
                select
                    o.id
                    , o.oper_type
                    , o.msg_type
                    , o.sttl_type
                    , o.oper_date
                    , o.host_date
                    , o.oper_count
                    , o.oper_amount
                    , o.oper_currency
                    , o.oper_request_amount
                    , o.oper_surcharge_amount
                    , o.oper_cashback_amount
                    , o.sttl_amount
                    , o.sttl_currency
                    , o.fee_amount
                    , o.fee_currency  
                    , o.originator_refnum
                    , o.network_refnum
                    , o.acq_inst_bin
                    , case o.status_reason
                          when aut_api_const_pkg.AUTH_REASON_DUE_TO_RESP_CODE   then t.resp_code
                          when aut_api_const_pkg.AUTH_REASON_DUE_TO_COMPLT_FLAG then t.is_completed
                                                                                else o.status_reason
                      end as status_reason
                    , o.oper_reason
                    , o.status
                    , o.is_reversal
                    , o.merchant_number
                    , o.mcc
                    , o.merchant_name
                    , o.merchant_street
                    , o.merchant_city
                    , o.merchant_region
                    , o.merchant_country
                    , o.merchant_postcode
                    , case o.terminal_type
                          when acq_api_const_pkg.TERMINAL_TYPE_MOBILE_POS
                          then acq_api_const_pkg.TERMINAL_TYPE_POS
                          else o.terminal_type
                      end as terminal_type
                    , o.terminal_number
                    , o.payment_order_id
                    , decode(l_split_files, com_api_const_pkg.TRUE, o.incom_sess_file_id, null) as incom_sess_file_id
                    , o.sttl_date as sttl_date                     
                    , t.id as au_id
                    , t.resp_code as au_resp_code
                    , t.proc_type as au_proc_type
                    , t.proc_mode as au_proc_mode
                    , t.is_advice as au_is_advice
                    , t.is_repeat as au_is_repeat
                    , t.bin_amount as au_bin_amount
                    , t.bin_currency as au_bin_currency
                    , t.bin_cnvt_rate as au_bin_cnvt_rate
                    , t.network_amount as au_network_amount
                    , t.network_currency as au_network_currency
                    , t.network_cnvt_date as au_network_cnvt_date
                    , t.network_cnvt_rate as au_network_cnvt_rate
                    , t.account_cnvt_rate as au_account_cnvt_rate
                    , t.parent_id as au_parent_id
                    , t.addr_verif_result as au_addr_verif_result
                    , t.iss_network_device_id as au_iss_network_device_id
                    , t.acq_device_id as au_acq_device_id
                    , t.acq_resp_code as au_acq_resp_code
                    , t.acq_device_proc_result as au_acq_device_proc_result
                    , t.cat_level as au_cat_level
                    , t.card_data_input_cap as au_card_data_input_cap
                    , t.crdh_auth_cap as au_crdh_auth_cap
                    , t.card_capture_cap as au_card_capture_cap
                    , t.terminal_operating_env as au_terminal_operating_env
                    , t.crdh_presence as au_crdh_presence
                    , t.card_presence as au_card_presence
                    , t.card_data_input_mode as au_card_data_input_mode
                    , t.crdh_auth_method as au_crdh_auth_method
                    , t.crdh_auth_entity as au_crdh_auth_entity
                    , t.card_data_output_cap as au_card_data_output_cap
                    , t.terminal_output_cap as au_terminal_output_cap
                    , t.pin_capture_cap as au_pin_capture_cap
                    , t.pin_presence as au_pin_presence
                    , t.cvv2_presence as au_cvv2_presence
                    , t.cvc_indicator as au_cvc_indicator
                    , t.pos_entry_mode as au_pos_entry_mode
                    , t.pos_cond_code as au_pos_cond_code
                    , t.emv_data as au_emv_data
                    , t.atc as au_atc
                    , t.tvr as au_tvr
                    , t.cvr as au_cvr
                    , t.addl_data as au_addl_data
                    , t.service_code as au_service_code
                    , t.device_date as au_device_date
                    , t.cvv2_result as au_cvv2_result
                    , t.certificate_method as au_certificate_method
                    , t.certificate_type as au_certificate_type
                    , t.merchant_certif as au_merchant_certif
                    , t.cardholder_certif as au_cardholder_certif
                    , t.ucaf_indicator as au_ucaf_indicator
                    , t.is_early_emv as au_is_early_emv
                    , t.is_completed as au_is_completed
                    , t.amounts as au_amounts
                    , t.agent_unique_id as au_agent_unique_id
                    , t.external_auth_id as external_auth_id
                    , t.external_orig_id as external_orig_id
                    , t.auth_purpose_id  as auth_purpose_id
                    , m.id as mc_id
                    , m.is_incoming as mc_is_incoming
                    , m.is_reversal as mc_is_reversal
                    , m.is_rejected as mc_is_rejected
                    , m.impact as mc_impact
                    , m.mti as mc_mti
                    , m.de024 as mc_de024
                    , m.de002 as mc_de002
                    , m.de003_1 as mc_de003_1
                    , m.de003_2 as mc_de003_2
                    , m.de003_3 as mc_de003_3
                    , m.de004 as mc_de004
                    , m.de005 as mc_de005
                    , m.de006 as mc_de006
                    , m.de009 as mc_de009
                    , m.de010 as mc_de010
                    , m.de012 as mc_de012
                    , m.de014 as mc_de014
                    , m.de022_1 as mc_de022_1
                    , m.de022_2 as mc_de022_2
                    , m.de022_3 as mc_de022_3
                    , m.de022_4 as mc_de022_4
                    , m.de022_5 as mc_de022_5
                    , m.de022_6 as mc_de022_6
                    , m.de022_7 as mc_de022_7
                    , m.de022_8 as mc_de022_8
                    , m.de022_9 as mc_de022_9
                    , m.de022_10 as mc_de022_10
                    , m.de022_11 as mc_de022_11
                    , m.de022_12 as mc_de022_12
                    , m.de023 as mc_de023
                    , m.de025 as mc_de025
                    , m.de026 as mc_de026
                    , m.de030_1 as mc_de030_1
                    , m.de030_2 as mc_de030_2
                    , m.de031 as mc_de031
                    , m.de032 as mc_de032
                    , m.de033 as mc_de033
                    , m.de037 as mc_de037
                    , m.de038 as mc_de038
                    , m.de040 as mc_de040
                    , m.de041 as mc_de041
                    , m.de042 as mc_de042
                    , m.de043_1 as mc_de043_1
                    , m.de043_2 as mc_de043_2
                    , m.de043_3 as mc_de043_3
                    , m.de043_4 as mc_de043_4
                    , m.de043_5 as mc_de043_5
                    , m.de043_6 as mc_de043_6
                    , m.de049 as mc_de049
                    , m.de050 as mc_de050
                    , m.de051 as mc_de051
                    , m.de054 as mc_de054
                    , m.de055 as mc_de055
                    , m.de063 as mc_de063
                    , m.de071 as mc_de071
                    , m.de072 as mc_de072
                    , m.de073 as mc_de073
                    , m.de093 as mc_de093
                    , m.de094 as mc_de094
                    , m.de095 as mc_de095
                    , m.de100 as mc_de100
                    , m.de111 as mc_de111
                    , m.p0002 as mc_p0002
                    , m.p0023 as mc_p0023
                    , m.p0025_1 as mc_p0025_1
                    , m.p0025_2 as mc_p0025_2
                    , m.p0043 as mc_p0043
                    , m.p0052 as mc_p0052
                    , m.p0137 as mc_p0137
                    , m.p0148 as mc_p0148
                    , m.p0146 as mc_p0146
                    , m.p0146_net as mc_p0146_net
                    , m.p0147 as mc_p0147
                    , m.p0149_1 as mc_p0149_1
                    , lpad(m.p0149_2, 3, '0') as mc_p0149_2
                    , m.p0158_1 as mc_p0158_1
                    , m.p0158_2 as mc_p0158_2
                    , m.p0158_3 as mc_p0158_3
                    , m.p0158_4 as mc_p0158_4
                    , m.p0158_5 as mc_p0158_5
                    , m.p0158_6 as mc_p0158_6
                    , m.p0158_7 as mc_p0158_7
                    , m.p0158_8 as mc_p0158_8
                    , m.p0158_9 as mc_p0158_9
                    , m.p0158_10 as mc_p0158_10
                    , m.p0159_1 as mc_p0159_1
                    , m.p0159_2 as mc_p0159_2
                    , m.p0159_3 as mc_p0159_3
                    , m.p0159_4 as mc_p0159_4
                    , m.p0159_5 as mc_p0159_5
                    , m.p0159_6 as mc_p0159_6
                    , m.p0159_7 as mc_p0159_7
                    , m.p0159_8 as mc_p0159_8
                    , m.p0159_9 as mc_p0159_9
                    , m.p0165 as mc_p0165
                    , m.p0176 as mc_p0176
                    , m.p0228 as mc_p0228
                    , m.p0230 as mc_p0230
                    , m.p0241 as mc_p0241
                    , m.p0243 as mc_p0243
                    , m.p0244 as mc_p0244
                    , m.p0260 as mc_p0260
                    , m.p0261 as mc_p0261
                    , m.p0262 as mc_p0262
                    , m.p0264 as mc_p0264
                    , m.p0265 as mc_p0265
                    , m.p0266 as mc_p0266
                    , m.p0267 as mc_p0267
                    , m.p0268_1 as mc_p0268_1
                    , m.p0268_2 as mc_p0268_2
                    , m.p0375 as mc_p0375
                    , m.emv_9f26 as mc_emv_9f26
                    , m.emv_9f02 as mc_emv_9f02
                    , m.emv_9f27 as mc_emv_9f27
                    , m.emv_9f10 as mc_emv_9f10
                    , m.emv_9f36 as mc_emv_9f36
                    , m.emv_95 as mc_emv_95
                    , m.emv_82 as mc_emv_82
                    , m.emv_9a as mc_emv_9a
                    , m.emv_9c as mc_emv_9c
                    , m.emv_9f37 as mc_emv_9f37
                    , m.emv_5f2a as mc_emv_5f2a
                    , m.emv_9f33 as mc_emv_9f33
                    , m.emv_9f34 as mc_emv_9f34
                    , m.emv_9f1a as mc_emv_9f1a
                    , m.emv_9f35 as mc_emv_9f35
                    , m.emv_9f53 as mc_emv_9f53
                    , m.emv_84 as mc_emv_84
                    , m.emv_9f09 as mc_emv_9f09
                    , m.emv_9f03 as mc_emv_9f03
                    , m.emv_9f1e as mc_emv_9f1e
                    , m.emv_9f41 as mc_emv_9f41
                    , m.p0042 as mc_p0042
                    , m.p0158_11 as mc_p0158_11
                    , m.p0158_12 as mc_p0158_12
                    , m.p0158_13 as mc_p0158_13
                    , m.p0158_14 as mc_p0158_14
                    , m.p0198 as mc_p0198
                    , m.p0200_1 as mc_p0200_1
                    , m.p0200_2 as mc_p0200_2
                    , m.p0210_1 as mc_p0210_1
                    , m.p0210_2 as mc_p0210_2
                    , v.id as vi_id
                    , v.is_reversal as vi_is_reversal
                    , v.is_incoming as vi_is_incoming
                    , v.is_returned as vi_is_returned
                    , v.is_invalid as vi_is_invalid
                    , v.rrn as vi_rrn
                    , v.trans_code as vi_trans_code
                    , v.trans_code_qualifier as vi_trans_code_qualifier
                    , v.card_mask as vi_card_mask
                    , v.oper_amount as vi_oper_amount
                    , v.oper_currency as vi_oper_currency
                    , v.oper_date as vi_oper_date
                    , v.sttl_amount as vi_sttl_amount
                    , v.sttl_currency as vi_sttl_currency
                    , v.network_amount as vi_network_amount
                    , v.network_currency as vi_network_currency
                    , v.floor_limit_ind as vi_floor_limit_ind
                    , v.exept_file_ind as vi_exept_file_ind
                    , v.pcas_ind as vi_pcas_ind
                    , v.arn as vi_arn
                    , v.acquirer_bin as vi_acquirer_bin
                    , v.acq_business_id as vi_acq_business_id
                    , v.merchant_name as vi_merchant_name
                    , v.merchant_city as vi_merchant_city
                    , v.merchant_country as vi_merchant_country
                    , v.merchant_postal_code as vi_merchant_postal_code
                    , v.merchant_region as vi_merchant_region
                    , v.merchant_street as vi_merchant_street
                    , v.mcc as vi_mcc
                    , v.req_pay_service as vi_req_pay_service
                    , v.usage_code as vi_usage_code
                    , v.reason_code as vi_reason_code
                    , v.settlement_flag as vi_settlement_flag
                    , v.auth_char_ind as vi_auth_char_ind
                    , v.auth_code as vi_auth_code
                    , v.pos_terminal_cap as vi_pos_terminal_cap
                    , v.inter_fee_ind as vi_inter_fee_ind
                    , v.crdh_id_method as vi_crdh_id_method
                    , v.collect_only_flag as vi_collect_only_flag
                    , v.pos_entry_mode as vi_pos_entry_mode
                    , v.central_proc_date as vi_central_proc_date
                    , v.reimburst_attr as vi_reimburst_attr
                    , v.iss_workst_bin as vi_iss_workst_bin
                    , v.acq_workst_bin as vi_acq_workst_bin
                    , v.chargeback_ref_num as vi_chargeback_ref_num
                    , v.docum_ind as vi_docum_ind
                    , v.member_msg_text as vi_member_msg_text
                    , v.spec_cond_ind as vi_spec_cond_ind
                    , v.fee_program_ind as vi_fee_program_ind
                    , v.issuer_charge as vi_issuer_charge
                    , v.merchant_number as vi_merchant_number
                    , v.terminal_number as vi_terminal_number
                    , v.national_reimb_fee as vi_national_reimb_fee
                    , v.electr_comm_ind as vi_electr_comm_ind
                    , v.spec_chargeback_ind as vi_spec_chargeback_ind
                    , v.interface_trace_num as vi_interface_trace_num
                    , v.unatt_accept_term_ind as vi_unatt_accept_term_ind
                    , v.prepaid_card_ind as vi_prepaid_card_ind
                    , v.service_development as vi_service_development
                    , v.avs_resp_code as vi_avs_resp_code
                    , v.auth_source_code as vi_auth_source_code
                    , v.purch_id_format as vi_purch_id_format
                    , v.account_selection as vi_account_selection
                    , v.installment_pay_count as vi_installment_pay_count
                    , v.purch_id as vi_purch_id
                    , v.cashback as vi_cashback
                    , v.chip_cond_code as vi_chip_cond_code
                    , v.pos_environment as vi_pos_environment
                    , v.transaction_type as vi_transaction_type
                    , v.card_seq_number as vi_card_seq_number
                    , v.terminal_profile as vi_terminal_profile
                    , v.unpredict_number as vi_unpredict_number
                    , v.appl_trans_counter as vi_appl_trans_counter
                    , v.appl_interch_profile as vi_appl_interch_profile
                    , v.cryptogram as vi_cryptogram
                    , v.term_verif_result as vi_term_verif_result
                    , v.cryptogram_amount as vi_cryptogram_amount
                    , v.card_verif_result as vi_card_verif_result
                    , v.issuer_appl_data as vi_issuer_appl_data
                    , v.issuer_script_result as vi_issuer_script_result
                    , v.card_expir_date as vi_card_expir_date
                    , v.cryptogram_version as vi_cryptogram_version
                    , v.cvv2_result_code as vi_cvv2_result_code
                    , v.auth_resp_code as vi_auth_resp_code
                    , v.cryptogram_info_data as vi_cryptogram_info_data
                    , v.transaction_id as vi_transaction_id
                    , v.merchant_verif_value as vi_merchant_verif_value
                    , v.proc_bin as vi_proc_bin
                    , v.chargeback_reason_code as vi_chargeback_reason_code
                    , v.destination_channel as vi_destination_channel
                    , v.source_channel as vi_source_channel
                    , v.acq_inst_bin as vi_acq_inst_bin
                    , v.spend_qualified_ind as vi_spend_qualified_ind
                    , v.service_code as vi_service_code
                from
                      opr_operation o
                    , aut_auth t
                    , mcw_fin m
                    , vis_fin_message v
                where
                    o.id in (select column_value from table(cast(l_oper_tab as num_tab_tpt)))
                    and t.id(+) = o.id
                    and m.id(+) = o.id
                    and v.id(+) = o.id
            ) x
            group by x.incom_sess_file_id
        )
        loop

            l_incom_sess_file_id := r_xml.incom_sess_file_id;
            l_file               := r_xml.xml_file;

            trc_log_pkg.debug (
                i_text       => 'XML CLOB was successfully created. l_incom_sess_file_id [#1]'
              , i_env_param1 => l_incom_sess_file_id
            );

            if l_incom_sess_file_id is not null then
                select file_name
                  into l_original_file_name
                  from prc_session_file
                 where id = l_incom_sess_file_id;

                rul_api_param_pkg.set_param( 
                    i_name    => 'ORIGINAL_FILE_NAME' 
                  , i_value   => l_original_file_name
                  , io_params => l_params 
                );
            end if;

            prc_api_file_pkg.open_file (
                o_sess_file_id  => l_session_file_id
              , io_params       => l_params
            );

            -- Put file record
            prc_api_file_pkg.put_file (
                i_sess_file_id  => l_session_file_id
              , i_clob_content  => l_file
            );

            trc_log_pkg.debug ('XML was put to the file.');

            prc_api_stat_pkg.log_current (
                i_current_count   => r_xml.current_count
              , i_excepted_count  => 0
            );

            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );

        end loop;  -- Make XML

    end if;  -- if l_estimated_count.count > 0

    -- Mark processed event object
    evt_api_event_pkg.process_event_object (
        i_event_object_id_tab  => l_evt_objects_tab
    );

    trc_log_pkg.debug (
        i_text       => '[#1] event objects marked as PROCESSED.'
      , i_env_param1 => l_evt_objects_tab.count
    );

    trc_log_pkg.debug(LOG_PREFIX || ' was successfully completed.');

    prc_api_stat_pkg.log_end (
        i_result_code => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
exception
    when others then
        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

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

end export_clearing_data_15;

procedure export_rates_data_10(
    i_inst_id             in    com_api_type_pkg.t_inst_id       default null
  , i_eff_date            in    date                             default null
  , i_full_export         in    com_api_type_pkg.t_boolean       default null
  , i_base_rate_export    in    com_api_type_pkg.t_boolean       default null
  , i_rate_type           in    com_api_type_pkg.t_dict_value    default null
  , i_subscriber_name     in    com_api_type_pkg.t_name          default null
) is

    DEFAULT_PROCEDURE_NAME      constant com_api_type_pkg.t_name  := $$PLSQL_UNIT || '.EXPORT_RATES_DATA_10';
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_file                      clob;
    l_file_type                 com_api_type_pkg.t_dict_value;
    l_subscriber_name           com_api_type_pkg.t_name           := upper(nvl(i_subscriber_name, DEFAULT_PROCEDURE_NAME));
    l_full_export               com_api_type_pkg.t_boolean;
    l_estimated_count           com_api_type_pkg.t_count          := 0;
    l_eff_date                  date;

    l_event_tab                 com_api_type_pkg.t_number_tab;
    l_rate_id_tab               num_tab_tpt;

    l_excepted_count            com_api_type_pkg.t_count          := 0;
    l_processed_count           com_api_type_pkg.t_count          := 0;

    l_params                    com_api_type_pkg.t_param_tab;
    
begin
    savepoint unload_currency_rates;

    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': start with i_inst_id [#1] i_eff_date [#2] i_full_export [#3] i_base_rate_export [#4] i_rate_type [#5]'
        , i_env_param1  => i_inst_id
        , i_env_param2  => to_char(i_eff_date, com_api_const_pkg.DATE_FORMAT)
        , i_env_param3  => i_full_export
        , i_env_param4  => i_base_rate_export
        , i_env_param5  => i_rate_type
    );

    prc_api_stat_pkg.log_start;
    
    l_full_export   := nvl(i_full_export, com_api_type_pkg.FALSE);
    
    l_eff_date      := nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate);

    if l_full_export = com_api_type_pkg.TRUE then

        select r.id
          bulk collect into
               l_rate_id_tab
          from com_rate r
         where r.status = com_api_rate_pkg.RATE_STATUS_VALID
           and (i_inst_id is null or i_inst_id = ost_api_const_pkg.DEFAULT_INST or r.inst_id = i_inst_id)
           and (i_rate_type is null or r.rate_type = i_rate_type)
           and r.eff_date >= 
                 (select max(cr.eff_date)
                    from com_rate cr
                   where cr.src_currency = r.src_currency
                     and cr.dst_currency = r.dst_currency
                     and cr.rate_type = r.rate_type
                     and cr.inst_id = r.inst_id
                     and cr.eff_date <= l_eff_date
                     and nvl(cr.exp_date, l_eff_date) >= l_eff_date
                     and cr.status = com_api_rate_pkg.RATE_STATUS_VALID
                  );
            
    else
        select o.id
             , r.id
          bulk collect into
               l_event_tab
             , l_rate_id_tab
          from evt_event_object o
             , com_rate r
         where decode(o.status, 'EVST0001', o.procedure_name, null) = l_subscriber_name
           and o.eff_date      <= l_eff_date
           and o.entity_type    = com_api_const_pkg.ENTITY_TYPE_CURRENCY_RATE
           and o.object_id      = r.id
           and r.status         = com_api_rate_pkg.RATE_STATUS_VALID
           and (i_rate_type is null or r.rate_type = i_rate_type)
           and (i_inst_id is null or i_inst_id = ost_api_const_pkg.DEFAULT_INST or r.inst_id = i_inst_id);

    end if;

    l_estimated_count := execute_rate_query(
                             i_count_query_only => com_api_type_pkg.TRUE
                           , io_file            => l_file
                           , io_rate_id_tab     => l_rate_id_tab
                           , i_base_rate_export => i_base_rate_export
                         );

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimated_count
    );
    trc_log_pkg.debug(
        i_text          => 'Estimated count [#1]'
        , i_env_param1  => l_estimated_count
    );

    l_processed_count := execute_rate_query(
                             i_count_query_only => com_api_type_pkg.FALSE
                           , io_file            => l_file
                           , io_rate_id_tab     => l_rate_id_tab
                           , i_base_rate_export => i_base_rate_export
                         );

    if l_processed_count > 0 then
        
        rul_api_param_pkg.set_param(
            i_name       => 'INST_ID'
            , i_value    => i_inst_id
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

        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count  => l_processed_count
        );
        
        trc_log_pkg.debug('file saved, cnt='||l_processed_count||', length='||length(l_file));
        
    end if;
        
    if l_full_export = com_api_type_pkg.FALSE then
        
        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab => l_event_tab
        );
        
    end if;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count    => l_processed_count
    );

    prc_api_stat_pkg.log_end(
          i_excepted_total   => l_excepted_count
        , i_processed_total  => l_processed_count
        , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
          i_text        => DEFAULT_PROCEDURE_NAME || ': finish with l_processed_count [#1]'
        , i_env_param1  => l_processed_count
    );

exception
    when others then
        rollback to savepoint unload_currency_rates;

        prc_api_stat_pkg.log_end(
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
                , i_env_param1  => sqlerrm
            );
        end if;

        raise;
        
end export_rates_data_10;

procedure export_rates_data_11(
    i_inst_id             in    com_api_type_pkg.t_inst_id       default null
  , i_eff_date            in    date                             default null
  , i_full_export         in    com_api_type_pkg.t_boolean       default null
  , i_base_rate_export    in    com_api_type_pkg.t_boolean       default null
  , i_rate_type           in    com_api_type_pkg.t_dict_value    default null
  , i_subscriber_name     in    com_api_type_pkg.t_name          default null
) is

    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := $$PLSQL_UNIT || '.EXPORT_RATES_DATA_11';
    
begin
    
    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': start'
    );
    
    export_rates_data_10(
        i_inst_id               =>    i_inst_id
      , i_eff_date              =>    i_eff_date
      , i_full_export           =>    i_full_export
      , i_base_rate_export      =>    i_base_rate_export
      , i_rate_type             =>    i_rate_type
      , i_subscriber_name       =>    i_subscriber_name
   );
   
    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': finish success'
    );
   
end export_rates_data_11;


procedure export_rates_data_12(
    i_inst_id             in    com_api_type_pkg.t_inst_id       default null
  , i_eff_date            in    date                             default null
  , i_full_export         in    com_api_type_pkg.t_boolean       default null
  , i_base_rate_export    in    com_api_type_pkg.t_boolean       default null
  , i_rate_type           in    com_api_type_pkg.t_dict_value    default null
  , i_subscriber_name     in    com_api_type_pkg.t_name          default null
) is

    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := $$PLSQL_UNIT || '.EXPORT_RATES_DATA_12';
    
begin
    
    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': start'
    );
    
    export_rates_data_11(
        i_inst_id               =>    i_inst_id
      , i_eff_date              =>    i_eff_date
      , i_full_export           =>    i_full_export
      , i_base_rate_export      =>    i_base_rate_export
      , i_rate_type             =>    i_rate_type
      , i_subscriber_name       =>    i_subscriber_name
   );
   
    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': finish success'
    );
   
end export_rates_data_12;

procedure export_rates_data_13(
    i_inst_id             in    com_api_type_pkg.t_inst_id       default null
  , i_eff_date            in    date                             default null
  , i_full_export         in    com_api_type_pkg.t_boolean       default null
  , i_base_rate_export    in    com_api_type_pkg.t_boolean       default null
  , i_rate_type           in    com_api_type_pkg.t_dict_value    default null
  , i_subscriber_name     in    com_api_type_pkg.t_name          default null
) is

    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := $$PLSQL_UNIT || '.EXPORT_RATES_DATA_13';
    
begin
    
    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': start'
    );
    
    export_rates_data_11(
        i_inst_id               =>    i_inst_id
      , i_eff_date              =>    i_eff_date
      , i_full_export           =>    i_full_export
      , i_base_rate_export      =>    i_base_rate_export
      , i_rate_type             =>    i_rate_type
      , i_subscriber_name       =>    i_subscriber_name
   );
   
    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': finish success'
    );
   
end;

procedure export_rates_data_14(
    i_inst_id             in    com_api_type_pkg.t_inst_id       default null
  , i_eff_date            in    date                             default null
  , i_full_export         in    com_api_type_pkg.t_boolean       default null
  , i_base_rate_export    in    com_api_type_pkg.t_boolean       default null
  , i_rate_type           in    com_api_type_pkg.t_dict_value    default null
  , i_subscriber_name     in    com_api_type_pkg.t_name          default null
) is

    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := $$PLSQL_UNIT || '.EXPORT_RATES_DATA_14';
    
begin
    
    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': start'
    );
    
    export_rates_data_11(
        i_inst_id               =>    i_inst_id
      , i_eff_date              =>    i_eff_date
      , i_full_export           =>    i_full_export
      , i_base_rate_export      =>    i_base_rate_export
      , i_rate_type             =>    i_rate_type
      , i_subscriber_name       =>    i_subscriber_name
   );
   
    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': finish success'
    );
   
end export_rates_data_14;

procedure export_rates_data_15(
    i_inst_id             in    com_api_type_pkg.t_inst_id       default null
  , i_eff_date            in    date                             default null
  , i_full_export         in    com_api_type_pkg.t_boolean       default null
  , i_base_rate_export    in    com_api_type_pkg.t_boolean       default null
  , i_rate_type           in    com_api_type_pkg.t_dict_value    default null
  , i_subscriber_name     in    com_api_type_pkg.t_name          default null
) is

    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := $$PLSQL_UNIT || '.EXPORT_RATES_DATA_15';
    
begin
    
    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': start'
    );
    
    export_rates_data_11(
        i_inst_id               =>    i_inst_id
      , i_eff_date              =>    i_eff_date
      , i_full_export           =>    i_full_export
      , i_base_rate_export      =>    i_base_rate_export
      , i_rate_type             =>    i_rate_type
      , i_subscriber_name       =>    i_subscriber_name
   );
   
    trc_log_pkg.debug(
        i_text          => DEFAULT_PROCEDURE_NAME || ': finish success'
    );
   
end export_rates_data_15;

end itf_api_fraud_mon_version_pkg;
/
