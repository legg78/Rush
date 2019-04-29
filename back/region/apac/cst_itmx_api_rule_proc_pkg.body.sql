CREATE OR REPLACE package body cst_itmx_api_rule_proc_pkg is

procedure create_itmx_fin_message is
    LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.create_itmx_fin_message ';

    l_fin_id                        com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_network_id                    com_api_type_pkg.t_network_id;
    l_message_status                com_api_type_pkg.t_dict_value;
    l_collection_only               com_api_type_pkg.t_boolean;
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || '<< opr_api_shared_data_pkg.g_auth.id [#1]'
        , i_env_param1 => opr_api_shared_data_pkg.g_auth.id
    );

    if opr_api_shared_data_pkg.g_auth.id is not null then
        select (
            select
                id
            from
                cst_itmx_fin_message
            where
                id = opr_api_shared_data_pkg.g_auth.id
        )
        into
            l_fin_id
        from
            dual;

        if l_fin_id is not null then
            trc_log_pkg.debug(
                i_text          =>  LOG_PREFIX || ' Outgoing ITMX message for operation [#1] already present with id [#2]'
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
                i_name => 'NETWORK_ID'
                , i_mask_error  => com_api_type_pkg.TRUE
                , i_error_value => null
            );

            l_message_status := opr_api_shared_data_pkg.get_param_char(
                i_name => 'MESSAGE_STATUS'
                , i_mask_error  => com_api_type_pkg.TRUE
                , i_error_value => null
            );

            l_collection_only := opr_api_shared_data_pkg.get_param_num(
                i_name => 'COLLECTION_ONLY'
                , i_mask_error  => com_api_type_pkg.TRUE
                , i_error_value => null
            );

            trc_log_pkg.debug(
                i_text          => LOG_PREFIX || ' Inst_id [#1], Network_id [#2], Message_status [#3], Collection_only [#4]'
              , i_env_param1    => l_inst_id
              , i_env_param2    => l_network_id
              , i_env_param3    => l_message_status
              , i_env_param4    => l_collection_only
            );

            cst_itmx_api_fin_message_pkg.process_auth(
                i_auth_rec          => opr_api_shared_data_pkg.g_auth
              , io_fin_mess_id      => opr_api_shared_data_pkg.g_auth.id
              , i_inst_id           => l_inst_id
              , i_network_id        => l_network_id
              , i_status            => l_message_status
              , i_collect_only      => l_collection_only
            );
        end if;
    end if;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || '>>'
    );
end;

end;
/
