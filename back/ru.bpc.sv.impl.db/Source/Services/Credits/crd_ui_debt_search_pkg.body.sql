create or replace package body crd_ui_debt_search_pkg is

procedure get_ref_cur_base(
    o_ref_cur              out  com_api_type_pkg.t_ref_cur
  , o_row_count            out  com_api_type_pkg.t_tiny_id
  , i_first_row         in      com_api_type_pkg.t_tiny_id
  , i_last_row          in      com_api_type_pkg.t_tiny_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt
  , i_is_first_call     in      com_api_type_pkg.t_boolean
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_ref_cur_base';
    CRLF               constant com_api_type_pkg.t_name := chr(13) || chr(10);
    
    COLUMN_LIST        constant com_api_type_pkg.t_text :=
    'select dbt.id'                  ||
         ', dbt.account_id'          ||   
         ', dbt.card_id'             ||
         ', dbt.product_id'          ||
         ', dbt.service_id'          ||
         ', dbt.oper_id'             ||
         ', dbt.oper_type'           ||
         ', dbt.sttl_type'           ||   
         ', dbt.fee_type'            ||   
         ', dbt.terminal_type'       ||   
         ', dbt.oper_date'           ||
         ', dbt.posting_date'        ||   
         ', dbt.sttl_day'            ||
         ', dbt.currency'            ||   
         ', dbt.amount'              ||
         ', dbt.debt_amount'         ||
         ', dbt.mcc'                 ||
         ', dbt.aging_period'        ||   
         ', dbt.is_new'              ||   
         ', dbt.status'              ||
         ', dbt.inst_id'             ||
         ', dbt.agent_id'            ||
         ', dbt.split_hash'          ||
         ', a.account_number'        ||
         ', c.card_mask'             ||
         ', iss_api_token_pkg.decode_card_number(i_card_number => n.card_number) as card_number' ||
         ', m.amount_purpose'        ||   
         ', dbt.macros_type_id'      ||
         ', get_text(''ost_institution'', ''name'', dbt.inst_id, p_lang) inst_name'    ||
         ', get_text(''ost_agent'', ''name'', dbt.agent_id, p_lang) agent_name'        ||
         ', get_text(''prd_product'', ''label'', p.id, p_lang) product_name'           ||
         ', get_text(''prd_service'', ''label'', dbt.service_id, p_lang) service_name' ||
         ', p.product_number'                                                           ||
         ', ost_ui_agent_pkg.get_agent_number(dbt.agent_id) agent_number'               ||
         ', get_text(''acc_macros_type'', ''name'', dbt.macros_type_id, p_lang) macros_type_name'  ||
         ', (select max(sttl_date) from com_settlement_day where dbt.sttl_day = sttl_day) sttl_date ' ||
         ', (select nvl(sum(cp.amount), 0) from crd_payment cp where cp.original_oper_id = dbt.oper_id and cp.is_reversal = 1) reverted_amount '         
        ;

    l_ref_source            com_api_type_pkg.t_text :=
     ' from crd_debt dbt'                               ||
         ', prd_product p'                              ||
         ', acc_macros m'                               ||
         ', iss_card_number n'                          ||
         ', iss_card c'                                 ||
         ', acc_account a'                              ||
         ', (select :p_inst_id p_inst_id'               ||
                 ', :p_card_number p_card_number'       ||
                 ', :p_oper_type p_oper_type'           ||
                 ', :p_status p_status'                 ||
                 ', :p_account_number p_account_number' ||
                 ', :p_date_from p_date_from'           ||
                 ', :p_date_to p_date_to'               ||
                 ', :p_is_new p_is_new '                ||
                 ', :p_account_id p_account_id'         ||
                 ', :p_card_id p_card_id'               ||
                 ', :p_lang p_lang '                    ||
              'from dual) x '                           ||
     'where dbt.product_id = p.id '                     ||
       'and dbt.id = m.id(+) '                          ||
       'and dbt.card_id = n.card_id(+) '                ||
       'and dbt.card_id = c.id(+) '                     ||
       'and a.id = dbt.account_id';

    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_card_number               com_api_type_pkg.t_card_number;
    l_oper_type                 com_api_type_pkg.t_dict_value;
    l_status                    com_api_type_pkg.t_dict_value;
    l_account_number            com_api_type_pkg.t_name;
    l_date_from                 date;
    l_date_to                   date;
    l_is_new                    com_api_type_pkg.t_boolean;
    l_account_id                com_api_type_pkg.t_medium_id;
    l_card_id                   com_api_type_pkg.t_medium_id;

    l_privil_limitation         com_api_type_pkg.t_full_desc;
    l_sorting_source            com_api_type_pkg.t_text;

    function get_sorting_param return com_api_type_pkg.t_name
    is
        l_result            com_api_type_pkg.t_name;
    begin
        select nvl2(list, 'order by '||list, '')
          into l_result
          from (select rtrim(xmlagg(xmlelement(e,name||' '||char_value,',').extract('//text()')),',') list
                  from table(cast(i_sorting_tab as com_param_map_tpt))
               );

        return l_result;
    exception
        when no_data_found then
            return null;
        when others then
            trc_log_pkg.debug(LOG_PREFIX || '->get_sorting_param FAILED, l_result [' || l_result || ']; '
                                         || 'dumping i_sorting_tab for debug...');
            utl_data_pkg.print_table(i_param_tab => i_sorting_tab); -- dumping collection, DEBUG logging level is required
            raise;
    end get_sorting_param;

    -- This function does NOT return a param value, it returns string for filtering condition like 'p_card_number'
    function get_string(
        i_param_name        in      com_api_type_pkg.t_name
      , i_is_format         in      com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_name is
        l_result            com_api_type_pkg.t_name;
    begin
        select
          case
              --------------------------------------------------------------
              when i_is_format = com_api_const_pkg.FALSE then
                  'p_'||lower(i_param_name)
              --------------------------------------------------------------
              when date_value is not null then
                  ' and '||lower(i_param_name)||' '||nvl(condition, '=')||' p_'||lower(i_param_name)
              when char_value is not null and substr(char_value, 1, 1) = '%' then
                  ' and reverse(lower(nvl('||lower(i_param_name)||',''%''))) '||nvl(condition, 'like')||' reverse(lower(p_'||lower(i_param_name)||'))'
              when char_value is not null and instr(char_value, '%') != 0 then
                  ' and lower(nvl('||lower(i_param_name)||',''%'')) '||nvl(condition, 'like')||' lower(p_'||lower(i_param_name)||')'
              when char_value is not null then
                  ' and lower('||lower(i_param_name)||') '||nvl(condition, '=')||' lower(p_'||lower(i_param_name)||')'
              when number_value is not null then
                  ' and '||lower(i_param_name)||' '||nvl(condition, '=')||' p_'||lower(i_param_name)
              else null
          end
          into l_result
          from table(cast(i_param_tab as com_param_map_tpt))
         where name = i_param_name;

         return l_result;
    exception
        when no_data_found then
            return null;
        when others then
            trc_log_pkg.debug(LOG_PREFIX || '->get_string FAILED with i_param_name [' || i_param_name ||']');
            raise;
    end get_string;

    function get_char_value(
        i_param_name        in      com_api_type_pkg.t_name
    ) return com_api_type_pkg.t_name is
        l_result            com_api_type_pkg.t_name;
    begin
        select char_value
          into l_result
          from table(cast(i_param_tab as com_param_map_tpt))
         where name = i_param_name;

         return l_result;
    exception
        when no_data_found then
            return null;
         when others then
            trc_log_pkg.debug(LOG_PREFIX || '->get_char_value FAILED with i_param_name ['||i_param_name||']');
            raise;
    end get_char_value;

    function get_date_value(
        i_param_name        in      com_api_type_pkg.t_name
    ) return date is
        l_result            date;
    begin
        select date_value
          into l_result
          from table(cast(i_param_tab as com_param_map_tpt))
         where name = i_param_name;

         return l_result;
    exception
        when no_data_found then
            return null;
        when others then
            trc_log_pkg.debug(LOG_PREFIX || '->get_date_value FAILED with i_param_name ['||i_param_name||']');
            raise;
    end get_date_value;

    function get_number_value(
        i_param_name        in      com_api_type_pkg.t_name
    ) return number is
        l_result            number;
    begin
        select number_value
          into l_result
          from table(cast(i_param_tab as com_param_map_tpt))
         where name = i_param_name;

         return l_result;
    exception
        when no_data_found then
            return null;
        when others then
            trc_log_pkg.debug(LOG_PREFIX || '->get_number_value FAILED with i_param_name ['||i_param_name||']');
            raise;
    end get_number_value;

    function card_number_condition(
        i_field_name        in     com_api_type_pkg.t_oracle_name
    ) return com_api_type_pkg.t_name
    is
        l_result            com_api_type_pkg.t_name;
    begin
        select case
                   when iss_api_token_pkg.is_token_enabled() = com_api_type_pkg.FALSE then
                       ' and reverse(' || i_field_name || ') like reverse(x.p_card_number)'
                   else
                       ' and reverse(' || i_field_name || ')' ||
                           ' like reverse(''%'' || substr(x.p_card_number, -'||iss_api_const_pkg.LENGTH_OF_PLAIN_PAN_ENDING || '))' ||
                       ' and iss_api_token_pkg.decode_card_number(i_card_number => ' || i_field_name || ') like x.p_card_number'
               end
          into l_result
          from table(cast(i_param_tab as com_param_map_tpt)) t
         where t.name = 'CARD_NUMBER';

        trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_ref_cur_base->card_number_condition [' || l_result || ']');
        return l_result;
    end;

begin
    trc_log_pkg.debug(LOG_PREFIX || ': START with i_tab_name [' || i_tab_name
                                 || '], i_is_first_call [' || i_is_first_call || ']');
    utl_data_pkg.print_table(i_param_tab => i_param_tab); -- dumping collection, DEBUG logging level is required

    if i_tab_name != 'DEBT' then
        com_api_error_pkg.raise_error(
            i_error      => 'INVALID_TAB_NAME'
          , i_env_param1 => i_tab_name
        );
    else
        l_inst_id            := get_number_value('INST_ID');
        l_oper_type          := get_char_value('OPER_TYPE');
        l_status             := get_char_value('STATUS');
        l_account_number     := get_char_value('ACCOUNT_NUMBER');
        l_date_from          := get_date_value('DATE_FROM');
        l_date_to            := get_date_value('DATE_TO');
        l_privil_limitation  := get_char_value('PRIVIL_LIMITATION');
        l_card_number        := get_char_value('CARD_NUMBER');
        l_is_new             := get_number_value('IS_NEW');
        l_account_id         := get_number_value('ACCOUNT_ID');
        l_card_id            := get_number_value('CARD_ID');
        l_sorting_source     := get_sorting_param();

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || ':' || CRLF || 'l_inst_id [' || l_inst_id || ']' || CRLF
                         || 'l_oper_type [#1]' || CRLF
                         || 'l_status [#2]' || CRLF
                         || 'l_card_number [#3]' || CRLF
                         || 'l_account_number [' || l_account_number || ']' || CRLF
                         || 'l_date_from [' || to_char(l_date_from, com_api_const_pkg.DATE_FORMAT) || ']' || CRLF
                         || 'l_date_to [' || to_char(l_date_to, com_api_const_pkg.DATE_FORMAT) || ']' || CRLF
                         || 'l_is_new [' || l_is_new || ']' || CRLF
                         || 'l_sorting_source [' || l_sorting_source || ']' || CRLF
                         || 'l_privil_limitation [' || l_privil_limitation || ']'
          , i_env_param1 => l_oper_type
          , i_env_param2 => l_status
          , i_env_param3 => iss_api_card_pkg.get_card_mask(l_card_number)
        );

        if l_inst_id is not null then
            l_ref_source := l_ref_source || ' and dbt.inst_id = '|| get_string('INST_ID', com_api_const_pkg.FALSE);
        end if;

        if l_card_number is not null then
            l_ref_source := l_ref_source || card_number_condition(i_field_name => 'n.card_number');
        end if;

        if l_oper_type is not null then
            l_ref_source := l_ref_source || ' and dbt.oper_type = ' || get_string('OPER_TYPE', com_api_const_pkg.FALSE);
        end if;

        if l_status is not null then
            l_ref_source := l_ref_source || ' and dbt.status = ' || get_string('STATUS', com_api_const_pkg.FALSE);
        end if;

        if l_account_number is not null then
            l_ref_source := l_ref_source || get_string('ACCOUNT_NUMBER');
        end if;

        if l_date_from is not null then
            l_ref_source := l_ref_source || ' and dbt.posting_date >= p_date_from';
        end if;

        if l_date_to is not null then
            l_ref_source := l_ref_source || ' and dbt.posting_date <= p_date_to';
        end if;
    
        if l_is_new is not null then
            l_ref_source := l_ref_source || ' and dbt.is_new = p_is_new';
        end if;

        if l_account_id is not null then
            l_ref_source := l_ref_source || ' and a.id = p_account_id';
        end if;

        if l_card_id is not null then
            l_ref_source := l_ref_source || ' and c.id = p_card_id';
        end if;

    end if;

    l_ref_source := l_ref_source || ' and dbt.inst_id in (select inst_id from acm_cu_inst_vw)';

    if l_privil_limitation is not null then
        l_ref_source := l_ref_source || ' and ' || l_privil_limitation;
    end if;

    if  i_is_first_call = com_api_const_pkg.TRUE then
        execute immediate 'select count(1) '|| l_ref_source
        into o_row_count
        using
            l_inst_id
          , l_card_number
          , l_oper_type
          , l_status
          , l_account_number
          , l_date_from
          , l_date_to
          , l_is_new
          , l_account_id
          , l_card_id
          , get_char_value('LANG');
    else
        l_ref_source := 'select * from (select a.*, rownum rn from (select * from (select * from ('
                     || COLUMN_LIST || l_ref_source || ')) ' || l_sorting_source
                     || ') a) where rn between :p_first_row and :p_last_row';

        open o_ref_cur for l_ref_source
        using
            l_inst_id
          , l_card_number
          , l_oper_type
          , l_status
          , l_account_number
          , l_date_from
          , l_date_to
          , l_is_new
          , l_account_id
          , l_card_id
          , get_char_value('LANG')
          , i_first_row
          , i_last_row;
    end if;

    trc_log_pkg.debug(LOG_PREFIX || ':' || CRLF || substr(l_ref_source, 1, 3900));
    trc_log_pkg.debug(LOG_PREFIX || ': END');
exception
    when others then
        trc_log_pkg.debug(LOG_PREFIX || ': FAILED with l_ref_source:' || CRLF || substr(l_ref_source, 1, 3900));
        raise;
end;

procedure get_ref_cur(
    o_ref_cur              out  com_api_type_pkg.t_ref_cur
  , i_first_row         in      com_api_type_pkg.t_tiny_id
  , i_last_row          in      com_api_type_pkg.t_tiny_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt
) is
    l_row_count         com_api_type_pkg.t_tiny_id;
begin
    get_ref_cur_base(
        o_ref_cur           => o_ref_cur
      , o_row_count         => l_row_count
      , i_first_row         => i_first_row
      , i_last_row          => i_last_row
      , i_tab_name          => i_tab_name
      , i_param_tab         => i_param_tab
      , i_sorting_tab       => i_sorting_tab
      , i_is_first_call     => com_api_const_pkg.FALSE
    );
end;

procedure get_row_count(
    o_row_count            out  com_api_type_pkg.t_tiny_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
) is
    l_ref_cur           com_api_type_pkg.t_ref_cur;
    l_sorting_tab       com_param_map_tpt;
begin
    get_ref_cur_base(
        o_ref_cur           => l_ref_cur
      , o_row_count         => o_row_count
      , i_first_row         => null
      , i_last_row          => null
      , i_tab_name          => i_tab_name
      , i_param_tab         => i_param_tab
      , i_sorting_tab       => l_sorting_tab
      , i_is_first_call     => com_api_const_pkg.TRUE
    );
end;

procedure get_interest_details_main(
    o_ref_cur           out     com_api_type_pkg.t_ref_cur
  , o_ref_count         out     com_api_type_pkg.t_medium_id
  , i_debt_id            in     com_api_type_pkg.t_long_id
  , i_sorting_tab        in     com_param_map_tpt
  , i_is_first_call      in     com_api_type_pkg.t_boolean
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name    := lower($$PLSQL_UNIT) || '.get_interest_details_main: ';
    CRLF               constant com_api_type_pkg.t_name    := chr(13) || chr(10);
    FIRST_ELEMENT      constant com_api_type_pkg.t_boolean := 1;
    
    l_sort             com_api_type_pkg.t_name;
    
    COLUMN_LIST        constant com_api_type_pkg.t_text :=
    'select dint.id' ||
         ', dint.debt_id' ||
         ', dint.balance_type' ||
         ', dint.start_date' ||
         ', case when inv.account_id is not null and ' ||
                'crd_interest_pkg.get_interest_calc_end_date( ' ||
                  '  i_account_id => inv.account_id ' ||
                ') = ''ICEDDDUE'' then ' ||  
                 '      case trunc(inv.invoice_date) ' ||  
                 '          when trunc(dint.end_date) ' ||
                 '          then inv.due_date ' || 
                 '          else dint.end_date ' || 
                 '      end ' || 
               ' else dint.end_date ' ||
          ' end as end_date' ||
         ', round( ' ||
         '  case when inv.account_id is not null and ' ||
                     'crd_interest_pkg.get_interest_calc_end_date( ' ||
                       '  i_account_id => inv.account_id ' ||
                     ') = ''ICEDDDUE'' then ' ||  
                     '      case trunc(inv.invoice_date) ' ||  
                     '          when trunc(dint.end_date) ' ||
                     '          then inv.due_date ' || 
                     '          else dint.end_date ' || 
                     '      end ' ||
                    ' else dint.end_date ' ||
               ' end - dint.start_date, 4) duration ' ||
         ', dint.amount' ||
         ', dint.min_amount_due' ||
         ', dint.interest_amount' ||
         ', dint.fee_id' ||
         ', crd_cst_interest_pkg.get_fee_desc(i_debt_intr_id => dint.id, i_fee_id => dint.fee_id) fee_desc' ||
         ', dint.add_fee_id' ||
         ', fcl_ui_fee_pkg.get_fee_desc(i_fee_id => dint.add_fee_id) add_fee_desc' ||
         ', dint.is_charged' ||
         ', dint.is_grace_enable' ||
         ', dint.invoice_id' ||
         ', dint.split_hash' ||
         ', inv.invoice_date' ||
         ', d.currency' ||
         ', d.oper_id' ||
         ', d.oper_type' ||
         ', d.oper_date' ||
         ', dint.is_waived'
        ;

    l_ref_source                com_api_type_pkg.t_text :=
        'from (' ||
               'select * ' ||
                 'from (' ||
                        'select id' ||
                             ', debt_id' ||
                             ', balance_type' ||
                             ', balance_date start_date' ||
                             ', lead(balance_date) over (partition by balance_type order by posting_order, balance_date, id) end_date' ||
                             ', amount' ||
                             ', min_amount_due' ||
                             ', interest_amount' ||
                             ', fee_id' ||
                             ', add_fee_id' ||
                             ', is_charged' ||
                             ', is_grace_enable' ||
                             ', invoice_id' ||
                             ', split_hash ' ||
                             ', is_waived ' ||
                          'from crd_debt_interest' ||
                             ', (select :p_debt_id p_debt_id from dual) p ' ||
                         'where debt_id = p.p_debt_id' ||
                 ') ' ||
                'where interest_amount > 0' ||
        ') dint' ||
        ', crd_invoice inv' ||
        ', crd_debt d ' ||
    'where dint.invoice_id = inv.id(+) ' ||
      'and dint.debt_id = d.id'
    ;

begin
    trc_log_pkg.debug(LOG_PREFIX || 'START i_debt_id=' || i_debt_id);
    
    begin
        
        if i_sorting_tab.exists(FIRST_ELEMENT) then
        
            select nvl2(list, 'order by '||list, '')
              into l_sort
              from (select rtrim(xmlagg(xmlelement(e,name||' '||char_value,',').extract('//text()')),',') list
                      from table(cast(i_sorting_tab as com_param_map_tpt))
                   );
                   
        end if;
               
    exception
        when no_data_found then
            null;
        when others then
            trc_log_pkg.debug(LOG_PREFIX || ' get_sorting_param FAILED; '||
                              'dumping i_sorting_tab for debug...'
            );
            
            utl_data_pkg.print_table(i_param_tab => i_sorting_tab); -- dumping collection, DEBUG logging level is required
            
            raise;
    end;
    
    if i_is_first_call = com_api_const_pkg.FALSE then
    
        l_ref_source := 'select * from ('
                     || COLUMN_LIST || ' ' || l_ref_source || ') ' || l_sort;

        trc_log_pkg.debug(LOG_PREFIX || ': l_ref_source [' || substr(l_ref_source, 1, 3900) || ']');
                     
        open o_ref_cur for l_ref_source
        using i_debt_id;
        
    else
        
        l_ref_source := 'select count(1) ' || l_ref_source;

        trc_log_pkg.debug(LOG_PREFIX || ': l_ref_source [' || substr(l_ref_source, 1, 3900) || ']');
        
        execute immediate l_ref_source
                     into o_ref_count
                    using in i_debt_id;
    
    end if;

    trc_log_pkg.debug(LOG_PREFIX || 'END');
    
exception
    when others then
        
        trc_log_pkg.debug(substr(LOG_PREFIX || 'FAILED with l_ref_source is:' || CRLF || l_ref_source, 1, 3900));
        
        raise;
        
end get_interest_details_main;

procedure get_interest_details(
    o_ref_cur           out        com_api_type_pkg.t_ref_cur
  , i_debt_id            in        com_api_type_pkg.t_long_id
  , i_sorting_tab        in        com_param_map_tpt
) is

    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_interest_details: ';
    l_row_count        com_api_type_pkg.t_medium_id;
    
begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START');
    
    get_interest_details_main(
        o_ref_cur        => o_ref_cur
      , o_ref_count      => l_row_count
      , i_debt_id        => i_debt_id
      , i_sorting_tab    => i_sorting_tab
      , i_is_first_call  => com_api_const_pkg.FALSE
    );
    
    trc_log_pkg.debug(LOG_PREFIX || 'END');
    
exception
    when others then
       
        trc_log_pkg.debug(LOG_PREFIX || 'FAILED with i_debt_id :' || i_debt_id);
        
        raise;
        
end get_interest_details;

procedure get_interest_details_count(
    o_row_count         out        com_api_type_pkg.t_medium_id
  , i_debt_id            in        com_api_type_pkg.t_long_id
) is

    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_interest_details_count: ';
    l_ref_cur          com_api_type_pkg.t_ref_cur;
    
begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START');
    
    get_interest_details_main(
        o_ref_cur        => l_ref_cur
      , o_ref_count      => o_row_count
      , i_debt_id        => i_debt_id
      , i_sorting_tab    => null
      , i_is_first_call  => com_api_const_pkg.TRUE
    );
    
    trc_log_pkg.debug(LOG_PREFIX || 'END');
    
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'FAILED with i_debt_id :' || i_debt_id);
        
        raise;
        
end get_interest_details_count;

procedure get_unpaid_dpp_details_main(
    o_ref_cur           out     com_api_type_pkg.t_ref_cur
  , o_ref_count         out     com_api_type_pkg.t_medium_id
  , i_account_id         in     com_api_type_pkg.t_account_id
  , i_sorting_tab        in     com_param_map_tpt
  , i_is_first_call      in     com_api_type_pkg.t_boolean
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name    := lower($$PLSQL_UNIT) || '.get_unpaid_dpp_details_main: ';
    CRLF               constant com_api_type_pkg.t_name    := chr(13) || chr(10);
    FIRST_ELEMENT      constant com_api_type_pkg.t_boolean := 1;
    
    l_account_rec      acc_api_type_pkg.t_account_rec;
    
    l_sort             com_api_type_pkg.t_name;
    l_lang             com_api_type_pkg.t_dict_value := get_user_lang();
    
    COLUMN_LIST        constant com_api_type_pkg.t_text :=
    'select d.id debt_id'
      || ', dp.id dpp_id'
      || ', dp.oper_id'
      || ', dp.oper_date'
      || ', dp.oper_amount'
      || ', dp.oper_currency'
      || ', op.oper_type'
      || ', get_article_text(op.oper_type, ''' || l_lang || ''') oper_type_name'
      || ', op.oper_reason'
      || ', get_article_text(op.oper_reason, ''' || l_lang || ''') oper_reason_name'
      || ', op.msg_type'
      || ', get_article_text(op.msg_type, ''' || l_lang || ''') msg_type_name'
      || ', op.status oper_status'
      || ', get_article_text(op.status, ''' || l_lang || ''') oper_status_name'
      || ', dp.instalment_total - nvl(dp.instalment_billed, 0) instalments'
      || ', sum(di.instalment_amount - coalesce(mt.amount, di.payment_amount, 0) - nvl(mi.amount, 0)) instalments_amount'
      || ', ci.fee_id'
      || ', dpp_api_payment_plan_pkg.get_year_percent_rate('
      ||        'i_rate_algorithm    => ''' || dpp_api_const_pkg.DPP_RATE_ALGORITHM_EXPONENTIAL || ''''
      ||      ', i_fee_id            => ci.fee_id'
      ||      ', i_incoming_amount   => d.debt_amount'
      ||      ', i_incoming_currency => d.currency'
      ||      ', i_mask_error        => ' || com_api_const_pkg.TRUE
      ||   ') / 12 as month_rate_nominal'
      || ', sum(di.interest_amount - nvl(mi.amount, 0)) interests_amount'
      || ', dp.dpp_currency '
      || ', ci.is_waived '
    ;

    l_ref_source                com_api_type_pkg.t_text :=
        'from  dpp_payment_plan dp'
         || ', opr_operation op'
         || ', crd_debt d'
         || ', dpp_instalment di'
         || ', acc_macros mt'
         || ', acc_macros mi'
         || ', crd_event_bunch_type e'
         || ', crd_debt_interest ci '
     || 'where decode(dp.status, ''DOST0100'', dp.account_id, null) = :account_id '
     ||   'and dp.split_hash = :split_hash '
     ||   'and op.id = dp.oper_id '
     ||   'and d.oper_id = dp.oper_id '
     ||   'and di.dpp_id = dp.id '
     ||   'and di.macros_id = mt.id(+) '
     ||   'and di.macros_intr_id = mi.id(+) '
     ||   'and e.event_type = ''' || crd_api_const_pkg.CREATE_DEBT_EVENT || ''' '
     ||   'and e.balance_type = ci.balance_type '
     ||   'and ci.debt_id = d.id '
     ||   'and ci.event_type = e.event_type '
     || 'group by '
     ||      ' d.id'
     ||     ', dp.id'
     ||     ', dp.oper_id'
     ||     ', dp.oper_date'
     ||     ', dp.oper_amount'
     ||     ', dp.oper_currency'
     ||     ', op.oper_type'
     ||     ', op.oper_reason'
     ||     ', op.msg_type'
     ||     ', op.status'
     ||     ', dp.instalment_total'
     ||     ', dp.instalment_billed'
     ||     ', ci.fee_id'
     ||     ', d.debt_amount'
     ||     ', d.currency'
     ||     ', dp.dpp_currency '
     ||     ', ci.is_waived '
    ;

begin
    trc_log_pkg.debug(LOG_PREFIX || 'START i_account_id=' || i_account_id);
    
    l_account_rec := acc_api_account_pkg.get_account(
        i_account_id => i_account_id
      , i_mask_error => com_api_const_pkg.FALSE 
    );
    
    begin
        
        if i_sorting_tab.exists(FIRST_ELEMENT) then
        
            select nvl2(list, 'order by '||list, '')
              into l_sort
              from (select rtrim(xmlagg(xmlelement(e,name||' '||char_value,',').extract('//text()')),',') list
                      from table(cast(i_sorting_tab as com_param_map_tpt))
                   );
                   
        end if;
               
    exception
        when no_data_found then
            null;
        when others then
            trc_log_pkg.debug(LOG_PREFIX || ' get_sorting_param FAILED; '||
                              'dumping i_sorting_tab for debug...'
            );
            
            utl_data_pkg.print_table(i_param_tab => i_sorting_tab); -- dumping collection, DEBUG logging level is required
            
            raise;
    end;
    
    if i_is_first_call = com_api_const_pkg.FALSE then
    
        l_ref_source := 'select * from ('
                     || COLUMN_LIST || ' ' || l_ref_source || ') ' || l_sort;

        trc_log_pkg.debug(LOG_PREFIX || ': l_ref_source [' || substr(l_ref_source, 1, 3900) || ']');
                     
        open o_ref_cur for l_ref_source
        using l_account_rec.account_id
            , l_account_rec.split_hash
        ;
        
    else
        
        l_ref_source := 'select count(1) from ('
                     || COLUMN_LIST || ' ' || l_ref_source || ') ';

        trc_log_pkg.debug(LOG_PREFIX || ': l_ref_source [' || substr(l_ref_source, 1, 3900) || ']');
        
        execute immediate l_ref_source
                     into o_ref_count
                    using in l_account_rec.account_id
                        , in l_account_rec.split_hash
        ;
    
    end if;

    trc_log_pkg.debug(LOG_PREFIX || 'END');
    
exception
    when others then
        
        trc_log_pkg.debug(substr(LOG_PREFIX || 'FAILED with l_ref_source is:' || CRLF || l_ref_source, 1, 3900));
        
        raise;
        
end get_unpaid_dpp_details_main;

procedure get_unpaid_dpp_details(
    o_ref_cur           out        com_api_type_pkg.t_ref_cur
  , i_acount_id          in        com_api_type_pkg.t_account_id
  , i_sorting_tab        in        com_param_map_tpt
) is

    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_unpaid_dpp_details: ';
    l_row_count        com_api_type_pkg.t_medium_id;

begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START');
    
    get_unpaid_dpp_details_main(
        o_ref_cur        => o_ref_cur
      , o_ref_count      => l_row_count
      , i_account_id     => i_acount_id
      , i_sorting_tab    => i_sorting_tab
      , i_is_first_call  => com_api_const_pkg.FALSE
    );
    
    trc_log_pkg.debug(LOG_PREFIX || 'END');
    
exception
    when others then
       
        trc_log_pkg.debug(LOG_PREFIX || 'FAILED with i_acount_id :' || i_acount_id);
        
        raise;
        
end ;

procedure get_unpaid_dpp_details_count(
    o_row_count         out        com_api_type_pkg.t_medium_id
  , i_account_id         in        com_api_type_pkg.t_account_id
) is

    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_unpaid_dpp_details_count: ';
    l_ref_cur          com_api_type_pkg.t_ref_cur;
    
begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START');
    
    get_unpaid_dpp_details_main(
        o_ref_cur        => l_ref_cur
      , o_ref_count      => o_row_count
      , i_account_id     => i_account_id
      , i_sorting_tab    => null
      , i_is_first_call  => com_api_const_pkg.TRUE
    );
    
    trc_log_pkg.debug(LOG_PREFIX || 'END');
    
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'FAILED with i_acount_id :' || i_account_id);
        
        raise;
        
end get_unpaid_dpp_details_count;

end;
/
