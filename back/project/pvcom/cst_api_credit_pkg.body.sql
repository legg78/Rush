create or replace package body cst_api_credit_pkg as

procedure modify_mandatory_amount_due(
    i_mandatory_amount_due      in      com_api_type_pkg.t_money
  , i_total_amount_due          in      com_api_type_pkg.t_money
  , i_product_id                in      com_api_type_pkg.t_short_id
  , i_account_id                in      com_api_type_pkg.t_medium_id
  , i_currency                  in      com_api_type_pkg.t_curr_code
  , i_service_id                in      com_api_type_pkg.t_short_id
  , i_eff_date                  in      date
  , o_modified_amount_due          out  com_api_type_pkg.t_money
  , i_overdraft_balance         in      com_api_type_pkg.t_money
  , i_aging_period              in      com_api_type_pkg.t_tiny_id
) is
    LOG_PREFIX                 constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.modify_mandatory_amount_due ';
    l_overlimit_amount                  com_api_type_pkg.t_money;
    l_account                           acc_api_type_pkg.t_account_rec;
    l_exceed_limit                      com_api_type_pkg.t_amount_rec;
    l_currency                          com_api_type_pkg.t_curr_code := i_currency;
    l_calc_amount                       com_api_type_pkg.t_money := 0;
    l_minimum_mad                       com_api_type_pkg.t_money;
    l_new_dpp_amount                    com_api_type_pkg.t_money;
    l_invoice_id                        com_api_type_pkg.t_medium_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_mandatory_amount_due (source) [#1], i_total_amount_due [#2], i_account_id [#3]'
                                   ||  ', i_service_id [#4], i_product_id [#5], i_eff_date [#6]'
      , i_env_param1 => i_mandatory_amount_due
      , i_env_param2 => i_total_amount_due
      , i_env_param3 => i_account_id
      , i_env_param4 => i_service_id
      , i_env_param5 => i_product_id
      , i_env_param6 => to_char(i_eff_date, 'dd.mm.yyyy hh24:mi:ss')
    );

    l_account :=
        acc_api_account_pkg.get_account(
            i_account_id   => i_account_id
          , i_mask_error   => com_api_const_pkg.FALSE
        );

    l_invoice_id := crd_api_algo_proc_pkg.get_param_num(i_name => 'INVOICE_ID');

    l_exceed_limit :=
        acc_api_balance_pkg.get_balance_amount (
            i_account_id     => i_account_id
          , i_balance_type   => crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
          , i_date           => i_eff_date
          , i_date_type      => com_api_const_pkg.DATE_PURPOSE_BANK
          , i_mask_error     => com_api_const_pkg.TRUE
        );

    select nvl(sum(amount), 0)
      into l_new_dpp_amount
      from crd_debt_balance
     where debt_id in (
            select debt_id
              from crd_invoice_debt_vw cid
                 , crd_debt d
                 , dpp_payment_plan p
             where d.id           = cid.debt_id
               and d.oper_id      = p.reg_oper_id
               and cid.invoice_id = l_invoice_id
               and cid.is_new     = com_api_const_pkg.TRUE
               and d.macros_type_id in (
                       cst_pvc_const_pkg.MACROS_TYPE_ID_DPP_PRINCIPAL  -- 1025
                     , cst_pvc_const_pkg.MACROS_TYPE_ID_DPP_INTEREST   -- 7013
                   )
           );

    if l_exceed_limit.amount < i_total_amount_due then -- we have overlimit
        l_overlimit_amount := i_total_amount_due - l_exceed_limit.amount;
    else
        l_overlimit_amount := 0;
    end if;

    trc_log_pkg.debug('l_exceed_limit.amount=[' || l_exceed_limit.amount || '], l_new_dpp_amount=[' || l_new_dpp_amount || '], l_overlimit_amount=[' || l_overlimit_amount || ']');

    prd_api_product_pkg.get_fee_amount(
        i_product_id     => i_product_id
      , i_entity_type    => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id      => i_account_id
      , i_fee_type       => crd_api_const_pkg.MAD_PERCENTAGE_FEE_TYPE
      , i_params         => g_params
      , i_service_id     => i_service_id
      , i_eff_date       => i_eff_date
      , i_split_hash     => l_account.split_hash
      , i_inst_id        => l_account.inst_id
      , i_base_amount    => greatest(0, i_total_amount_due - l_new_dpp_amount - l_overlimit_amount)
      , i_base_currency  => l_currency
      , io_fee_currency  => l_currency
      , o_fee_amount     => l_calc_amount
    );

    -- MAD = 5% of everything except overlimit and new DPP + 100% of overlimit + 100% of new DPP
    l_calc_amount := round(l_calc_amount + l_overlimit_amount + l_new_dpp_amount);
    trc_log_pkg.debug('calculated MAD: l_calc_amount=[' || l_calc_amount || ']');

    -- Apply minimum MAD:
    l_minimum_mad :=
        crd_invoice_pkg.get_min_mad(
            i_mandatory_amount_due  => l_calc_amount
          , i_total_amount_due      => i_total_amount_due
          , i_account_id            => i_account_id
          , i_eff_date              => i_eff_date
          , i_currency              => i_currency
          , i_product_id            => i_product_id
          , i_service_id            => i_service_id
          , i_param_tab             => g_params
          , i_split_hash            => l_account.split_hash
          , i_inst_id               => l_account.inst_id
        );

    o_modified_amount_due := least(greatest(l_calc_amount, l_minimum_mad), i_total_amount_due);

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>> o_modified_amount_due [#1]'
      , i_env_param1 => o_modified_amount_due
    );
end modify_mandatory_amount_due;

end cst_api_credit_pkg;
/
