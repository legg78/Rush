create or replace package body cst_smt_api_rule_proc_pkg is
/*********************************************************
 *  API for custom rules processing <br />
 *  Created by Gogolev I.(i.gogolev@bpcbt.com)  at 03.12.2018 <br />
 *  Module: CST_SMT_API_RULE_PROC_PKG <br />
 *  @headcom
 **********************************************************/

procedure set_oper_status_evt_processing is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.set_oper_status_evt_processing: ';
    l_oper                          opr_api_type_pkg.t_oper_rec;
    l_oper_status_new               com_api_type_pkg.t_dict_value;
    l_entity_type                   com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
begin
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id   := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    
    if l_entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION then
        opr_api_operation_pkg.get_operation(
            i_oper_id   => l_object_id
          , o_operation => opr_api_shared_data_pkg.g_operation
        );
        
        l_oper := opr_api_shared_data_pkg.get_operation;

        l_oper_status_new := opr_api_shared_data_pkg.get_param_char('OPERATION_STATUS');
        
        if l_oper_status_new <> l_oper.status then
            opr_api_shared_data_pkg.set_operation_status(
                i_id        => l_oper.id
              , i_status    => l_oper_status_new
            );
            update opr_operation
               set status = opr_api_shared_data_pkg.g_operation.status
             where id = opr_api_shared_data_pkg.g_operation.id;
        else
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'status didn''t changed - old [#1] new [#2]'
              , i_env_param1 => l_oper.status
              , i_env_param2 => l_oper_status_new
            );
        end if;
    else
        com_api_error_pkg.raise_error(
            i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => l_entity_type
        );
    end if;

end set_oper_status_evt_processing;

procedure set_oper_stage_evt_processing is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.set_oper_stage_evt_processing: ';
    l_oper                          opr_api_type_pkg.t_oper_rec;
    l_oper_stage_new                com_api_type_pkg.t_dict_value;
    l_entity_type                   com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
begin
    
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id   := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    
    if l_entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION then
        
        opr_api_operation_pkg.get_operation(
            i_oper_id   => l_object_id
          , o_operation => opr_api_shared_data_pkg.g_operation
        );
        
        l_oper := opr_api_shared_data_pkg.get_operation;

        l_oper_stage_new := opr_api_shared_data_pkg.get_param_char('OPER_STAGE');
        
        if l_oper_stage_new <> l_oper.proc_stage or l_oper.proc_stage is null then
            opr_api_shared_data_pkg.set_operation_proc_stage(
                i_id            => l_oper.id
              , i_proc_stage    => l_oper_stage_new
            );
            
            opr_api_shared_data_pkg.set_param(
                i_name      => 'OPER_STAGE'
              , i_value     => opr_api_shared_data_pkg.g_operation.proc_stage
            );
            opr_api_shared_data_pkg.set_param(
                i_name      => 'ENTITY_TYPE'
              , i_value     => opr_api_const_pkg.ENTITY_TYPE_OPERATION
            );
            opr_api_shared_data_pkg.set_param(
                i_name      => 'OBJECT_ID'
              , i_value     => opr_api_shared_data_pkg.g_operation.id
            );
            opr_api_shared_data_pkg.set_param(
                i_name      => 'SPLIT_HASH'
              , i_value     => com_api_hash_pkg.get_split_hash(
                                   i_entity_type    => opr_api_const_pkg.ENTITY_TYPE_OPERATION 
                                 , i_object_id      => opr_api_shared_data_pkg.g_operation.id
                                 , i_mask_error     => com_api_const_pkg.TRUE
                               )
            );
            
            evt_api_rule_proc_pkg.add_oper_stage;
            
        else
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'proc stage didn''t changed - old [#1] new [#2]'
              , i_env_param1 => l_oper.proc_stage
              , i_env_param2 => l_oper_stage_new
            );
        end if;
    else
        com_api_error_pkg.raise_error(
            i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => l_entity_type
        );
    end if;

end set_oper_stage_evt_processing;

procedure set_oper_status_opr_processing is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.set_oper_status_opr_processing: ';
    l_oper                          opr_api_type_pkg.t_oper_rec;
    l_oper_status_new               com_api_type_pkg.t_dict_value;
begin
    l_oper := opr_api_shared_data_pkg.get_operation;

    l_oper_status_new := opr_api_shared_data_pkg.get_param_char('OPERATION_STATUS');
        
    if l_oper_status_new <> l_oper.status then
            
        opr_api_shared_data_pkg.set_operation_status(
            i_id        => l_oper.id
          , i_status    => l_oper_status_new
        );

    else
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'status didn''t changed - old [#1] new [#2]'
          , i_env_param1 => l_oper.status
          , i_env_param2 => l_oper_status_new
        );
    end if;

end set_oper_status_opr_processing;

procedure set_oper_stage_opr_processing is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.set_oper_stage_opr_processing: ';
    l_oper                          opr_api_type_pkg.t_oper_rec;
    l_oper_stage_new                com_api_type_pkg.t_dict_value;
begin
            
    l_oper := opr_api_shared_data_pkg.get_operation;

    l_oper_stage_new := opr_api_shared_data_pkg.get_param_char('OPER_STAGE');
        
    if l_oper_stage_new <> l_oper.proc_stage or l_oper.proc_stage is null then
        opr_api_shared_data_pkg.set_operation_proc_stage(
            i_id            => l_oper.id
          , i_proc_stage    => l_oper_stage_new
        );
            
    else
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'proc stage didn''t changed - old [#1] new [#2]'
          , i_env_param1 => l_oper.proc_stage
          , i_env_param2 => l_oper_stage_new
        );
    end if;

end set_oper_stage_opr_processing;

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
        if opr_api_shared_data_pkg.g_operation.id is null then
            opr_api_operation_pkg.get_operation(
                i_oper_id   => l_object_id
              , o_operation => opr_api_shared_data_pkg.g_operation
            );
        end if;
        if opr_api_shared_data_pkg.g_auth.id is null then
            opr_api_shared_data_pkg.g_auth := aut_api_auth_pkg.get_auth(i_id => l_object_id);
        end if;
        if opr_api_shared_data_pkg.g_iss_participant.oper_id is null then
            opr_api_operation_pkg.get_participant(
                i_oper_id           => l_object_id
              , i_participaint_type => com_api_const_pkg.PARTICIPANT_ISSUER
              , o_participant       => opr_api_shared_data_pkg.g_iss_participant
            );
        end if;
        if opr_api_shared_data_pkg.g_acq_participant.oper_id is null then
            opr_api_operation_pkg.get_participant(
                i_oper_id           => l_object_id
              , i_participaint_type => com_api_const_pkg.PARTICIPANT_ACQUIRER
              , o_participant       => opr_api_shared_data_pkg.g_acq_participant
            );
        end if;
        
        l_oper := opr_api_shared_data_pkg.g_operation;
        l_auth := opr_api_shared_data_pkg.g_auth;
        
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'start with oper original [#1] card number [#2] auth code [#3] acq network [#4] merchant id [#5] external auth id [#6]'
          , i_env_param1 => l_oper.id
          , i_env_param2 => opr_api_shared_data_pkg.g_iss_participant.card_number
          , i_env_param3 => opr_api_shared_data_pkg.g_iss_participant.auth_code
          , i_env_param4 => opr_api_shared_data_pkg.g_acq_participant.acq_network_id
          , i_env_param5 => opr_api_shared_data_pkg.g_acq_participant.merchant_id
          , i_env_param6 => l_auth.external_auth_id
        );
        
        l_participant_tab(com_api_const_pkg.PARTICIPANT_ISSUER)   := opr_api_shared_data_pkg.g_iss_participant;
        l_participant_tab(com_api_const_pkg.PARTICIPANT_ACQUIRER) := opr_api_shared_data_pkg.g_acq_participant;
        
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

        opr_api_operation_pkg.get_participant(
            i_oper_id           => l_oper_reversal_id
          , i_participaint_type => com_api_const_pkg.PARTICIPANT_ISSUER
          , o_participant       => opr_api_shared_data_pkg.g_iss_participant
        );

        opr_api_operation_pkg.get_participant(
            i_oper_id           => l_oper_reversal_id
          , i_participaint_type => com_api_const_pkg.PARTICIPANT_ACQUIRER
          , o_participant       => opr_api_shared_data_pkg.g_acq_participant
        );

        opr_api_shared_data_pkg.g_auth := aut_api_auth_pkg.get_auth(i_id => l_oper_reversal_id);
    else
        com_api_error_pkg.raise_error(
            i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => l_entity_type
        );
    end if;
        
end create_reversal_from_original;

procedure generate_arn
is
    l_arn com_api_type_pkg.t_arn;
    l_tags aup_api_type_pkg.t_aup_tag_tab;
begin
    
    
    l_arn := acq_api_merchant_pkg.get_arn(
        i_acquirer_bin => opr_api_shared_data_pkg.g_operation.acq_inst_bin
        , i_proc_date  => opr_api_shared_data_pkg.g_operation.oper_date
    );
    
    l_tags(1).tag_id    := aup_api_tag_pkg.find_tag_by_reference(cst_smt_api_const_pkg.TAG_ARN);
    l_tags(1).tag_value := l_arn;
    
    aup_api_tag_pkg.save_tag(
        i_auth_id => opr_api_shared_data_pkg.g_operation.id
      , i_tags    => l_tags
    );
 
end;

end;
/
