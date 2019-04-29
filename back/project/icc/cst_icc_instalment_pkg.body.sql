create or replace package body cst_icc_instalment_pkg as

procedure cancel_active_dpp
is
    l_account_id        com_api_type_pkg.t_account_id;
    l_entity_type       com_api_type_pkg.t_dict_value;
    l_object_id         com_api_type_pkg.t_long_id;
    l_params            com_api_type_pkg.t_param_tab;
    l_dpp_tab           dpp_api_type_pkg.t_dpp_tab;
begin
    l_params := evt_api_shared_data_pkg.g_params;

    l_entity_type   := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
    l_object_id     := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);

    if l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        l_account_id := l_object_id;
    end if;

    if l_account_id is null then
        trc_log_pkg.error(
            i_text          => 'ACCOUNT_NOT_FOUND'
          , i_env_param1    => l_account_id
        );
    else
        l_dpp_tab := dpp_api_payment_plan_pkg.get_dpp(i_account_id => l_account_id);

        for i in 1 .. l_dpp_tab.count() loop
            dpp_api_payment_plan_pkg.cancel_dpp(
                i_dpp_id           => l_dpp_tab(i).id
            );
        end loop;

        trc_log_pkg.debug(
            i_text       => 'cancel_active_dpp() >> #1 DPPs were processed'
          , i_env_param1 => l_dpp_tab.count()
        );
    end if;
end cancel_active_dpp;

end;
/
