create or replace package body cst_bsm_api_report_pkg is
/**********************************************************
 * API for Campus Card Solution reports <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 16.01.2017 <br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: CST_CCS_API_REPORT_PKG
 * @headcom
 **********************************************************/
procedure acquirer_operations_for_period(
    o_xml             out clob
  , i_lang             in com_api_type_pkg.t_dict_value default null
  , i_inst_id          in com_api_type_pkg.t_inst_id
  , i_currency         in com_api_type_pkg.t_curr_code
  , i_rate_type        in com_api_type_pkg.t_dict_value
  , i_operation_type   in com_api_type_pkg.t_dict_value
  , i_start_date       in date
  , i_end_date         in date
) is
    
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.acquirer_operations_for_period: ';
    
    l_start         date;
    l_end           date;

begin

    trc_log_pkg.debug(
        i_text  => LOG_PREFIX || 'Start with params i_lang [' || i_lang
                || '], i_inst_id [' || i_inst_id
                || '], i_currency [' || i_currency
                || '], i_rate_type [' || i_rate_type
                || '], i_operation_type [' || i_operation_type
                || '], i_start_date [' || to_char(i_start_date, com_api_const_pkg.XML_DATE_FORMAT)
                || '], i_end_date [' || to_char(i_end_date, com_api_const_pkg.XML_DATE_FORMAT)
                || ']'
    );

    l_start   := trunc(i_start_date);

    l_end     := trunc(i_end_date) + 1 - com_api_const_pkg.ONE_SECOND;
    
    with t as (
        select report_date
             , oc.name as converted_currency
             , exponent
             , count(*) as day_count
             , sum(converted_amount) as day_amount
          from (
                  select trunc(oper_date) as report_date
                       , i_currency as converted_currency
                       , case
                             when op.oper_currency = i_currency
                             then op.oper_amount
                             else com_api_rate_pkg.convert_amount(
                                      i_src_amount   => op.oper_amount
                                    , i_src_currency => op.oper_currency
                                    , i_dst_currency => i_currency
                                    , i_rate_type    => i_rate_type
                                    , i_inst_id      => p.inst_id
                                    , i_eff_date     => op.oper_date
                                  )
                         end as converted_amount
                       , op.*
                       , p.*
                    from opr_operation op
                       , opr_participant p
                   where p.oper_id = op.id
                     and p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                     and op.oper_type = i_operation_type
                     and p.inst_id = i_inst_id
                     and op.oper_date between l_start and l_end
          )
             , com_currency oc
         where oc.code = converted_currency
          
         group by
               report_date
             , oc.name
             , exponent
    )
    select xmlelement("report",
               xmlAgg(data order by row_type)
           ).getClobVal()
      into o_xml
      from (
                select 1 as row_type 
                     , xmlelement("header",
                           xmlelement(
                               "p_institute_name"
                             , ost_ui_institution_pkg.get_inst_name(
                                   i_inst_id         => i_inst_id
                                 , i_lang            => i_lang
                               ) 
                            || ' - '
                            || i_inst_id
                           )
                         , xmlelement("p_converted_currency", i_currency)
                         , xmlelement("p_operation_type", i_operation_type)
                         , xmlelement("p_rate_type", i_rate_type)
                         , xmlelement("p_start_date", to_char(i_start_date, com_api_const_pkg.XML_DATE_FORMAT))
                         , xmlelement("p_end_date", to_char(i_end_date, com_api_const_pkg.XML_DATE_FORMAT))
                       ) as data
                  from dual
                union all
                select 2 as row_type
                     , xmlelement("detail",
                           xmlAgg(
                               xmlelement("transaction",
                                   xmlelement("report_date", t.report_date)
                                 , xmlelement("oper_count", t.day_count)
                                 , xmlelement(
                                       "oper_amount"
                                     , '$'
                                    || to_char(
                                           t.day_amount / power(10, t.exponent)
                                         , com_api_const_pkg.XML_NUMBER_FORMAT
                                           || rpad(
                                                  '.'
                                                , case t.exponent 
                                                      when 0
                                                          then 0 
                                                      else t.exponent + 1
                                                  end
                                                , '0'
                                              )
                                       )
                                   )
                                 , xmlelement("converted_currency", t.converted_currency)
                               ) order by t.report_date
                           )
                       ) as data
                  from t
                union all
                select 3 as row_type
                     , xmlelement("footer",
                           xmlAgg(
                               xmlelement("total_on_currency",
                                   xmlelement("oper_count", sum(t.day_count))
                                 , xmlelement(
                                       "oper_amount"
                                     , '$'
                                    || to_char(
                                           sum(t.day_amount) / power(10, t.exponent)
                                         , com_api_const_pkg.XML_NUMBER_FORMAT
                                           || rpad(
                                                  '.'
                                                , case t.exponent 
                                                      when 0
                                                          then 0 
                                                      else t.exponent + 1
                                                  end
                                                , '0'
                                              )
                                       )
                                   )
                                 , xmlelement("converted_currency", t.converted_currency)
                               ) order by t.converted_currency
                           )
                       ) as data
                  from t
                 group by
                       t.converted_currency
                     , t.exponent
      )
    ;
    
    if nvl(xmltype(o_xml).existsnode('report/detail/transaction'), com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
        
        raise no_data_found;
        
    end if;

    trc_log_pkg.debug(i_text => LOG_PREFIX || 'ok');

exception
    when others then
        
        trc_log_pkg.debug(
            i_text  => LOG_PREFIX || 'Failed with params i_lang [' || i_lang
                    || '], i_inst_id [' || i_inst_id
                    || '], i_currency [' || i_currency
                    || '], i_rate_type [' || i_rate_type
                    || '], i_operation_type [' || i_operation_type
                    || '], i_start_date [' || to_char(i_start_date, com_api_const_pkg.XML_DATE_FORMAT)
                    || '], i_end_date [' || to_char(i_end_date, com_api_const_pkg.XML_DATE_FORMAT)
                    || ']'
        );

        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE
            and com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE
        then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        
        raise;
        
end acquirer_operations_for_period;



end cst_bsm_api_report_pkg;
/
