create or replace package body opr_cst_shared_data_pkg is

procedure collect_global_oper_params(
    io_params       in out nocopy   com_api_type_pkg.t_param_tab
) is
    l_card_id               com_api_type_pkg.t_medium_id;
    l_account_id            com_api_type_pkg.t_account_id;
    l_contract_type         com_api_type_pkg.t_dict_value;
    l_oper_id               com_api_type_pkg.t_long_id;
    l_oper_type             com_api_type_pkg.t_dict_value;
    l_settlement_flag       com_api_type_pkg.t_tag;
    l_dpp_settlement_flag   com_api_type_pkg.t_tag;
begin
    trc_log_pkg.debug(
        i_text          => 'opr_cst_shared_data_pkg.collect_global_oper_params start'
    );

    l_card_id := opr_api_shared_data_pkg.g_iss_participant.card_id;

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

        if l_account_id is not null then
            begin
                select t.contract_type
                  into l_contract_type
                  from acc_account  a
                     , prd_contract t
                 where a.id         = l_account_id
                   and t.id         = a.contract_id;
    
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
    end if;

    l_oper_id := opr_api_shared_data_pkg.g_operation.id;
    l_oper_type := opr_api_shared_data_pkg.g_operation.oper_type;

    if l_oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER then
        begin
            select settlement_flag
              into l_dpp_settlement_flag
              from vis_fin_message
             where id = (select original_id
                           from opr_operation
                          where id = l_oper_id);

             opr_api_shared_data_pkg.set_param(
                 i_name      => 'DPP_SETTLEMENT_FLAG'
               , i_value     => l_dpp_settlement_flag
             );
        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text          => 'No data found in opr_cst_shared_data_pkg.collect_global_oper_params, param DPP_SETTLEMENT_FLAG, oper_id = [#1]'
                  , i_env_param1    => l_oper_id
                );
        end;
    else
        begin
            select settlement_flag
              into l_settlement_flag 
              from vis_fin_message
             where id = l_oper_id;

             opr_api_shared_data_pkg.set_param(
                 i_name      => 'SETTLEMENT_FLAG'
               , i_value     => l_settlement_flag
             );
        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text          => 'No data found in opr_cst_shared_data_pkg.collect_global_oper_params, param SETTLEMENT_FLAG, oper_id = [#1]'
                  , i_env_param1    => l_oper_id
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

end;
/
