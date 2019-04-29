create or replace package body cst_bof_ghp_api_rule_proc_pkg is

procedure create_fin_message
is
    l_fin_id                        com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_network_id                    com_api_type_pkg.t_network_id;
    l_message_status                com_api_type_pkg.t_dict_value;
begin
    if opr_api_shared_data_pkg.g_auth.id is not null then
        begin
            select id
              into l_fin_id
              from cst_bof_ghp_fin_msg
             where id = opr_api_shared_data_pkg.g_auth.id;
        exception 
            when no_data_found then
                null;
        end;

        if l_fin_id is not null then
            trc_log_pkg.debug(
                i_text          => 'Outgoing GHIPPS message for operation [#1] already present with id [#2]'
              , i_env_param1    => opr_api_shared_data_pkg.g_auth.id
              , i_env_param2    => l_fin_id
            );
        else
            l_inst_id := 
                opr_api_shared_data_pkg.get_param_num(
                    i_name        => 'INST_ID'
                  , i_mask_error  => com_api_type_pkg.TRUE
                  , i_error_value => null
                );

            l_network_id := 
                 opr_api_shared_data_pkg.get_param_num(
                     i_name        => 'NETWORK_ID'
                   , i_mask_error  => com_api_type_pkg.TRUE
                   , i_error_value => null
                 );

            l_message_status := 
                opr_api_shared_data_pkg.get_param_char(
                    i_name        => 'MESSAGE_STATUS'
                  , i_mask_error  => com_api_type_pkg.TRUE
                  , i_error_value => null
                );

            trc_log_pkg.debug(
                i_text          => 'Inst_id [#1], Network_id [#2], Message_status [#3]'
              , i_env_param1    => l_inst_id
              , i_env_param2    => l_network_id
              , i_env_param3    => l_message_status
            );

            cst_bof_ghp_api_fin_msg_pkg.process_auth(
                i_auth_rec          => opr_api_shared_data_pkg.g_auth
              , io_fin_mess_id      => opr_api_shared_data_pkg.g_auth.id
              , i_inst_id           => l_inst_id
              , i_network_id        => l_network_id
              , i_status            => l_message_status
            );
        end if;
    end if;
end create_fin_message;

procedure load_dispute_parameters
is
    l_fin_id                        com_api_type_pkg.t_long_id;
begin
    l_fin_id := dsp_api_shared_data_pkg.get_param_num('ORIGINAL_ID');

    for r in (
        select *
          from cst_bof_ghp_fin_msg_vw
         where id = l_fin_id
    ) loop
        dsp_api_shared_data_pkg.set_param(
            i_name   => 'TRANSACTION_CODE'
          , i_value  => r.trans_code
        );
        dsp_api_shared_data_pkg.set_param(
            i_name   => 'USAGE_CODE'
          , i_value  => r.usage_code
        );
        dsp_api_shared_data_pkg.set_param(
            i_name   => 'IS_INCOMING'
          , i_value  => r.is_incoming
        );
        dsp_api_shared_data_pkg.set_param(
            i_name   => 'MCC'
          , i_value  => r.mcc
        );
        dsp_api_shared_data_pkg.set_param(
            i_name   => 'INST_ID'
          , i_value  => r.inst_id
        );
    end loop;
end load_dispute_parameters;

end;
/
