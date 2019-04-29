create or replace package body cst_amk_epw_report_pkg as

procedure reconciliation_results(
    o_xml                  out clob 
  , i_file_id           in     com_api_type_pkg.t_long_id
  , i_lang              in     com_api_type_pkg.t_dict_value default null
) is
    l_lang              com_api_type_pkg.t_dict_value;

    l_header            xmltype;
    l_detail            xmltype;
    l_result            xmltype; 
begin
    trc_log_pkg.debug(
        i_text        => 'cst_amk_epw_report_pkg.reconciliation_results [#1][#2]'
      , i_env_param1  => i_file_id
      , i_env_param2  => i_lang
    );

    l_lang       := nvl( i_lang, get_user_lang );

    select xmlelement("header",
               xmlelement("incoming_cnt", count(case when e.is_incoming = 1 then e.is_incoming end))
             , xmlelement("matched_cnt", count(case when e.status = net_api_const_pkg.CLEARING_MSG_STATUS_MATCHED then 1 end))
             , xmlelement("not_found_in_sv", count(case when e.status = cst_amk_epw_api_const_pkg.MSG_STATUS_NOT_FOUND_IN_SV then 1 end))
             , xmlelement("not_found_in_file", count(case when e.status = cst_amk_epw_api_const_pkg.MSG_STATUS_NOT_FOUND_IN_FILE then 1 end))
           )
      into l_header
      from cst_amk_epw_fin_msg e
     where file_id = i_file_id;
     
     select xmlelement("details"
             , xmlagg(
                   xmlelement("detail"
                     , xmlelement("is_incoming"  , is_incoming)
                     , xmlelement("supplier_code", supplier_code)
                     , xmlelement("customer_code", customer_code)
                     , xmlelement("trxn_datetime", to_char(trxn_datetime, com_api_const_pkg.XML_DATETIME_FORMAT))
                     , xmlelement("amount"
                         , com_api_currency_pkg.get_amount_str(
                               i_amount         => amount
                             , i_curr_code      => currency_code
                             , i_mask_curr_code => com_api_const_pkg.TRUE
                             , i_format_mask    => null
                             , i_mask_error     => com_api_const_pkg.TRUE
                           )
                       )
                     , xmlelement("currency_name", currency_name)
                     , xmlelement("status"
                         , com_api_dictionary_pkg.get_article_text(
                               i_article => e.status
                             , i_lang    => l_lang
                           )
                       )
                   )
               )
            )
       into l_detail
       from cst_amk_epw_fin_msg e
      where file_id = i_file_id
        and e.status <> net_api_const_pkg.CLEARING_MSG_STATUS_MATCHED;

    select xmlelement("report"
             , l_header
             , l_detail
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'cst_amk_epw_report_pkg.reconciliation_results Finished' );

exception when others then
    trc_log_pkg.debug ( i_text => sqlerrm );
    raise ; 
end;

end;
/
