CREATE OR REPLACE package body mcw_api_rule_proc_pkg is

procedure create_mc_fin_message is
    l_fin_id                        com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_network_id                    com_api_type_pkg.t_network_id;
    l_message_status                com_api_type_pkg.t_dict_value;
    l_collection_only               com_api_type_pkg.t_boolean;
    l_use_merchant_address          com_api_type_pkg.t_boolean;
begin
    l_use_merchant_address := nvl(opr_api_shared_data_pkg.get_param_num('USE_MERCHANT_ADDRESS'), com_api_type_pkg.FALSE);

    if opr_api_shared_data_pkg.g_auth.id is not null then
        select (
            select
                id
            from
                mcw_fin
            where
                id = opr_api_shared_data_pkg.g_auth.id
        )
        into
            l_fin_id
        from
            dual;

        if l_fin_id is not null then
            trc_log_pkg.debug(
                i_text          => 'Outgoing MasterCard message for operation [#1] already present with id [#2]'
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
                i_text          => 'Inst_id [#1], Network_id [#2], Message_status [#3], Collection_only [#4]'
              , i_env_param1    => l_inst_id
              , i_env_param2    => l_network_id
              , i_env_param3    => l_message_status
              , i_env_param4    => l_collection_only
            );

            if l_use_merchant_address = com_api_type_pkg.TRUE then
            -- Change merchant address in auth to merchant address from DB
                begin
                    select substr(upper(a.street), 1, 31)
                         , substr(upper(a.city), 1, 31)
                         , cn.name
                         , cn.code
                         , a.postal_code
                      into opr_api_shared_data_pkg.g_auth.merchant_street
                         , opr_api_shared_data_pkg.g_auth.merchant_city
                         , opr_api_shared_data_pkg.g_auth.merchant_region
                         , opr_api_shared_data_pkg.g_auth.merchant_country
                         , opr_api_shared_data_pkg.g_auth.merchant_postcode
                      from acq_terminal t
                         , com_address a
                         , com_address_object ao
                         , com_country cn
                     where t.terminal_number = opr_api_shared_data_pkg.g_auth.terminal_number
                       and t.inst_id = opr_api_shared_data_pkg.g_auth.acq_inst_id
                       and a.id = ao.address_id
                       and ao.object_id = t.merchant_id
                       and ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                       and ao.address_type = 'ADTPBSNA'
                       and a.lang = com_api_const_pkg.LANGUAGE_ENGLISH
                       and cn.code = a.country;
                exception
                    when no_data_found then
                        null;
                end;
            end if;
            mcw_api_fin_pkg.create_from_auth (
                i_auth_rec          => opr_api_shared_data_pkg.g_auth
                , i_id              => opr_api_shared_data_pkg.g_auth.id
                , i_inst_id         => l_inst_id
                , i_network_id      => l_network_id
                , i_status          => l_message_status
                , i_collection_only => l_collection_only
            );
        end if;
    end if;

end;

end;
/
