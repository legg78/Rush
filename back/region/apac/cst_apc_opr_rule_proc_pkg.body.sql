create or replace package body cst_apc_opr_rule_proc_pkg is

procedure round_amount
is
    l_amount_name                   com_api_type_pkg.t_name;
    l_amount                        com_api_type_pkg.t_amount_rec;
    l_result_amount                 com_api_type_pkg.t_amount_rec;
    l_round_algorithm               com_api_type_pkg.t_dict_value;
    l_round_precision               com_api_type_pkg.t_tiny_id;
    l_currency_code                 com_api_type_pkg.t_curr_code;
begin
    l_amount_name := opr_api_shared_data_pkg.get_param_char('AMOUNT_NAME');
    l_round_algorithm := opr_api_shared_data_pkg.get_param_char('CST_ROUNDING_ALGO');
    l_round_precision := nvl(opr_api_shared_data_pkg.get_param_num('CST_ROUNDING_PRECISION'), 0);
    l_currency_code := opr_api_shared_data_pkg.get_param_char('CURRENCY');

    opr_api_shared_data_pkg.get_amount(
        i_name        => l_amount_name
      , o_amount      => l_amount.amount
      , o_currency    => l_amount.currency
    );

    if l_currency_code is null or l_currency_code = l_amount.currency then
        if l_round_algorithm = cst_apc_const_pkg.ROUNDING_ALGO_MATH then
            l_amount.amount := round(l_amount.amount, l_round_precision);
        elsif l_round_algorithm = cst_apc_const_pkg.ROUNDING_ALGO_TRUNC then
            l_amount.amount := trunc(l_amount.amount, l_round_precision);
        elsif l_round_algorithm = cst_apc_const_pkg.ROUNDING_ALGO_CEIL then
            l_amount.amount := ceil(l_amount.amount * power(10, l_round_precision))/power(10, l_round_precision);
        end if;
    end if;
    
    opr_api_shared_data_pkg.set_amount(
        i_name        => opr_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME')
      , i_amount      => l_amount.amount
      , i_currency    => l_amount.currency
    );
end round_amount;


procedure load_account_aging_period
is
    l_account_id              com_api_type_pkg.t_account_id;
    l_aging_period            com_api_type_pkg.t_tiny_id;
    l_result_param_name       com_api_type_pkg.t_name;
begin
    l_account_id := opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ISSUER).account_id;
    l_result_param_name := nvl(opr_api_shared_data_pkg.get_param_char('CST_RESULT_PARAMETER_NAME'), 'AGING_PERIOD');
    
    if l_account_id is null then
        l_account_id := 
            acc_api_account_pkg.get_account(
                i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id      => opr_api_shared_data_pkg.get_participant(com_api_const_pkg.PARTICIPANT_ISSUER).card_id
              , i_account_type   => acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
            ).account_id;
    end if;
                
    if l_account_id is not null then
        l_aging_period := 
            crd_invoice_pkg.get_last_invoice(
                i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id   => l_account_id
              , i_mask_error  => com_api_const_pkg.TRUE
            ).aging_period;
        
        opr_api_shared_data_pkg.set_param(
            i_name    => l_result_param_name
          , i_value   => l_aging_period
        );
    end if;

end load_account_aging_period;

end cst_apc_opr_rule_proc_pkg;
/
