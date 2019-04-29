create or replace package body nbc_api_rule_proc_pkg is

procedure create_nbc_fin_message is
    l_fin_id                        com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_network_id                    com_api_type_pkg.t_network_id;
    l_message_status                com_api_type_pkg.t_dict_value;
begin
    if opr_api_shared_data_pkg.g_auth.id is not null then
        select (
            select
                id
            from
                nbc_fin_message
            where
                id = opr_api_shared_data_pkg.g_auth.id
        )
        into
            l_fin_id
        from
            dual;

        if l_fin_id is not null then
            trc_log_pkg.debug(
                i_text          => 'Outgoing NBC message for operation [#1] already present with id [#2]'
              , i_env_param1    => opr_api_shared_data_pkg.g_auth.id
              , i_env_param2    => l_fin_id
            );
        else
            l_inst_id := opr_api_shared_data_pkg.get_param_num(
                i_name          => 'INST_ID'
                , i_mask_error  => com_api_type_pkg.TRUE
                , i_error_value => null
            );

            l_network_id := opr_api_shared_data_pkg.get_param_num(
                i_name          => 'NETWORK_ID'
                , i_mask_error  => com_api_type_pkg.TRUE
                , i_error_value => null
            );

            l_message_status := opr_api_shared_data_pkg.get_param_char(
                i_name => 'MESSAGE_STATUS'
                , i_mask_error  => com_api_type_pkg.TRUE
                , i_error_value => null
            );

            trc_log_pkg.debug(
                i_text          => 'Inst_id [#1], Network_id [#2], Message_status [#3]'
              , i_env_param1    => l_inst_id
              , i_env_param2    => l_network_id
              , i_env_param3    => l_message_status
            );

            trc_log_pkg.debug(
                i_text          => 'Id of message [#1]'
              , i_env_param1    => opr_api_shared_data_pkg.g_auth.id
            );

            nbc_api_fin_message_pkg.process_auth (
                i_auth_rec          => opr_api_shared_data_pkg.g_auth
                , i_inst_id         => l_inst_id
                , i_network_id      => l_network_id
                , i_status          => l_message_status
                , io_fin_mess_id    => opr_api_shared_data_pkg.g_auth.id
            );
            
        end if;
    end if;
end;

end;
/
