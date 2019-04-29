create or replace package body csm_ui_case_pkg as
/**************************************************
 *  Dispute application UI API <br />
 *  Renamed CSM_UI_DISPUTE_PKG (Created by Truschelev O.(truschelev@bpcbt.com) at 10.03.2017) <br />
 *  Module: CSM_UI_CASE_PKG <br />
 *  @headcom
 ***************************************************/

procedure get_default_manual_application(
    o_appl_id                         out com_api_type_pkg.t_long_id
  , o_created_date                    out date
  , o_created_by_user_id              out com_api_type_pkg.t_short_id
  , o_case_owner                      out com_api_type_pkg.t_short_id
  , o_case_id                         out com_api_type_pkg.t_long_id
  , o_claim_id                        out com_api_type_pkg.t_long_id
  , o_reject_code                     out com_api_type_pkg.t_dict_value
  , o_appl_status                     out com_api_type_pkg.t_dict_value
  , o_is_visible                      out com_api_type_pkg.t_boolean
  , o_team_id                         out com_api_type_pkg.t_tiny_id
)
is
begin
    o_created_date       := com_api_sttl_day_pkg.get_sysdate;
    o_appl_id            := com_api_id_pkg.get_id(app_application_seq.nextval, o_created_date);
    o_created_by_user_id := com_ui_user_env_pkg.get_user_id;
    o_case_owner         := o_created_by_user_id;
    o_case_id            := com_api_id_pkg.get_id(app_application_seq.nextval, com_api_sttl_day_pkg.get_sysdate);
    o_claim_id           := com_api_id_pkg.get_id(app_application_seq.nextval, com_api_sttl_day_pkg.get_sysdate);
    o_is_visible         := com_api_const_pkg.TRUE;
    o_appl_status        := app_api_const_pkg.APPL_STATUS_PENDING;
    o_reject_code        := app_api_const_pkg.APPL_REJECT_CODE_UNRESOLVED;
    o_team_id            := csm_api_const_pkg.CASE_CHARGEBACK_TEAM;

    trc_log_pkg.debug(
        i_text        => 'get_default_manual_application: o_appl_id [#1] o_created_date [#2] o_created_by_user_id [#3] case_owner [#4] o_case_id[#5] o_claim_id[#6]'
      , i_env_param1  => o_appl_id
      , i_env_param2  => o_created_date
      , i_env_param3  => o_created_by_user_id
      , i_env_param4  => o_case_owner
      , i_env_param5  => o_case_id
      , i_env_param6  => o_claim_id
    );
    trc_log_pkg.debug(
        i_text        => 'get_default_manual_application: o_appl_id [#1] o_reject_code [#2] o_appl_status [#3] o_is_visible [#4] o_team_id[#5]'
      , i_env_param1  => o_appl_id
      , i_env_param2  => o_reject_code
      , i_env_param3  => o_appl_status
      , i_env_param4  => o_is_visible
      , i_env_param5  => o_team_id
   );
end get_default_manual_application;

procedure assign_fin_msg_dispute_id(
    i_id                            in     com_api_type_pkg.t_long_id
  , i_dispute_id                    in     com_api_type_pkg.t_long_id
) as
begin
    update vis_fin_message
       set dispute_id = i_dispute_id
     where id = i_id;
    
    update mcw_fin
       set dispute_id = i_dispute_id
     where id = i_id;

    update amx_fin_message
       set dispute_id = i_dispute_id
     where id = i_id;

end assign_fin_msg_dispute_id;

function get_agent_id(
    i_card_number              in     com_api_type_pkg.t_card_number
  , i_inst_id                  in     com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_agent_id is
    l_card_hash     com_api_type_pkg.t_long_id;
    l_card_number   com_api_type_pkg.t_card_number;
    l_agent_id      com_api_type_pkg.t_agent_id;
begin
    l_card_hash     := com_api_hash_pkg.get_card_hash(i_card_number);
    l_card_number   := iss_api_token_pkg.encode_card_number(i_card_number => i_card_number);
            
    select p.agent_id
      into l_agent_id
      from iss_card c
         , iss_card_number cn
         , prd_contract p
     where c.id                    = cn.card_id
       and c.card_hash             = l_card_hash
       and reverse(cn.card_number) = reverse(l_card_number)
       and c.contract_id           = p.id
       and c.split_hash            = p.split_hash;

    return l_agent_id;
exception
    when no_data_found then
        l_agent_id := ost_api_institution_pkg.get_default_agent(i_inst_id => i_inst_id);
        return l_agent_id;
end get_agent_id;

/*
 * Procedure creates a dispute application (case) for a dispute operation;
 * operation's participant type defines if it will be an issuing dispute case or an acquring one.
 */
procedure create_manual_application(
    io_appl_id                     in out com_api_type_pkg.t_long_id
  , io_seqnum                      in out com_api_type_pkg.t_seqnum
  , i_inst_id                      in     com_api_type_pkg.t_inst_id
  , i_merchant_name                in     com_api_type_pkg.t_name
  , i_customer_number              in     com_api_type_pkg.t_name
  , i_dispute_reason               in     com_api_type_pkg.t_dict_value
  , i_oper_date                    in     date
  , i_oper_amount                  in     com_api_type_pkg.t_money
  , i_oper_currency                in     com_api_type_pkg.t_curr_code
  , i_dispute_id                   in     com_api_type_pkg.t_long_id
  , i_dispute_progress             in     com_api_type_pkg.t_dict_value
  , i_write_off_amount             in     com_api_type_pkg.t_money
  , i_write_off_currency           in     com_api_type_pkg.t_curr_code
  , i_due_date                     in     date
  , i_reason_code                  in     com_api_type_pkg.t_dict_value
  , i_disputed_amount              in     com_api_type_pkg.t_money
  , i_disputed_currency            in     com_api_type_pkg.t_curr_code
  , i_created_date                 in     date
  , i_created_by_user_id           in     com_api_type_pkg.t_short_id
  , i_arn                          in     com_api_type_pkg.t_card_number
  , i_claim_id                     in     com_api_type_pkg.t_long_id       default null
  , i_auth_code                    in     com_api_type_pkg.t_auth_code
  , i_case_progress                in     com_api_type_pkg.t_dict_value
  , i_acquirer_inst_bin            in     com_api_type_pkg.t_cmid
  , i_transaction_code             in     com_api_type_pkg.t_cmid
  , i_case_source                  in     com_api_type_pkg.t_dict_value
  , i_sttl_amount                  in     com_api_type_pkg.t_money
  , i_sttl_currency                in     com_api_type_pkg.t_curr_code
  , i_base_amount                  in     com_api_type_pkg.t_money
  , i_base_currency                in     com_api_type_pkg.t_curr_code
  , i_hide_date                    in     date
  , i_unhide_date                  in     date
  , i_team_id                      in     com_api_type_pkg.t_tiny_id
  , i_card_number                  in     com_api_type_pkg.t_card_number
  , i_flow_id                      in     com_api_type_pkg.t_tiny_id
  , i_agent_id                     in     com_api_type_pkg.t_short_id
  , i_duplicated_from_case_id      in     com_api_type_pkg.t_long_id       default null
  , i_ext_claim_id                 in     com_api_type_pkg.t_attr_name     default null
  , i_network_id                   in     com_api_type_pkg.t_network_id    default null
) is
    LOG_PREFIX               constant     com_api_type_pkg.t_name          := lower($$PLSQL_UNIT) || '.create_manual_application ';
    l_application                         app_api_type_pkg.t_application_rec;
    l_agent_id                            com_api_type_pkg.t_agent_id;
    l_appl_data                           app_data_tpt;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' Start: io_appl_id [#1]'
      , i_env_param1 => io_appl_id
    );

    if i_inst_id is null or i_flow_id is null then
        com_api_error_pkg.raise_error(
            i_error      => 'REQUIRED_PARAMETER_IS_NOT_SPECIFIED'
          , i_env_param1 => i_inst_id
          , i_env_param2 => i_flow_id
        );
    end if;

    l_application.id       := io_appl_id;
    l_application.flow_id  := i_flow_id;
    
    l_agent_id := i_agent_id;

    app_ui_flow_stage_pkg.get_initial_stage(
        i_flow_id      => l_application.flow_id
      , o_appl_status  => l_application.appl_status
      , o_reject_code  => l_application.reject_code
    );

    trc_log_pkg.debug(
        i_text       => 'Creating l_application = flow_id [#1], appl_status [#2], reject_code [#3]'
      , i_env_param1 => l_application.flow_id
      , i_env_param2 => l_application.appl_status
      , i_env_param3 => l_application.reject_code
    );
    
    if l_agent_id is null then
        l_agent_id := get_agent_id(
                          i_card_number => i_card_number
                        , i_inst_id     => i_inst_id
                      );
    end if;
    
    app_ui_application_pkg.add_application(
        i_context_mode     => null
      , io_appl_id         => l_application.id
      , o_seqnum           => io_seqnum
      , i_appl_type        => app_api_const_pkg.APPL_TYPE_DISPUTE
      , i_appl_number      => null
      , i_flow_id          => l_application.flow_id
      , i_inst_id          => i_inst_id
      , i_agent_id         => l_agent_id
      , i_appl_status      => l_application.appl_status
      , i_session_file_id  => null
      , i_file_rec_num     => null
      , i_customer_type    => null
      , i_reject_code      => l_application.reject_code
      , i_user_id          => com_ui_user_env_pkg.get_user_id
      , i_is_visible       => com_api_const_pkg.TRUE
      , i_customer_number  => i_customer_number
      , i_appl_data        => l_appl_data
    );

    trc_log_pkg.debug('New l_application.id [' || l_application.id || ']; i_dispute_id [' || i_dispute_id || ']');
    io_appl_id := l_application.id;

    csm_api_case_pkg.add_case(
        i_case_id              => l_application.id
      , i_seqnum               => io_seqnum
      , i_inst_id              => i_inst_id
      , i_merchant_name        => i_merchant_name
      , i_customer_number      => i_customer_number
      , i_dispute_reason       => i_dispute_reason
      , i_oper_date            => i_oper_date
      , i_oper_amount          => i_oper_amount
      , i_oper_currency        => i_oper_currency
      , i_dispute_id           => i_dispute_id
      , i_dispute_progress     => i_dispute_progress
      , i_write_off_amount     => i_write_off_amount
      , i_write_off_currency   => i_write_off_currency
      , i_due_date             => i_due_date
      , i_reason_code          => i_reason_code
      , i_disputed_amount      => i_disputed_amount
      , i_disputed_currency    => i_disputed_currency
      , i_created_date         => i_created_date
      , i_created_by_user_id   => i_created_by_user_id
      , i_arn                  => i_arn
      , i_claim_id             => i_claim_id
      , i_auth_code            => i_auth_code
      , i_case_progress        => i_case_progress
      , i_acquirer_inst_bin    => i_acquirer_inst_bin
      , i_transaction_code     => i_transaction_code
      , i_case_source          => i_case_source
      , i_sttl_amount          => i_sttl_amount
      , i_sttl_currency        => i_sttl_currency
      , i_base_amount          => i_base_amount
      , i_base_currency        => i_base_currency
      , i_hide_date            => i_hide_date
      , i_unhide_date          => i_unhide_date
      , i_team_id              => i_team_id
      , i_card_number          => i_card_number
      , i_original_id          => null
      , i_ext_claim_id         => i_ext_claim_id
      , i_network_id           => i_network_id
    );
    
    -- Add history
    csm_api_case_pkg.add_history(
        i_case_id         => l_application.id
      , i_action          => csm_api_const_pkg.CASE_ACTION_CREATE_LABEL
      , i_event_type      => dsp_api_const_pkg.EVENT_DISPUTE_CASE_REGISTERED
      , i_new_appl_status => l_application.appl_status
      , i_old_appl_status => l_application.appl_status
      , i_new_reject_code => l_application.reject_code
      , i_old_reject_code => l_application.reject_code
      , i_env_param1      => l_application.id
    );

    if i_duplicated_from_case_id is not null then
      csm_api_case_pkg.add_history(
          i_case_id         => l_application.id
        , i_action          => csm_api_const_pkg.CASE_ACTION_DUPLICATE_LABEL
        , i_event_type      => dsp_api_const_pkg.EVENT_DISPUTE_CASE_DUPLICATED
        , i_new_appl_status => l_application.appl_status
        , i_old_appl_status => l_application.appl_status
        , i_new_reject_code => l_application.reject_code
        , i_old_reject_code => l_application.reject_code
        , i_env_param1      => to_char(trunc(get_sysdate), 'DD.MM.YYYY')
        , i_env_param2      => i_duplicated_from_case_id
        , i_mask_error      => com_api_const_pkg.FALSE
      );
    end if;

    if i_claim_id is not null then
        app_ui_application_pkg.documents_copy(
            i_appl_id_from => i_claim_id
          , i_appl_id_to   => l_application.id
        );
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ': io_appl_id [' || io_appl_id || ']'
    );

exception
    when com_api_error_pkg.e_application_error
      or com_api_error_pkg.e_fatal_error
    then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED: io_appl_id [' || io_appl_id || ']'
        );
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end create_manual_application;

/*
 * Procedure creates a dispute application (case) for a dispute operation;
 * operation's participant type defines if it will be an issuing dispute case or an acquring one.
 */
procedure create_application(
    i_oper_id                      in     com_api_type_pkg.t_long_id
  , i_participant_type             in     com_api_type_pkg.t_dict_value
  , o_appl_id                         out com_api_type_pkg.t_long_id
  , i_unpaired_oper_id             in     com_api_type_pkg.t_long_id       := null
  , i_dispute_reason               in     com_api_type_pkg.t_dict_value    := null
  , i_claim_id                     in     com_api_type_pkg.t_long_id       := null
  , i_ext_claim_id                 in     com_api_type_pkg.t_attr_name     := null
  , i_ext_clearing_trans_id        in     com_api_type_pkg.t_name          := null
  , i_ext_auth_trans_id            in     com_api_type_pkg.t_name          := null
) is
    LOG_PREFIX               constant     com_api_type_pkg.t_name          := lower($$PLSQL_UNIT) || '.create_application ';
    l_operation                           opr_api_type_pkg.t_oper_rec;
    l_participant                         opr_api_type_pkg.t_oper_part_rec;
    l_issuer_participant                  opr_api_type_pkg.t_oper_part_rec;
    l_application                         app_api_type_pkg.t_application_rec;
    l_seqnum                              com_api_type_pkg.t_tiny_id;
    l_dispute_id                          com_api_type_pkg.t_long_id;
    l_reason_code                         com_api_type_pkg.t_name;
    l_case_source                         com_api_type_pkg.t_dict_value;
    l_customer_number                     com_api_type_pkg.t_name;
    l_merchant_name                       com_api_type_pkg.t_name;
    l_arn                                 com_api_type_pkg.t_card_number;
    l_transaction_code                    com_api_type_pkg.t_cmid;
    l_appl_data                           app_data_tpt;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' Start: i_oper_id [#1], i_participant_type [#2] i_unpaired_oper_id [#3] i_dispute_reason [#4] i_claim_id [#5]'
      , i_env_param1 => i_oper_id
      , i_env_param2 => i_participant_type
      , i_env_param3 => i_unpaired_oper_id
      , i_env_param4 => i_dispute_reason
      , i_env_param5 => i_claim_id
    );

    opr_api_operation_pkg.get_operation(
        i_oper_id           => i_oper_id
      , o_operation         => l_operation
    );

    if l_operation.dispute_id is not null then
        com_api_error_pkg.raise_error(
            i_error      => 'DISPUTE_ALREADY_EXIST'
          , i_env_param1 => l_operation.dispute_id
        );
    end if;
    
    opr_api_operation_pkg.get_participant(
        i_oper_id           => i_oper_id
      , i_participaint_type => i_participant_type
      , o_participant       => l_participant
    );

    if i_participant_type != com_api_const_pkg.PARTICIPANT_ISSUER then
        opr_api_operation_pkg.get_participant(
            i_oper_id           => i_oper_id
          , i_participaint_type => com_api_const_pkg.PARTICIPANT_ISSUER
          , o_participant       => l_issuer_participant
        );
        
        l_participant.card_number := l_issuer_participant.card_number;
    end if;

    -- Reason code, Settlement amount/Settlement currency
    if i_unpaired_oper_id is not null then
        select oo.sttl_amount
             , oo.sttl_currency
             , coalesce(mf.de025, vf.reason_code, af.reason_code) as reason_code
             , coalesce(mf.de031, vf.arn, af.arn) as arn
             , coalesce(mf.de024, vf.trans_code, af.func_code) as transaction_code
          into l_operation.sttl_amount
             , l_operation.sttl_currency
             , l_reason_code
             , l_arn
             , l_transaction_code
          from opr_operation oo
               left outer join mcw_fin mf         on oo.id = mf.id
               left outer join vis_fin_message vf on oo.id = vf.id
               left outer join amx_fin_message af on oo.id = af.id
         where oo.id = i_unpaired_oper_id;

        l_case_source := csm_api_const_pkg.CASE_SOURCE_UNPAIRED_ITEM;
    else
        l_case_source := csm_api_const_pkg.CASE_SOURCE_ORIGINAL_TRANS;
    end if;

    trc_log_pkg.debug(
        i_text       => 'l_operation = {'
                     ||    'merchant_country ['  || l_operation.merchant_country
                     || ']; oper_amount ['       || l_operation.oper_amount
                     || ']; oper_currency ['     || l_operation.oper_currency
                     || ']; sttl_amount ['       || l_operation.sttl_amount
                     || ']; sttl_currency ['     || l_operation.sttl_currency
                     || ']; oper_date [' || to_char(l_operation.oper_date, com_api_const_pkg.LOG_DATE_FORMAT)
                     || ']; merchant_name ['     || l_operation.merchant_name
                     || ']}'
                     || ', l_participant = {'
                     ||    'customer_id ['       || l_participant.customer_id
                     || ']; inst_id ['           || l_participant.inst_id
                     || ']; card_country ['      || l_participant.card_country
                     || ']; card_number [#1]'
                     ||  '; account_id ['        || l_participant.account_id
                     || ']; merchant_id ['       || l_participant.merchant_id      || ']}'
                     || ', l_reason_code ['      || l_reason_code                  || ']'
      , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number => l_participant.card_number)
    );

    l_application.flow_id := csm_api_case_pkg.get_flow_id(
        i_sttl_type => l_operation.sttl_type
    );        

    if l_application.flow_id is null then
        com_api_error_pkg.raise_error(
            i_error      => 'IMPOSSIBLE_TO_DEFINE_DISPUTE_APPLICATION_FLOW'
          , i_env_param1 => l_operation.id
          , i_env_param2 => l_operation.merchant_country
          , i_env_param3 => l_participant.participant_type
          , i_env_param4 => l_participant.card_country
        );
    end if;

    app_ui_flow_stage_pkg.get_initial_stage(
        i_flow_id      => l_application.flow_id
      , o_appl_status  => l_application.appl_status
      , o_reject_code  => l_application.reject_code
    );

    trc_log_pkg.debug(
        i_text       => 'Creating l_application = flow_id [#1], appl_status [#2], reject_code [#3]'
      , i_env_param1 => l_application.flow_id
      , i_env_param2 => l_application.appl_status
      , i_env_param3 => l_application.reject_code
    );

    -- Add to the element list some optional elements
    if l_participant.customer_id is not null then
        l_customer_number     := prd_api_customer_pkg.get_customer_number(
                                     i_customer_id    => l_participant.customer_id
                                   , i_inst_id        => l_participant.inst_id
                                   , i_mask_error     => com_api_type_pkg.FALSE
                                 );
    end if;

    if  l_operation.merchant_name is not null
        or
        l_participant.merchant_id is not null
    then
        l_merchant_name      := coalesce(
                                     l_operation.merchant_name
                                   , acq_api_merchant_pkg.get_merchant_name(
                                         i_merchant_id  => l_participant.merchant_id
                                       , i_mask_error   => com_api_const_pkg.FALSE
                                     )
                                 );
    end if;

    app_ui_application_pkg.add_application(
        i_context_mode     => null
      , io_appl_id         => l_application.id
      , o_seqnum           => l_seqnum
      , i_appl_type        => app_api_const_pkg.APPL_TYPE_DISPUTE
      , i_appl_number      => null
      , i_flow_id          => l_application.flow_id
      , i_inst_id          => l_participant.inst_id
      , i_agent_id         => ost_api_institution_pkg.get_default_agent(i_inst_id => l_participant.inst_id)
      , i_appl_status      => l_application.appl_status
      , i_session_file_id  => null
      , i_file_rec_num     => null
      , i_customer_type    => null
      , i_reject_code      => l_application.reject_code
      , i_is_visible       => com_api_const_pkg.TRUE
      , i_user_id          => com_ui_user_env_pkg.get_user_id
      , i_customer_number  => l_customer_number
      , i_appl_data        => l_appl_data
    );

    -- Create a list of mandatory elements
    dsp_ui_process_pkg.initiate_dispute(
        i_oper_id          => l_operation.id
      , o_dispute_id       => l_dispute_id
    );
    
    assign_fin_msg_dispute_id(
        i_id           => l_operation.id
      , i_dispute_id   => l_dispute_id
    );

    trc_log_pkg.debug('New l_application.id [' || l_application.id || ']; l_dispute_id [' || l_dispute_id || ']');

    if i_unpaired_oper_id is not null then
        update csm_unpaired_item
           set is_unpaired_item = null
         where id = i_unpaired_oper_id;
    end if;        

    csm_api_case_pkg.add_case(
        i_case_id                => l_application.id
      , i_seqnum                 => l_seqnum
      , i_inst_id                => l_participant.inst_id
      , i_merchant_name          => l_merchant_name
      , i_customer_number        => l_customer_number
      , i_dispute_reason         => i_dispute_reason
      , i_oper_date              => l_operation.oper_date
      , i_oper_amount            => l_operation.oper_amount
      , i_oper_currency          => l_operation.oper_currency
      , i_dispute_id             => l_dispute_id
      , i_dispute_progress       => null
      , i_write_off_amount       => null
      , i_write_off_currency     => null
      , i_due_date               => null
      , i_reason_code            => l_reason_code
      , i_disputed_amount        => case
                                        when l_application.flow_id in (app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_DOMESTIC, app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_INTERNTNL)
                                            then l_operation.sttl_amount
                                        when l_application.flow_id in (app_api_const_pkg.FLOW_ID_ISS_DISPUTE_DOMESTIC, app_api_const_pkg.FLOW_ID_ISS_DISPUTE_INTERNTNL)
                                            then l_operation.oper_amount
                                        else
                                            l_operation.oper_amount
                                    end
      , i_disputed_currency      => case
                                        when l_application.flow_id in (app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_DOMESTIC, app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_INTERNTNL)
                                            then l_operation.sttl_currency
                                        when l_application.flow_id in (app_api_const_pkg.FLOW_ID_ISS_DISPUTE_DOMESTIC, app_api_const_pkg.FLOW_ID_ISS_DISPUTE_INTERNTNL)
                                             then l_operation.oper_currency
                                        else
                                            l_operation.oper_currency
                                    end
      , i_created_date           => com_api_sttl_day_pkg.get_sysdate()
      , i_created_by_user_id     => com_ui_user_env_pkg.get_user_id()
      , i_arn                    => l_arn
      , i_claim_id               => i_claim_id
      , i_auth_code              => l_participant.auth_code
      , i_case_progress          => csm_api_const_pkg.CASE_PROGRESS_PRESENTMENT
      , i_acquirer_inst_bin      => l_operation.acq_inst_bin
      , i_transaction_code       => l_transaction_code
      , i_case_source            => l_case_source
      , i_sttl_amount            => case
                                        when l_application.flow_id in (app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_DOMESTIC, app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_INTERNTNL)
                                            then l_operation.sttl_amount
                                        when l_application.flow_id in (app_api_const_pkg.FLOW_ID_ISS_DISPUTE_DOMESTIC, app_api_const_pkg.FLOW_ID_ISS_DISPUTE_INTERNTNL)
                                            then null
                                        else
                                            l_operation.sttl_amount
                                    end
      , i_sttl_currency          => case
                                        when l_application.flow_id in (app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_DOMESTIC, app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_INTERNTNL)
                                            then l_operation.sttl_currency
                                        when l_application.flow_id in (app_api_const_pkg.FLOW_ID_ISS_DISPUTE_DOMESTIC, app_api_const_pkg.FLOW_ID_ISS_DISPUTE_INTERNTNL)
                                            then null
                                        else
                                            l_operation.sttl_currency
                                    end
      , i_base_amount            => null
      , i_base_currency          => null
      , i_hide_date              => null
      , i_unhide_date            => null
      , i_team_id                => null
      , i_card_number            => l_participant.card_number
      , i_original_id            => i_oper_id
      , i_network_id             =>    case i_participant_type when com_api_const_pkg.PARTICIPANT_ISSUER
                                           then l_participant.card_network_id
                                        when com_api_const_pkg.PARTICIPANT_ACQUIRER
                                            then l_participant.network_id 
                                        else 
                                             null
                                    end
      , i_ext_claim_id           => i_ext_claim_id
      , i_ext_clearing_trans_id  => i_ext_clearing_trans_id
      , i_ext_auth_trans_id      => i_ext_auth_trans_id
    );

    o_appl_id := l_application.id;
    
    -- Add history
    csm_api_case_pkg.add_history(
        i_case_id         => l_application.id
      , i_action          => csm_api_const_pkg.CASE_ACTION_CREATE_LABEL
      , i_event_type      => dsp_api_const_pkg.EVENT_DISPUTE_CASE_REGISTERED
      , i_new_appl_status => l_application.appl_status
      , i_old_appl_status => l_application.appl_status
      , i_new_reject_code => l_application.reject_code
      , i_old_reject_code => l_application.reject_code
      , i_env_param1      => l_application.id
    );

    if i_claim_id is not null then
        app_ui_application_pkg.documents_copy(
            i_appl_id_from => i_claim_id
          , i_appl_id_to   => l_application.id
        );
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ': Finish o_appl_id [' || o_appl_id || ']'
    ); 

exception
    when com_api_error_pkg.e_application_error
      or com_api_error_pkg.e_fatal_error
    then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED: l_application.id [' || l_application.id || ']'
        );
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end create_application;

procedure refuse_application_owner(
    i_appl_id                      in     com_api_type_pkg.t_long_id
  , io_seqnum                      in out com_api_type_pkg.t_tiny_id
) is

    LOG_PREFIX               constant     com_api_type_pkg.t_name          := lower($$PLSQL_UNIT) || '.refuse_application_owner: ';
    
    l_application_rec                     app_api_type_pkg.t_application_rec;
    
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START with i_appl_id [' || i_appl_id
                     || '] io_seqnum [' || io_seqnum
                     || ']'
    );
    
    l_application_rec := app_api_application_pkg.get_application(
                             i_appl_id        => i_appl_id
                           , i_raise_error    => com_api_type_pkg.TRUE
                         );
                         
    app_ui_application_pkg.modify_application(
        i_appl_id             => i_appl_id
      , io_seqnum             => io_seqnum
      , i_appl_status         => l_application_rec.appl_status
      , i_resp_sess_file_id   => l_application_rec.resp_file_id
      , i_change_action       => app_api_const_pkg.APPL_ACTION_REFUSE_OWNER
      , i_reject_code         => l_application_rec.reject_code
      , i_user_id             => acm_api_const_pkg.UNDEFINED_USER_ID
    );

exception               
    when com_api_error_pkg.e_application_error then
        
        raise;
        
    when com_api_error_pkg.e_fatal_error then
        
        raise;
        
    when others then
        
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
        
end refuse_application_owner;

procedure get_case(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , o_case_cur                        out sys_refcursor
) is
    l_case_rec                            csm_api_type_pkg.t_csm_case_rec;
begin
    csm_api_case_pkg.get_case(
        i_case_id    => i_case_id
      , o_case_rec   => l_case_rec
      , i_mask_error => com_api_const_pkg.FALSE
    );
    
    open o_case_cur for
    select l_case_rec.case_id               as case_id
         , l_case_rec.seqnum                as seqnum
         , l_case_rec.inst_id               as inst_id
         , l_case_rec.merchant_name         as merchant_name
         , l_case_rec.customer_number       as customer_number
         , l_case_rec.dispute_reason        as dispute_reason
         , l_case_rec.oper_date             as oper_date
         , l_case_rec.oper_amount           as oper_amount
         , l_case_rec.oper_currency         as oper_currency
         , l_case_rec.dispute_id            as dispute_id
         , l_case_rec.dispute_progress      as dispute_progress
         , l_case_rec.write_off_amount      as write_off_amount
         , l_case_rec.write_off_currency    as write_off_currency
         , l_case_rec.due_date              as due_date
         , l_case_rec.reason_code           as reason_code
         , l_case_rec.disputed_amount       as disputed_amount
         , l_case_rec.disputed_currency     as disputed_currency
         , l_case_rec.created_date          as created_date
         , l_case_rec.created_by_user_id    as created_by_user_id
         , l_case_rec.arn                   as arn
         , l_case_rec.claim_id              as claim_id
         , l_case_rec.auth_code             as auth_code
         , l_case_rec.case_progress         as case_progress
         , l_case_rec.acquirer_inst_bin     as acquirer_inst_bin
         , l_case_rec.transaction_code      as transaction_code
         , l_case_rec.case_source           as case_source
         , l_case_rec.sttl_amount           as sttl_amount
         , l_case_rec.sttl_currency         as sttl_currency
         , l_case_rec.base_amount           as base_amount
         , l_case_rec.base_currency         as base_currency
         , l_case_rec.hide_date             as hide_date
         , l_case_rec.unhide_date           as unhide_date
         , l_case_rec.team_id               as team_id
         , l_case_rec.card_id               as card_id
         , l_case_rec.merchant_id           as merchant_id
         , l_case_rec.is_visible            as is_visible
         , l_case_rec.case_status           as case_status
         , l_case_rec.case_resolution       as case_resolution
         , l_case_rec.flow_id               as flow_id
         , l_case_rec.split_hash            as split_hash
         , l_case_rec.original_id           as original_id
         , l_case_rec.ext_claim_id          as ext_claim_id
         , l_case_rec.ext_clearing_trans_id as ext_clearing_trans_id
         , l_case_rec.ext_auth_trans_id     as ext_auth_trans_id
      from dual;
end get_case;

procedure get_case(
    i_dispute_id   in     com_api_type_pkg.t_long_id
  , o_case_cur        out sys_refcursor
) is
    l_case_rec                            csm_api_type_pkg.t_csm_case_rec;
begin
    csm_api_case_pkg.get_case(
        i_dispute_id => i_dispute_id
      , o_case_rec   => l_case_rec
      , i_mask_error => com_api_const_pkg.FALSE
    );
    
    open o_case_cur for
    select l_case_rec.case_id               as case_id
         , l_case_rec.seqnum                as seqnum
         , l_case_rec.inst_id               as inst_id
         , l_case_rec.merchant_name         as merchant_name
         , l_case_rec.customer_number       as customer_number
         , l_case_rec.dispute_reason        as dispute_reason
         , l_case_rec.oper_date             as oper_date
         , l_case_rec.oper_amount           as oper_amount
         , l_case_rec.oper_currency         as oper_currency
         , l_case_rec.dispute_id            as dispute_id
         , l_case_rec.dispute_progress      as dispute_progress
         , l_case_rec.write_off_amount      as write_off_amount
         , l_case_rec.write_off_currency    as write_off_currency
         , l_case_rec.due_date              as due_date
         , l_case_rec.reason_code           as reason_code
         , l_case_rec.disputed_amount       as disputed_amount
         , l_case_rec.disputed_currency     as disputed_currency
         , l_case_rec.created_date          as created_date
         , l_case_rec.created_by_user_id    as created_by_user_id
         , l_case_rec.arn                   as arn
         , l_case_rec.claim_id              as claim_id
         , l_case_rec.auth_code             as auth_code
         , l_case_rec.case_progress         as case_progress
         , l_case_rec.acquirer_inst_bin     as acquirer_inst_bin
         , l_case_rec.transaction_code      as transaction_code
         , l_case_rec.case_source           as case_source
         , l_case_rec.sttl_amount           as sttl_amount
         , l_case_rec.sttl_currency         as sttl_currency
         , l_case_rec.base_amount           as base_amount
         , l_case_rec.base_currency         as base_currency
         , l_case_rec.hide_date             as hide_date
         , l_case_rec.unhide_date           as unhide_date
         , l_case_rec.team_id               as team_id
         , l_case_rec.card_id               as card_id
         , l_case_rec.merchant_id           as merchant_id
         , l_case_rec.is_visible            as is_visible
         , l_case_rec.case_status           as case_status
         , l_case_rec.case_resolution       as case_resolution
         , l_case_rec.flow_id               as flow_id
         , l_case_rec.split_hash            as split_hash
         , l_case_rec.original_id           as original_id
         , l_case_rec.ext_claim_id          as ext_claim_id
         , l_case_rec.ext_clearing_trans_id as ext_clearing_trans_id
         , l_case_rec.ext_auth_trans_id     as ext_auth_trans_id
      from dual;
end get_case;

procedure check_available_actions(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , o_new_case_enable                 out com_api_type_pkg.t_boolean
  , o_take_enable                     out com_api_type_pkg.t_boolean
  , o_refuse_enable                   out com_api_type_pkg.t_boolean
  , o_hide_enable                     out com_api_type_pkg.t_boolean
  , o_unhide_enable                   out com_api_type_pkg.t_boolean
  , o_close_enable                    out com_api_type_pkg.t_boolean
  , o_reopen_enable                   out com_api_type_pkg.t_boolean
  , o_duplicate_enable                out com_api_type_pkg.t_boolean
  , o_comment_enable                  out com_api_type_pkg.t_boolean
  , o_status_enable                   out com_api_type_pkg.t_boolean
  , o_resolution_enable               out com_api_type_pkg.t_boolean
  , o_team_enable                     out com_api_type_pkg.t_boolean
  , o_reassign_enable                 out com_api_type_pkg.t_boolean
  , o_letter_enable                   out com_api_type_pkg.t_boolean
  , o_progress_enable                 out com_api_type_pkg.t_boolean
  , o_reason_enable                   out com_api_type_pkg.t_boolean
  , o_check_due_enable                out com_api_type_pkg.t_boolean
  , o_set_due_enable                  out com_api_type_pkg.t_boolean
) is
    l_case_rec                            csm_api_type_pkg.t_csm_case_rec;
    l_user_id                             com_api_type_pkg.t_short_id;
    l_card_category                       com_api_type_pkg.t_tiny_id;
    LOG_PREFIX               constant     com_api_type_pkg.t_name          := lower($$PLSQL_UNIT) || '.check_available_actions ';
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' case_id [#1]' 
      , i_env_param1 => i_case_id
    );
    
    o_new_case_enable    := com_api_const_pkg.TRUE;
    if i_case_id is null then
        o_take_enable        := com_api_const_pkg.FALSE;
        o_refuse_enable      := com_api_const_pkg.FALSE;
        o_hide_enable        := com_api_const_pkg.FALSE;
        o_unhide_enable      := com_api_const_pkg.FALSE;
        o_duplicate_enable   := com_api_const_pkg.FALSE;
        o_comment_enable     := com_api_const_pkg.FALSE;
        o_team_enable        := com_api_const_pkg.FALSE;
        o_reassign_enable    := com_api_const_pkg.FALSE;
        o_letter_enable      := com_api_const_pkg.FALSE;
        o_progress_enable    := com_api_const_pkg.FALSE;
        o_reason_enable      := com_api_const_pkg.FALSE;
        o_check_due_enable   := com_api_const_pkg.FALSE;
        o_set_due_enable     := com_api_const_pkg.FALSE;
        o_close_enable       := com_api_const_pkg.FALSE;
        o_reopen_enable      := com_api_const_pkg.FALSE;
        o_status_enable      := com_api_const_pkg.FALSE;
        o_resolution_enable  := com_api_const_pkg.FALSE;
    else
        csm_api_case_pkg.get_case(
            i_case_id    => i_case_id
          , o_case_rec   => l_case_rec
          , i_mask_error => com_api_const_pkg.FALSE
        );
        begin
            select nvl(user_id, acm_api_const_pkg.UNDEFINED_USER_ID)
              into l_user_id
              from app_application
             where id = i_case_id;
        exception
            when no_data_found then
                l_user_id := acm_api_const_pkg.UNDEFINED_USER_ID;
        end;
    
        o_take_enable        := is_take_enabled(
                                    i_case_id       => i_case_id
                                  , i_user_id       => l_user_id
                                );
        o_refuse_enable      := is_refuse_enabled(
                                    i_case_id       => i_case_id
                                  , i_user_id       => l_user_id
                                );
        o_hide_enable        := is_hide_enabled(
                                    i_case_id       => i_case_id
                                  , i_is_visible    => l_case_rec.is_visible
                                  , i_case_status   => l_case_rec.case_status
                                  , i_user_id       => l_user_id
                                );
        o_unhide_enable      := is_unhide_enabled(
                                    i_case_id       => i_case_id
                                  , i_is_visible    => l_case_rec.is_visible
                                  , i_case_status   => l_case_rec.case_status
                                );
        o_duplicate_enable   := is_duplicate_enabled(
                                    i_case_id       => i_case_id
                                  , i_case_source   => l_case_rec.case_source
                                  , i_case_status   => l_case_rec.case_status
                                  , i_user_id       => l_user_id
                                );
        o_comment_enable     := is_comment_enabled(
                                    i_case_id       => i_case_id
                                  , i_case_status   => l_case_rec.case_status
                                  , i_user_id       => l_user_id
                                );
        o_team_enable        := is_team_enabled(
                                    i_case_id       => i_case_id
                                  , i_case_status   => l_case_rec.case_status
                                  , i_user_id       => l_user_id
                                );
        o_reassign_enable    := is_reassign_enabled(
                                    i_case_id       => i_case_id
                                  , i_case_status   => l_case_rec.case_status
                                  , i_user_id       => l_user_id
                                );
        o_letter_enable      := is_letter_enabled(
                                    i_case_id       => i_case_id
                                  , i_case_status   => l_case_rec.case_status
                                  , i_user_id       => l_user_id
                                );

        begin
            l_card_category := csm_api_case_pkg.get_card_category(
                                   i_case_id    => i_case_id
                                 , i_mask_error => com_api_const_pkg.TRUE
                               );
        exception
            when com_api_error_pkg.e_application_error then
                if com_api_error_pkg.get_last_error not in ('CASE_CARD_NOT_FOUND') then
                    raise;
                else
                    l_card_category := null;
                end if;
        end;

        o_progress_enable :=
            is_progress_enable(
                i_case_id       => i_case_id
              , i_flow_id       => l_case_rec.flow_id
              , i_case_progress => l_case_rec.case_progress
              , i_card_category => l_card_category
              , i_case_status   => l_case_rec.case_status
              , i_user_id       => l_user_id
            );
        o_reason_enable :=
            is_reason_enable(
                i_case_id       => i_case_id
              , i_flow_id       => l_case_rec.flow_id
              , i_case_progress => l_case_rec.case_progress
              , i_card_category => l_card_category
              , i_case_status   => l_case_rec.case_status
            );

        o_check_due_enable := 
            is_check_due_enabled(
                i_case_id       => i_case_id
              , i_flow_id       => l_case_rec.flow_id
              , i_card_category => l_card_category
              , i_case_status   => l_case_rec.case_status
              , i_user_id       => l_user_id
            );
        o_set_due_enable := 
            is_set_due_enabled(
                i_case_id       => i_case_id
              , i_flow_id       => l_case_rec.flow_id
              , i_case_progress => l_case_rec.case_progress
              , i_case_status   => l_case_rec.case_status
              , i_user_id       => l_user_id
            );                
        o_close_enable :=
            is_close_enabled(
                i_case_id       => i_case_id
              , i_flow_id       => l_case_rec.flow_id
              , i_appl_status   => l_case_rec.case_status
              , i_reject_code   => l_case_rec.case_resolution
              , i_user_id       => l_user_id
            );
        o_reopen_enable :=
            is_reopen_enabled(
                i_case_id       => i_case_id
              , i_flow_id       => l_case_rec.flow_id
              , i_appl_status   => l_case_rec.case_status
              , i_reject_code   => l_case_rec.case_resolution
            );
        o_status_enable :=
            is_status_enabled(
                i_case_id       => i_case_id
              , i_flow_id       => l_case_rec.flow_id
              , i_appl_status   => l_case_rec.case_status
              , i_reject_code   => l_case_rec.case_resolution
              , i_user_id       => l_user_id
            );
        o_resolution_enable :=
            is_resolution_enabled(
                i_case_id       => i_case_id
              , i_flow_id       => l_case_rec.flow_id
              , i_appl_status   => l_case_rec.case_status
              , i_reject_code   => l_case_rec.case_resolution
              , i_user_id       => l_user_id
            );
    end if;
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'end'
    );
end check_available_actions;

function is_check_due_enabled(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_flow_id                      in     com_api_type_pkg.t_tiny_id       default null
  , i_card_category                in     com_api_type_pkg.t_tiny_id       default null
  , i_case_status                  in     com_api_type_pkg.t_dict_value    default null
  , i_user_id                      in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean
is
    l_case_rec                            csm_api_type_pkg.t_csm_case_rec;
    l_card_category                       com_api_type_pkg.t_tiny_id;
    l_result                              com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
begin
    if i_user_id = acm_api_const_pkg.UNDEFINED_USER_ID
        or i_card_category not in (
            csm_api_const_pkg.CARD_CATEGORY_VISA
          , csm_api_const_pkg.CARD_CATEGORY_MASTERCARD
          , csm_api_const_pkg.CARD_CATEGORY_MAESTRO
        ) then
        l_result := com_api_const_pkg.FALSE;
    else
        l_card_category := i_card_category;

        if i_flow_id is null or i_case_status is null then
            csm_api_case_pkg.get_case(
                i_case_id  => i_case_id
              , o_case_rec => l_case_rec
              , i_mask_error => com_api_const_pkg.FALSE
            );
        end if;

        l_case_rec.flow_id       := nvl(i_flow_id, l_case_rec.flow_id);
        l_case_rec.case_status   := nvl(i_case_status, l_case_rec.case_status);

        l_result := case
                        when l_case_rec.case_status = app_api_const_pkg.APPL_STATUS_CLOSED
                            then com_api_const_pkg.FALSE
                        when l_case_rec.case_status = app_api_const_pkg.APPL_STATUS_CLOSED_WO_INV
                            then com_api_const_pkg.FALSE
                        when l_case_rec.case_source = csm_api_const_pkg.CASE_SOURCE_MANUAL_CASE
                            then com_api_const_pkg.FALSE
                        when l_case_rec.flow_id in (app_api_const_pkg.FLOW_ID_ISS_DISPUTE_DOMESTIC, app_api_const_pkg.FLOW_ID_ISS_DISPUTE_INTERNTNL)
                            then com_api_const_pkg.TRUE
                        when l_case_rec.flow_id in (app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_DOMESTIC, app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_INTERNTNL)
                            and l_card_category = csm_api_const_pkg.CARD_CATEGORY_VISA
                            then com_api_const_pkg.TRUE
                        else
                            com_api_const_pkg.FALSE
                    end;
    end if;
    return l_result;
end is_check_due_enabled;

function is_set_due_enabled(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_flow_id                      in     com_api_type_pkg.t_tiny_id       default null
  , i_case_progress                in     com_api_type_pkg.t_dict_value    default null
  , i_case_status                  in     com_api_type_pkg.t_dict_value    default null
  , i_user_id                      in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean
is
    l_case_rec                            csm_api_type_pkg.t_csm_case_rec;
begin
    if i_user_id = acm_api_const_pkg.UNDEFINED_USER_ID then
        return com_api_const_pkg.FALSE;
    else
        if i_case_progress is null or i_case_status is null or i_flow_id is null then
            csm_api_case_pkg.get_case(
                i_case_id    => i_case_id
              , o_case_rec   => l_case_rec
              , i_mask_error => com_api_const_pkg.FALSE
            );
        end if;
        l_case_rec.case_progress := nvl(i_case_progress, l_case_rec.case_progress);
        l_case_rec.case_status   := nvl(i_case_status, l_case_rec.case_status);
        l_case_rec.flow_id       := nvl(i_flow_id, l_case_rec.flow_id);

        return case
                   when l_case_rec.case_status = app_api_const_pkg.APPL_STATUS_CLOSED
                   then com_api_const_pkg.FALSE
                   when l_case_rec.case_status = app_api_const_pkg.APPL_STATUS_CLOSED_WO_INV
                       then com_api_const_pkg.FALSE
                   when l_case_rec.flow_id in (
                            app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_DOMESTIC
                          , app_api_const_pkg.FLOW_ID_ISS_DISPUTE_DOMESTIC
                          , app_api_const_pkg.FLOW_ID_DISPUTE_INTERNAL
                        ) or (
                            l_case_rec.flow_id in (
                                app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_INTERNTNL
                              , app_api_const_pkg.FLOW_ID_ISS_DISPUTE_INTERNTNL
                            ) and
                            l_case_rec.case_progress in (
                                dsp_api_const_pkg.DISPUTE_PROGRESS_PRE_COMPLNCE
                              , dsp_api_const_pkg.DISPUTE_PROGRESS_COMPLIANCE
                              , dsp_api_const_pkg.DISPUTE_PROGRESS_PRE_ARBITRAT
                              , dsp_api_const_pkg.DISPUTE_PROGRESS_ARBITRATION
                            )
                        )
                   then com_api_const_pkg.TRUE
                   else com_api_const_pkg.FALSE
               end;
    end if;
    
end is_set_due_enabled;

function get_due_date_lov(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_flow_id                      in     com_api_type_pkg.t_tiny_id       default null
) return com_api_type_pkg.t_tiny_id
is
    l_case_rec                            csm_api_type_pkg.t_csm_case_rec;
begin
    if i_flow_id is null then
        csm_api_case_pkg.get_case(
            i_case_id    => i_case_id
          , o_case_rec   => l_case_rec
          , i_mask_error => com_api_const_pkg.FALSE
        );
    else
        l_case_rec.flow_id := i_flow_id;
    end if;
    
    return case
               when l_case_rec.flow_id = app_api_const_pkg.FLOW_ID_ISS_DISPUTE_INTERNTNL 
                   then
                       csm_api_const_pkg.LOV_ID_CASE_DUE_DATE_DEFAULT
               when l_case_rec.flow_id <> app_api_const_pkg.FLOW_ID_ISS_DISPUTE_INTERNTNL
                   then csm_api_const_pkg.LOV_ID_CASE_DUE_DATE_ACQ
               else null
           end;
end get_due_date_lov;

function is_take_enabled(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_user_id                      in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean
is
    l_case_rec                            csm_api_type_pkg.t_csm_case_rec;
begin
    if i_user_id = acm_api_const_pkg.UNDEFINED_USER_ID then
        csm_api_case_pkg.get_case(
            i_case_id    => i_case_id
          , o_case_rec   => l_case_rec
          , i_mask_error => com_api_const_pkg.FALSE
        );
        if l_case_rec.case_status not in (app_api_const_pkg.APPL_STATUS_CLOSED,  app_api_const_pkg.APPL_STATUS_CLOSED_WO_INV) then
            return com_api_const_pkg.TRUE;
        else 
            return com_api_const_pkg.FALSE;
        end if;
    else
        return com_api_const_pkg.FALSE;
    end if;
end is_take_enabled;

function is_refuse_enabled(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_user_id                      in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean
is
    l_case_rec                            csm_api_type_pkg.t_csm_case_rec;
    i_result                              com_api_type_pkg.t_boolean; 
begin
    if i_user_id != acm_api_const_pkg.UNDEFINED_USER_ID and get_user_id = i_user_id then
        csm_api_case_pkg.get_case(
            i_case_id    => i_case_id
          , o_case_rec   => l_case_rec
          , i_mask_error => com_api_const_pkg.FALSE
        );

        if l_case_rec.case_status not in (app_api_const_pkg.APPL_STATUS_CLOSED, app_api_const_pkg.APPL_STATUS_CLOSED_WO_INV) then
            i_result :=  com_api_const_pkg.TRUE;
        else 
            i_result :=  com_api_const_pkg.FALSE;
        end if;
    else
        i_result := com_api_const_pkg.FALSE;
    end if;
    return i_result;
end is_refuse_enabled;

procedure set_application_team(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , io_seqnum                      in out com_api_type_pkg.t_tiny_id
  , i_team_id                      in     com_api_type_pkg.t_short_id
) is
    l_case_rec                            csm_api_type_pkg.t_csm_case_rec;
    l_old_name                            com_api_type_pkg.t_name;
    l_new_name                            com_api_type_pkg.t_name;

    function get_team_name(i_id in com_api_type_pkg.t_short_id)
    return com_api_type_pkg.t_name
    is
        l_res                             com_api_type_pkg.t_name;
    begin
        select get_text(i_table_name  => 'com_array_element'
                      , i_column_name => 'label'
                      , i_object_id   => id)
          into l_res
          from com_array_element
         where array_id = csm_api_const_pkg.DISPUTE_TEAM_ARRAY
           and element_number = i_id;

         return l_res;
    exception
        when no_data_found then
            return '';
    end;
begin
    trc_log_pkg.debug(
        i_text       => 'set_application_team: start i_case_id [#1], i_team_id [#2]'
      , i_env_param1 => i_case_id
      , i_env_param2 => i_team_id
    );
    csm_api_case_pkg.get_case(
        i_case_id    => i_case_id
      , o_case_rec   => l_case_rec
      , i_mask_error => com_api_const_pkg.FALSE
    );
    
    update csm_case_vw
       set team_id  = i_team_id
     where id       = i_case_id;

    update app_application_vw
       set seqnum   = io_seqnum
     where id       = i_case_id;

    io_seqnum := io_seqnum + 1;

    l_old_name := get_team_name(l_case_rec.team_id);
    l_new_name := get_team_name(i_team_id);
    
    csm_api_case_pkg.add_history(
        i_case_id         => i_case_id
      , i_action          => csm_api_const_pkg.CASE_ACTION_TEAM_CHNG_LABEL
      , i_event_type      => csm_api_const_pkg.EVENT_TEAM_CHANGED
      , i_new_appl_status => l_case_rec.case_status
      , i_old_appl_status => l_case_rec.case_status
      , i_new_reject_code => l_case_rec.case_resolution
      , i_old_reject_code => l_case_rec.case_resolution
      , i_env_param1      => l_old_name
      , i_env_param2      => l_new_name
      , i_mask_error      => com_api_const_pkg.FALSE
    );
    trc_log_pkg.debug(
        i_text       => 'set_application_team: end'
    );
exception
    when others then
        trc_log_pkg.debug(
            i_text       => 'set_application_team: ' || sqlerrm
        );
        raise;
end set_application_team;

function is_progress_enable(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_flow_id                      in     com_api_type_pkg.t_tiny_id       default null
  , i_card_category                in     com_api_type_pkg.t_tiny_id       default null
  , i_case_progress                in     com_api_type_pkg.t_dict_value    default null
  , i_case_status                  in     com_api_type_pkg.t_dict_value    default null
  , i_user_id                      in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean
is
    l_case_rec                            csm_api_type_pkg.t_csm_case_rec;
    l_flow_id                             com_api_type_pkg.t_tiny_id;
    l_card_category                       com_api_type_pkg.t_tiny_id;
    l_case_progress                       com_api_type_pkg.t_dict_value;
    l_res                                 com_api_type_pkg.t_boolean;
    l_case_status                         com_api_type_pkg.t_dict_value;
begin
    if i_user_id = acm_api_const_pkg.UNDEFINED_USER_ID then
        return com_api_const_pkg.FALSE;
    end if;

    if i_flow_id is null or i_case_progress is null or i_case_status is null then
        csm_api_case_pkg.get_case(
            i_case_id    => i_case_id
          , o_case_rec   => l_case_rec    
          , i_mask_error => com_api_const_pkg.FALSE
        );
        l_flow_id       := l_case_rec.flow_id;
        l_case_progress := l_case_rec.case_progress;
        l_case_status   := l_case_rec.case_status;
    else 
        l_flow_id       := i_flow_id;        
        l_case_progress := i_case_progress;       
        l_case_status   := i_case_status;
    end if;  
    
    case
        when l_case_status = app_api_const_pkg.APPL_STATUS_CLOSED then 
            l_res := com_api_const_pkg.FALSE;
        when l_case_status = app_api_const_pkg.APPL_STATUS_CLOSED_WO_INV then 
            l_res := com_api_const_pkg.FALSE; 
        when l_flow_id = app_api_const_pkg.FLOW_ID_DISPUTE_INTERNAL then
            l_res := com_api_const_pkg.FALSE;
        when l_flow_id in (app_api_const_pkg.FLOW_ID_ISS_DISPUTE_DOMESTIC, app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_DOMESTIC) then
            l_res := com_api_const_pkg.TRUE;
        when l_flow_id in (app_api_const_pkg.FLOW_ID_ISS_DISPUTE_INTERNTNL, app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_INTERNTNL) then
                if i_card_category is null then
                    l_card_category := csm_api_case_pkg.get_card_category(
                                           i_case_id    => i_case_id
                                         , i_mask_error => com_api_const_pkg.TRUE
                                       );
                else
                    l_card_category := i_card_category;
                end if;
                
                if (
                    l_card_category = csm_api_const_pkg.CARD_CATEGORY_VISA
                and l_case_progress in (
                        csm_api_const_pkg.CASE_PROGRESS_REPRESENTMENT
                      , csm_api_const_pkg.CASE_PROGRESS_DISPUTE
                      , csm_api_const_pkg.CASE_PROGRESS_DISPUTE_RESP
                    )
                )
                or (
                    l_card_category = csm_api_const_pkg.CARD_CATEGORY_MASTERCARD
                and l_case_progress = csm_api_const_pkg.CASE_PROGRESS_ARB_CHARGEB
                ) then
                    l_res := com_api_const_pkg.TRUE;
                else
                    l_res := com_api_const_pkg.FALSE;
                end if;
        else l_res := com_api_const_pkg.FALSE;
    end case;
    
    return l_res;
    
end is_progress_enable;

function is_reason_enable(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_flow_id                      in     com_api_type_pkg.t_tiny_id       default null
  , i_card_category                in     com_api_type_pkg.t_tiny_id       default null
  , i_case_progress                in     com_api_type_pkg.t_dict_value    default null
  , i_case_status                  in     com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_boolean
is
    l_case_rec                            csm_api_type_pkg.t_csm_case_rec;
    l_flow_id                             com_api_type_pkg.t_tiny_id;
    l_card_category                       com_api_type_pkg.t_tiny_id;
    l_case_progress                       com_api_type_pkg.t_dict_value;
    l_res                                 com_api_type_pkg.t_boolean;
    l_case_status                         com_api_type_pkg.t_dict_value;
begin
    
    if i_flow_id is null or l_case_progress is null or i_case_status is null then
        csm_api_case_pkg.get_case(
            i_case_id    => i_case_id
          , o_case_rec   => l_case_rec
          , i_mask_error => com_api_const_pkg.FALSE
        );
        l_flow_id       := l_case_rec.flow_id;
        l_case_progress := l_case_rec.case_progress;
        l_case_status   := l_case_rec.case_status;
    else 
        l_flow_id       := i_flow_id;        
        l_case_progress := i_case_progress;       
        l_case_status   := i_case_status;
    end if;
    
    if i_card_category is null then
        l_card_category := csm_api_case_pkg.get_card_category(
                               i_case_id    => i_case_id
                             , i_mask_error => com_api_const_pkg.TRUE
                           );
    else
        l_card_category := i_card_category;
    end if;

    case
        when l_case_status = app_api_const_pkg.APPL_STATUS_CLOSED then 
            l_res := com_api_const_pkg.FALSE;
        when l_case_status = app_api_const_pkg.APPL_STATUS_CLOSED_WO_INV then  
            l_res := com_api_const_pkg.FALSE;
        when l_flow_id = app_api_const_pkg.FLOW_ID_DISPUTE_INTERNAL then
            l_res := com_api_const_pkg.FALSE;
        when l_flow_id in (app_api_const_pkg.FLOW_ID_ISS_DISPUTE_DOMESTIC, app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_DOMESTIC) then
            if l_case_progress = csm_api_const_pkg.CASE_PROGRESS_CHARGEBACK or 
              (l_card_category = csm_api_const_pkg.CARD_CATEGORY_VISA and l_case_progress = csm_api_const_pkg.CASE_PROGRESS_REPRESENTMENT) then
                l_res := com_api_const_pkg.TRUE;
            else 
                l_res := com_api_const_pkg.FALSE;
            end if;
        when l_flow_id in (app_api_const_pkg.FLOW_ID_ISS_DISPUTE_INTERNTNL, app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_INTERNTNL) then
            if l_card_category = csm_api_const_pkg.CARD_CATEGORY_VISA and l_case_progress = csm_api_const_pkg.CASE_PROGRESS_PRE_ARBITRATION then
                l_res := com_api_const_pkg.TRUE;
            else
                l_res := com_api_const_pkg.FALSE;
            end if;   
        else l_res := com_api_const_pkg.FALSE;
    end case;            

    return l_res;
end is_reason_enable;

function count_link_operations(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_array_exclude_oper_status    in     com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_short_id
is
    LOG_PREFIX               constant     com_api_type_pkg.t_name          := lower($$PLSQL_UNIT) || '.count_link_operations: ';
    
    
    l_case_rec                            csm_api_type_pkg.t_csm_case_rec;
    l_array_exclude_oper_status           com_api_type_pkg.t_medium_id;
    
    l_result                              com_api_type_pkg.t_short_id;
begin
    l_array_exclude_oper_status := nvl(i_array_exclude_oper_status, csm_api_const_pkg.EXCLUDE_OPER_PROCESSED_ARRAY);
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'Started with params - case_id [#1] array_exclude_oper_status [#2]' 
      , i_env_param1 => i_case_id
      , i_env_param2 => l_array_exclude_oper_status
    );
    csm_api_case_pkg.get_case(
        i_case_id    => i_case_id
      , o_case_rec   => l_case_rec
      , i_mask_error => com_api_const_pkg.FALSE
    );
    select count(*)
      into l_result
      from opr_operation o
     where o.dispute_id = l_case_rec.dispute_id
       and o.status not in (select element_value from com_array_element where array_id = l_array_exclude_oper_status)
       and (o.oper_type in (select element_value from com_array_element where array_id = csm_api_const_pkg.DISPUTE_OPERATION_TYPE_ARRAY)
                or
            o.msg_type in (select element_value from com_array_element where array_id = csm_api_const_pkg.DISPUTE_MESSAGE_TYPE_ARRAY)
           );
    
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'End with ' || l_result
    );
    return l_result;
    
end count_link_operations;

function is_close_enabled(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_flow_id                      in     com_api_type_pkg.t_tiny_id       default null
  , i_appl_status                  in     com_api_type_pkg.t_dict_value    default null
  , i_reject_code                  in     com_api_type_pkg.t_dict_value    default null
  , i_user_id                      in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean
is
    LOG_PREFIX               constant     com_api_type_pkg.t_name          := lower($$PLSQL_UNIT) || '.is_close_enabled: ';

    l_case_rec                            csm_api_type_pkg.t_csm_case_rec;
    l_appl_status                         com_api_type_pkg.t_dict_value;
    
    l_result                              com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
    l_count_item                          com_api_type_pkg.t_short_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'Started with params - case_id [#1], flow_id [#2], appl_status [#3], reject_code [#4]' 
      , i_env_param1 => i_case_id
      , i_env_param2 => i_flow_id
      , i_env_param3 => i_appl_status
      , i_env_param4 => i_reject_code
    );
    if i_user_id = acm_api_const_pkg.UNDEFINED_USER_ID then
        return com_api_const_pkg.FALSE;
    end if;
    if i_flow_id is null or i_appl_status is null or i_reject_code is null then
        csm_api_case_pkg.get_case(
            i_case_id    => i_case_id
          , o_case_rec   => l_case_rec
          , i_mask_error => com_api_const_pkg.FALSE
        );
    end if;
    l_appl_status   := nvl(i_appl_status, l_case_rec.case_status);
    
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'Finished value of params - flow_id [#1], appl_status [#2], reject_code [#3]' 
      , i_env_param1 => i_flow_id
      , i_env_param2 => l_appl_status
      , i_env_param3 => i_reject_code
    );
    
    if l_appl_status = app_api_const_pkg.APPL_STATUS_PENDING then
        l_count_item :=
            count_link_operations(
                i_case_id                   => i_case_id
              , i_array_exclude_oper_status => csm_api_const_pkg.EXCLUDE_OPER_PROCESSED_ARRAY
            );
        if l_count_item = 0
        then
            l_result := com_api_const_pkg.TRUE;
        else
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || ' close is disable because of [#1] linked operations'
              , i_env_param1 => l_count_item
            );
            l_result := com_api_const_pkg.FALSE;
        end if;
    else
        l_result := com_api_const_pkg.FALSE;
    end if;
    
    return l_result;
exception
    when others then
        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then
            return com_api_const_pkg.FALSE;
        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end is_close_enabled;

function is_reopen_enabled(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_flow_id                      in     com_api_type_pkg.t_tiny_id       default null
  , i_appl_status                  in     com_api_type_pkg.t_dict_value    default null
  , i_reject_code                  in     com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_boolean
is
    LOG_PREFIX               constant     com_api_type_pkg.t_name          := lower($$PLSQL_UNIT) || '.is_reopen_enabled: ';

    l_case_rec                            csm_api_type_pkg.t_csm_case_rec;
    l_flow_id                             com_api_type_pkg.t_tiny_id;
    l_appl_status                         com_api_type_pkg.t_dict_value;
    l_reject_code                         com_api_type_pkg.t_dict_value;
    
    l_result                              com_api_type_pkg.t_boolean;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'Started with params - case_id [#1], flow_id [#2], appl_status [#3], reject_code [#4]' 
      , i_env_param1 => i_case_id
      , i_env_param2 => i_flow_id
      , i_env_param3 => i_appl_status
      , i_env_param4 => i_reject_code
    );
    if i_flow_id is null or i_appl_status is null or i_reject_code is null then
        csm_api_case_pkg.get_case(
            i_case_id    => i_case_id
          , o_case_rec   => l_case_rec
          , i_mask_error => com_api_const_pkg.FALSE
        );
    end if;
    l_flow_id       := nvl(i_flow_id, l_case_rec.flow_id);
    l_appl_status   := nvl(i_appl_status, l_case_rec.case_status);
    l_reject_code   := nvl(i_reject_code, l_case_rec.case_resolution);
    
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'Finished value of params - flow_id [#1], appl_status [#2], reject_code [#3]' 
      , i_env_param1 => l_flow_id
      , i_env_param2 => l_appl_status
      , i_env_param3 => l_reject_code
    );
    
    if l_appl_status <> app_api_const_pkg.APPL_STATUS_CLOSED_WO_INV then
        l_result := com_api_const_pkg.FALSE;
    else
        l_result := com_api_const_pkg.TRUE;
    end if;
    
    return l_result;
exception
    when others then
        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then
            return com_api_const_pkg.FALSE;
        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end is_reopen_enabled;

function is_transmit_enabled(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_flow_id                      in     com_api_type_pkg.t_tiny_id       default null
  , i_appl_status                  in     com_api_type_pkg.t_dict_value    default null
  , i_reject_code                  in     com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_boolean
is
    LOG_PREFIX               constant     com_api_type_pkg.t_name          := lower($$PLSQL_UNIT) || '.is_transmit_enabled: ';

    l_case_rec                            csm_api_type_pkg.t_csm_case_rec;
    l_flow_id                             com_api_type_pkg.t_tiny_id;
    l_appl_status                         com_api_type_pkg.t_dict_value;
    l_reject_code                         com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'Started with params - case_id [#1], flow_id [#2], appl_status [#3], reject_code [#4]' 
      , i_env_param1 => i_case_id
      , i_env_param2 => i_flow_id
      , i_env_param3 => i_appl_status
      , i_env_param4 => i_reject_code
    );
    csm_api_case_pkg.get_case(
        i_case_id    => i_case_id
      , o_case_rec   => l_case_rec
      , i_mask_error => com_api_const_pkg.FALSE
    );
    
    l_flow_id       := nvl(i_flow_id, l_case_rec.flow_id);
    l_appl_status   := nvl(i_appl_status, l_case_rec.case_status);
    l_reject_code   := nvl(i_reject_code, l_case_rec.case_resolution);
    
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'Finished value of params - flow_id [#1], appl_status [#2], reject_code [#3]' 
      , i_env_param1 => l_flow_id
      , i_env_param2 => l_appl_status
      , i_env_param3 => l_reject_code
    );
    
    if l_case_rec.case_status in (app_api_const_pkg.APPL_STATUS_CLOSED, app_api_const_pkg.APPL_STATUS_CLOSED_WO_INV)
       and l_case_rec.flow_id = app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_INTERNTNL
       and l_case_rec.case_resolution in (app_api_const_pkg.CASE_RESOLUTION_REPRESENTED, app_api_const_pkg.CASE_RESOLUTION_RESPONDED)
       or l_case_rec.case_status not in (app_api_const_pkg.APPL_STATUS_CLOSED, app_api_const_pkg.APPL_STATUS_CLOSED_WO_INV) then
        return
            app_api_flow_transition_pkg.check_available_transition(
                i_appl_id         => i_case_id
              , i_flow_id         => l_flow_id
              , i_new_appl_status => null
              , i_new_reject_code => null
              , i_old_appl_status => l_appl_status
              , i_old_reject_code => l_reject_code
            );
    else 
        return com_api_const_pkg.FALSE;
    end if;

exception
    when others then
        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then
            return com_api_const_pkg.FALSE;
        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end is_transmit_enabled;

function is_status_enabled(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_flow_id                      in     com_api_type_pkg.t_tiny_id       default null
  , i_appl_status                  in     com_api_type_pkg.t_dict_value    default null
  , i_reject_code                  in     com_api_type_pkg.t_dict_value    default null
  , i_user_id                      in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean
is
    LOG_PREFIX               constant     com_api_type_pkg.t_name          := lower($$PLSQL_UNIT) || '.is_status_enabled: ';
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'Started with params - case_id [#1], flow_id [#2], appl_status [#3], reject_code [#4]' 
      , i_env_param1 => i_case_id
      , i_env_param2 => i_flow_id
      , i_env_param3 => i_appl_status
      , i_env_param4 => i_reject_code
    );
    
    if i_user_id = acm_api_const_pkg.UNDEFINED_USER_ID or i_appl_status in (app_api_const_pkg.APPL_STATUS_CLOSED, app_api_const_pkg.APPL_STATUS_CLOSED_WO_INV) then
        return com_api_const_pkg.FALSE;
    else
        return
            is_transmit_enabled(
                i_case_id           => i_case_id
              , i_flow_id           => i_flow_id
              , i_appl_status       => i_appl_status
              , i_reject_code       => i_reject_code
            );
    end if;
exception
    when others then
        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then
            return com_api_const_pkg.FALSE;
        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end is_status_enabled;

function is_resolution_enabled(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_flow_id                      in     com_api_type_pkg.t_tiny_id       default null
  , i_appl_status                  in     com_api_type_pkg.t_dict_value    default null
  , i_reject_code                  in     com_api_type_pkg.t_dict_value    default null
  , i_user_id                      in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean
is
    LOG_PREFIX               constant     com_api_type_pkg.t_name          := lower($$PLSQL_UNIT) || '.is_resolution_enabled: ';
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'Started with params - case_id [#1], flow_id [#2], appl_status [#3], reject_code [#4]' 
      , i_env_param1 => i_case_id
      , i_env_param2 => i_flow_id
      , i_env_param3 => i_appl_status
      , i_env_param4 => i_reject_code
    );

    if i_user_id = acm_api_const_pkg.UNDEFINED_USER_ID or i_appl_status in (app_api_const_pkg.APPL_STATUS_CLOSED, app_api_const_pkg.APPL_STATUS_CLOSED_WO_INV) then
        return com_api_const_pkg.FALSE;
    else
        return
            is_transmit_enabled(
                i_case_id           => i_case_id
              , i_flow_id           => i_flow_id
              , i_appl_status       => i_appl_status
              , i_reject_code       => i_reject_code
            );
    end if;
exception
    when others then
        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then
            return com_api_const_pkg.FALSE;
        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end is_resolution_enabled;

procedure change_case_status(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_appl_status                  in     com_api_type_pkg.t_dict_value
  , i_reject_code                  in     com_api_type_pkg.t_dict_value    default null    
)
is
    LOG_PREFIX               constant     com_api_type_pkg.t_name          := lower($$PLSQL_UNIT) || '.change_case_status: ';

    l_application                         app_api_type_pkg.t_application_rec;
    l_comment                             com_api_type_pkg.t_text;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'Started with params - case_id [#1], appl_status [#2], reject_code [#3]' 
      , i_env_param1 => i_case_id
      , i_env_param2 => i_appl_status
      , i_env_param3 => i_reject_code
    );
    l_application := 
        app_api_application_pkg.get_application(
            i_appl_id     => i_case_id
          , i_raise_error => com_api_const_pkg.TRUE
        );
    l_comment :=
        csm_api_utl_pkg.get_case_comment(
            i_action      => csm_api_const_pkg.CASE_ACTION_STATUS_CHNG_LABEL
          , i_description => '"' || i_appl_status || '";"' || i_reject_code || '";'
        );
    
    app_ui_application_pkg.modify_application(
        i_appl_id           => i_case_id
      , io_seqnum           => l_application.seqnum
      , i_appl_status       => i_appl_status
      , i_resp_sess_file_id => l_application.resp_file_id
      , i_comments          => l_comment
      , i_change_action     => csm_api_const_pkg.CASE_ACTION_STATUS_CHNG_LABEL
      , i_reject_code       => i_reject_code
      , i_event_type        => null
      , i_user_id           => l_application.user_id
      , i_appl_prioritized  => l_application.appl_prioritized
    );

end change_case_status;

function is_duplicate_enabled(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_case_source                  in     com_api_type_pkg.t_dict_value    default null
  , i_case_status                  in     com_api_type_pkg.t_dict_value    default null
  , i_user_id                      in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean is
    l_case_source                         com_api_type_pkg.t_dict_value;
    l_case_rec                            csm_api_type_pkg.t_csm_case_rec;
    l_result                              com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
    l_case_status                         com_api_type_pkg.t_dict_value;
begin
    if i_user_id = acm_api_const_pkg.UNDEFINED_USER_ID or i_case_status in (app_api_const_pkg.APPL_STATUS_CLOSED, app_api_const_pkg.APPL_STATUS_CLOSED_WO_INV) then
        l_result := com_api_const_pkg.FALSE;
    else
        if i_case_source is null or i_case_status is null then
            csm_api_case_pkg.get_case(
                i_case_id    => i_case_id
              , o_case_rec   => l_case_rec
              , i_mask_error => com_api_const_pkg.FALSE
            );
        end if;

        l_case_source := nvl(i_case_source, l_case_rec.case_source);
        l_case_status := nvl(i_case_status, l_case_rec.case_status);

        if l_case_source  = csm_api_const_pkg.CASE_SOURCE_MANUAL_CASE and l_case_status != app_api_const_pkg.APPL_STATUS_CLOSED then
            l_result  := com_api_const_pkg.TRUE;
        else
            l_result  := com_api_const_pkg.FALSE;
        end if;
    end if;
    
    return l_result;
end is_duplicate_enabled;

procedure set_hide_unhide_date(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , io_seqnum                      in out com_api_type_pkg.t_tiny_id
  , i_hide_date                    in     date
  , i_unhide_date                  in     date
) is
    l_sysdate                             date := trunc(com_api_sttl_day_pkg.get_sysdate);
begin
    update csm_case_vw
       set hide_date    = i_hide_date
         , unhide_date  = i_unhide_date
     where id           = i_case_id;
     
    update app_application_vw
       set seqnum       = io_seqnum
     where id           = i_case_id;
     
    io_seqnum := io_seqnum + 1;

    if trunc(i_hide_date) = l_sysdate then
        change_case_visibility(
            i_case_id    => i_case_id
          , io_seqnum    => io_seqnum
          , i_is_visible => com_api_const_pkg.FALSE
          , i_start_date  => i_hide_date
          , i_end_date    => i_unhide_date
        );
    end if;
end set_hide_unhide_date;

procedure change_case_visibility(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , io_seqnum                      in out com_api_type_pkg.t_tiny_id
  , i_is_visible                   in     com_api_type_pkg.t_boolean
  , i_start_date                   in     date                       default null
  , i_end_date                     in     date                       default null
) is
    l_is_visible         com_api_type_pkg.t_boolean := nvl(i_is_visible, com_api_const_pkg.TRUE);
    l_start_date         date := nvl(i_start_date, trunc(com_api_sttl_day_pkg.get_sysdate));
    l_old_appl_status    com_api_type_pkg.t_dict_value;
    l_old_reject_code    com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text => 'change_case_visibility: start i_case_id=' || i_case_id || ' i_is_visible=' || i_is_visible
                || ' i_start_date=' || i_start_date || ' i_end_date=' || i_end_date
    );

    select a.appl_status
         , a.reject_code
      into l_old_appl_status
         , l_old_reject_code
      from app_application a
     where a.id = i_case_id;

    update app_application_vw
       set is_visible   = l_is_visible
         , seqnum       = io_seqnum
     where id           = i_case_id;

    if l_is_visible = com_api_const_pkg.FALSE then
        update csm_case_vw
           set hide_date    = l_start_date
             , unhide_date  = nvl(i_end_date, unhide_date)
         where id           = i_case_id;

    else
        update csm_case_vw
           set unhide_date  = l_start_date
         where id           = i_case_id;
    end if;
    
    csm_api_case_pkg.add_history(
        i_case_id         => i_case_id
      , i_action          => case
                                 when l_is_visible = com_api_const_pkg.FALSE
                                     then csm_api_const_pkg.CASE_ACTION_HIDE_LABEL
                                 else csm_api_const_pkg.CASE_ACTION_UNHIDE_LABEL
                             end
      , i_new_appl_status => l_old_appl_status
      , i_old_appl_status => l_old_appl_status
      , i_new_reject_code => l_old_reject_code
      , i_old_reject_code => l_old_reject_code
      , i_env_param1      => l_start_date
      , i_env_param2      => i_end_date
    );
end change_case_visibility;

function is_hide_enabled(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_is_visible                   in     com_api_type_pkg.t_boolean       default null
  , i_case_status                  in     com_api_type_pkg.t_dict_value    default null
  , i_user_id                      in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean is
    l_is_visible                          com_api_type_pkg.t_boolean;
    l_item_count                          com_api_type_pkg.t_count   := 0;
    l_case_rec                            csm_api_type_pkg.t_csm_case_rec;
    l_result                              com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
    l_case_status                         com_api_type_pkg.t_dict_value;
begin
    if i_user_id = acm_api_const_pkg.UNDEFINED_USER_ID or i_case_status in (app_api_const_pkg.APPL_STATUS_CLOSED, app_api_const_pkg.APPL_STATUS_CLOSED_WO_INV) then
        l_result  := com_api_const_pkg.FALSE;
    else
        if i_is_visible is null or i_case_status is null then
            csm_api_case_pkg.get_case(
                i_case_id    => i_case_id
              , o_case_rec   => l_case_rec
              , i_mask_error => com_api_const_pkg.FALSE
            );
        end if;

        l_is_visible  := coalesce(i_is_visible, l_case_rec.is_visible, com_api_const_pkg.TRUE);
        l_case_status := nvl(i_case_status, l_case_rec.case_status);

        l_item_count  := count_link_operations(
            i_case_id                    => i_case_id
          , i_array_exclude_oper_status  => null
        );

        if l_item_count = 0 and l_is_visible = com_api_const_pkg.TRUE and l_case_status != app_api_const_pkg.APPL_STATUS_CLOSED then
            l_result  := com_api_const_pkg.TRUE;
        else
            l_result  := com_api_const_pkg.FALSE;
        end if;
    end if;
    return l_result;
    
end is_hide_enabled;

function is_unhide_enabled(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_is_visible                   in     com_api_type_pkg.t_boolean       default null
  , i_case_status                  in     com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_boolean is
    l_is_visible                          com_api_type_pkg.t_boolean;
    l_case_rec                            csm_api_type_pkg.t_csm_case_rec;
    l_result                              com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
    l_case_status                         com_api_type_pkg.t_dict_value;
begin
    if i_is_visible is null or i_case_status is null then
        csm_api_case_pkg.get_case(
            i_case_id    => i_case_id
          , o_case_rec   => l_case_rec
          , i_mask_error => com_api_const_pkg.FALSE
        );
    end if;

    l_is_visible  := nvl(i_is_visible, l_case_rec.is_visible);
    l_case_status := nvl(i_case_status, l_case_rec.case_status);

    if l_is_visible = com_api_const_pkg.FALSE and l_case_status not in (app_api_const_pkg.APPL_STATUS_CLOSED, app_api_const_pkg.APPL_STATUS_CLOSED_WO_INV) then
        l_result  := com_api_const_pkg.TRUE;
    else
        l_result  := com_api_const_pkg.FALSE;
    end if;
    return l_result;

end is_unhide_enabled;

procedure add_history(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_action                       in     com_api_type_pkg.t_name
  , i_event_type                   in     com_api_type_pkg.t_dict_value    default null
  , i_new_appl_status              in     com_api_type_pkg.t_dict_value
  , i_old_appl_status              in     com_api_type_pkg.t_dict_value
  , i_new_reject_code              in     com_api_type_pkg.t_dict_value
  , i_old_reject_code              in     com_api_type_pkg.t_dict_value
  , i_env_param1                   in     com_api_type_pkg.t_name          default null
  , i_env_param2                   in     com_api_type_pkg.t_name          default null
  , i_env_param3                   in     com_api_type_pkg.t_name          default null
  , i_env_param4                   in     com_api_type_pkg.t_name          default null
  , i_mask_error                   in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
)
is
    LOG_PREFIX                   constant com_api_type_pkg.t_name          := lower($$PLSQL_UNIT) || '.add_history: ';
begin
    trc_log_pkg.debug(
        i_text          => LOG_PREFIX 
                        || 'Start with params: case_id [#1] action [#2] event_type [#3] new_appl_status [#4] new_reject_code [#5'
                        || '] env_param1 [' || i_env_param1
                        || '] env_param2 [' || i_env_param2
                        || '] env_param3 [' || i_env_param3
                        || '] env_param4 [' || i_env_param4
                        || ']'
      , i_env_param1    => i_case_id
      , i_env_param2    => i_action
      , i_env_param3    => i_event_type
      , i_env_param4    => i_new_appl_status
      , i_env_param5    => i_new_reject_code
    );

    csm_api_case_pkg.add_history(
        i_case_id         => i_case_id 
      , i_action          => i_action
      , i_event_type      => i_event_type
      , i_new_appl_status => i_new_appl_status
      , i_old_appl_status => i_old_appl_status
      , i_new_reject_code => i_new_reject_code
      , i_old_reject_code => i_old_reject_code
      , i_env_param1      => i_env_param1
      , i_env_param2      => i_env_param2
      , i_env_param3      => i_env_param3
      , i_env_param4      => i_env_param4
      , i_mask_error      => i_mask_error
    );
end add_history;

procedure set_due_date(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , i_due_date                     in     date
  , io_seqnum                      in out com_api_type_pkg.t_seqnum
) is
    LOG_PREFIX                   constant com_api_type_pkg.t_name          := lower($$PLSQL_UNIT) || '.set_due_date: ';
begin
    trc_log_pkg.debug(
        i_text          => LOG_PREFIX || 'Start with params: case_id [#1] due_date [#2] seqnum [#3]'
      , i_env_param1    => i_case_id
      , i_env_param2    => i_due_date
      , i_env_param3    => io_seqnum
    );
    csm_api_case_pkg.set_due_date(
        i_case_id       => i_case_id
      , i_due_date      => i_due_date
      , io_seqnum       => io_seqnum
    );
end set_due_date;

procedure modify_case(
    i_case_id                      in     com_api_type_pkg.t_long_id
  , io_seqnum                      in out com_api_type_pkg.t_seqnum
  , i_oper_date                    in     date
  , i_oper_amount                  in     com_api_type_pkg.t_money
  , i_oper_currency                in     com_api_type_pkg.t_curr_code
  , i_dispute_reason               in     com_api_type_pkg.t_dict_value
  , i_due_date                     in     date
  , i_reason_code                  in     com_api_type_pkg.t_dict_value
  , i_disputed_amount              in     com_api_type_pkg.t_money
  , i_disputed_currency            in     com_api_type_pkg.t_curr_code
  , i_arn                          in     com_api_type_pkg.t_card_number
  , i_claim_id                     in     com_api_type_pkg.t_long_id       default null
  , i_auth_code                    in     com_api_type_pkg.t_auth_code
  , i_merchant_name                in     com_api_type_pkg.t_name
  , i_transaction_code             in     com_api_type_pkg.t_cmid
  , i_agent_id                     in     com_api_type_pkg.t_short_id      default null
  , i_card_number                  in     com_api_type_pkg.t_card_number   default null
) as
    l_application                         app_api_type_pkg.t_application_rec;
    l_comment                             com_api_type_pkg.t_text;
    LOG_PREFIX               constant     com_api_type_pkg.t_name          := lower($$PLSQL_UNIT) || '.modify_application ';
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' Start: i_case_id [#1]'
      , i_env_param1 => i_case_id
    );
    
    l_application := 
        app_api_application_pkg.get_application(
            i_appl_id     => i_case_id
          , i_raise_error => com_api_const_pkg.TRUE
        );
    l_comment :=
        csm_api_utl_pkg.get_case_comment(
            i_action      => csm_api_const_pkg.CASE_ACTION_STATUS_CHNG_LABEL
          , i_description => '"' || l_application.appl_status || '";"' || l_application.reject_code || '";'
        );
    app_ui_application_pkg.modify_application(
        i_appl_id           => i_case_id
      , io_seqnum           => io_seqnum
      , i_appl_status       => l_application.appl_status
      , i_comments          => l_comment
      , i_change_action     => csm_api_const_pkg.CASE_ACTION_EDIT_LABEL
      , i_reject_code       => l_application.reject_code
      , i_user_id           => l_application.user_id
      , i_agent_id          => i_agent_id
    );
    
    update csm_case_vw 
       set dispute_reason    = i_dispute_reason
         , due_date          = i_due_date
         , reason_code       = i_reason_code
         , disputed_amount   = i_disputed_amount
         , disputed_currency = i_disputed_currency
         , arn               = i_arn
         , claim_id          = i_claim_id
         , auth_code         = i_auth_code
         , transaction_code  = i_transaction_code
         , oper_date         = i_oper_date
         , oper_amount       = i_oper_amount
         , oper_currency     = i_oper_currency
         , merchant_name     = i_merchant_name
     where id = i_case_id;

    -- update card number if required
    if i_card_number is not null then
        update csm_card
           set card_number = iss_api_token_pkg.encode_card_number(i_card_number => i_card_number)
         where id = i_case_id
           and card_number != iss_api_token_pkg.encode_card_number(i_card_number => i_card_number);
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || sql%rowcount || ' cards were updated'
    );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' finish'
    );
end;

procedure remove_claim(
    i_claim_id                     in     com_api_type_pkg.t_long_id
  , i_seqnum                       in     com_api_type_pkg.t_seqnum
) as
    l_case_id                     com_api_type_pkg.t_long_id;
begin
    begin
        select c.id 
          into l_case_id
          from csm_case c 
         where c.claim_id = i_claim_id
           and rownum = 1;
    exception 
        when no_data_found then
            null;
    end;
    
    if l_case_id is not null then
        com_api_error_pkg.raise_error(
            i_error      => 'UNABLE_DELETE_CLAIM_ATTACHED_TO_CASE'
          , i_env_param1 => l_case_id
        );
    end if;
    
    app_ui_application_pkg.remove_application(
        i_appl_id => i_claim_id
      , i_seqnum  => i_seqnum
    );
    
    delete from csm_case_vw where id = i_claim_id;
end;

procedure set_application_user(
    i_case_id                in      com_api_type_pkg.t_long_id
  , io_seqnum                in out  com_api_type_pkg.t_tiny_id
  , i_user_id                in      com_api_type_pkg.t_short_id      default null
) is
    l_application                    app_api_type_pkg.t_application_rec;
    l_comment                        com_api_type_pkg.t_text;
    LOG_PREFIX       constant        com_api_type_pkg.t_name          := lower($$PLSQL_UNIT) || '.set_application_user ';
    l_action                         com_api_type_pkg.t_name;
    l_user_id                        com_api_type_pkg.t_short_id := i_user_id;
    l_old_name                       com_api_type_pkg.t_name;
    l_new_name                       com_api_type_pkg.t_name;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' Start: i_case_id [#1] i_user_id [#2]'
      , i_env_param1 => i_case_id
      , i_env_param2 => i_user_id
    );
    
    l_application := app_api_application_pkg.get_application(
                         i_appl_id      => i_case_id
                       , i_raise_error  => com_api_const_pkg.FALSE
                     );

    -- -1 to null
    if l_user_id = acm_api_const_pkg.UNDEFINED_USER_ID then
        l_user_id := null;
    end if;
    if l_application.user_id = acm_api_const_pkg.UNDEFINED_USER_ID then
        l_application.user_id := null;
    end if;

    if l_application.user_id is null and l_user_id is not null then
        l_action := csm_api_const_pkg.CASE_ACTION_OWNER_TAKE;
    elsif l_user_id is null and l_application.user_id is not null then
        l_action := csm_api_const_pkg.CASE_ACTION_OWNER_REFUSE;
    else
        l_action := csm_api_const_pkg.CASE_ACTION_OWNER_CHNG_LABEL;
    end if;

    -- fill person names
    if l_application.user_id is not null then
        l_old_name := com_ui_person_pkg.get_person_name(
                          i_person_id => acm_api_user_pkg.get_person_id(
                              i_user_name => acm_api_user_pkg.get_user_name(i_user_id    => l_application.user_id
                                                                          , i_mask_error => com_api_const_pkg.TRUE)
                          )
                      );
    end if;
    if l_user_id is not null then
        l_new_name := com_ui_person_pkg.get_person_name(
                          i_person_id => acm_api_user_pkg.get_person_id(
                              i_user_name => acm_api_user_pkg.get_user_name(i_user_id    => l_user_id
                                                                          , i_mask_error => com_api_const_pkg.TRUE)
                          )
                      );
    end if;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || ' l_action=' || l_action
    );
    l_comment :=
        csm_api_utl_pkg.get_case_comment(
            i_action      => l_action -- csm_api_const_pkg.CASE_ACTION_OWNER_CHNG_LABEL l_user_id
          , i_description => '"' || l_old_name
                                 || '";"'
                                 || l_new_name
                                 || '";'
        );
    app_ui_application_pkg.modify_application(
        i_appl_id           => i_case_id
      , io_seqnum           => io_seqnum
      , i_appl_status       => l_application.appl_status
      , i_resp_sess_file_id => null
      , i_comments          => l_comment
      , i_change_action     => csm_api_const_pkg.CASE_ACTION_OWNER_CHNG_LABEL
      , i_reject_code       => l_application.reject_code
      , i_event_type        => dsp_api_const_pkg.EVENT_DISPUTE_ASSIGNED_USER
      , i_user_id           => i_user_id
    );

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'end'
    );
end set_application_user;

function is_comment_enabled(
    i_case_id                in      com_api_type_pkg.t_long_id
  , i_case_status            in      com_api_type_pkg.t_dict_value
  , i_user_id                in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean is
    l_case_rec                       csm_api_type_pkg.t_csm_case_rec;
    l_case_status                    com_api_type_pkg.t_dict_value;
    l_result                         com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
begin
    if i_user_id = acm_api_const_pkg.UNDEFINED_USER_ID then
        l_result := com_api_const_pkg.FALSE;
    else
        if i_case_status is null then
            csm_api_case_pkg.get_case(
                i_case_id    => i_case_id
              , o_case_rec   => l_case_rec
              , i_mask_error => com_api_const_pkg.FALSE
            );

            l_case_status := l_case_rec.case_status;
        else
            l_case_status := i_case_status;
        end if;

        if l_case_status not in (app_api_const_pkg.APPL_STATUS_CLOSED, app_api_const_pkg.APPL_STATUS_CLOSED_WO_INV) then
            l_result := com_api_const_pkg.TRUE;
        else
            l_result := com_api_const_pkg.FALSE;
        end if;
    end if;
    return l_result;

end is_comment_enabled;

function is_team_enabled(
    i_case_id                in      com_api_type_pkg.t_long_id
  , i_case_status            in      com_api_type_pkg.t_dict_value
  , i_user_id                in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean is
    l_case_rec                       csm_api_type_pkg.t_csm_case_rec;
    l_case_status                    com_api_type_pkg.t_dict_value;
    l_result                         com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
begin
    if i_user_id = acm_api_const_pkg.UNDEFINED_USER_ID then
        l_result := com_api_const_pkg.FALSE;
    else
        if i_case_status is null then
            csm_api_case_pkg.get_case(
                i_case_id    => i_case_id
              , o_case_rec   => l_case_rec
              , i_mask_error => com_api_const_pkg.FALSE
            );

            l_case_status := l_case_rec.case_status;
        else
            l_case_status := i_case_status;
        end if;

        if l_case_status not in (app_api_const_pkg.APPL_STATUS_CLOSED, app_api_const_pkg.APPL_STATUS_CLOSED_WO_INV) then
            l_result := com_api_const_pkg.TRUE;
        else
            l_result := com_api_const_pkg.FALSE;
        end if;
    end if;
    return l_result;

end is_team_enabled;

function is_reassign_enabled(
    i_case_id                in      com_api_type_pkg.t_long_id
  , i_case_status            in      com_api_type_pkg.t_dict_value
  , i_user_id                in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean is
    l_case_rec                       csm_api_type_pkg.t_csm_case_rec;
    l_case_status                    com_api_type_pkg.t_dict_value;
    l_result                         com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
begin
    if i_user_id = acm_api_const_pkg.UNDEFINED_USER_ID then
        l_result := com_api_const_pkg.FALSE;
    else
        if i_case_status is null then
            csm_api_case_pkg.get_case(
                i_case_id    => i_case_id
              , o_case_rec   => l_case_rec
              , i_mask_error => com_api_const_pkg.FALSE
            );

            l_case_status := l_case_rec.case_status;
        else
            l_case_status := i_case_status;
        end if;

        if l_case_status not in (app_api_const_pkg.APPL_STATUS_CLOSED, app_api_const_pkg.APPL_STATUS_CLOSED_WO_INV) then
            l_result := com_api_const_pkg.TRUE;
        else
            l_result := com_api_const_pkg.FALSE;
        end if;
    end if;
    return l_result;

end is_reassign_enabled;

function is_letter_enabled(
    i_case_id                in      com_api_type_pkg.t_long_id
  , i_case_status            in      com_api_type_pkg.t_dict_value
  , i_user_id                in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean is
    l_case_rec                       csm_api_type_pkg.t_csm_case_rec;
    l_case_status                    com_api_type_pkg.t_dict_value;
    l_result                         com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
begin
    if i_user_id = acm_api_const_pkg.UNDEFINED_USER_ID or i_case_status = app_api_const_pkg.APPL_STATUS_CLOSED then
        l_result := com_api_const_pkg.FALSE;
    else
        if i_case_status is null then
            csm_api_case_pkg.get_case(
                i_case_id    => i_case_id
              , o_case_rec   => l_case_rec
              , i_mask_error => com_api_const_pkg.FALSE
            );

            l_case_status := l_case_rec.case_status;
        else
            l_case_status := i_case_status;
        end if;

        if l_case_status not in (app_api_const_pkg.APPL_STATUS_CLOSED, app_api_const_pkg.APPL_STATUS_CLOSED_WO_INV) then
            l_result := com_api_const_pkg.TRUE;
        else
            l_result := com_api_const_pkg.FALSE;
        end if;
    end if;
    return l_result;

end is_letter_enabled;

procedure case_close_wo_inv(
    i_case_id                      in     com_api_type_pkg.t_long_id  
) is
    LOG_PREFIX               constant     com_api_type_pkg.t_name          := lower($$PLSQL_UNIT) || '.case_close_wo_inv: ';
    l_reject_code                         com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' i_case_id'
    );
    l_reject_code := app_api_application_pkg.get_application(
                         i_appl_id     => i_case_id
                       , i_raise_error => com_api_const_pkg.TRUE
                     ).reject_code;

    change_case_status(
        i_case_id     => i_case_id
      , i_appl_status => app_api_const_pkg.APPL_STATUS_CLOSED_WO_INV
      , i_reject_code => l_reject_code
    );
end case_close_wo_inv;

procedure case_reopen_wo_inv(
    i_case_id                      in     com_api_type_pkg.t_long_id  
) is
    LOG_PREFIX               constant     com_api_type_pkg.t_name          := lower($$PLSQL_UNIT) || '.case_reopen_wo_inv: ';
    l_reject_code                         com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' i_case_id'
    );
    l_reject_code := app_api_application_pkg.get_application(
                         i_appl_id     => i_case_id
                       , i_raise_error => com_api_const_pkg.TRUE
                     ).reject_code;

    change_case_status(
        i_case_id     => i_case_id
      , i_appl_status => app_api_const_pkg.APPL_STATUS_PENDING
      , i_reject_code => l_reject_code
    );
end case_reopen_wo_inv;

procedure get_case_network (
    i_oper_id                      in     com_api_type_pkg.t_long_id
  , o_inst_id                      out    com_api_type_pkg.t_inst_id
  , o_network_id                   out    com_api_type_pkg.t_network_id
) is
begin

    select case when com_api_array_pkg.is_element_in_array(
                         i_array_id     => opr_api_const_pkg.STTL_TYPE_ISS_ARRAY_ID
                       , i_elem_value   => o.sttl_type
                     ) = com_api_const_pkg.TRUE
                then p.card_inst_id
                when com_api_array_pkg.is_element_in_array(
                         i_array_id     => opr_api_const_pkg.STTL_TYPE_ACQ_ARRAY_ID
                       , i_elem_value   => o.sttl_type
                     ) = com_api_const_pkg.TRUE
                then a.inst_id
           end as inst_id
         , p.card_network_id
      into o_inst_id
         , o_network_id
      from opr_operation_vw o 
 left join opr_participant_vw p on
           p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
       and p.oper_id          = o.id
 left join opr_participant_vw a on
           a.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
       and a.oper_id          = o.id
     where o.id               = i_oper_id;

exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error        => 'OPERATION_NOT_FOUND'
          , i_env_param1   => i_oper_id
        );
end get_case_network;

procedure get_case_network (
    i_card_number                  in     com_api_type_pkg.t_card_number  
  , i_inst_id                      in     com_api_type_pkg.t_inst_id 
  , o_network_id                   out    com_api_type_pkg.t_network_id     
)is
    l_inst_id            com_api_type_pkg.t_inst_id := i_inst_id;
    l_dummy              com_api_type_pkg.t_long_id;
begin
    iss_api_bin_pkg.get_bin_info(
        i_card_number      => i_card_number
      , o_card_inst_id     => l_dummy
      , o_card_network_id  => o_network_id
      , o_card_type        => l_dummy
      , o_card_country     => l_dummy
      , i_raise_error      => com_api_const_pkg.TRUE
    );

    if o_network_id is null then
        net_api_bin_pkg.get_bin_info(
            i_card_number     => i_card_number
          , io_iss_inst_id    => l_inst_id
          , o_iss_network_id  => l_dummy
          , o_iss_host_id     => l_dummy
          , o_card_type_id    => l_dummy
          , o_card_country    => l_dummy
          , o_card_inst_id    => l_dummy
          , o_card_network_id => o_network_id
          , o_pan_length      => l_dummy
          , i_raise_error     => com_api_const_pkg.TRUE
        );
    end if;
end;

procedure change_case_progress(
    i_case_id                 in     com_api_type_pkg.t_long_id
  , io_seqnum                 in out com_api_type_pkg.t_seqnum
  , i_case_progress           in     com_api_type_pkg.t_dict_value
  , i_reason_code             in     com_api_type_pkg.t_dict_value
  , i_mask_error              in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) is
begin
    csm_api_case_pkg.change_case_progress(
        i_case_id       => i_case_id
      , io_seqnum       => io_seqnum
      , i_case_progress => i_case_progress
      , i_reason_code   => i_reason_code
      , i_mask_error    => i_mask_error
    );
end change_case_progress;

procedure change_case_progress(
    i_dispute_id              in     com_api_type_pkg.t_long_id
  , io_seqnum                 in out com_api_type_pkg.t_seqnum
  , i_case_progress           in     com_api_type_pkg.t_dict_value
  , i_reason_code             in     com_api_type_pkg.t_dict_value
  , i_mask_error              in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) is
begin
    csm_api_case_pkg.change_case_progress(
        i_dispute_id    => i_dispute_id
      , io_seqnum       => io_seqnum
      , i_case_progress => i_case_progress
      , i_reason_code   => i_reason_code
      , i_mask_error    => i_mask_error
    );
end change_case_progress;

function get_flow_id(
    i_operation_id    in com_api_type_pkg.t_long_id
)
    return com_api_type_pkg.t_tiny_id
is
    l_operation_rec opr_api_type_pkg.t_oper_rec;
begin
    return csm_api_case_pkg.get_flow_id(i_operation_id);
end get_flow_id;

end csm_ui_case_pkg;
/
