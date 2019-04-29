create or replace package body cst_bof_api_rule_proc_pkg is
/*********************************************************
 *  API for custom rules processing <br />
 *  Created by Gogolev I.(i.gogolev@bpcbt.com)  at 11.02.2018 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::              $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: CST_BOF_API_RULE_PROC_PKG <br />
 *  @headcom
 **********************************************************/
procedure check_card_status_opr_proc is
    l_card_status                   com_api_type_pkg.t_dict_value;
    l_oper_participant              opr_api_type_pkg.t_oper_part_rec;
    l_participant_type              com_api_type_pkg.t_dict_value;
    l_iss_card_instance             iss_api_type_pkg.t_card_instance;
begin
    l_card_status := opr_api_shared_data_pkg.get_param_char('CARD_INSTANCE_STATUS');
    
    l_participant_type := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    
    l_oper_participant := opr_api_shared_data_pkg.get_participant(l_participant_type);
    
    l_iss_card_instance :=
        iss_api_card_instance_pkg.get_instance(
            i_id          => iss_api_card_instance_pkg.get_card_instance_id(i_card_id => l_oper_participant.card_id)
          , i_raise_error => com_api_const_pkg.TRUE
        );
        
    if l_card_status <> l_iss_card_instance.status then
        com_api_error_pkg.raise_error(
            i_error      => 'OPERATION_HAS_INVALID_CARD_STATUS'
          , i_env_param1 => l_oper_participant.oper_id
          , i_env_param2 => l_oper_participant.card_id
          , i_env_param3 => l_iss_card_instance.status
          , i_env_param4 => l_iss_card_instance.state
        );
    end if;

end check_card_status_opr_proc;

procedure check_cycle_is_active_opr_proc is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.check_cycle_is_active_opr_proc: ';
    l_cycle_type                    com_api_type_pkg.t_dict_value;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_oper_participant              opr_api_type_pkg.t_oper_part_rec;
    l_participant_type              com_api_type_pkg.t_dict_value;
    l_prev_date                     date;
    l_next_date                     date;
    l_eff_date                      date;
begin
    l_cycle_type := opr_api_shared_data_pkg.get_param_char('CYCLE_TYPE');
    
    l_entity_type := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    
    l_participant_type := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    
    l_oper_participant := opr_api_shared_data_pkg.get_participant(l_participant_type);
    
    fcl_api_cycle_pkg.get_cycle_date(
        i_cycle_type  => l_cycle_type
      , i_entity_type => l_entity_type
      , i_object_id   => case l_entity_type
                             when iss_api_const_pkg.ENTITY_TYPE_CARD
                                 then l_oper_participant.card_id
                             when iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                                 then l_oper_participant.card_instance_id
                             when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                 then l_oper_participant.account_id
                             when acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                 then l_oper_participant.merchant_id
                             when acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                 then l_oper_participant.terminal_id
                             else null
                         end
      , i_add_counter => com_api_const_pkg.FALSE
      , o_prev_date   => l_prev_date
      , o_next_date   => l_next_date
    );
    
    l_eff_date := com_api_sttl_day_pkg.get_sysdate;
    
    l_next_date := trunc(l_next_date) + 1 - com_api_const_pkg.ONE_SECOND;
        
    if l_next_date is null
        or l_eff_date not between nvl(l_prev_date, l_eff_date) and l_next_date
    then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'cycle for cycle_type[#1] entity[#2] participant[#3] oper_id[#4] prev_date[#5] next_date[#6] not activated'
          , i_env_param1 => l_cycle_type
          , i_env_param2 => l_entity_type
          , i_env_param3 => l_participant_type
          , i_env_param4 => l_oper_participant.oper_id
          , i_env_param5 => l_prev_date
          , i_env_param6 => l_next_date
        );
        com_api_error_pkg.raise_error(
            i_error      => 'CYCLE_NOT_FOUND'
          , i_env_param1 => l_cycle_type
        );
    end if;

end check_cycle_is_active_opr_proc;

procedure activate_card_opr_proc is
    l_source_status                 com_api_type_pkg.t_dict_value;
    l_result_status                 com_api_type_pkg.t_dict_value;
    l_oper_participant              opr_api_type_pkg.t_oper_part_rec;
    l_participant_type              com_api_type_pkg.t_dict_value;
begin
    l_participant_type := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    
    l_oper_participant := opr_api_shared_data_pkg.get_participant(l_participant_type);
    
    l_source_status := opr_api_shared_data_pkg.get_param_char('INITIAL_CARD_STATUS');
    
    l_result_status := opr_api_shared_data_pkg.get_param_char('CARD_STATUS');

    iss_api_card_pkg.activate_card (
        i_card_instance_id  => coalesce(
                                   l_oper_participant.card_instance_id
                                 , iss_api_card_instance_pkg.get_card_instance_id(i_card_id => l_oper_participant.card_id)
                               )
      , i_initial_status    => l_source_status
      , i_status            => l_result_status
    );

end activate_card_opr_proc;

procedure deactivate_card_opr_proc is
    l_result_status                 com_api_type_pkg.t_dict_value;
    l_oper_participant              opr_api_type_pkg.t_oper_part_rec;
    l_participant_type              com_api_type_pkg.t_dict_value;
begin
    l_participant_type := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    
    l_oper_participant := opr_api_shared_data_pkg.get_participant(l_participant_type);
    
    l_result_status := opr_api_shared_data_pkg.get_param_char('CARD_STATUS');

    iss_api_card_pkg.deactivate_card (
        i_card_instance_id  => coalesce(
                                   l_oper_participant.card_instance_id
                                 , iss_api_card_instance_pkg.get_card_instance_id(i_card_id => l_oper_participant.card_id)
                               )
      , i_status            => l_result_status
    );

end deactivate_card_opr_proc;

procedure deactivate_card_evt_proc is
    l_result_status                 com_api_type_pkg.t_dict_value;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_object_id                     com_api_type_pkg.t_long_id;
begin
    l_result_status := opr_api_shared_data_pkg.get_param_char('CARD_STATUS');
    l_entity_type     := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id       := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    
    if l_entity_type in (
           iss_api_const_pkg.ENTITY_TYPE_CARD
         , iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
       )
    then
        iss_api_card_pkg.deactivate_card(
            i_card_instance_id  => case l_entity_type
                                       when iss_api_const_pkg.ENTITY_TYPE_CARD
                                           then iss_api_card_instance_pkg.get_card_instance_id(i_card_id => l_object_id)
                                       when iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                                           then l_object_id
                                       else null
                                   end
          , i_status            => l_result_status
        );
    else
        com_api_error_pkg.raise_error(
            i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => l_entity_type
        );
    end if;

end deactivate_card_evt_proc;

procedure reset_cycle_counter_opr_proc is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.reset_cycle_counter_opr_proc: ';
    l_participant_type              com_api_type_pkg.t_dict_value;
    l_oper_participant              opr_api_type_pkg.t_oper_part_rec;
    l_cycle_type                    com_api_type_pkg.t_name;
    l_entity_type                   com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_split_hash                    com_api_type_pkg.t_tiny_id;

begin
    l_participant_type := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    l_oper_participant := opr_api_shared_data_pkg.get_participant(l_participant_type);
    
    l_cycle_type  := opr_api_shared_data_pkg.get_param_char('CYCLE_TYPE');
    l_entity_type := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id   := case l_entity_type
                         when iss_api_const_pkg.ENTITY_TYPE_CARD
                             then l_oper_participant.card_id
                         when iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                             then coalesce(
                                      l_oper_participant.card_instance_id
                                    , iss_api_card_instance_pkg.get_card_instance_id(i_card_id => l_oper_participant.card_id)
                                  )
                         when acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                             then l_oper_participant.merchant_id
                         when acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                             then l_oper_participant.terminal_id
                         else null
                     end;
    l_split_hash  :=
        com_api_hash_pkg.get_split_hash(
            i_entity_type   =>  l_entity_type
          , i_object_id     =>  l_object_id
          , i_mask_error    =>  com_api_const_pkg.FALSE
        );

    trc_log_pkg.debug (
        i_text           => LOG_PREFIX || 'Going to reset cycle counter [#1][#2][#3][#4]'
        , i_env_param1   => l_cycle_type
        , i_env_param2   => l_entity_type
        , i_env_param3   => l_object_id
        , i_env_param4   => l_split_hash
    );

    fcl_api_cycle_pkg.reset_cycle_counter(
        i_cycle_type     => l_cycle_type
      , i_entity_type    => l_entity_type
      , i_object_id      => l_object_id
      , i_split_hash     => l_split_hash
    );
end reset_cycle_counter_opr_proc;

procedure get_remittance_opr_process is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_remittance_opr_process: ';
    l_reg_event_type                com_api_type_pkg.t_dict_value;
    l_oper_participant              opr_api_type_pkg.t_oper_part_rec;
    l_participant_type              com_api_type_pkg.t_dict_value;
    l_orig_party_type               com_api_type_pkg.t_dict_value;
    l_oper_id                       com_api_type_pkg.t_long_id;
begin
    l_reg_event_type   := opr_api_shared_data_pkg.get_param_char('EVENT_OBJECT_TYPE');
    l_participant_type := opr_api_shared_data_pkg.get_param_char('PARTY_TYPE');
    l_orig_party_type  := opr_api_shared_data_pkg.get_param_char('ORIGINAL_PARTY_TYPE');
    l_oper_participant := opr_api_shared_data_pkg.get_participant(l_participant_type);
    
    select max(o.id)
      into l_oper_id
      from opr_participant p
         , opr_operation o
     where p.card_id = l_oper_participant.card_id
       and p.participant_type = l_orig_party_type
       and o.id = p.oper_id
       and o.status in (
               opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
             , opr_api_const_pkg.OPERATION_STATUS_PROCESSED
             , opr_api_const_pkg.OPERATION_STATUS_PROCESSING
           )
       and not exists(select 1
                        from opr_operation r
                       where r.original_id = o.id
                         and r.is_reversal = com_api_const_pkg.TRUE
                         and r.status in (
                                 opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                               , opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                               , opr_api_const_pkg.OPERATION_STATUS_PROCESSING
                             )
                     );
        
    if l_oper_id is not null then
        evt_api_event_pkg.register_event (
            i_event_type    => l_reg_event_type
          , i_eff_date      => com_api_sttl_day_pkg.get_sysdate
          , i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id     => l_oper_id
          , i_inst_id       => l_oper_participant.inst_id
          , i_split_hash    => l_oper_participant.split_hash
          , i_param_tab     => opr_api_shared_data_pkg.g_params
        );
    else
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'original remittance operation not found for oper_id[#1] card_id[#2] original_party[#3]'
          , i_env_param1 => l_oper_participant.oper_id
          , i_env_param2 => l_oper_participant.card_id
          , i_env_param3 => l_orig_party_type
        );
    end if;

end get_remittance_opr_process;

procedure get_remittance_evt_process is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_remittance_evt_process: ';
    l_reg_event_type                com_api_type_pkg.t_dict_value;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_orig_party_type               com_api_type_pkg.t_dict_value;
    l_oper_id                       com_api_type_pkg.t_long_id;
    l_params                        com_api_type_pkg.t_param_tab;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
begin
    l_reg_event_type  := evt_api_shared_data_pkg.get_param_char('EVENT_OBJECT_TYPE');
    l_entity_type     := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id       := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_orig_party_type := evt_api_shared_data_pkg.get_param_char('ORIGINAL_PARTY_TYPE');
    l_inst_id         := evt_api_shared_data_pkg.get_param_num ('INST_ID');
    l_split_hash      := evt_api_shared_data_pkg.get_param_num ('SPLIT_HASH');
    l_params          := evt_api_shared_data_pkg.g_params;
    
    if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
    
        select max(o.id)
          into l_oper_id
          from opr_participant p
             , opr_operation o
         where p.card_id = l_object_id
           and p.participant_type = l_orig_party_type
           and o.id = p.oper_id
           and o.status in (
                   opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                 , opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                 , opr_api_const_pkg.OPERATION_STATUS_PROCESSING
               )
           and not exists(select 1
                            from opr_operation r
                           where r.original_id = o.id
                             and r.is_reversal = com_api_const_pkg.TRUE
                             and r.status in (
                                     opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                                   , opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                                   , opr_api_const_pkg.OPERATION_STATUS_PROCESSING
                                 )
                         );
            
        if l_oper_id is not null then
            evt_api_event_pkg.register_event (
                i_event_type    => l_reg_event_type
              , i_eff_date      => com_api_sttl_day_pkg.get_sysdate
              , i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id     => l_oper_id
              , i_inst_id       => l_inst_id
              , i_split_hash    => l_split_hash
              , i_param_tab     => l_params
            );
        else
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'original remittance operation not found for card_id[#1] original_party[#2]'
              , i_env_param1 => l_object_id
              , i_env_param2 => l_orig_party_type
            );
        end if;
    else
        com_api_error_pkg.raise_error(
            i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => l_entity_type
        );
    end if;

end get_remittance_evt_process;

procedure create_reversal_from_original is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.create_reversal_from_original: ';
    l_oper                          opr_api_type_pkg.t_oper_rec;
    l_auth                          aut_api_type_pkg.t_auth_rec;
    l_participant_tab               opr_api_type_pkg.t_oper_part_by_type_tab;
    l_oper_reversal_id              com_api_type_pkg.t_long_id;
    l_entity_type                   com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
begin
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id   := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    
    if l_entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION then
        opr_api_operation_pkg.get_operation(
            i_oper_id   => l_object_id
          , o_operation => l_oper
        );
        l_auth := aut_api_auth_pkg.get_auth(i_id => l_object_id);

        for pr in (select p.participant_type
                    from opr_participant p
                   where p.oper_id = l_object_id
                 )
        loop
            if pr.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then
                opr_api_operation_pkg.get_participant(
                    i_oper_id           => l_object_id
                  , i_participaint_type => com_api_const_pkg.PARTICIPANT_ISSUER
                  , o_participant       => l_participant_tab(com_api_const_pkg.PARTICIPANT_ISSUER)
                );
                l_participant_tab(com_api_const_pkg.PARTICIPANT_ISSUER).oper_id := null;
                trc_log_pkg.debug(
                    i_text       => LOG_PREFIX || 'finded participants [#2] for oper original [#1] card id [#3]'
                  , i_env_param1 => l_object_id
                  , i_env_param2 => com_api_const_pkg.PARTICIPANT_ISSUER
                  , i_env_param3 => l_participant_tab(com_api_const_pkg.PARTICIPANT_ISSUER).card_id
                );
            elsif pr.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER then
                opr_api_operation_pkg.get_participant(
                    i_oper_id           => l_object_id
                  , i_participaint_type => com_api_const_pkg.PARTICIPANT_ACQUIRER
                  , o_participant       => l_participant_tab(com_api_const_pkg.PARTICIPANT_ACQUIRER)
                );
                l_participant_tab(com_api_const_pkg.PARTICIPANT_ACQUIRER).oper_id := null;
                trc_log_pkg.debug(
                    i_text       => LOG_PREFIX || 'finded participants [#2] for oper original [#1]'
                  , i_env_param1 => l_object_id
                  , i_env_param2 => com_api_const_pkg.PARTICIPANT_ACQUIRER
                );
            elsif pr.participant_type = com_api_const_pkg.PARTICIPANT_DEST then
                opr_api_operation_pkg.get_participant(
                    i_oper_id           => l_object_id
                  , i_participaint_type => com_api_const_pkg.PARTICIPANT_DEST
                  , o_participant       => l_participant_tab(com_api_const_pkg.PARTICIPANT_DEST)
                );
                l_participant_tab(com_api_const_pkg.PARTICIPANT_DEST).oper_id := null;
                trc_log_pkg.debug(
                    i_text       => LOG_PREFIX || 'finded participants [#2] for oper original [#1] card id [#3]'
                  , i_env_param1 => l_object_id
                  , i_env_param2 => com_api_const_pkg.PARTICIPANT_DEST
                  , i_env_param3 => l_participant_tab(com_api_const_pkg.PARTICIPANT_DEST).card_id
                );
            end if;
        end loop;
        
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'start with oper original [#1] count of participants [#2]'
          , i_env_param1 => l_oper.id
          , i_env_param2 => l_participant_tab.count
        );
        
        opr_api_create_pkg.create_operation(
            io_oper_id                  => l_oper_reversal_id
          , i_is_reversal               => com_api_const_pkg.TRUE
          , i_original_id               => l_oper.id
          , i_oper_type                 => l_oper.oper_type
          , i_oper_reason               => l_oper.oper_reason
          , i_msg_type                  => l_oper.msg_type
          , i_status                    => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
          , i_status_reason             => l_oper.status_reason
          , i_sttl_type                 => l_oper.sttl_type
          , i_terminal_type             => l_oper.terminal_type
          , i_acq_inst_bin              => l_oper.acq_inst_bin
          , i_forw_inst_bin             => l_oper.forw_inst_bin
          , i_merchant_number           => l_oper.merchant_number
          , i_terminal_number           => l_oper.terminal_number
          , i_merchant_name             => l_oper.merchant_name
          , i_merchant_street           => l_oper.merchant_street
          , i_merchant_city             => l_oper.merchant_city
          , i_merchant_region           => l_oper.merchant_region
          , i_merchant_country          => l_oper.merchant_country
          , i_merchant_postcode         => l_oper.merchant_postcode
          , i_mcc                       => l_oper.mcc
          , i_oper_count                => l_oper.oper_count
          , i_oper_request_amount       => l_oper.oper_request_amount
          , i_oper_amount_algorithm     => l_oper.oper_amount_algorithm
          , i_oper_amount               => l_oper.oper_amount
          , i_oper_currency             => l_oper.oper_currency
          , i_oper_cashback_amount      => l_oper.oper_cashback_amount
          , i_oper_replacement_amount   => l_oper.oper_replacement_amount
          , i_oper_surcharge_amount     => l_oper.oper_surcharge_amount
          , i_oper_date                 => l_oper.oper_date
          , i_host_date                 => l_oper.host_date
          , i_sttl_amount               => l_oper.sttl_amount
          , i_sttl_currency             => l_oper.sttl_currency
          , i_dispute_id                => l_oper.dispute_id
          , i_payment_order_id          => l_oper.payment_order_id
          , i_payment_host_id           => l_oper.payment_host_id
          , i_forced_processing         => com_api_const_pkg.FALSE
          , i_proc_mode                 => l_oper.proc_mode
          , io_participants             => l_participant_tab
          , i_sttl_date                 => l_oper.sttl_date
          , i_acq_sttl_date             => l_oper.acq_sttl_date
        );
        
        l_auth.id                   := l_oper_reversal_id;
        l_auth.is_reversal          := com_api_const_pkg.TRUE;
        l_auth.forced_processing    := com_api_const_pkg.FALSE;
        l_auth.external_orig_id     := l_auth.external_auth_id;
        l_auth.external_auth_id     := null;

        aut_api_auth_pkg.save_auth(i_auth => l_auth);

        aup_api_tag_pkg.copy_tag_value(
            i_source_auth_id  => l_oper.id
          , i_target_auth_id  => l_oper_reversal_id
        );

        opr_api_operation_pkg.get_operation(
            i_oper_id   => l_oper_reversal_id
          , o_operation => opr_api_shared_data_pkg.g_operation
        );
        for pr in (select p.participant_type
                    from opr_participant p
                   where p.oper_id = l_oper_reversal_id
                 )
        loop 
            if pr.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then
                opr_api_operation_pkg.get_participant(
                    i_oper_id           => l_oper_reversal_id
                  , i_participaint_type => com_api_const_pkg.PARTICIPANT_ISSUER
                  , o_participant       => opr_api_shared_data_pkg.g_iss_participant
                );
            elsif pr.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER then
                opr_api_operation_pkg.get_participant(
                    i_oper_id           => l_oper_reversal_id
                  , i_participaint_type => com_api_const_pkg.PARTICIPANT_ACQUIRER
                  , o_participant       => opr_api_shared_data_pkg.g_acq_participant
                );
            elsif pr.participant_type = com_api_const_pkg.PARTICIPANT_DEST then
                opr_api_operation_pkg.get_participant(
                    i_oper_id           => l_oper_reversal_id
                  , i_participaint_type => com_api_const_pkg.PARTICIPANT_DEST
                  , o_participant       => opr_api_shared_data_pkg.g_dst_participant
                );
            end if;
        end loop;
        opr_api_shared_data_pkg.g_auth := aut_api_auth_pkg.get_auth(i_id => l_oper_reversal_id);
    else
        com_api_error_pkg.raise_error(
            i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => l_entity_type
        );
    end if;
        
end create_reversal_from_original;

end cst_bof_api_rule_proc_pkg;
/
