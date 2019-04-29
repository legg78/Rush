create or replace package body rus_api_report_pkg is
/*********************************************************
 *  Api for some reports  <br />
 *  Created by Kopachev D.(kopachev@bpcbt.com)  at 03.02.2012 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: rus_api_report_pkg <br />
 *  @headcom
 **********************************************************/

C_SORT_OPEN_GROUP_OPEN    constant com_api_type_pkg.t_tiny_id := 1;
C_SORT_CLOSE_GROUP_CLOSE  constant com_api_type_pkg.t_tiny_id := 2;
C_SORT_OPEN_NOT_GROUP     constant com_api_type_pkg.t_tiny_id := 3;
C_SORT_CLOSE_NOT_GROUP    constant com_api_type_pkg.t_tiny_id := 4;

function get_data(
    i_report_name   in    com_api_type_pkg.t_name
  , i_balances      in    num_tab_tpt
  , i_lang          in    com_api_type_pkg.t_dict_value
  , i_sort_group    in    com_api_type_pkg. t_tiny_id    default 0
) return xmltype is
l_result xmltype;
begin
    select
        xmlagg(
            xmlelement("account",
                xmlelement("report_name", i_report_name)
              , xmlelement("acc_open_date", nvl(to_char(t.open_date, 'dd/mm/yyyy'),' '))
              , xmlelement("acc_close_date", nvl(to_char(t.close_date, 'dd/mm/yyyy'),' '))
              , xmlelement("contract_date_number"
                  , nvl(decode(fee_flag, 1, '-', to_char(t.start_date, 'dd/mm/yyyy')||' '||t.contract_number), ' ') )
              , xmlelement("client_name", nvl(decode(fee_flag, 1, '-', t.client_name), ' ') )
              , xmlelement("account_name", nvl(get_article_desc(t.account_name, i_lang), ' ') )
              , xmlelement("account_number", nvl(t.account_number, ' ') )
              , xmlelement("statement_creation"
                    ,  nvl(decode(fee_flag, 1, '-'
                           , get_article_text(statement_creation_form, i_lang)
                             ||' '||
                             get_article_text(statement_creation_periodicity, i_lang)
                          ), ' '
                     )
                )
              , xmlelement("fiscal_notify_open",  nvl(decode(fee_flag, 1, '-', fiscal_notify_open ),' ' ) )
              , xmlelement("fiscal_notify_close", nvl(decode(fee_flag, 1, '-', fiscal_notify_close ), ' ') )
              , xmlelement("label", nvl( (select stragg(n.text) 
                                            from ntb_ui_note_vw  n
                                           where n.entity_type = 'ENTTACCT'
                                             and n.note_type   = 'NTTPRSTR' 
                                             and n.object_id   = t.account_id
                                             and n.lang        = i_lang)
                                        , ' '))
              , xmlelement("group_date"
                  , decode(i_sort_group
                      , C_SORT_OPEN_GROUP_OPEN,   to_char(t.open_date,  'dd/mm/yyyy')
                      , C_SORT_CLOSE_GROUP_CLOSE, to_char(t.close_date, 'dd/mm/yyyy')
                      , 0, ''
                      , ''
                    )
                )
            )
       )
  into l_result
  from (select b.open_date
             , b.close_date
             , n.start_date
             , n.contract_number
             , case n.contract_type
               when 'CNTPBANK'
               then com_ui_person_pkg.get_person_name(i_person_id => c.object_id, i_lang => i_lang)
               when 'CNTPEWLT'
               then c.customer_number
               else '-'
               end
               as client_name
             , decode(b.balance_type, acc_api_const_pkg.BALANCE_TYPE_LEDGER, a.account_type, b.balance_type) account_name
             , nvl(b.balance_number, a.account_number) as account_number
             , case when substr(nvl(b.balance_number, a.account_number),1,5) in ('47422', '47423') 
                    then 1 else 0 end as fee_flag
             , b.id
             , com_api_flexible_data_pkg.get_flexible_value (
                  i_field_name   => 'STATEMENT_CREATION_FORM'
                , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                , i_object_id    => a.id
               ) statement_creation_form
             , com_api_flexible_data_pkg.get_flexible_value (
                  i_field_name   => 'STATEMENT_CREATION_PERIODICITY'
                , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                , i_object_id    => a.id
               ) as statement_creation_periodicity
             , '-' fiscal_notify_open
             , '-' fiscal_notify_close
             , a.id account_id
          from table(cast(i_balances as num_tab_tpt))x
             , acc_balance b
             , acc_account a
             , prd_customer_vw c
             , prd_contract n
         where x.column_value = b.id
           and a.account_type in (select element_value from com_array_element_vw where array_id = 50000003)
           and a.id           = b.account_id
           and c.id(+)        = a.customer_id
           and n.id(+)        = a.contract_id
      order by decode(i_sort_group
          , C_SORT_OPEN_GROUP_OPEN,   trunc(open_date)
          , C_SORT_CLOSE_GROUP_CLOSE, trunc(close_date)
          , C_SORT_OPEN_NOT_GROUP,    trunc(open_date)
          , C_SORT_CLOSE_NOT_GROUP,   trunc(close_date)
          , 0, ''
        )
      , nvl(b.balance_number, a.account_number)
    ) t
    ;
    return l_result;
end;

procedure run_report_acc (
    o_xml                  out clob
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_mode              in     com_api_type_pkg.t_dict_value
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_start_date        in     date                              default null
  , i_end_date          in     date                              default null
  , i_agent_id          in     com_api_type_pkg.t_agent_id       default null
  , i_currency          in     com_api_type_pkg.t_curr_code
  , i_balance_number    in     com_api_type_pkg.t_name           default null
) is
    l_header           xmltype;
    l_details          xmltype;
    l_details2         xmltype;
    l_result           xmltype;

    l_start_date       date;
    l_end_date         date;
    l_opened           num_tab_tpt;
    l_closed           num_tab_tpt;
begin
    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate-1));
    l_end_date   := nvl(trunc(i_end_date), l_start_date) + 1 - 1/(24*60*60);

    trc_log_pkg.debug (
        i_text       => 'Registry of account opening and closing [#1][#2][#3][#4][#5]'
      , i_env_param1 => to_char(l_start_date, 'dd/mm/yyyy hh24:mi:ss')
      , i_env_param2 => to_char(l_end_date,   'dd/mm/yyyy hh24:mi:ss')
      , i_env_param3 => nvl(i_balance_number, '%')
      , i_env_param4 => i_lang
      , i_env_param5 => get_article_text(i_mode, i_lang)
    );

    select xmlelement("subject"
             , xmlelement("bank_name", get_text('ost_institution', 'name', i_inst_id, i_lang))
             , xmlelement("report_name", get_article_text(i_mode, i_lang))
             , xmlelement("start_date", to_char(l_start_date, 'dd/mm/yyyy'))
             , xmlelement("end_date", to_char(l_end_date, 'dd/mm/yyyy'))
           )
      into l_header
      from dual;

    case i_mode
    when 'MRACOEND' then
        select b.id
          bulk collect into l_opened
          from acc_balance b
             , acc_account a
         where b.account_id = a.id
           and a.currency     = i_currency
           and b.inst_id      = i_inst_id
           and a.agent_id     = nvl(i_agent_id, a.agent_id)
           and b.balance_type in (select element_value from com_array_element_vw where array_id = 2)
           and b.open_date   <= l_end_date
           and (b.close_date  > l_end_date or b.close_date is null)
           and nvl(b.balance_number, a.account_number) like nvl(i_balance_number, '%');

        l_details := get_data(
            i_report_name  => get_article_text(i_mode, i_lang)
          , i_balances     => l_opened
          , i_lang         => i_lang
          , i_sort_group   => C_SORT_OPEN_GROUP_OPEN
        );
        
    when 'MRACOPEN' then
        select b.id
          bulk collect into l_opened
          from acc_balance b
             , acc_account a
         where b.account_id = a.id
           and a.currency     = i_currency
           and b.inst_id      = i_inst_id
           and a.agent_id     = nvl(i_agent_id, a.agent_id)
           and b.balance_type in (select element_value from com_array_element_vw where array_id = 2)
           and b.open_date between l_start_date and l_end_date
           and nvl(b.balance_number, a.account_number) like nvl(i_balance_number, '%');
        
        l_details := get_data(
            i_report_name  => get_article_text(i_mode, i_lang)
          , i_balances     => l_opened
          , i_lang         => i_lang
          , i_sort_group   => C_SORT_OPEN_GROUP_OPEN
        );
        
    when 'MRACCLOS' then
        select b.id
          bulk collect into l_closed
          from acc_balance b
             , acc_account a
         where b.account_id = a.id
           and a.currency     = i_currency
           and b.inst_id      = i_inst_id
           and a.agent_id     = nvl(i_agent_id, a.agent_id)
           and b.balance_type in (select element_value from com_array_element_vw where array_id = 2)
           and b.close_date between l_start_date and l_end_date
           and nvl(b.balance_number, a.account_number) like nvl(i_balance_number, '%');

        l_details := get_data(
            i_report_name  => get_article_text(i_mode, i_lang)
          , i_balances     => l_closed
          , i_lang         => i_lang
          , i_sort_group   => C_SORT_CLOSE_GROUP_CLOSE
        );

    when 'MRACOPCL' then
        select b.id
          bulk collect into l_opened
          from acc_balance b
             , acc_account a
         where b.account_id = a.id
           and a.currency     = i_currency
           and b.inst_id      = i_inst_id
           and a.agent_id     = nvl(i_agent_id, a.agent_id)
           and b.balance_type in (select element_value from com_array_element_vw where array_id = 2)
           and b.open_date   >= l_start_date 
           and b.open_date   <= l_end_date
           and (b.close_date >= l_start_date or b.close_date is null)
           and nvl(b.balance_number, a.account_number) like nvl(i_balance_number, '%');
           trc_log_pkg.debug('found '||sql%rowcount||' opened accounts');

        l_details := get_data(
            i_report_name  => get_article_text('MRACOEND', i_lang)
          , i_balances     => l_opened
          , i_lang         => i_lang
          , i_sort_group   => C_SORT_OPEN_GROUP_OPEN
        );
        
        select b.id
          bulk collect into l_closed
          from acc_balance b
             , acc_account a
         where b.account_id = a.id
           and a.currency     = i_currency
           and b.inst_id      = i_inst_id
           and a.agent_id     = nvl(i_agent_id, a.agent_id)
           and b.balance_type in (select element_value from com_array_element_vw where array_id = 2)
           and b.close_date is not null
           and b.close_date  >= l_start_date 
           and b.close_date  <= l_end_date
           and nvl(b.balance_number, a.account_number) like nvl(i_balance_number, '%');
           trc_log_pkg.debug('found '||sql%rowcount||' closed accounts');
           
        l_details2 := get_data(
            i_report_name  => get_article_text('DICTMRAC', i_lang)
          , i_balances     => l_closed
          , i_lang         => i_lang
          , i_sort_group   => C_SORT_CLOSE_GROUP_CLOSE
        );
        if l_details2 is not null then
            select xmlconcat(l_details, l_details2)
              into l_details
              from dual;
        end if;
    else
        null;
    end case;

    select xmlelement("report",
               l_header
             , xmlelement("accounts", nvl(l_details, xmlelement("account", '')) )
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();
exception
    when others then
        trc_log_pkg.debug (
            i_text => sqlerrm
        );
        com_api_error_pkg.raise_fatal_error(
            i_error => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );

end;

end;
/
