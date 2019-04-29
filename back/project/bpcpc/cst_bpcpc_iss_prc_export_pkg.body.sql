create or replace package body cst_bpcpc_iss_prc_export_pkg as

CRLF                  constant com_api_type_pkg.t_name := chr(13) || chr(10);

function get_limit_id(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_instance_id       in      com_api_type_pkg.t_long_id
  , i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_service_id        in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_mask_error        in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_long_id
is
    l_params            com_api_type_pkg.t_param_tab;
begin
    rul_api_shared_data_pkg.load_card_params(
        i_card_id           => i_object_id
      , i_card_instance_id  => i_instance_id
      , io_params           => l_params
    );

    return prd_api_product_pkg.get_limit_id(
               i_product_id  => prd_api_product_pkg.get_product_id(
                                    i_entity_type => i_entity_type
                                  , i_object_id   => i_object_id
                                  , i_eff_date    => i_eff_date
                                  , i_inst_id     => i_inst_id
                                )
             , i_entity_type => i_entity_type
             , i_object_id   => i_object_id
             , i_limit_type  => i_limit_type
             , i_params      => l_params
             , i_service_id  => i_service_id
             , i_eff_date    => i_eff_date
             , i_split_hash  => i_split_hash
             , i_inst_id     => i_inst_id
             , i_mask_error  => i_mask_error
           );

exception
    when others then
        if i_mask_error = com_api_type_pkg.FALSE
           or
           com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.FALSE
        then
            raise;
        end if;

        return null;

end get_limit_id;

/*
 * Process for cards' unloading.
 * @param i_full_export          information about all cards will be unloaded.
 * @param i_include_address      include or not block of cardholder's address.
 * @param i_include_limits       include or not block of card's limits.
 * @param i_export_clear_pan     if it is FALSE then process unloads undecoded
 *     PANs (tokens) for case when Message Bus is capable to handle them.
 * @param i_count                count of <card_info> blocks per one XML-file.
 * @param i_include_notif        include cardholder notification settings block.
 * @param i_subscriber_name      subscriber procedure name.
 * @param i_include_contact      include cardholder primary contact block.
 * @param i_lang              - preffered language of retrieving address(es)
 * @param i_exclude_npz_cards    exclude not personalized cards.
 */
procedure export_cards_numbers(
    i_full_export         in     com_api_type_pkg.t_boolean    default null
  , i_event_type          in     com_api_type_pkg.t_dict_value default null
  , i_include_address     in     com_api_type_pkg.t_boolean    default null
  , i_include_limits      in     com_api_type_pkg.t_boolean    default null
  , i_export_clear_pan    in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_count               in     com_api_type_pkg.t_count
  , i_include_notif       in     com_api_type_pkg.t_boolean    default null
  , i_subscriber_name     in     com_api_type_pkg.t_name       default null
  , i_include_contact     in     com_api_type_pkg.t_boolean    default null
  , i_lang                in     com_api_type_pkg.t_dict_value default null
  , i_ids_type            in     com_api_type_pkg.t_dict_value default null
  , i_exclude_npz_cards   in     com_api_type_pkg.t_boolean    default null
) is
    pragma autonomous_transaction;

    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name :=
                                lower($$PLSQL_UNIT) || '.export_cards_numbers';
    -- Defult bulk size for <card_info> blocks per a file if <i_count> parameter is not specified
    DEFAULT_BULK_LIMIT      constant com_api_type_pkg.t_count := 2000;
    l_subscriber_name       com_api_type_pkg.t_name    := upper(nvl(i_subscriber_name, DEFAULT_PROCEDURE_NAME));
    l_full_export           com_api_type_pkg.t_boolean := nvl(i_full_export, com_api_type_pkg.FALSE);
    l_export_clear_pan      com_api_type_pkg.t_boolean := nvl(i_export_clear_pan, com_api_const_pkg.TRUE);
    l_customer_value_type   com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_file                  clob;
    l_current_count         com_api_type_pkg.t_count   := 0;
    l_total_count           com_api_type_pkg.t_count   := 0;
    l_counter               com_api_type_pkg.t_count   := 0;

    l_event_tab             com_api_type_pkg.t_number_tab;
    l_instance_id_tab       num_tab_tpt;
    l_estimation_tab        com_api_type_pkg.t_integer_tab;
    l_notif_event_tab       com_api_type_pkg.t_number_tab;

    l_lang                  com_api_type_pkg.t_dict_value;

    cursor cur_xml is
        with ids as (select * from table(cast(l_instance_id_tab as num_tab_tpt)))
        select
            xmlelement("cards_info"
              , xmlattributes('http://bpc.ru/sv/SVXP/card_info' as "xmlns")
              , xmlelement("file_type", iss_api_const_pkg.FILE_TYPE_CARD_INFO)
              , xmlelement("inst_id", i_inst_id)
              , xmlagg(xmlelement("card_info"
                  , xmlforest(
                        case l_export_clear_pan
                            when com_api_const_pkg.FALSE
                            then crd.card_number
                            else iss_api_token_pkg.decode_card_number(i_card_number => crd.card_number)
                        end as "card_number"
                      , crd.card_mask                 as "card_mask"
                      , crd.id                        as "card_id"
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
                        -- DF8013    Security ID (FF3F) in CREF; use security word of card, if it is null then use word for cardholder
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
                        -- DF807A    Agent Code (FF3F) in CREF
                      , (select a.agent_number
                           from ost_agent a
                          where a.id = ci.agent_id
                        )                             as "agent_number"
                      , nvl(pr.product_number, pr.id) as "product_number"
                    )
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
                           from (select id, min(lang) keep(dense_rank first order by decode(lang, l_lang, 1, 'LANGENG', 2, 3)) lang from com_person group by id) p2
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
                                select
                                    xmlagg(
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
                                   and (o.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                        and o.object_id = crd.cardholder_id
                                        or
                                        o.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                        and o.object_id = crd.customer_id
                                        and not exists (select *
                                                          from com_address_object ao
                                                         where ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                                           and ao.object_id   = crd.cardholder_id)
                                       )
                                   and a.lang = l_lang
                            )
                        end
                      -- notification
                      , case when nvl(i_include_notif, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
                            case
                                when prd_api_service_pkg.get_active_service_id(
                                         i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CARD
                                       , i_object_id           => ci.card_id
                                       , i_attr_name           => ntf_api_const_pkg.NOTIFICATION_SERVICE_USE_FEE
                                       , i_service_type_id     => ntf_api_const_pkg.NOTIFICATION_CARD_SERVICE
                                       , i_split_hash          => crd.split_hash
                                       , i_eff_date            => get_sysdate
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
                                                              , i_eff_date            => get_sysdate
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
                                       and co.custom_event_id = n.id
                                       and co.object_id       = crd.id
                                       and o.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                       and o.object_id(+)     = h.id
                                       and o.contact_type(+)  = com_api_const_pkg.CONTACT_TYPE_NOTIFICATION
                                       and d.contact_id(+)    = o.contact_id
                                       and d.commun_method(+) = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                                       and d.end_date is null
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
                                                              , i_eff_date            => get_sysdate
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
                                       and decode(eo.status, 'EVST0001', eo.procedure_name, null) = upper(DEFAULT_PROCEDURE_NAME)
                                       and eo.object_id       = crd.id
                                       and eo.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
                                       and eo.eff_date       <= com_api_sttl_day_pkg.get_sysdate
                                       and eo.split_hash      = ci.split_hash
                                       and eo.event_id        = e.id
                                       and e.event_type       = iss_api_const_pkg.EVENT_NOTIF_DEACTIVATION   -- close notification service
                                       and n.object_id(+)     = h.id
                                       and n.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                       and co.custom_event_id = n.id
                                       and co.object_id       = crd.id
                                       and o.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                       and o.object_id(+)     = h.id
                                       and o.contact_type(+)  = com_api_const_pkg.CONTACT_TYPE_NOTIFICATION
                                       and d.contact_id(+)    = o.contact_id
                                       and d.commun_method(+) = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                                       and d.end_date is null
                                       and (n.event_type is null or n.event_type != iss_api_const_pkg.EVENT_3D_SECURE_AUTH_REQUEST)
                                )
                            end
                        end
                      -- 3D secure
                      , case when nvl(i_include_notif, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
                            case
                                when prd_api_service_pkg.get_active_service_id(
                                         i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CARD
                                       , i_object_id           => ci.card_id
                                       , i_attr_name           => null
                                       , i_service_type_id     => ntf_api_const_pkg.THREE_D_SECURE_CARD_SERVICE
                                       , i_split_hash          => crd.split_hash
                                       , i_eff_date            => get_sysdate
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
                                                              , i_eff_date        => get_sysdate
                                                              , i_mask_error      => com_api_type_pkg.TRUE
                                                              , i_inst_id         => i_inst_id
                                                            ) as service_id
                                                       from dual)
                                                )
                                              , xmlelement("notification_event", e.event_type)
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
                                         , ntf_scheme_event e
                                         , com_contact_object o
                                         , com_contact_data d
                                     where h.id               = crd.cardholder_id
                                       and n.object_id(+)     = h.id
                                       and n.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                       and (n.event_type is null or n.event_type = iss_api_const_pkg.EVENT_3D_SECURE_AUTH_REQUEST)
                                       and co.custom_event_id = n.id
                                       and co.object_id       = crd.id
                                       and e.entity_type      = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                       and e.event_type       = iss_api_const_pkg.EVENT_3D_SECURE_AUTH_REQUEST
                                       and e.scheme_id        = prd_api_product_pkg.get_attr_value_number (
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
                                       and d.end_date is null
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
                                                              , i_eff_date            => get_sysdate
                                                              , i_last_active         => com_api_type_pkg.TRUE
                                                              , i_mask_error          => com_api_type_pkg.TRUE
                                                              , i_inst_id             => i_inst_id
                                                            ) service_id
                                                       from dual)
                                                )
                                              , xmlelement("notification_event", e.event_type)
                                              , xmlelement("delivery_channel", n.channel_id)
                                              , xmlelement("delivery_address", nvl(n.delivery_address, d.commun_address))
                                              , xmlelement("is_active", 0) --inactive
                                            )
                                        )
                                      from iss_cardholder h
                                         , ntf_custom_event n
                                         , ntf_custom_object co
                                         , ntf_scheme_event e
                                         , com_contact_object o
                                         , com_contact_data d
                                         , evt_event_object eo
                                         , evt_event ev
                                     where h.id               = crd.cardholder_id
                                       and n.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                       and n.object_id(+)     = h.id
                                       and (n.event_type is null or n.event_type = iss_api_const_pkg.EVENT_3D_SECURE_AUTH_REQUEST)
                                       and co.custom_event_id = n.id
                                       and co.object_id       = crd.id
                                       and e.entity_type      = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                       and e.event_type       = iss_api_const_pkg.EVENT_3D_SECURE_AUTH_REQUEST
                                       and e.scheme_id        = prd_api_product_pkg.get_attr_value_number (
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
                                       and d.end_date is null
                                       and decode(eo.status, 'EVST0001', eo.procedure_name, null) = upper(DEFAULT_PROCEDURE_NAME)
                                       and eo.object_id       = crd.id
                                       and eo.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
                                       and eo.eff_date       <= com_api_sttl_day_pkg.get_sysdate
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
                                   and o.contact_type(+)  = com_api_const_pkg.CONTACT_TYPE_PRIMARY
                                   and d.contact_id(+)    = o.contact_id
                                   and d.commun_method(+) = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                                   and d.end_date is null
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
                  , case
                        when nvl(i_include_limits, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then (
                            select
                                xmlelement("limits",
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
                                                                           when b.next_date > get_sysdate or b.next_date is null
                                                                           then b.next_date
                                                                           else fcl_api_cycle_pkg.calc_next_date(
                                                                                    i_cycle_type  => b.cycle_type
                                                                                  , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
                                                                                  , i_object_id   => crd.id
                                                                                  , i_split_hash  => crd.split_hash
                                                                                  , i_start_date  => com_api_sttl_day_pkg.get_sysdate()
                                                                                  , i_inst_id     => crd.inst_id
                                                                                )
                                                                       end)
                                          , xmlelement("length_type",  c.length_type)
                                          , xmlelement("cycle_length", nvl(c.cycle_length, 999))
                                        )
                                    )
                                )
                            from (
                                select x.limit_type
                                  from (
                                      select distinct a.object_type as limit_type
                                        from prd_attribute a
                                           , prd_service_type t
                                       where a.service_type_id = t.id
                                         and t.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
                                         and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                                  ) x
                                ) a
                              , fcl_limit l
                              , fcl_cycle c
                              , fcl_cycle_counter b
                            where l.id = get_limit_id(
                                             i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
                                           , i_object_id   => crd.id
                                           , i_instance_id => cip.id
                                           , i_limit_type  => a.limit_type
                                           , i_split_hash  => crd.split_hash
                                           , i_inst_id     => crd.inst_id
                                           , i_mask_error  => com_api_const_pkg.TRUE
                                         )
                              and c.id(+)          = l.cycle_id
                              and b.cycle_type(+)  = c.cycle_type
                              and b.entity_type(+) = iss_api_const_pkg.ENTITY_TYPE_CARD
                              and b.object_id(+)   = crd.id
                              and b.split_hash(+)  = crd.split_hash

                        )
                    end  --limits
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
        where ci.id in (select * from ids)
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
        ;

    cur_objects             sys_refcursor;

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
                select null -- event objects aren't used for full export mode
                     , max(ci.id)
                     , count(ci.card_id) over () as cards_count -- to avoid re-select query
                  from iss_card_instance ci
                 where ci.split_hash in (select split_hash from com_api_split_map_vw)
                   and (i_inst_id is null or ci.inst_id = i_inst_id)
              group by ci.card_id;
        else
            -- Get current cards' instances by events
            open o_cursor for
                select v.event_object_id
                     , max(v.card_instance_id)
                     , count(distinct v.card_id) over () as cards_count -- to avoid re-select query
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
                           and a.eff_date   <= com_api_sttl_day_pkg.get_sysdate
                           and ci.split_hash in (select split_hash from com_api_split_map_vw)
                           and (i_inst_id is null or ci.inst_id = i_inst_id)
                           and e.id          = a.event_id
                           and (i_event_type is null or i_event_type = e.event_type)
                           and (nvl(i_exclude_npz_cards, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE
                                or
                                i_exclude_npz_cards = com_api_type_pkg.TRUE
                                and ci.state != iss_api_const_pkg.CARD_STATE_PERSONALIZATION)
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
                           and a.eff_date   <= com_api_sttl_day_pkg.get_sysdate
                           and ci.split_hash in (select split_hash from com_api_split_map_vw)
                           and (i_inst_id is null or ci.inst_id = i_inst_id)
                           and e.id          = a.event_id
                           and (i_event_type is null or i_event_type = e.event_type)
                           and (nvl(i_exclude_npz_cards, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE
                                or
                                i_exclude_npz_cards = com_api_type_pkg.TRUE
                                and ci.state != iss_api_const_pkg.CARD_STATE_PERSONALIZATION)
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
                           and a.eff_date   <= com_api_sttl_day_pkg.get_sysdate
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
                        -- Also it is necessary to select all cards which products' attributes have been changed
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
                           and a.eff_date    <= com_api_sttl_day_pkg.get_sysdate()
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
                       ) v
              group by v.card_id
                     , v.event_object_id;
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

        trc_log_pkg.debug('File''s length [' || length(l_file) || ']');

    end save_file;

begin
    trc_log_pkg.debug(
        i_text       => DEFAULT_PROCEDURE_NAME || ': START with l_full_export [#1], i_include_address [#2]'
                                               || ', i_include_limits [#3], i_inst_id [#4], i_count [#5]'
      , i_env_param1 => l_full_export
      , i_env_param2 => i_include_address
      , i_env_param3 => i_include_limits
      , i_env_param4 => i_inst_id
      , i_env_param5 => i_count
    );

    l_lang := nvl(i_lang, com_ui_user_env_pkg.get_user_lang());

    -- If tokenization isn't used then there is no sense to call decoding function
    -- in then select section to reduce count of SQL-PLSQL context switches
    l_export_clear_pan :=
        case
            when iss_api_token_pkg.is_token_enabled() = com_api_const_pkg.TRUE
            then nvl(i_export_clear_pan, com_api_const_pkg.TRUE)
            else com_api_const_pkg.FALSE
        end;

    l_customer_value_type := iss_cst_export_pkg.get_customer_value_type;

    trc_log_pkg.debug(
        i_text       => 'l_export_clear_pan [#1] l_lang [#2] l_customer_value_type [#3]'
      , i_env_param1 => l_export_clear_pan
      , i_env_param2 => l_lang
      , i_env_param3 => l_customer_value_type
    );

    prc_api_stat_pkg.log_start;

    open_cur_objects(
        o_cursor      => cur_objects
      , i_full_export => l_full_export
      , i_inst_id     => i_inst_id
    );

    loop
        begin
            savepoint sp_before_iteration;

            l_current_count := 0;

            fetch cur_objects
             bulk collect into
                  l_event_tab
                , l_instance_id_tab
                , l_estimation_tab -- note: all elements are equal
            limit nvl(i_count, DEFAULT_BULK_LIMIT);

            trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

            if l_file is null then
                -- It executes only on first iteration to make estimation for
                -- entire process, not for a current file
                l_counter := case when l_estimation_tab.count() > 0
                                  then l_estimation_tab(1)
                                  else 0
                             end;
                prc_api_stat_pkg.log_estimation(
                    i_estimated_count => l_counter
                );
                trc_log_pkg.debug('Estimated count of cards is [' || l_counter || ']');

                l_counter := 0;
            end if;

            if l_instance_id_tab.count() > 0 then
                -- For every processing batch of card instances we fetch data and save it in a separate file
                open cur_xml;
                fetch cur_xml into l_file, l_current_count;
                close cur_xml;

                l_counter := l_counter + 1;

                save_file(
                    i_counter      => l_current_count
                );

                l_total_count := l_total_count + l_current_count;
            end if;

            if l_full_export = com_api_type_pkg.FALSE then
                -- In case of full export mode all elements of collection <l_event_tab> are null
                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab => l_event_tab
                );
            end if;

            prc_api_stat_pkg.log_current(
                i_current_count  => l_total_count
              , i_excepted_count => 0
            );

            -- Commit the current iteration in autonomous transaction.
            commit;

            exit when cur_objects%notfound;

        exception
            when others then
                rollback to sp_before_iteration;
                raise;
        end;
    end loop;

    close cur_objects;

    if l_full_export = com_api_type_pkg.TRUE and nvl(i_include_notif, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
        -- Process event objects for event close 3d secure service or close notification service
        select eo.id
          bulk collect
          into l_notif_event_tab
          from evt_event_object eo
             , evt_event ev
         where decode(eo.status, 'EVST0001', eo.procedure_name, null) = upper(DEFAULT_PROCEDURE_NAME)
           and eo.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
           and eo.eff_date       <= com_api_sttl_day_pkg.get_sysdate
           and eo.split_hash      in (select split_hash from com_api_split_map_vw)
           and eo.event_id        = ev.id
           and ev.event_type      in (iss_api_const_pkg.EVENT_3D_SECURE_DEACTIVATION, iss_api_const_pkg.EVENT_NOTIF_DEACTIVATION); -- close 3d secure service or notification service

        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab => l_notif_event_tab
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_excepted_total  => 0
      , i_processed_total => l_total_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(DEFAULT_PROCEDURE_NAME || ': FINISH');

    -- Commit the last process changes in autonomous transaction before exit.
    commit;
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        -- Commit the last process changes in autonomous transaction before exit.
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
end export_cards_numbers;

end cst_bpcpc_iss_prc_export_pkg;
/
