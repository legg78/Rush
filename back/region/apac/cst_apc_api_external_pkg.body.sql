create or replace package body cst_apc_api_external_pkg as

procedure credit_card_info (
    i_card_id             in     com_api_type_pkg.t_medium_id
  , i_date_format         in     com_api_type_pkg.t_name       default 'yyyy-mm-dd'
  , i_add_curr_name       in     com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , o_result_xml             out clob
)
is
    LOG_PREFIX       constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.credit_card_info: ';
    l_response_code           xmltype;
    l_response_data           xmltype;
    l_response_data_part      xmltype;
    l_result                  xmltype;
    l_ref_cursor              sys_refcursor;
    l_customer_id             com_api_type_pkg.t_medium_id;
    l_resp_code               com_api_type_pkg.t_dict_value;
    l_error_message           com_api_type_pkg.t_text;

    l_card_id                 com_api_type_pkg.t_medium_id := i_card_id;
    l_account                 acc_api_type_pkg.t_account_rec;
    l_split_hash              com_api_type_pkg.t_tiny_id;
    l_invoice                 crd_api_type_pkg.t_invoice_rec;
    l_balances                com_api_type_pkg.t_amount_by_name_tab;
    l_exceed_balance          com_api_type_pkg.t_money;
    l_available_balance       com_api_type_pkg.t_money;

begin

    l_split_hash :=
        com_api_hash_pkg.get_split_hash(
            i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id     => l_card_id
        );

    l_account :=
        acc_api_account_pkg.get_account(
            i_entity_type     => iss_api_const_pkg.ENTITY_TYPE_CARD -- 'ENTTCARD'
          , i_object_id       => l_card_id
          , i_account_type    => acc_api_const_pkg.ACCOUNT_TYPE_CREDIT -- 'ACTP0130'
          , i_mask_error      => com_api_type_pkg.FALSE
        );
    
    acc_api_balance_pkg.get_account_balances(
        i_account_id     => l_account.account_id
      , o_balances       => l_balances
    );
    
    if l_balances.exists(crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED) then
        l_exceed_balance := l_balances(crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED).amount;
    end if;
    
    l_available_balance := 
        acc_api_balance_pkg.get_aval_balance_amount_only(
            i_account_id   => l_account.account_id
        );

    l_invoice :=
        crd_invoice_pkg.get_last_invoice(
            i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT -- 'ENTTACCT'
          , i_object_id   => l_account.account_id
          , i_split_hash  => l_split_hash
          , i_mask_error  => com_api_type_pkg.TRUE
        );

    select xmlelement("response_data",
               xmlconcat(
                   xmlelement("card_id", l_card_id)
                 , xmlelement("account_currency_iso_digital", l_account.currency)
                 , xmlelement("account_currency_name", com_api_currency_pkg.get_currency_name(i_curr_code => l_account.currency))
                 , xmlelement("invoice_date", to_char(l_invoice.invoice_date, i_date_format))
                 , xmlelement("due_date", to_char(l_invoice.due_date, i_date_format))
                 , xmlelement("grace_date", to_char(l_invoice.grace_date, i_date_format))
                 , xmlelement("penalty_date", to_char(l_invoice.penalty_date, i_date_format))
                 , xmlelement("total_amount_due", l_invoice.total_amount_due)
                 , xmlelement("total_amount_due_formatted", cst_apc_com_pkg.format_amount(
                                                                i_amount        => l_invoice.total_amount_due
                                                              , i_curr_code     => l_account.currency
                                                              , i_add_curr_name => i_add_curr_name
                                                            )
                             )
                 , xmlelement("min_amount_due", l_invoice.min_amount_due)
                 , xmlelement("min_amount_due_formatted", cst_apc_com_pkg.format_amount(
                                                              i_amount        => l_invoice.min_amount_due
                                                            , i_curr_code     => l_account.currency
                                                            , i_add_curr_name => i_add_curr_name
                                                          ) 
                             )
                 , xmlelement("available_balance", l_available_balance)
                 , xmlelement("available_balance_formatted", cst_apc_com_pkg.format_amount(
                                                                 i_amount        => l_available_balance
                                                               , i_curr_code     => l_account.currency
                                                               , i_add_curr_name => i_add_curr_name
                                                             )
                             )
                 , xmlelement("total_credit_limit", l_exceed_balance)
                 , xmlelement("total_credit_limit_formatted", cst_apc_com_pkg.format_amount(
                                                                  i_amount        => l_exceed_balance
                                                                , i_curr_code     => l_account.currency
                                                                , i_add_curr_name => i_add_curr_name
                                                              )
                             )
                 , xmlelement("date_format", i_date_format)
               )
           )
      into l_response_data
      from dual;


    select xmlconcat(
               xmlelement("response_code", '0')
             , l_response_data
           )
      into l_result
      from dual;

    o_result_xml := l_result.getclobval();

exception
    when others then
        l_error_message := substr(sqlerrm, 1, 2000);
        select xmlconcat(
                   xmlelement("response_code", '-9')
                 , xmlelement("error_message", l_error_message)
                 , l_response_data
               )
          into l_result
          from dual;
        o_result_xml := l_result.getclobval();

        if  com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE
            and
            com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE
        then
            trc_log_pkg.error(
                i_text        => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
              , i_entity_type => case when l_card_id is not null
                                      then iss_api_const_pkg.ENTITY_TYPE_CARD
                                      else null
                                 end
              , i_object_id   => l_card_id
            );
        end if;

end credit_card_info;

end cst_apc_api_external_pkg;
/
