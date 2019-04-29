CREATE OR REPLACE package body cmp_api_rule_proc_pkg is

procedure create_cmp_fin_message is
    l_fin_id                        com_api_type_pkg.t_long_id;
    l_collection_only               com_api_type_pkg.t_boolean;
    l_status                        com_api_type_pkg.t_dict_value;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_network_id                    com_api_type_pkg.t_network_id;
begin
    if opr_api_shared_data_pkg.g_auth.id is not null then
        select (
            select
                id
            from
                cmp_fin_message
            where
                id = opr_api_shared_data_pkg.g_auth.id
        )
        into
            l_fin_id
        from
            dual;

        if l_fin_id is not null then
            trc_log_pkg.debug(
                i_text          => 'Outgoing CompassPlus message for operation [#1] already present with id [#2]'
              , i_env_param1    => opr_api_shared_data_pkg.g_auth.id
              , i_env_param2    => l_fin_id
            );
        else

            l_collection_only := opr_api_shared_data_pkg.get_param_num(
                i_name          => 'COLLECTION_ONLY'
                , i_mask_error  => com_api_type_pkg.TRUE
                , i_error_value => null
            );

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
                i_text          => 'Collection_only [#1], Message status [#2], Inst_id [#3], Network_id [#4]'
              , i_env_param1    => l_collection_only
              , i_env_param2    => l_status
              , i_env_param3    => l_inst_id
              , i_env_param4    => l_network_id
            );

            cmp_api_fin_message_pkg.process_auth(
                i_auth_rec          => opr_api_shared_data_pkg.g_auth
              , i_inst_id           => l_inst_id
              , i_network_id        => l_network_id
              , i_collect_only      => l_collection_only
              , i_status            => l_status
              , io_fin_mess_id      => opr_api_shared_data_pkg.g_auth.id
            );

        end if;
    end if;
end;

end;
/
