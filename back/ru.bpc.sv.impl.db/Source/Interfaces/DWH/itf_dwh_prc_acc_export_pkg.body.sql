create or replace package body itf_dwh_prc_acc_export_pkg is

procedure process_1_0(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_full_export           in     com_api_type_pkg.t_boolean        default null
  , i_lang                  in     com_api_type_pkg.t_dict_value     default null
  , i_count                 in     com_api_type_pkg.t_medium_id      default null
) is
    LOG_PREFIX             constant com_api_type_pkg.t_name  := lower($$PLSQL_UNIT) || '.process_1_0';
    BULK_LIMIT             constant simple_integer       := 2000;
    l_bulk_limit           simple_integer                := nvl(i_count, BULK_LIMIT);
    l_estimate_count       simple_integer := 0;
    l_file                 clob;
    l_file_type            com_api_type_pkg.t_dict_value;
    l_container_id         com_api_type_pkg.t_long_id    :=  prc_api_session_pkg.get_container_id;
    l_full_export          com_api_type_pkg.t_boolean;
    l_params               com_api_type_pkg.t_param_tab;

    l_event_tab            com_api_type_pkg.t_number_tab;
    l_incr_event_tab       com_api_type_pkg.t_number_tab;
    l_account_id_tab       num_tab_tpt                   := num_tab_tpt();
    l_incr_account_id_tab  num_tab_tpt                   := num_tab_tpt();
    l_account_id           com_api_type_pkg.t_account_id;
    l_sysdate              date;
    l_total_count          com_api_type_pkg.t_medium_id;
    l_session_file_id      com_api_type_pkg.t_long_id;

    l_estimated_count      com_api_type_pkg.t_count          := 0;
    l_counter              com_api_type_pkg.t_count          := 0;
    
    cursor all_account_cur is
        select a.id
          from acc_account a
         where a.split_hash    in (select split_hash from com_api_split_map_vw)
           and (a.inst_id   = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST);

    cursor evt_object_cur is
        select o.id
             , o.object_id     as account_id
          from evt_event_object o
             , acc_account a
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_DWH_PRC_ACC_EXPORT_PKG.PROCESS'
           and o.split_hash    in (select split_hash from com_api_split_map_vw)
           and o.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
           and o.eff_date      <= l_sysdate
           and (o.inst_id       = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
           and a.id             = o.object_id
           and a.split_hash     = o.split_hash
           and a.inst_id        = o.inst_id
       union all
        select o.id
             , ae.account_id
          from evt_event_object o
             , acc_entry ae
             , acc_account a
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_DWH_PRC_ACC_EXPORT_PKG.PROCESS'
           and o.split_hash    in (select split_hash from com_api_split_map_vw)
           and o.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ENTRY
           and o.eff_date      <= l_sysdate
           and (o.inst_id       = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
           and ae.id            = o.object_id
           and ae.split_hash    = o.split_hash
           and a.id             = ae.account_id
           and a.split_hash     = ae.split_hash
           and a.inst_id        = o.inst_id
      order by account_id;

    cursor main_cur_xml is
        select xmlelement(
                   "accounts"
                 , xmlattributes('http://sv.bpc.in/SVXP/Accounts' as "xmlns")
                 , xmlelement("file_id"  ,    to_char(l_session_file_id))
                 , xmlelement("file_type",    l_file_type)
                 , xmlelement("inst_id",      i_inst_id)
                 , xmlagg(
                       xmlelement(
                           "account"
                         , xmlattributes(g.account_id as "account_id")
                         , xmlelement("inst_id",         min(g.inst_id))
                         , xmlelement("agent_id",        min(g.agent_id))
                         , xmlelement("agent_number",    min(g.agent_number))
                         , xmlelement("account_number",  min(g.account_number))
                         , xmlforest(
                               min(g.account_type) as "account_type"
                             , min(g.status) as "account_status"
                           )
                         , xmlelement("currency",        min(g.account_currency))
                         , xmlelement(
                               "customer"
                             , xmlattributes(min(g.customer_id) as "customer_id")
                             , xmlelement("customer_number",  min(g.customer_number))
                           )
                         , xmlelement(
                               "contract"
                             , xmlattributes(min(g.contract_id) as "contract_id")
                             , xmlelement("contract_number",  min(g.contract_number))
                           )
                         , xmlagg(
                               xmlelement(
                                   "balance"
                                 , xmlattributes(g.balance_id as "balance_id")
                                 , xmlelement("balance_type",       g.balance_type)
                                 , xmlelement("balance_currency",   g.balance_currency)
                                 , xmlelement("balance_status",     g.balance_status)
                                 , xmlforest(
                                       to_date(g.balance_open_date, com_api_const_pkg.XML_DATE_FORMAT) as "balance_open_date"
                                     , to_date(g.balance_close_date, com_api_const_pkg.XML_DATE_FORMAT) as "balance_close_date"
                                   )
                               )
                           )
                       )
                   )
               ).getclobval()
             , count(1)
       from (
               select a.id account_id
                    , a.currency account_currency
                    , a.account_type
                    , a.status
                    , a.account_number
                    , a.currency
                    , a.inst_id
                    , a.split_hash
                    , a.agent_id
                    , ag.agent_number
                    , a.customer_id
                    , c.customer_number
                    , a.contract_id
                    , ct.contract_number
                    , ab.id as balance_id
                    , ab.balance_type
                    , ab.status as balance_status
                    , ab.currency as balance_currency 
                    , ab.open_date as balance_open_date
                    , ab.close_date as balance_close_date
                 from acc_account a
                    , acc_balance ab
                    , ost_agent ag
                    , prd_customer c
                    , prd_contract ct
                where a.id in (select column_value from table(cast(l_account_id_tab as num_tab_tpt)))
                  and ab.split_hash  = a.split_hash
                  and ab.account_id  = a.id
                  and a.agent_id     = ag.id
                  and a.customer_id  = c.id
                  and a.contract_id  = ct.id
            ) g
     group by g.account_id
            , g.split_hash
            , g.inst_id;

    -- Generate XML file
    procedure generate_xml is
        l_fetched_count                com_api_type_pkg.t_count    := 0;
        l_params                       com_api_type_pkg.t_param_tab;
        CRLF                  constant com_api_type_pkg.t_name := chr(13) || chr(10);
    begin
        if l_account_id_tab.count > 0 then
            trc_log_pkg.debug('Creating a new XML file...');
            
            -- Save estimated count of cards in the current iteration
            l_estimated_count := l_estimated_count + l_account_id_tab.count;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
              , i_measure         => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
            );
            trc_log_pkg.debug('Estimated count of cards is [' || l_estimated_count || ']');
            
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
        
            open  main_cur_xml;
            fetch main_cur_xml into l_file, l_fetched_count;
            close main_cur_xml;

            l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

            prc_api_file_pkg.put_file(
                i_sess_file_id        => l_session_file_id
              , i_clob_content        => l_file
              , i_add_to              => com_api_type_pkg.FALSE
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

begin
    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    l_full_export     := nvl(i_full_export, com_api_type_pkg.FALSE);
    l_sysdate         := com_api_sttl_day_pkg.get_sysdate;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX
                     || ' START: file_type [#1], thread_number [' || get_thread_number()
                     || '], l_container_id [' || l_container_id
                     || '], l_full_export [' || l_full_export
                     || '], i_lang [' || i_lang
                     || '], l_sysdate [' || to_char(l_sysdate, 'dd.mm.yyyy hh24:mi:ss')
                     || ']'
      , i_env_param1 => l_file_type
    );
    
    prc_api_stat_pkg.log_start;
    l_total_count := 0;

    if l_full_export = com_api_type_pkg.TRUE then

        select count(1)
          into l_estimate_count
          from acc_account a
         where a.split_hash in (select split_hash from com_api_split_map_vw)
           and (a.inst_id   = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST);

        trc_log_pkg.debug('Estimate count = [' || l_estimate_count || ']');

        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_estimate_count
          , i_measure         => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
        );

        open all_account_cur;
        loop
            savepoint sp_dwh_account_export;

            fetch all_account_cur bulk collect into
                  l_account_id_tab
            limit l_bulk_limit;

            -- Generate XML file
            generate_xml;

            exit when all_account_cur%notfound;
        end loop;
        close all_account_cur;
    else -- incremental export
        select count(distinct account_id) as cnt
          into l_estimate_count
          from (
              select a.id as account_id
                from evt_event_object o
                   , acc_account a
               where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_DWH_PRC_ACC_EXPORT_PKG.PROCESS'
                 and o.split_hash    in (select split_hash from com_api_split_map_vw)
                 and o.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                 and o.eff_date      <= l_sysdate
                 and (o.inst_id       = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                 and a.id             = o.object_id
                 and a.split_hash     = o.split_hash
                 and a.inst_id        = o.inst_id
             union all
              select a.id
                from evt_event_object o
                   , acc_entry ae
                   , acc_account a
               where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_DWH_PRC_ACC_EXPORT_PKG.PROCESS'
                 and o.split_hash    in (select split_hash from com_api_split_map_vw)
                 and o.entity_type    = 'ENTTENTR'
                 and o.eff_date      <= l_sysdate
                 and (o.inst_id       = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                 and ae.id            = o.object_id
                 and ae.split_hash    = o.split_hash
                 and a.id             = ae.account_id
                 and a.split_hash     = ae.split_hash
                 and a.inst_id        = o.inst_id
        );

        trc_log_pkg.debug('Estimate count = [' || l_estimate_count || ']');

        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_estimate_count
          , i_measure         => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
        );

        if l_estimate_count > 0 then
            open evt_object_cur;
            loop
                savepoint sp_dwh_account_export;
                    
                fetch evt_object_cur bulk collect into
                      l_event_tab
                    , l_incr_account_id_tab
                limit l_bulk_limit;

                for i in 1 .. l_incr_account_id_tab.count loop
                    if l_event_tab(i) is not null then
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);
                    end if;
                    
                    -- Decrease account count and remove the last account id from previous iteration
                    if (l_incr_account_id_tab(i) != l_account_id or l_account_id is null)
                       and l_incr_account_id_tab(i) is not null
                    then
                        l_account_id_tab.extend;
                        l_account_id_tab(l_account_id_tab.count) := l_incr_account_id_tab(i);

                        if i = l_incr_account_id_tab.count then
                            trc_log_pkg.debug('full package. i = ' || i);
                            -- Generate XML file for current portion of the "l_bulk_limit" records
                            generate_xml;

                            evt_api_event_pkg.process_event_object(
                                i_event_object_id_tab => l_incr_event_tab
                            );

                            -- Save last element of the array on a current iteration to use it for the next one
                            l_account_id := l_incr_account_id_tab(i);
                            trc_log_pkg.debug('last account after generating xml l_account_id = ' || l_account_id);
                            l_account_id_tab.delete;
                            l_incr_event_tab.delete;
                        end if;
                    end if;
                end loop;
                
                -- Generate XML file for last portion of records
                generate_xml;

                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab => l_incr_event_tab
                );

                trc_log_pkg.debug('events were processed, cnt = ' || l_event_tab.count);

                exit when evt_object_cur%notfound;
            end loop;

            close evt_object_cur;
        end if;  -- l_estimate_count > 0
    end if;      -- incremental export

    prc_api_stat_pkg.log_end(
        i_processed_total  => l_total_count
      , i_excepted_total   => 0
      , i_rejected_total   => 0
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(LOG_PREFIX || ' END: l_total_count [' || l_total_count || ']');

exception
    when others then
        rollback to sp_dwh_account_export;
        
        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
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

procedure process_1_3(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_full_export           in     com_api_type_pkg.t_boolean        default null
  , i_lang                  in     com_api_type_pkg.t_dict_value     default null
  , i_count                 in     com_api_type_pkg.t_medium_id      default null
) is
    LOG_PREFIX             constant com_api_type_pkg.t_name  := lower($$PLSQL_UNIT) || '.process_1_0';
    BULK_LIMIT             constant simple_integer       := 2000;
    l_bulk_limit           simple_integer                := nvl(i_count, BULK_LIMIT);
    l_estimate_count       simple_integer := 0;
    l_file                 clob;
    l_file_type            com_api_type_pkg.t_dict_value;
    l_container_id         com_api_type_pkg.t_long_id    :=  prc_api_session_pkg.get_container_id;
    l_full_export          com_api_type_pkg.t_boolean;
    l_params               com_api_type_pkg.t_param_tab;

    l_event_tab            com_api_type_pkg.t_number_tab;
    l_incr_event_tab       com_api_type_pkg.t_number_tab;
    l_account_id_tab       num_tab_tpt                   := num_tab_tpt();
    l_incr_account_id_tab  num_tab_tpt                   := num_tab_tpt();
    l_account_id           com_api_type_pkg.t_account_id;
    l_sysdate              date;
    l_total_count          com_api_type_pkg.t_medium_id;
    l_session_file_id      com_api_type_pkg.t_long_id;

    l_estimated_count      com_api_type_pkg.t_count          := 0;
    l_counter              com_api_type_pkg.t_count          := 0;
    
    cursor all_account_cur is
        select a.id
          from acc_account a
         where a.split_hash    in (select split_hash from com_api_split_map_vw)
           and (a.inst_id   = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST);

    cursor evt_object_cur is
        select o.id
             , o.object_id     as account_id
          from evt_event_object o
             , acc_account a
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_DWH_PRC_ACC_EXPORT_PKG.PROCESS'
           and o.split_hash    in (select split_hash from com_api_split_map_vw)
           and o.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
           and o.eff_date      <= l_sysdate
           and (o.inst_id       = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
           and a.id             = o.object_id
           and a.split_hash     = o.split_hash
           and a.inst_id        = o.inst_id
       union all
        select o.id
             , ae.account_id
          from evt_event_object o
             , acc_entry ae
             , acc_account a
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_DWH_PRC_ACC_EXPORT_PKG.PROCESS'
           and o.split_hash    in (select split_hash from com_api_split_map_vw)
           and o.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ENTRY
           and o.eff_date      <= l_sysdate
           and (o.inst_id       = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
           and ae.id            = o.object_id
           and ae.split_hash    = o.split_hash
           and a.id             = ae.account_id
           and a.split_hash     = ae.split_hash
           and a.inst_id        = o.inst_id
      order by account_id;

    cursor main_cur_xml is
        select xmlelement(
                   "accounts"
                 , xmlattributes('http://sv.bpc.in/SVXP/Accounts' as "xmlns")
                 , xmlelement("file_id"  ,    to_char(l_session_file_id))
                 , xmlelement("file_type",    l_file_type)
                 , xmlelement("inst_id",      i_inst_id)
                 , xmlagg(
                       xmlelement(
                           "account"
                         , xmlattributes(g.account_id as "account_id")
                         , xmlelement("inst_id",         min(g.inst_id))
                         , xmlelement("agent_id",        min(g.agent_id))
                         , xmlelement("agent_number",    min(g.agent_number))
                         , xmlelement("account_number",  min(g.account_number))
                         , xmlforest(
                               min(g.account_type) as "account_type"
                             , min(g.status) as "account_status"
                             , min(g.status_reason) as "account_status"
                           )
                         , xmlelement("currency",        min(g.account_currency))
                         , xmlelement(
                               "customer"
                             , xmlattributes(min(g.customer_id) as "customer_id")
                             , xmlelement("customer_number",  min(g.customer_number))
                           )
                         , xmlelement(
                               "contract"
                             , xmlattributes(min(g.contract_id) as "contract_id")
                             , xmlelement("contract_number",  min(g.contract_number))
                           )
                         , xmlagg(
                               xmlelement(
                                   "balance"
                                 , xmlattributes(g.balance_id as "balance_id")
                                 , xmlelement("balance_type",       g.balance_type)
                                 , xmlelement("balance_currency",   g.balance_currency)
                                 , xmlelement("balance_status",     g.balance_status)
                                 , xmlforest(
                                       to_date(g.balance_open_date, com_api_const_pkg.XML_DATE_FORMAT) as "balance_open_date"
                                     , to_date(g.balance_close_date, com_api_const_pkg.XML_DATE_FORMAT) as "balance_close_date"
                                   )
                               )
                           )
                       )
                   )
               ).getclobval()
             , count(1)
       from (
               select a.id as account_id
                    , a.currency account_currency
                    , a.account_type
                    , a.status
                    , evt_api_status_pkg.get_status_reason(
                          i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                        , i_object_id     => a.id
                        , i_raise_error   => com_api_const_pkg.FALSE
                      ) as status_reason
                    , a.account_number
                    , a.currency
                    , a.inst_id
                    , a.split_hash
                    , a.agent_id
                    , ag.agent_number
                    , a.customer_id
                    , c.customer_number
                    , a.contract_id
                    , ct.contract_number
                    , ab.id as balance_id
                    , ab.balance_type
                    , ab.status as balance_status
                    , ab.currency as balance_currency 
                    , ab.open_date as balance_open_date
                    , ab.close_date as balance_close_date
                 from acc_account a
                    , acc_balance ab
                    , ost_agent ag
                    , prd_customer c
                    , prd_contract ct
                where a.id in (select column_value from table(cast(l_account_id_tab as num_tab_tpt)))
                  and ab.split_hash  = a.split_hash
                  and ab.account_id  = a.id
                  and a.agent_id     = ag.id
                  and a.customer_id  = c.id
                  and a.contract_id  = ct.id
            ) g
     group by g.account_id
            , g.split_hash
            , g.inst_id;

    -- Generate XML file
    procedure generate_xml is
        l_fetched_count                com_api_type_pkg.t_count    := 0;
        l_params                       com_api_type_pkg.t_param_tab;
        CRLF                  constant com_api_type_pkg.t_name := chr(13) || chr(10);
    begin
        if l_account_id_tab.count > 0 then
            trc_log_pkg.debug('Creating a new XML file...');
            
            -- Save estimated count of cards in the current iteration
            l_estimated_count := l_estimated_count + l_account_id_tab.count;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
              , i_measure         => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
            );
            trc_log_pkg.debug('Estimated count of cards is [' || l_estimated_count || ']');
            
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
        
            open  main_cur_xml;
            fetch main_cur_xml into l_file, l_fetched_count;
            close main_cur_xml;

            l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

            prc_api_file_pkg.put_file(
                i_sess_file_id        => l_session_file_id
              , i_clob_content        => l_file
              , i_add_to              => com_api_type_pkg.FALSE
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

begin
    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    l_full_export     := nvl(i_full_export, com_api_type_pkg.FALSE);
    l_sysdate         := com_api_sttl_day_pkg.get_sysdate;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX
                     || ' START: file_type [#1], thread_number [' || get_thread_number()
                     || '], l_container_id [' || l_container_id
                     || '], l_full_export [' || l_full_export
                     || '], i_lang [' || i_lang
                     || '], l_sysdate [' || to_char(l_sysdate, 'dd.mm.yyyy hh24:mi:ss')
                     || ']'
      , i_env_param1 => l_file_type
    );
    
    prc_api_stat_pkg.log_start;
    l_total_count := 0;

    if l_full_export = com_api_type_pkg.TRUE then

        select count(1)
          into l_estimate_count
          from acc_account a
         where a.split_hash in (select split_hash from com_api_split_map_vw)
           and (a.inst_id   = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST);

        trc_log_pkg.debug('Estimate count = [' || l_estimate_count || ']');

        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_estimate_count
          , i_measure         => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
        );

        open all_account_cur;
        loop
            savepoint sp_dwh_account_export;

            fetch all_account_cur bulk collect into
                  l_account_id_tab
            limit l_bulk_limit;

            -- Generate XML file
            generate_xml;

            exit when all_account_cur%notfound;
        end loop;
        close all_account_cur;
    else -- incremental export
        select count(distinct account_id) as cnt
          into l_estimate_count
          from (
              select a.id as account_id
                from evt_event_object o
                   , acc_account a
               where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_DWH_PRC_ACC_EXPORT_PKG.PROCESS'
                 and o.split_hash    in (select split_hash from com_api_split_map_vw)
                 and o.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                 and o.eff_date      <= l_sysdate
                 and (o.inst_id       = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                 and a.id             = o.object_id
                 and a.split_hash     = o.split_hash
                 and a.inst_id        = o.inst_id
             union all
              select a.id
                from evt_event_object o
                   , acc_entry ae
                   , acc_account a
               where decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_DWH_PRC_ACC_EXPORT_PKG.PROCESS'
                 and o.split_hash    in (select split_hash from com_api_split_map_vw)
                 and o.entity_type    = 'ENTTENTR'
                 and o.eff_date      <= l_sysdate
                 and (o.inst_id       = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                 and ae.id            = o.object_id
                 and ae.split_hash    = o.split_hash
                 and a.id             = ae.account_id
                 and a.split_hash     = ae.split_hash
                 and a.inst_id        = o.inst_id
        );

        trc_log_pkg.debug('Estimate count = [' || l_estimate_count || ']');

        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_estimate_count
          , i_measure         => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
        );

        if l_estimate_count > 0 then
            open evt_object_cur;
            loop
                savepoint sp_dwh_account_export;
                    
                fetch evt_object_cur bulk collect into
                      l_event_tab
                    , l_incr_account_id_tab
                limit l_bulk_limit;

                for i in 1 .. l_incr_account_id_tab.count loop
                    if l_event_tab(i) is not null then
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);
                    end if;
                    
                    -- Decrease account count and remove the last account id from previous iteration
                    if (l_incr_account_id_tab(i) != l_account_id or l_account_id is null)
                       and l_incr_account_id_tab(i) is not null
                    then
                        l_account_id_tab.extend;
                        l_account_id_tab(l_account_id_tab.count) := l_incr_account_id_tab(i);

                        if i = l_incr_account_id_tab.count then
                            trc_log_pkg.debug('full package. i = ' || i);
                            -- Generate XML file for current portion of the "l_bulk_limit" records
                            generate_xml;

                            evt_api_event_pkg.process_event_object(
                                i_event_object_id_tab => l_incr_event_tab
                            );

                            -- Save last element of the array on a current iteration to use it for the next one
                            l_account_id := l_incr_account_id_tab(i);
                            trc_log_pkg.debug('last account after generating xml l_account_id = ' || l_account_id);
                            l_account_id_tab.delete;
                            l_incr_event_tab.delete;
                        end if;
                    end if;
                end loop;
                
                -- Generate XML file for last portion of records
                generate_xml;

                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab => l_incr_event_tab
                );

                trc_log_pkg.debug('events were processed, cnt = ' || l_event_tab.count);

                exit when evt_object_cur%notfound;
            end loop;

            close evt_object_cur;
        end if;  -- l_estimate_count > 0
    end if;      -- incremental export

    prc_api_stat_pkg.log_end(
        i_processed_total  => l_total_count
      , i_excepted_total   => 0
      , i_rejected_total   => 0
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(LOG_PREFIX || ' END: l_total_count [' || l_total_count || ']');

exception
    when others then
        rollback to sp_dwh_account_export;
        
        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
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

procedure process(
    i_dwh_version           in     com_api_type_pkg.t_name
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_full_export           in     com_api_type_pkg.t_boolean        default null
  , i_lang                  in     com_api_type_pkg.t_dict_value     default null
  , i_count                 in     com_api_type_pkg.t_medium_id      default null
) is
begin
    trc_log_pkg.debug(
        i_text        => 'i_dwh_version=' || i_dwh_version
    );
    
    if i_dwh_version between '1.0' and '1.2' then
        process_1_0(
            i_inst_id     => i_inst_id
          , i_full_export => i_full_export
          , i_lang        => i_lang
          , i_count       => i_count
        );
    elsif i_dwh_version = '1.3' then
        process_1_3(
            i_inst_id     => i_inst_id
          , i_full_export => i_full_export
          , i_lang        => i_lang
          , i_count       => i_count
        );
    else
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'VERSION_IS_NOT_SUPPORTED'
          , i_env_param1  => i_dwh_version
        );
    end if;
end;

end;
/
