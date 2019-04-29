create or replace package body cup_api_rule_proc_pkg is

procedure create_cup_fin_message is
    l_fin_id                        com_api_type_pkg.t_long_id;
    l_status                        com_api_type_pkg.t_dict_value;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_network_id                    com_api_type_pkg.t_network_id;
begin
    if opr_api_shared_data_pkg.g_auth.id is not null then
        select (
            select
                id
            from
                cup_fin_message
            where
                id = opr_api_shared_data_pkg.g_auth.id
        )
        into
            l_fin_id
        from
            dual;

        if l_fin_id is not null then
            trc_log_pkg.debug(
                i_text          => 'Outgoing CUP message for operation [#1] already present with id [#2]'
              , i_env_param1    => opr_api_shared_data_pkg.g_auth.id
              , i_env_param2    => l_fin_id
            );
        else

            l_status := opr_api_shared_data_pkg.get_param_char(
                i_name          => 'MESSAGE_STATUS'
                , i_mask_error  => com_api_type_pkg.TRUE
                , i_error_value => null
            );

            l_inst_id := opr_api_shared_data_pkg.get_param_num(
                i_name          => 'INST_ID'
                , i_mask_error  => com_api_type_pkg.TRUE
                , i_error_value => null
            );

            l_network_id := opr_api_shared_data_pkg.get_param_num(
                i_name => 'NETWORK_ID'
                , i_mask_error  => com_api_type_pkg.TRUE
                , i_error_value => null
            );

            trc_log_pkg.debug(
                i_text          => 'Message status [#1], Inst_id [#2], Network_id [#3]'
              , i_env_param1    => l_status
              , i_env_param2    => l_inst_id
              , i_env_param3    => l_network_id
            );

            cup_api_fin_message_pkg.process_auth(
                i_auth_rec          => opr_api_shared_data_pkg.g_auth
              , i_inst_id           => l_inst_id
              , i_network_id        => l_network_id
              , i_status            => l_status
              , io_fin_mess_id      => opr_api_shared_data_pkg.g_auth.id
            );

        end if;
    end if;
end;

procedure set_reimbursement_fee_amount is

    l_fin_msg_id                    com_api_type_pkg.t_long_id;
    l_amount                        com_api_type_pkg.t_money;
    l_currency                      com_api_type_pkg.t_curr_code;
    l_balance_impact                com_api_type_pkg.t_sign;

begin
    l_fin_msg_id := opr_api_shared_data_pkg.get_operation().id;
    
    select sttl_currency, reimbursement_fee_amount, reimbursement_fee_sign
      into l_currency, l_amount, l_balance_impact
      from cup_fee
     where fin_msg_id = l_fin_msg_id;
     
    opr_api_shared_data_pkg.set_amount (
        i_name        => opr_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME')
        , i_amount    => l_balance_impact*l_amount
        , i_currency  => l_currency
    );
    
    opr_api_shared_data_pkg.set_param(
        i_name    => 'BALANCE_IMPACT'
      , i_value   => l_balance_impact
    );
    
end set_reimbursement_fee_amount;

procedure set_service_fee_amount is

    l_fin_msg_id                    com_api_type_pkg.t_long_id;
    l_amount                        com_api_type_pkg.t_money;
    l_currency                      com_api_type_pkg.t_curr_code;
    l_balance_impact                com_api_type_pkg.t_sign;

begin
    l_fin_msg_id := opr_api_shared_data_pkg.get_operation().id;
    
    select sttl_currency, service_fee_amount, service_fee_sign
      into l_currency, l_amount, l_balance_impact
      from cup_fee
     where fin_msg_id = l_fin_msg_id;
     
    opr_api_shared_data_pkg.set_amount (
        i_name        => opr_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME')
        , i_amount    => l_balance_impact*l_amount
        , i_currency  => l_currency
    );
    
    opr_api_shared_data_pkg.set_param(
        i_name    => 'BALANCE_IMPACT'
      , i_value   => l_balance_impact
    );
    
end set_service_fee_amount;

end;
/
