create or replace package body iss_ui_card_pkg is

procedure get_cardholder_cards(
    i_card_id                   in     com_api_type_pkg.t_medium_id
  , o_cards_tab                    out iss_ui_card_pkg.t_card_tab
) is
    l_cardholder_id                    com_api_type_pkg.t_medium_id;
begin
    l_cardholder_id := iss_api_cardholder_pkg.get_cardholder_by_card(
                           i_card_id    => i_card_id
                       );

    select c.id card_id
         , n.card_number
      bulk collect into
           o_cards_tab
      from iss_card c
         , iss_card_number_vw n
     where id != i_card_id
       and n.card_id = c.id
       and cardholder_id = l_cardholder_id
       and c.id not in (select object_id
                          from acc_account_object
                         where account_id in (select account_id
                                                from acc_account_object
                                               where object_id = i_card_id
                                                 and entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD)
                       );
end;

procedure get_cardholder_accounts(
    i_card_id                   in     com_api_type_pkg.t_medium_id
  , o_account_tab                  out iss_ui_card_pkg.t_account_tab
) is
    l_cardholder_id                    com_api_type_pkg.t_medium_id;
begin
    l_cardholder_id := iss_api_cardholder_pkg.get_cardholder_by_card(
                           i_card_id    => i_card_id
                       );

    select distinct
           o.account_id
         , a.account_number
         , cst_api_name_pkg.get_friendly_account_number(i_account_id     => a.id
                                                      , i_account_number => a.account_number
                                                      , i_currency       => a.currency
                                                      , i_account_type   => a.account_type)
      bulk collect into
           o_account_tab
      from acc_account_object o
         , acc_account a
     where o.object_id in (select id from iss_card where cardholder_id = l_cardholder_id)
       and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
       and a.id = o.account_id
       and a.id not in (select account_id
                          from acc_account_object
                         where object_id = i_card_id
                           and entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD);
end;

/*
 * Procedure for cards' unloading in XML format.
 * @param i_appl_id           - application identifier.
 * @param i_include_limits    - include or not block of card's limits.
 * @param i_lang              - preffered language of retrieving address(es)
 * @param o_batch_id          - batch identifier.
 * @param o_cards_info        - information about cards.
 */
procedure get_cards_info(
    i_appl_id           in     com_api_type_pkg.t_long_id
  , i_include_limits    in     com_api_type_pkg.t_boolean    default null
  , i_include_service   in     com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_lang              in     com_api_type_pkg.t_dict_value default null
  , o_batch_id             out com_api_type_pkg.t_short_id
  , o_cards_info           out clob
)
is
    l_export_clear_pan      com_api_type_pkg.t_boolean        := com_api_const_pkg.TRUE;
    l_customer_value_type   com_api_type_pkg.t_boolean        := com_api_const_pkg.FALSE;
    l_sysdate               date;
    l_lang                  com_api_type_pkg.t_dict_value;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_agent_id              com_api_type_pkg.t_agent_id;
    l_instance_id_tab       num_tab_tpt                       := num_tab_tpt();
    l_estimation_tab        com_api_type_pkg.t_integer_tab;
    l_seqnum                com_api_type_pkg.t_seqnum;
    l_service_id_tab        prd_service_tpt;
    l_warning_msg           com_api_type_pkg.t_text;

    cursor cur_xml
    is
    with products as (
        select connect_by_root id product_id
             , level level_priority
             , id parent_id
             , product_type
             , case when parent_id is null then 1 else 0 end top_flag
          from prd_product
       connect by prior parent_id = id
    )
    select xmlelement("cards_info"
              , xmlattributes('http://bpc.ru/sv/SVXP/card_info' as "xmlns")
              , xmlelement("file_type", iss_api_const_pkg.FILE_TYPE_CARD_INFO)
              , xmlelement("inst_id", l_inst_id)
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
                        -- DF8100
                      , cd.kcolb_nip                  as "pin_block"
                        -- DF8163
                      , 0                             as "pin_update_flag"
                      , crd.card_type_id              as "card_type_id" -- DF802F in block FF41 of CREF
                         -- DF862E in block FF41 of CREF
                      , case l_export_clear_pan
                            when com_api_const_pkg.FALSE
                            then cnp.card_number
                            else iss_api_token_pkg.decode_card_number(i_card_number => cnp.card_number)
                        end                           as "prev_card_number"
                      , case when cip.id is not null then iss_api_card_instance_pkg.get_card_uid(i_card_instance_id => cip.id) else null end as "prev_card_id"
                        -- DF807A - Agent Code (FF3F) in CREF
                      , (select a.agent_number
                           from ost_agent a
                          where a.id = ct.agent_id
                        )                             as "agent_number"
                      , com_api_i18n_pkg.get_text(
                            i_table_name  => 'OST_AGENT'
                          , i_column_name => 'NAME'
                          , i_object_id   => ct.agent_id
                          , i_lang        => l_lang
                        )                             as "agent_name"
                      , (select a.agent_number
                           from ost_agent a
                          where a.id = ci.agent_id
                        )                             as "delivery_agent_number"
                      , com_api_i18n_pkg.get_text(
                            i_table_name  => 'OST_AGENT'
                          , i_column_name => 'NAME'
                          , i_object_id   => ci.agent_id
                          , i_lang        => l_lang
                        )                             as "delivery_agent_name"
                      , nvl(pr.product_number, pr.id) as "product_number"
                      , com_api_i18n_pkg.get_text(
                            i_table_name  => 'PRD_PRODUCT'
                          , i_column_name => 'LABEL'
                          , i_object_id   => pr.id
                          , i_lang        => l_lang
                        )                             as "product_name"
                    )
                  , xmlelement("customer"
                      , xmlforest(
                            case
                                when l_customer_value_type = com_api_const_pkg.TRUE
                                then to_char(m.id)
                                else m.customer_number
                            end                       as "customer_number"
                          , m.id                      as "customer_id"
                          , m.category                as "customer_category"
                          , m.relation                as "customer_relation"
                          , m.resident                as "resident"
                          , m.nationality             as "nationality"
                          , m.credit_rating           as "credit_rating"
                          , m.money_laundry_risk      as "money_laundry_risk"
                          , m.money_laundry_reason    as "money_laundry_reason"
                        )
                        -- customer limits
                      , case when nvl(i_include_limits, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then (
                            case
                                when prd_api_service_pkg.get_active_service_id(
                                         i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                       , i_object_id           => crd.customer_id
                                       , i_attr_name           => null
                                       , i_service_type_id     => prd_api_const_pkg.CUSTOMER_MAINTENANCE_SERVICE
                                       , i_split_hash          => crd.split_hash
                                       , i_eff_date            => l_sysdate
                                       , i_mask_error          => com_api_const_pkg.TRUE
                                       , i_inst_id             => l_inst_id
                                     ) is not null
                                then (
                                    select xmlelement("limits",
                                           xmlagg(
                                               xmlelement("limit"
                                                 , xmlelement("limit_type",   l.limit_type)
                                                 , xmlelement("sum_limit",    nvl(l.sum_limit, 0))
                                                 , xmlelement("count_limit",  nvl(l.count_limit, 0))
                                                 , xmlelement("sum_current",  nvl(fcl_api_limit_pkg.get_limit_sum_curr(
                                                                                      i_limit_type  => l.limit_type
                                                                                    , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                                                                    , i_object_id   => crd.customer_id
                                                                                    , i_limit_id    => l.id
                                                                                    , i_split_hash  => crd.split_hash
                                                                                    , i_mask_error  => com_api_const_pkg.TRUE
                                                                                  )
                                                                                , 0
                                                                              )
                                                   )
                                                 , xmlelement("currency",     l.currency)
                                                 , xmlelement("next_date",    case
                                                                                  when b.next_date > l_sysdate or b.next_date is null
                                                                                  then b.next_date
                                                                                  else fcl_api_cycle_pkg.calc_next_date(
                                                                                           i_cycle_type  => b.cycle_type
                                                                                         , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                                                                         , i_object_id   => crd.customer_id
                                                                                         , i_split_hash  => crd.split_hash
                                                                                         , i_start_date  => l_sysdate
                                                                                         , i_inst_id     => crd.inst_id
                                                                                       )
                                                                              end)
                                                 , xmlelement("length_type",  c.length_type)
                                                 , xmlelement("cycle_length", nvl(c.cycle_length, 999))
                                                 , xmlelement("start_date",   to_char(limits.start_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                                 , xmlelement("end_date",     to_char(limits.end_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                               )
                                           )
                                       )
                                  from fcl_limit l
                                     , (select to_number(limit_id, com_api_const_pkg.NUMBER_FORMAT) limit_id
                                             , row_number() over (partition by customer_id, limit_type
                                                                      order by decode(level_priority, 0, 0, 1)
                                                                             , level_priority
                                                                             , start_date desc
                                                                             , register_timestamp desc
                                               ) rn
                                             , customer_id
                                             , split_hash
                                             , start_date
                                             , end_date
                                          from (
                                                select v.attr_value as limit_id
                                                     , 0 level_priority
                                                     , a.object_type as limit_type
                                                     , v.register_timestamp
                                                     , v.start_date
                                                     , v.end_date
                                                     , v.object_id as customer_id
                                                     , v.split_hash
                                                  from prd_attribute_value v
                                                     , prd_attribute a
                                                 where v.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                                   and a.entity_type  = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                                                   and a.id           = v.attr_id
                                                   and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                             union all
                                                select v.attr_value
                                                     , p.level_priority
                                                     , a.object_type as limit_type
                                                     , v.register_timestamp
                                                     , v.start_date
                                                     , v.end_date
                                                     , c.customer_id
                                                     , c.split_hash
                                                  from products p
                                                     , prd_attribute_value v
                                                     , prd_attribute a
                                                     , prd_service_type st
                                                     , prd_service s
                                                     , prd_product_service ps
                                                     , prd_contract c
                                                 where v.service_id      = s.id
                                                   and v.object_id       = decode(a.definition_level, 'SADLSRVC', s.id, p.parent_id)
                                                   and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                                   and v.attr_id         = a.id
                                                   and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                   and a.service_type_id = s.service_type_id
                                                   and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                                                   and st.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                                   and st.id             = s.service_type_id
                                                   and p.product_id      = ps.product_id
                                                   and s.id              = ps.service_id
                                                   and ps.product_id     = c.product_id
                                            ) tt
                                       ) limits
                                     , fcl_cycle c
                                     , fcl_cycle_counter b
                                 where limits.customer_id = crd.customer_id
                                   and limits.split_hash  = crd.split_hash
                                   and limits.rn          = 1
                                   and l.id               = limits.limit_id
                                   and c.id(+)            = l.cycle_id
                                   and b.cycle_type(+)    = c.cycle_type
                                   and b.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                   and b.object_id(+)     = crd.id
                                   and b.split_hash(+)    = crd.split_hash
                                     )
                            end
                        )
                        end --case (limits)
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
                          , ci.cardholder_name        as "cardholder_name"
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
                      , (select
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
                                 and not exists (select 1
                                                   from com_address_object ao
                                                  where ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                                    and ao.object_id   = crd.cardholder_id)
                                )
                            and a.lang = l_lang
                        )
                      -- notification
                      , case
                            when prd_api_service_pkg.get_active_service_id(
                                     i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CARD
                                   , i_object_id           => ci.card_id
                                   , i_attr_name           => ntf_api_const_pkg.NOTIFICATION_SERVICE_USE_FEE
                                   , i_service_type_id     => ntf_api_const_pkg.NOTIFICATION_CARD_SERVICE
                                   , i_split_hash          => crd.split_hash
                                   , i_eff_date            => com_api_sttl_day_pkg.get_calc_date(i_inst_id => crd.inst_id)
                                   , i_mask_error          => com_api_const_pkg.TRUE
                                   , i_inst_id             => crd.inst_id
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
                                                          , i_eff_date            => com_api_sttl_day_pkg.get_calc_date(i_inst_id => crd.inst_id)
                                                          , i_mask_error          => com_api_const_pkg.TRUE
                                                          , i_inst_id             => crd.inst_id
                                                        ) service_id
                                                   from dual)
                                            )
                                          , xmlelement(
                                                "start_date"
                                              , to_char(nvl2(n.delivery_address, n.start_date, d.start_date), com_api_const_pkg.XML_DATE_FORMAT)
                                            )
                                          , xmlelement(
                                                "end_date"
                                              , to_char(nvl2(n.delivery_address, n.end_date, d.end_date), com_api_const_pkg.XML_DATE_FORMAT)
                                            )
                                          , xmlelement("notification_event", nvl(n.event_type, aut_api_const_pkg.EVENT_AUTH_BY_CARD))
                                          , xmlelement("delivery_channel", n.channel_id)
                                          , xmlelement("delivery_address", nvl(n.delivery_address, d.commun_address))
                                          , xmlelement("is_active"
                                              , case
                                                    when co.is_active is not null then
                                                        co.is_active
                                                    when n.status = ntf_api_const_pkg.STATUS_DO_NOT_SEND then
                                                        com_api_const_pkg.FALSE
                                                    else
                                                        com_api_const_pkg.TRUE
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
                                   and (d.end_date is null or d.end_date > l_sysdate)
                                   and (n.event_type is null or n.event_type != iss_api_const_pkg.EVENT_3D_SECURE_AUTH_REQUEST)
                                )
                        end
                      -- 3D secure
                      , case
                            when prd_api_service_pkg.get_active_service_id(
                                     i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CARD
                                   , i_object_id           => ci.card_id
                                   , i_attr_name           => null
                                   , i_service_type_id     => ntf_api_const_pkg.THREE_D_SECURE_CARD_SERVICE
                                   , i_split_hash          => crd.split_hash
                                   , i_eff_date            => com_api_sttl_day_pkg.get_calc_date(i_inst_id => crd.inst_id)
                                   , i_mask_error          => com_api_const_pkg.TRUE
                                   , i_inst_id             => crd.inst_id
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
                                                          , i_eff_date        => com_api_sttl_day_pkg.get_calc_date(i_inst_id => crd.inst_id)
                                                          , i_mask_error      => com_api_const_pkg.TRUE
                                                          , i_inst_id         => crd.inst_id
                                                        ) as service_id
                                                   from dual)
                                            )
                                          , xmlelement(
                                                "start_date"
                                              , to_char(nvl2(dc.delivery_address, dc.start_date, d.start_date), com_api_const_pkg.XML_DATE_FORMAT)
                                            )
                                          , xmlelement(
                                                "end_date"
                                              , to_char(nvl2(dc.delivery_address, dc.end_date, d.end_date), com_api_const_pkg.XML_DATE_FORMAT)
                                            )
                                          , xmlelement("notification_event", e.event_type)
                                          , xmlelement("delivery_channel", n.channel_id)
                                          , xmlelement("delivery_address", nvl(n.delivery_address, d.commun_address))
                                          , xmlelement("is_active"
                                              , case
                                                    when co.is_active is not null then
                                                        co.is_active
                                                    when n.status = ntf_api_const_pkg.STATUS_DO_NOT_SEND then
                                                        com_api_const_pkg.FALSE
                                                    else
                                                        com_api_const_pkg.TRUE
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
                                     , (select n.id
                                             , n.channel_id
                                             , n.delivery_address
                                             , co.is_active
                                             , n.status
                                             , n.object_id
                                             , co.object_id   card_id
                                             , n.start_date
                                             , n.end_date
                                             , case when co.is_active = com_api_const_pkg.FALSE then 1 else row_number() over (partition by n.scheme_event_id, n.entity_type, n.object_id, co.object_id, co.is_active order by n.id desc) end rn
                                          from ntf_custom_event  n
                                             , ntf_custom_object co
                                         where n.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                           and (n.event_type is null
                                                or n.event_type = iss_api_const_pkg.EVENT_3D_SECURE_AUTH_REQUEST
                                               )
                                           and co.custom_event_id(+) = n.id
                                        ) dc
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
                                                               , i_mask_error      => com_api_const_pkg.TRUE
                                                             )
                                   and o.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                   and o.object_id(+)     = h.id
                                   and o.contact_type(+)  = com_api_const_pkg.CONTACT_TYPE_NOTIFICATION
                                   and d.contact_id(+)    = o.contact_id
                                   and d.commun_method(+) = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                                   and (d.end_date is null or d.end_date > l_sysdate)
                                   and dc.id(+)           = n.id
                                   and dc.object_id(+)    = crd.cardholder_id
                            )
                        end
                      -- Cardholder primary contact data
                      , (
                            select xmlagg(
                                       xmlelement("contact"
                                         , xmlelement("contact_type",   o.contact_type)
                                         , xmlelement("preferred_lang", c.preferred_lang)
                                         , xmlelement("commun_method",  d.commun_method)
                                         , xmlelement("commun_address", d.commun_address)
                                       )
                                   )
                              from iss_cardholder     h
                                 , com_contact_object o
                                 , com_contact        c
                                 , com_contact_data   d
                             where h.id               = crd.cardholder_id
                               and o.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                               and o.object_id(+)     = h.id
                               and o.contact_type(+)  = com_api_const_pkg.CONTACT_TYPE_PRIMARY
                               and c.id               = o.contact_id
                               and d.contact_id(+)    = o.contact_id
                               and d.commun_method(+) = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                               and (d.end_date is null or d.end_date > l_sysdate)
                        )
                    ) --cardholder
                  , case when ci.state != iss_api_const_pkg.CARD_STATE_CLOSED then (
                        select xmlagg(xmlelement("account",
                                   xmlforest(
                                       ac.account_number   as "account_number"
                                     , ac.currency         as "currency"
                                     , ac.account_type     as "account_type"
                                     , ac.status           as "account_status"
                                     , ao.is_pos_default   as "is_pos_default"
                                     , ao.is_atm_default   as "is_atm_default"
                                     , ao.is_atm_currency  as "is_atm_currency"
                                     , ao.is_pos_currency  as "is_pos_currency"
                                     , ao.link_flag        as "link_flag"
                                     )
                                   )
                                   order by link_flag
                               )
                          from iss_linked_account_vw ao  -- acc_account_object ao
                             , acc_account ac
                         where ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                           and ao.object_id   = crd.id
                           and ao.split_hash  = crd.split_hash
                           and ac.id          = ao.account_id
                           and ac.split_hash  = ao.split_hash
                        ) --account
                    end
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
                        when nvl(i_include_limits, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then (
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
                                          , xmlelement("start_date", to_char(limits.start_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                          , xmlelement("end_date", to_char(limits.end_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                        )
                                    )
                                )
                          from fcl_limit l
                             , (select to_number(limit_id, 'FM000000000000000000.0000') limit_id
                                     , row_number() over (partition by card_id, limit_type order by decode(level_priority, 0, 0, 1)
                                                                                                         , level_priority
                                                                                                         , start_date desc
                                                                                                         , register_timestamp desc) rn
                                     , card_id
                                     , split_hash
                                     , start_date
                                     , end_date
                                  from (
                                        select v.attr_value limit_id
                                             , 0 level_priority
                                             , a.object_type limit_type
                                             , v.register_timestamp
                                             , v.start_date
                                             , v.end_date
                                             , v.object_id  card_id
                                             , v.split_hash
                                          from prd_attribute_value v
                                             , prd_attribute a
                                         where v.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
                                           and a.entity_type  = fcl_api_const_pkg.ENTITY_TYPE_LIMIT  --'ENTTLIMT'
                                           and a.id           = v.attr_id
                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                     union all
                                        select v.attr_value
                                             , p.level_priority
                                             , a.object_type as limit_type
                                             , v.register_timestamp
                                             , v.start_date
                                             , v.end_date
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
                    end  --limits
                    --services
                  , case when nvl(i_include_service, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
                        (select xmlagg(
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
                        )
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
      from iss_card_vw crd
         , prd_contract ct
         , prd_product pr
         , prd_customer m
         , iss_cardholder h
         , iss_card_instance ci
         , iss_card_instance_data cd
         , iss_card_instance cip -- for preceding card instance
         , iss_card_number cnp
     where ci.id              in (select column_value from table(cast(l_instance_id_tab as num_tab_tpt)))
       and ci.split_hash      in (select split_hash from com_api_split_map_vw)
       and crd.id                 = ci.card_id
       and crd.split_hash         = ci.split_hash
       and ct.id                  = crd.contract_id
       and ct.split_hash          = ci.split_hash
       and pr.id                  = ct.product_id
       and m.id                   = crd.customer_id
       and m.split_hash           = ci.split_hash
       and crd.cardholder_id      = h.id(+)
       and cd.card_instance_id(+) = ci.id
       and cip.id(+)              = ci.preceding_card_instance_id
       and cip.split_hash(+)      = ci.split_hash
       and cnp.card_id(+)         = cip.card_id;

    cur_objects             sys_refcursor;

    -- Function returns a reference for a cursor with card instances being processed.
    -- In case of incremental unloading it also returns event objects' identifiers.
    procedure open_cur_objects(
        o_cursor               out sys_refcursor
      , i_appl_id           in     com_api_type_pkg.t_long_id
    ) is
    begin
        trc_log_pkg.debug('Opening a cursor for all card instances those are processed...');
        -- Get current instances for all available cards
        open o_cursor for
            select max(ci.id)
                 , count(ci.card_id) over () as cards_count -- to avoid re-select query
              from iss_card_instance ci
                 , app_object ao
                 , app_application a
             where ci.split_hash      in (select split_hash from com_api_split_map_vw)
               and ao.appl_id          = i_appl_id
               and ao.entity_type      = iss_api_const_pkg.ENTITY_TYPE_CARD
               and a.id                = ao.appl_id
               and a.appl_status       = app_api_const_pkg.APPL_STATUS_PROC_SUCCESS
               and ci.card_id          = ao.object_id
          group by ci.card_id;
        trc_log_pkg.debug('Cursor was opened...');
    end open_cur_objects;

begin
    -- If tokenization isn't used then there is no sense to call decoding function
    -- in then select section to reduce count of SQL-PLSQL context switches
    l_export_clear_pan := iss_api_token_pkg.is_token_enabled();

    l_customer_value_type := iss_cst_export_pkg.get_customer_value_type;
    l_lang                := coalesce(i_lang, com_ui_user_env_pkg.get_user_lang());
    l_sysdate             := com_api_sttl_day_pkg.get_sysdate;

    select inst_id, agent_id
      into l_inst_id, l_agent_id
      from app_application
     where id = i_appl_id;

    open_cur_objects(
        o_cursor      => cur_objects
      , i_appl_id     => i_appl_id
    );

    fetch cur_objects
     bulk collect into
          l_instance_id_tab
        , l_estimation_tab; -- note: all elements are equal

    select prd_service_tpr(
               s.id
             , t.id
             , get_text('prd_service_type', 'label', t.id, l_lang)
             , t.external_code
             , s.service_number
             , 1
             , null
           )
      bulk collect into
           l_service_id_tab
      from prd_service_type t
         , prd_service s
     where entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
       and product_type = prd_api_const_pkg.PRODUCT_TYPE_ISS --'PRDT0100'
       and t.id not in (ntf_api_const_pkg.NOTIFICATION_CARD_SERVICE
                      , ntf_api_const_pkg.THREE_D_SECURE_CARD_SERVICE)
       and s.service_type_id = t.id;

    open cur_xml;
    fetch cur_xml into o_cards_info;
    close cur_xml;

    -- Create batch ant put all cards ito this batch
    prs_ui_batch_pkg.add_batch(
        o_id                => o_batch_id
      , o_seqnum            => l_seqnum
      , i_inst_id           => l_inst_id
      , i_agent_id          => l_agent_id
      , i_product_id        => null
      , i_card_type_id      => null
      , i_blank_type_id     => null
      , i_card_count        => l_instance_id_tab.count
      , i_hsm_device_id     => null
      , i_status            => prs_api_const_pkg.BATCH_STATUS_INITIAL
      , i_sort_id           => 1002 -- Sorting by card number
      , i_perso_priority    => null
      , i_lang              => l_lang
      , i_batch_name        => to_char(i_appl_id)
      , i_reissue_reason    => null
      , i_force             => com_api_const_pkg.TRUE  -- force run, so remove info from previous run with this batch_name
    );

    for i in 1..l_instance_id_tab.count loop
        prs_ui_batch_card_pkg.add_batch_card(
            i_batch_id           => o_batch_id
          , i_card_instance_id   => l_instance_id_tab(i)
          , o_warning_msg        => l_warning_msg
        );
    end loop;
end;

/*
 * Procedure for card' unloading in XML format.
 * @param i_card_id           - card identifier.
 * @param i_include_limits    - include or not block of card's or account's limits.
 * @param i_include_service   - include or not block of account's services.
 * @param i_lang              - preffered language of retrieving address(es)
 * @param o_account_info      - information about account.
 * @param o_card_info         - information about card.
 */
procedure get_card_info(
    i_card_id           in     com_api_type_pkg.t_long_id
  , i_include_limits    in     com_api_type_pkg.t_boolean    default null
  , i_include_service   in     com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_lang              in     com_api_type_pkg.t_dict_value default null
  , o_account_info         out clob
  , o_card_info            out clob
)
is
    l_export_clear_pan      com_api_type_pkg.t_boolean        := com_api_const_pkg.TRUE;
    l_customer_value_type   com_api_type_pkg.t_boolean        := com_api_const_pkg.FALSE;
    l_sysdate               date;
    l_lang                  com_api_type_pkg.t_dict_value;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_card_instance_id      com_api_type_pkg.t_long_id;
    l_account_id_tab        num_tab_tpt                       := num_tab_tpt();
    l_service_id_tab        prd_service_tpt;

    cursor cur_xml is
    with products as (
        select connect_by_root id product_id
             , level level_priority
             , id parent_id
             , product_type
             , case when parent_id is null then 1 else 0 end top_flag
          from prd_product
       connect by prior parent_id = id
    )
    select xmlelement("cards_info"
              , xmlattributes('http://bpc.ru/sv/SVXP/card_info' as "xmlns")
              , xmlelement("file_type", iss_api_const_pkg.FILE_TYPE_CARD_INFO)
              , xmlelement("inst_id", l_inst_id)
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
                        -- DF8100
                      , cd.kcolb_nip                  as "pin_block"
                        -- DF8163
                      , 0                             as "pin_update_flag"
                      , crd.card_type_id              as "card_type_id" -- DF802F in block FF41 of CREF
                         -- DF862E in block FF41 of CREF
                      , case l_export_clear_pan
                            when com_api_const_pkg.FALSE
                            then cnp.card_number
                            else iss_api_token_pkg.decode_card_number(i_card_number => cnp.card_number)
                        end as "prev_card_number"
                      , case when cip.id is not null then iss_api_card_instance_pkg.get_card_uid(i_card_instance_id => cip.id) else null end as "prev_card_id"
                        -- DF807A - Agent Code (FF3F) in CREF
                      , (select a.agent_number
                           from ost_agent a
                          where a.id = ct.agent_id
                        )                             as "agent_number"
                      , com_api_i18n_pkg.get_text(
                            i_table_name  => 'OST_AGENT'
                          , i_column_name => 'NAME'
                          , i_object_id   => ct.agent_id
                          , i_lang        => l_lang
                        )                             as "agent_name"
                      , (select a.agent_number
                           from ost_agent a
                          where a.id = ci.agent_id
                        )                             as "delivery_agent_number"
                      , com_api_i18n_pkg.get_text(
                            i_table_name  => 'OST_AGENT'
                          , i_column_name => 'NAME'
                          , i_object_id   => ci.agent_id
                          , i_lang        => l_lang
                        )                             as "delivery_agent_name"
                      , nvl(pr.product_number, pr.id) as "product_number"
                      , com_api_i18n_pkg.get_text(
                            i_table_name  => 'PRD_PRODUCT'
                          , i_column_name => 'LABEL'
                          , i_object_id   => pr.id
                          , i_lang        => l_lang
                        )                             as "product_name"
                    )
                  , xmlelement("customer"
                      , xmlforest(
                            case
                                when l_customer_value_type = com_api_const_pkg.TRUE
                                then to_char(m.id)
                                else m.customer_number
                            end                       as "customer_number"
                          , m.id                      as "customer_id"
                          , m.category                as "customer_category"
                          , m.relation                as "customer_relation"
                          , m.resident                as "resident"
                          , m.nationality             as "nationality"
                          , m.credit_rating           as "credit_rating"
                          , m.money_laundry_risk      as "money_laundry_risk"
                          , m.money_laundry_reason    as "money_laundry_reason"
                        )
                       -- customer limits
                      , case when nvl(i_include_limits, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then (
                            case
                                when prd_api_service_pkg.get_active_service_id(
                                         i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                       , i_object_id           => crd.customer_id
                                       , i_attr_name           => null
                                       , i_service_type_id     => prd_api_const_pkg.CUSTOMER_MAINTENANCE_SERVICE
                                       , i_split_hash          => crd.split_hash
                                       , i_eff_date            => l_sysdate
                                       , i_mask_error          => com_api_const_pkg.TRUE
                                       , i_inst_id             => l_inst_id
                                     ) is not null
                                then (
                                    select xmlelement("limits",
                                           xmlagg(
                                               xmlelement("limit"
                                                 , xmlelement("limit_type",   l.limit_type)
                                                 , xmlelement("sum_limit",    nvl(l.sum_limit, 0))
                                                 , xmlelement("count_limit",  nvl(l.count_limit, 0))
                                                 , xmlelement("sum_current",  nvl(fcl_api_limit_pkg.get_limit_sum_curr(
                                                                                      i_limit_type  => l.limit_type
                                                                                    , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                                                                    , i_object_id   => crd.customer_id
                                                                                    , i_limit_id    => l.id
                                                                                    , i_split_hash  => crd.split_hash
                                                                                    , i_mask_error  => com_api_const_pkg.TRUE
                                                                                  )
                                                                                , 0
                                                                              )
                                                   )
                                                 , xmlelement("currency",     l.currency)
                                                 , xmlelement("next_date",    case
                                                                                  when b.next_date > l_sysdate or b.next_date is null
                                                                                  then b.next_date
                                                                                  else fcl_api_cycle_pkg.calc_next_date(
                                                                                           i_cycle_type  => b.cycle_type
                                                                                         , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                                                                         , i_object_id   => crd.customer_id
                                                                                         , i_split_hash  => crd.split_hash
                                                                                         , i_start_date  => l_sysdate
                                                                                         , i_inst_id     => crd.inst_id
                                                                                       )
                                                                              end)
                                                 , xmlelement("length_type",  c.length_type)
                                                 , xmlelement("cycle_length", nvl(c.cycle_length, 999))
                                                 , xmlelement("start_date",   to_char(limits.start_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                                 , xmlelement("end_date",     to_char(limits.end_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                               )
                                           )
                                       )
                                  from fcl_limit l
                                     , (select to_number(limit_id, com_api_const_pkg.NUMBER_FORMAT) limit_id
                                             , row_number() over (partition by customer_id, limit_type
                                                                      order by decode(level_priority, 0, 0, 1)
                                                                             , level_priority
                                                                             , start_date desc
                                                                             , register_timestamp desc
                                               ) rn
                                             , customer_id
                                             , split_hash
                                             , start_date
                                             , end_date
                                          from (
                                                select v.attr_value as limit_id
                                                     , 0 level_priority
                                                     , a.object_type as limit_type
                                                     , v.register_timestamp
                                                     , v.start_date
                                                     , v.end_date
                                                     , v.object_id as customer_id
                                                     , v.split_hash
                                                  from prd_attribute_value v
                                                     , prd_attribute a
                                                 where v.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                                   and a.entity_type  = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                                                   and a.id           = v.attr_id
                                                   and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                             union all
                                                select v.attr_value
                                                     , p.level_priority
                                                     , a.object_type as limit_type
                                                     , v.register_timestamp
                                                     , v.start_date
                                                     , v.end_date
                                                     , c.customer_id
                                                     , c.split_hash
                                                  from products p
                                                     , prd_attribute_value v
                                                     , prd_attribute a
                                                     , prd_service_type st
                                                     , prd_service s
                                                     , prd_product_service ps
                                                     , prd_contract c
                                                 where v.service_id      = s.id
                                                   and v.object_id       = decode(a.definition_level, 'SADLSRVC', s.id, p.parent_id)
                                                   and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                                   and v.attr_id         = a.id
                                                   and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                   and a.service_type_id = s.service_type_id
                                                   and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                                                   and st.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                                   and st.id             = s.service_type_id
                                                   and p.product_id      = ps.product_id
                                                   and s.id              = ps.service_id
                                                   and ps.product_id     = c.product_id
                                            ) tt
                                       ) limits
                                     , fcl_cycle c
                                     , fcl_cycle_counter b
                                 where limits.customer_id = crd.customer_id
                                   and limits.split_hash  = crd.split_hash
                                   and limits.rn          = 1
                                   and l.id               = limits.limit_id
                                   and c.id(+)            = l.cycle_id
                                   and b.cycle_type(+)    = c.cycle_type
                                   and b.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                   and b.object_id(+)     = crd.id
                                   and b.split_hash(+)    = crd.split_hash
                                     )
                            end
                        )
                        end --case (limits)
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
                          , ci.cardholder_name        as "cardholder_name"
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
                      , (select
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
                                 and not exists (select 1
                                                   from com_address_object ao
                                                  where ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                                    and ao.object_id   = crd.cardholder_id)
                                )
                            and a.lang = l_lang
                        )
                      -- notification
                      , case
                            when prd_api_service_pkg.get_active_service_id(
                                     i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CARD
                                   , i_object_id           => ci.card_id
                                   , i_attr_name           => ntf_api_const_pkg.NOTIFICATION_SERVICE_USE_FEE
                                   , i_service_type_id     => ntf_api_const_pkg.NOTIFICATION_CARD_SERVICE
                                   , i_split_hash          => crd.split_hash
                                   , i_eff_date            => com_api_sttl_day_pkg.get_calc_date(i_inst_id => crd.inst_id)
                                   , i_mask_error          => com_api_const_pkg.TRUE
                                   , i_inst_id             => crd.inst_id
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
                                                          , i_eff_date            => com_api_sttl_day_pkg.get_calc_date(i_inst_id => crd.inst_id)
                                                          , i_mask_error          => com_api_const_pkg.TRUE
                                                          , i_inst_id             => crd.inst_id
                                                        ) service_id
                                                   from dual)
                                            )
                                          , xmlelement(
                                                "start_date"
                                              , to_char(nvl2(n.delivery_address, n.start_date, d.start_date), com_api_const_pkg.XML_DATE_FORMAT)
                                            )
                                          , xmlelement(
                                                "end_date"
                                              , to_char(nvl2(n.delivery_address, n.end_date, d.end_date), com_api_const_pkg.XML_DATE_FORMAT)
                                            )
                                          , xmlelement("notification_event", nvl(n.event_type, aut_api_const_pkg.EVENT_AUTH_BY_CARD))
                                          , xmlelement("delivery_channel", n.channel_id)
                                          , xmlelement("delivery_address", nvl(n.delivery_address, d.commun_address))
                                          , xmlelement("is_active"
                                              , case
                                                    when co.is_active is not null then
                                                        co.is_active
                                                    when n.status = ntf_api_const_pkg.STATUS_DO_NOT_SEND then
                                                        com_api_const_pkg.FALSE
                                                    else
                                                        com_api_const_pkg.TRUE
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
                                   and (d.end_date is null or d.end_date > l_sysdate)
                                   and (n.event_type is null or n.event_type != iss_api_const_pkg.EVENT_3D_SECURE_AUTH_REQUEST)
                                )
                        end
                      -- 3D secure
                      , case
                            when prd_api_service_pkg.get_active_service_id(
                                     i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CARD
                                   , i_object_id           => ci.card_id
                                   , i_attr_name           => null
                                   , i_service_type_id     => ntf_api_const_pkg.THREE_D_SECURE_CARD_SERVICE
                                   , i_split_hash          => crd.split_hash
                                   , i_eff_date            => com_api_sttl_day_pkg.get_calc_date(i_inst_id => crd.inst_id)
                                   , i_mask_error          => com_api_const_pkg.TRUE
                                   , i_inst_id             => crd.inst_id
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
                                                          , i_eff_date        => com_api_sttl_day_pkg.get_calc_date(i_inst_id => crd.inst_id)
                                                          , i_mask_error      => com_api_const_pkg.TRUE
                                                          , i_inst_id         => crd.inst_id
                                                        ) as service_id
                                                   from dual)
                                            )
                                          , xmlelement(
                                                "start_date"
                                              , to_char(nvl2(dc.delivery_address, dc.start_date, d.start_date), com_api_const_pkg.XML_DATE_FORMAT)
                                            )
                                          , xmlelement(
                                                "end_date"
                                              , to_char(nvl2(dc.delivery_address, dc.end_date, d.end_date), com_api_const_pkg.XML_DATE_FORMAT)
                                            )
                                          , xmlelement("notification_event", e.event_type)
                                          , xmlelement("delivery_channel", n.channel_id)
                                          , xmlelement("delivery_address", nvl(n.delivery_address, d.commun_address))
                                          , xmlelement("is_active"
                                              , case
                                                    when co.is_active is not null then
                                                        co.is_active
                                                    when n.status = ntf_api_const_pkg.STATUS_DO_NOT_SEND then
                                                        com_api_const_pkg.FALSE
                                                    else
                                                        com_api_const_pkg.TRUE
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
                                     , (select n.id
                                             , n.channel_id
                                             , n.delivery_address
                                             , co.is_active
                                             , n.status
                                             , n.object_id
                                             , co.object_id   card_id
                                             , n.start_date
                                             , n.end_date
                                             , case when co.is_active = com_api_const_pkg.FALSE then 1 else row_number() over (partition by n.scheme_event_id, n.entity_type, n.object_id, co.object_id, co.is_active order by n.id desc) end rn
                                          from ntf_custom_event  n
                                             , ntf_custom_object co
                                         where n.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                           and (n.event_type is null
                                                or n.event_type = iss_api_const_pkg.EVENT_3D_SECURE_AUTH_REQUEST
                                               )
                                           and co.custom_event_id(+) = n.id
                                        ) dc
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
                                                               , i_mask_error      => com_api_const_pkg.TRUE
                                                             )
                                   and o.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                   and o.object_id(+)     = h.id
                                   and o.contact_type(+)  = com_api_const_pkg.CONTACT_TYPE_NOTIFICATION
                                   and d.contact_id(+)    = o.contact_id
                                   and d.commun_method(+) = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                                   and (d.end_date is null or d.end_date > l_sysdate)
                                   and dc.id(+)           = n.id
                                   and dc.object_id(+)    = crd.cardholder_id
                            )
                        end
                      -- Cardholder primary contact data
                      , (
                            select xmlagg(
                                       xmlelement("contact"
                                         , xmlelement("contact_type",   o.contact_type)
                                         , xmlelement("preferred_lang", c.preferred_lang)
                                         , xmlelement("commun_method",  d.commun_method)
                                         , xmlelement("commun_address", d.commun_address)
                                       )
                                   )
                              from iss_cardholder h
                                 , com_contact_object o
                                 , com_contact        c
                                 , com_contact_data d
                             where h.id               = crd.cardholder_id
                               and o.entity_type(+)   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                               and o.object_id(+)     = h.id
                               and o.contact_type(+)  = com_api_const_pkg.CONTACT_TYPE_PRIMARY
                               and c.id               = o.contact_id
                               and d.contact_id(+)    = o.contact_id
                               and d.commun_method(+) = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                               and (d.end_date is null or d.end_date > l_sysdate)
                        )
                    ) --cardholder
                  , case when ci.state != iss_api_const_pkg.CARD_STATE_CLOSED then (
                        select xmlagg(xmlelement("account",
                                   xmlforest(
                                       ac.account_number   as "account_number"
                                     , ac.currency         as "currency"
                                     , ac.account_type     as "account_type"
                                     , ac.status           as "account_status"
                                     , ao.is_pos_default   as "is_pos_default"
                                     , ao.is_atm_default   as "is_atm_default"
                                     , ao.is_atm_currency  as "is_atm_currency"
                                     , ao.is_pos_currency  as "is_pos_currency"
                                     , ao.link_flag        as "link_flag"
                                     )
                                   )
                                   order by link_flag
                               )
                          from iss_linked_account_vw ao  -- acc_account_object ao
                             , acc_account ac
                         where ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                           and ao.object_id   = crd.id
                           and ao.split_hash  = crd.split_hash
                           and ac.id          = ao.account_id
                           and ac.split_hash  = ao.split_hash
                        ) --account
                    end
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
                        when nvl(i_include_limits, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then (
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
                                          , xmlelement("start_date", to_char(limits.start_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                          , xmlelement("end_date", to_char(limits.end_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                        )
                                    )
                                )
                          from fcl_limit l
                             , (select to_number(limit_id, 'FM000000000000000000.0000') limit_id
                                     , row_number() over (partition by card_id, limit_type order by decode(level_priority, 0, 0, 1)
                                                                                                         , level_priority
                                                                                                         , start_date desc
                                                                                                         , register_timestamp desc) rn
                                     , card_id
                                     , split_hash
                                     , start_date
                                     , end_date
                                  from (
                                        select v.attr_value limit_id
                                             , 0 level_priority
                                             , a.object_type limit_type
                                             , v.register_timestamp
                                             , v.start_date
                                             , v.end_date
                                             , v.object_id  card_id
                                             , v.split_hash
                                          from prd_attribute_value v
                                             , prd_attribute a
                                         where v.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
                                           and a.entity_type  = fcl_api_const_pkg.ENTITY_TYPE_LIMIT  --'ENTTLIMT'
                                           and a.id           = v.attr_id
                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                     union all
                                        select v.attr_value
                                             , p.level_priority
                                             , a.object_type as limit_type
                                             , v.register_timestamp
                                             , v.start_date
                                             , v.end_date
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
                    end  --limits
                    --services
                  , case when nvl(i_include_service, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
                        (select xmlagg(
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
                        )
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
      from iss_card_vw crd
         , prd_contract ct
         , prd_product pr
         , prd_customer m
         , iss_cardholder h
         , iss_card_instance ci
         , iss_card_instance_data cd
         , iss_card_instance cip -- for preceding card instance
         , iss_card_number cnp
     where ci.id               = l_card_instance_id
       and ci.split_hash      in (select split_hash from com_api_split_map_vw)
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
       and cnp.card_id(+)      = cip.card_id;

    cursor main_limit_cur_xml is
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
            xmlelement("accounts", xmlattributes('http://sv.bpc.in/SVXP' as "xmlns")
              , xmlelement("file_type",     acc_api_const_pkg.FILE_TYPE_ACCOUNTS)
              , xmlelement("date_purpose",  com_api_const_pkg.DATE_PURPOSE_PROCESSING)
              , xmlelement("start_date",    to_char(l_sysdate, 'yyyy-mm-dd'))
              , xmlelement("end_date",      to_char(l_sysdate, 'yyyy-mm-dd'))
              , xmlelement("inst_id",       l_inst_id)
              , xmlelement("tokenized_pan", case l_export_clear_pan
                                                when com_api_const_pkg.FALSE
                                                then com_api_const_pkg.TRUE
                                                else com_api_const_pkg.FALSE
                                            end)
              , xmlagg(xmlelement("account", xmlattributes(g.account_id as "id")
                  , xmlelement("account_number",  min(g.account_number))
                  , xmlelement("currency",        min(g.currency))
                  , xmlelement("account_type",    min(g.account_type))
                  , xmlelement("account_status",  min(g.status))
                  , xmlelement("aval_balance",    min(g.aval_balance))
                  , xmlelement("create_date",     min(to_char(g.open_date, com_api_const_pkg.XML_DATE_FORMAT)))
                  , ( --xmlagg support only 1 level
                     select xmlagg(xmlelement("balance", xmlattributes(b.id as "id")
                              , xmlelement("balance_type", b.balance_type)
                              , xmlelement("turnover"
                                  , xmlelement("outgoing_balance", b.balance)
                                )
                            ))
                       from acc_balance b
                      where b.account_id = g.account_id
                        and b.split_hash = g.split_hash
                    )
                  , case when nvl(i_include_limits, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then (
                        select xmlelement("limits",
                                   xmlagg(xmlelement("limit"
                                     , xmlelement("limit_type",   l.limit_type)
                                     , xmlelement("sum_limit",
                                           case when l.limit_base is not null and l.limit_rate is not null
                                           then
                                               nvl(fcl_api_limit_pkg.get_limit_border_sum(
                                                       i_entity_type          => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                     , i_object_id            => g.account_id
                                                     , i_limit_type           => l.limit_type
                                                     , i_limit_base           => l.limit_base
                                                     , i_limit_rate           => l.limit_rate
                                                     , i_currency             => l.currency
                                                     , i_inst_id              => g.inst_id
                                                     , i_product_id           => prd_api_product_pkg.get_product_id(
                                                                                     i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                                                   , i_object_id         => g.account_id
                                                                                   , i_inst_id           => g.inst_id
                                                                                 )
                                                     , i_split_hash           => g.split_hash
                                                     , i_mask_error           => com_api_const_pkg.TRUE
                                                  ), 0
                                               )
                                           else
                                               nvl(l.sum_limit, 0)
                                           end
                                       )
                                     , xmlelement("count_limit",
                                           case when l.limit_base is not null and l.limit_rate is not null
                                           then
                                               nvl(fcl_api_limit_pkg.get_limit_border_count(
                                                       i_entity_type          => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                     , i_object_id            => g.account_id
                                                     , i_limit_type           => l.limit_type
                                                     , i_limit_base           => l.limit_base
                                                     , i_limit_rate           => l.limit_rate
                                                     , i_currency             => l.currency
                                                     , i_inst_id              => g.inst_id
                                                     , i_product_id           => prd_api_product_pkg.get_product_id(
                                                                                     i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                                                   , i_object_id         => g.account_id
                                                                                   , i_inst_id           => g.inst_id
                                                                                 )
                                                     , i_split_hash           => g.split_hash
                                                     , i_mask_error           => com_api_const_pkg.TRUE
                                                  ), 0
                                               )
                                           else
                                               nvl(l.count_limit, 0)
                                           end
                                       )
                                     , xmlelement("sum_current",  nvl(fcl_api_limit_pkg.get_limit_sum_curr(
                                                                          i_limit_type   => l.limit_type
                                                                        , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                                        , i_object_id    => g.account_id
                                                                        , i_limit_id     => l.id
                                                                        , i_mask_error   => com_api_type_pkg.FALSE
                                                                        , i_split_hash   => g.split_hash
                                                                      )
                                                                    , 0))
                                     , xmlelement("currency",     l.currency)
                                     , xmlelement("next_date",    case when b.next_date > l_sysdate or b.next_date is null
                                                                       then b.next_date
                                                                       else fcl_api_cycle_pkg.calc_next_date(
                                                                                i_cycle_type  => b.cycle_type
                                                                              , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                                              , i_object_id   => g.account_id
                                                                              , i_split_hash  => g.split_hash
                                                                              , i_start_date  => l_sysdate
                                                                              , i_inst_id     => g.inst_id
                                                                            )
                                                                  end
                                                 )
                                     , xmlelement("length_type",  c.length_type)
                                     , xmlelement("cycle_length", c.cycle_length)
                                     , xmlelement("start_date", to_char(limits.start_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                     , xmlelement("end_date", to_char(limits.end_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                                   ))
                               )
                          from fcl_limit l
                             , (select to_number(limit_id, 'FM000000000000000000.0000') limit_id
                                     , row_number() over (partition by account_id, limit_type order by decode(level_priority, 0, 0, 1)
                                                                                                            , level_priority
                                                                                                            , start_date desc
                                                                                                            , register_timestamp desc) rn
                                     , account_id
                                     , split_hash
                                     , start_date
                                     , end_date
                                  from (
                                        select v.attr_value limit_id
                                             , 0 level_priority
                                             , a.object_type limit_type
                                             , v.register_timestamp
                                             , v.start_date
                                             , v.end_date
                                             , v.object_id  account_id
                                             , v.split_hash
                                          from prd_attribute_value v
                                             , prd_attribute a
                                         where v.entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                           and a.entity_type  = fcl_api_const_pkg.ENTITY_TYPE_LIMIT  --'ENTTLIMT'
                                           and a.id           = v.attr_id
                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                     union all
                                        select v.attr_value
                                             , p.level_priority
                                             , a.object_type limit_type
                                             , v.register_timestamp
                                             , v.start_date
                                             , v.end_date
                                             , ac.id  account_id
                                             , ac.split_hash
                                          from products p
                                             , prd_attribute_value v
                                             , prd_attribute a
                                             , prd_service_type st
                                             , prd_service s
                                             , prd_product_service ps
                                             , prd_contract c
                                             , acc_account ac
                                         where v.service_id      = s.id
                                           and v.object_id       = decode(a.definition_level, 'SADLSRVC', s.id, p.parent_id)
                                           and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                           and v.attr_id         = a.id
                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                           and a.service_type_id = s.service_type_id
                                           and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT  --'ENTTLIMT'
                                           and st.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                           and st.id             = s.service_type_id
                                           and p.product_id      = ps.product_id
                                           and s.id              = ps.service_id
                                           and ps.product_id     = c.product_id
                                           and c.id              = ac.contract_id
                                           and c.split_hash      = ac.split_hash
                                           -- Get active service id with subquery instead of the "prd_api_service_pkg.get_active_service_id" function
                                           and s.id = coalesce(
                                                          (
                                                              select min(service_id)
                                                                from prd_service_object o
                                                                   , prd_service s
                                                               where o.service_id      = s.id
                                                                 and s.service_type_id = a.service_type_id
                                                                 and o.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                                 and o.object_id       = ac.id
                                                                 and o.split_hash      = ac.split_hash
                                                                 and l_sysdate between nvl(trunc(o.start_date), l_sysdate) and nvl(o.end_date, trunc(l_sysdate)+1)
                                                          )
                                                            -- Save debug message when active service is not exist
                                                          , prd_api_service_pkg.message_no_active_service(
                                                                i_entity_type          => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                              , i_object_id            => ac.id
                                                              , i_limit_type           => a.object_type
                                                              , i_eff_date             => l_sysdate
                                                            )
                                                      )
                                    ) tt
                               ) limits
                             , fcl_cycle c
                             , fcl_cycle_counter b
                         where limits.account_id = g.account_id
                           and limits.split_hash = g.split_hash
                           and limits.rn         = 1
                           and l.id              = limits.limit_id
                           and c.id(+)           = l.cycle_id
                           and b.cycle_type(+)   = c.cycle_type
                           and b.entity_type(+)  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                           and b.object_id(+)    = g.account_id
                           and b.split_hash(+)   = g.split_hash
                        )
                    end
                  -- services
                  , case when nvl(i_include_service, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then (
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
                                                       , row_number() over (partition by account_id, attr_name
                                                                                order by decode(level_priority, 0, 0, 1)
                                                                                       , level_priority
                                                                                       , start_date desc
                                                                                       , register_timestamp desc
                                                         ) rn
                                                       , account_id
                                                       , split_hash
                                                       , attr_name
                                                       , service_id
                                                    from (
                                                        select v.attr_value
                                                             , 0 level_priority
                                                             , a.object_type
                                                             , v.register_timestamp
                                                             , v.start_date
                                                             , v.object_id  account_id
                                                             , v.split_hash
                                                             , a.attr_name
                                                             , v.service_id
                                                          from prd_attribute_value v
                                                             , prd_attribute a
                                                         where v.entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                                                           and a.entity_type  is null
                                                           and a.data_type    = com_api_const_pkg.DATA_TYPE_CHAR --'DTTPCHAR'
                                                           and a.id           = v.attr_id
                                                           and v.service_id in (select id from table(cast(l_service_id_tab as prd_service_tpt)))
                                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                     union all
                                                        select v.attr_value
                                                             , p.level_priority
                                                             , a.object_type
                                                             , v.register_timestamp
                                                             , v.start_date
                                                             , ac.id  account_id
                                                             , ac.split_hash
                                                             , a.attr_name
                                                             , v.service_id
                                                          from products p
                                                             , prd_attribute_value v
                                                             , prd_attribute a
                                                             , (select distinct id, service_type_id from table(cast(l_service_id_tab as prd_service_tpt))) srv
                                                             , prd_product_service ps
                                                             , prd_contract c
                                                             , acc_account ac
                                                         where v.service_id      = srv.id
                                                           and v.object_id       = decode(a.definition_level, 'SADLSRVC', srv.id, p.parent_id)
                                                           and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                                           and v.attr_id         = a.id
                                                           and a.service_type_id = srv.service_type_id
                                                           and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                           and a.entity_type  is null
                                                           and a.data_type       = com_api_const_pkg.DATA_TYPE_CHAR --'DTTPCHAR'
                                                           and ps.service_id     = srv.id
                                                           and ps.service_id     = v.service_id
                                                           and p.product_id      = ps.product_id
                                                           and ps.product_id     = c.product_id
                                                           and c.id              = ac.contract_id
                                                           and c.split_hash      = ac.split_hash
                                                     ) tt
                                                  ) attr
                                              where attr.rn = 1
                                                and attr.service_id = s.id
                                                and attr.account_id = b.object_id
                                                and attr.split_hash = b.split_hash
                                              )
                                      )
                                  )
                                  from table(cast(l_service_id_tab as prd_service_tpt)) s
                                     , prd_service_object b
                                 where b.service_id    = s.id
                                   and b.object_id     = g.account_id
                                   and b.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                                   and b.split_hash    = g.split_hash
                            )
                  end
                  , itf_cst_account_export_pkg.generate_add_data(i_account_id  => g.account_id)
                  , (select xmlagg(
                                xmlelement("flexible_field"
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
                      where ff.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                        and fd.field_id    = ff.id
                        and fd.object_id   = g.account_id
                    ) -- account flexible fields
                ))
            ).getclobval()
       from (
          select f.id account_id
               , f.account_type
               , f.status
               , f.account_number
               , (
                 select nvl(
                            sum(t.aval_impact *
                                case
                                    when f.currency = b.currency
                                    then b.balance
                                    else com_api_rate_pkg.convert_amount(
                                             i_src_amount   => b.balance
                                           , i_src_currency => b.currency
                                           , i_dst_currency => f.currency
                                           , i_rate_type    => t.rate_type
                                           , i_inst_id      => f.inst_id
                                           , i_eff_date     => l_sysdate
                                         )
                                end)
                          , 0
                        )
                   from acc_balance_type t
                      , acc_balance b
                  where b.account_id   = f.id
                    and b.split_hash   = f.split_hash
                    and t.account_type = f.account_type
                    and t.inst_id      = f.inst_id
                    and t.aval_impact != 0
                    and t.balance_type = b.balance_type
               ) aval_balance
               , f.split_hash
               , f.currency
               , f.inst_id
               , (select min(open_date) from acc_balance where account_id = f.id and split_hash = f.split_hash) open_date
            from acc_account f
           where f.id in (select column_value from table(cast(l_account_id_tab as num_tab_tpt)))
       ) g
     group by
           g.account_id
         , g.split_hash
         , g.inst_id
    ;

    cursor main_cur_xml is
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
            xmlelement("accounts", xmlattributes('http://sv.bpc.in/SVXP' as "xmlns")
              , xmlelement("file_type",    acc_api_const_pkg.FILE_TYPE_ACCOUNTS)
              , xmlelement("date_purpose", com_api_const_pkg.DATE_PURPOSE_PROCESSING)
              , xmlelement("start_date",   to_char(l_sysdate, 'yyyy-mm-dd'))
              , xmlelement("end_date",     to_char(l_sysdate, 'yyyy-mm-dd'))
              , xmlelement("inst_id",      l_inst_id)
              , xmlelement("tokenized_pan", case l_export_clear_pan
                                                when com_api_const_pkg.FALSE
                                                then com_api_const_pkg.TRUE
                                                else com_api_const_pkg.FALSE
                                            end)
              , xmlagg(xmlelement("account", xmlattributes(g.account_id as "id")
                  , xmlelement("account_number",  min(g.account_number))
                  , xmlelement("currency",        min(g.account_currency))
                  , xmlelement("account_type",    min(g.account_type))
                  , xmlelement("account_status",  min(g.status))
                  , xmlelement("aval_balance",    min(g.aval_balance))
                  , xmlelement("create_date",     min(to_char(g.open_date, com_api_const_pkg.XML_DATE_FORMAT)))
                  , xmlagg(xmlelement("balance", xmlattributes(g.balance_id as "id")
                      , xmlelement("balance_type", g.balance_type)
                      , xmlelement("turnover"
                          , xmlelement("outgoing_balance", g.balance)
                        )
                    ))
                  -- services
                  , case when nvl(i_include_service, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then (
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
                                                   , row_number() over (partition by account_id, attr_name order by decode(level_priority, 0, 0, 1)
                                                                                                                          , level_priority
                                                                                                                          , start_date desc
                                                                                                                          , register_timestamp desc) rn
                                                   , account_id
                                                   , split_hash
                                                   , attr_name
                                                   , service_id
                                                from (
                                                    select v.attr_value
                                                         , 0 level_priority
                                                         , a.object_type
                                                         , v.register_timestamp
                                                         , v.start_date
                                                         , v.object_id  account_id
                                                         , v.split_hash
                                                         , a.attr_name
                                                         , v.service_id
                                                      from prd_attribute_value v
                                                         , prd_attribute a
                                                     where v.entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                                                       and a.entity_type  is null
                                                       and a.data_type    = com_api_const_pkg.DATA_TYPE_CHAR --'DTTPCHAR'
                                                       and a.id           = v.attr_id
                                                       and v.service_id in (select id from table(cast(l_service_id_tab as prd_service_tpt)))
                                                       and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                 union all
                                                    select v.attr_value
                                                         , p.level_priority
                                                         , a.object_type
                                                         , v.register_timestamp
                                                         , v.start_date
                                                         , ac.id  account_id
                                                         , ac.split_hash
                                                         , a.attr_name
                                                         , v.service_id
                                                      from products p
                                                         , prd_attribute_value v
                                                         , prd_attribute a
                                                         , (select distinct id, service_type_id from table(cast(l_service_id_tab as prd_service_tpt))) srv
                                                         , prd_product_service ps
                                                         , prd_contract c
                                                         , acc_account ac
                                                     where v.service_id      = srv.id
                                                       and v.object_id       = decode(a.definition_level, 'SADLSRVC', srv.id, p.parent_id)
                                                       and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                                                       and v.attr_id         = a.id
                                                       and a.service_type_id = srv.service_type_id
                                                       and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
                                                       and a.entity_type  is null
                                                       and a.data_type       = com_api_const_pkg.DATA_TYPE_CHAR --'DTTPCHAR'
                                                       and ps.service_id     = srv.id
                                                       and ps.service_id     = v.service_id
                                                       and p.product_id      = ps.product_id
                                                       and ps.product_id     = c.product_id
                                                       and c.id              = ac.contract_id
                                                       and c.split_hash      = ac.split_hash
                                                 ) tt
                                              ) attr
                                          where attr.rn = 1
                                            and attr.service_id = s.id
                                            and attr.account_id = b.object_id
                                            and attr.split_hash = b.split_hash
                                          )
                                  )
                              )
                              from table(cast(l_service_id_tab as prd_service_tpt)) s
                                 , prd_service_object b
                             where b.service_id    = s.id
                               and b.object_id     = g.account_id
                               and b.entity_type   = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                               and b.split_hash    = g.split_hash
                        )
                  end
                  , itf_cst_account_export_pkg.generate_add_data(
                      i_account_id  => g.account_id
                   )
                ))
            ).getclobval()
          from (
              select f.account_id
                   , f.currency balance_currency
                   , f.account_type
                   , f.status
                   , f.account_number
                   , f.balance_type
                   , f.balance_id
                   , f.balance
                   , (select nvl(
                                 sum(t.aval_impact *
                                     case
                                         when f.account_currency = b.currency
                                         then b.balance
                                         else com_api_rate_pkg.convert_amount(
                                                  i_src_amount   => b.balance
                                                , i_src_currency => b.currency
                                                , i_dst_currency => f.account_currency
                                                , i_rate_type    => t.rate_type
                                                , i_inst_id      => f.inst_id
                                                , i_eff_date     => l_sysdate
                                              )
                                     end)
                               , 0
                             )
                        from acc_balance_type t
                           , acc_balance b
                       where b.account_id   = f.account_id
                         and b.split_hash   = f.split_hash
                         and t.account_type = f.account_type
                         and t.inst_id      = f.inst_id
                         and t.aval_impact != 0
                         and t.balance_type = b.balance_type
                     ) aval_balance
                   , f.split_hash
                   , f.inst_id account_inst_id
                   , f.account_currency
                   , f.inst_id
                   , f.open_date
               from (
                   select a.id account_id
                        , a.currency account_currency
                        , a.account_type
                        , a.status
                        , a.account_number
                        , a.inst_id
                        , a.split_hash
                        , ab.id as balance_id
                        , ab.balance_type
                        , ab.currency
                        , ab.balance
                        , ab.open_date
                     from acc_account a
                        , acc_balance ab
                    where a.id in (select column_value from table(cast(l_account_id_tab as num_tab_tpt)))
                      and ab.split_hash  = a.split_hash
                      and ab.account_id  = a.id
               ) f
          ) g
      group by g.account_id
             , g.split_hash
             , g.inst_id
    ;
begin
    -- If tokenization isn't used then there is no sense to call decoding function
    -- in then select section to reduce count of SQL-PLSQL context switches
    l_export_clear_pan := iss_api_token_pkg.is_token_enabled();

    l_customer_value_type := iss_cst_export_pkg.get_customer_value_type;
    l_lang                := coalesce(i_lang, com_ui_user_env_pkg.get_user_lang());
    l_sysdate             := com_api_sttl_day_pkg.get_sysdate;

    select inst_id
      into l_inst_id
      from iss_card
     where id = i_card_id;

    l_card_instance_id := iss_api_card_instance_pkg.get_card_instance_id(i_card_id);

    open cur_xml;
    fetch cur_xml into o_card_info;
    close cur_xml;

    select prd_service_tpr(
               s.id
             , t.id
             , get_text ('prd_service_type', 'label', t.id, l_lang)
             , t.external_code
             , s.service_number
             , 1
             , null
           )
      bulk collect into
           l_service_id_tab
      from prd_service_type t
         , prd_service s
     where entity_type       = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
       and product_type      = prd_api_const_pkg.PRODUCT_TYPE_ISS --'PRDT0100'
       and s.service_type_id = t.id;

    select ao.account_id
      bulk collect into
           l_account_id_tab
      from acc_account_object ao
     where ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
       and ao.object_id   = i_card_id;

    if i_include_limits = com_api_const_pkg.TRUE then
        open main_limit_cur_xml;
        fetch main_limit_cur_xml into o_account_info;
        close main_limit_cur_xml;
    else
        open main_cur_xml;
        fetch main_cur_xml into o_account_info;
        close main_cur_xml;
    end if;

exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'CARD_NOT_FOUND'
          , i_env_param1 => i_card_id
        );
end;

end;
/
