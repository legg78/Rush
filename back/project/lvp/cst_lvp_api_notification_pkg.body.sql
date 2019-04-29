create or replace package body cst_lvp_api_notification_pkg as

procedure report_payment (
    o_xml                  out  clob
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value
) is
    l_result                  xmltype;
    l_account_id              com_api_type_pkg.t_account_id;
    l_card_number             com_api_type_pkg.t_card_number;
    l_split_hash              com_api_type_pkg.t_tiny_id;
    l_card_id                 com_api_type_pkg.t_medium_id;
    l_oper_amount             com_api_type_pkg.t_money;
    l_oper_currency           com_api_type_pkg.t_dict_value;
    l_oper_date               date;
    l_invoice                 crd_api_type_pkg.t_invoice_rec;
    l_currency_exponent       com_api_type_pkg.t_tiny_id;
    l_currency_name           com_api_type_pkg.t_curr_name;
begin
    trc_log_pkg.debug (
        i_text       => 'Payment notification [#1] [#2] [#3] [#4] [#5]'
      , i_env_param1 => i_event_type
      , i_env_param2 => i_entity_type
      , i_env_param3 => i_object_id
      , i_env_param4 => i_inst_id
      , i_env_param5 => i_lang
    );

    if i_entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION then
        null;
    else
        com_api_error_pkg.raise_error (
            i_error       => 'UNKNOWN_ENTITY_TYPE'
          , i_env_param1  => i_entity_type
        );
    end if;

    if i_entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION then
        -- Try to get a payment operation:
        begin
            select oo.oper_date
                 , oo.oper_amount
                 , oo.oper_currency
                 , op.split_hash
                 , op.account_id
                 , iss_api_token_pkg.decode_card_number(i_card_number => oc.card_number)
                 , cc.exponent
                 , cc.name
              into l_oper_date
                 , l_oper_amount
                 , l_oper_currency
                 , l_split_hash
                 , l_account_id
                 , l_card_number
                 , l_currency_exponent
                 , l_currency_name
              from opr_operation oo
                 , opr_participant op
                 , opr_card oc
                 , com_currency cc
             where oo.id = i_object_id
               and op.oper_id = oo.id
               and op.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
               and oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_PAYMENT
               and oc.oper_id(+) = oo.id
               and oc.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER
               and cc.code(+) = oo.oper_currency;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error       => 'LVP_PAYMENT_OPERATION_NOT_FOUND'
                  , i_env_param1  => i_object_id
                );
        end;

    end if;

    if l_card_number is null then
        l_card_id :=
            cst_lvp_com_pkg.get_main_card_id(
                i_account_id => l_account_id
              , i_split_hash => l_split_hash
            );

        select iss_api_token_pkg.decode_card_number(
                   i_card_number => icn.card_number
                 , i_mask_error  => com_api_type_pkg.TRUE
               )
          into l_card_number
          from iss_card_number icn
         where icn.card_id = l_card_id;
    end if;

    -- Try to get invoice
    l_invoice :=
        crd_invoice_pkg.get_last_invoice(
            i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => l_account_id
          , i_split_hash    => l_split_hash
          , i_mask_error    => com_api_const_pkg.TRUE
        );

    select xmlelement("report"
             , xmlelement("oper_date", to_char(l_oper_date, com_api_const_pkg.XML_DATETIME_FORMAT))
             , xmlelement("oper_date_char", to_char(l_oper_date, 'dd/mm/yyyy'))
             , xmlelement("oper_amount"
                 , xmlelement("amount_value", to_char(l_oper_amount/power(10, l_currency_exponent), com_api_const_pkg.XML_NUMBER_FORMAT || rpad('.', case l_currency_exponent when 0 then 0 else l_currency_exponent+1 end, '0')))
                 , xmlelement("currency", l_oper_currency)
                 , xmlelement("name", l_currency_name)
                 , xmlelement("amount_value_formatted", cst_lvp_com_pkg.format_amount (
                                                            i_amount    => l_oper_amount
                                                          , i_curr_code => l_oper_currency
                                                        )
                             )
               )
             , xmlelement("short_card_mask", iss_api_card_pkg.get_short_card_mask(l_card_number))
             , xmlelement("card_mask", substr(l_card_number, 1, 4) || '***' || substr(l_card_number, -4))
             , xmlelement("due_date", l_invoice.due_date)
             , xmlelement("due_date_char", to_char(l_invoice.due_date, 'dd/mm/yyyy'))
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

exception
    when others then
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
end report_payment;

end cst_lvp_api_notification_pkg;
/
