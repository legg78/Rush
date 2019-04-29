create or replace package body ntf_ui_message_search_pkg is

procedure get_ref_cur_base(
    o_ref_cur           out     com_api_type_pkg.t_ref_cur
  , o_row_count         out     com_api_type_pkg.t_tiny_id
  , i_first_row         in      com_api_type_pkg.t_tiny_id
  , i_last_row          in      com_api_type_pkg.t_tiny_id
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt
  , i_is_first_call     in      com_api_type_pkg.t_boolean
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_ref_cur_base: ';
    CRLF               constant com_api_type_pkg.t_name := chr(13) || chr(10);
    
    l_event_type       com_api_type_pkg.t_dict_value;
    l_inst_id          com_api_type_pkg.t_inst_id; 
    l_card_number      com_api_type_pkg.t_name;
    l_account_number   com_api_type_pkg.t_name;
    l_date_from        date;
    l_date_to          date;
    l_delivery_date_from   date;
    l_delivery_date_to     date;
    l_lang             com_api_type_pkg.t_dict_value;
    l_channel_id       com_api_type_pkg.t_inst_id; 
    l_is_delivered     com_api_type_pkg.t_boolean; 
    l_urgency_level    com_api_type_pkg.t_tiny_id; 
    l_delivery_address com_api_type_pkg.t_full_desc;
    
    COLUMN_LIST        constant com_api_type_pkg.t_text :=
    'select n.id'               ||
         ', n.channel_id'       ||        
         ', n.text'             ||
         ', n.lang'             ||
         ', n.delivery_address' ||
         ', n.delivery_date'    ||    
         ', n.is_delivered'     ||
         ', n.urgency_level'    ||
         ', n.inst_id'          ||
         ', n.event_type'       ||
         ', n.eff_date'         ||
         ', n.entity_type'      ||
         ', n.object_id '       ||
         ', n.message_status '  
        ;

    l_ref_source                com_api_type_pkg.t_text :=
        'from ntf_message n '                              ||
        ', (select :p_date_from p_date_from'               ||
                ', :p_date_to p_date_to'                   ||
                ', :p_event_type p_event_type'             ||
                ', :p_inst_id p_inst_id'                   ||
                ', :p_lang p_lang'                         ||
                ', :p_channel_id p_channel_id'             ||
                ', :p_is_delivered p_is_delivered'         ||
                ', :p_urgency_level p_urgency_level'       ||
                ', :p_delivery_address p_delivery_address' ||
             ' from dual '                                 ||
             ') x '           
            ;

    l_opr_source                  com_api_type_pkg.t_text;
    l_card_source                 com_api_type_pkg.t_text;
    l_account_source              com_api_type_pkg.t_text;
    l_run_source                  com_api_type_pkg.t_text;

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
        when others then
            trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_ref_cur_base->get_sorting_param FAILED; '||
                              'dumping i_sorting_tab for debug...');
            utl_data_pkg.print_table(i_param_tab => i_sorting_tab); -- dumping collection, DEBUG logging level is required
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
                       ' and reverse(' || i_field_name || ') like reverse(''' || t.char_value || ''')'
                   when instr(t.char_value, '%') = 0 then
                       ' and reverse(' || i_field_name || ')' ||
                           ' like reverse(''' || iss_api_token_pkg.encode_card_number(i_card_number => t.char_value) || ''')'
                   else
                       ' and reverse(' || i_field_name || ')' ||
                           ' like reverse(''%'' || substr(''' || t.char_value ||
                                     ''', -'||iss_api_const_pkg.LENGTH_OF_PLAIN_PAN_ENDING || '))' ||
                       ' and iss_api_token_pkg.decode_card_number(i_card_number => ' || i_field_name || ')' ||
                           ' like ''' || t.char_value || ''''
               end
          into l_result
          from table(cast(i_param_tab as com_param_map_tpt)) t
         where t.name = 'CARD_NUMBER';

        trc_log_pkg.debug('card_number_condition [' || l_result || ']');
        return l_result;
    end;

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
    end;

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
    end;

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
    end;

    function get_string(
        i_param_name        in      com_api_type_pkg.t_name
    ) return com_api_type_pkg.t_name
    is
        l_result            com_api_type_pkg.t_name;
    begin
        select
          case
              when date_value is not null then
                  'to_date('''||to_char(date_value, com_api_const_pkg.DATE_FORMAT)||''', '''||com_api_const_pkg.DATE_FORMAT||''')'
              when char_value is not null then
                  ''''||char_value||''''
              when number_value is not null then
                  'to_number('''||to_char(number_value, com_api_const_pkg.NUMBER_FORMAT)||''', '''||com_api_const_pkg.NUMBER_FORMAT||''')'
              else null
          end
          into l_result
          from table(cast(i_param_tab as com_param_map_tpt))
         where upper(name) = upper(i_param_name);

         return l_result;
    exception
        when no_data_found then
            return null;
        when others then
            trc_log_pkg.debug('get_string FAILED with i_param_name [' || i_param_name ||']');
            raise;
    end get_string;
    
   
 function get_where
    return com_api_type_pkg.t_text
    is    
    l_result    com_api_type_pkg.t_text;
    begin   
     --   l_result := ' and n.inst_id in (select inst_id from acm_cu_inst_vw)';
        
        if l_inst_id is not null then
            l_result := l_result || ' and n.inst_id = x.p_inst_id ';
        end if;

        if l_date_from is not null then
            --l_result := l_result || ' and n.eff_date >= x.p_date_from ';
            l_result := l_result || 'and ((length(to_char(n.id)) > 15 and n.id >= com_api_id_pkg.get_from_id('||get_string('DATE_FROM')||')) ';
            l_result := l_result || 'or (length(to_char(n.id)) < 15 and n.eff_date >= x.p_date_from))';
        end if;

        if l_date_to is not null then
            --l_result := l_result || ' and n.eff_date <= x.p_date_to ';
            l_result := l_result || 'and ((length(to_char(n.id)) > 15 and n.id <= com_api_id_pkg.get_from_id('||get_string('DATE_TO')||')) ';
            l_result := l_result || 'or (length(to_char(n.id)) < 15 and n.eff_date <= x.p_date_to))';
        end if;

        if l_delivery_date_from is not null then
            l_result := l_result || ' and n.delivery_date >= '||get_string('DELIVERY_DATE_FROM')||' ';
        end if;

        if l_delivery_date_to is not null then
            l_result := l_result || ' and n.delivery_date <= '||get_string('DELIVERY_DATE_TO')||' ';
        end if;

        if l_event_type is not null then
            l_result := l_result || ' and n.event_type = x.p_event_type ';
        end if;

        if l_lang is not null then
            l_result := l_result || ' and n.lang = x.p_lang ';
        end if;

        if l_channel_id is not null then
            l_result := l_result || ' and n.channel_id = x.p_channel_id ';
        end if;

        if l_is_delivered is not null then
            l_result := l_result || ' and n.is_delivered = x.p_is_delivered ';
        end if;

        if l_urgency_level is not null then
            l_result := l_result || ' and n.urgency_level = x.p_urgency_level ';
        end if;
    
        if l_delivery_address is not null then
            l_result := l_result || ' and n.delivery_address = x.p_delivery_address ';
        end if;

        return l_result;
    end;
    
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START i_is_first_call [' || i_is_first_call || ']');
    
    utl_data_pkg.print_table(i_param_tab => i_param_tab); 
    
    l_card_number      := get_char_value('CARD_NUMBER');
    l_account_number   := get_char_value('ACCOUNT_NUMBER');
    l_date_from        := get_date_value('DATE_FROM');
    l_date_to          := get_date_value('DATE_TO');
    l_delivery_date_from := get_date_value('DELIVERY_DATE_FROM');
    l_delivery_date_to   := get_date_value('DELIVERY_DATE_TO');
    l_inst_id          := get_number_value('INST_ID');
    l_event_type       := get_char_value('EVENT_TYPE');     
    l_channel_id       := get_number_value('CANNEL_ID'); 
    l_is_delivered     := get_number_value('IS_DELIVERED'); 
    l_urgency_level    := get_number_value('URGENCY_LEVEL'); 
    l_delivery_address := get_char_value('DELIVERY_ADDRESS');
        
    if l_card_number is not null then
        
        l_card_source := l_ref_source             ||  
             ', iss_card c'                       ||
             ', iss_card_number t '               ||
        ' where n.object_id = c.id'               ||
          ' and n.entity_type = ''ENTTCARD'''     ||
          ' and t.card_id = c.id'                 ||
          card_number_condition(i_field_name => 't.card_number');

        l_card_source := l_card_source || get_where();

        --union  
        l_opr_source := l_ref_source            || 
             ', opr_card c '                    ||
        ' where n.object_id = c.oper_id '       ||  
          ' and n.entity_type = ''ENTTOPER'''   ||
            card_number_condition(i_field_name => 'c.card_number');
        
        l_opr_source := l_opr_source || get_where();
        
        l_run_source := 
            COLUMN_LIST    || 
            l_card_source  || 
            ' union all '  ||
            COLUMN_LIST    || 
            l_opr_source; 
        
    elsif l_account_number is not null then
    
        l_account_source := l_ref_source            ||
             ', acc_account a'                      ||
        ' where n.object_id = a.id'                 ||
          ' and n.entity_type = ''ENTTACCT'''       ||
          ' and reverse(a.account_number) like reverse(replace(''' || l_account_number || ''', ''*'',''%'')) ';
          
        l_account_source := l_account_source || get_where();
        
        --union  
        l_opr_source := l_ref_source                || 
             ', opr_participant p '                 ||
             ', acc_account a'                      ||
        ' where n.object_id = p.oper_id '           ||  
          ' and n.entity_type = ''ENTTOPER'''       ||
          ' and p.participant_type = ''PRTYISS'''   ||
          ' and a.id = p.account_id'                ||
          ' and a.split_hash = p.split_hash'        ||
          ' and reverse(a.account_number) like reverse(replace(''' || l_account_number || ''', ''*'',''%'')) ';
        
        l_opr_source := l_opr_source || get_where();
        
        l_run_source := 
            COLUMN_LIST       || 
            l_account_source  || 
            ' union all '     ||
            COLUMN_LIST       || 
            l_opr_source; 
        
    else
        l_run_source := COLUMN_LIST || l_ref_source || ' where 1=1 ' || get_where(); 
                                         
    end if;
       
    if l_card_number is not null or l_account_number is not null then

        if  i_is_first_call = com_api_const_pkg.TRUE then
            
            l_run_source := 'select count(1) from (' || l_run_source || ')';
            trc_log_pkg.debug(l_run_source);
            --dbms_output.put_line(l_run_source);
            execute immediate l_run_source
               into o_row_count
              using l_date_from 
                  , l_date_to
                  , l_event_type
                  , l_inst_id
                  , l_lang
                  , l_channel_id 
                  , l_is_delivered  
                  , l_urgency_level 
                  , l_delivery_address                  
                  , l_date_from 
                  , l_date_to
                  , l_event_type
                  , l_inst_id
                  , l_lang
                  , l_channel_id 
                  , l_is_delivered  
                  , l_urgency_level 
                  , l_delivery_address                  
                  ;      
            --dbms_output.put_line('o_row_count='||o_row_count);
        else    
            l_run_source := 'select b.* ' || 
                                 ', get_text (''ntf_channel'',''name'',b.channel_id, b.lang) channel_name ' || 
                                 ', case when b.inst_id = 9999 then com_api_label_pkg.get_label_text (''SYS_INST_NAME'', b.lang)' ||
                                 ' else get_text (''ost_institution'',''name'', b.inst_id, b.lang) end inst_name ' ||
                            ' from (select a.*, rownum rn from (' || l_run_source || get_sorting_param() || ')a ) b where rn between :p_first_row and :p_last_row';    
            --dbms_output.put_line(l_run_source);           
            trc_log_pkg.debug(l_run_source);
            open o_ref_cur for l_run_source 
            using l_date_from 
                , l_date_to
                , l_event_type
                , l_inst_id
                , l_lang
                , l_channel_id 
                , l_is_delivered  
                , l_urgency_level 
                , l_delivery_address                  
                , l_date_from 
                , l_date_to
                , l_event_type
                , l_inst_id     
                , l_lang
                , l_channel_id 
                , l_is_delivered  
                , l_urgency_level 
                , l_delivery_address                  
                , i_first_row
                , i_last_row;      
        end if;  
    else 
        if  i_is_first_call = com_api_const_pkg.TRUE then
            
            l_run_source := 'select count(1) from (' || l_run_source || ')';
            trc_log_pkg.debug(l_run_source);
            --dbms_output.put_line(l_run_source);
            execute immediate l_run_source
               into o_row_count
              using l_date_from 
                  , l_date_to
                  , l_event_type
                  , l_inst_id
                  , l_lang
                  , l_channel_id 
                  , l_is_delivered  
                  , l_urgency_level 
                  , l_delivery_address                  
                  ;
            --dbms_output.put_line('o_row_count='||o_row_count);
        else        
        
            l_run_source := 'select b.* ' || 
                                 ', get_text (''ntf_channel'',''name'',b.channel_id, b.lang) channel_name ' || 
                                 ', case when b.inst_id = 9999 then com_api_label_pkg.get_label_text (''SYS_INST_NAME'', b.lang)' ||
                                 ' else get_text (''ost_institution'',''name'', b.inst_id, b.lang) end inst_name ' ||
                            ' from (select a.*, rownum rn from (' || l_run_source || get_sorting_param() || ')a ) b where rn between :p_first_row and :p_last_row';    
            --dbms_output.put_line(l_run_source);           
            trc_log_pkg.debug(l_run_source);
            open o_ref_cur for l_run_source 
            using l_date_from 
                , l_date_to
                , l_event_type
                , l_inst_id
                , l_lang
                , l_channel_id 
                , l_is_delivered  
                , l_urgency_level 
                , l_delivery_address                  
                , i_first_row
                , i_last_row;      
        end if;        
    end if;
    
   -- open o_ref_cur for 'select * from ntf_scheme';
      
    --o_row_count := 1;
    
    trc_log_pkg.debug(LOG_PREFIX || 'END');

exception
    when others then
        trc_log_pkg.debug(substr(LOG_PREFIX || 'FAILED with l_ref_source is:' || CRLF || l_run_source, 1, 4000));
        raise;      
end get_ref_cur_base;

procedure get_ref_cur(
    o_ref_cur           out     com_api_type_pkg.t_ref_cur
  , i_first_row         in      com_api_type_pkg.t_tiny_id
  , i_last_row          in      com_api_type_pkg.t_tiny_id
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
      , i_param_tab         => i_param_tab
      , i_sorting_tab       => i_sorting_tab
      , i_is_first_call     => com_api_const_pkg.FALSE
    );
end get_ref_cur;

procedure get_row_count(
    o_row_count         out     com_api_type_pkg.t_tiny_id
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
      , i_param_tab         => i_param_tab
      , i_sorting_tab       => l_sorting_tab
      , i_is_first_call     => com_api_const_pkg.TRUE
    );
end get_row_count;

end ntf_ui_message_search_pkg;
/
