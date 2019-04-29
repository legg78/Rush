create or replace package body cst_lvp_opr_rule_proc_pkg is

procedure select_auth_account is
    l_account               acc_api_type_pkg.t_account_rec;
    l_macros_type           com_api_type_pkg.t_tiny_id;
    l_selector              com_api_type_pkg.t_name;
    l_oper_id               com_api_type_pkg.t_long_id;
begin
    l_macros_type := to_number(opr_api_shared_data_pkg.get_param_char('MACROS_TYPE'));

    l_selector := opr_api_shared_data_pkg.get_param_char (
        i_name         => 'OPERATION_SELECTOR'
      , i_mask_error   => com_api_type_pkg.TRUE
      , i_error_value  => opr_api_const_pkg.OPER_SELECTOR_CURRENT
    );
    l_selector := nvl(l_selector, opr_api_const_pkg.OPER_SELECTOR_CURRENT);

    l_oper_id := opr_api_shared_data_pkg.get_operation_id (
        i_selector => l_selector
    );

    trc_log_pkg.debug (
        i_text         => 'Going to find authorization account by macros [#1][#2]'
      , i_env_param1   => l_oper_id
      , i_env_param2   => l_macros_type
      , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id    => l_oper_id
    );

    begin
        select a.id
             , a.account_number
             , a.currency
             , a.account_type
             , a.inst_id
             , a.agent_id
             , a.contract_id
             , a.customer_id
             , a.split_hash
          into l_account.account_id
             , l_account.account_number
             , l_account.currency
             , l_account.account_type
             , l_account.inst_id
             , l_account.agent_id
             , l_account.contract_id
             , l_account.customer_id
             , l_account.split_hash
          from acc_macros m
             , acc_account a
         where m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and m.object_id = l_oper_id
           and m.macros_type_id = l_macros_type
           and m.account_id = a.id;
    exception
        when no_data_found then
            trc_log_pkg.error (
                i_text        => 'LVP_NO_INFO_FOR_OPERATION_AND_MACROS_TYPE'
              , i_env_param1  => l_oper_id
              , i_env_param2  => l_macros_type
            );
        when too_many_rows then
            trc_log_pkg.error (
                i_text        => 'LVP_TOO_MANY_MACROSES_FOR_OPERATION'
              , i_env_param1  => l_oper_id
              , i_env_param2  => l_macros_type
            );
    end;

    opr_api_shared_data_pkg.set_account (
        i_name         => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , i_account_rec  => l_account
    );

    rul_api_shared_data_pkg.load_account_params(
        i_account_id    => l_account.account_id
      , io_params       => opr_api_shared_data_pkg.g_params
    );
end select_auth_account;

procedure select_reversal_status is
    l_selector              com_api_type_pkg.t_name;
    l_oper_id               com_api_type_pkg.t_long_id;
begin
    l_selector :=
        opr_api_shared_data_pkg.get_param_char (
            i_name         => 'OPERATION_SELECTOR'
          , i_mask_error   => com_api_type_pkg.TRUE
          , i_error_value  => opr_api_const_pkg.OPER_SELECTOR_CURRENT
        );
    l_selector := nvl(l_selector, opr_api_const_pkg.OPER_SELECTOR_CURRENT);
    l_oper_id  := opr_api_shared_data_pkg.get_operation_id(i_selector => l_selector);

    trc_log_pkg.debug(
        i_text => 'opr_cst_rule_proc_pkg.select_reversal_status - oper_id [' || l_oper_id || '] '
    );

    for rec in (
        select nvl(max(1), 0) reversal_match_status
          from crd_payment p
             , crd_debt d
             , crd_debt_payment dp
         where p.oper_id     = l_oper_id
           and p.is_reversal = com_api_const_pkg.TRUE
           and p.id          = dp.pay_id
           and dp.debt_id    = d.id
           and d.oper_id     = p.original_oper_id
           and p.amount      = dp.pay_amount
    ) loop
        rul_api_param_pkg.set_param(
            i_name    => 'REVERSAL_MATCH_STATUS'
          , i_value   => rec.reversal_match_status
          , io_params => opr_api_shared_data_pkg.g_params
        );
    end loop;
end select_reversal_status;

procedure check_payment_ability
is
    l_amount_name                   com_api_type_pkg.t_name;
    l_account_name                  com_api_type_pkg.t_name;
    l_aval_amount                   com_api_type_pkg.t_money;
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_account                       acc_api_type_pkg.t_account_rec;
begin
    l_account_name := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME');
    opr_api_shared_data_pkg.get_account(
        i_name              => l_account_name
      , o_account_rec       => l_account
    );

    l_amount_name := opr_api_shared_data_pkg.get_param_char('AMOUNT_NAME');
    opr_api_shared_data_pkg.get_amount(
        i_name      => l_amount_name
      , o_amount    => l_amount.amount
      , o_currency  => l_amount.currency
    );

    l_aval_amount := 
        acc_api_balance_pkg.get_aval_balance_amount_only(
            i_account_id  => l_account.account_id
        );

    if l_amount.amount <= l_aval_amount then
        opr_api_shared_data_pkg.set_param (
            i_name   => 'CHK_PAYABLE'
          , i_value  => com_api_type_pkg.TRUE
        );
    else
        opr_api_shared_data_pkg.set_param (
            i_name   => 'CHK_PAYABLE'
          , i_value  => com_api_type_pkg.FALSE
        );
    end if;
end check_payment_ability;

procedure get_debt_level
is
    l_account                       acc_api_type_pkg.t_account_rec;
    l_debt_level                    com_api_type_pkg.t_tiny_id;
begin
    opr_api_shared_data_pkg.get_account (
        i_name              => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , o_account_rec       => l_account
    );

    l_debt_level := 
        cst_lvp_com_pkg.get_debt_level(
            i_account_id    => l_account.account_id
        );

    opr_api_shared_data_pkg.set_param(
        i_name     => 'DEBT_LEVEL'
      , i_value    => l_debt_level
    );
end get_debt_level;

procedure get_current_fee_debt
is
    l_account                       acc_api_type_pkg.t_account_rec;
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_result_amount_name            com_api_type_pkg.t_name;
begin
    opr_api_shared_data_pkg.get_account (
        i_name              => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , o_account_rec       => l_account
    );

    l_result_amount_name := opr_api_shared_data_pkg.get_param_char(
        i_name           => 'RESULT_AMOUNT_NAME'
      , i_mask_error     => com_api_type_pkg.FALSE
    );

    l_amount := 
        cst_lvp_com_pkg.current_fee_debt(
            i_account_id    => l_account.account_id
        );

    opr_api_shared_data_pkg.set_amount (
        i_name        => l_result_amount_name
      , i_amount      => l_amount.amount
      , i_currency    => l_amount.currency
    );
end get_current_fee_debt;

procedure get_current_interest_debt
is
    l_account                       acc_api_type_pkg.t_account_rec;
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_result_amount_name            com_api_type_pkg.t_name;
begin
    opr_api_shared_data_pkg.get_account (
        i_name              => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , o_account_rec       => l_account
    );

    l_result_amount_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name           => 'RESULT_AMOUNT_NAME'
          , i_mask_error     => com_api_type_pkg.FALSE
        );

    l_amount := 
        cst_lvp_com_pkg.current_interest_debt(
            i_account_id     => l_account.account_id
        );

    opr_api_shared_data_pkg.set_amount(
        i_name        => l_result_amount_name
      , i_amount      => l_amount.amount
      , i_currency    => l_amount.currency
    );
end get_current_interest_debt;

procedure get_current_main_debt
is
    l_account                       acc_api_type_pkg.t_account_rec;
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_result_amount_name            com_api_type_pkg.t_name;
begin
    opr_api_shared_data_pkg.get_account (
        i_name              => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , o_account_rec       => l_account
    );

    l_result_amount_name := opr_api_shared_data_pkg.get_param_char(
        i_name           => 'RESULT_AMOUNT_NAME'
      , i_mask_error     => com_api_type_pkg.FALSE
    );

    l_amount := 
        cst_lvp_com_pkg.current_main_debt(
            i_account_id    => l_account.account_id
        );

    opr_api_shared_data_pkg.set_amount (
        i_name        => l_result_amount_name
      , i_amount      => l_amount.amount
      , i_currency    => l_amount.currency
    );
end get_current_main_debt;


procedure get_spent_own_funds
is
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_result_amount_name            com_api_type_pkg.t_name;
    l_macros_type                   com_api_type_pkg.t_tiny_id;
    l_selector                      com_api_type_pkg.t_name;
    l_oper_id                       com_api_type_pkg.t_long_id;
    l_count                         com_api_type_pkg.t_long_id;
begin
    l_macros_type := to_number(opr_api_shared_data_pkg.get_param_char('MACROS_TYPE'));

    l_selector := opr_api_shared_data_pkg.get_param_char (
        i_name         => 'OPERATION_SELECTOR'
      , i_mask_error   => com_api_type_pkg.TRUE
      , i_error_value  => opr_api_const_pkg.OPER_SELECTOR_CURRENT
    );
    l_selector := nvl(l_selector, opr_api_const_pkg.OPER_SELECTOR_CURRENT);

    l_oper_id := opr_api_shared_data_pkg.get_operation_id (
        i_selector => l_selector
    );

    l_result_amount_name := opr_api_shared_data_pkg.get_param_char(
        i_name           => 'RESULT_AMOUNT_NAME'
      , i_mask_error     => com_api_type_pkg.FALSE
    );

    trc_log_pkg.debug (
        i_text         => 'Operation [#1], macros type [#2], result amount name [#3]'
      , i_env_param1   => l_oper_id
      , i_env_param2   => l_macros_type
      , i_env_param3   => l_result_amount_name
      , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id    => l_oper_id
    );

    select nvl(sum(greatest(0, nvl(cd.amount, 0) - nvl(cd.debt_amount, 0))), 0)
         , max(cd.currency)
         , count(*)
      into l_amount.amount
         , l_amount.currency
         , l_count
      from crd_debt cd
     where cd.oper_id = l_oper_id
       and cd.macros_type_id = l_macros_type;

    trc_log_pkg.debug (
        i_text         => 'Amount [#1], currency [#2], debts count [#3]'
      , i_env_param1   => l_amount.amount
      , i_env_param2   => l_amount.currency
      , i_env_param3   => l_count
      , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id    => l_oper_id
    );

    opr_api_shared_data_pkg.set_amount (
        i_name        => l_result_amount_name
      , i_amount      => l_amount.amount
      , i_currency    => l_amount.currency
    );

end get_spent_own_funds;

procedure get_mcw_billing_amount
is
    l_selector                      com_api_type_pkg.t_name;
    l_oper_id                       com_api_type_pkg.t_long_id;
    l_result_amount_name            com_api_type_pkg.t_name;
    l_fin_rec                       mcw_api_type_pkg.t_fin_rec;
begin
    l_selector :=
        opr_api_shared_data_pkg.get_param_char (
            i_name         => 'OPERATION_SELECTOR'
          , i_mask_error   => com_api_type_pkg.TRUE
          , i_error_value  => opr_api_const_pkg.OPER_SELECTOR_CURRENT
        );
    l_selector := nvl(l_selector, opr_api_const_pkg.OPER_SELECTOR_CURRENT);
    l_oper_id  := opr_api_shared_data_pkg.get_operation_id (i_selector => l_selector);

    l_result_amount_name :=
        opr_api_shared_data_pkg.get_param_char(
            i_name           => 'RESULT_AMOUNT_NAME'
          , i_mask_error     => com_api_type_pkg.FALSE
        );

    mcw_api_fin_pkg.get_fin(
        i_id             => l_oper_id
      , o_fin_rec        => l_fin_rec
      , i_mask_error     => com_api_type_pkg.TRUE
    );

    trc_log_pkg.debug (
        i_text         => 'Operation [#1], de006 value [#2], de051 value [#3],  result amount name [#4]'
      , i_env_param1   => l_oper_id
      , i_env_param2   => l_fin_rec.de006
      , i_env_param3   => l_fin_rec.de051
      , i_env_param4   => l_result_amount_name
      , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id    => l_oper_id
    );

    opr_api_shared_data_pkg.set_amount (
        i_name        => l_result_amount_name
      , i_amount      => l_fin_rec.de006
      , i_currency    => l_fin_rec.de051
    );
end get_mcw_billing_amount;

end cst_lvp_opr_rule_proc_pkg;
/
