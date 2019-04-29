create or replace package body crd_api_service_pkg as

procedure activate_service(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_eff_date          in      date
) is
    l_param_tab         com_api_type_pkg.t_param_tab;
    l_next_date         date;
    l_fee_id            com_api_type_pkg.t_short_id;
    l_exceed_limit      com_api_type_pkg.t_money;
    l_currency          com_api_type_pkg.t_curr_code;
    l_account_number    com_api_type_pkg.t_account_number;
    l_customer_id       com_api_type_pkg.t_medium_id;
    l_oper_id           com_api_type_pkg.t_long_id;
begin
--    fcl_api_cycle_pkg.switch_cycle(
--        i_cycle_type        => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE
--      , i_product_id        => i_product_id
--      , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
--      , i_object_id         => i_account_id
--      , i_params            => l_param_tab
--      , i_eff_date          => i_eff_date
--      , i_split_hash        => i_split_hash
--      , i_inst_id           => i_inst_id
--      , o_new_finish_date   => l_next_date
--    );

    fcl_api_cycle_pkg.switch_cycle(
        i_cycle_type        => crd_api_const_pkg.PROMOTIONAL_PERIOD_CYCLE_TYPE
      , i_product_id        => i_product_id
      , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id         => i_account_id
      , i_params            => l_param_tab
      , i_eff_date          => i_eff_date
      , i_split_hash        => i_split_hash
      , i_inst_id           => i_inst_id
      , o_new_finish_date   => l_next_date
    );

    fcl_api_cycle_pkg.switch_cycle(
        i_cycle_type        => crd_api_const_pkg.INTEREST_CHARGE_CYCLE_TYPE
      , i_product_id        => i_product_id
      , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id         => i_account_id
      , i_params            => l_param_tab
      , i_eff_date          => i_eff_date
      , i_split_hash        => i_split_hash
      , i_inst_id           => i_inst_id
      , o_new_finish_date   => l_next_date
    );

    l_fee_id := 
        prd_api_product_pkg.get_fee_id (
            i_product_id    => i_product_id
          , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => i_account_id
          , i_fee_type      => crd_api_const_pkg.LIMIT_VALUE_FEE_TYPE
          , i_params        => l_param_tab
          , i_eff_date      => i_eff_date            
          , i_inst_id       => i_inst_id
        );
            
    l_exceed_limit := 
        fcl_api_fee_pkg.get_fee_amount(
            i_fee_id            => l_fee_id
          , i_base_amount       => 0
          , io_base_currency    => l_currency
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_eff_date          => i_eff_date
        );

    select account_number
         , customer_id
      into l_account_number
         , l_customer_id
      from acc_account_vw
     where id = i_account_id;

    opr_api_create_pkg.create_operation(
        io_oper_id          => l_oper_id
      , i_is_reversal       => com_api_const_pkg.FALSE
      , i_oper_type         => crd_api_const_pkg.OPERATION_TYPE_PROVIDE_CREDIT
      , i_oper_reason       => null
      , i_msg_type          => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
      , i_status            => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
      , i_status_reason     => null
      , i_sttl_type         => opr_api_const_pkg.SETTLEMENT_INTERNAL_INTRAINST
      , i_oper_count        => 1
      , i_oper_amount       => l_exceed_limit
      , i_oper_currency     => l_currency
      , i_oper_date         => i_eff_date
      , i_host_date         => i_eff_date
    );
    
    opr_api_create_pkg.add_participant(
        i_oper_id           => l_oper_id
      , i_msg_type          => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
      , i_oper_type         => crd_api_const_pkg.OPERATION_TYPE_PROVIDE_CREDIT
      , i_participant_type  => com_api_const_pkg.PARTICIPANT_ISSUER
      , i_host_date         => i_eff_date
      , i_inst_id           => i_inst_id
      , i_customer_id       => l_customer_id
      , i_account_id        => i_account_id
      , i_account_number    => l_account_number
      , i_split_hash        => i_split_hash
      , i_without_checks    => com_api_const_pkg.TRUE
    );
end;

procedure deactivate_service(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_eff_date          in      date
) is
begin
    null;
end;

function get_active_service(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id       default null
  , i_mask_error        in      com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_short_id
is
    l_service_id        com_api_type_pkg.t_short_id;
    l_split_hash        com_api_type_pkg.t_tiny_id;
begin

    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(
                            i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id   => i_account_id
                        );
    else
        l_split_hash := i_split_hash;
    end if;

    begin
        select o.service_id
          into l_service_id
          from prd_service_object o
             , prd_service s
         where o.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
           and o.object_id       = i_account_id
           and i_eff_date between nvl(o.start_date, i_eff_date) and nvl(o.end_date, i_eff_date)
           and o.service_id      = s.id
           and s.service_type_id = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
           and o.split_hash      = l_split_hash;
    exception
        when no_data_found then
            if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error       => 'PRD_NO_ACTIVE_SERVICE'
                  , i_env_param1  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_env_param2  => i_account_id
                  , i_env_param3  => null
                  , i_env_param4  => i_eff_date
                  , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id   => i_account_id
                );
            end if;
    end;

    return l_service_id;
end;

end;
/
