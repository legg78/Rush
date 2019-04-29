create or replace package body opr_ui_operation_pkg as

procedure modify_status(
    i_oper_id           in      com_api_type_pkg.t_long_id
  , i_oper_status       in      com_api_type_pkg.t_dict_value
  , i_forced_processing in      com_api_type_pkg.t_boolean      default null
) is
begin
    update opr_operation
       set status = i_oper_status
         , forced_processing = nvl(i_forced_processing, forced_processing)
     where id = i_oper_id;

    evt_api_status_pkg.add_status_log(
        i_event_type    => null
      , i_initiator     => evt_api_const_pkg.INITIATOR_OPERATOR
      , i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id     => i_oper_id
      , i_reason        => null
      , i_status        => i_oper_status
      , i_eff_date      => com_api_sttl_day_pkg.get_sysdate
    );

    trc_log_pkg.info(
        i_text          => 'Status of operation changed to [#1]; forced processing [#2]'
      , i_env_param1    => i_oper_status 
      , i_env_param2    => i_forced_processing
      , i_object_id     => i_oper_id
      , i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
    );
end;

procedure modify_statuses(
    i_session_id          in    com_api_type_pkg.t_long_id      default null
  , i_incom_sess_file_id  in    com_api_type_pkg.t_long_id      default null
  , i_host_date_from      in    date                            default null
  , i_host_date_to        in    date                            default null
  , i_msg_type            in    com_api_type_pkg.t_dict_value   default null
  , i_sttl_type           in    com_api_type_pkg.t_dict_value   default null    
  , i_is_reversal         in    com_api_type_pkg.t_boolean      default null  
  , i_oper_currency       in    com_api_type_pkg.t_curr_code    default null
  , i_oper_type           in    com_api_type_pkg.t_dict_value   default null
  , i_oper_status         in    com_api_type_pkg.t_dict_value   
  , i_new_status          in    com_api_type_pkg.t_dict_value   
  , i_oper_id             in    com_api_type_pkg.t_long_id      default null
  , i_oper_reason         in    com_api_type_pkg.t_dict_value   default null
) is
    l_event_type_tab            com_api_type_pkg.t_dict_tab;
    l_initiator_tab             com_api_type_pkg.t_dict_tab;
    l_entity_type_tab           com_api_type_pkg.t_dict_tab;
    l_object_id_tab             com_api_type_pkg.t_number_tab;
    l_reason_tab                com_api_type_pkg.t_dict_tab;
    l_status_tab                com_api_type_pkg.t_dict_tab;
    l_eff_date_tab              com_api_type_pkg.t_date_tab;
    l_event_date_tab            com_api_type_pkg.t_date_tab;

    l_oper_id_tab               num_tab_tpt := num_tab_tpt();
    l_particip_oper_id_tab      com_api_type_pkg.t_long_tab;
    l_particip_split_hash_tab   com_api_type_pkg.t_tiny_tab;
    l_particip_inst_id_tab      com_api_type_pkg.t_tiny_tab;
    l_count                     com_api_type_pkg.t_count := 0;
begin
    trc_log_pkg.debug(
        i_text => lower($$PLSQL_UNIT) || '.modify_statuses' ||
        ': i_session_id=[' || i_session_id || '], i_incom_sess_file_id=[' || i_incom_sess_file_id ||']' ||
        ', i_host_date_from=[' || i_host_date_from || '], i_host_date_to=[' || i_host_date_to ||']' ||
        ', i_msg_type=[' || i_msg_type || '], i_sttl_type=[' || i_sttl_type ||']' || ', i_is_reversal=['|| i_is_reversal ||']' ||
        ', i_oper_currency=[' || i_oper_currency || '], i_oper_type=[' || i_oper_type ||']' || ', i_oper_id=['|| i_oper_id ||']' ||
        ', i_oper_status=[' || i_oper_status || ']'        
    );

    if i_session_id is null 
        and i_incom_sess_file_id is null 
        and i_host_date_from is null
        and i_host_date_to is null
        and i_msg_type is null
        and i_sttl_type is null
        and i_is_reversal is null
        and i_oper_currency is null
        and i_oper_type is null
        and i_oper_id  is null
    then
        com_api_error_pkg.raise_error(
            i_error => 'NOT_ENOUGH_DATA_TO_FIND_OPERATIONS'
        );       
    end if;

    if i_oper_id is not null then
        update opr_operation 
           set status = i_new_status 
             , oper_reason = nvl(i_oper_reason, oper_reason)
         where id = i_oper_id;

        evt_api_status_pkg.add_status_log(
            i_event_type    => null
          , i_initiator     => evt_api_const_pkg.INITIATOR_OPERATOR
          , i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id     => i_oper_id
          , i_reason        => i_oper_reason
          , i_status        => i_new_status
          , i_eff_date      => com_api_sttl_day_pkg.get_sysdate
          , i_event_date    => null
        );
        
        select count(1)
          into l_count
          from opr_participant pa
         where pa.oper_id = i_oper_id;
        
        if l_count > 0 then
            select distinct 
                   split_hash
                 , inst_id
              bulk collect
              into l_particip_split_hash_tab
                 , l_particip_inst_id_tab
              from opr_participant
             where oper_id = i_oper_id;

            if l_particip_split_hash_tab.count > 0 then
                for i in 1 .. l_particip_split_hash_tab.count loop
                    evt_api_event_pkg.register_event(
                        i_event_type     => opr_api_const_pkg.EVENT_OPERATION_STATUS_CHANGED
                      , i_eff_date       => com_api_sttl_day_pkg.get_sysdate
                      , i_entity_type    => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      , i_object_id      => i_oper_id
                      , i_inst_id        => l_particip_inst_id_tab(i)
                      , i_split_hash     => l_particip_split_hash_tab(i)
                      , i_param_tab      => opr_api_shared_data_pkg.g_params
                    );
                end loop;
            end if;
        else
            trc_log_pkg.debug(
                i_text       => 'Events [#1] was not registered for the operation [#2] because of no participants'
              , i_env_param1 => opr_api_const_pkg.EVENT_OPERATION_STATUS_CHANGED
              , i_env_param2 => i_oper_id
            );
        end if;
    else
        select null
             , evt_api_const_pkg.INITIATOR_OPERATOR 
             , opr_api_const_pkg.ENTITY_TYPE_OPERATION
             , id
             , nvl(i_oper_reason, oper_reason)
             , i_new_status
             , com_api_sttl_day_pkg.get_sysdate
             , null
          bulk collect into 
               l_event_type_tab   
             , l_initiator_tab  
             , l_entity_type_tab
             , l_object_id_tab  
             , l_reason_tab     
             , l_status_tab     
             , l_eff_date_tab
             , l_event_date_tab
          from opr_operation 
         where status not in (opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                            , opr_api_const_pkg.OPERATION_STATUS_DONE_WO_PROC
                            , opr_api_const_pkg.OPERATION_STATUS_UNHOLDED
                            , opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED
                            , opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD
                            , opr_api_const_pkg.OPERATION_STATUS_PART_UNHOLD)
           and (i_session_id is null         or session_id = i_session_id)
           and (i_incom_sess_file_id is null or incom_sess_file_id = i_incom_sess_file_id)
           and (i_host_date_from is null     or host_date >= i_host_date_from)
           and (i_host_date_to is null       or host_date <= i_host_date_to)
           and (i_msg_type is null           or msg_type = i_msg_type)
           and (i_sttl_type is null          or sttl_type = i_sttl_type)
           and (is_reversal is null          or is_reversal = i_is_reversal)
           and (i_oper_currency is null      or oper_currency = i_oper_currency)
           and (i_oper_type is null          or oper_type = i_oper_type)
           and (i_oper_status is null        or status = i_oper_status);
          
        update opr_operation 
           set status = i_new_status 
             , oper_reason = nvl(i_oper_reason, oper_reason)
         where status not in (opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                            , opr_api_const_pkg.OPERATION_STATUS_DONE_WO_PROC
                            , opr_api_const_pkg.OPERATION_STATUS_UNHOLDED
                            , opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED
                            , opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD
                            , opr_api_const_pkg.OPERATION_STATUS_PART_UNHOLD)
           and (i_session_id is null         or session_id = i_session_id)
           and (i_incom_sess_file_id is null or incom_sess_file_id = i_incom_sess_file_id)
           and (i_host_date_from is null     or host_date >= i_host_date_from)
           and (i_host_date_to is null       or host_date <= i_host_date_to)
           and (i_msg_type is null           or msg_type = i_msg_type)
           and (i_sttl_type is null          or sttl_type = i_sttl_type)
           and (is_reversal is null          or is_reversal = i_is_reversal)
           and (i_oper_currency is null      or oper_currency = i_oper_currency)
           and (i_oper_type is null          or oper_type = i_oper_type)
           and (i_oper_status is null        or status = i_oper_status)
        returning id bulk collect into l_oper_id_tab;
        
        if l_oper_id_tab.count > 0 then
            select count(1)
              into l_count
              from opr_participant
             where oper_id in (select column_value from table(l_oper_id_tab));
             
            if l_count > 0 then
                select distinct 
                       split_hash
                     , inst_id
                     , oper_id
                  bulk collect
                  into l_particip_split_hash_tab
                     , l_particip_inst_id_tab
                     , l_particip_oper_id_tab
                  from opr_participant
                 where oper_id in (select column_value from table(l_oper_id_tab));

                if l_particip_split_hash_tab.count > 0 then
                    for i in 1 .. l_particip_split_hash_tab.count loop
                        evt_api_event_pkg.register_event(
                            i_event_type     => opr_api_const_pkg.EVENT_OPERATION_STATUS_CHANGED
                          , i_eff_date       => com_api_sttl_day_pkg.get_sysdate
                          , i_entity_type    => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                          , i_object_id      => l_particip_oper_id_tab(i)
                          , i_inst_id        => l_particip_inst_id_tab(i)
                          , i_split_hash     => l_particip_split_hash_tab(i)
                          , i_param_tab      => opr_api_shared_data_pkg.g_params
                        );
                    end loop;
                end if;
            else
                trc_log_pkg.debug(
                    i_text       => 'Event [#1] was not registered for operations because of no participants'
                  , i_env_param1 => opr_api_const_pkg.EVENT_OPERATION_STATUS_CHANGED
                );
            end if;
        end if;
           
        evt_api_status_pkg.add_status_log (
            i_event_type    => l_event_type_tab
            , i_initiator   => l_initiator_tab
            , i_entity_type => l_entity_type_tab
            , i_object_id   => l_object_id_tab
            , i_reason      => l_reason_tab
            , i_status      => l_status_tab
            , i_eff_date    => l_eff_date_tab
            , i_event_date  => l_event_date_tab
        );            
    end if;        

    trc_log_pkg.debug('Updated [' || sql%rowcount || '] records');
end;

procedure match_operations(
    i_orig_oper_id         in      com_api_type_pkg.t_long_id
  , i_pres_oper_id         in      com_api_type_pkg.t_long_id
)
is
begin
    trc_log_pkg.debug(
        i_text          => 'match_operation Start. i_orig_oper_id=[#1], i_pres_oper_id=[#2]'
        , i_env_param1  => i_orig_oper_id
        , i_env_param2  => i_pres_oper_id
    );
    
    update opr_operation 
       set match_status = opr_api_const_pkg.OPERATION_MATCH_MATCHED
         , match_id     = i_orig_oper_id
    where id = i_pres_oper_id;

    trc_log_pkg.debug(
        i_text       => 'Updated [' || sql%rowcount || '] records'
    );

    update opr_operation 
       set match_status = opr_api_const_pkg.OPERATION_MATCH_MATCHED
         , match_id     = i_pres_oper_id
    where id = i_orig_oper_id;

    trc_log_pkg.debug(
        i_text       => 'Updated [' || sql%rowcount || '] records'
    );

    trc_log_pkg.debug(
        i_text       => 'match_operation End'
    );
end;

procedure match_operation_reversal(
    i_orig_oper_id         in      com_api_type_pkg.t_long_id
  , i_reversal_oper_id     in      com_api_type_pkg.t_long_id
)
is
begin
    trc_log_pkg.debug(
        i_text          => 'match_operation_reversal Start. i_orig_oper_id=[#1], i_reversal_oper_id=[#2]'
        , i_env_param1  => i_orig_oper_id
        , i_env_param2  => i_reversal_oper_id
    );
    
    update opr_operation 
       set original_id    = i_orig_oper_id
    where id = i_reversal_oper_id;

    trc_log_pkg.debug(
        i_text       => 'Updated [' || sql%rowcount || '] records'
    );

    trc_log_pkg.debug(
        i_text       => 'match_operation_reversal End'
    );
end;

/*
 * Procedure searches an operation's participant and performs checks that could modify some its data.
 */
procedure perform_checks(
    i_oper_id               in     com_api_type_pkg.t_long_id
  , i_participant_type      in     com_api_type_pkg.t_dict_value
  , o_network_id               out com_api_type_pkg.t_tiny_id
  , o_inst_id                  out com_api_type_pkg.t_inst_id
  , o_card_inst_id             out com_api_type_pkg.t_inst_id
  , o_card_network_id          out com_api_type_pkg.t_network_id
  , o_card_type_id             out com_api_type_pkg.t_tiny_id
  , o_card_mask                out com_api_type_pkg.t_card_number
  , o_card_hash                out com_api_type_pkg.t_medium_id
  , o_card_seq_number          out com_api_type_pkg.t_tiny_id
  , o_card_expir_date          out date
  , o_card_service_code        out com_api_type_pkg.t_country_code
  , o_card_country             out com_api_type_pkg.t_country_code
  , o_account_id               out com_api_type_pkg.t_medium_id
  , o_customer_id              out com_api_type_pkg.t_medium_id
  , o_merchant_id              out com_api_type_pkg.t_short_id
  , o_terminal_id              out com_api_type_pkg.t_short_id
  , o_card_id                  out com_api_type_pkg.t_medium_id
  , o_card_instance_id         out com_api_type_pkg.t_medium_id
  , o_split_hash               out com_api_type_pkg.t_tiny_id
  -- Parameters that could be changed indirectly
  , o_customer_name            out com_api_type_pkg.t_text
  , o_inst_name                out com_api_type_pkg.t_text
  , o_card_inst_name           out com_api_type_pkg.t_text
  , o_network_name             out com_api_type_pkg.t_text
  , o_card_network_name        out com_api_type_pkg.t_text
  , o_card_type_name           out com_api_type_pkg.t_text
  -- Additional parameters
  , o_client_id_type           out com_api_type_pkg.t_dict_value
  , o_client_id_value          out com_api_type_pkg.t_name
  , o_account_type             out com_api_type_pkg.t_dict_value
  , o_account_amount           out com_api_type_pkg.t_money
  , o_account_currency         out com_api_type_pkg.t_curr_code
  , o_auth_code                out com_api_type_pkg.t_auth_code
  , o_card_number              out com_api_type_pkg.t_card_number
) is
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.perform_checks: ';
    l_participant           opr_api_type_pkg.t_oper_part_rec;
    l_operation             opr_api_type_pkg.t_oper_rec;
    l_participant_acquirer  opr_api_type_pkg.t_oper_part_rec;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START with i_oper_id [' || i_oper_id || '], i_participant_type [#1]'
      , i_env_param1 => i_participant_type
    );

    opr_api_operation_pkg.get_operation(
        i_oper_id           => i_oper_id
      , o_operation         => l_operation
    );
    opr_api_operation_pkg.get_participant(
        i_oper_id           => i_oper_id
      , i_participaint_type => i_participant_type
      , o_participant       => l_participant
    );

    opr_api_operation_pkg.get_participant(
        i_oper_id           => i_oper_id
      , i_participaint_type => com_api_const_pkg.PARTICIPANT_ACQUIRER
      , o_participant       => l_participant_acquirer
    );

    if l_operation.id is null then
        trc_log_pkg.debug(LOG_PREFIX || 'operation has NOT been found, exit from the procedure');
    elsif l_participant.oper_id is null then
        trc_log_pkg.debug(LOG_PREFIX || 'operation''s participant has NOT been found, exit from the procedure');
    else
        -- Storing fields that are used as outgoing parameters in procedure below,
        -- because they could be set to NULL if no any checks will be found 
        o_card_id           := l_participant.card_id;
        o_card_instance_id  := l_participant.card_instance_id;
        o_split_hash        := l_participant.split_hash;

        --trc_log_pkg.debug(LOG_PREFIX || 'l_participant.split_hash [' || l_participant.split_hash || ']');
        opr_api_create_pkg.perform_checks(
            i_oper_id            => l_participant.oper_id
          , i_msg_type           => l_operation.msg_type
          , i_oper_type          => l_operation.oper_type
          , i_oper_reason        => l_operation.oper_reason
          , i_party_type         => l_participant.participant_type
          , i_host_date          => l_operation.host_date
          , io_network_id        => l_participant.network_id
          , io_inst_id           => l_participant.inst_id
          , io_client_id_type    => l_participant.client_id_type
          , io_client_id_value   => l_participant.client_id_value
          , io_card_number       => l_participant.card_number
          , io_card_inst_id      => l_participant.card_inst_id
          , io_card_network_id   => l_participant.card_network_id
          , o_card_id            => l_participant.card_id
          , o_card_instance_id   => l_participant.card_instance_id
          , io_card_type_id      => l_participant.card_type_id
          , io_card_mask         => l_participant.card_mask
          , io_card_hash         => l_participant.card_hash
          , io_card_seq_number   => l_participant.card_seq_number
          , io_card_expir_date   => l_participant.card_expir_date
          , io_card_service_code => l_participant.card_service_code
          , io_card_country      => l_participant.card_country
          , i_account_number     => l_participant.account_number
          , io_account_id        => l_participant.account_id
          , io_customer_id       => l_participant.customer_id
          , i_merchant_number    => l_operation.merchant_number
          , io_merchant_id       => l_participant.merchant_id
          , i_terminal_number    => l_operation.terminal_number
          , io_terminal_id       => l_participant.terminal_id
          , o_split_hash         => l_participant.split_hash
          , i_mask_error         => com_api_type_pkg.FALSE
          , i_acq_inst_id        => l_participant_acquirer.inst_id
          , i_acq_network_id     => l_participant_acquirer.network_id
          , i_oper_currency      => l_operation.oper_currency
        );
        trc_log_pkg.debug(LOG_PREFIX || 'checks completed');
        --trc_log_pkg.debug(LOG_PREFIX || 'l_participant.split_hash [' || l_participant.split_hash || ']');

        o_network_id        := l_participant.network_id;
        o_inst_id           := l_participant.inst_id;
        o_card_inst_id      := l_participant.card_inst_id;
        o_card_network_id   := l_participant.card_network_id;
        o_card_type_id      := l_participant.card_type_id;
        o_card_mask         := l_participant.card_mask;
        o_card_hash         := l_participant.card_hash;
        o_card_seq_number   := l_participant.card_seq_number;
        o_card_expir_date   := l_participant.card_expir_date;
        o_card_service_code := l_participant.card_service_code;
        o_card_country      := l_participant.card_country;
        o_account_id        := l_participant.account_id;
        o_customer_id       := l_participant.customer_id;
        o_merchant_id       := l_participant.merchant_id;
        o_terminal_id       := l_participant.terminal_id;
        o_card_id           := nvl(l_participant.card_id, o_card_id);
        o_card_instance_id  := nvl(l_participant.card_instance_id, o_card_instance_id);
        o_split_hash        := nvl(l_participant.split_hash, o_split_hash);
        
        o_customer_name     := com_ui_object_pkg.get_object_desc(
                                   i_object_id   => l_participant.customer_id
                                 , i_entity_type => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                               );
        o_inst_name         := com_api_i18n_pkg.get_text(
                                   i_table_name  => 'ost_institution'
                                 , i_column_name => 'name'
                                 , i_object_id   => l_participant.inst_id
                               );
        o_card_inst_name    := com_api_i18n_pkg.get_text(
                                   i_table_name  => 'ost_institution'
                                 , i_column_name => 'name'
                                 , i_object_id   => l_participant.card_inst_id
                               );
        o_network_name      := com_api_i18n_pkg.get_text(
                                   i_table_name  => 'net_network'
                                 , i_column_name => 'name'
                                 , i_object_id   => l_participant.network_id
                               );
        o_card_network_name := com_api_i18n_pkg.get_text(
                                   i_table_name  => 'net_network'
                                 , i_column_name => 'name'
                                 , i_object_id   => l_participant.card_network_id
                               );
        o_card_type_name    := com_api_i18n_pkg.get_text(
                                   i_table_name  => 'net_card_type'
                                 , i_column_name => 'name'
                                 , i_object_id   => l_participant.card_type_id
                               );
        o_client_id_type    := l_participant.client_id_type;
        o_client_id_value   := l_participant.client_id_value;
        o_account_type      := l_participant.account_type;
        o_account_amount    := l_participant.account_amount;
        o_account_currency  := l_participant.account_currency;
        o_auth_code         := l_participant.auth_code;
        o_card_number       := l_participant.card_number;
    end if;

    trc_log_pkg.debug(LOG_PREFIX || 'END');
end perform_checks;

/*
 * Procedure searches participant by PK i_oper_id & i_participant_type and updates all its fields.
 */
procedure update_participant(
    i_oper_id               in     com_api_type_pkg.t_long_id
  , i_participant_type      in     com_api_type_pkg.t_dict_value
  , i_split_hash            in     com_api_type_pkg.t_tiny_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_card_inst_id          in     com_api_type_pkg.t_inst_id
  , i_card_network_id       in     com_api_type_pkg.t_network_id
  , i_card_id               in     com_api_type_pkg.t_medium_id
  , i_card_instance_id      in     com_api_type_pkg.t_medium_id
  , i_card_type_id          in     com_api_type_pkg.t_tiny_id
  , i_card_mask             in     com_api_type_pkg.t_card_number
  , i_card_hash             in     com_api_type_pkg.t_medium_id
  , i_card_seq_number       in     com_api_type_pkg.t_tiny_id
  , i_card_expir_date       in     date
  , i_card_service_code     in     com_api_type_pkg.t_country_code
  , i_card_country          in     com_api_type_pkg.t_country_code
  , i_customer_id           in     com_api_type_pkg.t_medium_id
  , i_account_id            in     com_api_type_pkg.t_medium_id
  , i_merchant_id           in     com_api_type_pkg.t_short_id
  , i_terminal_id           in     com_api_type_pkg.t_short_id
  , i_client_id_type        in     com_api_type_pkg.t_dict_value        default null
  , i_client_id_value       in     com_api_type_pkg.t_name              default null
  , i_account_type          in     com_api_type_pkg.t_dict_value        default null
  , i_account_number        in     com_api_type_pkg.t_account_number    default null
  , i_account_amount        in     com_api_type_pkg.t_money             default null
  , i_account_currency      in     com_api_type_pkg.t_curr_code         default null
  , i_auth_code             in     com_api_type_pkg.t_auth_code         default null
  , i_card_number           in     com_api_type_pkg.t_card_number       default null
) is
    LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.update_participant: ';
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'START with i_oper_id [' || i_oper_id
               || '], i_participant_type [' || i_participant_type 
               || '], i_split_hash [' || i_split_hash
               || '], i_card_mask [' || i_card_mask || ']'
    );

    update opr_participant_vw op
       set op.split_hash        = i_split_hash
         , op.client_id_type    = nvl(i_client_id_type, op.client_id_type)
         , op.client_id_value   = nvl(i_client_id_value, op.client_id_value)  
         , op.inst_id           = i_inst_id
         , op.network_id        = i_network_id
         , op.card_inst_id      = i_card_inst_id
         , op.card_network_id   = i_card_network_id
         , op.card_id           = i_card_id
         , op.card_instance_id  = i_card_instance_id
         , op.card_type_id      = i_card_type_id
         , op.card_mask         = i_card_mask
         , op.card_hash         = i_card_hash
         , op.card_seq_number   = i_card_seq_number
         , op.card_expir_date   = i_card_expir_date
         , op.card_service_code = i_card_service_code
         , op.card_country      = i_card_country
         , op.customer_id       = i_customer_id
         , op.account_id        = i_account_id
         , op.account_type      = nvl(i_account_type, op.account_type)
         , op.account_number    = nvl(i_account_number, op.account_number)
         , op.account_amount    = nvl(i_account_amount, op.account_amount)
         , op.account_currency  = nvl(i_account_currency, op.account_currency)
         , op.auth_code         = nvl(i_auth_code, op.auth_code)
         , op.merchant_id       = i_merchant_id
         , op.terminal_id       = i_terminal_id
     where op.oper_id           = i_oper_id
       and op.participant_type  = i_participant_type;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'participant has '
               || case when sql%rowcount = 0 then 'NOT been found' else 'been updated' end
    );

    if i_card_number is not null then
        update opr_card oc
           set oc.card_number       = i_card_number
             , oc.split_hash        = i_split_hash
         where oc.oper_id           = i_oper_id
           and oc.participant_type  = i_participant_type;

        trc_log_pkg.debug(LOG_PREFIX || 'card number has ' || case when sql%rowcount = 0 then 'NOT ' else null end || 'been updated');
    end if;
end update_participant;

procedure modify_sttl_type(
    i_oper_id               in     com_api_type_pkg.t_long_id
  , i_sttl_type             in     com_api_type_pkg.t_dict_value
) is
begin
    com_api_dictionary_pkg.check_article(
        i_dict => opr_api_const_pkg.SETTLEMENT_TYPE_KEY
      , i_code => i_sttl_type
    );

    update opr_operation_vw
       set sttl_type = i_sttl_type
     where id = i_oper_id;

    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.modify_sttl_type: sttl_type has'
                                          || case when sql%rowcount = 0 then 'NOT ' else null end || 'been updated');
end;

end;
/
