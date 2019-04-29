create or replace package body opr_cst_shared_data_pkg is

procedure collect_global_oper_params(
    io_params       in out nocopy   com_api_type_pkg.t_param_tab
) is
    l_card_id               com_api_type_pkg.t_medium_id;
    l_account_id            com_api_type_pkg.t_account_id;
    l_contract_type         com_api_type_pkg.t_dict_value;
    l_client_id_type        com_api_type_pkg.t_dict_value;

begin
    trc_log_pkg.debug(
        i_text          => 'opr_cst_shared_data_pkg.collect_global_oper_params start'
    );

    l_card_id := opr_api_shared_data_pkg.g_iss_participant.card_id;
    l_client_id_type := opr_api_shared_data_pkg.g_iss_participant.client_id_type;

    opr_api_shared_data_pkg.set_param(
        i_name   => 'CLIENT_ID_TYPE'
      , i_value  => l_client_id_type
    );

    if l_card_id is not null then
        begin
            select t.contract_type
              into l_contract_type
              from iss_card     c
                 , prd_contract t
             where c.id         = l_card_id
               and t.id         = c.contract_id
                 ;

            opr_api_shared_data_pkg.set_param(
                i_name   => 'CONTRACT_TYPE'
              , i_value  => l_contract_type
            );
        exception
            when no_data_found then
                trc_log_pkg.error(
                    i_text          => 'CONTRACT_ID_NOT_DEFINED'
                  , i_env_param1    => l_card_id
                );
        end;

    else
        l_account_id := opr_api_shared_data_pkg.g_iss_participant.account_id;

        begin
            select t.contract_type
              into l_contract_type
              from acc_account  a
                 , prd_contract t
             where a.id         = l_account_id
               and t.id         = a.contract_id
                 ;

            opr_api_shared_data_pkg.set_param(
                i_name   => 'CONTRACT_TYPE'
              , i_value  => l_contract_type
            );
        exception
            when no_data_found then
                trc_log_pkg.error(
                    i_text          => 'CONTRACT_ID_NOT_DEFINED'
                  , i_env_param1    => l_account_id
                );
        end;

    end if;

    trc_log_pkg.debug(
        i_text          => 'opr_cst_shared_data_pkg.collect_global_oper_params end'
    );
end;

procedure collect_oper_params(
    i_oper          in              opr_api_type_pkg.t_oper_rec         default null
  , i_iss_part      in              opr_api_type_pkg.t_oper_part_rec    default null
  , i_acq_part      in              opr_api_type_pkg.t_oper_part_rec    default null
  , io_params       in out nocopy   com_api_type_pkg.t_param_tab
) is
begin
    trc_log_pkg.debug(
        i_text          => 'opr_cst_shared_data_pkg.collect_oper_params dummy'
    );
end;

end opr_cst_shared_data_pkg;
/
