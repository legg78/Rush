create or replace package body atm_api_report_pkg is

procedure report_atm_cnt
  ( o_xml          out clob
  , i_lang         in com_api_type_pkg.t_dict_value
  , i_inst_id      in com_api_type_pkg.t_tiny_id   default null
  , i_agent_id     in com_api_type_pkg.t_short_id  default null
  )
is
  l_result        xmltype;
  l_atm_cnt       xmltype;
  l_header        xmltype;

begin
   trc_log_pkg.debug
        ( i_text       => 'atm_api_report_pkg.report_atm_cnt [#1][#2][#3]]'
        , i_env_param1 => i_lang
        , i_env_param2 => i_inst_id
        , i_env_param3 => i_agent_id
        );

   -- header
   select xmlelement( "header"
             , xmlelement( "user_name", com_ui_person_pkg.get_person_name( acm_api_user_pkg.get_person_id( get_user_name ), i_lang ) )
             , xmlelement( "rep_date", to_char(com_api_sttl_day_pkg.get_sysdate(), 'dd.mm.yyyy hh24:mi' ) )
             , xmlelement( "par_inst_id",
                           decode( i_inst_id, null, null, to_char(i_inst_id) ||' - '|| get_text ('OST_INSTITUTION', 'NAME', i_inst_id, i_lang) )
                         )
             , xmlelement( "par_agent_id",
                           decode( i_agent_id, null, null, to_char(i_agent_id) ||' - '|| get_text ('OST_AGENT', 'NAME', i_agent_id, i_lang) )
                         )
          ) xml
   into l_header
   from dual ;

   -- data
   select xmlelement ( "atm_cnt", xmlagg (t.xml) )
   into l_atm_cnt
   from (
     select xmlagg( xmlelement
                    ("table"
                    , xmlelement( "inst_desc"           , X.inst_desc            )
                    , xmlelement( "agent_desc"          , X.agent_desc           )
                    , xmlelement( "cnt_all"             , X.cnt_all              )
                    , xmlelement( "cnt_not_cash_in"     , X.cnt_not_cash_in      )
                    , xmlelement( "cnt_cash_in"         , X.cnt_cash_in          )
                    , xmlelement( "cnt_recycling"       , X.cnt_recycling        )
                    , xmlelement( "cnt_all_inst"        , X.cnt_all_inst         )
                    , xmlelement( "cnt_not_cash_in_inst", X.cnt_not_cash_in_inst )
                    , xmlelement( "cnt_cash_in_inst"    , X.cnt_cash_in_inst     )
                    , xmlelement( "cnt_recycling_inst"  , X.cnt_recycling_inst   )
                    , xmlelement( "cnt_all_tot"         , X.cnt_all_tot          )
                    , xmlelement( "cnt_not_cash_in_tot" , X.cnt_not_cash_in_tot  )
                    , xmlelement( "cnt_cash_in_tot"     , X.cnt_cash_in_tot      )
                    , xmlelement( "cnt_recycling_tot"   , X.cnt_recycling_tot    )
                    )
                    order by X.inst_desc, X.agent_desc
            ) xml
     from ( select inst_desc, agent_desc
                 , cnt_all, cnt_not_cash_in, cnt_cash_in, cnt_recycling
                 , sum (cnt_all)         over(partition by inst_id) cnt_all_inst
                 , sum (cnt_not_cash_in) over(partition by inst_id) cnt_not_cash_in_inst
                 , sum (cnt_cash_in)     over(partition by inst_id) cnt_cash_in_inst
                 , sum (cnt_recycling)   over(partition by inst_id) cnt_recycling_inst
                 , sum (cnt_all)         over() cnt_all_tot
                 , sum (cnt_not_cash_in) over() cnt_not_cash_in_tot
                 , sum (cnt_cash_in)     over() cnt_cash_in_tot
                 , sum (cnt_recycling)   over() cnt_recycling_tot
              from ( select decode ( D.inst_id, null, 'Undefined Institution', to_char(D.inst_id) ||' - '|| get_text ('OST_INSTITUTION', 'NAME', D.inst_id, i_lang) ) as inst_desc
                          , decode ( D.agent_id, null, 'Undefined Agent', to_char(D.agent_id) ||' - '|| get_text ('OST_AGENT', 'NAME', D.agent_id, i_lang) ) as agent_desc
                          , count(D.id) cnt_all
                          , sum(D.is_not_cash_in) cnt_not_cash_in
                          , sum(D.is_cash_in) cnt_cash_in
                          , sum(D.is_recycling) cnt_recycling
                          , inst_id 
                       from ( select t.id
                                   , nvl(t.cash_in_present, 0) cash_in
                                   , nvl(t.recycling_present, 0) recycling
                                   , a.inst_id
                                   , c.agent_id
                                   , decode ( nvl(t.cash_in_present, 0), 0, 1, 0 ) is_not_cash_in
                                   , decode ( nvl(t.cash_in_present, 0), 0, 0, 1 ) is_cash_in
                                   , decode ( nvl(t.recycling_present, 0), 0, 0, 1 ) is_recycling
                                from atm_terminal t
                                   , acq_terminal a
                                   , prd_contract c
                               where t.id = a.id
                                 and a.contract_id = c.id(+)
                                 and ( nvl(a.inst_id, -99) = nvl(i_inst_id, nvl(a.inst_id, -99) ) )
                                 and ( nvl(c.agent_id, -99) = nvl(i_agent_id, nvl(c.agent_id, -99) ) )
                            ) D
                      group by D.inst_id, D.agent_id
                   )
             order by inst_desc, agent_desc
          ) X
        ) T;

    --if no data
    if l_atm_cnt.getclobval() = '<atm_cnt></atm_cnt>' then
        select xmlelement("atm_cnt"
                       , xmlagg( xmlelement
                            ("table"
                            , xmlelement( "inst_desc"           , 'Undefined Institution')
                            , xmlelement( "agent_desc"          , 'Undefined Agent'      )
                            , xmlelement( "cnt_all"             , null                   )
                            , xmlelement( "cnt_not_cash_in"     , null                   )
                            , xmlelement( "cnt_cash_in"         , null                   )
                            , xmlelement( "cnt_recycling"       , null                   )
                            , xmlelement( "cnt_all_inst"        , null                   )
                            , xmlelement( "cnt_not_cash_in_inst", null                   )
                            , xmlelement( "cnt_cash_in_inst"    , null                   )
                            , xmlelement( "cnt_recycling_inst"  , null                   )
                            , xmlelement( "cnt_all_tot"         , null                   )
                            , xmlelement( "cnt_not_cash_in_tot" , null                   )
                            , xmlelement( "cnt_cash_in_tot"     , null                   )
                            , xmlelement( "cnt_recycling_tot"   , null                   )
                            )
                    )
              )
        into l_atm_cnt from dual ;
    end if;
    
    select xmlelement ( "report"
             , l_header
             , l_atm_cnt
           )
    into l_result
    from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'atm_api_report_pkg.report_atm_cnt - ok' );

exception
  when no_data_found then trc_log_pkg.debug ( i_text => sqlerrm );

end;

procedure report_atm_turnover
  ( o_xml            out clob
  , i_lang           in com_api_type_pkg.t_dict_value
  , i_inst_id        in com_api_type_pkg.t_tiny_id    default null
  , i_agent_id       in com_api_type_pkg.t_short_id   default null
  , i_date_start     in date
  , i_date_end       in date
  , i_placement_type in com_api_type_pkg.t_dict_value default null
  )
is
  l_result        xmltype;
  l_atms          xmltype;
  l_header        xmltype;

begin
   trc_log_pkg.debug
        ( i_text       => 'atm_api_report_pkg.report_atm_turnover [#1][#2][#3][#4][#5][#6]]'
        , i_env_param1 => i_lang
        , i_env_param2 => i_inst_id
        , i_env_param3 => i_agent_id
        , i_env_param4 => i_date_start
        , i_env_param5 => i_date_end
        , i_env_param6 => i_placement_type
        );

   -- header
   select xmlelement( "header"
             , xmlelement( "rep_date", com_api_sttl_day_pkg.get_sysdate())
             , xmlelement( "prm_inst", decode( i_inst_id, null, null, to_char(i_inst_id) ||' - '|| get_text ('OST_INSTITUTION', 'NAME', i_inst_id, i_lang) ))
             , xmlelement( "prm_agent", decode( i_agent_id, null, null, to_char(i_agent_id) ||' - '|| get_text ('OST_AGENT', 'NAME', i_agent_id, i_lang) ) )
             , xmlelement( "prm_placement_type", decode( i_placement_type, null, null, com_api_dictionary_pkg.get_article_text ( i_placement_type, i_lang ) ) )
             , xmlelement( "prm_data_start", to_char( i_date_start, 'dd.mm.yyyy hh24:mi:ss') )
             , xmlelement( "prm_data_end", to_char( i_date_end, 'dd.mm.yyyy hh24:mi:ss') )
          ) xml
   into l_header
   from dual ;

   -- data
   select xmlelement ( "atms", xmlagg (atms.xml) )
   into l_atms
   from (
     select xmlagg( xmlelement
                    ("record"
                    , xmlelement( "inst_desc"      , X.inst_desc       )
                    , xmlelement( "agent_desc"     , X.agent_desc      )
                    , xmlelement( "terminal_number", X.terminal_number )
                    , xmlelement( "address"        , X.address         )
                    , xmlelement( "r_currency"     , X.r_currency      )
                    , xmlelement( "r_amount"       , to_char( X.r_amount/power(10, nvl(X.expn,0)), 'FM999999999999999990.'||rpad('0', X.expn, '0')) )
                    , xmlelement( "op_date"        , to_char( X.op_date, 'dd.mm' ) )
                    , xmlelement( "currency"       , X.currency        )
                    , xmlelement( "amount"         , to_char( X.amount/power(10, nvl(X.expn,0)), 'FM999999999999999990.'||rpad('0', X.expn, '0')) )
                    , xmlelement( "p_currency"     , X.p_currency      )
                    , xmlelement( "p_amount"       , to_char( X.p_amount/power(10, nvl(X.expn,0)), 'FM999999999999999999999990.'||rpad('0', X.expn, '0')) )
                    , xmlelement( "type_string"    , X.type_string     )
                    )
                    order by X.inst_desc, X.agent_desc, X.terminal_number, X.type_string, X.op_date, X.currency
            ) xml
     from ( select decode ( A.inst_id, null, 'Undefined Institution', to_char(A.inst_id) ||' - '|| get_text ('OST_INSTITUTION', 'NAME', A.inst_id, i_lang) ) as inst_desc
                 , decode ( C.agent_id, null, 'Undefined Agent', to_char(C.agent_id) ||' - '|| get_text ('OST_AGENT', 'NAME', C.agent_id, i_lang) ) as agent_desc
                 , A.terminal_number 
                 , decode ( type_string, 'adr_string'
                          , com_api_address_pkg.get_address_string (NVL (aot.address_id, aom.address_id), i_lang )
                          , null 
                          ) as address
                 --remainds
                   , R_CU.name as r_currency
                   , TT.r_amount
                 --turnover
                   , TT.op_date  
                   , CU.name   as currency
                   , TT.amount
                 --period turnover 
                   , P_CU.name as p_currency
                   , TT.p_amount
                 , decode ( type_string
                          , 'adr_string', R_CU.exponent 
                          , 'data_string', CU.exponent 
                          , 'period_string', P_CU.exponent 
                          ) as expn
                 , TT.type_string
            from ( select 'adr_string' type_string
                        , terminal_id
                        , currency as r_currency, amount as r_amount
                        , null as op_date 
                        , null as currency, null as amount
                        , null as p_currency, null as p_amount
                     from ( select DI.terminal_id
                                 , DI.currency
                                 , nvl( sum(DI.face_value*DID.note_remained), 0) amount
                              from atm_dispenser  DI
                                 , atm_dispenser_dynamic DID
                             where di.id = did.id(+)
                             group by DI.terminal_id, DI.currency 
                          ) R
                   union all
                   select decode(op_date,null,'period_string','data_string') as type_string
                        , terminal_id
                        , null as r_currency, null as r_amount
                        , op_date 
                        , decode(op_date,null,null,currency) as currency
                        , decode(op_date,null,null,amount)   as amount
                        , decode(op_date,null,currency,null) as p_currency
                        , decode(op_date,null,amount,null)   as p_amount
                     from ( select terminal_id, op_date, currency, sum(amount) as amount
                              from ( select p.terminal_id
                                          , trunc(o.oper_date)     as op_date
                                          , o.oper_currency as currency
                                          , o.oper_amount * decode (o.is_reversal,0,1,1,-1) as amount
                                       from opr_operation O
                                          , opr_participant P
                                      where O.id = P.oper_id
                                        and P.participant_type = 'PRTYACQ'
                                        and O.oper_date >= i_date_start
                                        and O.oper_date <= i_date_end
                                   )
                             group by grouping sets ((terminal_id,op_date,currency), (terminal_id,currency))
                             order by terminal_id, op_date, currency
                          )    
                   order by terminal_id, type_string, op_date, currency
                 ) TT
               , atm_terminal T
               , acq_terminal A
               , prd_contract C
               , com_currency CU
               , com_currency R_CU
               , com_currency P_CU
               , com_address_object aot
               , com_address_object aom
            where A.id = TT.terminal_id
              and A.id = T.id
              and A.contract_id = C.id(+)
              and CU.code(+) = TT.currency
              and R_CU.code(+) = TT.r_currency
              and P_CU.code(+) = TT.p_currency
              and ( nvl(a.inst_id, -99) = nvl(i_inst_id, nvl(a.inst_id, -99) ) ) 
              and ( nvl(c.agent_id, -99) = nvl(i_agent_id, nvl(c.agent_id, -99) ) )
              and ( nvl(t.placement_type, '&') = nvl(i_placement_type, nvl(t.placement_type, '&') ) )
              and aot.entity_type(+) = 'ENTTTRMN'
              and aot.object_id(+) = T.ID
              and aot.address_type(+) = 'ADTPBSNA'
              and aom.entity_type(+) = 'ENTTMRCH'
              and aom.object_id(+) = A.merchant_id
              and aom.address_type(+) = 'ADTPBSNA'
            order by A.inst_id, C.agent_id, A.terminal_number, TT.type_string, TT.op_date, TT.currency
          ) X
        ) ATMS;

    --if no data
    if l_atms.getclobval() = '<atms></atms>' then
        select xmlelement("atms"
                       , xmlagg( xmlelement
                            ("record"
                            , xmlelement( "inst_desc"           , 'Undefined Institution')
                            , xmlelement( "agent_desc"          , 'Undefined Agent'      )
                            , xmlelement( "terminal_number"     , null                   )
                            , xmlelement( "address"             , null                   )
                            , xmlelement( "r_currency"          , null                   )
                            , xmlelement( "r_amount"            , null                   )
                            , xmlelement( "op_date"             , null                   )
                            , xmlelement( "currency"            , null                   )
                            , xmlelement( "amount"              , null                   )
                            , xmlelement( "p_currency"          , null                   )
                            , xmlelement( "p_amount"            , null                   )
                            , xmlelement( "type_string"         , null                   )
                            )
                    )
              )
        into l_atms from dual ;
    end if;
    
    select xmlelement ( "report"
             , l_header
             , l_atms
           )
    into l_result
    from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'atm_api_report_pkg.report_atm_turnover - ok' );

exception
  when no_data_found then trc_log_pkg.debug ( i_text => sqlerrm );

end;

procedure report_atm_disp_empty_cnt
  ( o_xml          out clob
  , i_lang         in com_api_type_pkg.t_dict_value
  , i_inst_id      in com_api_type_pkg.t_tiny_id   default null
  , i_agent_id     in com_api_type_pkg.t_short_id  default null
  )
is
  l_result        xmltype;
  l_atm_cnt       xmltype;
  l_header        xmltype;

begin
   trc_log_pkg.debug
        ( i_text       => 'atm_api_report_pkg.report_atm_disp_empty_cnt [#1][#2][#3]]'
        , i_env_param1 => i_lang
        , i_env_param2 => i_inst_id
        , i_env_param3 => i_agent_id
        );

   -- header
   select xmlelement( "header"
             , xmlelement( "rep_date", to_char(com_api_sttl_day_pkg.get_sysdate(), 'dd.mm.yyyy hh24:mi' ) )
             , xmlelement( "prm_inst",
                           decode( i_inst_id, null, null, to_char(i_inst_id) ||' - '|| get_text ('OST_INSTITUTION', 'NAME', i_inst_id, i_lang) )
                         )
             , xmlelement( "prm_agent",
                           decode( i_agent_id, null, null, to_char(i_agent_id) ||' - '|| get_text ('OST_AGENT', 'NAME', i_agent_id, i_lang) )
                         )
          ) xml
   into l_header
   from dual ;

   -- data
   select xmlelement ( "atm_cnt", xmlagg (t.xml) )
   into l_atm_cnt
   from (
     select xmlagg( xmlelement
                    ("table"
                    , xmlelement( "inst_desc"           , X.inst_desc            )
                    , xmlelement( "agent_desc"          , X.agent_desc           )
                    , xmlelement( "cnt_all"             , X.cnt_all              )
                    , xmlelement( "cnt_disp_empty"      , X.cnt_disp_empty       )
                    , xmlelement( "cnt_all_inst"        , X.cnt_all_inst         )
                    , xmlelement( "cnt_disp_empty_inst" , X.cnt_disp_empty_inst  )
                    , xmlelement( "cnt_all_tot"         , X.cnt_all_tot          )
                    , xmlelement( "cnt_disp_empty_tot"  , X.cnt_disp_empty_tot   )
                    )
                    order by X.inst_desc, X.agent_desc
            ) xml
     from ( 
            select inst_desc, agent_desc
                 , cnt_all
                 , sum (cnt_all) over(partition by inst_id) cnt_all_inst
                 , sum (cnt_all) over() cnt_all_tot
                 , cnt_disp_empty
                 , sum (cnt_disp_empty) over(partition by inst_id) cnt_disp_empty_inst
                 , sum (cnt_disp_empty) over() cnt_disp_empty_tot
              from ( select decode ( D.inst_id, null, 'Undefined Institution', to_char(D.inst_id) ||' - '|| get_text ('OST_INSTITUTION', 'NAME', D.inst_id, i_lang) ) as inst_desc
                          , decode ( D.agent_id, null, 'Undefined Agent', to_char(D.agent_id) ||' - '|| get_text ('OST_AGENT', 'NAME', D.agent_id, i_lang) ) as agent_desc
                          , count(D.id) cnt_all
                          , sum(D.disp_empty) cnt_disp_empty
                          , inst_id 
                       from ( select inst_id, agent_id, id, disp_cnt, disp_remaind_cnt
                                   , case when disp_cnt > 0 and disp_cnt > disp_remaind_cnt then 1 
                                          else 0
                                     end  as disp_empty
                                from ( select a.inst_id
                                            , c.agent_id
                                            , t.id
                                            , count (d.terminal_id) disp_cnt
                                            , sum( decode (nvl(dy.note_remained,0),0,0,1) ) disp_remaind_cnt
                                         from atm_terminal t
                                            , atm_dispenser d
                                            , atm_dispenser_dynamic dy
                                            , acq_terminal a
                                            , prd_contract c
                                        where t.id = d.terminal_id(+) 
                                          and d.id= dy.id(+)
                                          and t.id = a.id
                                          and a.contract_id = c.id(+)
                                          and ( nvl(a.inst_id, -99) = nvl(i_inst_id, nvl(a.inst_id, -99) ) )
                                          and ( nvl(c.agent_id, -99) = nvl(i_agent_id, nvl(c.agent_id, -99) ) )
                                        group by a.inst_id, c.agent_id, t.id
                                        order by a.inst_id, c.agent_id, t.id
                                     )
                            ) D
                      group by D.inst_id, D.agent_id
                   )
          ) X
        ) T;

    --if no data
    if l_atm_cnt.getclobval() = '<atm_cnt></atm_cnt>' then
        select xmlelement("atm_cnt"
                       , xmlagg( xmlelement
                            ("table"
                            , xmlelement( "inst_desc"           , 'Undefined Institution')
                            , xmlelement( "agent_desc"          , 'Undefined Agent'      )
                            , xmlelement( "cnt_all"             , null                   )
                            , xmlelement( "cnt_disp_empty"      , null                   )
                            , xmlelement( "cnt_all_inst"        , null                   )
                            , xmlelement( "cnt_disp_empty_inst" , null                   )
                            , xmlelement( "cnt_all_tot"         , null                   )
                            , xmlelement( "cnt_disp_empty_tot"  , null                   )
                            )
                    )
              )
        into l_atm_cnt from dual ;
    end if;
    
    select xmlelement ( "report"
             , l_header
             , l_atm_cnt
           )
    into l_result
    from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'atm_api_report_pkg.report_atm_disp_empty_cnt - ok' );

exception
  when no_data_found then trc_log_pkg.debug ( i_text => sqlerrm );

end;

end;
/
