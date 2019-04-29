create or replace package body cst_ap_api_report_pkg as
/**********************************************************
 * Reports for AP project <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 15.03.2019 <br />
 * Module: CST_AP_API_REPORT_PKG
 * @headcom
 **********************************************************/
 
procedure compare_tp_with_synt_file_type(
    o_xml                     out  clob
  , i_ap_session_id            in  com_api_type_pkg.t_long_id
  , i_synt_file_type           in  com_api_type_pkg.t_dict_value
  , i_usonthem_direct          in  com_api_type_pkg.t_dict_value
  , i_themonus_direct          in  com_api_type_pkg.t_dict_value
  , i_lang                     in  com_api_type_pkg.t_dict_value  default null
) is
    LOG_PREFIX  constant    com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.compare_tp_with_synt_file_type: ';
    
    l_start_date            date;
    l_end_date              date;
    
    l_eff_date              date;
    l_from_id               com_api_type_pkg.t_long_id;
    l_till_id               com_api_type_pkg.t_long_id;
    l_xml_detail            xmltype;
    l_lang                  com_api_type_pkg.t_dict_value   := nvl( i_lang, get_user_lang );
    
    l_detail_init           xmltype := xmltype('<oper_type value=""><bank_id/><field_a/><field_aa/><field_b/><field_bb/></oper_type>');
begin
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'Run with params ap_session_id [#1] synt_file_type [#2] lang [#3] usonthem_direct [#4] themonus_direct [#5]'
      , i_env_param1  => i_ap_session_id
      , i_env_param2  => i_synt_file_type
      , i_env_param3  => l_lang
      , i_env_param4  => i_usonthem_direct
      , i_env_param5  => i_themonus_direct
    );
    l_eff_date    := com_api_sttl_day_pkg.get_sysdate;
    cst_ap_api_process_pkg.get_ap_session_date(
        i_ap_session_id => i_ap_session_id
      , o_start_date    => l_start_date
      , o_end_date      => l_end_date
      , i_end_date_def  => l_eff_date
    );
    l_from_id := com_api_id_pkg.get_from_id(i_date => l_start_date);
    l_till_id := com_api_id_pkg.get_till_id(i_date => l_end_date);
    
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'Get date params for ap_session_id [#1] - start date [#2], end date [#3], from id [#4] and till id [#5]'
      , i_env_param1  => i_ap_session_id
      , i_env_param2  => l_start_date
      , i_env_param3  => l_end_date
      , i_env_param4  => l_from_id
      , i_env_param5  => l_till_id
    );
    
    if i_synt_file_type = cst_ap_api_const_pkg.SYNTI_IN_HEADER_SPEC then
        with tp_data as (
                 select s.tp_oper_type
                      , s.bank_id
                      , count(1)         as oper_count_tp
                      , sum(oper_amount) as oper_amount_tp
                   from (
                         select aup_api_tag_pkg.get_tag_value(
                                    i_auth_id => o.id
                                  , i_tag_id  => aup_api_tag_pkg.find_tag_by_reference(i_reference => 'CST_ISS_PART_CODE')
                                ) as bank_id
                              , cst_ap_api_process_pkg.convert_oper_type_sv_to_tp(
                                    i_oper_type  =>  o.oper_type
                                  , i_term_type  =>  o.terminal_type
                                ) as tp_oper_type
                              , o.oper_amount
                           from opr_operation o
                          where o.id between l_from_id and l_till_id
                            and exists(
                                    select 1
                                      from com_array_element
                                     where array_id = cst_ap_api_const_pkg.ARRAY_ID_TP_OPER_TYPE_SV_CODE
                                       and element_value = o.oper_type
                                )
                            and o.match_status in (cst_ap_api_const_pkg.CRO_ASP_PROCDESSED, cst_ap_api_const_pkg.CRO_ADT_PROCDESSED)
                            and o.sttl_type = i_themonus_direct
                            and aup_api_tag_pkg.get_tag_value(
                                    i_auth_id => o.id
                                  , i_tag_id  => cst_ap_api_const_pkg.TAG_ID_SESSION_DAY
                                ) = i_ap_session_id
                            and aup_api_tag_pkg.get_tag_value(
                                    i_auth_id => o.id
                                  , i_tag_id  => aup_api_tag_pkg.find_tag_by_reference(i_reference => 'CST_ISS_PART_CODE')
                                ) is not null
                   ) s
                  group by
                        s.tp_oper_type
                      , s.bank_id
             ),
             synt_data as (
                 select c.opr_type as tp_oper_type
                      , c.bank_id
                      , sum(nvl(c.oper_cnt, 0))    as oper_count_synt
                      , sum(nvl(c.oper_amount, 0)) as oper_amount_synt
                   from cst_ap_synt c
                  where c.session_day >= l_start_date
                    and c.session_day  < l_end_date
                    and c.file_type    = cst_ap_api_const_pkg.SYNTI_IN_HEADER_SPEC
                    and c.bank_id     <> 'SCS'
                  group by
                        c.opr_type
                      , c.bank_id
             )
        select xmlelement(
                   "operations"
                 , xmlelement(
                       "operation"
                     , nvl(
                           xmlagg(
                               xmlelement(
                                   "oper_type"
                                 , xmlattributes(
                                       lpad(nvl(a.tp_oper_type, b.tp_oper_type), 3, '0') as "value"
                                   )
                                 , xmlelement("bank_id",  nvl(a.bank_id, b.bank_id))
                                 , xmlelement("field_a",  a.oper_count_tp)
                                 , xmlelement("field_aa", a.oper_amount_tp)
                                 , xmlelement("field_b",  b.oper_count_synt)
                                 , xmlelement("field_bb", b.oper_amount_synt)
                               ) order by nvl(a.bank_id,  b.bank_id)
                           )
                         , l_detail_init
                       )
                   )
               )
          into l_xml_detail
          from tp_data a
          full outer join
               synt_data b
            on a.tp_oper_type = b.tp_oper_type
               and a.bank_id  = b.bank_id
         order by
               nvl(a.tp_oper_type, b.tp_oper_type);
               
    elsif i_synt_file_type = cst_ap_api_const_pkg.SYNTO_IN_HEADER_SPEC then
        with tp_data as (
                 select s.tp_oper_type
                      , s.bank_id
                      , count(1)         as oper_count_tp
                      , sum(oper_amount) as oper_amount_tp
                   from (
                         select aup_api_tag_pkg.get_tag_value(
                                    i_auth_id => o.id
                                  , i_tag_id  => aup_api_tag_pkg.find_tag_by_reference(i_reference => 'CST_ACQ_PART_CODE')
                                ) as bank_id
                              , cst_ap_api_process_pkg.convert_oper_type_sv_to_tp(
                                    i_oper_type  =>  o.oper_type
                                  , i_term_type  =>  o.terminal_type
                                ) as tp_oper_type
                              , o.oper_amount
                           from opr_operation o
                          where o.id between l_from_id and l_till_id
                            and exists(
                                    select 1
                                      from com_array_element
                                     where array_id = cst_ap_api_const_pkg.ARRAY_ID_TP_OPER_TYPE_SV_CODE
                                       and element_value = o.oper_type
                                )
                            and o.match_status in (cst_ap_api_const_pkg.CRO_ASP_PROCDESSED, cst_ap_api_const_pkg.CRO_ADT_PROCDESSED)
                            and o.sttl_type = i_usonthem_direct
                            and aup_api_tag_pkg.get_tag_value(
                                    i_auth_id => o.id
                                  , i_tag_id  => cst_ap_api_const_pkg.TAG_ID_SESSION_DAY
                                ) = i_ap_session_id
                            and aup_api_tag_pkg.get_tag_value(
                                    i_auth_id => o.id
                                  , i_tag_id  => aup_api_tag_pkg.find_tag_by_reference(i_reference => 'CST_ACQ_PART_CODE')
                                ) is not null
                   ) s
                  group by
                        s.tp_oper_type
                      , s.bank_id
             ),
             synt_data as (
                 select c.opr_type as tp_oper_type
                      , c.bank_id
                      , sum(nvl(c.oper_cnt, 0))    as oper_count_synt
                      , sum(nvl(c.oper_amount, 0)) as oper_amount_synt
                   from cst_ap_synt c
                  where c.session_day >= l_start_date
                    and c.session_day  < l_end_date
                    and c.file_type    = cst_ap_api_const_pkg.SYNTO_IN_HEADER_SPEC
                    and c.bank_id     <> 'SCS'
                  group by
                        c.opr_type
                      , c.bank_id
             )
        select xmlelement(
                   "operations"
                 , xmlelement(
                       "operation"
                     , nvl(
                           xmlagg(
                               xmlelement(
                                   "oper_type"
                                 , xmlattributes(
                                       lpad(nvl(a.tp_oper_type, b.tp_oper_type), 3, '0') as "value"
                                   )
                                 , xmlelement("bank_id",  nvl(a.bank_id, b.bank_id))
                                 , xmlelement("field_a",  a.oper_count_tp)
                                 , xmlelement("field_aa", a.oper_amount_tp)
                                 , xmlelement("field_b",  b.oper_count_synt)
                                 , xmlelement("field_bb", b.oper_amount_synt)
                               ) order by nvl(a.bank_id,  b.bank_id)
                           )
                         , l_detail_init
                       )
                   )
               )
          into l_xml_detail
          from tp_data a
          full outer join
               synt_data b
            on a.tp_oper_type = b.tp_oper_type
               and a.bank_id  = b.bank_id
         order by
               nvl(a.tp_oper_type, b.tp_oper_type);
    elsif i_synt_file_type = cst_ap_api_const_pkg.SYNTR_IN_HEADER_SPEC then
        with tp_data as (
                 select s.tp_oper_type
                      , s.bank_id
                      , sum(
                            decode(
                                sttl_type
                              , i_themonus_direct
                              , oper_amount
                              , 0
                            )
                        ) as oper_amount_cr_tp
                      , sum(
                            decode(
                                sttl_type
                              , i_usonthem_direct
                              , oper_amount
                              , 0
                            )
                        ) as oper_amount_db_tp
                   from (
                         select decode(
                                    o.sttl_type
                                  , i_themonus_direct
                                  , aup_api_tag_pkg.get_tag_value(
                                        i_auth_id => o.id
                                      , i_tag_id  => aup_api_tag_pkg.find_tag_by_reference(i_reference => 'CST_ISS_PART_CODE')
                                    )
                                  , i_usonthem_direct
                                  , aup_api_tag_pkg.get_tag_value(
                                        i_auth_id => o.id
                                      , i_tag_id  => aup_api_tag_pkg.find_tag_by_reference(i_reference => 'CST_ACQ_PART_CODE')
                                    )
                                  , null
                                ) as bank_id
                              , cst_ap_api_process_pkg.convert_oper_type_sv_to_tp(
                                    i_oper_type  =>  o.oper_type
                                  , i_term_type  =>  o.terminal_type
                                ) as tp_oper_type
                              , o.oper_amount
                              , o.sttl_type
                           from opr_operation o
                          where o.id between l_from_id and l_till_id
                            and exists(
                                    select 1
                                      from com_array_element
                                     where array_id = cst_ap_api_const_pkg.ARRAY_ID_TP_OPER_TYPE_SV_CODE
                                       and element_value = o.oper_type
                                )
                            and o.match_status in (cst_ap_api_const_pkg.CRO_ASP_PROCDESSED, cst_ap_api_const_pkg.CRO_ADT_PROCDESSED)
                            and aup_api_tag_pkg.get_tag_value(
                                    i_auth_id => o.id
                                  , i_tag_id  => cst_ap_api_const_pkg.TAG_ID_SESSION_DAY
                                ) = i_ap_session_id
                            and ((o.sttl_type = i_usonthem_direct
                                  and aup_api_tag_pkg.get_tag_value(
                                          i_auth_id => o.id
                                        , i_tag_id  => aup_api_tag_pkg.find_tag_by_reference(i_reference => 'CST_ACQ_PART_CODE')
                                      ) is not null
                                 ) or
                                 (o.sttl_type = i_themonus_direct
                                  and aup_api_tag_pkg.get_tag_value(
                                          i_auth_id => o.id
                                        , i_tag_id  => aup_api_tag_pkg.find_tag_by_reference(i_reference => 'CST_ISS_PART_CODE')
                                      ) is not null
                                  )
                                 )
                   ) s
                  group by
                        s.tp_oper_type
                      , s.bank_id
             ),
             synt_data as (
                 select c.opr_type as tp_oper_type
                      , c.bank_id
                      , sum(
                            decode(
                                c.balance_impact
                              , com_api_const_pkg.CREDIT
                              , nvl(c.oper_amount, 0)
                              , 0
                            )
                        ) as oper_amount_cr_synt
                      , sum(
                            decode(
                                c.balance_impact
                              , com_api_const_pkg.DEBIT
                              , nvl(c.oper_amount, 0)
                              , 0
                            )
                        ) as oper_amount_db_synt
                   from cst_ap_synt c
                  where c.session_day >= l_start_date
                    and c.session_day  < l_end_date
                    and c.file_type    = cst_ap_api_const_pkg.SYNTR_IN_HEADER_SPEC
                    and c.bank_id     <> 'SCS'
                  group by
                        c.opr_type
                      , c.bank_id
             )
        select xmlelement(
                   "operations"
                 , xmlelement(
                       "operation"
                     , nvl(
                           xmlagg(
                               xmlelement(
                                   "oper_type"
                                 , xmlattributes(
                                       lpad(nvl(a.tp_oper_type, b.tp_oper_type), 3, '0') as "value"
                                   )
                                 , xmlelement("bank_id", nvl(a.bank_id, b.bank_id))
                                 , xmlelement("field_a",  a.oper_amount_cr_tp)
                                 , xmlelement("field_aa", a.oper_amount_db_tp)
                                 , xmlelement("field_b",  b.oper_amount_cr_synt)
                                 , xmlelement("field_bb", b.oper_amount_db_synt)
                               ) order by nvl(a.bank_id, b.bank_id)
                           )
                         , l_detail_init
                       )
                   )
               )
          into l_xml_detail
          from tp_data a
          full outer join
               synt_data b
            on a.tp_oper_type = b.tp_oper_type
               and a.bank_id  = b.bank_id
         order by
               nvl(a.tp_oper_type, b.tp_oper_type);
    end if;
    
    select xmlelement(
               "compare_result"
             , xmlelement(
                   "header"
                 , xmlelement("report_file_type", i_synt_file_type)
                 , xmlelement("effective_date",   to_char(l_eff_date, com_api_const_pkg.LOG_DATE_FORMAT))
                 , xmlelement("session_id",       i_ap_session_id)
                 , xmlelement("session_date",     to_char(l_end_date, com_api_const_pkg.LOG_DATE_FORMAT))
               )
             , l_xml_detail
           ).getClobVal()
      into o_xml
      from dual;
    
end compare_tp_with_synt_file_type;

end cst_ap_api_report_pkg;
/
