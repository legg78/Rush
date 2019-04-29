create or replace package body cst_amk_report_pkg as

procedure agents_awarding(
    o_xml                  out clob 
  , i_start_date        in     date
  , i_end_date          in     date
  , i_inst_id           in     com_api_type_pkg.t_inst_id        default null
  , i_lang              in     com_api_type_pkg.t_dict_value 
) is
    l_start_date        date;
    l_end_date          date;
    l_lang              com_api_type_pkg.t_dict_value;

    l_header            xmltype;
    l_detail            xmltype;
    l_result            xmltype; 
begin
    trc_log_pkg.debug (
        i_text        => 'cst_amk_report_pkg.agents_awarding [#1][#2][#3][#4]'
      , i_env_param1  => i_lang
      , i_env_param2  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
      , i_env_param3  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - (1/86400))
      , i_env_param4  => i_inst_id
    );

    l_start_date := trunc( nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate) );
    l_end_date   := nvl( trunc(i_end_date), l_start_date ) + 1 - (1/86400);
    l_lang       := nvl( i_lang, get_user_lang );

    -- header
    select xmlelement ( "header",
                 xmlelement( "p_date_start" , to_char(l_start_date, 'dd.mm.yyyy') )
               , xmlelement( "p_date_end"   , to_char(l_end_date, 'dd.mm.yyyy'  ) )
               , xmlelement( "p_inst_id"    , decode (i_inst_id, null, '0'
                                                     ,i_inst_id||' - '||get_text('OST_INSTITUTION','NAME', i_inst_id, l_lang) )
                           )
           )
    into l_header from dual ;

    -- details 
    select xmlelement("table"
             , xmlagg(
                   xmlelement("record"
                     , xmlelement("agent_id", a.agent_id)
                     , xmlelement("agent_account_number", a.agent_account_number)
                     , xmlelement("currency", c.name)
                     , xmlelement("awarding_amount", round(sum(awarding_amount / power(10, c.exponent)), 2))
                     , xmlelement("agent_type", a.agent_type)
                     , xmlelement("agent_name", nvl(a.agent_name,' '))
                   )
               )
           )
      into l_detail
      from cst_amk_agents a
         , com_currency c
     where (a.inst_id = i_inst_id or i_inst_id is null)
       and a.open_date between l_start_date and l_end_date
       and a.currency = c.code
       and a.account_id is not null
  group by a.agent_id
         , a.agent_account_number
         , c.name
         , a.agent_type
         , nvl(a.agent_name,' ');
       
    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table"
                 , xmlagg(
                       xmlelement("record"
                     , xmlelement("agent_id", null)
                     , xmlelement("agent_account_number", null)
                     , xmlelement("currency", null)
                     , xmlelement("awarding_amount", null)
                     , xmlelement("agent_type", null)
                     , xmlelement("agent_name", null)
                   )
               )
           )
        into l_detail from dual;
    end if;

    select xmlelement ( "report"
             , l_header
             , l_detail
           )
    into l_result from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(i_text => 'cst_amk_report_pkg.agents_awarding - ok');

exception when others then
    trc_log_pkg.debug (i_text => sqlerrm);
    raise ; 
end agents_awarding;

procedure agents_bonus_awarding(
    o_xml                  out clob 
  , i_start_date        in     date
  , i_end_date          in     date
  , i_inst_id           in     com_api_type_pkg.t_inst_id        default null
  , i_lang              in     com_api_type_pkg.t_dict_value 
) is
    l_start_date        date;
    l_end_date          date;
    l_lang              com_api_type_pkg.t_dict_value;

    l_header            xmltype;
    l_detail            xmltype;
    l_result            xmltype; 
begin
    trc_log_pkg.debug (
        i_text        => 'cst_amk_report_pkg.agents_bonus_awarding [#1][#2][#3][#4]'
      , i_env_param1  => i_lang
      , i_env_param2  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
      , i_env_param3  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - (1/86400))
      , i_env_param4  => i_inst_id
    );

    l_start_date := trunc( nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate) );
    l_end_date   := nvl( trunc(i_end_date), l_start_date ) + 1 - (1/86400);
    l_lang       := nvl( i_lang, get_user_lang );

    -- header
    select xmlelement ( "header",
                 xmlelement( "p_date_start" , to_char(l_start_date, 'dd.mm.yyyy') )
               , xmlelement( "p_date_end"   , to_char(l_end_date, 'dd.mm.yyyy'  ) )
               , xmlelement( "p_inst_id"    , decode (i_inst_id, null, '0'
                                                     ,i_inst_id||' - '||get_text('OST_INSTITUTION','NAME', i_inst_id, l_lang) )
                           )
           )
    into l_header from dual ;

    -- details 
    select xmlelement("table"
             , xmlagg(
                   xmlelement("record"
                     , xmlelement("agent_id", a.agent_id)
                     , xmlelement("agent_account_number", a.agent_account_number)
                     , xmlelement("currency", c.name)
                     , xmlelement("awarding_amount", round(sum(a.bonus / power(10, c.exponent)), 2))
                     , xmlelement("agent_type", a.agent_type)
                     , xmlelement("agent_name", nvl(a.agent_name,' '))
                   )
               )
           )
      into l_detail
      from cst_amk_agents a
         , com_currency c
     where (a.inst_id = i_inst_id or i_inst_id is null)
       and a.open_date between l_start_date and l_end_date
       and a.currency = c.code
       and a.account_id is null
  group by a.agent_id
         , a.agent_account_number
         , c.name
         , a.agent_type
         , nvl(a.agent_name,' ');
       
    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table"
                 , xmlagg(
                       xmlelement("record"
                     , xmlelement("agent_id", null)
                     , xmlelement("agent_account_number", null)
                     , xmlelement("currency", null)
                     , xmlelement("awarding_amount", null)
                     , xmlelement("agent_type", null)
                     , xmlelement("agent_name", null)
                   )
               )
           )
        into l_detail from dual;
    end if;

    select xmlelement ( "report"
             , l_header
             , l_detail
           )
    into l_result from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug (i_text => 'cst_amk_report_pkg.agents_bonus_awarding - ok');

exception when others then
    trc_log_pkg.debug (i_text => sqlerrm);
    raise ; 
end agents_bonus_awarding;

end;
/
