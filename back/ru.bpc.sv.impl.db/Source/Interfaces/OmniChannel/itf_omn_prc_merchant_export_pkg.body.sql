create or replace package body itf_omn_prc_merchant_exp_pkg is
/*********************************************************
 *  Export merchants into Omni channel processes <br />
 *  Created by Andrey Fomichev (fomichev@bpcbt.com) at 25.04.2018 <br />
 *  Last changed by $Author: fomichev $ <br />
 *  $LastChangedDate:: 2018-04-25 11:28:00 +0400#$ <br />
 *  Module: itf_omn_prc_merchant_exp_pkg <br />
 *  @headcom
 **********************************************************/

procedure process_merchant_1_0(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_count               in     com_api_type_pkg.t_medium_id     default null
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := 'ITF_OMN_PRC_MERCHANT_EXP_PKG.PROCESS_MERCHANT';

    -- Default bulk size for records per a file if <i_count> parameter is not specified
    DEFAULT_BULK_LIMIT      constant com_api_type_pkg.t_count := 2000;
    l_bulk_limit            com_api_type_pkg.t_count          := nvl(i_count, DEFAULT_BULK_LIMIT);
    l_subscriber_name       com_api_type_pkg.t_name           := DEFAULT_PROCEDURE_NAME;
    l_full_export           com_api_type_pkg.t_boolean        := nvl(i_full_export, com_api_const_pkg.FALSE);
    l_file                  clob;
    l_total_count           com_api_type_pkg.t_count          := 0;
    l_counter               com_api_type_pkg.t_count          := 0;
    l_event_tab             com_api_type_pkg.t_number_tab;
    l_object_id_tab         num_tab_tpt                       := num_tab_tpt();
    l_estimated_count_tab   num_tab_tpt                       := num_tab_tpt();
    l_processed_count_tab   num_tab_tpt                       := num_tab_tpt();
    l_estimated_count       com_api_type_pkg.t_long_id;
    l_processed_count       com_api_type_pkg.t_long_id;
    l_session_file_id       com_api_type_pkg.t_long_id;
    l_file_type             com_api_type_pkg.t_dict_value;
    l_empty_file            com_api_type_pkg.t_boolean;
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
                                      , xmlattributes(l.lang as "language")
                                      , nvl(i.text, eng.text)
                                    )
                                )
                           from com_i18n i 
                              , com_i18n eng
                              , com_language_vw l
                          where i.column_name(+) = 'LABEL'
                            and i.table_name(+)  = 'ACQ_MERCHANT'
                            and eng.column_name  = 'LABEL'
                            and eng.table_name   = 'ACQ_MERCHANT'
                            and i.lang(+)        = l.lang
                            and eng.lang         = com_api_const_pkg.DEFAULT_LANGUAGE
                            and (l.lang          = i_lang or i_lang is null)
                            and i.object_id (+)  = m.merchant_id
                            and eng.object_id    = m.merchant_id
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
                                                      , xmlattributes(l.lang as "language")
                                                      , xmlelement("region", nvl(aa.region, eng.region) )
                                                      , xmlelement("city",   nvl(aa.city,   eng.city  ) )
                                                      , xmlelement("street", nvl(aa.street, eng.street) )
                                                    )
                                                ) 
                                           from com_address aa
                                              , com_address eng
                                              , com_language_vw l
                                          where aa.id(+)   = a.id
                                            and aa.lang(+) = l.lang
                                            and eng.id     = a.id
                                            and eng.lang   = com_api_const_pkg.DEFAULT_LANGUAGE
                                            and (l.lang    = i_lang or i_lang is null)
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
                                      , l.lang
                                      , row_number() over (partition by o.object_id, o.address_type 
                                                               order by decode(a.lang
                                                                             , i_lang, -1
                                                                             , com_api_const_pkg.DEFAULT_LANGUAGE, 0
                                                                             , o.address_id)
                                        ) rn
                                   from com_address_object o
                                      , com_address a
                                      , com_language_vw l
                                  where o.entity_type   = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                    and a.id            = o.address_id
                                    and (a.lang         = i_lang or i_lang is null)
                           ) a
                          where a.object_id = m.merchant_id
                          and a.rn = 1
                        ) -- end of address
                    ----------  merchant card
                      , (select xmlagg(
                                    xmlelement("merchant_card"
                                      ,  xmlelement("card_number"
                                                 , iss_api_token_pkg.decode_card_number(q.card_number)
                                         )
                                    )
                                )
                         from( select distinct 
                                      card_number 
                                    , om.object_id
                                    , om.split_hash
                                 from acc_account a
                                    , acc_account_object oc -- for card
                                    , acc_account_object om -- for merchant
                                    , iss_card_instance ci
                                    , iss_card_number cn
                                where oc.account_id  = a.id
                                  and oc.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                                  and oc.object_id   = ci.card_id
                                  and om.split_hash  = a.split_hash
                                  and om.account_id  = oc.account_id
                                  and om.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                  and om.split_hash  = oc.split_hash
                                  and cn.card_id     = ci.card_id
                                  and ci.state      != iss_api_const_pkg.CARD_STATE_CLOSED
                                  and ci.split_hash  = oc.split_hash
                             ) q 
                         where q.object_id  = m.merchant_id 
                           and q.split_hash = m.split_hash
                        ) -- end of merchant card
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
             where m.id in (select x.column_value from table(cast(l_object_id_tab as num_tab_tpt)) x where x.column_value is not null)
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
            select distinct m.id
                 , count(1) over() estimated_cnt
                 , count(distinct m.id) over() processed_cnt
              from acq_merchant m
                 , acc_account a
                 , acc_account_object oc -- for card
                 , acc_account_object om -- for merchant
                 , iss_card_instance i
             where oc.account_id  = a.id
               and oc.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
               and oc.object_id   = i.card_id
               and oc.split_hash  = i.split_hash
               and om.account_id  = oc.account_id
               and om.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
               and om.object_id   = m.id
               and om.split_hash  = oc.split_hash
               and i.state       != iss_api_const_pkg.CARD_STATE_CLOSED
               and (m.inst_id     = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
               and m.split_hash in (select split_hash from com_api_split_map_vw);
        else
            -- Get objects by events
            open o_cursor for
            select event_object_id
                 , case when rn=1 then merchant_id  end as merchant_id 
                 , count(1) over() estimated_cnt
                 , count(distinct case when rn=1 then merchant_id  end) over() processed_cnt
                 
              from (
                  select event_object_id
                       , merchant_id
                       , row_number() over(partition by merchant_id order by event_object_id) rn
                    from (
                        select o.id as event_object_id
                            -- unload merchants with merchant card in active state only
                             , decode( (select count(i.id)
                                          from acc_account a
                                             , acc_account_object oc -- for card
                                             , acc_account_object om -- for merchant
                                             , iss_card_instance i
                                         where oc.account_id  = a.id
                                           and om.account_id  = oc.account_id
                                           and oc.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                                           and oc.object_id   = i.card_id
                                           and om.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                           and om.object_id   = m.id
                                           and oc.split_hash  = i.split_hash
                                           and om.split_hash  = oc.split_hash
                                           and i.state       != iss_api_const_pkg.CARD_STATE_CLOSED
                                       )
                                     , 0
                                     , null
                                     , m.id
                               ) as merchant_id
                          from evt_event_object o
                             , acq_merchant m
                         where decode(o.status, 'EVST0001', o.procedure_name, null) = i_subscriber_name
                           and m.split_hash in (select x.split_hash from com_api_split_map_vw x)
                           and o.eff_date     <= l_sysdate
                           and (o.inst_id      = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                           and o.entity_type   = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                           and o.object_id     = m.id
                         )
                   )
               order by merchant_id nulls last;
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
            savepoint sp_merchant_export;

            if l_full_export = com_api_const_pkg.TRUE then
                fetch cur_objects
                 bulk collect into
                      l_object_id_tab
                    , l_estimated_count_tab
                    , l_processed_count_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                if l_estimated_count is null and l_estimated_count_tab.exists(1) and l_processed_count_tab.exists(1) then
                    l_estimated_count := l_estimated_count_tab(1);
                    l_processed_count := l_processed_count_tab(1);
                    prc_api_stat_pkg.log_estimation(
                        i_estimated_count => l_estimated_count
                    );
                end if;

                -- Generate XML file
                generate_xml;

            else  -- l_full_export = com_api_const_pkg.FALSE
                fetch cur_objects
                 bulk collect into
                      l_event_tab
                    , l_object_id_tab
                    , l_estimated_count_tab
                    , l_processed_count_tab
                limit l_bulk_limit;

                if l_estimated_count is null and l_estimated_count_tab.exists(1) and l_processed_count_tab.exists(1) then 
                    l_estimated_count := l_estimated_count_tab(1);
                    l_processed_count := l_processed_count_tab(1);
                    prc_api_stat_pkg.log_estimation(
                        i_estimated_count => l_estimated_count
                    );
                end if;
                  
                -- Generate XML file for current portion of the "l_bulk_limit" records
                l_empty_file := com_api_const_pkg.TRUE;    
                if l_object_id_tab.count>0 and l_object_id_tab.exists(1) then
                    for x in l_object_id_tab.first.. l_object_id_tab.last loop

                        if l_object_id_tab.exists(x) and l_object_id_tab(x) is not null then
                            l_empty_file := com_api_const_pkg.FALSE;
                        end if;
                    end loop;
                end if;
                -- Skip empty files
                if l_empty_file = com_api_const_pkg.FALSE then
                    generate_xml;
                end if;
            end if;
            exit when cur_objects%notfound;

        exception
            when others then
                rollback to sp_merchant_export;
                raise;
        end;
    end loop;
    close cur_objects;

    if l_full_export = com_api_const_pkg.FALSE then
        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab => l_event_tab
        );
    end if;

    if l_estimated_count is null then
       prc_api_stat_pkg.log_estimation(
            i_estimated_count => 0
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_excepted_total  => nvl(l_estimated_count, 0) - nvl(l_processed_count, 0)
      , i_processed_total => nvl(l_processed_count, 0)
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
end process_merchant_1_0;
 
procedure process_merchant(
    i_omni_version in    com_api_type_pkg.t_name
  , i_inst_id      in    com_api_type_pkg.t_inst_id
  , i_full_export  in    com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_lang         in    com_api_type_pkg.t_dict_value
  , i_count        in    com_api_type_pkg.t_long_id
) is
begin
    trc_log_pkg.debug(
        i_text        => 'i_omni_version=' || i_omni_version
    );
    
    if i_omni_version between '1.0' and '1.0' then
        process_merchant_1_0(
            i_inst_id     => i_inst_id
          , i_full_export => i_full_export
          , i_lang        => i_lang
          , i_count       => i_count
        );
    else
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'VERSION_IS_NOT_SUPPORTED'
          , i_env_param1  => i_omni_version
        );
    end if;
end process_merchant;

end itf_omn_prc_merchant_exp_pkg;
/
