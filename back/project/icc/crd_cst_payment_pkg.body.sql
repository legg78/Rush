create or replace package body crd_cst_payment_pkg as

procedure apply_payment(
    i_payment_id        in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_account_id        in      com_api_type_pkg.t_account_id
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_account_type      in      com_api_type_pkg.t_dict_value
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , io_payment_amount   in out  com_api_type_pkg.t_money
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.apply_payment'; 
    l_dpp_tab                   dpp_api_type_pkg.t_dpp_tab;
    l_index                     binary_integer;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << i_payment_id [#1], i_account_id [#2], io_payment_amount [#3]'
      , i_env_param1 => i_payment_id
      , i_env_param2 => i_account_id
      , i_env_param3 => io_payment_amount
    );

    if  io_payment_amount > 0
        and
        opr_api_shared_data_pkg.get_operation().oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER
    then
        com_api_error_pkg.raise_error(
            i_error      => 'CST_ICC_IMPOSSIBLE_TO_APPLY_PAYMENT_FOR_DPP_REGISTRATION'
          , i_env_param1 => i_payment_id
          , i_env_param2 => i_account_id
          , i_env_param3 => io_payment_amount
          , i_env_param4 => dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER
        );
    end if;

    l_dpp_tab := dpp_api_payment_plan_pkg.get_dpp(i_account_id => i_account_id);

    -- Use all amount <io_payment_amount> for full or partial advanced repayment DPPs for the account
    l_index := l_dpp_tab.first(); -- 1st DPP by date of creation
    while io_payment_amount > 0 and l_index <= l_dpp_tab.last() loop
        dpp_api_payment_plan_pkg.accelerate_dpp(
            i_dpp_id            => l_dpp_tab(l_index).id
          , i_new_count         => null
          , i_payment_amount    => least(io_payment_amount, l_dpp_tab(l_index).dpp_amount)
          , i_acceleration_type => dpp_api_const_pkg.DPP_ACCELERT_KEEP_INSTLMT_AMT
        );
        io_payment_amount := io_payment_amount - l_dpp_tab(l_index).dpp_amount;
        l_index           := l_dpp_tab.next(l_index);
    end loop;

    io_payment_amount := greatest(io_payment_amount, 0);

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >> #1 DPPs were processed of #2 in total for the account'
                                   || ', the rest of io_payment_amount is [#3]'
      , i_env_param1 => nvl(l_index - 1, 0)
      , i_env_param2 => l_dpp_tab.count()
      , i_env_param3 => io_payment_amount
    );
end apply_payment;

procedure enum_debt_order(
    io_cur_debts        in out  com_api_type_pkg.t_ref_cur
  , io_query            in out  com_api_type_pkg.t_text
  , io_order_by         in out  com_api_type_pkg.t_text
  , i_account_id        in      com_api_type_pkg.t_account_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_eff_date          in      date
  , i_original_oper_id  in      com_api_type_pkg.t_long_id
  , i_payment_condition in      com_api_type_pkg.t_dict_value
  , i_repay_mad_first   in      com_api_type_pkg.t_boolean
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.enum_debt_order'; 
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_ray_older_trnsct_first    com_api_type_pkg.t_boolean;
begin
    l_ray_older_trnsct_first :=
        nvl(
            prd_api_product_pkg.get_attr_value_number(
                i_product_id   => i_product_id
              , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id    => i_account_id
              , i_attr_name    => 'CST_ICC_RAY_OLDER_TRANSACTIONS_FIRST'
              , i_split_hash   => i_split_hash
              , i_service_id   => i_service_id
              , i_params       => l_param_tab
              , i_eff_date     => i_eff_date
              , i_inst_id      => i_inst_id
            )
          , com_api_const_pkg.TRUE
        );

    if l_ray_older_trnsct_first = com_api_const_pkg.FALSE then
        io_order_by := io_order_by || ' desc'; -- add descending sorting for field <d.posting_date>
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >> l_ray_older_trnsct_first [' || l_ray_older_trnsct_first
                                   || '], io_order_by [#1]'
      , i_env_param1 => io_order_by
    );
end;

end;
/
