create or replace package body iss_ui_bin_search_pkg is
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
    l_inst_id                   com_api_type_pkg.t_name;
    l_card_type_id              com_api_type_pkg.t_name;
    l_bin                       com_api_type_pkg.t_name;
    l_network_id                com_api_type_pkg.t_name;
    l_description               com_api_type_pkg.t_name;    
    l_id                        com_api_type_pkg.t_name;
    l_privil_limitation         com_api_type_pkg.t_full_desc;
    
    l_column_list           com_api_type_pkg.t_text :=
    'select ib.id'              ||
         ', p_lang'             ||
         ', ib.bin'             ||
         ', ib.seqnum'          ||
         ', ib.inst_id'         ||    
         ', ib.network_id'      ||
         ', ib.card_type_id'    || 
         ', ib.bin_currency'    ||
         ', ib.sttl_currency'   ||
         ', ib.pan_length'      ||
         ', ib.country'         ||
         ', get_text (''iss_bin'', ''description'', ib.id, p_lang) description'         ||
         ', get_text (''ost_institution'', ''name'', ib.inst_id, p_lang) inst_name'     ||
         ', get_text (''net_network'', ''name'', ib.network_id, p_lang) network_name'   ||
         ', get_text (''net_card_type'', ''name'', ib.card_type_id, p_lang) card_type_name'
        ;

    l_ref_source            com_api_type_pkg.t_text :=
     ' from iss_bin ib'                             ||
         ', (select :p_lang p_lang'                 ||
                 ', :p_inst_id p_inst_id'           ||
                 ', :p_network_id p_network_id'     ||
                 ', :p_bin p_bin'                   ||
                 ', :p_description p_description'   ||
                 ', :p_card_type_id p_card_type_id' ||   
                 ', :p_id p_id'                     ||   
            ' from dual) x '                        ||
     'where 1=1 '
        ;

    l_sorting_source            com_api_type_pkg.t_text;
    l_ref_source_debug          com_api_type_pkg.t_text;

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
    -------!!!! this function does NOT return an param value !!! it return string such as 'P_CARD_NUMBER'!!!
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
    end;

    function get_char_value(
        i_param_name        in      com_api_type_pkg.t_name
    ) return com_api_type_pkg.t_name is
        l_result            com_api_type_pkg.t_name;
    begin
        select
          case
              when char_value is not null then char_value
              else null
          end
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
        select
          case
              when date_value is not null then date_value
              else null
          end
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
        select
          case
              when number_value is not null then number_value
              else null
          end
          into l_result
          from table(cast(i_param_tab as com_param_map_tpt))
         where name = i_param_name;

         return l_result;
    exception
        when no_data_found then
            return null;
    end;

begin

    if i_tab_name = 'BIN' then
        l_id    := get_number_value('ID');
        if l_id is not null then
            l_ref_source := l_ref_source || ' and ib.id = '|| get_string('ID', com_api_const_pkg.FALSE);
        end if;
    
        l_inst_id    := get_number_value('INST_ID');
        if l_inst_id is not null then
            l_ref_source := l_ref_source || ' and ib.inst_id = '|| get_string('INST_ID', com_api_const_pkg.FALSE);
        end if;

        l_network_id    := get_number_value('NETWORK_ID');
        if l_network_id is not null then
            l_ref_source := l_ref_source || ' and ib.network_id = '|| get_string('NETWORK_ID', com_api_const_pkg.FALSE);
        end if;
        
        l_bin    := get_string('BIN');
        if l_bin is not null then
            l_ref_source := l_ref_source || l_bin;
        end if;
        
        l_description := get_string('DESCRIPTION');
        if l_description is not null then
            l_ref_source := l_ref_source || ' and lower(get_text (''iss_bin'', ''description'', ib.id, p_lang)) like lower('|| get_string('DESCRIPTION', com_api_const_pkg.FALSE) || ')';
        end if;        
        
        l_card_type_id := get_number_value('CARD_TYPE_ID');
        if l_card_type_id is not null then
            l_ref_source := l_ref_source || ' and ib.card_type_id = '|| get_string('CARD_TYPE_ID', com_api_const_pkg.FALSE);
        end if;        
            
    else
        com_api_error_pkg.raise_error(
            i_error => 'INVALID_TAB_NAME'
        );                            
    end if;
    
    l_ref_source := l_ref_source || ' and ib.inst_id in (select inst_id from acm_cu_inst_vw) ';    

    trc_log_pkg.debug('PRIVIL_LIMITATION: '|| get_char_value('PRIVIL_LIMITATION'));
    l_privil_limitation := ' and '|| nvl( get_char_value('PRIVIL_LIMITATION'), ' 1 = 1');
    l_ref_source := l_ref_source || l_privil_limitation;

    l_sorting_source := get_sorting_param;

--    trc_log_pkg.debug('LANG: '           ||   get_char_value('LANG'));
--    trc_log_pkg.debug('INST_ID: '        ||   get_number_value('INST_ID'));
--    trc_log_pkg.debug('NETWORK_ID: '     ||   get_number_value('NETWORK_ID'));
--    trc_log_pkg.debug('BIN: '            ||   get_char_value('BIN'));
--    trc_log_pkg.debug('DESCRIPTION: '    ||   get_char_value('DESCRIPTION'));
--    trc_log_pkg.debug('CARD_TYPE_ID: '   ||   get_number_value('CARD_TYPE_ID'));

    l_ref_source_debug :=
       'select * from (select a.*, rownum rn from (select * from (select * from ('||l_column_list||l_ref_source||')) '||l_sorting_source||') a) where rn between :p_first_row and :p_last_row';

    trc_log_pkg.debug(l_ref_source_debug);
    --dbms_output.put_line(l_ref_source_debug);

    if  i_is_first_call = com_api_const_pkg.TRUE then

        execute immediate 'select count(1) '|| l_ref_source 
        into o_row_count
        using
            get_char_value('LANG')
          , get_number_value('INST_ID')
          , get_number_value('NETWORK_ID')
          , get_char_value('BIN')
          , get_char_value('DESCRIPTION')
          , get_number_value('CARD_TYPE_ID')
          , get_number_value('ID');

    else
        open o_ref_cur for 'select * from (select a.*, rownum rn from (select * from (select * from ('||l_column_list||l_ref_source||')) '||l_sorting_source||') a) where rn between :p_first_row and :p_last_row'
        using
            get_char_value('LANG')
          , get_number_value('INST_ID')
          , get_number_value('NETWORK_ID')
          , get_char_value('BIN')
          , get_char_value('DESCRIPTION')
          , get_number_value('CARD_TYPE_ID')
          , get_number_value('ID')
          , i_first_row
          , i_last_row;
    end if;
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
    l_tab_name          com_api_type_pkg.t_name;
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
