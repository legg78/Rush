create or replace package body acq_api_report_pkg is
/*********************************************************
 *  Acquiring reports API <br />
 *  Created by Nasybullina (nasybullina@bpcbt.com) at 25.04.2013 <br />
 *  Last changed by $Author: truschelev $ <br />
 *  $LastChangedDate:: 2015-08-21 09:46:00 +0400#$ <br />
 *  Revision: $LastChangedRevision: 25841 $ <br />
 *  Module: acq_api_report_pkg <br />
 *  @headcom
 **********************************************************/

type t_merch_data_tab is table of varchar2(2000) index by binary_integer;
g_merch_tab t_merch_data_tab;

procedure list_of_cash_sale (
        o_xml             out clob
        , i_lang           in com_api_type_pkg.t_dict_value
        , i_date_start     in date
        , i_date_end       in date
        , i_inst_id        in com_api_type_pkg.t_inst_id  default null
        , i_merchant_id    in com_api_type_pkg.t_short_id default null
        , i_terminal_id    in com_api_type_pkg.t_short_id default null
        , i_mode           in com_api_type_pkg.t_sign
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
              i_text        => 'acq_api_report_pkg.list_of_cash_sale [#1][#2][#3][#4][#5][#6]'
            , i_env_param1  => i_lang
            , i_env_param2  => com_api_type_pkg.convert_to_char(trunc(nvl(i_date_start, com_api_sttl_day_pkg.get_sysdate)))
            , i_env_param3  => com_api_type_pkg.convert_to_char(nvl(trunc(i_date_end), l_date_start) + 1 - (1/86400))
            , i_env_param4  => i_inst_id
            , i_env_param5  => i_merchant_id
            , i_env_param6  => i_terminal_id
    );

    l_date_start := trunc( nvl(i_date_start, com_api_sttl_day_pkg.get_sysdate) );
    l_date_end   := nvl( trunc(i_date_end), l_date_start ) + 1 - (1/86400);
    l_lang       := nvl( i_lang, get_user_lang );

    -- header
    select xmlelement ( "header",
                 xmlelement( "p_date_start" , to_char(l_date_start, 'dd.mm.yyyy') )
               , xmlelement( "p_date_end"   , to_char(l_date_end, 'dd.mm.yyyy'  ) )
               , xmlelement( "p_inst_id"    , decode (i_inst_id, null, '0'
                                                     ,i_inst_id||' - '||get_text('OST_INSTITUTION','NAME', i_inst_id, l_lang) )
                           )
               , xmlelement( "p_merchant_id", decode(i_merchant_id, null, '0', i_merchant_id) )
               , xmlelement( "p_terminal_id", decode(i_terminal_id, null, '0', i_terminal_id) )
           )
    into l_header from dual ;

    -- details
    select
           xmlelement("table"
                       , xmlagg(
                            xmlelement( "record"
                                 , xmlelement( "row_type"               , row_type            )
                                 , xmlelement( "inst_id"                , inst_id             )
                                 , xmlelement( "inst_name"              , nvl( get_text ('OST_INSTITUTION', 'NAME', inst_id, l_lang), ' ' ) )
                                 , xmlelement( "currency"               , currency            )
                                 , xmlelement( "agent_id"               , agent_id            )
                                 , xmlelement( "agent_name"             , nvl( get_text ('OST_AGENT', 'NAME', agent_id, l_lang), ' ' ) )
                                 , xmlelement( "agent_address"          , nvl( agent_address, ' ' ) )
                                 , xmlelement( "phone"                  , nvl( agent_phone, ' ' ) )
                                 , xmlelement( "merchant_id"            , merchant_id         )
                                 , xmlelement( "merchant_name"          , nvl(merchant_name,' ') )
                                 , xmlelement( "terminal_number"        , terminal_number     )
                                 , xmlelement( "terminal_type"          , terminal_type       )
                                 , xmlelement( "oper_date"              , to_char(oper_date, 'dd.mm.yy') )
                                 , xmlelement( "oper_time"              , to_char(oper_date, 'hh24:mi') )
                                 , xmlelement( "auth_code"              , auth_code           )
                                 , xmlelement( "oper_id"                , oper_id             )
                                 , xmlelement( "card_number"            , card_number         )
                                 , xmlelement( "oper_amount"            , oper_amount         )
                                 , xmlelement( "req_amount"             , req_amount          )
                                 , xmlelement( "fee_amount"             , fee_amount          )
                                 , xmlelement( "oper_type"              , oper_type           )
                                 , xmlelement( "network_name"           , decode ( network_id, null, 'all'
                                                                                 , get_text ('NET_NETWORK', 'NAME', network_id, l_lang)
                                                                                 )
                                             )
                                 , xmlelement( "oper_amt_term_oper_type", oper_amt_term_oper_type )
                                 , xmlelement( "req_amt_term_oper_type" , req_amt_term_oper_type  )
                                 , xmlelement( "fee_amt_term_oper_type" , fee_amt_term_oper_type  )
                            )
                         )
             )
    into
           l_detail
    from (
           select
                  row_type
                , inst_id
                , currency
                , agent_id
                , agent_address, agent_phone
                , merchant_id, merchant_name
                , terminal_number, terminal_type
                , oper_date
                , oper_id
                , card_number
                , to_char( oper_amount/ power(10, exponent), format ) as oper_amount
                , to_char( req_amount / power(10, exponent), format ) as req_amount
                , to_char( fee_amount / power(10, exponent), format ) as fee_amount
                , oper_type
                , network_id
                , auth_code
                , to_char( oper_amt_term_oper_type/ power(10, exponent), format ) as oper_amt_term_oper_type
                , to_char( req_amt_term_oper_type / power(10, exponent), format ) as req_amt_term_oper_type
                , to_char( fee_amt_term_oper_type / power(10, exponent), format ) as fee_amt_term_oper_type
           from
              ( select oper.*
                     , cr.name as currency, cr.exponent
                     , 'FM999999999999999990' || decode ( nvl(cr.exponent,0), 0, null, '.' || lpad('0',cr.exponent,'0') ) as format
                     , m.merchant_name
                     , a.agent_address
                     , p.agent_phone
                from
                  ( with OPR as (
                                  select o.oper_currency
                                       , t.inst_id
                                       , contr.agent_id
                                       , pa.merchant_id
                                       , t.terminal_number
                                       , get_article_text(t.terminal_type, l_lang) as terminal_type
                                       , o.oper_type
                                       , o.oper_date
                                       , o.id               as oper_id
                                       , card.card_number
                                       , pi.card_network_id as network_id
                                       , pi.auth_code
                                       , o.oper_amount * decode(o.is_reversal,1,-1,1)           as oper_amount
                                       , o.oper_request_amount * decode(o.is_reversal,1,-1,1)   as req_amount
                                       , o.oper_surcharge_amount * decode(o.is_reversal,1,-1,1) as fee_amount
                                    from opr_operation   o
                                       , opr_participant pa
                                       , opr_participant pi
                                       , opr_card        card
                                       , acq_terminal    t
                                       , prd_contract    contr
                                   where o.oper_date between l_date_start and l_date_end
                                     and (  ( i_mode = 1 and o.oper_type in ('OPTP0001','OPTP0012') ) --  cash out
                                          or( i_mode = 2 and o.oper_type in ('OPTP0000','OPTP0009','OPTP0020','OPTP0028','OPTP0060') )  -- sale
                                         )
                                     and o.id                  = pa.oper_id
                                     and pa.participant_type   = 'PRTYACQ'
                                     and o.id                  = pi.oper_id
                                     and pi.participant_type   = 'PRTYISS'
                                     and o.id                  = card.oper_id
                                     and card.participant_type = 'PRTYISS'
                                     and t.id                  = pa.terminal_id
                                     and contr.id              = t.contract_id
                                     --and o.status in('OPST0100', 'OPST0400', 'OPST0403')
                                     and o.status in (select element_value
                                                        from com_array_element e
                                                       where e.array_id = opr_api_const_pkg.OPER_STATUS_ARRAY_ID)
                                     and o.sttl_type in ('STTT0200', 'STTT0010', 'STTT5001')    --?
                                     and ( i_inst_id     is null or t.inst_id = i_inst_id )
                                     and ( i_terminal_id is null or pa.terminal_id = i_terminal_id )
                                     and ( i_merchant_id is null or pa.merchant_id = i_merchant_id )
                                     and card.card_number   is not null
                                     and pa.terminal_id     is not null
                                     and pa.merchant_id     is not null
                                     and pi.card_network_id is not null
                                ) -- with OPR end
                    select 0 as sort_number
                         , 'record' as row_type
                         , inst_id
                         , oper_currency, agent_id, merchant_id, terminal_number, terminal_type
                         , oper_date, oper_id
                         , iss_api_token_pkg.decode_card_number(i_card_number => card_number) as card_number
                         , oper_amount
                         , req_amount
                         , fee_amount
                         , oper_type
                         , network_id
                         , auth_code
                         , sum(oper_amount) over(partition by agent_id, merchant_id, oper_currency, terminal_number, terminal_type, network_id, oper_type) as oper_amt_term_oper_type
                         , sum(req_amount) over (partition by agent_id, merchant_id, oper_currency, terminal_number, terminal_type, network_id, oper_type) as req_amt_term_oper_type
                         , sum(fee_amount) over (partition by agent_id, merchant_id, oper_currency, terminal_number, terminal_type, network_id, oper_type) as fee_amt_term_oper_type
                      from OPR
                  union
                    select case when merchant_id is not null and terminal_number is not null then 1
                                when merchant_id is not null and terminal_number is null     then 2
                                when merchant_id is null     and terminal_number is null     then
                                     decode (terminal_type, null, 4, 3)
                           end  as sort_number
                         , case when merchant_id is not null and terminal_number is not null then 'terminal'
                                when merchant_id is not null and terminal_number is null     then 'merchant'
                                when merchant_id is null     and terminal_number is null     then
                                     decode (terminal_type, null, 'agent', 'term_type')
                           end  as row_type
                         , inst_id
                         , oper_currency, agent_id, merchant_id, terminal_number, terminal_type
                         , null, null, null   -- oper_date,oper_id,card_number
                         , sum(oper_amount)
                         , sum(req_amount)
                         , sum(fee_amount)
                         , null               -- oper_type
                         , network_id
                         , null               -- auth_code
                         , null               -- oper_amt_term_oper_type
                         , null               -- req_amt_term_oper_type
                         , null               -- fee_amt_term_oper_type
                      from OPR
                     group by grouping sets
                         ( (inst_id, oper_currency, agent_id, merchant_id, terminal_number, terminal_type, network_id)
                          ,(inst_id, oper_currency, agent_id, merchant_id, terminal_number, terminal_type)
                          ,(inst_id, oper_currency, agent_id, merchant_id, network_id)
                          ,(inst_id, oper_currency, agent_id, merchant_id)
                          ,(inst_id, oper_currency, agent_id, terminal_type, network_id)
                          ,(inst_id, oper_currency, agent_id, network_id)
                          ,(inst_id, oper_currency, agent_id)
                         )
                  ) OPER
                , com_currency CR
                , acq_merchant M
                , (select com_api_address_pkg.get_address_string (o.address_id, l_lang) as agent_address
                        , o.object_id as agent_id
                     from com_address_object o
                        , com_address a
                    where o.entity_type = ost_api_const_pkg.ENTITY_TYPE_AGENT
                      and o.address_type = 'ADTPBSNA'
                      and a.id = o.address_id) a
                , (select d.commun_address as agent_phone
                        , o.object_id as agent_id
                     from com_contact_object o
                        , com_contact_data d
                    where o.entity_type = ost_api_const_pkg.ENTITY_TYPE_AGENT
                      and o.contact_type = com_api_const_pkg.CONTACT_TYPE_PRIMARY
                      and d.contact_id = o.contact_id
                      and d.commun_method = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE) p
             where
                  oper.oper_currency = cr.code
              and oper.merchant_id = m.id(+)
              and oper.agent_id = a.agent_id(+)
              and oper.agent_id = p.agent_id(+)
              )
             order by
                  inst_id
                , oper_currency
                , agent_id
                , merchant_id      nulls last
                , terminal_number  nulls last
                , sort_number
                , oper_type
                , terminal_type
                , network_id       nulls last
                , oper_date
           );

    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table"
                       , xmlagg(
                            xmlelement("record"
                                 , xmlelement( "row_type"        , null )
                                 , xmlelement( "inst_id"         , null )
                                 , xmlelement( "inst_name"       , null )
                                 , xmlelement( "currency"        , null )
                                 , xmlelement( "agent_id"        , null )
                                 , xmlelement( "agent_name"      , null )
                                 , xmlelement( "agent_address"   , null )
                                 , xmlelement( "phone"           , null )
                                 , xmlelement( "merchant_id"     , null )
                                 , xmlelement( "merchant_name"   , null )
                                 , xmlelement( "terminal_number" , null )
                                 , xmlelement( "terminal_type"   , null )
                                 , xmlelement( "oper_date"       , null )
                                 , xmlelement( "auth_code"       , null )
                                 , xmlelement( "oper_id"         , null )
                                 , xmlelement( "card_number"     , null )
                                 , xmlelement( "oper_amount"     , null )
                                 , xmlelement( "req_amount"      , null )
                                 , xmlelement( "fee_amount"      , null )
                                 , xmlelement( "oper_type"       , null )
                                 , xmlelement( "network_name"    , null )
                                 , xmlelement( "oper_amt_term_oper_type" , null )
                                 , xmlelement( "req_amt_term_oper_type"  , null )
                                 , xmlelement( "fee_amt_term_oper_type"  , null )
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

    trc_log_pkg.debug ( i_text => 'acq_api_report_pkg.list_of_cash_sale - ok' );

exception when others then
    trc_log_pkg.debug ( i_text => sqlerrm );
    raise ;
end;


procedure list_of_terminal
        ( o_xml          out clob
        , i_lang         in com_api_type_pkg.t_dict_value
        , i_inst_id      in com_api_type_pkg.t_tiny_id default null
        )
is
    l_lang             com_api_type_pkg.t_dict_value;

    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;
    l_logo_path        xmltype;
begin

   trc_log_pkg.debug
        ( i_text       => 'acq_api_report_pkg.list_of_terminal [#1][#2]]'
        , i_env_param1 => i_lang
        , i_env_param2 => i_inst_id
        );

    -- header
    l_logo_path := rpt_api_template_pkg.logo_path_xml;
    select xmlelement ( "header",
                 l_logo_path
               , xmlelement( "p_date"      , to_char(rep_date, 'dd.mm.yyyy')        )
               , xmlelement( "p_inst_id"   , decode (i_inst_id, null, 0, i_inst_id) )
               , xmlelement( "p_inst_name" , decode (i_inst_id, null, '0', nvl( get_text('OST_INSTITUTION','NAME', i_inst_id, l_lang), ' ' ) ) )
           )
    into l_header
    from ( select get_sysdate() rep_date from dual );

    -- details
   select xmlelement ( "table", xmlagg (xml) )
   into l_detail
   from (
          select xmlagg( xmlelement
                         ("record"
                         , xmlelement( "agent_id"        , agent_id        )
                         , xmlelement( "merchant_number" , merchant_number )
                         , xmlelement( "merchant_name"   , merchant_name   )
                         , xmlelement( "terminal_number" , terminal_number )
                         , xmlelement( "terminal_type"   , terminal_type   )
                         , xmlelement( "mcc"             , mcc             )
                         , xmlelement( "terminal_status" , terminal_status )
                         , xmlelement( "agent_name"      , agent_name      )
                         )
                 ) xml
          from (
                 select
                        c.agent_id
                      , m.merchant_number
                      , m.merchant_name
                      , a.terminal_number
                      , nvl(a.mcc, m.mcc)                          as mcc
                      , get_article_text(a.terminal_type, i_lang)  as terminal_type
                      , get_article_text(a.status, i_lang)         as terminal_status
                      , get_text ('OST_AGENT', 'NAME', c.agent_id, i_lang) as agent_name
                   from
                        acq_terminal    a
                      , acq_merchant    m
                      , prd_contract    c
                  where
                        ( i_inst_id is null or a.inst_id = i_inst_id )
                    and a.merchant_id = m.id
                    and a.contract_id = c.id
                    and a.is_template <> 1
                  order by
                        agent_id
                      , decode ( nvl(a.mcc, m.mcc), '6010', 2, '6011', 2, 1 )
                      , mcc
               )
        ) ;

    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table", xmlagg(
                            xmlelement("record"
                            , xmlelement( "agent_id"        , ' ' )
                            , xmlelement( "merchant_number" , null )
                            , xmlelement( "merchant_name"   , null )
                            , xmlelement( "terminal_number" , null )
                            , xmlelement( "terminal_type"   , null )
                            , xmlelement( "mcc"             , null )
                            , xmlelement( "terminal_status" , null )
                            , xmlelement( "agent_name"      , ' ' )
                            )
                         )
              )
        into l_detail from dual ;
    end if;

    select xmlelement ( "report"
             , l_header
             , l_detail
           )
    into l_result
    from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'acq_api_report_pkg.list_of_terminal - ok' );

exception
    when others then
        trc_log_pkg.debug (
            i_text   => sqlerrm
        );
        raise;
end;


procedure list_of_unconfirmed_auth (
    o_xml                   out clob
  , i_date_start             in date                           default null
  , i_date_end               in date                           default null
  , i_inst_id                in com_api_type_pkg.t_tiny_id     default null
  , i_agent_id               in com_api_type_pkg.t_short_id    default null
  , i_imprn                  in com_api_type_pkg.t_boolean     default 1
  , i_pos                    in com_api_type_pkg.t_boolean     default 1
  , i_atm                    in com_api_type_pkg.t_boolean     default 1
  , i_epos                   in com_api_type_pkg.t_boolean     default 1
  , i_lang                   in com_api_type_pkg.t_dict_value  default null
) is
    l_start_date               date;
    l_end_date                 date;
    l_start_id                 com_api_type_pkg.t_long_id;
    l_end_id                   com_api_type_pkg.t_long_id;
    l_lang                     com_api_type_pkg.t_dict_value;
    l_header                   xmltype;
    l_detail                   xmltype;
    l_result                   xmltype;
    l_logo_path                xmltype;
begin
    l_start_date := trunc(nvl(i_date_start, com_api_sttl_day_pkg.get_sysdate));
    l_end_date   := nvl(trunc(i_date_end), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
    l_lang       := nvl(i_lang, get_user_lang);

    l_start_id   := com_api_id_pkg.get_from_id(l_start_date);
    l_end_id     := com_api_id_pkg.get_till_id(l_end_date);

    trc_log_pkg.debug(
        i_text       => 'acq_api_report_pkg.list_of_unconfirmed_auth: start_date [#1] end_date [#2] start_id [#3] end_id [#4] lang [#5]'
      , i_env_param1 => to_char(l_start_date, com_api_const_pkg.LOG_DATE_FORMAT)
      , i_env_param2 => to_char(l_end_date,   com_api_const_pkg.LOG_DATE_FORMAT)
      , i_env_param3 => l_start_id
      , i_env_param4 => l_end_id
      , i_env_param5 => l_lang
    );

    -- header
  l_logo_path := rpt_api_template_pkg.logo_path_xml;
    select
        xmlelement("header"
        , l_logo_path
            , xmlelement("p_date_start", to_char(l_start_date, 'dd.mm.yyyy'))
            , xmlelement("p_date_end",   to_char(l_end_date,   'dd.mm.yyyy'))
            , xmlelement("p_inst_id",    case when i_inst_id is not null then i_inst_id || ' ' || get_text('ost_institution', 'name', i_inst_id, l_lang) else '0' end)
            , xmlelement("p_agent_id",   nvl(i_agent_id, '0'))
            , xmlelement("p_imprn",      nvl(i_imprn, 0))
            , xmlelement("p_pos",        nvl(i_pos,   0))
            , xmlelement("p_atm",        nvl(i_atm,   0))
            , xmlelement("p_epos",       nvl(i_epos,  0))
        )
      into l_header
      from dual;

    -- details
    begin
        select
            xmlagg(
                xmlelement("record"
                    , xmlelement("inst_id",         inst_id )
                    , xmlelement("inst_name",       get_text('ost_institution', 'name', inst_id, l_lang))
                    --, xmlelement("agent_id", agent_id)
                    , xmlelement("oper_status",     status || ' ' || get_article_text(status, l_lang))
                    , xmlelement("terminal_number", terminal_number)
                    , xmlelement("terminal_type",   get_article_text(terminal_type, l_lang))
                    , xmlelement("oper_type",       get_article_text(oper_type, l_lang))
                    , xmlelement("oper_date",       to_char(oper_date, 'dd.mm.yyyy hh24:mi:ss'))
                    , xmlelement("card_number",     iss_api_card_pkg.get_card_mask(iss_api_token_pkg.decode_card_number(card_number)))
                    , xmlelement("oper_amount",     oper_amount)
                    , xmlelement("oper_currency",   oper_currency)
                    , xmlelement("auth_code",       auth_code)
                    , xmlelement("oper_place",      oper_place)
                )
                order by inst_id
                       , status
                       , id
            )
          into l_detail
          from (
              select o.id
                   , acq.inst_id
                   --, to_number(null) agent_id
                   , o.oper_type
                   , o.oper_date
                   , com_api_currency_pkg.get_amount_str(i_amount => o.oper_amount, i_curr_code => o.oper_currency, i_mask_curr_code => get_true, i_format_mask => null, i_mask_error => get_true) oper_amount
                   , cur.name oper_currency
                   , o.status
                   , c.card_number
                   , o.terminal_number
                   , o.terminal_type
                   , o.merchant_name
                     ||'\'||o.merchant_postcode
                     ||'\'||o.merchant_street
                     ||'\'||o.merchant_city
                     ||'\'||o.merchant_region
                     ||'\'||o.merchant_country oper_place
                   , iss.auth_code  
              from opr_operation o
                 , opr_participant acq
                 , opr_participant iss
                 , opr_card c
                 , com_currency cur
              where o.id        between l_start_id   and l_end_id
                and o.oper_date between l_start_date and l_end_date
                and o.sttl_type in (select element_value from com_array_element where array_id = 10000013)
                and o.oper_type in (select element_value from com_array_element where array_id = 10000014)
                and o.msg_type  in (opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
                                  , opr_api_const_pkg.MESSAGE_TYPE_COMPLETION)
                and acq.oper_id             = o.id 
                and acq.participant_type    = com_api_const_pkg.PARTICIPANT_ACQUIRER 
                and iss.oper_id(+)          = o.id
                and iss.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER
                and c.oper_id(+)            = o.id
                and c.participant_type(+)   = com_api_const_pkg.PARTICIPANT_ISSUER
                and cur.code(+)             = o.oper_currency
                and (i_inst_id is null or acq.inst_id = i_inst_id)
                --and (i_agent_id is null or cont.agent_id = i_agent_id)
                and o.status in (opr_api_const_pkg.OPERATION_STATUS_MANUAL      -- Frozen for manual processing
                               , opr_api_const_pkg.OPERATION_STATUS_EXCEPTION)  -- Processing error
                and (
                        (nvl(i_atm, 0)  = 1 and o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM)
                        or
                        (nvl(i_pos, 0)  = 1 and o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS)
                        or
                        (nvl(i_epos, 0) = 1 and o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_EPOS)
                        or
                        (nvl(i_imprn, 0)= 1 and o.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER)
                )
          );

    exception
        when no_data_found then
            null;
    end;
     
    select
        xmlelement (
            "report"
            , l_header
            , xmlelement("table", nvl(l_detail, xmlelement("record", '')))
        ) r
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(
        i_text  => 'acq_api_report_pkg.list_of_unconfirmed_auth - ok'
    );
exception
    when others then
        trc_log_pkg.debug (
            i_text   => sqlerrm
        );
        raise;
end;

procedure list_of_chargeback   --report is not maded
        ( o_xml          out clob
        , i_lang         in com_api_type_pkg.t_dict_value
        , i_date_start   in date   default trunc(com_api_sttl_day_pkg.get_sysdate)
        , i_date_end     in date   default trunc(com_api_sttl_day_pkg.get_sysdate)
        , i_network_id   in com_api_type_pkg.t_network_id
        , i_inst_id      in com_api_type_pkg.t_tiny_id
        )
is
    l_date_start       date;
    l_date_end         date;
    l_lang             com_api_type_pkg.t_dict_value;

    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;
begin

   trc_log_pkg.debug
        ( i_text       => 'acq_api_report_pkg.list_of_chargeback [#1][#2][#3][#4]'
        , i_env_param1 => com_api_type_pkg.convert_to_char(trunc(nvl(i_date_start, com_api_sttl_day_pkg.get_sysdate)))
        , i_env_param2 => com_api_type_pkg.convert_to_char(nvl(trunc(i_date_end), l_date_start) + 1 - (1/86400))
        , i_env_param3 => i_network_id
        , i_env_param4 => i_inst_id
        );

    l_date_start := trunc( nvl(i_date_start, com_api_sttl_day_pkg.get_sysdate) );
    l_date_end   := nvl( trunc(i_date_end), l_date_start ) + 1 - (1/86400);
    l_lang       := nvl( i_lang, get_user_lang );

    -- header
    select xmlelement ( "header",
                 xmlelement( "p_date_start"    , to_char(l_date_start, 'dd.mm.yyyy') )
               , xmlelement( "p_date_end"      , to_char(l_date_end, 'dd.mm.yyyy'  ) )
               , xmlelement( "p_network_id"    , nvl(i_network_id,'0')               )
               , xmlelement( "p_network_name"  , get_text('NET_NETWORK','NAME', i_network_id, l_lang) )
               , xmlelement( "p_inst_id"       , nvl(i_inst_id,'0' )                 )
           )
    into l_header from dual ;

    -- details
   select xmlelement ( "table", xmlagg (xml) )
   into l_detail
   from (
          select xmlagg( xmlelement
                         ("record"
                         , xmlelement( "oper_id"         , oper_id           )
                         , xmlelement( "dispute_id"      , dispute_id        )
                         , xmlelement( "present_number"  , present_number    )
                         , xmlelement( "oper_type"       , oper_type         )
                         , xmlelement( "terminal_number" , terminal_number   )
                         , xmlelement( "terminal_type"   , terminal_type     )
                         , xmlelement( "auth_code"       , auth_code         )
                         , xmlelement( "card_number"     , card_number       )
                         , xmlelement( "amount_clir"     , amount_clir       )
                         , xmlelement( "currency_clir"   , currency_clir     )
                         , xmlelement( "date_clir"       , date_clir         )
                         , xmlelement( "amount_orig"     , amount_orig       )
                         , xmlelement( "currency_orig"   , currency_orig     )
                         , xmlelement( "date_orig"       , date_orig         )
                         , xmlelement( "branch_name"     , branch_name       )
                         , xmlelement( "arn"             , arn               )
                         )
                 ) xml
          from (
                 select o.id                                      as oper_id
                      , o.dispute_id
                      , null                                      as present_number
                      , o.oper_type
                      , t.terminal_number
                      , get_article_text(t.terminal_type, l_lang) as terminal_type
                      , opi.auth_code
                      , iss_api_token_pkg.decode_card_number(i_card_number => card.card_number) as card_number
                      , to_char( o.oper_amount / power(10, curr.exponent)
                               , 'FM999999999990' || decode ( nvl(curr.exponent,0), 0, null, '.' || lpad('0',curr.exponent,'0') )
                               )
                                                                  as amount_clir    --?
                      --, o.oper_currency                           as currency_clir
                      , curr.name                                 as currency_clir
                      , to_char(o.oper_date,'dd.mm.yyyy')         as date_clir
                      --  original transaction:
                      , null                                      as amount_orig
                      , to_char(null,'dd.mm.yyyy hh24:mi')        as currency_orig
                      , null                                      as date_orig
                      --
                      , o.merchant_name                           as branch_name
                      , null                                      as arn
                      , opa.inst_id
                 from
                      opr_operation         o
                    , opr_participant       opa
                    , opr_participant       opi
                    , opr_card              card
                    , acq_terminal          t
                    , com_currency          curr
                    , acq_merchant          m
                 where
                      o.oper_date between l_date_start and l_date_end
                  and opa.oper_id           = o.id
                  and opa.participant_type  = 'PRTYACQ'
                  and opi.oper_id           = o.id
                  and opi.participant_type  = 'PRTYISS'
                  and card.oper_id          = o.id
                  and card.participant_type = 'PRTYISS'
                  and t.id                  = opa.terminal_id
                  and curr.code             = o.oper_currency
                  and opi.card_network_id   = i_network_id
                  and opa.inst_id           = i_inst_id
                  and o.oper_type           in ('OPTP0001','OPTP0012'                                   --cash
                                               ,'OPTP0000','OPTP0009','OPTP0020','OPTP0028','OPTP0060') --sale
                  and o.msg_type            in ('MSGTCHBK')
                  and o.sttl_type           in ('STTT0200', 'STTT0010')  --?
                  --and o.status              in ('OPST0400')              --?
                  and o.status in (select element_value
                                     from com_array_element e
                                    where e.array_id = opr_api_const_pkg.OPER_STATUS_ARRAY_ID)
                  and m.id                  = opa.merchant_id
                  and m.contract_id in                                   --?
                          ( select acnt.contract_id
                              from acc_macros a_m, acc_entry a_e, acc_account acnt
                             where a_m.object_id = o.id
                               and a_m.entity_type = 'ENTTOPER'
                               and a_e.macros_id = a_m.id
                               and acnt.id = a_e.account_id
                          )
               )
          order by
                inst_id
              , case when oper_type in ('OPTP0001','OPTP0012') then 2 else 1 end --first sale, then cash
              , case when currency_orig = '840' then 1       --? currency_
                     when currency_orig = '643' then 2 else 3
                end
              , date_clir  -- date_orig
        ) ;

    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table", xmlagg(
                            xmlelement("record"
                            , xmlelement( "oper_id"         , null )
                            , xmlelement( "dispute_id"      , null )
                            , xmlelement( "present_number"  , null )
                            , xmlelement( "oper_type"       , null )
                            , xmlelement( "terminal_number" , null )
                            , xmlelement( "terminal_type"   , null )
                            , xmlelement( "auth_code"       , null )
                            , xmlelement( "card_number"     , null )
                            , xmlelement( "amount_clir"     , null )
                            , xmlelement( "currency_clir"   , null )
                            , xmlelement( "date_clir"       , null )
                            , xmlelement( "amount_orig"     , null )
                            , xmlelement( "currency_orig"   , null )
                            , xmlelement( "date_orig"       , null )
                            , xmlelement( "branch_name"     , null )
                            , xmlelement( "arn"             , null )
                            )
                         )
               )
        into l_detail from dual ;
    end if;

    select xmlelement ( "report"
             , l_header
             , l_detail
           )
    into l_result
    from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'acq_api_report_pkg.list_of_chargeback - ok' );

exception
  --when no_data_found then trc_log_pkg.debug ( i_text => sqlerrm );
  when others then trc_log_pkg.debug ( i_text => sqlerrm );
                   raise_application_error (-20001,sqlerrm);

end;

procedure cash_payment_sum
        ( o_xml          out clob
        , i_lang         in com_api_type_pkg.t_dict_value
        , i_date_start   in date   default trunc(com_api_sttl_day_pkg.get_sysdate)
        , i_date_end     in date   default trunc(com_api_sttl_day_pkg.get_sysdate)
        , i_network_id   in com_api_type_pkg.t_network_id
        , i_inst_id      in com_api_type_pkg.t_tiny_id
        )
is
    l_date_start       date;
    l_date_end         date;
    l_lang             com_api_type_pkg.t_dict_value;

    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;
    l_logo_path        xmltype;
begin

   trc_log_pkg.debug
        ( i_text       => 'acq_api_report_pkg.cash_payment_sum [#1][#2][#3][#4]'
        , i_env_param1 => com_api_type_pkg.convert_to_char(trunc(nvl(i_date_start, com_api_sttl_day_pkg.get_sysdate)))
        , i_env_param2 => com_api_type_pkg.convert_to_char(nvl(trunc(i_date_end), l_date_start) + 1 - (1/86400))
        , i_env_param3 => i_network_id
        , i_env_param4 => i_inst_id
        );

    l_date_start := trunc( nvl(i_date_start, com_api_sttl_day_pkg.get_sysdate) );
    l_date_end   := nvl( trunc(i_date_end), l_date_start ) + 1 - (1/86400);
    l_lang       := nvl( i_lang, get_user_lang );
    l_logo_path  := rpt_api_template_pkg.logo_path_xml;

    -- header
    select xmlelement ( "header",
               l_logo_path
               , xmlelement( "p_date_start"    , to_char(l_date_start, 'dd.mm.yyyy') )
               , xmlelement( "p_date_end"      , to_char(l_date_end, 'dd.mm.yyyy'  ) )
               , xmlelement( "p_network_id"    , nvl(i_network_id,'0')               )
               , xmlelement( "p_network_name"  , get_text('NET_NETWORK','NAME', i_network_id, l_lang) )
               , xmlelement( "p_inst_id"       , nvl(i_inst_id,'0' )                 )
               , xmlelement( "p_inst_name"     , get_text('OST_INSTITUTION','NAME', i_inst_id, l_lang) )
           )
    into l_header from dual ;

    -- details
    select
        case when count(1) = 0 then
            xmlelement ("table"
                , xmlelement("record", null)
                )
        else
            xmlelement ( "table", xmlagg (xml) )
        end
   into l_detail
   from (
          select xmlagg( xmlelement
                         ("record"
                         , xmlelement( "currency"        , currency        )
                         , xmlelement( "oper_group"      , oper_group      )
                         , xmlelement( "oper_type"       , oper_type       )
                         , xmlelement( "terminal_type"   , terminal_type   )
                         , xmlelement( "terminal_number" , terminal_number )
                         , xmlelement( "oper_count"      , oper_count      )
                         , xmlelement( "oper_amount"     , oper_amount     )
                         , xmlelement( "fee_amount"      , fee_amount      )
                         , xmlelement( "row_type"        , row_type        )
                         , xmlelement( "agent_id"        , agent_id        )
                         , xmlelement( "agent_name"      , get_text('OST_AGENT', 'NAME', agent_id, l_lang) )
                         , xmlelement( "merchant_number" , merchant_number )
                         , xmlelement( "branch_name"     , branch_name     )
                         )
                 ) xml
          from (
                 with opr as
                      ( select o.id,
                               cont.agent_id
                             , t.terminal_number
                             --, t.terminal_type
                             , get_article_text(t.terminal_type, l_lang) as terminal_type
                             , o.oper_type
                             ,  case
                                when o.is_reversal = 0 then
                                     case when o.oper_type in ('OPTP0001','OPTP0012') then 'cash'
                                          when o.oper_type in ('OPTP0000','OPTP0009','OPTP0028','OPTP0060') then 'sale'
                                          when o.oper_type in ('OPTP0020') then 'return'
                                     end
                                when o.is_reversal = 1 then
                                     case when o.oper_type in ('OPTP0001','OPTP0012') then 'rev cash'
                                          when o.oper_type in ('OPTP0000','OPTP0009','OPTP0028','OPTP0060') then 'rev sale'
                                          when o.oper_type in ('OPTP0020') then 'rev return'
                                     end
                                end                as oper_group
                             , (case when o.oper_type <>'OPTP0020' and o.is_reversal = 0 then o.oper_amount
                                     when o.oper_type <>'OPTP0020' and o.is_reversal = 1 then (-1)*o.oper_amount
                                     when o.oper_type = 'OPTP0020' and o.is_reversal = 0 then (-1)*o.oper_amount
                                     when o.oper_type = 'OPTP0020' and o.is_reversal = 1 then o.oper_amount
                                end
                               )                   as oper_amount
                             , (case when o.oper_type <>'OPTP0020' and o.is_reversal = 0 then o.oper_surcharge_amount
                                     when o.oper_type <>'OPTP0020' and o.is_reversal = 1 then (-1)*o.oper_surcharge_amount
                                     when o.oper_type = 'OPTP0020' and o.is_reversal = 0 then (-1)*o.oper_surcharge_amount
                                     when o.oper_type = 'OPTP0020' and o.is_reversal = 1 then o.oper_surcharge_amount
                                end
                               )                   as fee_amount
                             --, o.oper_currency
                             , m.merchant_number
                             , m.merchant_name     as branch_name
                             , curr.name           as currency
                             , curr.exponent
                        from
                             opr_operation         o
                           , opr_participant       opa
                           , opr_participant       opi
                           , acq_terminal          t
                           , acq_merchant          m
                           , prd_contract          cont
                           , com_currency          curr
                        where
                             o.host_date between l_date_start and l_date_end
                         and opa.oper_id           = o.id
                         and opa.participant_type  = 'PRTYACQ'
                         and opi.oper_id           = o.id
                         and opi.participant_type  = 'PRTYISS'
                         and t.id                  = opa.terminal_id
                         and cont.id               = t.contract_id
                         and curr.code             = o.oper_currency
                         and m.id                  = opa.merchant_id
                         and opi.card_network_id   = i_network_id
                         and opa.inst_id           = i_inst_id
                         and o.oper_type in ('OPTP0001','OPTP0012'                       --cash
                                            ,'OPTP0000','OPTP0009','OPTP0028','OPTP0060' --sale
                                            ,'OPTP0020'                                  --purchase return
                                            )
                         and o.sttl_type in ('STTT0200', 'STTT0010')  --?  them-on-us, us-on-us
                         --and o.status    in ('OPST0400')              --?  processed
                         and o.status in (select element_value
                                            from com_array_element e
                                           where e.array_id = opr_api_const_pkg.OPER_STATUS_ARRAY_ID)
                         and exists (select 1
                                       from acc_macros    a_m
                                          , acc_entry     a_e
                                          , acc_account   acnt
                                      where a_e.macros_id    = a_m.id
                                        and acnt.id          = a_e.account_id
                                        and a_m.object_id    = o.id
                                        and a_m.entity_type  = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                        and acnt.contract_id = m.contract_id)
                      ) --end of opr
                 select
                      currency
                    , oper_group
                    , oper_type
                    , terminal_type
                    , terminal_number
                    , count(1)         as oper_count
                    , to_char( sum(oper_amount) / power(10, exponent)
                             , 'FM999999999990' || decode ( nvl(exponent,0), 0, null, '.' || lpad('0',exponent,'0') )
                             )         as oper_amount
                    , to_char( sum(fee_amount) / power(10, exponent)
                             , 'FM999999999990' || decode ( nvl(exponent,0), 0, null, '.' || lpad('0',exponent,'0') )
                             )         as fee_amount
                    , case when terminal_number is not null                           then 'not_gr'
                           when terminal_number is null and terminal_type is not null then 'term_type_gr'
                           when terminal_type   is null and oper_type     is not null then 'oper_type_gr'
                           when oper_type       is null and oper_group    is not null then 'oper_group_gr'
                           when oper_group      is null                               then 'currency_gr'
                      end  as row_type
                    , agent_id
                    , merchant_number
                    , branch_name
                 from
                      opr
                 group by grouping sets
                    ( (currency, exponent, oper_group, oper_type, terminal_type, terminal_number, agent_id, merchant_number, branch_name)
                     ,(currency, exponent, oper_group, oper_type, terminal_type)
                     ,(currency, exponent, oper_group, oper_type)
                     ,(currency, exponent, oper_group)
                     ,(currency, exponent)
                    )
               )
          order by
                currency
              , oper_group      nulls last
              , oper_type       nulls last
              , terminal_type   nulls last
              , terminal_number
        ) ;

    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table", xmlagg(
                            xmlelement("record"
                             , xmlelement( "currency"        , null )
                             , xmlelement( "oper_group"      , null )
                             , xmlelement( "oper_type"       , null )
                             , xmlelement( "terminal_type"   , null )
                             , xmlelement( "terminal_number" , null )
                             , xmlelement( "oper_count"      , null )
                             , xmlelement( "oper_amount"     , null )
                             , xmlelement( "fee_amount"      , null )
                             , xmlelement( "row_type"        , null )
                             , xmlelement( "agent_id"        , null )
                             , xmlelement( "merchant_number" , null )
                             , xmlelement( "branch_name"     , null )
                            )
                         )
               )
        into l_detail from dual ;
    end if;

    select xmlelement ( "report"
             , l_header
             , l_detail
           )
    into l_result
    from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'acq_api_report_pkg.cash_payment_sum - ok' );

exception
  --when no_data_found then trc_log_pkg.debug ( i_text => sqlerrm );
  when others then trc_log_pkg.debug ( i_text => sqlerrm );
                   raise_application_error (-20001,sqlerrm);

end;


procedure list_of_internet_shop
        ( o_xml          out clob
        , i_lang         in com_api_type_pkg.t_dict_value
        , i_date_start   in date   default trunc(com_api_sttl_day_pkg.get_sysdate)
        , i_date_end     in date   default trunc(com_api_sttl_day_pkg.get_sysdate)
        , i_inst_id      in com_api_type_pkg.t_tiny_id default null
        )
is
    l_date_start       date;
    l_date_end         date;
    l_lang             com_api_type_pkg.t_dict_value;

    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;
begin

   trc_log_pkg.debug
        ( i_text       => 'acq_api_report_pkg.list_of_internet_shop [#1][#2][#3][#4]]'
        , i_env_param1 => i_lang
        , i_env_param2 => i_date_start
        , i_env_param3 => i_date_end
        , i_env_param4 => i_inst_id
        );

    l_date_start := trunc( nvl(i_date_start, com_api_sttl_day_pkg.get_sysdate) );
    l_date_end   := nvl( trunc(i_date_end), l_date_start ) + 1 - (1/86400);
    l_lang       := nvl( i_lang, get_user_lang );

    -- header
    select xmlelement ( "header",
                 xmlelement( "p_date_start", to_char(l_date_start, 'dd.mm.yyyy') )
               , xmlelement( "p_date_end"  , to_char(l_date_end, 'dd.mm.yyyy'  ) )
               , xmlelement( "p_inst_id"   , decode (i_inst_id, null, 0, i_inst_id) )
               , xmlelement( "p_inst_name" , decode (i_inst_id, null, '0', nvl( get_text('OST_INSTITUTION','NAME', i_inst_id, l_lang), ' ' ) ) )
           )
    into l_header from dual ;

    -- details
   select xmlelement ( "table", xmlagg (xml) )
   into l_detail
   from (
          select xmlagg( xmlelement
                         ("record"
                         , xmlelement( "terminal_number" , terminal_number )
                         , xmlelement( "agent_id"        , agent_id        )
                         , xmlelement( "merchant_id"     , merchant_id     )
                         , xmlelement( "merchant_name"   , merchant_name   )
                         , xmlelement( "reg_date"        , to_char( start_date,'dd.mm.rr hh24:mi' ) )
                         )
                 ) xml
          from (
                  select
                       t.terminal_number
                     , c.agent_id
                     , t.merchant_id
                     , m.merchant_name
                     , c.start_date
                  from
                       acq_terminal t
                     , acq_merchant m
                     , prd_contract c
                  where
                       ( i_inst_id is null or t.inst_id = i_inst_id )
                   and m.id = t.merchant_id
                   and c.id = t.contract_id
                   and t.terminal_type = 'TRMT0004'
                   and c.start_date between l_date_start and l_date_end
                   and t.is_template <> 1
                  order by
                       c.agent_id
                     , c.start_date
               )
        ) ;

    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table", xmlagg(
                            xmlelement("record"
                            , xmlelement( "terminal_number" , null )
                            , xmlelement( "agent_id"        , null )
                            , xmlelement( "merchant_number" , null )
                            , xmlelement( "merchant_name"   , null )
                            , xmlelement( "terminal_status" , null )
                            , xmlelement( "reg_date"        , null )
                            )
                         )
              )
        into l_detail from dual ;
    end if;

    select xmlelement ( "report"
             , l_header
             , l_detail
           )
    into l_result
    from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'acq_api_report_pkg.list_of_internet_shop - ok' );

exception
  --when no_data_found then trc_log_pkg.debug ( i_text => sqlerrm );
  when others then trc_log_pkg.debug ( i_text => sqlerrm );
                   raise_application_error (-20001,sqlerrm);

end;

procedure fin_chargeback (
    o_xml             out clob
    , i_lang           in com_api_type_pkg.t_dict_value
    , i_start_date     in date              default null
    , i_end_date       in date              default null
    , i_inst_id        in com_api_type_pkg.t_inst_id
    , i_network_id     in com_api_type_pkg.t_short_id
) is
    l_start_date                   date;
    l_end_date                     date;
    l_result                       xmltype;
    l_header                       xmltype;
    l_detail                       xmltype;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_visa_network                 com_api_type_pkg.t_network_id   := 1003;
    l_mc_network                   com_api_type_pkg.t_network_id   := 1002;
    l_up_network                   com_api_type_pkg.t_network_id   := 1010;
begin

    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;

    -- header
    select
        xmlconcat(
            xmlelement("inst_id", i_inst_id)
            , xmlelement("inst", com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', i_inst_id, l_lang))
            , xmlelement("network_id", i_network_id)
            , xmlelement("network", com_api_i18n_pkg.get_text('NET_NETWORK','NAME', i_network_id, l_lang))
            , xmlelement("start_date", to_char(l_start_date, 'dd.mm.yyyy'))
            , xmlelement("end_date", to_char(l_end_date, 'dd.mm.yyyy'))
        )
    into
        l_header
            from dual;

    -- details
    begin
        if i_network_id = l_visa_network then --visa

            select
                xmlelement("messages"
                        , xmlagg(
                            xmlelement("message"
                                , xmlelement("dispute_id", dispute_id)
                                , xmlelement("usage_code", usage_code)
                                , xmlelement("oper_type", oper_type)
                                , xmlelement("terminal_number", terminal_number)
                                , xmlelement("terminal_type", get_article_text(terminal_type, l_lang))
                                , xmlelement("auth_code", auth_code)
                                , xmlelement("card_number", card_mask)
                                , xmlelement("orig_amount", case when orig_code is not null then com_api_currency_pkg.get_amount_str(nvl(orig_amount, 0), orig_code, com_api_type_pkg.TRUE) else null end)
                                , xmlelement("orig_currency", orig_currency)
                                , xmlelement("sttl_amount", case when sttl_code is not null then com_api_currency_pkg.get_amount_str(nvl(sttl_amount, 0), sttl_code, com_api_type_pkg.TRUE) else null end)
                                , xmlelement("sttl_currency", sttl_currency)
                                , xmlelement("oper_date", to_char(oper_date, 'dd.mm.yyyy'))
                                , xmlelement("sttl_date", to_char(sttl_date, 'dd.mm.yyyy'))
                                , xmlelement("agent", com_api_i18n_pkg.get_text('OST_AGENT','NAME', agent_id, l_lang))
                                , xmlelement("arn", arn)
                                , xmlelement("msg_id", id)
                                , xmlelement("sort_by_type", sort_by_type)
                                , xmlelement("sort_by_curr", sort_by_curr)
                            )
                            order by sort_by_type, sort_by_curr
                        )
                    )
            into
                l_detail
            from (
                select *
                  from (
                    select m.dispute_id
                         , m.usage_code
                         , o.oper_type
                         , o.terminal_number
                         , o.terminal_type
                         , m.auth_code
                         , m.card_mask
                         , m.oper_amount orig_amount
                         , r_orig.name orig_currency
                         , m.sttl_amount
                         , r_sttl.name sttl_currency
                         , m.oper_date
                         , to_date (substr (to_char (m.oper_date, 'YYYY'), 1, 3) || m.central_proc_date, 'YYYYDDD') sttl_date
                         , m.agent_unique_id agent_id
                         , m.arn
                         , m.id
                         , case when o.mcc in ('6011', '6010') then 2 else 1 end as sort_by_type
                         , case when r_sttl.name = 'USD' then 1 else 2 end as sort_by_curr
                         , r_orig.code orig_code
                         , r_sttl.code sttl_code
                      from vis_fin_message m
                         , opr_operation o
                         , com_currency r_orig
                         , com_currency r_sttl
                     where m.inst_id          = i_inst_id
                       and m.network_id       = i_network_id
                       and m.usage_code       = 2
                       and m.trans_code       in (vis_api_const_pkg.TC_SALES, vis_api_const_pkg.TC_VOUCHER, vis_api_const_pkg.TC_CASH)
                       and m.is_incoming      = 0
                       and o.id               = m.id
                       and r_orig.code        = m.oper_currency
                       and r_sttl.code        = m.sttl_currency
                       and nvl(to_date (substr (to_char (m.oper_date, 'YYYY'), 1, 3) || m.central_proc_date, 'YYYYDDD'), m.oper_date) between l_start_date and l_end_date
                    union
                    --CHBCK
                    select m.dispute_id
                         , m.usage_code
                         , o.oper_type
                         , o.terminal_number
                         , o.terminal_type
                         , m.auth_code
                         , m.card_mask
                         , m.oper_amount orig_amount
                         , r_orig.name orig_currency
                         , m.sttl_amount
                         , r_sttl.name sttl_currency
                         , m.oper_date
                         , to_date (substr (to_char (m.oper_date, 'YYYY'), 1, 3) || m.central_proc_date, 'YYYYDDD') sttl_date
                         , m.agent_unique_id agent_id
                         , m.arn
                         , m.id
                         , case when o.mcc in ('6011', '6010') then 2 else 1 end as sort_by_type
                         , case when r_sttl.name = 'USD' then 1 else 2 end as sort_by_curr
                         , r_orig.code orig_code
                         , r_sttl.code sttl_code
                      from vis_fin_message m
                         , opr_operation o
                         , com_currency r_orig
                         , com_currency r_sttl
                     where m.inst_id          = i_inst_id
                       and m.network_id       = i_network_id
                       and m.usage_code       = 1
                       and m.trans_code       in (vis_api_const_pkg.TC_SALES_CHARGEBACK, vis_api_const_pkg.TC_VOUCHER_CHARGEBACK, vis_api_const_pkg.TC_CASH_CHARGEBACK)
                       and o.id               = m.id
                       and m.is_incoming      = 1
                       and r_orig.code        = m.oper_currency
                       and r_sttl.code        = m.sttl_currency
                       and nvl(to_date (substr (to_char (m.oper_date, 'YYYY'), 1, 3) || m.central_proc_date, 'YYYYDDD'), m.oper_date) between l_start_date and l_end_date
                )
              );

        elsif i_network_id = l_mc_network then --mc
            select
                xmlelement("messages"
                        , xmlagg(
                            xmlelement("message"
                                , xmlelement("dispute_id", dispute_id)
                                , xmlelement("usage_code", usage_code)
                                , xmlelement("oper_type", oper_type)
                                , xmlelement("terminal_number", terminal_number)
                                , xmlelement("terminal_type", get_article_text(terminal_type, l_lang))
                                , xmlelement("auth_code", auth_code)
                                , xmlelement("card_number", card_mask)
                                , xmlelement("orig_amount", case when orig_code is not null then com_api_currency_pkg.get_amount_str(nvl(orig_amount, 0), orig_code, com_api_type_pkg.TRUE) else null end)
                                , xmlelement("orig_currency", orig_currency)
                                , xmlelement("sttl_amount", case when sttl_code is not null then com_api_currency_pkg.get_amount_str(nvl(sttl_amount, 0), sttl_code, com_api_type_pkg.TRUE) else null end)
                                , xmlelement("sttl_currency", sttl_currency)
                                , xmlelement("oper_date", to_char(oper_date, 'dd.mm.yyyy'))
                                , xmlelement("sttl_date", to_char(sttl_date, 'dd.mm.yyyy'))
                                , xmlelement("agent", com_api_i18n_pkg.get_text('OST_AGENT','NAME', ost_api_institution_pkg.get_default_agent(i_inst_id => i_inst_id), l_lang))
                                , xmlelement("arn", arn)
                                , xmlelement("msg_id", id)
                                , xmlelement("sort_by_type", sort_by_type)
                                , xmlelement("sort_by_curr", sort_by_curr)
                            )
                            order by sort_by_type, sort_by_curr
                        )
                    )
            into
                l_detail
            from (
                select *
                  from (
                    select m.dispute_id
                         , 2 usage_code
                         , o.oper_type
                         , o.terminal_number
                         , o.terminal_type
                         , p_iss.auth_code
                         , iss_api_card_pkg.get_card_mask(c.card_number) card_mask
                         , m.de004 orig_amount
                         , r_orig.name orig_currency
                         , m.de005 sttl_amount
                         , r_sttl.name sttl_currency
                         , m.de012 oper_date
                         , m.p0159_8 sttl_date
                         , m.de031 arn
                         , m.id
                         , case when o.mcc in ('6011', '6010') then 2 else 1 end as sort_by_type
                         , case when r_sttl.name = 'USD' then 1 else 2 end as sort_by_curr
                         , r_orig.code orig_code
                         , r_sttl.code sttl_code
                      from mcw_fin m
                         , mcw_card c
                         , opr_operation o
                         , opr_participant p_iss
                         , com_currency r_orig
                         , com_currency r_sttl
                     where m.inst_id              = i_inst_id
                       and m.network_id           = i_network_id
                       and o.id                   = m.id
                       and m.is_incoming          = 0
                       and m.mti                  = mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
                       and m.de024                in (mcw_api_const_pkg.FUNC_CODE_SECOND_PRES_FULL, mcw_api_const_pkg.FUNC_CODE_SECOND_PRES_PART)
                       and c.id                   = m.id
                       and p_iss.oper_id          = o.id
                       and p_iss.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                       and r_orig.code(+)         = m.de049
                       and r_sttl.code(+)         = m.p0149_1
                       and nvl(m.p0159_8, m.de012) between l_start_date and l_end_date
                    --CHBCK
                    union
                    select m.dispute_id
                         , 1 usage_code
                         , o.oper_type
                         , o.terminal_number
                         , o.terminal_type
                         , p_iss.auth_code
                         , iss_api_card_pkg.get_card_mask(c.card_number) card_mask
                         , m.de004 orig_amount
                         , r_orig.name orig_currency
                         , m.de005 sttl_amount
                         , r_sttl.name sttl_currency
                         , m.de012 oper_date
                         , m.p0159_8 sttl_date
                         , m.de031 arn
                         , m.id
                         , case when o.mcc in ('6011', '6010') then 2 else 1 end as sort_by_type
                         , case when r_sttl.name = 'USD' then 1 else 2 end as sort_by_curr
                         , r_orig.code orig_code
                         , nvl(r_sttl.code, r_orig.code) sttl_code
                      from mcw_fin m
                         , mcw_card c
                         , opr_operation o
                         , opr_participant p_iss
                         , com_currency r_orig
                         , com_currency r_sttl
                     where m.inst_id              = i_inst_id
                       and m.network_id           = i_network_id
                       and o.id                   = m.id
                       and m.is_incoming          = 1
                       and m.mti                  = mcw_api_const_pkg.MSG_TYPE_CHARGEBACK
                       and m.de024                in (mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL, mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART
                                                    , mcw_api_const_pkg.FUNC_CODE_CHARGEBACK2_FULL, mcw_api_const_pkg.FUNC_CODE_CHARGEBACK2_PART)
                       and c.id                   = m.id
                       and p_iss.oper_id          = o.id
                       and p_iss.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                       and r_orig.code(+)         = m.de049
                       and r_sttl.code(+)         = m.p0149_1
                       and nvl(m.p0159_8, m.de012) between l_start_date and l_end_date
                )
             );

        elsif i_network_id = l_up_network then --up
            null;
        else
            null;

        end if;

    exception
        when no_data_found then
            select
                xmlelement("messages", '')
            into
                l_detail
            from
                dual;

            trc_log_pkg.debug (
                i_text  => 'messages not found'
            );
    end;

    select
        xmlelement (
            "report"
            , l_header
            , l_detail
        ) r
    into
        l_result
    from
        dual;

    o_xml := l_result.getclobval();

    --dbms_output.put_line(o_xml);
end;

procedure list_of_unconmerchanted_auth(
    o_xml         out clob
  , i_lang         in com_api_type_pkg.t_dict_value
  , i_date_start   in date                              default null
  , i_date_end     in date                              default null
  , i_inst_id      in com_api_type_pkg.t_inst_id        default null
  , i_agent_id     in com_api_type_pkg.t_agent_id       default null
  , i_cash         in com_api_type_pkg.t_boolean        default com_api_const_pkg.true
  , i_sale         in com_api_type_pkg.t_boolean        default com_api_const_pkg.true
  , i_imprn        in com_api_type_pkg.t_boolean        default com_api_const_pkg.true
  , i_pos          in com_api_type_pkg.t_boolean        default com_api_const_pkg.true
  , i_atm          in com_api_type_pkg.t_boolean        default com_api_const_pkg.true
  , i_epos         in com_api_type_pkg.t_boolean        default com_api_const_pkg.true
  , i_unconmerch   in com_api_type_pkg.t_boolean        default com_api_const_pkg.true
  , i_unprocess    in com_api_type_pkg.t_boolean        default com_api_const_pkg.true
) is
    l_date_start       date;
    l_date_end         date;
    l_lang             com_api_type_pkg.t_dict_value;
    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;
    l_logo_path        xmltype;
begin

    trc_log_pkg.debug(
        i_text       => 'acq_api_report_pkg.list_of_unconmerchanted_auth [#1][#2][#3][#4][#5]'
      , i_env_param1 => com_api_type_pkg.convert_to_char(i_date_start)
      , i_env_param2 => com_api_type_pkg.convert_to_char(i_date_end)
      , i_env_param3 => i_inst_id
      , i_env_param4 => i_agent_id
    );

    l_date_start := trunc(nvl(i_date_start, com_api_sttl_day_pkg.get_sysdate));
    l_date_end := nvl(trunc(i_date_end), l_date_start) + 1 - com_api_const_pkg.ONE_SECOND;
    l_lang := nvl(i_lang, get_user_lang);

    -- header
    l_logo_path := rpt_api_template_pkg.logo_path_xml;
    select
        xmlelement("header"
          , l_logo_path
          , xmlelement("p_date_start", to_char(l_date_start, 'dd.mm.yyyy'))
          , xmlelement("p_date_end", to_char(l_date_end, 'dd.mm.yyyy'))
          , xmlelement("p_inst_id", nvl(i_inst_id, '0'))
          , xmlelement("p_agent_id", nvl(i_agent_id, '0'))
          , xmlelement("p_oper_class"
              , case
                    when nvl(i_cash, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
                        'cash' || case
                                      when nvl(i_sale, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
                                          ' and sale'
                                      else
                                          null
                                  end
                    else
                        case
                            when nvl(i_sale, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
                                'sale'
                            else
                                null
                        end
                end
            )
          , xmlelement("p_cash", nvl(i_cash, 0))
          , xmlelement("p_sale", nvl(i_sale, 0))
          , xmlelement("p_imprn", nvl(i_imprn, 0))
          , xmlelement("p_pos", nvl(i_pos, 0))
          , xmlelement("p_atm", nvl(i_atm, 0))
          , xmlelement("p_epos", nvl(i_epos, 0))
          , xmlelement("p_auth_class"
              , case
                    when nvl(i_unconmerch, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
                        'Unconmerchanted' || case
                                                 when nvl(i_unprocess, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
                                                     ' and unprocessed'
                                                 else
                                                     null
                                             end
                    else
                        case
                            when nvl(i_unprocess, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
                                'Unprocessed'
                            else
                                null
                        end
                end
            )
          , xmlelement("p_unconmerch", nvl(i_unconmerch, 0))
          , xmlelement("p_unprocess", nvl(i_unprocess, 0))
        )
      into l_header
      from dual;

    -- details
    select xmlelement("table", xmlagg(xml))
      into l_detail
      from (
            select
                xmlagg(
                    xmlelement("record"
                      , xmlelement("inst_id", inst_id)
                      , xmlelement("inst_name", inst_name)
                      , xmlelement("agent_id", agent_id)
                      , xmlelement("agent_name", agent_name)
                      , xmlelement("oper_status", oper_status)
                      , xmlelement("terminal_number", terminal_number)
                      , xmlelement("terminal_type", terminal_type)
                      , xmlelement("oper_type", oper_type)
                      , xmlelement("oper_date", oper_date)
                      , xmlelement("card_number", card_number)
                      , xmlelement("oper_amount", oper_amount)
                      , xmlelement("oper_currency", oper_currency)
                      , xmlelement("auth_code", auth_code)
                      , xmlelement("oper_place", oper_place)
                    )
                ) xml
              from (select
                        opa.inst_id
                      , get_text(
                            i_table_name    => 'OST_INSTITUTION'
                          , i_column_name   => 'NAME'
                          , i_object_id     => opa.inst_id
                          , i_lang          => l_lang
                        ) inst_name
                      , cont.agent_id
                      , get_text(
                            i_table_name    => 'OST_AGENT'
                          , i_column_name   => 'NAME'
                          , i_object_id     => cont.agent_id
                          , i_lang          => l_lang
                        ) agent_name
                      , case
                            when o.status in (opr_api_const_pkg.OPERATION_STATUS_MANUAL, opr_api_const_pkg.OPERATION_STATUS_EXCEPTION) then
                                'Unprocessed'
                            else
                                'Unconmerchanted'
                        end oper_status
                      , t.terminal_number
                      , get_article_text(
                            i_article       => t.terminal_type
                          , i_lang          => l_lang
                        ) terminal_type
                      , case
                            when o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH, opr_api_const_pkg.OPERATION_TYPE_POS_CASH) then
                                'Cash'
                            else
                                'Sale'
                        end oper_type
                      , to_char(o.oper_date, 'dd.mm.yyyy') oper_date
                      , iss_api_card_pkg.get_card_mask(card.card_number) card_number
                      , to_char(o.oper_amount / power(10, curr.exponent)
                          , com_api_const_pkg.XML_NUMBER_FORMAT || decode(nvl(curr.exponent, 0), 0, null, '.' || lpad('0', curr.exponent, '0'))
                        ) oper_amount
                      , o.oper_currency
                      , opi.auth_code
                      , o.merchant_name oper_place
                      , o.status
                 from
                      opr_operation o
                    , opr_participant opa
                    , opr_participant opi
                    , opr_card card
                    , acq_terminal t
                    , com_currency curr
                    , prd_contract cont
                where
                      o.id between com_api_id_pkg.get_from_id(l_date_start) and com_api_id_pkg.get_till_id(l_date_end)
                  and trunc(o.oper_date) between l_date_start and l_date_end
                  and opa.oper_id           = o.id
                  and opa.participant_type  = com_api_const_pkg.PARTICIPANT_ACQUIRER
                  and opi.oper_id           = o.id
                  and opi.participant_type  = com_api_const_pkg.PARTICIPANT_ISSUER
                  and card.oper_id          = o.id
                  and card.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                  and t.id                  = opa.terminal_id
                  and curr.code             = o.oper_currency
                  and cont.id               = t.contract_id
                  and (i_inst_id is null or opa.inst_id = i_inst_id)
                  and (i_agent_id is null or cont.agent_id = i_agent_id)
                  and (
                       (nvl(i_unconmerch, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE
                        and o.match_status not in(opr_api_const_pkg.OPERATION_MATCH_DONT_REQ_MATCH, opr_api_const_pkg.OPERATION_MATCH_MATCHED)
                       )
                       or
                       (nvl(i_unprocess, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE
                        and o.status in (opr_api_const_pkg.OPERATION_STATUS_MANUAL, opr_api_const_pkg.OPERATION_STATUS_EXCEPTION)            --Frozen for manual processing, Processing error
                       )
                      )
                  and o.sttl_type in (opr_api_const_pkg.SETTLEMENT_USONUS, opr_api_const_pkg.SETTLEMENT_THEMONUS)               --us-on-us, them-on-us
                  and (
                       (nvl(i_imprn, com_api_const_pkg.FALSE)= com_api_const_pkg.TRUE
                        and t.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER
                       )
                       or
                       (nvl(i_atm, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE
                        and t.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM
                       )
                       or
                       (nvl(i_pos, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE
                        and t.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS
                       )
                       or
                       (nvl(i_epos, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE
                        and t.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_EPOS
                       )
                      )
                order by
                      opa.inst_id
                    , cont.agent_id
                    , case
                          when o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH, opr_api_const_pkg.OPERATION_TYPE_POS_CASH) then
                              1
                          else
                              2
                      end
                    , decode(t.terminal_type
                        , acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER, 1 --imprinter
                        , acq_api_const_pkg.TERMINAL_TYPE_POS, 2 --pos
                        , acq_api_const_pkg.TERMINAL_TYPE_ATM, 3 --atm
                        , acq_api_const_pkg.TERMINAL_TYPE_EPOS, 4 --epos
                      )
                    , oper_date
                   )
           );

    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select
            xmlelement("table",
                xmlagg(
                    xmlelement("record"
                      , xmlelement("inst_id", null)
                      , xmlelement("inst_name", ' ')
                      , xmlelement("agent_id", null)
                      , xmlelement("agent_name", ' ')
                      , xmlelement("oper_status", null)
                      , xmlelement("terminal_number", null)
                      , xmlelement("terminal_type", null)
                      , xmlelement("oper_type", null)
                      , xmlelement("oper_date", null)
                      , xmlelement("card_number", null)
                      , xmlelement("oper_amount", null)
                      , xmlelement("oper_currency", null)
                      , xmlelement("auth_code", null)
                      , xmlelement("oper_place", null)
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

    trc_log_pkg.debug(i_text => 'acq_api_report_pkg.list_of_unconmerchanted_auth - ok');

exception
    when others then
        trc_log_pkg.debug(
            i_text  => 'acq_api_report_pkg.list_of_unconmerchanted_auth i_inst_id [' || i_inst_id
                    || '], i_agent_id [' || i_agent_id
                    || '], l_date_start [' || com_api_type_pkg.convert_to_char(l_date_start)
                    || '], l_date_end [' || com_api_type_pkg.convert_to_char(l_date_end)
                    || '], i_cash ['|| i_cash
                    || '], i_sale [' || i_sale
                    || '], i_imprn [' || i_imprn
                    || '], i_pos [' || i_pos
                    || '], i_atm [' || i_atm
                    || '], i_epos [' || i_epos
                    || '], i_unconmerch [' || i_unconmerch
                    || '], i_unprocess [' || i_unprocess || ']'
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

procedure aggregate_stat_bin_range_used(
    o_xml              out clob
  , i_lang              in com_api_type_pkg.t_dict_value    default null
  , i_year              in com_api_type_pkg.t_tiny_id
  , i_quarter           in com_api_type_pkg.t_sign
  , i_network_id        in com_api_type_pkg.t_network_id
  , i_inst_id           in com_api_type_pkg.t_inst_id
  , i_bin_range_start   in com_api_type_pkg.t_short_id
  , i_bin_range_end     in com_api_type_pkg.t_short_id
) is
    UNCATEGORIZED_POS_TYPE     constant com_api_type_pkg.t_name := 'Uncategorized';
    
    l_start                    date;
    l_end                      date;
    l_header                   xmltype;
    l_detail_part_1            xmltype;
    l_detail_part_2            xmltype;

begin

    trc_log_pkg.debug(
        i_text  => 'acq_api_report_pkg.aggregate_stat_bin_range_used i_lang [' || i_lang
                || '], i_year [' || i_year
                || '], i_quarter [' || i_quarter
                || '], i_network_id [' || i_network_id
                || '], i_inst_id [' || i_inst_id
                || '], i_bin_range_start [' || i_bin_range_start
                || '], i_bin_range_end [' || i_bin_range_end || ']'
    );

    l_start   := add_months(
                     to_date('01' || lpad(i_quarter * 3, 2, '0') || to_char(i_year), 'ddmmyyyy')
                   , -2
                 );

    l_end     := add_months(l_start, 3) - 0.00001;

    -- header
    select
           xmlelement("header",
               xmlelement("p_year", i_year)
             , xmlelement("p_quarter", i_quarter)
           )
      into l_header
      from dual;

    -- details
    select 
           xmlelement("table_atm_merchant"
             , xmlelement("all_atm_merchant", all_merch)
             , xmlelement("merchant_complient_value", merch_compl)
             , xmlelement("merchant_complient_percent", round((merch_compl / decode(all_merch, 0, 1, all_merch)) * 100, 2))
             , xmlelement("atm_terminal", all_terminal)
             , xmlelement("atm_terminal_complient_value", terminal_compl)
             , xmlelement("atm_terminal_complient_percent", round((terminal_compl / decode(all_terminal, 0, 1, all_terminal)) * 100, 2))
           )
      into l_detail_part_1
      from(
          select 
                 sum(decode(rank_merch, 1, 1, 0))           as all_merch
               , sum(decode(rank_merch, 1, new_bin, 0))     as merch_compl
               , sum(decode(rank_terminal, 1, 1, 0))        as all_terminal
               , sum(decode(rank_terminal, 1, new_bin, 0))  as terminal_compl
          from
          (
              select row_number() over(partition by 
                                           aqt.merchant_id
                                       order by case
                                                    when to_number(substr(iss_api_token_pkg.decode_card_number(i_card_number => oc.card_number), 1, 6)) between i_bin_range_start and i_bin_range_end
                                                        then 1
                                                    else 0
                                                end desc
                                  ) rank_merch
                   , row_number() over(partition by 
                                           aqt.id
                                       order by case
                                                    when to_number(substr(iss_api_token_pkg.decode_card_number(i_card_number => oc.card_number), 1, 6)) between i_bin_range_start and i_bin_range_end
                                                        then 1
                                                    else 0
                                                end desc
                                  ) rank_terminal
                   , case
                         when to_number(substr(iss_api_token_pkg.decode_card_number(i_card_number => oc.card_number), 1, 6)) between i_bin_range_start and i_bin_range_end
                             then 1
                         else 0
                     end new_bin
                from opr_operation oo
                   , opr_participant opaq
                   , opr_participant opi
                   , acq_terminal aqt
                   , opr_card oc
             where
                   trunc(oo.oper_date) between l_start and l_end
               and oo.sttl_type in (
                       opr_api_const_pkg.SETTLEMENT_USONUS
                     , opr_api_const_pkg.SETTLEMENT_USONUS_INTRAINST
                     , opr_api_const_pkg.SETTLEMENT_USONUS_INTERINST
                     , opr_api_const_pkg.SETTLEMENT_THEMONUS
                   )
               and opaq.oper_id = oo.id
               and opaq.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
               and opaq.inst_id = i_inst_id
               and aqt.id = opaq.terminal_id
               and aqt.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM
               and opi.oper_id = oo.id
               and opi.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
               and opi.network_id = i_network_id
               and oc.oper_id = oo.id
               and not regexp_like(iss_api_token_pkg.decode_card_number(i_card_number => oc.card_number),'[^[:digit:]]')
        )
        where rank_merch = 1 
           or rank_terminal = 1
      );
      
    select 
           xmlelement("table_pos_merchants",
               xmlagg(
                   xmlelement("table_pos_merchant"
                     , xmlelement("all_pos_merchant", all_merch_pos)
                     , xmlelement("merchant_complient_value", merch_pos_compl)
                     , xmlelement("merchant_complient_percent",round((merch_pos_compl / decode(all_merch_pos, 0, 1, all_merch_pos)) *100, 2))
                     , xmlelement("target_date_compliens", null)
                     , xmlelement("merchant_pos_type", nvl(com_api_dictionary_pkg.get_article_text(
                                                               i_article => pos_type
                                                             , i_lang    => i_lang
                                                           )
                                                         , UNCATEGORIZED_POS_TYPE
                                                       )
                       )
                     , xmlelement("terminal_is_updated_remote", 'No')
                   ) order by pos_type
               )
           )
      into l_detail_part_2
      from(
          select sum(decode(rank_merch, 1, 1, 0))           as all_merch_pos
               , sum(decode(rank_merch, 1, new_bin, 0))     as merch_pos_compl
               , pos_type
          from
          (
              select aqt.merchant_id
                   , aqt.card_data_input_mode pos_type
                   , row_number() over(partition by 
                                           aqt.merchant_id
                                         , aqt.card_data_input_mode
                                       order by case
                                                    when to_number(substr(iss_api_token_pkg.decode_card_number(i_card_number => oc.card_number), 1, 6)) between i_bin_range_start and i_bin_range_end
                                                        then 1
                                                    else 0
                                                end desc
                                  ) as rank_merch
                   , case
                         when to_number(substr(iss_api_token_pkg.decode_card_number(i_card_number => oc.card_number), 1, 6)) between i_bin_range_start and i_bin_range_end
                             then 1
                         else 0
                     end new_bin
                from opr_operation oo
                   , opr_participant opaq
                   , opr_participant opi
                   , acq_terminal aqt
                   , opr_card oc
             where trunc(oo.oper_date) between l_start and l_end
               and oo.sttl_type in (
                       opr_api_const_pkg.SETTLEMENT_USONUS
                     , opr_api_const_pkg.SETTLEMENT_USONUS_INTRAINST
                     , opr_api_const_pkg.SETTLEMENT_USONUS_INTERINST
                     , opr_api_const_pkg.SETTLEMENT_THEMONUS
                   )
               and opaq.oper_id = oo.id
               and opaq.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
               and opaq.inst_id = i_inst_id
               and aqt.id = opaq.terminal_id
               and aqt.terminal_type in (
                       acq_api_const_pkg.TERMINAL_TYPE_POS
                     , acq_api_const_pkg.TERMINAL_TYPE_EPOS
                     , acq_api_const_pkg.TERMINAL_TYPE_MOBILE_POS
                   )
               and opi.oper_id = oo.id
               and opi.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
               and opi.network_id = i_network_id
               and oc.oper_id = oo.id
               and not regexp_like(iss_api_token_pkg.decode_card_number(i_card_number => oc.card_number),'[^[:digit:]]')
        )
        where rank_merch = 1 
        group by
              pos_type
      );
    

    select xmlelement("report"
             , l_header
             , l_detail_part_1
             , l_detail_part_2
           ).getClobVal()
      into o_xml
      from dual;

    trc_log_pkg.debug(i_text => 'acq_api_report_pkg.aggregate_stat_bin_range_used - ok');

exception
    when others then
        trc_log_pkg.debug(
            i_text  => 'acq_api_report_pkg.aggregate_stat_bin_range_used l_start [' || com_api_type_pkg.convert_to_char(l_start)
                    || '], l_end [' || com_api_type_pkg.convert_to_char(l_end)
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
end aggregate_stat_bin_range_used;

function get_customer_name(
    i_customer_id          in  com_api_type_pkg.t_medium_id
) return  com_api_type_pkg.t_name
is
    l_customer_name     com_api_type_pkg.t_name;
    l_lang              com_api_type_pkg.t_dict_value := get_user_lang;
begin
    select case c.entity_type
           when com_api_const_pkg.ENTITY_TYPE_PERSON -- 'ENTTPERS'
           then com_ui_person_pkg.get_person_name (c.object_id, l_lang)
           when com_api_const_pkg.ENTITY_TYPE_COMPANY -- 'ENTTCOMP'
           then nvl(
                    get_text ('COM_COMPANY', 'DESCRIPTION', c.object_id, l_lang)
                  , get_text ('COM_COMPANY', 'LABEL', c.object_id, l_lang)
                )
           end as customer_name
      into l_customer_name
      from prd_customer c
     where c.id = i_customer_id;
    return l_customer_name;
exception
    when no_data_found then
        trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_customer_name(i_customer_id => [' || i_customer_id || ']) No data found.');
        return null;
end get_customer_name;

procedure acquiring_activity_report( 
    o_xml                  out clob
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_customer_number   in     com_api_type_pkg.t_name
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value  default null
) is
    l_institution          com_api_type_pkg.t_full_desc;
    l_customer_id          com_api_type_pkg.t_medium_id;
    l_customer             com_api_type_pkg.t_full_desc;
    l_start_date           date                             := trunc(i_start_date);
    l_end_date             date                             := trunc(i_end_date + 1) - 1 / 24 / 60 / 60;
    l_header               xmltype;
    l_detail               xmltype;
    l_footer               xmltype;
    l_result               xmltype;
begin
    trc_log_pkg.debug(
        i_text  => 'acq_api_report_pkg.acquiring_activity_report: i_inst_id [' || i_inst_id
                || '], i_customer_number [' || i_customer_number
                || '], i_start_date ['  || i_start_date
                || '], i_end_date ['    || i_end_date
                || ']'
    );

    l_institution := i_inst_id || ' ' || get_text(i_table_name => 'ost_institution', i_column_name => 'name', i_object_id => i_inst_id);
    l_customer_id := prd_api_customer_pkg.get_customer_id(
                        i_customer_number   => i_customer_number
                      , i_inst_id           => i_inst_id
                      , i_mask_error        => com_api_const_pkg.FALSE
                     );
    l_customer    := i_customer_number || ' ' || get_customer_name(i_customer_id => l_customer_id);

    -- header
    select xmlelement(
               "header"
             , xmlelement("institution"     , l_institution)
             , xmlelement("customer"        , nvl(l_customer, 'N/A'))
             , xmlelement("start_date"      , to_char(l_start_date, 'dd.mm.yyyy'))
             , xmlelement("end_date"        , to_char(l_end_date, 'dd.mm.yyyy'))
           )
      into l_header
      from dual;

    -- detail
    select xmlelement(
               "details"
             , xmlagg(
                   xmlelement(
                       "detail"
                     , xmlelement("account_number"    , account_number)
                     , xmlelement("account_currency"  , com_api_currency_pkg.get_currency_name(i_curr_code => account_currency))
                     , xmlelement("funds_flow"        , funds_flow)
                     , xmlelement("total_amount"      , com_api_currency_pkg.get_amount_str(
                                                            i_amount           => total_amount
                                                          , i_curr_code        => account_currency
                                                          , i_mask_curr_code   => com_api_type_pkg.TRUE
                                                          , i_mask_error       => com_api_type_pkg.FALSE
                                                        )
                       )
                     , xmlelement("total_count"       , total_count)
                     , xmlelement("account_total"     , com_api_currency_pkg.get_amount_str(
                                                            i_amount           => account_total
                                                          , i_curr_code        => account_currency
                                                          , i_mask_curr_code   => com_api_type_pkg.TRUE
                                                          , i_mask_error       => com_api_type_pkg.FALSE
                                                        )
                       )
                     , xmlelement("balance_impact"    , balance_impact)
                   )
               )
           )
      into l_detail
      from(
        select account_number
             , account_currency
             , nvl(funds_flow, 'N/A') as funds_flow
             , sum(amount_signed) as total_amount
             , nvl2(funds_flow, count(1), null) as total_count
             , nvl2(funds_flow, sum(sum(amount_signed)) over(partition by account_number, account_currency), null) as account_total
             , balance_impact
        from(
            select t3.account_number                                    as account_number
                 , t3.account_currency                                  as account_currency
                 , nvl(t3.balance_impact, t3.balance_impact_multiply)   as balance_impact
                 , nvl((t3.balance_impact * t3.amount), 0)              as amount_signed
                 , case
                       when t3.amount_purpose like 'FETP%' then
                            get_article_text(i_article => t3.amount_purpose)
                       when t3.fee_id is not null then
                            get_text(i_table_name => 'com_dictionary', i_column_name => 'name', i_object_id => t3.fee_id)
                       else com_api_dictionary_pkg.get_article_text(o.oper_type) || decode(o.is_reversal, 1, ' reversal')
                   end                                                  as funds_flow
            from(
                select m.amount_purpose
                     , m.object_id
                     , m.fee_id
                     , t2.balance_impact
                     , t2.amount
                     , t2.account_currency
                     , t2.account_number
                     , t2.balance_impact_multiply
                from(
                    select e.balance_impact
                         , e.amount
                         , e.currency as entry_currency
                         , e.macros_id
                         , t1.account_currency
                         , t1.account_id
                         , t1.account_number
                         , t1.balance_impact_multiply
                    from(
                        select a.id as account_id
                             , a.account_number
                             , a.currency as account_currency
                             , b.balance_type
                             , bim.balance_impact_multiply
                        from acc_account a
                           , acc_balance b
                           , (
                              select  1 as balance_impact_multiply from dual
                              union all
                              select -1 from dual
                             ) bim
                        where a.account_type  = acc_api_const_pkg.ACCOUNT_TYPE_MERCHANT
                          and a.inst_id       = i_inst_id
                          and a.customer_id   = l_customer_id
                          and b.account_id    = a.id
                          and b.balance_type in (
                                                 acc_api_const_pkg.BALANCE_TYPE_LEDGER
                                               , acc_api_const_pkg.BALANCE_TYPE_DEPOSIT
                                                )
                    ) t1
                    , acc_entry e
                where 1=1
                  and e.account_id(+)      = t1.account_id
                  and e.posting_date(+)   >= trunc(l_start_date)
                  and e.posting_date(+)   <  trunc(l_end_date) + 1
                  and e.balance_type(+)    = t1.balance_type
                  and e.balance_impact(+)  = t1.balance_impact_multiply
                  and e.status(+)         != acc_api_const_pkg.ENTRY_STATUS_CANCELED
                ) t2
                , acc_macros m
                where 1=1
                  and m.account_id(+)      = t2.account_id
                  and m.entity_type(+)     = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                  and m.id(+)              = t2.macros_id
            ) t3
                , opr_operation o
            where t3.object_id = o.id(+)
         ) t4
        group by
            account_number
          , account_currency
          , funds_flow
          , balance_impact
        order by
            account_number
          , account_currency
          , balance_impact desc
          , funds_flow
    ) t5;

    if l_detail.getclobval() = '<details></details>' then
        select xmlelement(
                   "details"
                 , xmlconcat(
                       xmlagg(
                           xmlelement(
                               "detail"
                             , xmlelement("account_number"      ,    'N/A')
                             , xmlelement("account_currency"    ,    null)
                             , xmlelement("funds_flow"          ,    'N/A')
                             , xmlelement("total_amount"        ,    '0.00')
                             , xmlelement("total_count"         ,    null)
                             , xmlelement("account_total"       ,    null)
                             , xmlelement("balance_impact"      ,    1)
                           )
                       )
                     , xmlagg(
                           xmlelement(
                               "detail"
                             , xmlelement("account_number"      ,    'N/A')
                             , xmlelement("account_currency"    ,    null)
                             , xmlelement("funds_flow"          ,    'N/A')
                             , xmlelement("total_amount"        ,    '0.00')
                             , xmlelement("total_count"         ,    null)
                             , xmlelement("account_total"       ,    null)
                             , xmlelement("balance_impact"      ,    -1)
                           )
                       )
                   )
               )
        into l_detail
        from dual;
    end if;
    -- footer
    select
        xmlelement(
            "footer"
          , xmlelement(
                "currency_total_list",
                xmlagg(
                    xmlelement(
                        e
                      , currency_total || ';'
                    )
                ).extract ('//text()')
            )
        ) as footer
    into l_footer
    from(
        select
            com_api_currency_pkg.get_currency_name(i_curr_code =>  t3.account_currency)
            || ': ' ||
            nvl(
                com_api_currency_pkg.get_amount_str(
                    i_amount           => sum(t3.balance_impact * t3.amount)
                  , i_curr_code        => t3.account_currency
                  , i_mask_curr_code   => com_api_type_pkg.TRUE
                  , i_mask_error       => com_api_type_pkg.FALSE
                )
              , '0.00'
            ) as currency_total
        from(
            select t2.balance_impact
                 , t2.amount
                 , t2.account_currency
            from(
                select e.balance_impact
                     , e.amount
                     , e.currency as entry_currency
                     , e.macros_id
                     , t1.account_currency
                     , t1.account_id
                     , t1.account_number
                     , t1.balance_impact_multiply
                from(
                    select a.id as account_id
                         , a.account_number
                         , a.currency as account_currency
                         , b.balance_type
                         , bim.balance_impact_multiply
                    from acc_account a
                       , acc_balance b
                       , (
                          select  1 as balance_impact_multiply from dual
                          union all
                          select -1 from dual
                         ) bim
                    where a.account_type  = acc_api_const_pkg.ACCOUNT_TYPE_MERCHANT
                      and a.inst_id       = i_inst_id
                      and a.customer_id   = l_customer_id
                      and b.account_id    = a.id
                      and b.balance_type in (
                                             acc_api_const_pkg.BALANCE_TYPE_LEDGER
                                           , acc_api_const_pkg.BALANCE_TYPE_DEPOSIT
                                            )
                ) t1
                , acc_entry e
            where 1=1
              and e.account_id(+)      = t1.account_id
              and e.posting_date(+)   >= trunc(l_start_date)
              and e.posting_date(+)   <  trunc(l_end_date) + 1
              and e.balance_type(+)    = t1.balance_type
              and e.balance_impact(+)  = t1.balance_impact_multiply
              and e.status(+)         != acc_api_const_pkg.ENTRY_STATUS_CANCELED
            ) t2
        ) t3
        group by t3.account_currency
    ) t4;


    select 
        xmlelement(
            "report"
          , l_header
          , l_detail
          , l_footer
        ) r
     into l_result
     from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
         i_text => 'Financial report on acquiring activity - Executed'
    );
exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end acquiring_activity_report;

function get_merchant_data(
    i_merchant_id          com_api_type_pkg.t_short_id
) return varchar2 is
begin
    return g_merch_tab(i_merchant_id);
end get_merchant_data;

procedure acq_merchant_activity_report(
    o_xml                  out clob
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_merchant_number   in     com_api_type_pkg.t_name        default null
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value  default null
) is
    l_institution          com_api_type_pkg.t_full_desc;
    l_merchant_id          com_api_type_pkg.t_short_id;
    l_start_date           date                             := trunc(i_start_date);
    l_end_date             date                             := trunc(i_end_date + 1) - 1 / 24 / 60 / 60;
    l_header               xmltype;
    l_detail               xmltype;
    l_footer               xmltype;
    l_result               xmltype;
    l_split_hash           com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(
        i_text  => 'acq_api_report_pkg.acq_merchant_activity_report: i_inst_id [' || i_inst_id
                   || '], i_merchant_number ['  || i_merchant_number
                   || '], i_start_date ['       || i_start_date
                   || '], i_end_date ['         || i_end_date
                   || ']'
    );

    l_institution := i_inst_id || ' ' || get_text(i_table_name => 'ost_institution', i_column_name => 'name', i_object_id => i_inst_id);

    if i_merchant_number is not null then
        acq_api_merchant_pkg.get_merchant(
              i_inst_id         => i_inst_id
            , i_merchant_number => i_merchant_number
            , o_merchant_id     => l_merchant_id
            , o_split_hash      => l_split_hash
      );
    end if;

    -- header
    select xmlelement(
               "header"
             , xmlelement("institution"     , l_institution)
             , xmlelement("start_date"      , to_char(l_start_date, 'dd.mm.yyyy'))
             , xmlelement("end_date"        , to_char(l_end_date, 'dd.mm.yyyy'))
           )
    into l_header
    from dual;

    for rec in (
        select merchant_id
             , currency_total
        from (
            select merchant_id
                 , com_api_currency_pkg.get_currency_name(i_curr_code =>  t3.account_currency)
                   || ': ' ||
                   nvl(
                       com_api_currency_pkg.get_amount_str(
                           i_amount           => sum(t3.balance_impact * t3.amount)
                           , i_curr_code        => t3.account_currency
                           , i_mask_curr_code   => com_api_type_pkg.TRUE
                           , i_mask_error       => com_api_type_pkg.FALSE
                       )
                       , '0.00'
                   ) as currency_total
            from(
                select t2.balance_impact
                     , t2.amount
                     , t2.account_currency
                     , t2.merchant_id
                from(
                    select e.balance_impact
                         , e.amount
                         , e.currency as entry_currency
                         , e.macros_id
                         , t1.account_currency
                         , t1.account_id
                         , t1.account_number
                         , t1.balance_impact_multiply
                         , t1.merchant_id
                    from(
                        select a.id as account_id
                             , a.account_number
                             , a.currency as account_currency
                             , b.balance_type
                             , bim.balance_impact_multiply
                             , ao.object_id as merchant_id
                        from acc_account a
                           , acc_balance b
                           , (
                              select  1 as balance_impact_multiply from dual
                              union all
                              select -1 from dual
                             ) bim
                           , acc_account_object ao
                        where a.account_type  = acc_api_const_pkg.ACCOUNT_TYPE_MERCHANT
                          and a.inst_id       = i_inst_id
                          and ao.entity_type  = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                          and b.account_id    = a.id
                          and a.id            = ao.account_id
                          and b.balance_type in (
                                                 acc_api_const_pkg.BALANCE_TYPE_LEDGER
                                               , acc_api_const_pkg.BALANCE_TYPE_DEPOSIT
                                                )
                          and (
                                  l_merchant_id is not null and ao.object_id = l_merchant_id
                               or l_merchant_id is null
                              )
                    ) t1
                    , acc_entry e
                where 1=1
                  and e.account_id(+)      = t1.account_id
                  and e.posting_date(+)   >= trunc(l_start_date)
                  and e.posting_date(+)   <  trunc(l_end_date) + 1
                  and e.balance_type(+)    = t1.balance_type
                  and e.balance_impact(+)  = t1.balance_impact_multiply
                  and e.status(+)         != acc_api_const_pkg.ENTRY_STATUS_CANCELED
                ) t2
            ) t3
            group by t3.merchant_id
                   , t3.account_currency
        ) t4
    )
    loop if g_merch_tab.exists(rec.merchant_id) then
            g_merch_tab(rec.merchant_id) := g_merch_tab(rec.merchant_id) || ';' || rec.currency_total;
         else
            g_merch_tab(rec.merchant_id) := rec.currency_total;
         end if;
    end loop;

    -- detail
    select xmlelement(
               "details"
             , xmlagg(
                   xmlelement(
                       "detail"
                     , xmlelement("merchant"              , merchant)
                     , xmlelement("account_number"        , account_number)
                     , xmlelement("account_currency"      , com_api_currency_pkg.get_currency_name(i_curr_code => account_currency))
                     , xmlelement("funds_flow"            , funds_flow)
                     , xmlelement("total_amount"          , com_api_currency_pkg.get_amount_str(
                                                                i_amount           => total_amount
                                                              , i_curr_code        => account_currency
                                                              , i_mask_curr_code   => com_api_type_pkg.TRUE
                                                              , i_mask_error       => com_api_type_pkg.FALSE
                                                            )
                       )
                     , xmlelement("total_count"           , total_count)
                     , xmlelement("account_total"         , com_api_currency_pkg.get_amount_str(
                                                                i_amount           => account_total
                                                              , i_curr_code        => account_currency
                                                              , i_mask_curr_code   => com_api_type_pkg.TRUE
                                                              , i_mask_error       => com_api_type_pkg.FALSE
                                                            )
                       )
                     , xmlelement("balance_impact"        , balance_impact)
                     , xmlelement("currency_total_list"   , get_merchant_data(merchant_id))
            )
        )
    )
    into l_detail
    from(
        select account_number
             , account_currency
             , nvl(funds_flow, 'N/A') as funds_flow
             , sum(amount_signed) as total_amount
             , nvl2(funds_flow, count(1), null) as total_count
             , nvl2(funds_flow, sum(sum(amount_signed)) over(partition by account_number, account_currency), null) as account_total
             , balance_impact
             , merchant
             , merchant_id
        from(
            select t3.account_number                                    as account_number
                 , t3.account_currency                                  as account_currency
                 , nvl(t3.balance_impact, t3.balance_impact_multiply)   as balance_impact
                 , nvl((t3.balance_impact * t3.amount), 0)              as amount_signed
                 , case
                       when t3.amount_purpose like 'FETP%' then
                            get_article_text(i_article => t3.amount_purpose)
                       when t3.fee_id is not null then
                            get_text(i_table_name => 'com_dictionary', i_column_name => 'name', i_object_id => t3.fee_id)
                       else com_api_dictionary_pkg.get_article_text(o.oper_type) || decode(o.is_reversal, 1, ' reversal')
                   end                                                  as funds_flow
                 , t3.merchant                                          as merchant
                 , t3.merchant_id                                       as merchant_id
            from(
                select m.amount_purpose
                     , m.object_id
                     , m.fee_id
                     , t2.balance_impact
                     , t2.amount
                     , t2.account_currency
                     , t2.account_number
                     , t2.balance_impact_multiply
                     , t2.merchant
                     , t2.merchant_id
                from(
                    select e.balance_impact
                         , e.amount
                         , e.currency as entry_currency
                         , e.macros_id
                         , t1.account_currency
                         , t1.account_id
                         , t1.account_number
                         , t1.balance_impact_multiply
                         , t1.merchant
                         , t1.merchant_id
                    from(
                        select a.id as account_id
                             , a.account_number
                             , a.currency as account_currency
                             , b.balance_type
                             , bim.balance_impact_multiply
                             , m.merchant_number || ' ' || m.merchant_name as merchant
                             , m.id as merchant_id
                        from acc_account a
                           , acc_balance b
                           , (
                              select  1 as balance_impact_multiply from dual
                              union all
                              select -1 from dual
                             ) bim
                           , acc_account_object ao
                           , acq_merchant m
                        where a.account_type  = acc_api_const_pkg.ACCOUNT_TYPE_MERCHANT
                          and a.inst_id       = i_inst_id
                          and ao.entity_type  = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                          and a.id            = ao.account_id
                          and b.account_id    = a.id
                          and b.balance_type in (
                                                 acc_api_const_pkg.BALANCE_TYPE_LEDGER
                                               , acc_api_const_pkg.BALANCE_TYPE_DEPOSIT
                                                )
                          and (
                                  l_merchant_id is not null and ao.object_id = l_merchant_id
                               or l_merchant_id is null
                              )

                          and m.id = ao.object_id
                    ) t1
                    , acc_entry e
                    where 1=1
                      and e.account_id(+)      = t1.account_id
                      and e.posting_date(+)   >= trunc(l_start_date)
                      and e.posting_date(+)   <  trunc(l_end_date) + 1
                      and e.balance_type(+)    = t1.balance_type
                      and e.balance_impact(+)  = t1.balance_impact_multiply
                      and e.status(+)         != acc_api_const_pkg.ENTRY_STATUS_CANCELED
                ) t2
                , acc_macros m
                where 1=1
                  and m.account_id(+)      = t2.account_id
                  and m.entity_type(+)     = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                  and m.id(+)              = t2.macros_id
            ) t3
            , opr_operation o
            where t3.object_id = o.id(+)
        ) t4
        group by
            merchant_id
          , merchant
          , account_number
          , account_currency
          , funds_flow
          , balance_impact
        order by
            merchant
          , account_number
          , account_currency
          , balance_impact desc
          , funds_flow
    ) t5;

    select
      xmlelement(
          "report"
          , l_header
          , l_detail
      ) r
    into l_result
    from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
        i_text => 'Financial report on merchant activity - Executed'
    );
exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end acq_merchant_activity_report;

end acq_api_report_pkg;
/
