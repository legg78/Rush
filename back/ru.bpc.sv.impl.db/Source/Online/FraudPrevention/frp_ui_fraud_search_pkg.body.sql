create or replace package body frp_ui_fraud_search_pkg is
/********************************************************* 
 *  User Interface procedures for FRP Fraud search  <br /> 
 *  Created by Kondratyev A.(kondratyev@bpcbt.com)  at 06.06.2014 <br /> 
 *  Last changed by $Author: kondratyev $ <br /> 
 *  $LastChangedDate:: 2014-06-06 15:01:00 +0400#$ <br /> 
 *  Revision: $LastChangedRevision: 43029 $ <br /> 
 *  Module: frp_ui_fraud_search_pkg <br /> 
 *  @headcom 
 **********************************************************/ 
 
procedure get_ref_cur_base(
    o_ref_cur              out com_api_type_pkg.t_ref_cur
  , o_row_count            out com_api_type_pkg.t_tiny_id
  , i_first_row         in     com_api_type_pkg.t_tiny_id
  , i_last_row          in     com_api_type_pkg.t_tiny_id
  , i_tab_name          in     com_api_type_pkg.t_name
  , i_param_tab         in     com_param_map_tpt
  , i_sorting_tab       in     com_param_map_tpt
  , i_is_first_call     in     com_api_type_pkg.t_boolean
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_ref_cur_base';
    CRLF                constant com_api_type_pkg.t_name := chr(13) || chr(10);
    l_amount_from       com_api_type_pkg.t_money;
    l_amount_to         com_api_type_pkg.t_money;
    l_currency          com_api_type_pkg.t_curr_code;
    l_currency_exponent com_api_type_pkg.t_tiny_id;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_account_number    com_api_type_pkg.t_name;
    l_terminal_number   com_api_type_pkg.t_name;
    l_account_id        com_api_type_pkg.t_account_id;
    l_terminal_id       com_api_type_pkg.t_short_id;
    l_surname           com_api_type_pkg.t_name;
    l_first_name        com_api_type_pkg.t_name;   
    l_second_name       com_api_type_pkg.t_name;   
    l_privil_limitation com_api_type_pkg.t_full_desc;

    COLUMN_LIST         constant com_api_type_pkg.t_text :=
        'select f.id'||
             ', f.seqnum'||
             ', f.auth_id'||
             ', f.case_id'||
             ', f.entity_type'||
             ', f.object_id'||
             ', f.resolution'||
             ', f.resolution_user_id'||
             ', o.oper_date'||
             ', o.oper_amount'||
             ', o.oper_currency'||
             ', o.oper_type'||
             ', com_ui_object_pkg.get_object_desc(f.entity_type, f.object_id, get_user_lang()) as object_desc'||
             ', com_api_i18n_pkg.get_text(''frp_case'', ''label'', f.case_id, get_user_lang()) as case_name'||
             ', com_api_i18n_pkg.get_text(''frp_case'', ''description'', f.case_id, get_user_lang()) as case_desc'||
             ', com_api_dictionary_pkg.get_article_text(f.resolution, get_user_lang()) as resolution_name'||
             ', acm_ui_user_pkg.get_user_full_name(f.resolution_user_id) as resolution_user'
             ;

    l_ref_source        com_api_type_pkg.t_text :=
          ' from frp_fraud f'
        ||    ', aut_auth a'
        ||    ', opr_operation o'
        ||    ', opr_participant p'
        ||    ', iss_card_number c'
        ||', (select :p_oper_amount_from as p_oper_amount_from'
        ||        ', :p_oper_amount_to   as p_oper_amount_to'
        ||        ', :p_oper_currency    as p_oper_currency'
        ||        ', :p_account_id       as p_account_id'
        ||        ', :p_terminal_id      as p_terminal_id'
        ||        ', :p_oper_date_form   as p_oper_date_from'
        ||        ', :p_oper_date_till   as p_oper_date_till'
        ||        ', :p_mcc              as p_mcc'
        ||        ', :p_oper_type        as p_oper_type'
        ||        ', :p_card_number      as p_card_number'
        ||        ', :p_inst_id          as p_inst_id'
        ||        ', :p_account_number   as p_account_number'
        ||        ', :p_terminal_number  as p_terminal_number'
        ||        ', :p_entity_type      as p_entity_type'
        ||        ', :p_resolution       as p_resolution'
        ||        ', :p_first_name       as p_first_name'
        ||        ', :p_second_name      as p_second_name'
        ||        ', :p_surname          as p_surname'
        ||        ' from dual) x '
        ||' where f.auth_id = a.id '
        ||  ' and a.id = o.id'
        ||  ' and o.id = p.oper_id'
        ||  ' and p.participant_type = :participant_type'
        ||  ' and c.card_id(+) = p.card_id'
        ||  ' and p.inst_id in (select inst_id from acm_cu_inst_vw)';

    procedure add_where(
        i_param_name        in     com_api_type_pkg.t_name
      , i_is_format         in     com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    ) is
        l_result            com_api_type_pkg.t_name;
    begin
        trc_log_pkg.debug('add_where: i_param_name = '||i_param_name || ', i_is_format = ' || i_is_format);
        for r in (
            select *
              from table(cast(i_param_tab as com_param_map_tpt))
             where name = i_param_name)
        loop
            l_result := l_result ||
            case 
                --------------------------------------------------------------    
                when i_is_format = com_api_const_pkg.FALSE then
                    'p_'||lower(i_param_name)
                --------------------------------------------------------------    
                when r.date_value is not null then
                    case 
                        when r.condition = '>=' then 
                            ' and '||lower(i_param_name)||' '||nvl(r.condition, '=')||' p_'||lower(i_param_name)||'_from'
                        else
                            ' and '||lower(i_param_name)||' '||nvl(r.condition, '=')||' p_'||lower(i_param_name)||'_till'
                    end    
                when r.char_value is not null and substr(r.char_value, 1, 1) = '%' then
                    ' and reverse(lower('||lower(i_param_name)||')) '||nvl(r.condition, 'like')||' reverse(lower(p_'||lower(i_param_name)||'))'
                when r.char_value is not null and instr(r.char_value, '%') != 0 then
                    ' and lower('||lower(i_param_name)||') '||nvl(r.condition, 'like')||' lower(p_'||lower(i_param_name)||')'
                when r.char_value is not null then
                    ' and lower('||lower(i_param_name)||') '||nvl(r.condition, '=')||' lower(p_'||lower(i_param_name)||')'
                when r.number_value is not null then
                    case
                        when r.condition = '>=' then 
                            ' and '||lower(i_param_name)||' '||nvl(r.condition, '=')||' p_'||lower(i_param_name)||'_from'
                        else
                            ' and '||lower(i_param_name)||' '||nvl(r.condition, '=')||' p_'||lower(i_param_name)||'_to'
                    end
            end;
        end loop;
         
        if l_result is not null then
            l_ref_source := l_ref_source || l_result;
            trc_log_pkg.debug(LOG_PREFIX || '->add_where [' || l_result || ']');
        end if;

    exception
        when no_data_found then
            null;
        when others then
            trc_log_pkg.debug(
                i_text => LOG_PREFIX || '->add_where FAILED: i_param_name [' || i_param_name 
                                     || '], i_is_format [' || i_is_format || ']'
            );
            raise;
    end;

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

        trc_log_pkg.debug(LOG_PREFIX || '->card_number_condition [' || l_result || ']');
        return l_result;
    end;

    procedure retrieve_values(
        i_param_name        in            com_api_type_pkg.t_name
      , i_condition         in            com_api_type_pkg.t_name
      , o_record            in out nocopy com_param_map_tpr
    ) is
    begin
        -- creating object
        if o_record is null then
            o_record := com_param_map_tpr(null, null, null, null, null);
        end if;
        
        select char_value
             , number_value
             , date_value
          into o_record.char_value
             , o_record.number_value
             , o_record.date_value
          from table(cast(i_param_tab as com_param_map_tpt))
         where name = i_param_name
           and (i_condition is null or condition = i_condition);
    exception
        when no_data_found then
            null;
        when others then
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || '->retrieve_values() FAILED: i_param_name [#1], i_condition [#2]'
              , i_env_param1 => i_param_name
              , i_env_param2 => i_condition
            );
            raise;
    end retrieve_values;
    
    function get_char_value(
        i_param_name        in      com_api_type_pkg.t_name
      , i_condition         in      com_api_type_pkg.t_name default null
    ) return com_api_type_pkg.t_name is
        l_values            com_param_map_tpr;
    begin
        --trc_log_pkg.debug('get_char_value: i_param_name = ' || i_param_name || ', i_condition = "' || i_condition || '"');
        retrieve_values(
            i_param_name => i_param_name
          , i_condition  => i_condition
          , o_record     => l_values
        );
        return l_values.char_value;
    end get_char_value;
    
    function get_date_value(
        i_param_name        in      com_api_type_pkg.t_name
      , i_condition         in      com_api_type_pkg.t_name default null
    ) return date is
        l_values            com_param_map_tpr;
    begin
        --trc_log_pkg.debug('get_date_value: i_param_name = ' || i_param_name || ', i_condition = "' || i_condition || '"');
        retrieve_values(
            i_param_name => i_param_name
          , i_condition  => i_condition
          , o_record     => l_values
        );
        return l_values.date_value;
    end get_date_value;
    
    function get_number_value(
        i_param_name        in      com_api_type_pkg.t_name
      , i_condition         in      com_api_type_pkg.t_name default null
    ) return number is
        l_values            com_param_map_tpr;
    begin
        --trc_log_pkg.debug('get_number_value: i_param_name = ' || i_param_name || ', i_condition = "' || i_condition || '"');
        retrieve_values(
            i_param_name => i_param_name
          , i_condition  => i_condition
          , o_record     => l_values
        );
        return l_values.number_value;
    end get_number_value;
    
    function get_sorting_param return com_api_type_pkg.t_name is
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
    end;
    
begin
    trc_log_pkg.debug(LOG_PREFIX || ': i_tab_name [' || i_tab_name || '], i_is_first_call [' || i_is_first_call || ']');
    utl_data_pkg.print_table(i_param_tab => i_param_tab); -- dumping collection, DEBUG logging level is required

    l_currency    := get_char_value('OPER_CURRENCY');
    l_amount_from := get_number_value('OPER_AMOUNT', '>=');
    l_amount_to   := get_number_value('OPER_AMOUNT', '<=');
    
    if l_currency is not null then
        l_currency_exponent := com_api_currency_pkg.get_currency_exponent(l_currency);
        l_amount_from := l_amount_from * power(10, l_currency_exponent);
        l_amount_to   := l_amount_to   * power(10, l_currency_exponent);
    end if;

    if i_tab_name = 'AUTHORIZATION' then
        add_where('OPER_AMOUNT');
        add_where('OPER_CURRENCY');
        add_where('OPER_DATE');
        add_where('MCC');
        add_where('OPER_TYPE');
    elsif i_tab_name = 'CARD' then
        l_ref_source := l_ref_source || card_number_condition('CARD_NUMBER');
        add_where('OPER_CURRENCY');
        add_where('OPER_DATE');
    elsif i_tab_name = 'ACCOUNT' then
        begin
            l_inst_id         := get_number_value('INST_ID');
            l_account_number  := get_char_value('ACCOUNT_NUMBER');
            select id
              into l_account_id
              from acc_account
             where inst_id         = l_inst_id
               and account_number  = l_account_number;
            add_where('ACCOUNT_ID');
            add_where('OPER_DATE');
        exception
            when no_data_found then
                null;
        end;
    elsif i_tab_name = 'TERMINAL' then
        begin
            l_inst_id         := get_number_value('INST_ID');
            l_terminal_number := get_char_value('TERMINAL_NUMBER');
            select id
              into l_terminal_id
              from acq_terminal
             where inst_id         = l_inst_id
               and terminal_number = l_terminal_number;
            add_where('TERMINAL_ID');
            add_where('TERMINAL_NUMBER');
            add_where('OPER_DATE');
        exception
            when no_data_found then
                null;
        end;
    end if;
    add_where('ENTITY_TYPE');
    add_where('RESOLUTION');
    l_surname    := get_char_value('SURNAME');
    if l_surname is not null then
        l_ref_source := l_ref_source || ' and f.user_id in (select u.id from acm_user u, com_person ps where u.person_id = ps.id and lower(ps.surname) = lower(';
        add_where('SURNAME', com_api_const_pkg.FALSE);
        l_ref_source := l_ref_source || ')';
    
        l_first_name    := get_char_value('FIRST_NAME');
        if l_first_name is not null then
            l_ref_source := l_ref_source || ' and lower(ps.first_name) = lower(';
            add_where('FIRST_NAME', com_api_const_pkg.FALSE);
            l_ref_source := l_ref_source || ')';            
        end if;            
            
        l_second_name    := get_char_value('SECOND_NAME');
        if l_second_name is not null then
            l_ref_source := l_ref_source || ' and lower(ps.second_name) = lower(';
            add_where('SECOND_NAME', com_api_const_pkg.FALSE);
            l_ref_source := l_ref_source || ')';            
        end if;            
            
        l_ref_source := l_ref_source || ')';
    end if;

    trc_log_pkg.debug('PRIVIL_LIMITATION: '|| get_char_value('PRIVIL_LIMITATION'));
    l_privil_limitation := ' and '|| nvl( get_char_value('PRIVIL_LIMITATION'), ' 1 = 1');
    l_ref_source := l_ref_source || l_privil_limitation;

    if i_is_first_call = com_api_const_pkg.TRUE then
        l_ref_source := 'select count(1) '|| l_ref_source; 
        trc_log_pkg.debug(LOG_PREFIX || ':' || CRLF || l_ref_source);

        execute immediate l_ref_source 
           into o_row_count
          using l_amount_from
              , l_amount_to
              , l_currency
              , l_account_id
              , l_terminal_id
              , get_date_value('OPER_DATE', '>=')
              , get_date_value('OPER_DATE', '<=')
              , get_char_value('MCC')
              , get_char_value('OPER_TYPE')
              , get_char_value('CARD_NUMBER')
              , l_inst_id
              , get_char_value('ACCOUNT_NUMBER')
              , get_char_value('TERMINAL_NUMBER')
              , get_char_value('ENTITY_TYPE')
              , get_char_value('RESOLUTION')
              , get_char_value('FIRST_NAME')
              , get_char_value('SECOND_NAME')
              , get_char_value('SURNAME')
              , com_api_const_pkg.PARTICIPANT_ISSUER;

        trc_log_pkg.debug(LOG_PREFIX || 'o_row_count [' || o_row_count || ']');
                    
    else
        l_ref_source := 'select * from (select a.*, rownum rn from (' ||
                            COLUMN_LIST || l_ref_source || ' ' || get_sorting_param() ||
                        ') a) where rn >= :p_first_row and rn <= :p_last_row';
        trc_log_pkg.debug(LOG_PREFIX || ':' || CRLF || l_ref_source);

        open o_ref_cur for l_ref_source
        using l_amount_from
            , l_amount_to
            , l_currency
            , l_account_id
            , l_terminal_id
            , get_date_value('OPER_DATE', '>=')
            , get_date_value('OPER_DATE', '<=')
            , get_char_value('MCC')
            , get_char_value('OPER_TYPE')
            , get_char_value('CARD_NUMBER')
            , l_inst_id
            , get_char_value('ACCOUNT_NUMBER')
            , get_char_value('TERMINAL_NUMBER')
            , get_char_value('ENTITY_TYPE')
            , get_char_value('RESOLUTION')
            , get_char_value('FIRST_NAME')
            , get_char_value('SECOND_NAME')
            , get_char_value('SURNAME')
            , com_api_const_pkg.PARTICIPANT_ISSUER
            , i_first_row
            , i_last_row;
    end if;

exception
    when others then
        trc_log_pkg.debug(LOG_PREFIX || ': FAILED with l_ref_source [' || CRLF || substr(l_ref_source, 1, 3900) || ']');
        raise;
end get_ref_cur_base;

procedure get_ref_cur(
    o_ref_cur              out  com_api_type_pkg.t_ref_cur
  , i_first_row         in      com_api_type_pkg.t_tiny_id
  , i_last_row          in      com_api_type_pkg.t_tiny_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in     com_param_map_tpt
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

end;
/