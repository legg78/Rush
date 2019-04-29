create or replace package body crd_cst_report_pkg as

function get_additional_amounts(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_invoice_id            in      com_api_type_pkg.t_medium_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
  , i_product_id            in      com_api_type_pkg.t_short_id
  , i_service_id            in      com_api_type_pkg.t_short_id
  , i_eff_date              in      date
) return xmltype
is
    l_result                        xmltype;
begin
    return l_result;
end;

function get_subject(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_eff_date              in      date
) return com_api_type_pkg.t_name
is
    l_result                        com_api_type_pkg.t_name;
    l_account_number                com_api_type_pkg.t_account_number;
begin
    select account_number
      into l_account_number
      from acc_account
     where id = i_account_id;

    l_result := 'Credit statement of ' || l_account_number;

    return l_result;
end;

function credit_statement_invoice_data(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_eff_date              in      date
  , i_currency              in      com_api_type_pkg.t_curr_code
  , i_invoice_id            in      com_api_type_pkg.t_medium_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
) return xmltype
is
    l_xml                           xmltype;
begin
    select
        xmlconcat(
            xmlelement(
                "ext_min_amount_due"
              , com_api_currency_pkg.get_amount_str(
                    i_amount          => to_number(
                                             com_api_flexible_data_pkg.get_flexible_value(
                                                 i_field_name  => cst_apc_const_pkg.FLEX_FIELD_EXTRA_MAD
                                               , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE
                                               , i_object_id   => i_invoice_id
                                             )
                                           , com_api_const_pkg.NUMBER_FORMAT
                                         )
                  , i_curr_code       => i_currency
                  , i_mask_curr_code  => com_api_const_pkg.TRUE
                )
            )
          , xmlelement(
                "ext_due_date"
              , to_char(
                    to_date(
                        com_api_flexible_data_pkg.get_flexible_value(
                            i_field_name  => cst_apc_const_pkg.FLEX_FIELD_EXTRA_DUE_DATE
                          , i_entity_type => crd_api_const_pkg.ENTITY_TYPE_INVOICE
                          , i_object_id   => i_invoice_id
                        )
                      , com_api_const_pkg.DATE_FORMAT
                    )
                  , com_api_const_pkg.XML_DATETIME_FORMAT
                )
            )
        )
    into l_xml
    from dual;

    return l_xml;
end;

end;
/
