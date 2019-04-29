create or replace package body acq_api_audit_report_pkg
is

function get_prev_oper_date (
    i_terminal_id in com_api_type_pkg.t_short_id
  , i_oper_date   in date
) return date
is
    vReturn date;
begin
    select max(o.oper_date)
      into vReturn
      from opr_operation   o 
         , opr_participant opa
     where opa.oper_id = o.id
       and opa.participant_type = 'PRTYACQ'
       and opa.terminal_id = i_terminal_id
       and o.oper_date < i_oper_date ;

    return vReturn ;
exception
    when others then
        return null;
end;

function get_trans_count_post_inactive(
    i_terminal_id in com_api_type_pkg.t_short_id
  , i_start_date  in date
  , i_end_date    in date
) return com_api_type_pkg.t_short_id
is
    vReturn com_api_type_pkg.t_short_id;
begin
    select count(o.id)
      into vReturn
      from opr_operation   o 
         , opr_participant opa
     where opa.oper_id = o.id
       and opa.participant_type = 'PRTYACQ'
       and opa.terminal_id = i_terminal_id
       and o.oper_date between i_start_date and i_end_date;

    return vReturn;
exception
    when others then
        return null;
end;

procedure get_header (
          i_lang         in com_api_type_pkg.t_dict_value
        , i_inst_id      in com_api_type_pkg.t_tiny_id
        , i_network_id   in com_api_type_pkg.t_network_id
        , i_date_start   in date
        , i_date_end     in date
        , i_currency     in com_api_type_pkg.t_curr_code
        , i_threshold    in com_api_type_pkg.t_short_id
        , o_header       out xmltype
        )
is
begin
    select
         xmlelement ( "header",
              xmlelement( "inst_id", decode( i_inst_id, null, '0'
                                           , i_inst_id||' - '||com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', i_inst_id, i_lang) )
                        )
            , xmlelement( "network_id", decode( i_network_id, null, '0'
                                              , i_network_id||' - '||com_api_i18n_pkg.get_text('NET_NETWORK','NAME', i_network_id, i_lang) )
                        )
            , xmlelement( "threshold" , i_threshold                         )
            , xmlelement( "date_start", to_char(i_date_start, 'dd.mm.yyyy') )
            , xmlelement( "date_end"  , to_char(i_date_end, 'dd.mm.yyyy')   )
            , xmlelement( "currency"  , i_currency                          )
         )
    into
         o_header
    from (
           select i_inst_id
                   , i_network_id
                   , i_threshold
                   , i_date_start
                   , i_date_end
                   , i_currency
            from dual
         );

exception when others then raise_application_error (-20001, sqlerrm);
  --raise;
end;

procedure get_header (
          i_lang         in com_api_type_pkg.t_dict_value
        , i_inst_id      in com_api_type_pkg.t_tiny_id
        , i_network_id   in com_api_type_pkg.t_network_id
        , i_date_start   in date
        , i_date_end     in date
        , o_header       out xmltype
        )
is
begin
    select
         xmlelement ( "header",
              xmlelement( "inst_id", decode( i_inst_id, null, '0'
                                           , i_inst_id||' - '||com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', i_inst_id, i_lang) )
                        )
            , xmlelement( "network_id", decode( i_network_id, null, '0'
                                              , i_network_id||' - '||com_api_i18n_pkg.get_text('NET_NETWORK','NAME', i_network_id, i_lang) )
                        )
            , xmlelement( "date_start", to_char(i_date_start, 'dd.mm.yyyy') )
            , xmlelement( "date_end"  , to_char(i_date_end, 'dd.mm.yyyy')   )
         )
    into
         o_header
    from (
           select i_inst_id
                   , i_network_id
                   , i_date_start
                   , i_date_end
            from dual
         );

exception when others then raise_application_error (-20001, sqlerrm);
  --raise;
end;

procedure get_header (
          i_lang         in com_api_type_pkg.t_dict_value
        , i_inst_id      in com_api_type_pkg.t_tiny_id
        , i_network_id   in com_api_type_pkg.t_network_id
        , o_header       out xmltype
        )
is
begin
    select
         xmlelement ( "header",
              xmlelement( "inst_id", decode( i_inst_id, null, '0'
                                           , i_inst_id||' - '||com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', i_inst_id, i_lang) )
                        )
            , xmlelement( "network_id", decode( i_network_id, null, '0'
                                              , i_network_id||' - '||com_api_i18n_pkg.get_text('NET_NETWORK','NAME', i_network_id, i_lang) )
                        )
         )
    into
         o_header
    from (
           select i_inst_id, i_network_id from dual
         );

exception when others then raise_application_error (-20001, sqlerrm);
  --raise;
end;

procedure get_currency_prm (
          i_currency  in  com_api_type_pkg.t_tiny_id
        , o_format    out varchar2
        , o_currency  out com_api_type_pkg.t_curr_code
        , o_exponent  out com_api_type_pkg.t_tiny_id
        )
is
begin
    select
         'FM999999999999999990' || decode ( nvl(exponent,0), 0, null, '.' || lpad('0',exponent,'0') )
       , name
       , exponent
    into
         o_format
       , o_currency
       , o_exponent
    from
         com_currency
    where
         code = nvl(i_currency, 643) ;

exception when others then raise_application_error (-20001, sqlerrm);
  --raise;
end;


procedure total_avg_term_auth (  
        o_xml              out clob
        , i_lang           in com_api_type_pkg.t_dict_value
        , i_inst_id        in com_api_type_pkg.t_inst_id    default null
        , i_network_id     in com_api_type_pkg.t_network_id default null
        , i_date_start     in date
        , i_date_end       in date
        , i_currency       in com_api_type_pkg.t_curr_name  default '643'
        , i_threshold      in com_api_type_pkg.t_short_id   default 1
        )
is
begin
    get_list_of_transactions (
        o_xml           => o_xml
        , i_lang        => i_lang
        , i_inst_id     => i_inst_id
        , i_network_id  => i_network_id
        , i_date_start  => i_date_start
        , i_date_end    => i_date_end
        , i_currency    => i_currency
        , i_threshold   => i_threshold
        , i_mode        => 0
    ) ;
end;
        
procedure total_avg_term_chargeback (
        o_xml              out clob
        , i_lang           in com_api_type_pkg.t_dict_value
        , i_inst_id        in com_api_type_pkg.t_inst_id    default null
        , i_network_id     in com_api_type_pkg.t_network_id default null
        , i_date_start     in date
        , i_date_end       in date
        , i_currency       in com_api_type_pkg.t_curr_name  default '643'
        , i_threshold      in com_api_type_pkg.t_short_id   default 1
        )
is
begin
    get_list_of_transactions (
        o_xml           => o_xml
        , i_lang        => i_lang
        , i_inst_id     => i_inst_id
        , i_network_id  => i_network_id
        , i_date_start  => i_date_start
        , i_date_end    => i_date_end
        , i_currency    => i_currency
        , i_threshold   => i_threshold
        , i_mode        => 1
    ) ;
end;
        
procedure total_avg_term_credit (
        o_xml              out clob
        , i_lang           in com_api_type_pkg.t_dict_value
        , i_inst_id        in com_api_type_pkg.t_inst_id    default null
        , i_network_id     in com_api_type_pkg.t_network_id default null
        , i_date_start     in date
        , i_date_end       in date
        , i_currency       in com_api_type_pkg.t_curr_name  default '643'
        , i_threshold      in com_api_type_pkg.t_short_id   default 1
        )
is
begin
    get_list_of_transactions (
        o_xml           => o_xml
        , i_lang        => i_lang
        , i_inst_id     => i_inst_id
        , i_network_id  => i_network_id
        , i_date_start  => i_date_start
        , i_date_end    => i_date_end
        , i_currency    => i_currency
        , i_threshold   => i_threshold
        , i_mode        => 2
    ) ;
end;

procedure total_avg_term_manual (
        o_xml              out clob
        , i_lang           in com_api_type_pkg.t_dict_value
        , i_inst_id        in com_api_type_pkg.t_inst_id    default null
        , i_network_id     in com_api_type_pkg.t_network_id default null
        , i_date_start     in date
        , i_date_end       in date
        , i_currency       in com_api_type_pkg.t_curr_name  default '643'
        , i_threshold      in com_api_type_pkg.t_short_id   default 1
        )
is
begin
    get_list_of_transactions (
        o_xml           => o_xml
        , i_lang        => i_lang
        , i_inst_id     => i_inst_id
        , i_network_id  => i_network_id
        , i_date_start  => i_date_start
        , i_date_end    => i_date_end
        , i_currency    => i_currency
        , i_threshold   => i_threshold
        , i_mode        => 3
    ) ;
end;
        
procedure total_avg_term_below_floor_lmt (
        o_xml              out clob
        , i_lang           in com_api_type_pkg.t_dict_value
        , i_inst_id        in com_api_type_pkg.t_inst_id    default null
        , i_network_id     in com_api_type_pkg.t_network_id default null
        , i_date_start     in date
        , i_date_end       in date
        , i_currency       in com_api_type_pkg.t_curr_name  default '643'
        , i_threshold      in com_api_type_pkg.t_short_id   default 1
        )
is
begin
    get_list_of_transactions (
        o_xml           => o_xml
        , i_lang        => i_lang
        , i_inst_id     => i_inst_id
        , i_network_id  => i_network_id
        , i_date_start  => i_date_start
        , i_date_end    => i_date_end
        , i_currency    => i_currency
        , i_threshold   => i_threshold
        , i_mode        => 4
    ) ;
end;
        
procedure get_list_of_transactions (
        o_xml              out clob
        , i_lang           in com_api_type_pkg.t_dict_value
        , i_inst_id        in com_api_type_pkg.t_inst_id    default null
        , i_network_id     in com_api_type_pkg.t_network_id default null
        , i_date_start     in date
        , i_date_end       in date
        , i_currency       in com_api_type_pkg.t_curr_name  default '643'
        , i_threshold      in com_api_type_pkg.t_short_id   default 1
        , i_mode           in com_api_type_pkg.t_sign
        )
-- i_mode
-- 0 - reports 2.1, 2.2 (all financial transactions)
-- 1 - report 2.4 (Retrieval Request and Chargeback )
-- 2 - report 2.8 (Credits (refunds) )
-- 3 - report 2.5 (Key-Entered Transactions)
-- 4 - report 2.6 (Below Floor Limit)
is
    l_date_start       date;
    l_date_end         date;
    l_lang             com_api_type_pkg.t_dict_value;
    l_threshold        com_api_type_pkg.t_short_id ;

    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;

    l_format           varchar2(24);
    l_currency         com_api_type_pkg.t_curr_code;
    l_exponent         com_api_type_pkg.t_tiny_id;

begin

    trc_log_pkg.debug (
            i_text          => 'acq_api_audit_report_pkg.get_list_of_transactions [#1][#2][#3][#4][#5][#6]'
            , i_env_param1  => i_lang
            , i_env_param2  => i_inst_id
            , i_env_param3  => i_network_id
            , i_env_param4  => com_api_type_pkg.convert_to_char(trunc(nvl(i_date_start, com_api_sttl_day_pkg.get_sysdate)))
            , i_env_param5  => com_api_type_pkg.convert_to_char(nvl(trunc(i_date_end), l_date_start) + 1 - (1/86400))
            , i_env_param6  => i_threshold
    );

    l_date_start := trunc( nvl(i_date_start, com_api_sttl_day_pkg.get_sysdate) );
    l_date_end   := nvl( trunc(i_date_end), l_date_start ) + 1 - (1/86400);
    l_threshold  := nvl( i_threshold, 1 );
    l_lang       := nvl( i_lang, get_user_lang );

    get_currency_prm (
          i_currency  => i_currency
        , o_format    => l_format
        , o_currency  => l_currency
        , o_exponent  => l_exponent
        ) ;

    get_header (
          i_lang         => l_lang
        , i_inst_id      => i_inst_id
        , i_network_id   => i_network_id
        , i_date_start   => i_date_start
        , i_date_end     => i_date_end
        , i_currency     => l_currency
        , i_threshold    => l_threshold
        , o_header       => l_header
        ) ;

    -- details
      select 
             xmlelement("table"
                       , xmlagg(
                            xmlelement("record"
                                 , xmlelement( "terminal_number"  , terminal_number  )
                                 , xmlelement( "oper_date"        , to_char(oper_date, 'dd.mm.yyyy') )
                                 , xmlelement( "day_term_cnt"     , day_term_cnt     )
                                 , xmlelement( "avg_day_term_cnt" , avg_day_term_cnt )
                                 , xmlelement( "percent_cnt"      , percent_cnt      )
                                 , xmlelement( "day_term_amt"     , day_term_amt     )
                                 , xmlelement( "avg_day_term_amt" , avg_day_term_amt )
                                 , xmlelement( "percent_amt"      , percent_amt      )
                            )
                         )
             )
      into
           l_detail
      from (
             select opr.terminal_number
                  , opr.oper_date
                  , to_char( opr.day_term_cnt )     as day_term_cnt
                  , to_char( opr.avg_day_term_cnt ) as avg_day_term_cnt
                  , decode ( opr.avg_day_term_cnt, 0, 999,
                             round  ( (abs(opr.day_term_cnt - opr.avg_day_term_cnt) / opr.avg_day_term_cnt * 100), 2 ) 
                           )                        as percent_cnt
                  , to_char( opr.day_term_amt / power(10, l_exponent), l_format ) 
                                                    as day_term_amt
                  , to_char( opr.avg_day_term_amt / power(10, l_exponent), l_format ) 
                                                    as avg_day_term_amt
                  , decode ( opr.avg_day_term_amt, 0, 999,
                             round  ( (abs(opr.day_term_amt - opr.avg_day_term_amt) / opr.avg_day_term_amt * 100), 2 ) 
                           )                        as percent_amt
             from
                  ( select terminal_number
                         , oper_date
                         , count(1)         as day_term_cnt
                         , avg_day_term_cnt
                         , sum(oper_amount) as day_term_amt
                         , avg_day_term_amt
                      from ( select t.terminal_number
                                  , trunc(o.oper_date)                         as oper_date
                                  , o.oper_amount * decode(is_reversal,1,-1,1) as oper_amount
                                  , round ( count(1) over(partition by pa.terminal_id) / count(distinct trunc(o.oper_date) ) over(partition by pa.terminal_id), 0 ) 
                                                                               as avg_day_term_cnt
                                  , round ( sum(o.oper_amount) over(partition by pa.terminal_id) / count(distinct trunc(o.oper_date) ) over(partition by pa.terminal_id), 0 ) 
                                                                               as avg_day_term_amt     --average value with count of active days of terminals
                                  --, round ( sum(o.oper_amount) over(partition by pa.terminal_id) / (l_date_end + (1/86400) - l_date_start), 0 ) 
                                                                            --   as avg_day_term_amt     --average value with count of days of specified period
                               from opr_operation   o
                                  , opr_participant pi
                                  , opr_participant pa
                                  , acq_terminal    t
                                  , acq_merchant    m
                              where o.id = pi.oper_id
                                and pi.participant_type = 'PRTYISS'
                                and o.id = pa.oper_id
                                and pa.participant_type = 'PRTYACQ'
                                and t.id = pa.terminal_id
                                and o.oper_date between l_date_start and l_date_end
                                and o.oper_currency = nvl(i_currency, 643)
                                and m.id = pa.merchant_id
                                and m.contract_id in
                                     ( select acnt.contract_id
                                         from acc_macros a_m, acc_entry a_e, acc_account acnt
                                        where a_m.object_id = o.id
                                          and a_m.entity_type = 'ENTTOPER'
                                          and a_e.macros_id = a_m.id
                                          and acnt.id = a_e.account_id
                                     )
                                and o.status = 'OPST0400'
                                and o.sttl_type = 'STTT0200'
                                and ( i_inst_id is null or t.inst_id = i_inst_id )
                                and ( i_network_id is null or pi.card_network_id = i_network_id )
                          --which report 
                                and ( ( i_mode = 0 )             -- all financial transactions
                                      or ( i_mode = 1            -- Retrieval Request and Chargeback
                                           and o.msg_type in ('MSGTCHBK') 
                                         )
                                      or ( i_mode = 2            -- Credits (refunds)
                                           and o.oper_type in ('OPTP0020') 
                                         )  
                                      or ( i_mode = 3            -- Key-Entered Transactions
                                           and exists ( select 1 from aut_auth
                                                         where id = o.id 
                                                           and card_data_input_mode in ('F2270001','F2270006','F2270009','F2270007')
                                                      )
                                         )
                                    /*  or ( i_mode = 4            -- Below Floor Limit
                                            and  
                                         ) */
                                    )
                           )
                    group by terminal_number, oper_date, avg_day_term_cnt, avg_day_term_amt
                  ) opr
             where
                  ( round ( (abs(opr.day_term_amt - opr.avg_day_term_amt) / opr.avg_day_term_amt * 100), 2 ) >= l_threshold
                    or
                    round ( (abs(opr.day_term_cnt - opr.avg_day_term_cnt) / opr.avg_day_term_cnt * 100), 2 ) >= l_threshold
                  )
             order by opr.terminal_number, opr.oper_date
           );

    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table"
                       , xmlagg(
                            xmlelement("record"
                                 , xmlelement( "terminal_number"  , null )
                                 , xmlelement( "oper_date"        , null )
                                 , xmlelement( "day_term_cnt"     , null )
                                 , xmlelement( "avg_day_term_cnt" , null )
                                 , xmlelement( "percent_cnt"      , null )
                                 , xmlelement( "day_term_amt"     , null )
                                 , xmlelement( "avg_day_term_amt" , null )
                                 , xmlelement( "percent_amt"      , null )
                            )
                         )
              )
        into l_detail from dual ;
    end if;

    select xmlelement ( "report"
             , l_header
             , l_detail
           )
    into l_result from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'acq_api_audit_report_pkg.get_list_of_transactions - ok' );

exception when others then
    trc_log_pkg.debug ( i_text => sqlerrm );
    raise ;
end;


procedure total_avg_card_term_auth (
        o_xml              out clob
        , i_lang           in com_api_type_pkg.t_dict_value
        , i_inst_id        in com_api_type_pkg.t_inst_id    default null
        , i_network_id     in com_api_type_pkg.t_network_id default null
        , i_date_start     in date
        , i_date_end       in date
        , i_currency       in com_api_type_pkg.t_curr_name  default '643'
        , i_threshold      in com_api_type_pkg.t_short_id   default 1
        )
is
begin
    get_list_of_card_bin_trans (
        o_xml           => o_xml
        , i_lang        => i_lang
        , i_inst_id     => i_inst_id
        , i_network_id  => i_network_id
        , i_date_start  => i_date_start
        , i_date_end    => i_date_end
        , i_currency    => i_currency
        , i_threshold   => i_threshold
        , i_mode        => 1
    ) ;
end;

procedure total_avg_bin_term_auth (
        o_xml              out clob
        , i_lang           in com_api_type_pkg.t_dict_value
        , i_inst_id        in com_api_type_pkg.t_inst_id    default null
        , i_network_id     in com_api_type_pkg.t_network_id default null
        , i_date_start     in date
        , i_date_end       in date
        , i_currency       in com_api_type_pkg.t_curr_name  default '643'
        , i_threshold      in com_api_type_pkg.t_short_id   default 1
        )
is
begin
    get_list_of_card_bin_trans (
        o_xml           => o_xml
        , i_lang        => i_lang
        , i_inst_id     => i_inst_id
        , i_network_id  => i_network_id
        , i_date_start  => i_date_start
        , i_date_end    => i_date_end
        , i_currency    => i_currency
        , i_threshold   => i_threshold
        , i_mode        => 2
    ) ;
end;

procedure get_list_of_card_bin_trans (
        o_xml              out clob
        , i_lang           in com_api_type_pkg.t_dict_value
        , i_inst_id        in com_api_type_pkg.t_inst_id    default null
        , i_network_id     in com_api_type_pkg.t_network_id default null
        , i_date_start     in date
        , i_date_end       in date
        , i_currency       in com_api_type_pkg.t_curr_name  default '643'
        , i_threshold      in com_api_type_pkg.t_short_id   default 1
        , i_mode           in com_api_type_pkg.t_sign
        )
-- i_mode
-- 1 - report 2.3 (transactions by card)
-- 2 - report 2.7 (transactions by BIN )

is
    l_date_start       date;
    l_date_end         date;
    l_lang             com_api_type_pkg.t_dict_value;
    l_threshold        com_api_type_pkg.t_short_id ;

    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;

    l_format           varchar2(24);
    l_currency         com_api_type_pkg.t_curr_code;
    l_exponent         com_api_type_pkg.t_tiny_id;

begin

    trc_log_pkg.debug (
            i_text          => 'acq_api_audit_report_pkg.get_list_of_card_bin_trans [#1][#2][#3][#4][#5][#6]'
            , i_env_param1  => i_lang
            , i_env_param2  => i_inst_id
            , i_env_param3  => i_network_id
            , i_env_param4  => com_api_type_pkg.convert_to_char(trunc(nvl(i_date_start, com_api_sttl_day_pkg.get_sysdate)))
            , i_env_param5  => com_api_type_pkg.convert_to_char(nvl(trunc(i_date_end), l_date_start) + 1 - (1/86400))
            , i_env_param6  => i_threshold
    );

    l_date_start := trunc( nvl(i_date_start, com_api_sttl_day_pkg.get_sysdate) );
    l_date_end   := nvl( trunc(i_date_end), l_date_start ) + 1 - (1/86400);
    l_threshold  := nvl( i_threshold, 1 );
    l_lang       := nvl( i_lang, get_user_lang );

    get_currency_prm (
          i_currency  => i_currency
        , o_format    => l_format
        , o_currency  => l_currency
        , o_exponent  => l_exponent
        ) ;

    get_header (
          i_lang         => l_lang
        , i_inst_id      => i_inst_id
        , i_network_id   => i_network_id
        , i_date_start   => i_date_start
        , i_date_end     => i_date_end
        , i_currency     => l_currency
        , i_threshold    => l_threshold
        , o_header       => l_header
        ) ;

    -- details
      select
             xmlelement("table"
                       , xmlagg(
                            xmlelement("record"
                                 , xmlelement( "p_number"         , p_number         )
                                 , xmlelement( "terminal_number"  , terminal_number  )
                                 , xmlelement( "oper_date"        , to_char(oper_date, 'dd.mm.yyyy') )
                                 , xmlelement( "day_term_cnt"     , day_term_cnt     )
                                 , xmlelement( "avg_day_term_cnt" , avg_day_term_cnt )
                                 , xmlelement( "percent_cnt"      , percent_cnt      )
                                 , xmlelement( "day_term_amt"     , day_term_amt     )
                                 , xmlelement( "avg_day_term_amt" , avg_day_term_amt )
                                 , xmlelement( "percent_amt"      , percent_amt      )
                            )
                         )
             )
      into
           l_detail
      from (
             select opr.p_number
                  , opr.terminal_number
                  , opr.oper_date
                  , to_char( opr.day_term_cnt )            as day_term_cnt
                  , to_char( opr.avg_day_term_cnt )        as avg_day_term_cnt
                  , decode ( opr.avg_day_term_cnt, 0, 999,
                             round ( (abs(opr.day_term_cnt - opr.avg_day_term_cnt) / opr.avg_day_term_cnt * 100), 2 ) 
                           )                               as percent_cnt
                  , to_char( opr.day_term_amt / power(10, l_exponent), l_format ) 
                                                           as day_term_amt
                  , to_char( opr.avg_day_term_amt / power(10, l_exponent), l_format ) 
                                                           as avg_day_term_amt
                  , decode ( opr.avg_day_term_amt, 0, 999,
                             round ( (abs(opr.day_term_amt - opr.avg_day_term_amt) / opr.avg_day_term_amt * 100), 2 ) 
                           )                               as percent_amt
             from
                  ( select p_number
                         , terminal_number
                         , oper_date
                         , count(1)         as day_term_cnt
                         , avg_day_term_cnt
                         , sum(oper_amount) as day_term_amt
                         , avg_day_term_amt
                    from 
                           ( select decode(
                                        i_mode
                                      , 1, iss_api_token_pkg.decode_card_number(i_card_number => c.card_number)
                                      , 2, substr(c.card_number, 1, 6)
                                    )                                          as p_number 
                                  , t.terminal_number
                                  , trunc(o.oper_date)                         as oper_date
                                  , o.oper_amount * decode(is_reversal,1,-1,1) as oper_amount
                                  , round( count(1) over( partition by decode(i_mode, 1, c.card_number, 2, substr(c.card_number,1,6)), pa.terminal_id ) 
                                           / count(distinct trunc(o.oper_date) )
                                                 over (partition by decode(i_mode, 1, c.card_number, 2, substr(c.card_number,1,6)), pa.terminal_id)
                                         , 0 
                                         )                                     as avg_day_term_cnt
                                  , round( sum(o.oper_amount) over( partition by decode(i_mode, 1, c.card_number, 2, substr(c.card_number,1,6)), pa.terminal_id ) 
                                           / count(distinct trunc(o.oper_date) )
                                                 over (partition by decode(i_mode, 1, c.card_number, 2, substr(c.card_number,1,6)), pa.terminal_id)
                                         , 0  
                                         )                                     as avg_day_term_amt
                               from opr_operation   o
                                  , opr_participant pa
                                  , opr_participant pi
                                  , opr_card        c
                                  , acq_terminal    t
                                  , acq_merchant    m
                                  --, acc_macros      a_m
                                  --, acc_entry       a_e
                                  --, acc_account     acnt
                              where o.oper_date between l_date_start and l_date_end
                                and o.id = pa.oper_id
                                and pa.participant_type = 'PRTYACQ'
                                and o.id = pi.oper_id
                                and pi.participant_type = 'PRTYISS'
                                and o.id = c.oper_id
                                and c.participant_type = 'PRTYISS'
                                and t.id = pa.terminal_id
                                and m.id = pa.merchant_id
                               /* and a_m.object_id = o.id           --select operations that are in acc_macros
                                and a_m.entity_type = 'ENTTOPER'
                                and a_e.macros_id = a_m.id
                                and acnt.id = a_e.account_id
                                and acnt.contract_id = m.contract_id */
                                and m.contract_id in
                                     ( select acnt.contract_id
                                         from acc_macros a_m, acc_entry a_e, acc_account acnt
                                        where a_m.object_id = o.id
                                          and a_m.entity_type = 'ENTTOPER'
                                          and a_e.macros_id = a_m.id
                                          and acnt.id = a_e.account_id
                                     )
                                and o.oper_currency = nvl(i_currency, 643)
                                and o.status = 'OPST0400'
                                and o.sttl_type = 'STTT0200'
                                and ( i_inst_id is null or t.inst_id = i_inst_id )
                                and ( i_network_id is null or pi.card_network_id = i_network_id )
                           )
                    group by p_number, terminal_number, oper_date, avg_day_term_cnt, avg_day_term_amt
                  ) opr
             where
                  ( round ( (abs(opr.day_term_amt - opr.avg_day_term_amt) / opr.avg_day_term_amt * 100), 2 ) >= l_threshold
                    or
                    round ( (abs(opr.day_term_cnt - opr.avg_day_term_cnt) / opr.avg_day_term_cnt * 100), 2 ) >= l_threshold
                  )
             order by p_number, terminal_number, oper_date
           );

    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table"
                       , xmlagg(
                            xmlelement("record"
                                 , xmlelement( "p_number"         , null )
                                 , xmlelement( "terminal_number"  , null )
                                 , xmlelement( "oper_date"        , null )
                                 , xmlelement( "day_term_cnt"     , null )
                                 , xmlelement( "avg_day_term_cnt" , null )
                                 , xmlelement( "percent_cnt"      , null )
                                 , xmlelement( "day_term_amt"     , null )
                                 , xmlelement( "avg_day_term_amt" , null )
                                 , xmlelement( "percent_amt"      , null )
                            )
                         )
               )
        into l_detail from dual ;
    end if;

    select xmlelement ( "report"
             , l_header
             , l_detail
           )
    into l_result from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'acq_api_audit_report_pkg.get_list_of_card_bin_trans - ok' );

exception when others then
    trc_log_pkg.debug ( i_text => sqlerrm );
    raise ;
end;

procedure get_term_active_after_closing (
        o_xml              out clob
        , i_lang           in com_api_type_pkg.t_dict_value
        , i_inst_id        in com_api_type_pkg.t_inst_id    default null
        , i_network_id     in com_api_type_pkg.t_network_id default null
        , i_date_start     in date
        , i_date_end       in date
        )
is
    l_date_start       date;
    l_date_end         date;
    l_lang             com_api_type_pkg.t_dict_value;

    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;

begin

    trc_log_pkg.debug (
            i_text          => 'acq_api_audit_report_pkg.get_after_closing [#1][#2][#3][#4][#5]'
            , i_env_param1  => i_lang
            , i_env_param2  => i_inst_id
            , i_env_param3  => i_network_id
            , i_env_param4  => i_date_start
            , i_env_param5  => i_date_end
    );

    l_lang       := nvl( i_lang, get_user_lang );
    l_date_start := i_date_start;
    case when i_date_end is null then  l_date_end := i_date_end;
         else l_date_end :=  i_date_end + 1 - (1/86400);
    end case;

    get_header (
          i_lang         => l_lang
        , i_inst_id      => i_inst_id
        , i_network_id   => i_network_id
        , i_date_start   => i_date_start
        , i_date_end     => i_date_end
        , o_header       => l_header
        ) ;

    -- details
      select
             xmlelement("table"
                       , xmlagg(
                            xmlelement("record"
                                 , xmlelement( "terminal_number" , terminal_number )
                                 , xmlelement( "end_date"        , to_char(end_date, 'dd.mm.yyyy') )
                                 , xmlelement( "trans_cnt"       , trans_cnt       )
                            )
                         )
             )
      into
           l_detail
      from (  
                    select terminal_number
                         , end_date
                         , count(1) as trans_cnt
                      from ( 
                             select 
                                    o.id
                                  , t.terminal_number
                                  , c.end_date
                               from 
                                    opr_operation     o
                                  , opr_participant   pa
                                  , opr_participant   pi
                                  , acq_terminal      t
                                  , acq_merchant      m
                                  , prd_contract      c
                              where 
                                    (   (l_date_start is null) 
                                     or (l_date_start is not null and o.oper_date >= l_date_start )      
                                    )
                                and (   (l_date_end is null) 
                                     or (l_date_end is not null and o.oper_date <= l_date_end )      
                                    )
                                and o.id = pa.oper_id
                                and pa.participant_type = 'PRTYACQ'
                                and o.id = pi.oper_id
                                and pi.participant_type = 'PRTYISS'
                                and t.id = pa.terminal_id
                                and m.id = pa.merchant_id
                                and m.contract_id in
                                         ( select acnt.contract_id
                                             from acc_macros      a_m
                                                , acc_entry       a_e
                                                , acc_account     acnt
                                            where a_m.object_id   = o.id
                                              and a_m.entity_type = 'ENTTOPER'
                                              and a_e.macros_id   = a_m.id
                                              and acnt.id         = a_e.account_id
                                         ) 
                                --and o.status = 'OPST0400'
                                and c.id = m.contract_id
                                and (   (l_date_end is null) 
                                     or (l_date_end is not null and trunc(c.end_date) < l_date_end - 1 )      
                                    ) 
                                and o.oper_date > decode ( to_number( to_char(c.end_date,'hh24miss') ), 0
                                                         , trunc(c.end_date) + 1 - 1/86400  
                                                         , c.end_date
                                                         ) 
                                and ( i_inst_id is null or t.inst_id = i_inst_id )
                                and ( i_network_id is null or pi.card_network_id = i_network_id )
                           )
                    group by terminal_number, end_date
                    order by terminal_number
           );

    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table"
                       , xmlagg(
                            xmlelement("record"
                                 , xmlelement( "terminal_number" , null )
                                 , xmlelement( "end_date"        , null )
                                 , xmlelement( "trans_cnt"       , null )
                            )
                         )
               )
        into l_detail from dual ;
    end if;

    select xmlelement ( "report"
             , l_header
             , l_detail
           )
    into l_result from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'acq_api_audit_report_pkg.get_after_closing - ok' );

exception when others then
    trc_log_pkg.debug ( i_text => sqlerrm );
    raise ;
end;

procedure get_term_inactive (
        o_xml              out clob
        , i_lang           in com_api_type_pkg.t_dict_value
        , i_inst_id        in com_api_type_pkg.t_inst_id    default null
        , i_network_id     in com_api_type_pkg.t_network_id default null
        , i_date_end       in date
        )
is
    l_date_start       date;
    l_date_end         date;
    l_lang             com_api_type_pkg.t_dict_value;

    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;

begin

    trc_log_pkg.debug (
            i_text          => 'acq_api_audit_report_pkg.get_term_inactive [#1][#2][#3][#4]'
            , i_env_param1  => i_lang
            , i_env_param2  => i_inst_id
            , i_env_param3  => i_network_id
            , i_env_param4  => i_date_end
    );

    l_lang       := nvl( i_lang, get_user_lang );
    l_date_end   := trunc( nvl(i_date_end, com_api_sttl_day_pkg.get_sysdate) ) + 1 ;
    l_date_start := add_months( trunc( nvl(i_date_end, com_api_sttl_day_pkg.get_sysdate) ), -3 ) ;

    get_header (
          i_lang         => l_lang
        , i_inst_id      => i_inst_id
        , i_network_id   => i_network_id
        , o_header       => l_header
        ) ;

    -- details
      select
             xmlelement("table"
                       , xmlagg(
                            xmlelement("record"
                                 , xmlelement( "terminal_number" , terminal_number )
                                 , xmlelement( "start_date"      , to_char(l_date_start, 'dd.mm.yyyy') )
                                 , xmlelement( "end_date"        , to_char(l_date_end, 'dd.mm.yyyy') )
                            )
                         )
             )
      into
           l_detail
      from (
              select 
                    t.terminal_number
                  , l_date_start
                  , l_date_end
              from
                    acq_terminal t
                  , acq_merchant m
              where
                    ( i_inst_id is null or m.inst_id = i_inst_id )
                and t.merchant_id = m.id
                and not exists
                             (select 1 
                                from opr_operation   o
                                   , opr_participant pa
                                   , opr_participant pi
                                   , acq_merchant    me
                               where o.oper_date between l_date_start and l_date_end - (1/86400) 
                                 and o.id = pa.oper_id
                                 and pa.participant_type = 'PRTYACQ'
                                 and o.id = pi.oper_id
                                 and pi.participant_type = 'PRTYISS'
                                 and pa.terminal_id = t.id
                                 and me.id = pa.merchant_id
                                 and me.contract_id in
                                        ( select acnt.contract_id
                                            from acc_macros a_m, acc_entry a_e, acc_account acnt
                                           where a_m.object_id = o.id 
                                             and a_m.entity_type = 'ENTTOPER'
                                             and a_e.macros_id = a_m.id
                                             and acnt.id = a_e.account_id
                                        )  
                                 --and o.status = 'OPST0400'
                                 and o.sttl_type = 'STTT0200'
                                 and ( i_inst_id is null or me.inst_id = i_inst_id )
                                 and ( i_network_id is null or pi.card_network_id = i_network_id )
                             )
              order by terminal_number
           );

    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table"
                       , xmlagg(
                            xmlelement("record"
                                 , xmlelement( "terminal_number" , null )
                                 , xmlelement( "start_date"      , null )
                                 , xmlelement( "end_date"        , null )
                            )
                         )
               )
        into l_detail from dual ;
    end if;

    select xmlelement ( "report"
             , l_header
             , l_detail
           )
    into l_result from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'acq_api_audit_report_pkg.get_term_inactive - ok' );

exception when others then
    trc_log_pkg.debug ( i_text => sqlerrm );
    raise ;
end;

procedure get_term_active_after_inactive (
        o_xml              out clob
        , i_lang           in com_api_type_pkg.t_dict_value
        , i_inst_id        in com_api_type_pkg.t_inst_id    default null
        , i_network_id     in com_api_type_pkg.t_network_id default null
        , i_date_start     in date
        , i_date_end       in date
        )
is
    l_date_start       date;
    l_date_end         date;
    l_lang             com_api_type_pkg.t_dict_value;

    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;

    v_3months_days     number := 5;

begin

    trc_log_pkg.debug (
            i_text          => 'acq_api_audit_report_pkg.get_term_active_after_inactive [#1][#2][#3][#4][#5]'
            , i_env_param1  => i_lang
            , i_env_param2  => i_inst_id
            , i_env_param3  => i_network_id
            , i_env_param4  => i_date_start
            , i_env_param5  => i_date_end
    );

    l_lang       := nvl( i_lang, get_user_lang );
    l_date_start := trunc( nvl(i_date_start, com_api_sttl_day_pkg.get_sysdate) );
    l_date_end   := nvl( trunc(i_date_end), l_date_start ) + 1 - (1/86400);

    get_header (
          i_lang         => l_lang
        , i_inst_id      => i_inst_id
        , i_network_id   => i_network_id
        , i_date_start   => i_date_start
        , i_date_end     => i_date_end
        , o_header       => l_header
        ) ;

    -- details
      select
             xmlelement("table"
                       , xmlagg(
                            xmlelement("record"
                                 , xmlelement( "terminal_number"     , terminal_number )
                                 , xmlelement( "inactive_date_start" , to_char(inactive_date_start, 'dd.mm.yyyy') )
                                 , xmlelement( "inactive_date_end"   , to_char(inactive_date_end, 'dd.mm.yyyy') )
                                 , xmlelement( "trans_count"         , trans_count )

                            )
                         )
             )
      into
           l_detail
      from (
             select
                    terminal_number
                  , inactive_date_start
                  , inactive_date_end
                  , acq_api_audit_report_pkg.get_trans_count_post_inactive 
                                ( i_terminal_id => terminal_id
                                , i_start_date  => inactive_date_end + 1
                                , i_end_date    => nvl( lead (inactive_date_start) over( partition by terminal_id order by terminal_id, inactive_date_start )
                                                      , l_date_end 
                                                      ) -0.00001 
                                ) as trans_count
             from 
                  ( select
                           terminal_id
                         , terminal_number
                         , decode ( nvl(prev_oper_date, oper_date), oper_date, 0, oper_date-(prev_oper_date+1) ) 
                                              as inactive_days  
                         , oper_date - 1      as inactive_date_end
                         , prev_oper_date + 1 as inactive_date_start 
                    from 
                         ( select 
                                  pa.terminal_id
                                , trunc(o.oper_date) as oper_date
                                , trunc( nvl( lag(o.oper_date) over (partition by pa.terminal_id order by pa.terminal_id, o.oper_date)
                                            , acq_api_audit_report_pkg.get_prev_oper_date 
                                                                 ( i_terminal_id => pa.terminal_id
                                                                 , i_oper_date   => o.oper_date ) 
                                            )
                                       )             as prev_oper_date 
                                , t.terminal_number
                           from
                                opr_operation   o
                              , opr_participant pa
                              , acq_terminal    t    
                              , acq_merchant    m  
                           where 
                                o.oper_date between l_date_start and l_date_end 
                            and pa.oper_id = o.id
                            and pa.participant_type = 'PRTYACQ'     
                            and t.id = pa.terminal_id
                            and m.id = pa.merchant_id 
                            and m.contract_id in
                                         ( select acnt.contract_id
                                             from acc_macros      a_m
                                                , acc_entry       a_e
                                                , acc_account     acnt
                                            where a_m.object_id   = o.id
                                              and a_m.entity_type = 'ENTTOPER'
                                              and a_e.macros_id   = a_m.id
                                              and acnt.id         = a_e.account_id
                                         ) 
                         )       
                  )  
             where 
                  inactive_days >= v_3months_days
             order by 
                  terminal_number
                , inactive_date_start
           );

    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table"
                       , xmlagg(
                            xmlelement("record"
                                 , xmlelement( "terminal_number"     , null )
                                 , xmlelement( "inactive_date_start" , null )
                                 , xmlelement( "inactive_date_end"   , null )
                                 , xmlelement( "trans_count"         , null )
                            )
                         )
               )
        into l_detail from dual ;
    end if;

    select xmlelement ( "report"
             , l_header
             , l_detail
           )
    into l_result from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'acq_api_audit_report_pkg.get_term_active_after_inactive - ok' );

exception when others then
    trc_log_pkg.debug ( i_text => sqlerrm );
    raise ;
end;

procedure percent_of_below_floor_limit(
    o_xml          out clob
  , i_lang          in com_api_type_pkg.t_dict_value
  , i_inst_id       in com_api_type_pkg.t_inst_id       default null
  , i_date_start    in date                             default null
  , i_date_end      in date                             default null
  , i_threshold     in com_api_type_pkg.t_short_id      default 1
) is
    l_date_start       date;
    l_date_end         date;
    l_lang             com_api_type_pkg.t_dict_value;
    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;
begin

    trc_log_pkg.debug(
        i_text => 'acq_api_audit_report_pkg.percentage_of_below_floor_limit - start. i_inst_id [' || i_inst_id
               || '], i_date_start [' || com_api_type_pkg.convert_to_char(i_date_start)
               || '], i_date_end [' || com_api_type_pkg.convert_to_char(i_date_end)
               || '], i_threshold ['|| i_threshold
               || ']'
    );

    l_date_start := trunc(nvl(i_date_start, com_api_sttl_day_pkg.get_sysdate));
    l_date_end := nvl(trunc(i_date_end), l_date_start) + 1 - com_api_const_pkg.ONE_SECOND;
    l_lang := nvl(i_lang, get_user_lang);

    -- header
    select
        xmlelement("header",
            xmlelement("p_date_start", to_char(l_date_start, 'dd.mm.yyyy'))
          , xmlelement("p_date_end", to_char(l_date_end, 'dd.mm.yyyy'))
          , xmlelement("p_inst_id", nvl(i_inst_id, 0))
          , xmlelement("p_threshold", nvl(i_threshold, 0))
        )
      into l_header
      from dual;
      
    -- detail
    select xmlelement("table",
               xmlagg(
                   xmlelement("record"
                     , xmlelement("inst_id", inst_id)
                     , xmlelement("merchant_id", merchant_id)
                     , xmlelement("terminal_number", terminal_number)
                     , xmlelement("oper_date", oper_date)
                     , xmlelement("quantity", quantity)
                     , xmlelement("avg_daily", avg_daily)
                     , xmlelement("count_below_limit_trans", count_trans)
                     , xmlelement("percentage", trunc(count_trans / avg_daily, 2))
                   )
                   order by terminal_number
                       , oper_date
               )
           )
      into l_detail
      from (
            select distinct p.inst_id 
                 , p.merchant_id
                 , o.terminal_number
                 , to_char(o.oper_date, 'dd.mm.yyyy') oper_date
                 , count(1) over (partition by p.merchant_id, trunc(o.oper_date)) quantity
                 , count(1) over (partition by p.merchant_id, trunc(o.oper_date))
                     / count(distinct o.terminal_number) over (partition by p.merchant_id, trunc(o.oper_date)) avg_daily
                 , sum(nvl2(a.id, 0, 1)) over (partition by p.merchant_id, o.terminal_number, trunc(o.oper_date)) count_trans
              from opr_operation    o
                 , opr_participant  p
                 , aut_auth         a
             where o.id between com_api_id_pkg.get_from_id(l_date_start) and com_api_id_pkg.get_till_id(l_date_end)
               and trunc(o.oper_date) between l_date_start and l_date_end
               and o.id = p.oper_id
               and (i_inst_id is null or p.inst_id = i_inst_id)
               and p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
               and o.sttl_type in (opr_api_const_pkg.SETTLEMENT_USONUS, opr_api_const_pkg.SETTLEMENT_THEMONUS)
               and o.id = a.id(+)
           )
     where (count_trans / avg_daily) - 1 > i_threshold / 100;

    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table",
                   xmlagg(
                       xmlelement("record"
                         , xmlelement("inst_id", ' ')
                         , xmlelement("merchant_id", null)
                         , xmlelement("terminal_number", null)
                         , xmlelement("oper_date", null)
                         , xmlelement("quantity", null)
                         , xmlelement("avg_daily", null)
                         , xmlelement("count_below_limit_trans", null)
                         , xmlelement("percentage", null)
                       )
                   )
               )
          into l_detail
          from dual;
    end if;

    select xmlelement("report"
             , l_header
             , l_detail
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(i_text => 'acq_api_audit_report_pkg.percentage_of_below_floor_limit - ok');

exception
    when others then
        trc_log_pkg.debug(
            i_text  => 'acq_api_audit_report_pkg.percentage_of_below_floor_limit l_date_start [' || com_api_type_pkg.convert_to_char(l_date_start)
                    || '], l_date_end [' || com_api_type_pkg.convert_to_char(l_date_end)
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
end;

end acq_api_audit_report_pkg;
/