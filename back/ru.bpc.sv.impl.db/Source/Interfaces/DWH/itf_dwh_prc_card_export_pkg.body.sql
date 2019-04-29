create or replace package body itf_dwh_prc_card_export_pkg as

procedure export_cards_status_1_0(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_count               in     com_api_type_pkg.t_medium_id     default null
  , i_masking_card        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := 'ITF_DWH_PRC_CARD_EXPORT_PKG.EXPORT_CARDS_STATUS';

    -- Defult bulk size for <card_info> blocks per a file if <i_count> parameter is not specified
    DEFAULT_BULK_LIMIT      constant com_api_type_pkg.t_count := 2000;
    l_bulk_limit            com_api_type_pkg.t_count          := nvl(i_count, DEFAULT_BULK_LIMIT);
    l_subscriber_name       com_api_type_pkg.t_name           := DEFAULT_PROCEDURE_NAME;
    l_full_export           com_api_type_pkg.t_boolean        := nvl(i_full_export, com_api_type_pkg.FALSE);
    l_file                  clob;
    l_total_count           com_api_type_pkg.t_count          := 0;
    l_counter               com_api_type_pkg.t_count          := 0;

    l_event_tab             com_api_type_pkg.t_number_tab;
    l_incr_event_tab        com_api_type_pkg.t_number_tab;
    l_instance_id_tab       num_tab_tpt                       := num_tab_tpt();
    l_incr_instance_id_tab  num_tab_tpt                       := num_tab_tpt();
    l_instance_id           com_api_type_pkg.t_medium_id;
    l_estimated_count       com_api_type_pkg.t_count          := 0;
    l_session_file_id       com_api_type_pkg.t_long_id;
    l_file_type             com_api_type_pkg.t_dict_value;
    l_is_token_enabled      com_api_type_pkg.t_boolean;

    cursor cur_xml is
        with ids as (
            select column_value from table(cast(l_instance_id_tab as num_tab_tpt))
        )
        select xmlelement(
                   "card_statuses"
                 , xmlattributes('http://sv.bpc.in/SVXP/Card_statuses' as "xmlns")
                 , xmlelement("file_id"  , to_char(l_session_file_id))
                 , xmlelement("file_type", l_file_type)
                 , xmlelement("inst_id",   i_inst_id)
                 , xmlagg(
                       xmlelement(
                           "card_status"
                         , xmlattributes(ci.card_id as "card_id")
                         , xmlelement(
                               "card_number"
                             , case when nvl(i_masking_card, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE
                                   then
                                       coalesce(
                                           crd.card_mask
                                         , iss_api_card_pkg.get_card_mask(i_card_number => crd.card_number)
                                       )
                                   when l_is_token_enabled = com_api_const_pkg.FALSE then
                                       crd.card_number
                                   else
                                       iss_api_token_pkg.decode_card_number(i_card_number => crd.card_number)
                               end
                           )
                         , xmlforest(
                               ci.id            as "instance_id"
                             , ci.seq_number    as "sequential_number"
                             , ci.status        as "card_status"
                             , ci.state         as "card_state"
                             , to_char(ci.expir_date, com_api_const_pkg.XML_DATE_FORMAT)   as "expiration_date"
                           )
                         , (select xmlforest(
                                       max(initiator) keep (dense_rank first order by change_date desc, id desc) as "initiatior"
                                     , max(event_type) keep (dense_rank first order by change_date desc, id desc) as "status_reason"
                                   )
                              from evt_status_log s
                             where s.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                               and object_id = ci.id
                           )
                       )
                   )
               ).getclobval()  --xml root element
             , count(*)
        from iss_card_vw crd
           , iss_card_instance ci
        where ci.id in (select column_value from ids)
          and ci.split_hash in (select split_hash from com_api_split_map_vw)
          and crd.id              = ci.card_id
          and crd.split_hash      = ci.split_hash;

    cur_objects             sys_refcursor;

    l_container_id          com_api_type_pkg.t_long_id;
    
    -- Generate XML file
    procedure generate_xml is
        l_fetched_count                com_api_type_pkg.t_count    := 0;
        l_params                       com_api_type_pkg.t_param_tab;
        CRLF                  constant com_api_type_pkg.t_name := chr(13) || chr(10);
    begin
        if l_instance_id_tab.count > 0 then
            trc_log_pkg.debug('Creating a new XML file...');
            
            -- Save estimated count of cards in the current iteration
            l_estimated_count := l_estimated_count + l_instance_id_tab.count;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
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

            -- For every processing batch of card instances we fetch data and save it in a separate file
            open cur_xml;
            fetch cur_xml into l_file, l_fetched_count;
            close cur_xml;
            
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

    -- Function returns a reference for a cursor with card instances being processed.
    -- In case of incremental unloading it also returns event objects' identifiers.
    procedure open_cur_objects(
        o_cursor               out sys_refcursor
      , i_full_export       in     com_api_type_pkg.t_boolean
      , i_inst_id           in     com_api_type_pkg.t_inst_id
      , i_subscriber_name   in     com_api_type_pkg.t_name
    ) is
        l_sysdate   date; 
    begin
        trc_log_pkg.debug('Opening a cursor for all card instances those are processed...');

        l_sysdate   := com_api_sttl_day_pkg.get_sysdate;
        if i_full_export = com_api_type_pkg.TRUE then
            -- Get current instances for all available cards
            open o_cursor for
                select max(ci.id)
                  from iss_card_instance ci
                 where ci.split_hash in (select split_hash from com_api_split_map_vw)
                   and (ci.inst_id  = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
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
                         where decode(a.status, 'EVST0001', a.procedure_name, null) = i_subscriber_name
                           and a.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                           and a.object_id   = ci.card_id
                           and a.split_hash  = ci.split_hash
                           and a.eff_date   <= l_sysdate
                           and ci.split_hash in (select split_hash from com_api_split_map_vw)
                           and (ci.inst_id   = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                           and e.id          = a.event_id
                        union all
                        select a.id  as event_object_id
                             , ci.id as card_instance_id
                             , ci.card_id
                          from evt_event_object a
                             , iss_card_instance ci
                             , evt_event e
                         where decode(a.status, 'EVST0001', a.procedure_name, null) = i_subscriber_name
                           and a.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                           and a.object_id   = ci.id
                           and a.split_hash  = ci.split_hash
                           and a.eff_date   <= l_sysdate
                           and ci.split_hash in (select split_hash from com_api_split_map_vw)
                           and (ci.inst_id   = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                           and e.id          = a.event_id
                       ) v
              group by v.card_id
                     , v.event_object_id
              order by 2 asc -- card_instance_id
            ;
        end if;
        trc_log_pkg.debug('Cursor was opened...');
    end;
begin
    trc_log_pkg.debug(
        i_text       => 'export_cards_status_1_0: START with l_full_export [#1], i_inst_id [#2], i_count [#3]'
      , i_env_param1 => l_full_export
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_count
    );

    l_container_id        := prc_api_session_pkg.get_container_id;
    l_is_token_enabled    := iss_api_token_pkg.is_token_enabled;
    
    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    trc_log_pkg.debug(
        i_text       => 'i_masking_card [#1] l_container_id [#2]'
      , i_env_param1 => i_masking_card
      , i_env_param2 => l_container_id
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
            savepoint sp_dwh_card_num_export;

            if l_full_export = com_api_type_pkg.TRUE then
                fetch cur_objects
                 bulk collect into
                      l_instance_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                -- Generate XML file
                generate_xml;

            else  -- l_full_export = com_api_type_pkg.FALSE
                fetch cur_objects
                 bulk collect into
                      l_event_tab
                    , l_incr_instance_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                for i in 1 .. l_incr_instance_id_tab.count loop
                    -- Decrease card instance count and remove the last card instance id from previous iteration
                    if (l_incr_instance_id_tab(i) != l_instance_id or l_instance_id is null)
                       and l_incr_instance_id_tab(i) is not null
                    then
                        l_instance_id := l_incr_instance_id_tab(i);
                        
                        l_instance_id_tab.extend;
                        l_instance_id_tab(l_instance_id_tab.count)   := l_incr_instance_id_tab(i);
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);

                        if i = l_incr_instance_id_tab.count then
                            -- Generate XML file for current portion of the "l_bulk_limit" records
                            generate_xml;

                            evt_api_event_pkg.process_event_object(
                                i_event_object_id_tab => l_incr_event_tab
                            );

                            -- Save last element of the array on a current iteration to use it for the next one
                            l_instance_id_tab.delete;
                            l_incr_event_tab.delete;
                        end if;
                    else  -- Select event for last account id from previous iteration
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
                rollback to sp_dwh_card_num_export;
                raise;
        end;
    end loop;
    close cur_objects;

    prc_api_stat_pkg.log_end(
        i_excepted_total  => 0
      , i_processed_total => l_total_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug('export_cards_status_1_0: FINISH');
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

procedure export_cards_status_1_3(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_count               in     com_api_type_pkg.t_medium_id     default null
  , i_masking_card        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := 'ITF_DWH_PRC_CARD_EXPORT_PKG.EXPORT_CARDS_STATUS';

    -- Defult bulk size for <card_info> blocks per a file if <i_count> parameter is not specified
    DEFAULT_BULK_LIMIT      constant com_api_type_pkg.t_count := 2000;
    l_bulk_limit            com_api_type_pkg.t_count          := nvl(i_count, DEFAULT_BULK_LIMIT);
    l_subscriber_name       com_api_type_pkg.t_name           := DEFAULT_PROCEDURE_NAME;
    l_full_export           com_api_type_pkg.t_boolean        := nvl(i_full_export, com_api_type_pkg.FALSE);
    l_file                  clob;
    l_total_count           com_api_type_pkg.t_count          := 0;
    l_counter               com_api_type_pkg.t_count          := 0;

    l_event_tab             com_api_type_pkg.t_number_tab;
    l_incr_event_tab        com_api_type_pkg.t_number_tab;
    l_instance_id_tab       num_tab_tpt                       := num_tab_tpt();
    l_incr_instance_id_tab  num_tab_tpt                       := num_tab_tpt();
    l_instance_id           com_api_type_pkg.t_medium_id;
    l_estimated_count       com_api_type_pkg.t_count          := 0;
    l_session_file_id       com_api_type_pkg.t_long_id;
    l_file_type             com_api_type_pkg.t_dict_value;
    l_is_token_enabled      com_api_type_pkg.t_boolean;

    cursor cur_xml is
        with ids as (
            select column_value from table(cast(l_instance_id_tab as num_tab_tpt))
        )
        select xmlelement(
                   "card_statuses"
                 , xmlattributes('http://sv.bpc.in/SVXP/Card_statuses' as "xmlns")
                 , xmlelement("file_id"  , to_char(l_session_file_id))
                 , xmlelement("file_type", l_file_type)
                 , xmlelement("inst_id",   i_inst_id)
                 , xmlagg(
                       xmlelement(
                           "card_status"
                         , xmlattributes(ci.card_id as "card_id")
                         , xmlelement(
                               "card_number"
                             , case when nvl(i_masking_card, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE
                                   then
                                       coalesce(
                                           crd.card_mask
                                         , iss_api_card_pkg.get_card_mask(i_card_number => crd.card_number)
                                       )
                                   when l_is_token_enabled = com_api_const_pkg.FALSE then
                                       crd.card_number
                                   else
                                       iss_api_token_pkg.decode_card_number(i_card_number => crd.card_number)
                               end
                           )
                         , xmlforest(
                               ci.id            as "instance_id"
                             , ci.seq_number    as "sequential_number"
                             , ci.status        as "card_status"
                             , evt_api_status_pkg.get_status_reason(
                                   i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                                 , i_object_id     => ci.id
                                 , i_raise_error   => com_api_const_pkg.FALSE
                               )                             as "status_reason"
                             , ci.state         as "card_state"
                             , to_char(ci.expir_date, com_api_const_pkg.XML_DATE_FORMAT)   as "expiration_date"
                           )
                         , (select xmlforest(
                                       max(initiator) keep (dense_rank first order by change_date desc, id desc) as "initiatior"
                                     , max(event_type) keep (dense_rank first order by change_date desc, id desc) as "status_reason"
                                   )
                              from evt_status_log s
                             where s.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                               and object_id = ci.id
                           )
                       )
                   )
               ).getclobval()  --xml root element
             , count(*)
        from iss_card_vw crd
           , iss_card_instance ci
        where ci.id in (select column_value from ids)
          and ci.split_hash in (select split_hash from com_api_split_map_vw)
          and crd.id              = ci.card_id
          and crd.split_hash      = ci.split_hash;

    cur_objects             sys_refcursor;

    l_container_id          com_api_type_pkg.t_long_id;
    
    -- Generate XML file
    procedure generate_xml is
        l_fetched_count                com_api_type_pkg.t_count    := 0;
        l_params                       com_api_type_pkg.t_param_tab;
        CRLF                  constant com_api_type_pkg.t_name := chr(13) || chr(10);
    begin
        if l_instance_id_tab.count > 0 then
            trc_log_pkg.debug('Creating a new XML file...');
            
            -- Save estimated count of cards in the current iteration
            l_estimated_count := l_estimated_count + l_instance_id_tab.count;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
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

            -- For every processing batch of card instances we fetch data and save it in a separate file
            open cur_xml;
            fetch cur_xml into l_file, l_fetched_count;
            close cur_xml;
            
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

    -- Function returns a reference for a cursor with card instances being processed.
    -- In case of incremental unloading it also returns event objects' identifiers.
    procedure open_cur_objects(
        o_cursor               out sys_refcursor
      , i_full_export       in     com_api_type_pkg.t_boolean
      , i_inst_id           in     com_api_type_pkg.t_inst_id
      , i_subscriber_name   in     com_api_type_pkg.t_name
    ) is
        l_sysdate   date; 
    begin
        trc_log_pkg.debug('Opening a cursor for all card instances those are processed...');

        l_sysdate   := com_api_sttl_day_pkg.get_sysdate;
        if i_full_export = com_api_type_pkg.TRUE then
            -- Get current instances for all available cards
            open o_cursor for
                select max(ci.id)
                  from iss_card_instance ci
                 where ci.split_hash in (select split_hash from com_api_split_map_vw)
                   and (ci.inst_id  = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
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
                         where decode(a.status, 'EVST0001', a.procedure_name, null) = i_subscriber_name
                           and a.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                           and a.object_id   = ci.card_id
                           and a.split_hash  = ci.split_hash
                           and a.eff_date   <= l_sysdate
                           and ci.split_hash in (select split_hash from com_api_split_map_vw)
                           and (ci.inst_id   = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                           and e.id          = a.event_id
                        union all
                        select a.id  as event_object_id
                             , ci.id as card_instance_id
                             , ci.card_id
                          from evt_event_object a
                             , iss_card_instance ci
                             , evt_event e
                         where decode(a.status, 'EVST0001', a.procedure_name, null) = i_subscriber_name
                           and a.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                           and a.object_id   = ci.id
                           and a.split_hash  = ci.split_hash
                           and a.eff_date   <= l_sysdate
                           and ci.split_hash in (select split_hash from com_api_split_map_vw)
                           and (ci.inst_id   = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                           and e.id          = a.event_id
                       ) v
              group by v.card_id
                     , v.event_object_id
              order by 2 asc -- card_instance_id
            ;
        end if;
        trc_log_pkg.debug('Cursor was opened...');
    end;
begin
    trc_log_pkg.debug(
        i_text       => 'export_cards_status_1_0: START with l_full_export [#1], i_inst_id [#2], i_count [#3]'
      , i_env_param1 => l_full_export
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_count
    );

    l_container_id        := prc_api_session_pkg.get_container_id;
    l_is_token_enabled    := iss_api_token_pkg.is_token_enabled;
    
    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    trc_log_pkg.debug(
        i_text       => 'i_masking_card [#1] l_container_id [#2]'
      , i_env_param1 => i_masking_card
      , i_env_param2 => l_container_id
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
            savepoint sp_dwh_card_num_export;

            if l_full_export = com_api_type_pkg.TRUE then
                fetch cur_objects
                 bulk collect into
                      l_instance_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                -- Generate XML file
                generate_xml;

            else  -- l_full_export = com_api_type_pkg.FALSE
                fetch cur_objects
                 bulk collect into
                      l_event_tab
                    , l_incr_instance_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                for i in 1 .. l_incr_instance_id_tab.count loop
                    -- Decrease card instance count and remove the last card instance id from previous iteration
                    if (l_incr_instance_id_tab(i) != l_instance_id or l_instance_id is null)
                       and l_incr_instance_id_tab(i) is not null
                    then
                        l_instance_id := l_incr_instance_id_tab(i);
                        
                        l_instance_id_tab.extend;
                        l_instance_id_tab(l_instance_id_tab.count)   := l_incr_instance_id_tab(i);
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);

                        if i = l_incr_instance_id_tab.count then
                            -- Generate XML file for current portion of the "l_bulk_limit" records
                            generate_xml;

                            evt_api_event_pkg.process_event_object(
                                i_event_object_id_tab => l_incr_event_tab
                            );

                            -- Save last element of the array on a current iteration to use it for the next one
                            l_instance_id_tab.delete;
                            l_incr_event_tab.delete;
                        end if;
                    else  -- Select event for last account id from previous iteration
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
                rollback to sp_dwh_card_num_export;
                raise;
        end;
    end loop;
    close cur_objects;

    prc_api_stat_pkg.log_end(
        i_excepted_total  => 0
      , i_processed_total => l_total_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug('export_cards_status_1_0: FINISH');
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

procedure export_cards_numbers_1_0(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_count               in     com_api_type_pkg.t_medium_id     default null
  , i_masking_card        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := 'ITF_DWH_PRC_CARD_EXPORT_PKG.EXPORT_CARDS_NUMBERS';

    -- Defult bulk size for <card_info> blocks per a file if <i_count> parameter is not specified
    DEFAULT_BULK_LIMIT      constant com_api_type_pkg.t_count := 2000;
    l_bulk_limit            com_api_type_pkg.t_count          := nvl(i_count, DEFAULT_BULK_LIMIT);
    l_subscriber_name       com_api_type_pkg.t_name           := DEFAULT_PROCEDURE_NAME;
    l_full_export           com_api_type_pkg.t_boolean        := nvl(i_full_export, com_api_type_pkg.FALSE);
    l_file                  clob;
    l_total_count           com_api_type_pkg.t_count          := 0;
    l_counter               com_api_type_pkg.t_count          := 0;

    l_event_tab             com_api_type_pkg.t_number_tab;
    l_incr_event_tab        com_api_type_pkg.t_number_tab;
    l_instance_id_tab       num_tab_tpt                       := num_tab_tpt();
    l_incr_instance_id_tab  num_tab_tpt                       := num_tab_tpt();
    l_instance_id           com_api_type_pkg.t_medium_id;
    l_estimated_count       com_api_type_pkg.t_count          := 0;
    l_session_file_id       com_api_type_pkg.t_long_id;

    l_lang                  com_api_type_pkg.t_dict_value;
    l_sysdate               date;
    l_file_type             com_api_type_pkg.t_dict_value;
    l_is_token_enabled      com_api_type_pkg.t_boolean;

    cursor cur_xml is
        with ids as (
            select column_value from table(cast(l_instance_id_tab as num_tab_tpt))
        )
        select xmlelement(
                   "cards"
                 , xmlattributes('http://sv.bpc.in/SVXP/Cards' as "xmlns")
                 , xmlelement("file_id"  , to_char(l_session_file_id))
                 , xmlelement("file_type", l_file_type)
                 , xmlelement("inst_id", i_inst_id)
                 , xmlagg(
                       xmlelement(
                           "card"
                         , xmlattributes(ci.id as "card_id")
                         , xmlelement("inst_id", crd.inst_id)
                         , xmlelement(
                               "card_number"
                             , case when nvl(i_masking_card, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE
                                   then
                                       coalesce(
                                           crd.card_mask
                                         , iss_api_card_pkg.get_card_mask(i_card_number => crd.card_number)
                                       )
                                   when l_is_token_enabled = com_api_const_pkg.FALSE then
                                       crd.card_number
                                   else
                                       iss_api_token_pkg.decode_card_number(i_card_number => crd.card_number)
                               end
                           )
                         , xmlforest(
                               crd.card_mask    as "card_mask"
                             , crd.card_type_id as "card_type"
                           )
                         , xmlelement("country",    crd.country)
                         , xmlforest(crd.category   as "category")
                         , xmlelement("reg_date",   to_char(crd.reg_date, com_api_const_pkg.XML_DATE_FORMAT))
                         , xmlelement(
                               "customer"
                             , xmlattributes(crd.customer_id as "customer_id")
                             , xmlelement("customer_number",  m.customer_number)
                           )
                         , xmlelement(
                               "contract"
                             , xmlattributes(crd.contract_id as "contract_id")
                             , xmlelement("contract_number",  ct.contract_number)
                           )
                         , xmlelement(
                               "cardholder"
                             , xmlattributes(crd.cardholder_id as "cardholder_id")
                             , xmlforest(
                                   h.cardholder_number       as "cardholder_number"
                                 , ci.cardholder_name        as "cardholder_name"
                               )
                             , (select xmlagg(
                                           xmlelement(
                                               "person"
                                             , xmlattributes(p.id as "person_id")
                                             , xmlforest(p.title  as "person_title")
                                             , xmlelement(
                                                   "person_name"
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
                                             , (select xmlagg(
                                                           xmlelement(
                                                              "identity_card"
                                                             , xmlelement("id_type",  io.id_type)
                                                             , xmlforest(io.id_series  as "id_series")
                                                             , xmlelement("id_number",  io.id_number)
                                                             , xmlforest(
                                                                   io.id_issuer      as "id_issuer"
                                                                 , to_char(io.id_issue_date, com_api_const_pkg.XML_DATE_FORMAT)  as "id_issue_date"
                                                                 , to_char(io.id_expire_date, com_api_const_pkg.XML_DATE_FORMAT)  as "id_expire_date"
                                                               )
                                                           )
                                                       )
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
                                   and (p.lang = i_lang  or i_lang is null)
                               )
                             , (select xmlagg(
                                           xmlelement(
                                               "address"
                                             , xmlattributes(a.id as "address_id")
                                             , xmlelement("address_type", a.address_type)
                                             , xmlelement("country", a.country)
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
                                                   and (aa.lang = i_lang or i_lang is null)
                                               )
                                             , xmlforest(
                                                   a.house       as "house"
                                                 , a.apartment   as "apartment"
                                                 , a.postal_code as "postal_code"
                                                 , a.place_code  as "place_code"
                                                 , a.region_code as "region_code"
                                               )
                                           ) --xmlelement
                                       )
                                  from (
                                      select a.id
                                           , o.address_type
                                           , a.country
                                           , a.house
                                           , a.apartment
                                           , a.postal_code
                                           , a.place_code
                                           , a.region_code
                                           , o.object_id
                                           , o.entity_type
                                           , row_number() over (partition by o.object_id, o.entity_type, o.address_type order by a.id desc) rn
                                        from com_address_object o
                                           , com_address a
                                       where o.entity_type in (iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER, iss_api_const_pkg.ENTITY_TYPE_CUSTOMER)
                                         and a.id          = o.address_id
                                       ) a
                                 where (a.object_id, a.entity_type) in ((crd.cardholder_id, iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER)
                                                                      , (crd.customer_id,   iss_api_const_pkg.ENTITY_TYPE_CUSTOMER))
                                   and rn = 1
                               )
                           -- Cardholder contact data
                           ,  (select xmlagg(
                                          xmlelement(
                                              "contact"
                                            , xmlattributes(x.id as "contact_id")
                                            , xmlelement("contact_type",   y.contact_type)
                                            , xmlelement("preferred_lang", x.preferred_lang)
                                            , xmlelement("job_title", x.job_title)
                                            , (select xmlelement(
                                                          "person"
                                                        , xmlattributes(to_char(z.id) as "person_id")
                                                        , xmlelement("person_title", z.title)
                                                        , xmlelement(
                                                              "person_name"
                                                           ,  xmlattributes(z.lang as "language")
                                                           ,  xmlelement("surname",     z.surname)
                                                           ,  xmlelement("first_name",  z.first_name)
                                                           ,  case when z.second_name is not null then
                                                                  xmlelement("second_name", z.second_name)
                                                              end
                                                          )
                                                        , xmlelement("suffix", z.suffix)
                                                        , xmlelement("birthday", z.birthday)
                                                        , xmlelement("place_of_birth", z.place_of_birth)
                                                        , xmlelement("gender", z.gender)
                                                        , (select xmlagg(
                                                                      xmlelement(
                                                                         "identity_card"
                                                                        , xmlelement("id_type",  o.id_type)
                                                                        , xmlforest(
                                                                              o.id_series      as "id_series"
                                                                          )
                                                                        , xmlelement("id_number",  o.id_number)
                                                                        , xmlforest(
                                                                              o.id_issuer      as "id_issuer"
                                                                            , to_char(o.id_issue_date, com_api_const_pkg.XML_DATE_FORMAT)  as "id_issue_date"
                                                                            , to_char(o.id_expire_date, com_api_const_pkg.XML_DATE_FORMAT)  as "id_expire_date"
                                                                          )
                                                                      )
                                                                  )
                                                             from com_id_object o 
                                                            where o.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
                                                              and o.object_id = z.id
                                                          )
                                                          
                                                      )
                                                 from com_person z
                                                where z.id = x.person_id
                                              )
                                            , (select xmlagg(
                                                          xmlelement(
                                                              "contact_data"
                                                            , xmlelement("commun_method"  , d.commun_method)
                                                            , xmlelement("commun_address" , d.commun_address)
                                                            , xmlelement("start_date"     , to_char(d.start_date, com_api_const_pkg.XML_DATE_FORMAT))
                                                            , xmlelement("end_date"       , to_char(d.end_date, com_api_const_pkg.XML_DATE_FORMAT))
                                                          )
                                                      )
                                                from com_contact_data d
                                               where d.contact_id  = y.contact_id
                                                 and (d.end_date is null or d.end_date > l_sysdate)
                                              )
                                          )
                                      ) 
                                 from com_contact x
                                    , com_contact_object y
                                where x.id          = y.contact_id
                                  and y.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                  and y.object_id   = crd.cardholder_id
                              )
                           ) --cardholder
                         , xmlelement(
                               "card_instance"
                             , xmlattributes(ci.id as "instance_id")
                             , xmlforest(
                                   ci.inst_id       as "inst_id"
                                 , ci.agent_id      as "agent_id"
                                 , a.agent_number   as "agent_number"
                                 , ci.seq_number    as "sequential_number"
                                 , ci.status        as "card_status"
                                 , ci.state         as "card_state"
                                 , to_char(ci.iss_date, com_api_const_pkg.XML_DATE_FORMAT)   as "iss_date"
                                 , to_char(ci.start_date, com_api_const_pkg.XML_DATE_FORMAT) as "start_date"
                                 , to_char(ci.expir_date, com_api_const_pkg.XML_DATE_FORMAT) as "expiration_date"
                                 , ci.reissue_reason as "reissue_reason"
                                   -- pin update flag
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
                                   end               as "pin_update_flag"
                                 , ci.pin_request    as "pin_request"
                                 , ci.perso_priority as "perso_priority"
                                 , ci.embossing_request  as "embossing_request"
                                 , ci.pin_mailer_request as "pin_mailer_request"
                                 , ci.preceding_card_instance_id as "preceding_instance_id"
                               )
                           ) -- card_instance
                           
                         , case when ci.state != iss_api_const_pkg.CARD_STATE_CLOSED then (
                               select xmlagg(
                                          xmlelement(
                                              "account"
                                            , xmlattributes(ac.id as "account_id")
                                            , xmlforest(
                                                  ac.account_number   as "account_number"
                                                , ac.account_type     as "account_type"
                                                , ac.currency         as "currency"
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
                                where ao.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
                                  and ao.object_id       = crd.id
                                  and ao.split_hash      = crd.split_hash
                                  and ac.id              = ao.account_id
                                  and ac.split_hash      = ao.split_hash
                                  and (ao.procedure_name = 'ITF_DWH_PRC_CARD_EXPORT_PKG.EXPORT_CARDS_NUMBERS' or procedure_name is null )
                                  and ao.account_rownum  = 1
                               ) --account
                           end
                       )
                   )  --xmlagg
               ).getclobval()  --xml root element
             , count(*)
        from iss_card_vw crd
           , prd_contract ct
           , prd_product pr
           , prd_customer m
           , iss_cardholder h
           , iss_card_instance ci
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
          and a.id                = ci.agent_id;

    cur_objects             sys_refcursor;

    l_container_id          com_api_type_pkg.t_long_id;

    -- Generate XML file
    procedure generate_xml is
        l_fetched_count                com_api_type_pkg.t_count    := 0;
        l_params                       com_api_type_pkg.t_param_tab;
        CRLF                  constant com_api_type_pkg.t_name := chr(13) || chr(10);
    begin
        if l_instance_id_tab.count > 0 then
            trc_log_pkg.debug('Creating a new XML file...');
            
            -- Save estimated count of cards in the current iteration
            l_estimated_count := l_estimated_count + l_instance_id_tab.count;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
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

            -- For every processing batch of card instances we fetch data and save it in a separate file
            open cur_xml;
            fetch cur_xml into l_file, l_fetched_count;
            close cur_xml;
            
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

    -- Function returns a reference for a cursor with card instances being processed.
    -- In case of incremental unloading it also returns event objects' identifiers.
    procedure open_cur_objects(
        o_cursor               out sys_refcursor
      , i_full_export       in     com_api_type_pkg.t_boolean
      , i_inst_id           in     com_api_type_pkg.t_inst_id
      , i_subscriber_name   in     com_api_type_pkg.t_name
    ) is
        l_sysdate   date; 
    begin
        trc_log_pkg.debug('Opening a cursor for all card instances those are processed...');

        l_sysdate   := com_api_sttl_day_pkg.get_sysdate;
        if i_full_export = com_api_type_pkg.TRUE then
            -- Get current instances for all available cards
            open o_cursor for
                select max(ci.id)
                  from iss_card_instance ci
                 where ci.split_hash in (select split_hash from com_api_split_map_vw)
                   and (ci.inst_id  = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
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
                         where decode(a.status, 'EVST0001', a.procedure_name, null) = i_subscriber_name
                           and a.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                           and a.object_id   = ci.card_id
                           and a.split_hash  = ci.split_hash
                           and a.eff_date   <= l_sysdate
                           and ci.split_hash in (select split_hash from com_api_split_map_vw)
                           and (ci.inst_id   = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                           and e.id          = a.event_id
                        union all
                        select a.id  as event_object_id
                             , ci.id as card_instance_id
                             , ci.card_id
                          from evt_event_object a
                             , iss_card_instance ci
                             , evt_event e
                         where decode(a.status, 'EVST0001', a.procedure_name, null) = i_subscriber_name
                           and a.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                           and a.object_id   = ci.id
                           and a.split_hash  = ci.split_hash
                           and a.eff_date   <= l_sysdate
                           and ci.split_hash in (select split_hash from com_api_split_map_vw)
                           and (ci.inst_id   = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                           and e.id          = a.event_id
                       ) v
              group by v.card_id
                     , v.event_object_id
              order by 2 asc -- card_instance_id
            ;
        end if;
        trc_log_pkg.debug('Cursor was opened...');
    end;

begin
    trc_log_pkg.debug(
        i_text       => 'export_cards_numbers_1_0: START with l_full_export [#1], i_inst_id [#4], i_count [#5]'
      , i_env_param1 => l_full_export
      , i_env_param4 => i_inst_id
      , i_env_param5 => i_count
    );

    l_sysdate   := com_api_sttl_day_pkg.get_sysdate;

    l_container_id        := prc_api_session_pkg.get_container_id;
    l_is_token_enabled  := iss_api_token_pkg.is_token_enabled;

    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    trc_log_pkg.debug(
        i_text       => 'i_masking_card [#1] l_lang [#2] l_container_id [#3]'
      , i_env_param1 => i_masking_card
      , i_env_param2 => l_lang
      , i_env_param3 => l_container_id
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
            savepoint sp_dwh_card_num_export;

            if l_full_export = com_api_type_pkg.TRUE then
                fetch cur_objects
                 bulk collect into
                      l_instance_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                -- Generate XML file
                generate_xml;

            else  -- l_full_export = com_api_type_pkg.FALSE
                fetch cur_objects
                 bulk collect into
                      l_event_tab
                    , l_incr_instance_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                for i in 1 .. l_incr_instance_id_tab.count loop
                    -- Decrease card instance count and remove the last card instance id from previous iteration
                    if (l_incr_instance_id_tab(i) != l_instance_id or l_instance_id is null)
                       and l_incr_instance_id_tab(i) is not null
                    then
                        l_instance_id := l_incr_instance_id_tab(i);
                        
                        l_instance_id_tab.extend;
                        l_instance_id_tab(l_instance_id_tab.count)   := l_incr_instance_id_tab(i);
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);

                        if i = l_incr_instance_id_tab.count then
                            -- Generate XML file for current portion of the "l_bulk_limit" records
                            generate_xml;

                            evt_api_event_pkg.process_event_object(
                                i_event_object_id_tab => l_incr_event_tab
                            );

                            -- Save last element of the array on a current iteration to use it for the next one
                            l_instance_id_tab.delete;
                            l_incr_event_tab.delete;
                        end if;
                    else  -- Select event for last account id from previous iteration
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
                rollback to sp_dwh_card_num_export;
                raise;
        end;
    end loop;
    close cur_objects;

    prc_api_stat_pkg.log_end(
        i_excepted_total  => 0
      , i_processed_total => l_total_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug('export_cards_numbers_1_0: FINISH');
exception
    when others then
        rollback to sp_dwh_card_num_export;
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

procedure export_cards_numbers_1_3(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_count               in     com_api_type_pkg.t_medium_id     default null
  , i_masking_card        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
) is
    DEFAULT_PROCEDURE_NAME  constant com_api_type_pkg.t_name  := 'ITF_DWH_PRC_CARD_EXPORT_PKG.EXPORT_CARDS_NUMBERS';

    -- Defult bulk size for <card_info> blocks per a file if <i_count> parameter is not specified
    DEFAULT_BULK_LIMIT      constant com_api_type_pkg.t_count := 2000;
    l_bulk_limit            com_api_type_pkg.t_count          := nvl(i_count, DEFAULT_BULK_LIMIT);
    l_subscriber_name       com_api_type_pkg.t_name           := DEFAULT_PROCEDURE_NAME;
    l_full_export           com_api_type_pkg.t_boolean        := nvl(i_full_export, com_api_type_pkg.FALSE);
    l_file                  clob;
    l_total_count           com_api_type_pkg.t_count          := 0;
    l_counter               com_api_type_pkg.t_count          := 0;

    l_event_tab             com_api_type_pkg.t_number_tab;
    l_incr_event_tab        com_api_type_pkg.t_number_tab;
    l_instance_id_tab       num_tab_tpt                       := num_tab_tpt();
    l_incr_instance_id_tab  num_tab_tpt                       := num_tab_tpt();
    l_instance_id           com_api_type_pkg.t_medium_id;
    l_estimated_count       com_api_type_pkg.t_count          := 0;
    l_session_file_id       com_api_type_pkg.t_long_id;

    l_lang                  com_api_type_pkg.t_dict_value;
    l_sysdate               date;
    l_file_type             com_api_type_pkg.t_dict_value;
    l_is_token_enabled      com_api_type_pkg.t_boolean;

    cursor cur_xml is
        with ids as (
            select column_value from table(cast(l_instance_id_tab as num_tab_tpt))
        )
        select xmlelement(
                   "cards"
                 , xmlattributes('http://sv.bpc.in/SVXP/Cards' as "xmlns")
                 , xmlelement("file_id"  , to_char(l_session_file_id))
                 , xmlelement("file_type", l_file_type)
                 , xmlelement("inst_id", i_inst_id)
                 , xmlagg(
                       xmlelement(
                           "card"
                         , xmlattributes(ci.id as "card_id")
                         , xmlelement("inst_id", crd.inst_id)
                         , xmlelement(
                               "card_number"
                             , case when nvl(i_masking_card, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE
                                   then
                                       coalesce(
                                           crd.card_mask
                                         , iss_api_card_pkg.get_card_mask(i_card_number => crd.card_number)
                                       )
                                   when l_is_token_enabled = com_api_const_pkg.FALSE then
                                       crd.card_number
                                   else
                                       iss_api_token_pkg.decode_card_number(i_card_number => crd.card_number)
                               end
                           )
                         , xmlforest(
                               crd.card_mask    as "card_mask"
                             , crd.card_type_id as "card_type"
                           )
                         , xmlelement("country",    crd.country)
                         , xmlforest(crd.category   as "category")
                         , xmlelement("reg_date",   to_char(crd.reg_date, com_api_const_pkg.XML_DATE_FORMAT))
                         , xmlelement(
                               "customer"
                             , xmlattributes(crd.customer_id as "customer_id")
                             , xmlelement("customer_number",  m.customer_number)
                           )
                         , xmlelement(
                               "contract"
                             , xmlattributes(crd.contract_id as "contract_id")
                             , xmlelement("contract_number",  ct.contract_number)
                           )
                         , xmlelement(
                               "cardholder"
                             , xmlattributes(crd.cardholder_id as "cardholder_id")
                             , xmlforest(
                                   h.cardholder_number       as "cardholder_number"
                                 , ci.cardholder_name        as "cardholder_name"
                               )
                             , (select xmlagg(
                                           xmlelement(
                                               "person"
                                             , xmlattributes(p.id as "person_id")
                                             , xmlforest(p.title  as "person_title")
                                             , xmlelement(
                                                   "person_name"
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
                                             , (select xmlagg(
                                                           xmlelement(
                                                              "identity_card"
                                                             , xmlelement("id_type",  io.id_type)
                                                             , xmlforest(io.id_series  as "id_series")
                                                             , xmlelement("id_number",  io.id_number)
                                                             , xmlforest(
                                                                   io.id_issuer      as "id_issuer"
                                                                 , to_char(io.id_issue_date, com_api_const_pkg.XML_DATE_FORMAT)  as "id_issue_date"
                                                                 , to_char(io.id_expire_date, com_api_const_pkg.XML_DATE_FORMAT)  as "id_expire_date"
                                                               )
                                                           )
                                                       )
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
                                   and (p.lang = i_lang  or i_lang is null)
                               )
                             , (select xmlagg(
                                           xmlelement(
                                               "address"
                                             , xmlattributes(a.id as "address_id")
                                             , xmlelement("address_type", a.address_type)
                                             , xmlelement("country", a.country)
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
                                                   and (aa.lang = i_lang or i_lang is null)
                                               )
                                             , xmlforest(
                                                   a.house       as "house"
                                                 , a.apartment   as "apartment"
                                                 , a.postal_code as "postal_code"
                                                 , a.place_code  as "place_code"
                                                 , a.region_code as "region_code"
                                               )
                                           ) --xmlelement
                                       )
                                  from (
                                      select a.id
                                           , o.address_type
                                           , a.country
                                           , a.house
                                           , a.apartment
                                           , a.postal_code
                                           , a.place_code
                                           , a.region_code
                                           , o.object_id
                                           , o.entity_type
                                           , row_number() over (partition by o.object_id, o.entity_type, o.address_type order by a.id desc) rn
                                        from com_address_object o
                                           , com_address a
                                       where o.entity_type in (iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER, iss_api_const_pkg.ENTITY_TYPE_CUSTOMER)
                                         and a.id          = o.address_id
                                       ) a
                                 where (a.object_id, a.entity_type) in ((crd.cardholder_id, iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER)
                                                                      , (crd.customer_id,   iss_api_const_pkg.ENTITY_TYPE_CUSTOMER))
                                   and rn = 1
                               )
                           -- Cardholder contact data
                           ,  (select xmlagg(
                                          xmlelement(
                                              "contact"
                                            , xmlattributes(x.id as "contact_id")
                                            , xmlelement("contact_type",   y.contact_type)
                                            , xmlelement("preferred_lang", x.preferred_lang)
                                            , xmlelement("job_title", x.job_title)
                                            , (select xmlelement(
                                                          "person"
                                                        , xmlattributes(to_char(z.id) as "person_id")
                                                        , xmlelement("person_title", z.title)
                                                        , xmlelement(
                                                              "person_name"
                                                           ,  xmlattributes(z.lang as "language")
                                                           ,  xmlelement("surname",     z.surname)
                                                           ,  xmlelement("first_name",  z.first_name)
                                                           ,  case when z.second_name is not null then
                                                                  xmlelement("second_name", z.second_name)
                                                              end
                                                          )
                                                        , xmlelement("suffix", z.suffix)
                                                        , xmlelement("birthday", z.birthday)
                                                        , xmlelement("place_of_birth", z.place_of_birth)
                                                        , xmlelement("gender", z.gender)
                                                        , (select xmlagg(
                                                                      xmlelement(
                                                                         "identity_card"
                                                                        , xmlelement("id_type",  o.id_type)
                                                                        , xmlforest(
                                                                              o.id_series      as "id_series"
                                                                          )
                                                                        , xmlelement("id_number",  o.id_number)
                                                                        , xmlforest(
                                                                              o.id_issuer      as "id_issuer"
                                                                            , to_char(o.id_issue_date, com_api_const_pkg.XML_DATE_FORMAT)  as "id_issue_date"
                                                                            , to_char(o.id_expire_date, com_api_const_pkg.XML_DATE_FORMAT)  as "id_expire_date"
                                                                          )
                                                                      )
                                                                  )
                                                             from com_id_object o 
                                                            where o.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
                                                              and o.object_id = z.id
                                                          )
                                                          
                                                      )
                                                 from com_person z
                                                where z.id = x.person_id
                                              )
                                            , (select xmlagg(
                                                          xmlelement(
                                                              "contact_data"
                                                            , xmlelement("commun_method"  , d.commun_method)
                                                            , xmlelement("commun_address" , d.commun_address)
                                                            , xmlelement("start_date"     , to_char(d.start_date, com_api_const_pkg.XML_DATE_FORMAT))
                                                            , xmlelement("end_date"       , to_char(d.end_date, com_api_const_pkg.XML_DATE_FORMAT))
                                                          )
                                                      )
                                                from com_contact_data d
                                               where d.contact_id  = y.contact_id
                                                 and (d.end_date is null or d.end_date > l_sysdate)
                                              )
                                          )
                                      ) 
                                 from com_contact x
                                    , com_contact_object y
                                where x.id          = y.contact_id
                                  and y.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                                  and y.object_id   = crd.cardholder_id
                              )
                           ) --cardholder
                         , xmlelement(
                               "card_instance"
                             , xmlattributes(ci.id as "instance_id")
                             , xmlforest(
                                   ci.inst_id       as "inst_id"
                                 , ci.agent_id      as "agent_id"
                                 , a.agent_number   as "agent_number"
                                 , ci.seq_number    as "sequential_number"
                                 , ci.status        as "card_status"
                                 , evt_api_status_pkg.get_status_reason(
                                       i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                                     , i_object_id     => ci.id
                                     , i_raise_error   => com_api_const_pkg.FALSE
                                   )                             as "status_reason"
                                 , ci.state         as "card_state"
                                 , to_char(ci.iss_date, com_api_const_pkg.XML_DATE_FORMAT)   as "iss_date"
                                 , to_char(ci.start_date, com_api_const_pkg.XML_DATE_FORMAT) as "start_date"
                                 , to_char(ci.expir_date, com_api_const_pkg.XML_DATE_FORMAT) as "expiration_date"
                                 , ci.reissue_reason as "reissue_reason"
                                   -- pin update flag
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
                                   end               as "pin_update_flag"
                                 , ci.pin_request    as "pin_request"
                                 , ci.perso_priority as "perso_priority"
                                 , ci.embossing_request  as "embossing_request"
                                 , ci.pin_mailer_request as "pin_mailer_request"
                                 , ci.preceding_card_instance_id as "preceding_instance_id"
                               )
                           ) -- card_instance
                           
                         , case when ci.state != iss_api_const_pkg.CARD_STATE_CLOSED then (
                               select xmlagg(
                                          xmlelement(
                                              "account"
                                            , xmlattributes(ac.id as "account_id")
                                            , xmlforest(
                                                  ac.account_number   as "account_number"
                                                , ac.account_type     as "account_type"
                                                , ac.currency         as "currency"
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
                                where ao.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
                                  and ao.object_id       = crd.id
                                  and ao.split_hash      = crd.split_hash
                                  and ac.id              = ao.account_id
                                  and ac.split_hash      = ao.split_hash
                                  and (ao.procedure_name = 'ITF_DWH_PRC_CARD_EXPORT_PKG.EXPORT_CARDS_NUMBERS' or procedure_name is null )
                                  and ao.account_rownum  = 1
                               ) --account
                           end
                       )
                   )  --xmlagg
               ).getclobval()  --xml root element
             , count(*)
        from iss_card_vw crd
           , prd_contract ct
           , prd_product pr
           , prd_customer m
           , iss_cardholder h
           , iss_card_instance ci
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
          and a.id                = ci.agent_id;

    cur_objects             sys_refcursor;

    l_container_id          com_api_type_pkg.t_long_id;

    -- Generate XML file
    procedure generate_xml is
        l_fetched_count                com_api_type_pkg.t_count    := 0;
        l_params                       com_api_type_pkg.t_param_tab;
        CRLF                  constant com_api_type_pkg.t_name := chr(13) || chr(10);
    begin
        if l_instance_id_tab.count > 0 then
            trc_log_pkg.debug('Creating a new XML file...');
            
            -- Save estimated count of cards in the current iteration
            l_estimated_count := l_estimated_count + l_instance_id_tab.count;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
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

            -- For every processing batch of card instances we fetch data and save it in a separate file
            open cur_xml;
            fetch cur_xml into l_file, l_fetched_count;
            close cur_xml;
            
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

    -- Function returns a reference for a cursor with card instances being processed.
    -- In case of incremental unloading it also returns event objects' identifiers.
    procedure open_cur_objects(
        o_cursor               out sys_refcursor
      , i_full_export       in     com_api_type_pkg.t_boolean
      , i_inst_id           in     com_api_type_pkg.t_inst_id
      , i_subscriber_name   in     com_api_type_pkg.t_name
    ) is
        l_sysdate   date; 
    begin
        trc_log_pkg.debug('Opening a cursor for all card instances those are processed...');

        l_sysdate   := com_api_sttl_day_pkg.get_sysdate;
        if i_full_export = com_api_type_pkg.TRUE then
            -- Get current instances for all available cards
            open o_cursor for
                select max(ci.id)
                  from iss_card_instance ci
                 where ci.split_hash in (select split_hash from com_api_split_map_vw)
                   and (ci.inst_id  = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
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
                         where decode(a.status, 'EVST0001', a.procedure_name, null) = i_subscriber_name
                           and a.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                           and a.object_id   = ci.card_id
                           and a.split_hash  = ci.split_hash
                           and a.eff_date   <= l_sysdate
                           and ci.split_hash in (select split_hash from com_api_split_map_vw)
                           and (ci.inst_id   = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                           and e.id          = a.event_id
                        union all
                        select a.id  as event_object_id
                             , ci.id as card_instance_id
                             , ci.card_id
                          from evt_event_object a
                             , iss_card_instance ci
                             , evt_event e
                         where decode(a.status, 'EVST0001', a.procedure_name, null) = i_subscriber_name
                           and a.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                           and a.object_id   = ci.id
                           and a.split_hash  = ci.split_hash
                           and a.eff_date   <= l_sysdate
                           and ci.split_hash in (select split_hash from com_api_split_map_vw)
                           and (ci.inst_id   = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                           and e.id          = a.event_id
                       ) v
              group by v.card_id
                     , v.event_object_id
              order by 2 asc -- card_instance_id
            ;
        end if;
        trc_log_pkg.debug('Cursor was opened...');
    end;

begin
    trc_log_pkg.debug(
        i_text       => 'export_cards_numbers_1_0: START with l_full_export [#1], i_inst_id [#4], i_count [#5]'
      , i_env_param1 => l_full_export
      , i_env_param4 => i_inst_id
      , i_env_param5 => i_count
    );

    l_sysdate   := com_api_sttl_day_pkg.get_sysdate;

    l_container_id        := prc_api_session_pkg.get_container_id;
    l_is_token_enabled  := iss_api_token_pkg.is_token_enabled;

    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    trc_log_pkg.debug(
        i_text       => 'i_masking_card [#1] l_lang [#2] l_container_id [#3]'
      , i_env_param1 => i_masking_card
      , i_env_param2 => l_lang
      , i_env_param3 => l_container_id
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
            savepoint sp_dwh_card_num_export;

            if l_full_export = com_api_type_pkg.TRUE then
                fetch cur_objects
                 bulk collect into
                      l_instance_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                -- Generate XML file
                generate_xml;

            else  -- l_full_export = com_api_type_pkg.FALSE
                fetch cur_objects
                 bulk collect into
                      l_event_tab
                    , l_incr_instance_id_tab
                limit l_bulk_limit;

                trc_log_pkg.debug('Records were fetched from cursor cur_objects [' || cur_objects%rowcount || ']');

                for i in 1 .. l_incr_instance_id_tab.count loop
                    -- Decrease card instance count and remove the last card instance id from previous iteration
                    if (l_incr_instance_id_tab(i) != l_instance_id or l_instance_id is null)
                       and l_incr_instance_id_tab(i) is not null
                    then
                        l_instance_id := l_incr_instance_id_tab(i);
                        
                        l_instance_id_tab.extend;
                        l_instance_id_tab(l_instance_id_tab.count)   := l_incr_instance_id_tab(i);
                        l_incr_event_tab(l_incr_event_tab.count + 1) := l_event_tab(i);

                        if i = l_incr_instance_id_tab.count then
                            -- Generate XML file for current portion of the "l_bulk_limit" records
                            generate_xml;

                            evt_api_event_pkg.process_event_object(
                                i_event_object_id_tab => l_incr_event_tab
                            );

                            -- Save last element of the array on a current iteration to use it for the next one
                            l_instance_id_tab.delete;
                            l_incr_event_tab.delete;
                        end if;
                    else  -- Select event for last account id from previous iteration
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
                rollback to sp_dwh_card_num_export;
                raise;
        end;
    end loop;
    close cur_objects;

    prc_api_stat_pkg.log_end(
        i_excepted_total  => 0
      , i_processed_total => l_total_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug('export_cards_numbers_1_0: FINISH');
exception
    when others then
        rollback to sp_dwh_card_num_export;
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

procedure export_cards_numbers(
    i_dwh_version         in     com_api_type_pkg.t_name
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_count               in     com_api_type_pkg.t_medium_id     default null
  , i_masking_card        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
) as
begin
    trc_log_pkg.debug(
        i_text        => 'i_dwh_version=' || i_dwh_version
    );
    
    if i_dwh_version between '1.0' and '1.2' then
        export_cards_numbers_1_0(
            i_inst_id          => i_inst_id
          , i_full_export      => i_full_export
          , i_lang             => i_lang
          , i_count            => i_count
          , i_masking_card     => i_masking_card
        );
    elsif i_dwh_version = '1.3' then
        export_cards_numbers_1_3(
            i_inst_id          => i_inst_id
          , i_full_export      => i_full_export
          , i_lang             => i_lang
          , i_count            => i_count
          , i_masking_card     => i_masking_card
        );
    else
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'VERSION_IS_NOT_SUPPORTED'
          , i_env_param1  => i_dwh_version
        );
    end if;
end;

procedure export_cards_status(
    i_dwh_version         in     com_api_type_pkg.t_name
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_count               in     com_api_type_pkg.t_medium_id     default null
  , i_masking_card        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
) as
begin
    trc_log_pkg.debug(
        i_text        => 'i_dwh_version=' || i_dwh_version
    );
    
    if i_dwh_version between '1.0' and '1.2' then
        export_cards_status_1_0(
            i_inst_id          => i_inst_id
          , i_full_export      => i_full_export
          , i_count            => i_count
          , i_masking_card     => i_masking_card
        );
    elsif i_dwh_version = '1.3' then
        export_cards_status_1_3(
            i_inst_id          => i_inst_id
          , i_full_export      => i_full_export
          , i_count            => i_count
          , i_masking_card     => i_masking_card
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
