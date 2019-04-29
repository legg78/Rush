create or replace package body opr_cst_rule_proc_pkg is

procedure update_repay_priority_before is
    l_selector              com_api_type_pkg.t_name;
    l_oper_id               com_api_type_pkg.t_long_id;
    l_oper_id_orig          com_api_type_pkg.t_long_id;
    l_debt_balance_id       com_api_type_pkg.t_long_id;
    l_oper_type             com_api_type_pkg.t_dict_value;
    l_fee_repay_prior       com_api_type_pkg.t_long_id;
    l_orig_repay_prior      com_api_type_pkg.t_medium_id;
begin
    l_selector := opr_api_shared_data_pkg.get_param_char (
                      i_name              => 'OPERATION_SELECTOR'
                    , i_mask_error        => com_api_type_pkg.TRUE
                    , i_error_value       => opr_api_const_pkg.OPER_SELECTOR_CURRENT
                  );
                  
    l_selector := nvl(l_selector, opr_api_const_pkg.OPER_SELECTOR_CURRENT);

    l_oper_id := opr_api_shared_data_pkg.get_operation_id (
                     i_selector => l_selector
                 );

    trc_log_pkg.debug(
        i_text => 'opr_cst_rule_proc_pkg.update_repay_priority_before - oper_id [' || l_oper_id || '] '
    );

    select oper_type
      into l_oper_type
      from opr_operation
     where id = l_oper_id;

    if l_oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER --'OPTP1501'
    then
        select original_id
          into l_oper_id_orig
          from opr_operation
         where id = l_oper_id;
    else
        l_oper_id_orig := l_oper_id;
    end if;

    --Get id and priority of the debt before changing priority
    select cdb.repay_priority
         , cdb.id
      into l_orig_repay_prior
         , l_debt_balance_id
      from crd_debt cd
         , crd_debt_balance cdb
     where cd.id = cdb.debt_id
       and cd.split_hash = cdb.split_hash
       and cd.oper_id = l_oper_id_orig
       and cd.macros_type_id = cst_pvc_const_pkg.MACROS_TYPE_ID_DEBIT_ON_OPER --1004
       and cdb.balance_type = acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT --'BLTP1002'
       ;

    --Get MIN priority of fees
    select min(cdb.repay_priority)
      into l_fee_repay_prior
      from crd_debt cd
         , crd_debt_balance cdb
     where cd.id = cdb.debt_id
       and cd.split_hash = cdb.split_hash
       and cd.oper_id = l_oper_id_orig
       and cd.macros_type_id = cst_pvc_const_pkg.MACROS_TYPE_ID_DEBIT_FEE --1007
       and cdb.balance_type = acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT --'BLTP1002'
       ;

    l_fee_repay_prior := nvl(l_fee_repay_prior, l_orig_repay_prior + 1);
        
    opr_api_shared_data_pkg.set_param(
        i_name      => 'ORI_REPAYMENT_PRIORITY'
      , i_value     => l_orig_repay_prior
    );

    update crd_debt_balance
       set repay_priority = l_fee_repay_prior - 1
     where id = l_debt_balance_id;

end update_repay_priority_before;

procedure update_repay_priority_after is
    l_selector              com_api_type_pkg.t_name;
    l_oper_id               com_api_type_pkg.t_long_id;
    l_oper_id_orig          com_api_type_pkg.t_long_id;
    l_debt_balance_id       com_api_type_pkg.t_long_id;
    l_oper_type             com_api_type_pkg.t_dict_value;
    l_orig_repay_prior      com_api_type_pkg.t_medium_id;
begin
    l_selector := opr_api_shared_data_pkg.get_param_char (
                      i_name              => 'OPERATION_SELECTOR'
                    , i_mask_error        => com_api_type_pkg.TRUE
                    , i_error_value       => opr_api_const_pkg.OPER_SELECTOR_CURRENT
                  );
                  
    l_selector := nvl(l_selector, opr_api_const_pkg.OPER_SELECTOR_CURRENT);

    l_oper_id := opr_api_shared_data_pkg.get_operation_id (
                     i_selector => l_selector
                 );

    trc_log_pkg.debug(
        i_text => 'opr_cst_rule_proc_pkg.update_repay_priority_after - oper_id [' || l_oper_id || '] '
    );
    
    select oper_type
      into l_oper_type
      from opr_operation
     where id = l_oper_id;

    if l_oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER --'OPTP1501'
    then
        select original_id
          into l_oper_id_orig
          from opr_operation
         where id = l_oper_id;
    else
        l_oper_id_orig := l_oper_id;
    end if;

    select cdb.id
      into l_debt_balance_id
      from crd_debt cd
         , crd_debt_balance cdb
     where cd.id = cdb.debt_id
       and cd.split_hash = cdb.split_hash
       and cd.oper_id = l_oper_id_orig
       and cd.macros_type_id = cst_pvc_const_pkg.MACROS_TYPE_ID_DEBIT_ON_OPER --1004
       and cdb.balance_type = acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT --'BLTP1002'
       ;

    l_orig_repay_prior := opr_api_shared_data_pkg.get_param_num(
                              i_name        => 'ORI_REPAYMENT_PRIORITY'
                            , i_mask_error  => com_api_type_pkg.TRUE
                          );
    
    update crd_debt_balance
       set repay_priority = nvl(l_orig_repay_prior, repay_priority)
     where id = l_debt_balance_id;

end update_repay_priority_after;

procedure select_auth_account is
    l_account               acc_api_type_pkg.t_account_rec;
    l_macros_type           com_api_type_pkg.t_tiny_id;
    l_selector              com_api_type_pkg.t_name;
    l_oper_id               com_api_type_pkg.t_long_id;

begin
    l_macros_type := opr_api_shared_data_pkg.get_param_char('MACROS_TYPE');

    l_selector := opr_api_shared_data_pkg.get_param_char (
                      i_name              => 'OPERATION_SELECTOR'
                    , i_mask_error        => com_api_type_pkg.TRUE
                    , i_error_value       => opr_api_const_pkg.OPER_SELECTOR_CURRENT
                  );
    
    l_selector := nvl(l_selector, opr_api_const_pkg.OPER_SELECTOR_CURRENT);

    l_oper_id := opr_api_shared_data_pkg.get_operation_id (
        i_selector => l_selector
    );

    trc_log_pkg.debug (
        i_text              => 'Going to find authorization account by macros [#1][#2]'
      , i_env_param1        => l_oper_id
      , i_env_param2        => l_macros_type
      , i_entity_type       => opr_api_const_pkg.ENTITY_TYPE_OPERATION
      , i_object_id         => l_oper_id
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
          into
               l_account.account_id
             , l_account.account_number
             , l_account.currency
             , l_account.account_type
             , l_account.inst_id
             , l_account.agent_id
             , l_account.contract_id
             , l_account.customer_id
             , l_account.split_hash
          from
               acc_macros m
             , acc_account a
         where
               m.entity_type         = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and m.object_id       = l_oper_id
               and m.macros_type_id  = l_macros_type
               and m.account_id      = a.id;
    exception
        when others then
            trc_log_pkg.error (
                i_text            => 'Error occured [#1][#2][#3]'
              , i_env_param1      => l_oper_id
              , i_env_param2      => l_macros_type
              , i_env_param3      => sqlerrm
            );
    end;

    opr_api_shared_data_pkg.set_account (
        i_name          => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , i_account_rec   => l_account
    );

    rul_api_shared_data_pkg.load_account_params(
        i_account_id    => l_account.account_id
      , io_params       => opr_api_shared_data_pkg.g_params
    );
end;

procedure select_reversal_status is
    l_selector              com_api_type_pkg.t_name;
    l_oper_id               com_api_type_pkg.t_long_id;
begin
    l_selector := opr_api_shared_data_pkg.get_param_char (
                      i_name              => 'OPERATION_SELECTOR'
                    , i_mask_error        => com_api_type_pkg.TRUE
                    , i_error_value       => opr_api_const_pkg.OPER_SELECTOR_CURRENT
                  );
    l_selector := nvl(l_selector, opr_api_const_pkg.OPER_SELECTOR_CURRENT);

    l_oper_id := opr_api_shared_data_pkg.get_operation_id (
        i_selector => l_selector
    );
    
    trc_log_pkg.debug(
        i_text => 'opr_cst_rule_proc_pkg.select_reversal_status - oper_id [' || l_oper_id || '] '
    );
    
    for rec in (
        select nvl(max(1), 0) reversal_match_status
          from crd_payment   p
             , crd_debt      d
             , crd_debt_payment dp
         where p.oper_id        = l_oper_id
           and p.is_reversal    = com_api_const_pkg.TRUE
           and p.id             = dp.pay_id
           and dp.debt_id       = d.id
           and d.oper_id        = p.original_oper_id
           and p.amount         = dp.pay_amount
    ) loop
        rul_api_param_pkg.set_param(
            i_name    => 'REVERSAL_MATCH_STATUS'
          , i_value   => rec.reversal_match_status
          , io_params => opr_api_shared_data_pkg.g_params
        );

    end loop;
end select_reversal_status;

end opr_cst_rule_proc_pkg;
/
