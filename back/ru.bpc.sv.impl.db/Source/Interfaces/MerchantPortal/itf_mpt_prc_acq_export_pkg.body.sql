create or replace package body itf_mpt_prc_acq_export_pkg is

procedure process_merchant_1_2(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_count               in     com_api_type_pkg.t_medium_id     default null
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := 'ITF_MPT_PRC_ACQ_EXPORT_PKG.PROCESS_MERCHANT';

    -- Default bulk size for records per a file if <i_count> parameter is not specified
    DEFAULT_BULK_LIMIT      constant com_api_type_pkg.t_count := 2000;
    l_bulk_limit            com_api_type_pkg.t_count          := nvl(i_count, DEFAULT_BULK_LIMIT);
    l_subscriber_name       com_api_type_pkg.t_name           := DEFAULT_PROCEDURE_NAME;
    l_full_export           com_api_type_pkg.t_boolean        := nvl(i_full_export, com_api_const_pkg.FALSE);
    l_file                  clob;
    l_total_count           com_api_type_pkg.t_count          := 0;
    l_counter               com_api_type_pkg.t_count          := 0;
    

    l_event_tab             com_api_type_pkg.t_number_tab;
    l_incr_event_tab        com_api_type_pkg.t_number_tab;
    l_object_id_tab         num_tab_tpt                       := num_tab_tpt();
    l_incr_object_id_tab    num_tab_tpt                       := num_tab_tpt();
    l_object_id             com_api_type_pkg.t_medium_id;
    l_estimated_count       com_api_type_pkg.t_count          := 0;
    l_session_file_id       com_api_type_pkg.t_long_id;
    l_file_type             com_api_type_pkg.t_dict_value;

    cursor cur_xml is
        select
            xmlelement(
                "merchants"
              , xmlattributes('http://sv.bpc.in/SVXP/Merchants' as "xmlns")
              , xmlelement("file_id"  , to_char(l_session_file_id))
              , xmlelement("file_type", l_file_type)
              , xmlelement("inst_id", i_inst_id)
              , xmlagg(
                    xmlelement(
                       "merchant"
                      , xmlattributes(m.merchant_id as "merchant_id")
                      , xmlelement("inst_id",             m.inst_id)
                      , xmlelement("agent_id",            m.agent_id)
                      , xmlelement("agent_number",        m.agent_number)
                      , xmlelement("merchant_number",     m.merchant_number)
                      , xmlelement("merchant_name",       m.merchant_name)
                      , (select xmlagg(
                                    xmlelement(
                                        "merchant_label"
                                      , xmlattributes(lang as "language")
                                      , merchant_label
                                    )
                                )
                           from
                         (
                            select i.object_id
                                 , i.lang
                                 , i.text as merchant_label
                                 , row_number() over (partition by i.object_id
                                                          order by decode(i.lang
                                                                        , i_lang, -1
                                                                        , com_api_const_pkg.DEFAULT_LANGUAGE, 0)
                                   ) as rn
                               from com_i18n i 
                              where i.column_name = 'LABEL'
                                and i.table_name = 'ACQ_MERCHANT'
                         ) l
                         where (rn = 1 or i_lang is null)
                           and l.object_id = m.merchant_id
                        )
                      , xmlelement("merchant_type"  , m.merchant_type)
                      , xmlelement("mcc"            , m.mcc)
                      , xmlelement("merchant_status", m.merchant_status)
                      , xmlforest(m.parent_id  as "parent_id")
                      , xmlelement(
                            "customer"
                          , xmlattributes(m.customer_id as "customer_id")
                          , xmlelement("customer_number", m.customer_number)
                        )
                      , xmlelement(
                            "contract"
                          , xmlattributes(m.contract_id as "contract_id")
                          , xmlelement("contract_number", m.contract_number)
                        )
                      , (select xmlagg(
                                    xmlelement(
                                       "contact"
                                      , xmlattributes(c.id as "contact_id")
                                      , xmlelement("contact_type",   min(o.contact_type))
                                      , xmlagg(
                                            xmlelement(
                                                "contact_data"
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
                          group by c.id
                                 , o.contact_type
                        ) -- end of contact
                      , (select xmlagg(
                                    xmlelement(
                                        "address"
                                      , xmlattributes(a.id as "address_id")
                                      , xmlelement("address_type", a.address_type)
                                      , xmlelement("country",      a.country)
                                      , (select xmlagg(
                                                    xmlelement(
                                                        "address_name"
                                                      , xmlattributes(aa.lang as "language")
                                                      , xmlelement("region", aa.region)
                                                      , xmlelement("city",   aa.city)
                                                      , xmlelement("street", aa.street)
                                                    )
                                                ) 
                                           from com_address aa
                                          where aa.id = a.id
                                            and (aa.lang = a.lang or i_lang is null)
                                        )
                                      , xmlelement("house",        a.house)
                                      , xmlforest(
                                            a.apartment      as "apartment"
                                          , a.postal_code    as "postal_code"
                                          , a.place_code     as "place_code"
                                          , a.region_code    as "region_code"
                                        )
                                    )
                                )
                           from (select a.id
                                      , o.address_type
                                      , a.country
                                      , a.house
                                      , a.apartment
                                      , a.postal_code
                                      , a.place_code
                                      , a.region_code
                                      , o.object_id
                                      , a.lang
                                      , row_number() over (partition by o.object_id, o.address_type 
                                                               order by decode(a.lang
                                                                             , i_lang, -1
                                                                             , com_api_const_pkg.DEFAULT_LANGUAGE, 0
                                                                             , o.address_id)
                                        ) rn
                                   from com_address_object o
                                      , com_address a
                                  where o.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                    and a.id          = o.address_id
                                    and a.lang in (i_lang, com_api_const_pkg.DEFAULT_LANGUAGE)
                           ) a
                          where a.rn        = 1
                            and a.object_id = m.merchant_id
                        ) -- end of address
                      , (
                            select xmlagg(
                                       xmlelement(
                                           "account"
                                         , xmlattributes(ac.id as "account_id")
                                         , xmlforest(
                                               ac.account_number     as "account_number"
                                             , ac.account_type       as "account_type"
                                             , ac.currency           as "currency"
                                             , ac.status             as "account_status"
                                           )
                                      )
                                   )
                              from acc_account ac
                                 , acc_account_object ao
                             where ao.split_hash  = m.split_hash
                               and ac.split_hash  = ao.split_hash
                               and ac.id          = ao.account_id
                               and ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                               and ao.object_id   = m.merchant_id
                        )
                    )
                ) -- xmlagg(xmlelement("merchant"...
            ).getclobval()
          , count(*)
        from (
            select m.id as merchant_id
                 , m.inst_id
                 , m.merchant_name
                 , m.merchant_number
                 , m.status as merchant_status
                 , m.mcc
                 , m.merchant_type
                 , m.split_hash
                 , m.parent_id
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
             where m.id in (select column_value from table(cast(l_object_id_tab as num_tab_tpt)))
               and c.id = m.contract_id
               and s.id = c.customer_id
               and a.id = c.agent_id
        ) m;

    cur_objects             sys_refcursor;
    l_container_id          com_api_type_pkg.t_long_id;
    
    -- Generate XML file
    procedure generate_xml is
        l_fetched_count                com_api_type_pkg.t_count    := 0;
        l_params                       com_api_type_pkg.t_param_tab;
        CRLF                  constant com_api_type_pkg.t_name := chr(13) || chr(10);
    begin
        if l_object_id_tab.count > 0 then
            trc_log_pkg.debug('Creating a new XML file...');
            
            -- Save estimated count of records in the current iteration
            l_estimated_count := l_estimated_count + l_object_id_tab.count;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
            );
            trc_log_pkg.debug('Estimated count of records is [' || l_estimated_count || ']');
            
            rul_api_param_pkg.set_param (
                i_name          => 'INST_ID'
              , i_value         => i_inst_id
              , io_params       => l_params
            );
            
            prc_api_file_pkg.open_file(
                o_sess_file_id          => l_session_file_id
              , i_file_type             => l_file_type
              , i_file_purpose          => prc_api_const_pkg.FILE_PURPOSE_OUT
              , io_params               => l_params
            );

            -- For every processing batch of records we fetch data and save it in a separate file
            open cur_xml;
            fetch cur_xml into l_file, l_fetched_count;
            close cur_xml;
            
            l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

            prc_api_file_pkg.put_file(
                i_sess_file_id        => l_session_file_id
              , i_clob_content        => l_file
              , i_add_to              => com_api_const_pkg.FALSE
            );

            l_counter     := l_counter + 1;
            trc_log_pkg.debug('file saved, count=' || l_counter || ', length=' || length(l_file));

            l_total_count := l_total_count + l_fetched_count;

            prc_api_stat_pkg.log_current(
                i_current_count  => l_total_count
              , i_excepted_count => 0
            );
        end if;
    end;
    
    procedure open_cur_objects(
        o_cursor               out sys_refcursor
      , i_full_export       in     com_api_type_pkg.t_boolean
      , i_inst_id           in     com_api_type_pkg.t_inst_id
      , i_subscriber_name   in     com_api_type_pkg.t_name
    ) is
        l_sysdate   date; 
    begin
        trc_log_pkg.debug('Opening a cursor for all reconrs those are processed...');

        l_sysdate   := com_api_sttl_day_pkg.get_sysdate;
        if i_full_export = com_api_const_pkg.TRUE then
            -- Get all available objects
            open o_cursor for
                select m.id
                  from acq_merchant m
                 where m.split_hash in (select split_hash from com_api_split_map_vw)
                   and (m.inst_id   = i_inst_id  or i_inst_id = ost_api_const_pkg.DEFAULT_INST);
        else
            -- Get objects by events
            open o_cursor for
                select o.id as event_object_id
                     , m.id as merchant_id
                  from evt_event_object o
                     , acq_merchant m
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = i_subscriber_name
                   and m.split_hash in (select split_hash from com_api_split_map_vw)
                   and o.eff_date     <= l_sysdate
                   and (o.inst_id      = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                   and o.entity_type   = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   and o.object_id     = m.id
                 order by merchant_id;
        end if;
        trc_log_pkg.debug('Cursor was opened...');
    end;

begin
    trc_log_pkg.debug(
        i_text       => 'process_merchant_1_2: START with l_full_export [#1], i_inst_id [#2], i_count [#3]'
      , i_env_param1 => l_full_export
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_count
    );
    l_container_id      := prc_api_session_pkg.get_container_id;
    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    trc_log_pkg.debug(
        i_text       => 'l_container_id [#1]'
      , i_env_param1 => l_container_id
    );

    prc_api_stat_pkg.log_start;

    open_cur_objects(
        o_cursor          => cur_objects
      , i_full_export     => l_full_export
      , i_inst_id         => i_inst_id
      , i_subscriber_name => l_subscriber_name
    );

    loop
        begin
            savepoint sp_mpt_merchant_export;

            if l_full_export = com_api_const_pkg.TRUE then
                fetch cur_objects
                 bulk collect into
                      l_object_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                -- Generate XML file
                generate_xml;

            else  -- l_full_export = com_api_const_pkg.FALSE
                fetch cur_objects
                 bulk collect into
                      l_event_tab
                    , l_incr_object_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                for i in 1 .. l_incr_object_id_tab.count loop
                    -- Decrease records count and remove the last record from previous iteration
                    if (l_incr_object_id_tab(i) != l_object_id or l_object_id is null)
                       and l_incr_object_id_tab(i) is not null
                    then
                        l_object_id := l_incr_object_id_tab(i);
                        
                        l_object_id_tab.extend;
                        l_object_id_tab(l_object_id_tab.count)       := l_incr_object_id_tab(i);
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);

                        if i = l_incr_object_id_tab.count then
                            -- Generate XML file for current portion of the "l_bulk_limit" records
                            generate_xml;

                            evt_api_event_pkg.process_event_object(
                                i_event_object_id_tab => l_incr_event_tab
                            );

                            -- Save last element of the array on a current iteration to use it for the next one
                            l_object_id_tab.delete;
                            l_incr_event_tab.delete;
                        end if;
                    else  
                        -- Select event for last account id from previous iteration
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);
                    end if;
                end loop;
                
                -- Generate XML file for last portion of records
                generate_xml;

                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab => l_incr_event_tab
                );
            end if;

            exit when cur_objects%notfound;

        exception
            when others then
                rollback to sp_mpt_merchant_export;
                raise;
        end;
    end loop;
    close cur_objects;

    prc_api_stat_pkg.log_end(
        i_excepted_total  => 0
      , i_processed_total => l_total_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug('process_merchant_1_2: FINISH');
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end;

procedure process_merchant_1_4(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_count               in     com_api_type_pkg.t_medium_id     default null
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := 'ITF_MPT_PRC_ACQ_EXPORT_PKG.PROCESS_MERCHANT';

    -- Default bulk size for records per a file if <i_count> parameter is not specified
    DEFAULT_BULK_LIMIT      constant com_api_type_pkg.t_count := 2000;
    l_bulk_limit            com_api_type_pkg.t_count          := nvl(i_count, DEFAULT_BULK_LIMIT);
    l_subscriber_name       com_api_type_pkg.t_name           := DEFAULT_PROCEDURE_NAME;
    l_full_export           com_api_type_pkg.t_boolean        := nvl(i_full_export, com_api_const_pkg.FALSE);
    l_file                  clob;
    l_total_count           com_api_type_pkg.t_count          := 0;
    l_counter               com_api_type_pkg.t_count          := 0;
    

    l_event_tab             com_api_type_pkg.t_number_tab;
    l_incr_event_tab        com_api_type_pkg.t_number_tab;
    l_object_id_tab         num_tab_tpt                       := num_tab_tpt();
    l_incr_object_id_tab    num_tab_tpt                       := num_tab_tpt();
    l_object_id             com_api_type_pkg.t_medium_id;
    l_estimated_count       com_api_type_pkg.t_count          := 0;
    l_session_file_id       com_api_type_pkg.t_long_id;
    l_file_type             com_api_type_pkg.t_dict_value;

    cursor cur_xml is
        select
            xmlelement(
                "merchants"
              , xmlattributes('http://sv.bpc.in/SVXP/Merchants' as "xmlns")
              , xmlelement("file_id"  , to_char(l_session_file_id))
              , xmlelement("file_type", l_file_type)
              , xmlelement("inst_id", i_inst_id)
              , xmlagg(
                    xmlelement(
                       "merchant"
                      , xmlattributes(m.merchant_id as "merchant_id")
                      , xmlelement("inst_id",             m.inst_id)
                      , xmlelement("agent_id",            m.agent_id)
                      , xmlelement("agent_number",        m.agent_number)
                      , xmlelement("merchant_number",     m.merchant_number)
                      , xmlelement("merchant_name",       m.merchant_name)
                      , (select xmlagg(
                                    xmlelement(
                                        "merchant_label"
                                      , xmlattributes(lang as "language")
                                      , merchant_label
                                    )
                                )
                           from
                         (
                            select i.object_id
                                 , i.lang
                                 , i.text as merchant_label
                                 , row_number() over (partition by i.object_id
                                                          order by decode(i.lang
                                                                        , i_lang, -1
                                                                        , com_api_const_pkg.DEFAULT_LANGUAGE, 0)
                                   ) as rn
                               from com_i18n i 
                              where i.column_name = 'LABEL'
                                and i.table_name = 'ACQ_MERCHANT'
                         ) l
                         where (rn = 1 or i_lang is null)
                           and l.object_id = m.merchant_id
                        )
                      , xmlelement("merchant_type"  , m.merchant_type)
                      , xmlelement("mcc"            , m.mcc)
                      , xmlelement("merchant_status", m.merchant_status)
                      , (select xmlagg(
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
                        ) -- end of merchant_card
                      , xmlforest(m.parent_id  as "parent_id")
                      , xmlelement(
                            "customer"
                          , xmlattributes(m.customer_id as "customer_id")
                          , xmlelement("customer_number", m.customer_number)
                        )
                      , xmlelement(
                            "contract"
                          , xmlattributes(m.contract_id as "contract_id")
                          , xmlelement("contract_number", m.contract_number)
                        )
                      , (select xmlagg(
                                    xmlelement(
                                       "contact"
                                      , xmlattributes(c.id as "contact_id")
                                      , xmlelement("contact_type",   min(o.contact_type))
                                      , xmlagg(
                                            xmlelement(
                                                "contact_data"
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
                          group by c.id
                                 , o.contact_type
                        ) -- end of contact
                      , (select xmlagg(
                                    xmlelement(
                                        "address"
                                      , xmlattributes(a.id as "address_id")
                                      , xmlelement("address_type", a.address_type)
                                      , xmlelement("country",      a.country)
                                      , (select xmlagg(
                                                    xmlelement(
                                                        "address_name"
                                                      , xmlattributes(aa.lang as "language")
                                                      , xmlelement("region", aa.region)
                                                      , xmlelement("city",   aa.city)
                                                      , xmlelement("street", aa.street)
                                                    )
                                                ) 
                                           from com_address aa
                                          where aa.id = a.id
                                            and (aa.lang = a.lang or i_lang is null)
                                        )
                                      , xmlelement("house",        a.house)
                                      , xmlforest(
                                            a.apartment      as "apartment"
                                          , a.postal_code    as "postal_code"
                                          , a.place_code     as "place_code"
                                          , a.region_code    as "region_code"
                                        )
                                    )
                                )
                           from (select a.id
                                      , o.address_type
                                      , a.country
                                      , a.house
                                      , a.apartment
                                      , a.postal_code
                                      , a.place_code
                                      , a.region_code
                                      , o.object_id
                                      , a.lang
                                      , row_number() over (partition by o.object_id, o.address_type 
                                                               order by decode(a.lang
                                                                             , i_lang, -1
                                                                             , com_api_const_pkg.DEFAULT_LANGUAGE, 0
                                                                             , o.address_id)
                                        ) rn
                                   from com_address_object o
                                      , com_address a
                                  where o.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                    and a.id          = o.address_id
                                    and a.lang in (i_lang, com_api_const_pkg.DEFAULT_LANGUAGE)
                           ) a
                          where a.rn        = 1
                            and a.object_id = m.merchant_id
                        ) -- end of address
                      , (
                            select xmlagg(
                                       xmlelement(
                                           "account"
                                         , xmlattributes(ac.id as "account_id")
                                         , xmlforest(
                                               ac.account_number     as "account_number"
                                             , ac.account_type       as "account_type"
                                             , ac.currency           as "currency"
                                             , ac.status             as "account_status"
                                           )
                                      )
                                   )
                              from acc_account ac
                                 , acc_account_object ao
                             where ao.split_hash  = m.split_hash
                               and ac.split_hash  = ao.split_hash
                               and ac.id          = ao.account_id
                               and ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                               and ao.object_id   = m.merchant_id
                        )
                    )
                ) -- xmlagg(xmlelement("merchant"...
            ).getclobval()
          , count(*)
        from (
            select m.id as merchant_id
                 , m.inst_id
                 , m.merchant_name
                 , m.merchant_number
                 , m.status as merchant_status
                 , m.mcc
                 , m.merchant_type
                 , m.split_hash
                 , m.parent_id
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
             where m.id in (select column_value from table(cast(l_object_id_tab as num_tab_tpt)))
               and c.id = m.contract_id
               and s.id = c.customer_id
               and a.id = c.agent_id
        ) m;

    cur_objects             sys_refcursor;
    l_container_id          com_api_type_pkg.t_long_id;
    
    -- Generate XML file
    procedure generate_xml is
        l_fetched_count                com_api_type_pkg.t_count    := 0;
        l_params                       com_api_type_pkg.t_param_tab;
        CRLF                  constant com_api_type_pkg.t_name := chr(13) || chr(10);
    begin
        if l_object_id_tab.count > 0 then
            trc_log_pkg.debug('Creating a new XML file...');
            
            -- Save estimated count of records in the current iteration
            l_estimated_count := l_estimated_count + l_object_id_tab.count;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
            );
            trc_log_pkg.debug('Estimated count of records is [' || l_estimated_count || ']');
            
            rul_api_param_pkg.set_param (
                i_name          => 'INST_ID'
              , i_value         => i_inst_id
              , io_params       => l_params
            );
            
            prc_api_file_pkg.open_file(
                o_sess_file_id          => l_session_file_id
              , i_file_type             => l_file_type
              , i_file_purpose          => prc_api_const_pkg.FILE_PURPOSE_OUT
              , io_params               => l_params
            );

            -- For every processing batch of records we fetch data and save it in a separate file
            open cur_xml;
            fetch cur_xml into l_file, l_fetched_count;
            close cur_xml;
            
            l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

            prc_api_file_pkg.put_file(
                i_sess_file_id        => l_session_file_id
              , i_clob_content        => l_file
              , i_add_to              => com_api_const_pkg.FALSE
            );

            l_counter     := l_counter + 1;
            trc_log_pkg.debug('file saved, count=' || l_counter || ', length=' || length(l_file));

            l_total_count := l_total_count + l_fetched_count;

            prc_api_stat_pkg.log_current(
                i_current_count  => l_total_count
              , i_excepted_count => 0
            );
        end if;
    end;
    
    procedure open_cur_objects(
        o_cursor               out sys_refcursor
      , i_full_export       in     com_api_type_pkg.t_boolean
      , i_inst_id           in     com_api_type_pkg.t_inst_id
      , i_subscriber_name   in     com_api_type_pkg.t_name
    ) is
        l_sysdate   date; 
    begin
        trc_log_pkg.debug('Opening a cursor for all reconrs those are processed...');

        l_sysdate   := com_api_sttl_day_pkg.get_sysdate;
        if i_full_export = com_api_const_pkg.TRUE then
            -- Get all available objects
            open o_cursor for
                select m.id
                  from acq_merchant m
                 where m.split_hash in (select split_hash from com_api_split_map_vw)
                   and (m.inst_id   = i_inst_id  or i_inst_id = ost_api_const_pkg.DEFAULT_INST);
        else
            -- Get objects by events
            open o_cursor for
                select o.id as event_object_id
                     , m.id as merchant_id
                  from evt_event_object o
                     , acq_merchant m
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = i_subscriber_name
                   and m.split_hash in (select split_hash from com_api_split_map_vw)
                   and o.eff_date     <= l_sysdate
                   and (o.inst_id      = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                   and o.entity_type   = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   and o.object_id     = m.id
                 order by merchant_id;
        end if;
        trc_log_pkg.debug('Cursor was opened...');
    end;

begin
    trc_log_pkg.debug(
        i_text       => 'process_merchant_1_2: START with l_full_export [#1], i_inst_id [#2], i_count [#3]'
      , i_env_param1 => l_full_export
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_count
    );
    l_container_id      := prc_api_session_pkg.get_container_id;
    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    trc_log_pkg.debug(
        i_text       => 'l_container_id [#1]'
      , i_env_param1 => l_container_id
    );

    prc_api_stat_pkg.log_start;

    open_cur_objects(
        o_cursor          => cur_objects
      , i_full_export     => l_full_export
      , i_inst_id         => i_inst_id
      , i_subscriber_name => l_subscriber_name
    );

    loop
        begin
            savepoint sp_mpt_merchant_export;

            if l_full_export = com_api_const_pkg.TRUE then
                fetch cur_objects
                 bulk collect into
                      l_object_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                -- Generate XML file
                generate_xml;

            else  -- l_full_export = com_api_const_pkg.FALSE
                fetch cur_objects
                 bulk collect into
                      l_event_tab
                    , l_incr_object_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                for i in 1 .. l_incr_object_id_tab.count loop
                    -- Decrease records count and remove the last record from previous iteration
                    if (l_incr_object_id_tab(i) != l_object_id or l_object_id is null)
                       and l_incr_object_id_tab(i) is not null
                    then
                        l_object_id := l_incr_object_id_tab(i);
                        
                        l_object_id_tab.extend;
                        l_object_id_tab(l_object_id_tab.count)       := l_incr_object_id_tab(i);
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);

                        if i = l_incr_object_id_tab.count then
                            -- Generate XML file for current portion of the "l_bulk_limit" records
                            generate_xml;

                            evt_api_event_pkg.process_event_object(
                                i_event_object_id_tab => l_incr_event_tab
                            );

                            -- Save last element of the array on a current iteration to use it for the next one
                            l_object_id_tab.delete;
                            l_incr_event_tab.delete;
                        end if;
                    else  
                        -- Select event for last account id from previous iteration
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);
                    end if;
                end loop;
                
                -- Generate XML file for last portion of records
                generate_xml;

                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab => l_incr_event_tab
                );
            end if;

            exit when cur_objects%notfound;

        exception
            when others then
                rollback to sp_mpt_merchant_export;
                raise;
        end;
    end loop;
    close cur_objects;

    prc_api_stat_pkg.log_end(
        i_excepted_total  => 0
      , i_processed_total => l_total_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug('process_merchant_1_2: FINISH');
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end;

procedure process_merchant_1_7(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_count               in     com_api_type_pkg.t_medium_id     default null
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := 'ITF_MPT_PRC_ACQ_EXPORT_PKG.PROCESS_MERCHANT';

    -- Default bulk size for records per a file if <i_count> parameter is not specified
    DEFAULT_BULK_LIMIT      constant com_api_type_pkg.t_count := 2000;
    l_bulk_limit            com_api_type_pkg.t_count          := nvl(i_count, DEFAULT_BULK_LIMIT);
    l_subscriber_name       com_api_type_pkg.t_name           := DEFAULT_PROCEDURE_NAME;
    l_full_export           com_api_type_pkg.t_boolean        := nvl(i_full_export, com_api_const_pkg.FALSE);
    l_file                  clob;
    l_total_count           com_api_type_pkg.t_count          := 0;
    l_counter               com_api_type_pkg.t_count          := 0;
    

    l_event_tab             com_api_type_pkg.t_number_tab;
    l_incr_event_tab        com_api_type_pkg.t_number_tab;
    l_object_id_tab         num_tab_tpt                       := num_tab_tpt();
    l_incr_object_id_tab    num_tab_tpt                       := num_tab_tpt();
    l_object_id             com_api_type_pkg.t_medium_id;
    l_estimated_count       com_api_type_pkg.t_count          := 0;
    l_session_file_id       com_api_type_pkg.t_long_id;
    l_file_type             com_api_type_pkg.t_dict_value;

    cursor cur_xml is
        select
            xmlelement(
                "merchants"
              , xmlattributes('http://sv.bpc.in/SVXP/Merchants' as "xmlns")
              , xmlelement("file_id"  , to_char(l_session_file_id))
              , xmlelement("file_type", l_file_type)
              , xmlelement("inst_id", i_inst_id)
              , xmlagg(
                    xmlelement(
                       "merchant"
                      , xmlattributes(m.merchant_id as "merchant_id")
                      , xmlelement("inst_id",             m.inst_id)
                      , xmlelement("agent_id",            m.agent_id)
                      , xmlelement("agent_number",        m.agent_number)
                      , xmlelement("merchant_number",     m.merchant_number)
                      , xmlelement("merchant_name",       m.merchant_name)
                      , (select xmlagg(
                                    xmlelement(
                                        "merchant_label"
                                      , xmlattributes(lang as "language")
                                      , merchant_label
                                    )
                                )
                           from
                         (
                            select i.object_id
                                 , i.lang
                                 , i.text as merchant_label
                                 , row_number() over (partition by i.object_id
                                                          order by decode(i.lang
                                                                        , i_lang, -1
                                                                        , com_api_const_pkg.DEFAULT_LANGUAGE, 0)
                                   ) as rn
                               from com_i18n i 
                              where i.column_name = 'LABEL'
                                and i.table_name = 'ACQ_MERCHANT'
                         ) l
                         where (rn = 1 or i_lang is null)
                           and l.object_id = m.merchant_id
                        )
                      , xmlelement("merchant_type"  , m.merchant_type)
                      , xmlelement("mcc"            , m.mcc)
                      , xmlelement("merchant_status", m.merchant_status)
                      , case when m.status_reason is not null then xmlelement("status_reason", m.status_reason) end
                      , (select xmlagg(
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
                        ) -- end of merchant_card
                      , xmlforest(m.parent_id  as "parent_id")
                      , xmlelement(
                            "customer"
                          , xmlattributes(m.customer_id as "customer_id")
                          , xmlelement("customer_number", m.customer_number)
                        )
                      , xmlelement(
                            "contract"
                          , xmlattributes(m.contract_id as "contract_id")
                          , xmlelement("contract_number", m.contract_number)
                        )
                      , (select xmlagg(
                                    xmlelement(
                                       "contact"
                                      , xmlattributes(c.id as "contact_id")
                                      , xmlelement("contact_type",   min(o.contact_type))
                                      , xmlagg(
                                            xmlelement(
                                                "contact_data"
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
                          group by c.id
                                 , o.contact_type
                        ) -- end of contact
                      , (select xmlagg(
                                    xmlelement(
                                        "address"
                                      , xmlattributes(a.id as "address_id")
                                      , xmlelement("address_type", a.address_type)
                                      , xmlelement("country",      a.country)
                                      , (select xmlagg(
                                                    xmlelement(
                                                        "address_name"
                                                      , xmlattributes(aa.lang as "language")
                                                      , xmlelement("region", aa.region)
                                                      , xmlelement("city",   aa.city)
                                                      , xmlelement("street", aa.street)
                                                    )
                                                ) 
                                           from com_address aa
                                          where aa.id = a.id
                                            and (aa.lang = a.lang or i_lang is null)
                                        )
                                      , xmlelement("house",        a.house)
                                      , xmlforest(
                                            a.apartment      as "apartment"
                                          , a.postal_code    as "postal_code"
                                          , a.place_code     as "place_code"
                                          , a.region_code    as "region_code"
                                        )
                                    )
                                )
                           from (select a.id
                                      , o.address_type
                                      , a.country
                                      , a.house
                                      , a.apartment
                                      , a.postal_code
                                      , a.place_code
                                      , a.region_code
                                      , o.object_id
                                      , a.lang
                                      , row_number() over (partition by o.object_id, o.address_type 
                                                               order by decode(a.lang
                                                                             , i_lang, -1
                                                                             , com_api_const_pkg.DEFAULT_LANGUAGE, 0
                                                                             , o.address_id)
                                        ) rn
                                   from com_address_object o
                                      , com_address a
                                  where o.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                    and a.id          = o.address_id
                                    and a.lang in (i_lang, com_api_const_pkg.DEFAULT_LANGUAGE)
                           ) a
                          where a.rn        = 1
                            and a.object_id = m.merchant_id
                        ) -- end of address
                      , (
                            select xmlagg(
                                       xmlelement(
                                           "account"
                                         , xmlattributes(ac.id as "account_id")
                                         , xmlforest(
                                               ac.account_number     as "account_number"
                                             , ac.account_type       as "account_type"
                                             , ac.currency           as "currency"
                                             , ac.status             as "account_status"
                                           )
                                      )
                                   )
                              from acc_account ac
                                 , acc_account_object ao
                             where ao.split_hash  = m.split_hash
                               and ac.split_hash  = ao.split_hash
                               and ac.id          = ao.account_id
                               and ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                               and ao.object_id   = m.merchant_id
                        )
                    )
                ) -- xmlagg(xmlelement("merchant"...
            ).getclobval()
          , count(*)
        from (
            select m.id as merchant_id
                 , m.inst_id
                 , m.merchant_name
                 , m.merchant_number
                 , m.status as merchant_status
                 , evt_api_status_pkg.get_status_reason(
                       i_entity_type   => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                     , i_object_id     => m.id
                     , i_raise_error   => com_api_const_pkg.FALSE
                   ) as status_reason
                 , m.mcc
                 , m.merchant_type
                 , m.split_hash
                 , m.parent_id
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
             where m.id in (select column_value from table(cast(l_object_id_tab as num_tab_tpt)))
               and c.id = m.contract_id
               and s.id = c.customer_id
               and a.id = c.agent_id
        ) m;

    cur_objects             sys_refcursor;
    l_container_id          com_api_type_pkg.t_long_id;
    
    -- Generate XML file
    procedure generate_xml is
        l_fetched_count                com_api_type_pkg.t_count    := 0;
        l_params                       com_api_type_pkg.t_param_tab;
        CRLF                  constant com_api_type_pkg.t_name := chr(13) || chr(10);
    begin
        if l_object_id_tab.count > 0 then
            trc_log_pkg.debug('Creating a new XML file...');
            
            -- Save estimated count of records in the current iteration
            l_estimated_count := l_estimated_count + l_object_id_tab.count;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
            );
            trc_log_pkg.debug('Estimated count of records is [' || l_estimated_count || ']');
            
            rul_api_param_pkg.set_param (
                i_name          => 'INST_ID'
              , i_value         => i_inst_id
              , io_params       => l_params
            );
            
            prc_api_file_pkg.open_file(
                o_sess_file_id          => l_session_file_id
              , i_file_type             => l_file_type
              , i_file_purpose          => prc_api_const_pkg.FILE_PURPOSE_OUT
              , io_params               => l_params
            );

            -- For every processing batch of records we fetch data and save it in a separate file
            open cur_xml;
            fetch cur_xml into l_file, l_fetched_count;
            close cur_xml;
            
            l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

            prc_api_file_pkg.put_file(
                i_sess_file_id        => l_session_file_id
              , i_clob_content        => l_file
              , i_add_to              => com_api_const_pkg.FALSE
            );

            l_counter     := l_counter + 1;
            trc_log_pkg.debug('file saved, count=' || l_counter || ', length=' || length(l_file));

            l_total_count := l_total_count + l_fetched_count;

            prc_api_stat_pkg.log_current(
                i_current_count  => l_total_count
              , i_excepted_count => 0
            );
        end if;
    end;
    
    procedure open_cur_objects(
        o_cursor               out sys_refcursor
      , i_full_export       in     com_api_type_pkg.t_boolean
      , i_inst_id           in     com_api_type_pkg.t_inst_id
      , i_subscriber_name   in     com_api_type_pkg.t_name
    ) is
        l_sysdate   date; 
    begin
        trc_log_pkg.debug('Opening a cursor for all reconrs those are processed...');

        l_sysdate   := com_api_sttl_day_pkg.get_sysdate;
        if i_full_export = com_api_const_pkg.TRUE then
            -- Get all available objects
            open o_cursor for
                select m.id
                  from acq_merchant m
                 where m.split_hash in (select split_hash from com_api_split_map_vw)
                   and (m.inst_id   = i_inst_id  or i_inst_id = ost_api_const_pkg.DEFAULT_INST);
        else
            -- Get objects by events
            open o_cursor for
                select o.id as event_object_id
                     , m.id as merchant_id
                  from evt_event_object o
                     , acq_merchant m
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = i_subscriber_name
                   and m.split_hash in (select split_hash from com_api_split_map_vw)
                   and o.eff_date     <= l_sysdate
                   and (o.inst_id      = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                   and o.entity_type   = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   and o.object_id     = m.id
                 order by merchant_id;
        end if;
        trc_log_pkg.debug('Cursor was opened...');
    end;

begin
    trc_log_pkg.debug(
        i_text       => 'process_merchant_1_2: START with l_full_export [#1], i_inst_id [#2], i_count [#3]'
      , i_env_param1 => l_full_export
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_count
    );
    l_container_id      := prc_api_session_pkg.get_container_id;
    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    trc_log_pkg.debug(
        i_text       => 'l_container_id [#1]'
      , i_env_param1 => l_container_id
    );

    prc_api_stat_pkg.log_start;

    open_cur_objects(
        o_cursor          => cur_objects
      , i_full_export     => l_full_export
      , i_inst_id         => i_inst_id
      , i_subscriber_name => l_subscriber_name
    );

    loop
        begin
            savepoint sp_mpt_merchant_export;

            if l_full_export = com_api_const_pkg.TRUE then
                fetch cur_objects
                 bulk collect into
                      l_object_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                -- Generate XML file
                generate_xml;

            else  -- l_full_export = com_api_const_pkg.FALSE
                fetch cur_objects
                 bulk collect into
                      l_event_tab
                    , l_incr_object_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                for i in 1 .. l_incr_object_id_tab.count loop
                    -- Decrease records count and remove the last record from previous iteration
                    if (l_incr_object_id_tab(i) != l_object_id or l_object_id is null)
                       and l_incr_object_id_tab(i) is not null
                    then
                        l_object_id := l_incr_object_id_tab(i);
                        
                        l_object_id_tab.extend;
                        l_object_id_tab(l_object_id_tab.count)       := l_incr_object_id_tab(i);
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);

                        if i = l_incr_object_id_tab.count then
                            -- Generate XML file for current portion of the "l_bulk_limit" records
                            generate_xml;

                            evt_api_event_pkg.process_event_object(
                                i_event_object_id_tab => l_incr_event_tab
                            );

                            -- Save last element of the array on a current iteration to use it for the next one
                            l_object_id_tab.delete;
                            l_incr_event_tab.delete;
                        end if;
                    else  
                        -- Select event for last account id from previous iteration
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);
                    end if;
                end loop;
                
                -- Generate XML file for last portion of records
                generate_xml;

                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab => l_incr_event_tab
                );
            end if;

            exit when cur_objects%notfound;

        exception
            when others then
                rollback to sp_mpt_merchant_export;
                raise;
        end;
    end loop;
    close cur_objects;

    prc_api_stat_pkg.log_end(
        i_excepted_total  => 0
      , i_processed_total => l_total_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug('process_merchant_1_2: FINISH');
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end;

procedure process_terminal_1_2(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_count               in     com_api_type_pkg.t_medium_id     default null
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := 'ITF_MPT_PRC_ACQ_EXPORT_PKG.PROCESS_TERMINAL';

    -- Default bulk size for records per a file if <i_count> parameter is not specified
    DEFAULT_BULK_LIMIT      constant com_api_type_pkg.t_count := 2000;
    l_bulk_limit            com_api_type_pkg.t_count          := nvl(i_count, DEFAULT_BULK_LIMIT);
    l_subscriber_name       com_api_type_pkg.t_name           := DEFAULT_PROCEDURE_NAME;
    l_full_export           com_api_type_pkg.t_boolean        := nvl(i_full_export, com_api_const_pkg.FALSE);
    l_file                  clob;
    l_total_count           com_api_type_pkg.t_count          := 0;
    l_counter               com_api_type_pkg.t_count          := 0;

    l_event_tab             com_api_type_pkg.t_number_tab;
    l_incr_event_tab        com_api_type_pkg.t_number_tab;
    l_object_id_tab         num_tab_tpt                       := num_tab_tpt();
    l_incr_object_id_tab    num_tab_tpt                       := num_tab_tpt();
    l_object_id             com_api_type_pkg.t_medium_id;
    l_estimated_count       com_api_type_pkg.t_count          := 0;
    l_session_file_id       com_api_type_pkg.t_long_id;
    l_file_type             com_api_type_pkg.t_dict_value;

    cursor cur_xml is
        select
            xmlelement(
                "terminals"
              , xmlattributes('http://sv.bpc.in/SVXP/Terminals' as "xmlns")
              , xmlelement("file_id"  , to_char(l_session_file_id))
              , xmlelement("file_type", l_file_type)
              , xmlelement("inst_id", i_inst_id)
              , xmlagg(
                    xmlelement(
                       "terminal"
                      , xmlattributes(t.terminal_id as "terminal_id")
                      , xmlforest(
                            t.inst_id                           as "inst_id"
                          , t.agent_id                          as "agent_id"
                          , t.agent_number                      as "agent_number"
                          , t.terminal_number                   as "terminal_number"
                          , t.terminal_type                     as "terminal_type"
                          , t.mcc                               as "mcc"
                          , t.terminal_status                   as "terminal_status"
                        )
                      , xmlelement(
                            "merchant"
                          , xmlattributes(t.merchant_id as "merchant_id")
                          , xmlelement("merchant_number", t.merchant_number)
                        )
                      , xmlelement(
                            "customer"
                          , xmlattributes(t.customer_id as "customer_id")
                          , xmlelement("customer_number", t.customer_number)
                        )
                      , xmlelement(
                            "contract"
                          , xmlattributes(t.contract_id as "contract_id")
                          , xmlelement("contract_number", t.contract_number)
                        )
                      , (select xmlagg(
                                    xmlelement(
                                       "contact"
                                      , xmlattributes(c.id as "contact_id")
                                      , xmlelement("contact_type", o.contact_type)
                                      , xmlagg(
                                            xmlelement(
                                                "contact_data"
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
                          group by c.id
                                 , o.contact_type
                        ) -- end of contact
                      , (select xmlagg(
                                    xmlelement(
                                        "address"
                                      , xmlattributes(a.id as "address_id")
                                      , xmlelement("address_type", a.address_type)
                                      , xmlelement("country",      a.country)
                                      , (select xmlagg(
                                                    xmlelement(
                                                        "address_name"
                                                      , xmlattributes(aa.lang as "language")
                                                      , xmlelement("region", aa.region)
                                                      , xmlelement("city",   aa.city)
                                                      , xmlelement("street", aa.street)
                                                    )
                                                ) 
                                           from com_address aa
                                          where aa.id = a.id
                                            and (aa.lang = a.lang or i_lang is null)
                                        )
                                      , xmlelement("house",        a.house)
                                      , xmlforest(
                                            a.apartment      as "apartment"
                                          , a.postal_code    as "postal_code"
                                          , a.place_code     as "place_code"
                                          , a.region_code    as "region_code"
                                        )
                                    )
                                )
                           from (select a.id
                                      , o.address_type
                                      , a.country
                                      , a.house
                                      , a.apartment
                                      , a.postal_code
                                      , a.place_code
                                      , a.region_code
                                      , o.object_id
                                      , a.lang
                                      , row_number() over (partition by o.object_id, o.address_type 
                                                               order by decode(a.lang
                                                                             , i_lang, -1
                                                                             , com_api_const_pkg.DEFAULT_LANGUAGE, 0
                                                                             , o.address_id)
                                        ) as rn
                                   from com_address_object o
                                      , com_address a
                                  where o.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                    and a.id          = o.address_id
                                    and a.lang in (i_lang, com_api_const_pkg.DEFAULT_LANGUAGE)
                           ) a
                          where a.rn        = 1
                            and a.object_id = t.terminal_id
                        ) -- end of address
                      , (select xmlagg(
                                    xmlelement(
                                        "account"
                                      , xmlattributes(a.id as "account_id")
                                      , xmlelement("account_number", a.account_number)
                                      , xmlelement("account_type",   a.account_type)
                                      , xmlelement("currency",       a.currency)
                                      , xmlelement("account_status", a.status)
                                    )
                                )
                           from acc_account_object ao
                              , acc_account a
                          where ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                            and ao.object_id   = t.terminal_id
                            and ao.account_id  = a.id
                        )
                    )
                )
            ).getclobval()
          , count(*)
        from (
            select t.id as terminal_id
                 , t.inst_id
                 , case when length(t.terminal_number) >= 8 
                       then substr(t.terminal_number, -8)
                       else t.terminal_number
                   end as terminal_number
                 , t.terminal_type
                 , t.status as terminal_status
                 , (select s.standard_id
                      from cmn_standard_object s
                     where s.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                       and s.object_id = t.id) as standard_id
                 , (select s.version_id
                      from cmn_standard_version_obj s
                     where s.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                       and s.object_id = t.id) as version_id
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
                 , t.gmt_offset
                 , t.cash_dispenser_present
                 , t.payment_possibility
                 , t.use_card_possibility
                 , t.cash_in_present
                 , nvl(p.instalment_support, com_api_const_pkg.FALSE) as instalment_support
                 , t.pos_batch_support
                 , t.merchant_id
                 , m.merchant_name
                 , m.merchant_number
                 , m.mcc
                 , c.id as contract_id
                 , c.contract_number
                 , s.id as customer_id
                 , s.customer_number
                 , c.agent_id
                 , a.agent_number
              from acq_terminal t
                 , acq_merchant m
                 , prd_customer s
                 , prd_contract c
                 , ost_agent    a
                 , pos_terminal p
             where t.id in (select column_value from table(cast(l_object_id_tab as num_tab_tpt)))
               and t.contract_id = c.id 
               and c.customer_id = s.id 
               and c.agent_id    = a.id
               and t.merchant_id = m.id
               and t.id          = p.id(+)
        ) t;

    cur_objects             sys_refcursor;
    l_container_id          com_api_type_pkg.t_long_id;
    
    -- Generate XML file
    procedure generate_xml is
        l_fetched_count                com_api_type_pkg.t_count    := 0;
        l_params                       com_api_type_pkg.t_param_tab;
        CRLF                  constant com_api_type_pkg.t_name := chr(13) || chr(10);
    begin
        if l_object_id_tab.count > 0 then
            trc_log_pkg.debug('Creating a new XML file...');
            
            -- Save estimated count of records in the current iteration
            l_estimated_count := l_estimated_count + l_object_id_tab.count;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
            );
            trc_log_pkg.debug('Estimated count of records is [' || l_estimated_count || ']');
            
            rul_api_param_pkg.set_param (
                i_name          => 'INST_ID'
              , i_value         => i_inst_id
              , io_params       => l_params
            );
            
            prc_api_file_pkg.open_file(
                o_sess_file_id          => l_session_file_id
              , i_file_type             => l_file_type
              , i_file_purpose          => prc_api_const_pkg.FILE_PURPOSE_OUT
              , io_params               => l_params
            );

            -- For every processing batch of records we fetch data and save it in a separate file
            open cur_xml;
            fetch cur_xml into l_file, l_fetched_count;
            close cur_xml;
            
            l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

            prc_api_file_pkg.put_file(
                i_sess_file_id        => l_session_file_id
              , i_clob_content        => l_file
              , i_add_to              => com_api_const_pkg.FALSE
            );

            l_counter     := l_counter + 1;
            trc_log_pkg.debug('file saved, count=' || l_counter || ', length=' || length(l_file));

            l_total_count := l_total_count + l_fetched_count;

            prc_api_stat_pkg.log_current(
                i_current_count  => l_total_count
              , i_excepted_count => 0
            );
        end if;
    end;
    
    procedure open_cur_objects(
        o_cursor               out sys_refcursor
      , i_full_export       in     com_api_type_pkg.t_boolean
      , i_inst_id           in     com_api_type_pkg.t_inst_id
      , i_subscriber_name   in     com_api_type_pkg.t_name
    ) is
        l_sysdate   date; 
    begin
        trc_log_pkg.debug('Opening a cursor for all reconrs those are processed...');

        l_sysdate   := com_api_sttl_day_pkg.get_sysdate;
        if i_full_export = com_api_const_pkg.TRUE then
            -- Get all available objects
            open o_cursor for
                select t.id
                  from acq_terminal t
                 where t.split_hash in (select split_hash from com_api_split_map_vw)
                   and (t.inst_id   = i_inst_id  or i_inst_id = ost_api_const_pkg.DEFAULT_INST);
        else
            -- Get objects by events
            open o_cursor for
                select o.id as event_object_id
                     , t.id as terminal_id
                  from evt_event_object o
                     , acq_terminal t
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = i_subscriber_name
                   and t.split_hash in (select split_hash from com_api_split_map_vw)
                   and o.eff_date     <= l_sysdate
                   and (o.inst_id      = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                   and o.entity_type   = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                   and o.object_id     = t.id
                 order by terminal_id;
        end if;
        trc_log_pkg.debug('Cursor was opened...');
    end;

begin
    trc_log_pkg.debug(
        i_text       => 'process_terminal_1_2: START with l_full_export [#1], i_inst_id [#2], i_count [#3]'
      , i_env_param1 => l_full_export
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_count
    );
    l_container_id      := prc_api_session_pkg.get_container_id;
    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    trc_log_pkg.debug(
        i_text       => 'l_container_id [#1]'
      , i_env_param1 => l_container_id
    );

    prc_api_stat_pkg.log_start;

    open_cur_objects(
        o_cursor          => cur_objects
      , i_full_export     => l_full_export
      , i_inst_id         => i_inst_id
      , i_subscriber_name => l_subscriber_name
    );

    loop
        begin
            savepoint sp_mpt_terminal_export;

            if l_full_export = com_api_const_pkg.TRUE then
                fetch cur_objects
                 bulk collect into
                      l_object_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                -- Generate XML file
                generate_xml;

            else  -- l_full_export = com_api_const_pkg.FALSE
                fetch cur_objects
                 bulk collect into
                      l_event_tab
                    , l_incr_object_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                for i in 1 .. l_incr_object_id_tab.count loop
                    -- Decrease records count and remove the last record from previous iteration
                    if (l_incr_object_id_tab(i) != l_object_id or l_object_id is null)
                       and l_incr_object_id_tab(i) is not null
                    then
                        l_object_id := l_incr_object_id_tab(i);
                        
                        l_object_id_tab.extend;
                        l_object_id_tab(l_object_id_tab.count)       := l_incr_object_id_tab(i);
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);

                        if i = l_incr_object_id_tab.count then
                            -- Generate XML file for current portion of the "l_bulk_limit" records
                            generate_xml;

                            evt_api_event_pkg.process_event_object(
                                i_event_object_id_tab => l_incr_event_tab
                            );

                            -- Save last element of the array on a current iteration to use it for the next one
                            l_object_id_tab.delete;
                            l_incr_event_tab.delete;
                        end if;
                    else  
                        -- Select event for last account id from previous iteration
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);
                    end if;
                end loop;
                
                -- Generate XML file for last portion of records
                generate_xml;

                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab => l_incr_event_tab
                );
            end if;

            exit when cur_objects%notfound;

        exception
            when others then
                rollback to sp_mpt_terminal_export;
                raise;
        end;
    end loop;
    close cur_objects;

    prc_api_stat_pkg.log_end(
        i_excepted_total  => 0
      , i_processed_total => l_total_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug('process_terminal_1_2: FINISH');
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end;

procedure process_terminal_1_3(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_count               in     com_api_type_pkg.t_medium_id     default null
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := 'ITF_MPT_PRC_ACQ_EXPORT_PKG.PROCESS_TERMINAL';

    -- Default bulk size for records per a file if <i_count> parameter is not specified
    DEFAULT_BULK_LIMIT      constant com_api_type_pkg.t_count := 2000;
    l_bulk_limit            com_api_type_pkg.t_count          := nvl(i_count, DEFAULT_BULK_LIMIT);
    l_subscriber_name       com_api_type_pkg.t_name           := DEFAULT_PROCEDURE_NAME;
    l_full_export           com_api_type_pkg.t_boolean        := nvl(i_full_export, com_api_const_pkg.FALSE);
    l_file                  clob;
    l_total_count           com_api_type_pkg.t_count          := 0;
    l_counter               com_api_type_pkg.t_count          := 0;

    l_event_tab             com_api_type_pkg.t_number_tab;
    l_incr_event_tab        com_api_type_pkg.t_number_tab;
    l_object_id_tab         num_tab_tpt                       := num_tab_tpt();
    l_incr_object_id_tab    num_tab_tpt                       := num_tab_tpt();
    l_object_id             com_api_type_pkg.t_medium_id;
    l_estimated_count       com_api_type_pkg.t_count          := 0;
    l_session_file_id       com_api_type_pkg.t_long_id;
    l_file_type             com_api_type_pkg.t_dict_value;

    cursor cur_xml is
        select
            xmlelement(
                "terminals"
              , xmlattributes('http://sv.bpc.in/SVXP/Terminals' as "xmlns")
              , xmlelement("file_id"  , to_char(l_session_file_id))
              , xmlelement("file_type", l_file_type)
              , xmlelement("inst_id", i_inst_id)
              , xmlagg(
                    xmlelement(
                       "terminal"
                      , xmlattributes(t.terminal_id as "terminal_id")
                      , xmlforest(
                            t.inst_id                           as "inst_id"
                          , t.agent_id                          as "agent_id"
                          , t.agent_number                      as "agent_number"
                          , t.terminal_number                   as "terminal_number"
                          , t.terminal_type                     as "terminal_type"
                          , t.mcc                               as "mcc"
                          , t.terminal_status                   as "terminal_status"
                        )
                      , xmlelement(
                            "merchant"
                          , xmlattributes(t.merchant_id as "merchant_id")
                          , xmlelement("merchant_number", t.merchant_number)
                        )
                      , xmlelement(
                            "customer"
                          , xmlattributes(t.customer_id as "customer_id")
                          , xmlelement("customer_number", t.customer_number)
                        )
                      , xmlelement(
                            "contract"
                          , xmlattributes(t.contract_id as "contract_id")
                          , xmlelement("contract_number", t.contract_number)
                        )
                      , (select xmlagg(
                                    xmlelement(
                                       "contact"
                                      , xmlattributes(c.id as "contact_id")
                                      , xmlelement("contact_type", o.contact_type)
                                      , xmlagg(
                                            xmlelement(
                                                "contact_data"
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
                          group by c.id
                                 , o.contact_type
                        ) -- end of contact
                      , (select xmlagg(
                                    xmlelement(
                                        "address"
                                      , xmlattributes(a.id as "address_id")
                                      , xmlelement("address_type", a.address_type)
                                      , xmlelement("country",      a.country)
                                      , (select xmlagg(
                                                    xmlelement(
                                                        "address_name"
                                                      , xmlattributes(aa.lang as "language")
                                                      , xmlelement("region", aa.region)
                                                      , xmlelement("city",   aa.city)
                                                      , xmlelement("street", aa.street)
                                                    )
                                                ) 
                                           from com_address aa
                                          where aa.id = a.id
                                            and (aa.lang = a.lang or i_lang is null)
                                        )
                                      , xmlelement("house",        a.house)
                                      , xmlforest(
                                            a.apartment      as "apartment"
                                          , a.postal_code    as "postal_code"
                                          , a.place_code     as "place_code"
                                          , a.region_code    as "region_code"
                                        )
                                    )
                                )
                           from (select a.id
                                      , o.address_type
                                      , a.country
                                      , a.house
                                      , a.apartment
                                      , a.postal_code
                                      , a.place_code
                                      , a.region_code
                                      , o.object_id
                                      , a.lang
                                      , row_number() over (partition by o.object_id, o.address_type 
                                                               order by decode(a.lang
                                                                             , i_lang, -1
                                                                             , com_api_const_pkg.DEFAULT_LANGUAGE, 0
                                                                             , o.address_id)
                                        ) as rn
                                   from com_address_object o
                                      , com_address a
                                  where o.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                    and a.id          = o.address_id
                                    and a.lang in (i_lang, com_api_const_pkg.DEFAULT_LANGUAGE)
                           ) a
                          where a.rn        = 1
                            and a.object_id = t.terminal_id
                        ) -- end of address
                      , (select xmlagg(
                                    xmlelement(
                                        "account"
                                      , xmlattributes(a.id as "account_id")
                                      , xmlelement("account_number", a.account_number)
                                      , xmlelement("account_type",   a.account_type)
                                      , xmlelement("currency",       a.currency)
                                      , xmlelement("account_status", a.status)
                                    )
                                )
                           from acc_account_object ao
                              , acc_account a
                          where ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                            and ao.object_id   = t.terminal_id
                            and ao.account_id  = a.id
                        )
                    )
                )
            ).getclobval()
          , count(*)
        from (
            select t.id as terminal_id
                 , t.inst_id
                 , t.terminal_number
                 , t.terminal_type
                 , t.status as terminal_status
                 , (select s.standard_id
                      from cmn_standard_object s
                     where s.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                       and s.object_id = t.id) as standard_id
                 , (select s.version_id
                      from cmn_standard_version_obj s
                     where s.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                       and s.object_id = t.id) as version_id
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
                 , t.gmt_offset
                 , t.cash_dispenser_present
                 , t.payment_possibility
                 , t.use_card_possibility
                 , t.cash_in_present
                 , nvl(p.instalment_support, com_api_const_pkg.FALSE) as instalment_support
                 , t.pos_batch_support
                 , t.merchant_id
                 , m.merchant_name
                 , m.merchant_number
                 , m.mcc
                 , c.id as contract_id
                 , c.contract_number
                 , s.id as customer_id
                 , s.customer_number
                 , c.agent_id
                 , a.agent_number
              from acq_terminal t
                 , acq_merchant m
                 , prd_customer s
                 , prd_contract c
                 , ost_agent    a
                 , pos_terminal p
             where t.id in (select column_value from table(cast(l_object_id_tab as num_tab_tpt)))
               and t.contract_id = c.id 
               and c.customer_id = s.id 
               and c.agent_id    = a.id
               and t.merchant_id = m.id
               and t.id          = p.id(+)
        ) t;

    cur_objects             sys_refcursor;
    l_container_id          com_api_type_pkg.t_long_id;
    
    -- Generate XML file
    procedure generate_xml is
        l_fetched_count                com_api_type_pkg.t_count    := 0;
        l_params                       com_api_type_pkg.t_param_tab;
        CRLF                  constant com_api_type_pkg.t_name := chr(13) || chr(10);
    begin
        if l_object_id_tab.count > 0 then
            trc_log_pkg.debug('Creating a new XML file...');
            
            -- Save estimated count of records in the current iteration
            l_estimated_count := l_estimated_count + l_object_id_tab.count;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
            );
            trc_log_pkg.debug('Estimated count of records is [' || l_estimated_count || ']');
            
            rul_api_param_pkg.set_param (
                i_name          => 'INST_ID'
              , i_value         => i_inst_id
              , io_params       => l_params
            );
            
            prc_api_file_pkg.open_file(
                o_sess_file_id          => l_session_file_id
              , i_file_type             => l_file_type
              , i_file_purpose          => prc_api_const_pkg.FILE_PURPOSE_OUT
              , io_params               => l_params
            );

            -- For every processing batch of records we fetch data and save it in a separate file
            open cur_xml;
            fetch cur_xml into l_file, l_fetched_count;
            close cur_xml;
            
            l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

            prc_api_file_pkg.put_file(
                i_sess_file_id        => l_session_file_id
              , i_clob_content        => l_file
              , i_add_to              => com_api_const_pkg.FALSE
            );

            l_counter     := l_counter + 1;
            trc_log_pkg.debug('file saved, count=' || l_counter || ', length=' || length(l_file));

            l_total_count := l_total_count + l_fetched_count;

            prc_api_stat_pkg.log_current(
                i_current_count  => l_total_count
              , i_excepted_count => 0
            );
        end if;
    end;
    
    procedure open_cur_objects(
        o_cursor               out sys_refcursor
      , i_full_export       in     com_api_type_pkg.t_boolean
      , i_inst_id           in     com_api_type_pkg.t_inst_id
      , i_subscriber_name   in     com_api_type_pkg.t_name
    ) is
        l_sysdate   date; 
    begin
        trc_log_pkg.debug('Opening a cursor for all records those are processed...');

        l_sysdate   := com_api_sttl_day_pkg.get_sysdate;
        if i_full_export = com_api_const_pkg.TRUE then
            -- Get all available objects
            open o_cursor for
                select t.id
                  from acq_terminal t
                 where t.split_hash in (select split_hash from com_api_split_map_vw)
                   and (t.inst_id   = i_inst_id  or i_inst_id = ost_api_const_pkg.DEFAULT_INST);
        else
            -- Get objects by events
            open o_cursor for
                select o.id as event_object_id
                     , t.id as terminal_id
                  from evt_event_object o
                     , acq_terminal t
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = i_subscriber_name
                   and t.split_hash in (select split_hash from com_api_split_map_vw)
                   and o.eff_date     <= l_sysdate
                   and (o.inst_id      = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                   and o.entity_type   = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                   and o.object_id     = t.id
                 order by terminal_id;
        end if;
        trc_log_pkg.debug('Cursor was opened...');
    end;

begin
    trc_log_pkg.debug(
        i_text       => 'process_terminal_1_3: START with l_full_export [#1], i_inst_id [#2], i_count [#3]'
      , i_env_param1 => l_full_export
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_count
    );
    l_container_id      := prc_api_session_pkg.get_container_id;
    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    trc_log_pkg.debug(
        i_text       => 'l_container_id [#1]'
      , i_env_param1 => l_container_id
    );

    prc_api_stat_pkg.log_start;

    open_cur_objects(
        o_cursor          => cur_objects
      , i_full_export     => l_full_export
      , i_inst_id         => i_inst_id
      , i_subscriber_name => l_subscriber_name
    );

    loop
        begin
            savepoint sp_mpt_terminal_export;

            if l_full_export = com_api_const_pkg.TRUE then
                fetch cur_objects
                 bulk collect into
                      l_object_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                -- Generate XML file
                generate_xml;

            else  -- l_full_export = com_api_const_pkg.FALSE
                fetch cur_objects
                 bulk collect into
                      l_event_tab
                    , l_incr_object_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                for i in 1 .. l_incr_object_id_tab.count loop
                    -- Decrease records count and remove the last record from previous iteration
                    if (l_incr_object_id_tab(i) != l_object_id or l_object_id is null)
                       and l_incr_object_id_tab(i) is not null
                    then
                        l_object_id := l_incr_object_id_tab(i);
                        
                        l_object_id_tab.extend;
                        l_object_id_tab(l_object_id_tab.count)       := l_incr_object_id_tab(i);
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);

                        if i = l_incr_object_id_tab.count then
                            -- Generate XML file for current portion of the "l_bulk_limit" records
                            generate_xml;

                            evt_api_event_pkg.process_event_object(
                                i_event_object_id_tab => l_incr_event_tab
                            );

                            -- Save last element of the array on a current iteration to use it for the next one
                            l_object_id_tab.delete;
                            l_incr_event_tab.delete;
                        end if;
                    else  
                        -- Select event for last account id from previous iteration
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);
                    end if;
                end loop;
                
                -- Generate XML file for last portion of records
                generate_xml;

                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab => l_incr_event_tab
                );
            end if;

            exit when cur_objects%notfound;

        exception
            when others then
                rollback to sp_mpt_terminal_export;
                raise;
        end;
    end loop;
    close cur_objects;

    prc_api_stat_pkg.log_end(
        i_excepted_total  => 0
      , i_processed_total => l_total_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug('process_terminal_1_3: FINISH');
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end;

procedure process_terminal_1_7(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_count               in     com_api_type_pkg.t_medium_id     default null
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := 'ITF_MPT_PRC_ACQ_EXPORT_PKG.PROCESS_TERMINAL';

    -- Default bulk size for records per a file if <i_count> parameter is not specified
    DEFAULT_BULK_LIMIT      constant com_api_type_pkg.t_count := 2000;
    l_bulk_limit            com_api_type_pkg.t_count          := nvl(i_count, DEFAULT_BULK_LIMIT);
    l_subscriber_name       com_api_type_pkg.t_name           := DEFAULT_PROCEDURE_NAME;
    l_full_export           com_api_type_pkg.t_boolean        := nvl(i_full_export, com_api_const_pkg.FALSE);
    l_file                  clob;
    l_total_count           com_api_type_pkg.t_count          := 0;
    l_counter               com_api_type_pkg.t_count          := 0;

    l_event_tab             com_api_type_pkg.t_number_tab;
    l_incr_event_tab        com_api_type_pkg.t_number_tab;
    l_object_id_tab         num_tab_tpt                       := num_tab_tpt();
    l_incr_object_id_tab    num_tab_tpt                       := num_tab_tpt();
    l_object_id             com_api_type_pkg.t_medium_id;
    l_estimated_count       com_api_type_pkg.t_count          := 0;
    l_session_file_id       com_api_type_pkg.t_long_id;
    l_file_type             com_api_type_pkg.t_dict_value;

    cursor cur_xml is
        select
            xmlelement(
                "terminals"
              , xmlattributes('http://sv.bpc.in/SVXP/Terminals' as "xmlns")
              , xmlelement("file_id"  , to_char(l_session_file_id))
              , xmlelement("file_type", l_file_type)
              , xmlelement("inst_id", i_inst_id)
              , xmlagg(
                    xmlelement(
                       "terminal"
                      , xmlattributes(t.terminal_id as "terminal_id")
                      , xmlforest(
                            t.inst_id                           as "inst_id"
                          , t.agent_id                          as "agent_id"
                          , t.agent_number                      as "agent_number"
                          , t.terminal_number                   as "terminal_number"
                          , t.terminal_type                     as "terminal_type"
                          , t.mcc                               as "mcc"
                          , t.terminal_status                   as "terminal_status"
                          , t.status_reason                     as "status_reason"
                        )
                      , xmlelement(
                            "merchant"
                          , xmlattributes(t.merchant_id as "merchant_id")
                          , xmlelement("merchant_number", t.merchant_number)
                        )
                      , xmlelement(
                            "customer"
                          , xmlattributes(t.customer_id as "customer_id")
                          , xmlelement("customer_number", t.customer_number)
                        )
                      , xmlelement(
                            "contract"
                          , xmlattributes(t.contract_id as "contract_id")
                          , xmlelement("contract_number", t.contract_number)
                        )
                      , (select xmlagg(
                                    xmlelement(
                                       "contact"
                                      , xmlattributes(c.id as "contact_id")
                                      , xmlelement("contact_type", o.contact_type)
                                      , xmlagg(
                                            xmlelement(
                                                "contact_data"
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
                          group by c.id
                                 , o.contact_type
                        ) -- end of contact
                      , (select xmlagg(
                                    xmlelement(
                                        "address"
                                      , xmlattributes(a.id as "address_id")
                                      , xmlelement("address_type", a.address_type)
                                      , xmlelement("country",      a.country)
                                      , (select xmlagg(
                                                    xmlelement(
                                                        "address_name"
                                                      , xmlattributes(aa.lang as "language")
                                                      , xmlelement("region", aa.region)
                                                      , xmlelement("city",   aa.city)
                                                      , xmlelement("street", aa.street)
                                                    )
                                                ) 
                                           from com_address aa
                                          where aa.id = a.id
                                            and (aa.lang = a.lang or i_lang is null)
                                        )
                                      , xmlelement("house",        a.house)
                                      , xmlforest(
                                            a.apartment      as "apartment"
                                          , a.postal_code    as "postal_code"
                                          , a.place_code     as "place_code"
                                          , a.region_code    as "region_code"
                                        )
                                    )
                                )
                           from (select a.id
                                      , o.address_type
                                      , a.country
                                      , a.house
                                      , a.apartment
                                      , a.postal_code
                                      , a.place_code
                                      , a.region_code
                                      , o.object_id
                                      , a.lang
                                      , row_number() over (partition by o.object_id, o.address_type 
                                                               order by decode(a.lang
                                                                             , i_lang, -1
                                                                             , com_api_const_pkg.DEFAULT_LANGUAGE, 0
                                                                             , o.address_id)
                                        ) as rn
                                   from com_address_object o
                                      , com_address a
                                  where o.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                    and a.id          = o.address_id
                                    and a.lang in (i_lang, com_api_const_pkg.DEFAULT_LANGUAGE)
                           ) a
                          where a.rn        = 1
                            and a.object_id = t.terminal_id
                        ) -- end of address
                      , (select xmlagg(
                                    xmlelement(
                                        "account"
                                      , xmlattributes(a.id as "account_id")
                                      , xmlelement("account_number", a.account_number)
                                      , xmlelement("account_type",   a.account_type)
                                      , xmlelement("currency",       a.currency)
                                      , xmlelement("account_status", a.status)
                                    )
                                )
                           from acc_account_object ao
                              , acc_account a
                          where ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                            and ao.object_id   = t.terminal_id
                            and ao.account_id  = a.id
                        )
                    )
                )
            ).getclobval()
          , count(*)
        from (
            select t.id as terminal_id
                 , t.inst_id
                 , t.terminal_number
                 , t.terminal_type
                 , t.status as terminal_status
                 , evt_api_status_pkg.get_status_reason(
                       i_entity_type   => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                     , i_object_id     => t.id
                     , i_raise_error   => com_api_const_pkg.FALSE
                   ) as status_reason
                 , (select s.standard_id
                      from cmn_standard_object s
                     where s.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                       and s.object_id = t.id) as standard_id
                 , (select s.version_id
                      from cmn_standard_version_obj s
                     where s.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                       and s.object_id = t.id) as version_id
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
                 , t.gmt_offset
                 , t.cash_dispenser_present
                 , t.payment_possibility
                 , t.use_card_possibility
                 , t.cash_in_present
                 , nvl(p.instalment_support, com_api_const_pkg.FALSE) as instalment_support
                 , t.pos_batch_support
                 , t.merchant_id
                 , m.merchant_name
                 , m.merchant_number
                 , m.mcc
                 , c.id as contract_id
                 , c.contract_number
                 , s.id as customer_id
                 , s.customer_number
                 , c.agent_id
                 , a.agent_number
              from acq_terminal t
                 , acq_merchant m
                 , prd_customer s
                 , prd_contract c
                 , ost_agent    a
                 , pos_terminal p
             where t.id in (select column_value from table(cast(l_object_id_tab as num_tab_tpt)))
               and t.contract_id = c.id 
               and c.customer_id = s.id 
               and c.agent_id    = a.id
               and t.merchant_id = m.id
               and t.id          = p.id(+)
        ) t;

    cur_objects             sys_refcursor;
    l_container_id          com_api_type_pkg.t_long_id;
    
    -- Generate XML file
    procedure generate_xml is
        l_fetched_count                com_api_type_pkg.t_count    := 0;
        l_params                       com_api_type_pkg.t_param_tab;
        CRLF                  constant com_api_type_pkg.t_name := chr(13) || chr(10);
    begin
        if l_object_id_tab.count > 0 then
            trc_log_pkg.debug('Creating a new XML file...');
            
            -- Save estimated count of records in the current iteration
            l_estimated_count := l_estimated_count + l_object_id_tab.count;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
            );
            trc_log_pkg.debug('Estimated count of records is [' || l_estimated_count || ']');
            
            rul_api_param_pkg.set_param (
                i_name          => 'INST_ID'
              , i_value         => i_inst_id
              , io_params       => l_params
            );
            
            prc_api_file_pkg.open_file(
                o_sess_file_id          => l_session_file_id
              , i_file_type             => l_file_type
              , i_file_purpose          => prc_api_const_pkg.FILE_PURPOSE_OUT
              , io_params               => l_params
            );

            -- For every processing batch of records we fetch data and save it in a separate file
            open cur_xml;
            fetch cur_xml into l_file, l_fetched_count;
            close cur_xml;
            
            l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

            prc_api_file_pkg.put_file(
                i_sess_file_id        => l_session_file_id
              , i_clob_content        => l_file
              , i_add_to              => com_api_const_pkg.FALSE
            );

            l_counter     := l_counter + 1;
            trc_log_pkg.debug('file saved, count=' || l_counter || ', length=' || length(l_file));

            l_total_count := l_total_count + l_fetched_count;

            prc_api_stat_pkg.log_current(
                i_current_count  => l_total_count
              , i_excepted_count => 0
            );
        end if;
    end;
    
    procedure open_cur_objects(
        o_cursor               out sys_refcursor
      , i_full_export       in     com_api_type_pkg.t_boolean
      , i_inst_id           in     com_api_type_pkg.t_inst_id
      , i_subscriber_name   in     com_api_type_pkg.t_name
    ) is
        l_sysdate   date; 
    begin
        trc_log_pkg.debug('Opening a cursor for all records those are processed...');

        l_sysdate   := com_api_sttl_day_pkg.get_sysdate;
        if i_full_export = com_api_const_pkg.TRUE then
            -- Get all available objects
            open o_cursor for
                select t.id
                  from acq_terminal t
                 where t.split_hash in (select split_hash from com_api_split_map_vw)
                   and (t.inst_id   = i_inst_id  or i_inst_id = ost_api_const_pkg.DEFAULT_INST);
        else
            -- Get objects by events
            open o_cursor for
                select o.id as event_object_id
                     , t.id as terminal_id
                  from evt_event_object o
                     , acq_terminal t
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = i_subscriber_name
                   and t.split_hash in (select split_hash from com_api_split_map_vw)
                   and o.eff_date     <= l_sysdate
                   and (o.inst_id      = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                   and o.entity_type   = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                   and o.object_id     = t.id
                 order by terminal_id;
        end if;
        trc_log_pkg.debug('Cursor was opened...');
    end;

begin
    trc_log_pkg.debug(
        i_text       => 'process_terminal_1_3: START with l_full_export [#1], i_inst_id [#2], i_count [#3]'
      , i_env_param1 => l_full_export
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_count
    );
    l_container_id      := prc_api_session_pkg.get_container_id;
    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    trc_log_pkg.debug(
        i_text       => 'l_container_id [#1]'
      , i_env_param1 => l_container_id
    );

    prc_api_stat_pkg.log_start;

    open_cur_objects(
        o_cursor          => cur_objects
      , i_full_export     => l_full_export
      , i_inst_id         => i_inst_id
      , i_subscriber_name => l_subscriber_name
    );

    loop
        begin
            savepoint sp_mpt_terminal_export;

            if l_full_export = com_api_const_pkg.TRUE then
                fetch cur_objects
                 bulk collect into
                      l_object_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                -- Generate XML file
                generate_xml;

            else  -- l_full_export = com_api_const_pkg.FALSE
                fetch cur_objects
                 bulk collect into
                      l_event_tab
                    , l_incr_object_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                for i in 1 .. l_incr_object_id_tab.count loop
                    -- Decrease records count and remove the last record from previous iteration
                    if (l_incr_object_id_tab(i) != l_object_id or l_object_id is null)
                       and l_incr_object_id_tab(i) is not null
                    then
                        l_object_id := l_incr_object_id_tab(i);
                        
                        l_object_id_tab.extend;
                        l_object_id_tab(l_object_id_tab.count)       := l_incr_object_id_tab(i);
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);

                        if i = l_incr_object_id_tab.count then
                            -- Generate XML file for current portion of the "l_bulk_limit" records
                            generate_xml;

                            evt_api_event_pkg.process_event_object(
                                i_event_object_id_tab => l_incr_event_tab
                            );

                            -- Save last element of the array on a current iteration to use it for the next one
                            l_object_id_tab.delete;
                            l_incr_event_tab.delete;
                        end if;
                    else  
                        -- Select event for last account id from previous iteration
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);
                    end if;
                end loop;
                
                -- Generate XML file for last portion of records
                generate_xml;

                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab => l_incr_event_tab
                );
            end if;

            exit when cur_objects%notfound;

        exception
            when others then
                rollback to sp_mpt_terminal_export;
                raise;
        end;
    end loop;
    close cur_objects;

    prc_api_stat_pkg.log_end(
        i_excepted_total  => 0
      , i_processed_total => l_total_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug('process_terminal_1_3: FINISH');
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end;

procedure process_merchant(
    i_mpt_version         in     com_api_type_pkg.t_name
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_count               in     com_api_type_pkg.t_medium_id     default null
) as
begin
    trc_log_pkg.debug(
        i_text        => 'i_mpt_version=' || i_mpt_version
    );
    
    if i_mpt_version between '1.2' and '1.3' then
        process_merchant_1_2(
            i_inst_id     => i_inst_id
          , i_full_export => i_full_export
          , i_lang        => i_lang
          , i_count       => i_count
        );
    elsif i_mpt_version between '1.4' and '1.6' then
        process_merchant_1_4(
            i_inst_id     => i_inst_id
          , i_full_export => i_full_export
          , i_lang        => i_lang
          , i_count       => i_count
        );
    elsif i_mpt_version = '1.7' then
        process_merchant_1_7(
            i_inst_id     => i_inst_id
          , i_full_export => i_full_export
          , i_lang        => i_lang
          , i_count       => i_count
        );
    else
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'VERSION_IS_NOT_SUPPORTED'
          , i_env_param1  => i_mpt_version
        );
    end if;
end;

procedure process_terminal(
    i_mpt_version         in     com_api_type_pkg.t_name
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_count               in     com_api_type_pkg.t_medium_id     default null
) as
begin
    trc_log_pkg.debug(
        i_text        => 'i_mpt_version=' || i_mpt_version
    );
    
    if i_mpt_version = '1.2' then
        process_terminal_1_2(
            i_inst_id     => i_inst_id
          , i_full_export => i_full_export
          , i_lang        => i_lang
          , i_count       => i_count
        );
    elsif i_mpt_version between '1.3' and '1.6' then
        process_terminal_1_3(
            i_inst_id     => i_inst_id
          , i_full_export => i_full_export
          , i_lang        => i_lang
          , i_count       => i_count
        );
    elsif i_mpt_version = '1.7' then
        process_terminal_1_7(
            i_inst_id     => i_inst_id
          , i_full_export => i_full_export
          , i_lang        => i_lang
          , i_count       => i_count
        );
    else
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'VERSION_IS_NOT_SUPPORTED'
          , i_env_param1  => i_mpt_version
        );
    end if;
end;

end;
/
