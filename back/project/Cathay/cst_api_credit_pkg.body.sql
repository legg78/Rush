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
    l_account                           acc_api_type_pkg.t_account_rec;
    l_mad_thres_fee_id                  com_api_type_pkg.t_long_id;
    l_mad_extra_fee_id                  com_api_type_pkg.t_long_id;
    l_mad_calc_thres                    com_api_type_pkg.t_money    := 0;
    l_mad_calc_extra                    com_api_type_pkg.t_money    := 0;
    l_currency                          com_api_type_pkg.t_curr_code;
    l_balance                           com_api_type_pkg.t_money    := 0;
    l_balance_total                     com_api_type_pkg.t_money    := 0;
    l_mandatory_amount_due              com_api_type_pkg.t_money    := 0;
    l_used_condition                    com_api_type_pkg.t_name;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_mandatory_amount_due (source) [#1], i_total_amount_due [#2], i_account_id [#3]'
                                   ||  ', i_currency [#4], i_aging_period [#5], i_eff_date [#6]'
      , i_env_param1 => i_mandatory_amount_due
      , i_env_param2 => i_total_amount_due
      , i_env_param3 => i_account_id
      , i_env_param4 => i_currency
      , i_env_param5 => i_aging_period
      , i_env_param6 => to_char(i_eff_date, 'dd.mm.yyyy hh24:mi:ss')
    );

    l_account :=
        acc_api_account_pkg.get_account(
            i_account_id        => i_account_id
          , i_mask_error        => com_api_const_pkg.FALSE
        );

    l_mad_thres_fee_id :=
        prd_api_product_pkg.get_attr_value_number(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => crd_api_const_pkg.MAD_CALC_THRESHOLD
          , i_service_id        => i_service_id
          , i_eff_date          => i_eff_date
          , i_split_hash        => l_account.split_hash
          , i_inst_id           => l_account.inst_id
          , i_mask_error        => com_api_const_pkg.TRUE
          , i_use_default_value => com_api_const_pkg.TRUE
          , i_default_value     => null
        );
    fcl_api_fee_pkg.get_fee_amount(
        i_fee_id            => l_mad_thres_fee_id
      , i_base_amount       => com_api_const_pkg.NONE
      , io_fee_currency     => l_currency
      , o_fee_amount        => l_mad_calc_thres
      , i_base_currency     => i_currency
      , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id         => i_account_id
      , i_eff_date          => i_eff_date
    );

    select nvl(sum(b.amount), 0)
      into l_balance
      from (select d.id
              from crd_debt d
             where decode(d.status, 'DBTSACTV', d.account_id, null) = i_account_id
               and d.split_hash     = l_account.split_hash
               and d.inst_id        = l_account.inst_id
            union
            select d.id
              from crd_debt d
             where decode(d.is_new, 1, d.account_id, null) = i_account_id
               and d.account_id     = i_account_id
               and d.split_hash     = l_account.split_hash
               and d.inst_id        = l_account.inst_id
           ) debt
         , crd_debt_balance b
     where b.debt_id        = debt.id
       and b.split_hash     = l_account.split_hash
       and b.balance_type   in (
                                 crd_api_const_pkg.BALANCE_TYPE_OVERDUE
                               , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST
                               , crd_api_const_pkg.BALANCE_TYPE_OVERLIMIT
                               , crd_api_const_pkg.BALANCE_TYPE_INSTALLMENT
                               , crd_api_const_pkg.BALANCE_TYPE_TMP_OVERLIMIT
                               );

    select nvl(sum(b.amount), 0)
      into l_balance_total
      from (select d.id
              from crd_debt d
             where decode(d.status, 'DBTSACTV', d.account_id, null) = i_account_id
               and d.split_hash     = l_account.split_hash
               and d.inst_id        = l_account.inst_id
            union
            select d.id
              from crd_debt d
             where decode(d.is_new, 1, d.account_id, null) = i_account_id
               and d.account_id     = i_account_id
               and d.split_hash     = l_account.split_hash
               and d.inst_id        = l_account.inst_id
           ) debt
         , crd_debt_balance b
     where b.debt_id        = debt.id
       and b.split_hash     = l_account.split_hash
       and b.balance_type   in (
                                 crd_api_const_pkg.BALANCE_TYPE_INTEREST
                               , crd_api_const_pkg.BALANCE_TYPE_OVERDRAFT
                               , crd_api_const_pkg.BALANCE_TYPE_PENALTY
                               , acc_api_const_pkg.BALANCE_TYPE_FEES
                               );

    l_mad_extra_fee_id :=
        prd_api_product_pkg.get_attr_value_number(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => crd_api_const_pkg.EXTRA_MANDATORY_AMOUNT_DUE
          , i_service_id        => i_service_id
          , i_eff_date          => i_eff_date
          , i_split_hash        => l_account.split_hash
          , i_inst_id           => l_account.inst_id
          , i_mask_error        => com_api_const_pkg.TRUE
          , i_use_default_value => com_api_const_pkg.TRUE
          , i_default_value     => null
        );
    fcl_api_fee_pkg.get_fee_amount(
        i_fee_id            => l_mad_extra_fee_id
      , i_base_amount       => l_balance_total
      , io_fee_currency     => l_currency
      , o_fee_amount        => l_mad_calc_extra
      , i_base_currency     => i_currency
      , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id         => i_account_id
      , i_eff_date          => i_eff_date
    );
    l_mad_calc_extra := round(l_mad_calc_extra, 0);

    if  l_mad_calc_extra            >= l_mad_calc_thres
    then
        l_mandatory_amount_due      := l_mandatory_amount_due + l_balance + l_mad_calc_extra;
        l_used_condition            := 'Used condition No.1';
    elsif     l_mad_calc_extra      <  l_mad_calc_thres
          and i_overdraft_balance   <  l_mad_calc_thres
    then
        l_mandatory_amount_due      := l_mandatory_amount_due + l_balance + l_balance_total;
        l_used_condition            := 'Used condition No.2';
    elsif     l_mad_calc_extra      <  l_mad_calc_thres
          and i_overdraft_balance   >= l_mad_calc_thres
    then
        l_mandatory_amount_due      := l_mandatory_amount_due + l_balance + l_mad_calc_thres;
        l_used_condition            := 'Used condition No.3';
    end if;

    if i_aging_period > 1 then
        l_mandatory_amount_due := nvl(i_total_amount_due, l_mandatory_amount_due);
    end if;

    -- Check lower threshold of mandatory amount due
    o_modified_amount_due :=
        crd_invoice_pkg.get_min_mad(
            i_mandatory_amount_due  => l_mandatory_amount_due
          , i_total_amount_due      => i_total_amount_due
          , i_account_id            => i_account_id
          , i_eff_date              => i_eff_date
          , i_currency              => i_currency
          , i_product_id            => i_product_id
          , i_service_id            => i_service_id
          , i_param_tab             => g_params
        );
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>> o_modified_amount_due = ' || o_modified_amount_due
                     || '; l_balance_total = ' || l_balance_total
                     || ', l_mad_calc_extra = ' || l_mad_calc_extra
                     || ', l_mad_calc_thres = ' || l_mad_calc_thres
                     || ', l_balance = ' || l_balance
                     || ', l_used_condition = ' || l_used_condition
    );
end;

end;
/
