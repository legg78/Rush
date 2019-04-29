create or replace package body acq_ui_merchant_search_pkg is

procedure get_ref_cur_base(
    o_ref_cur              out  com_api_type_pkg.t_ref_cur
  , o_row_count            out  com_api_type_pkg.t_medium_id
  , i_first_row         in      com_api_type_pkg.t_tiny_id
  , i_last_row          in      com_api_type_pkg.t_tiny_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt
  , i_is_first_call     in      com_api_type_pkg.t_boolean
) is
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_customer_id               com_api_type_pkg.t_medium_id;
    l_account_id                com_api_type_pkg.t_medium_id;
    l_merchant_id               com_api_type_pkg.t_medium_id;
    l_merchant_number           com_api_type_pkg.t_name;
    l_customer_number           com_api_type_pkg.t_name;
    l_status                    com_api_type_pkg.t_dict_value;
    l_merchant_type             com_api_type_pkg.t_dict_value;
    l_company_name              com_api_type_pkg.t_name;
    l_contract_id               com_api_type_pkg.t_medium_id;
    l_privil_limitation         com_api_type_pkg.t_full_desc;
    
    CRLF               constant com_api_type_pkg.t_name := chr(13) || chr(10);
    COLUMN_LIST        constant com_api_type_pkg.t_text :=
    'select m.id'                               ||
         ', m.seqnum'                           ||
         ', m.merchant_number'                  ||
         ', m.merchant_name'                    ||
         ', m.merchant_type'                    ||
         ', m.parent_id'                        ||
         ', m.mcc'                              ||
         ', m.status'                           ||
         ', m.contract_id'                      ||
         ', m.inst_id'                          ||
         ', m.split_hash'                       ||
         ', p.id product_id'                    ||
         ', p.product_number'                   ||
         ', ct.contract_number'                 ||
         ', p.product_type'                     ||
         ', cu.id customer_id'                  ||
         ', cu.customer_number'                 ||
         ', cu.entity_type as customer_type'    ||
         ', p_lang lang'                        ||
         ', mc.id mcc_id'                       ||
         ', m.partner_id_code'                  ||
         ', get_text(''com_company'', ''label'', cu.object_id, p_lang) as company_name ' ||
         ', m.risk_indicator '                  ||
         ', m.mc_assigned_id '
    ;

    l_ref_source                com_api_type_pkg.t_text :=
     'from acq_merchant m'                                  ||
        ', prd_contract ct'                                 ||
        ', com_mcc mc'                                      ||
        ', prd_product p'                                   ||
        ', prd_customer cu'                                 ||
        ', (select :p_lang as p_lang'                       ||
                ', :p_inst_id as p_inst_id'                 ||
                ', :p_merchant_number as p_merchant_number' ||
                ', :p_customer_number as p_customer_number' ||
                ', :p_customer_id as p_customer_id'         ||
                ', :p_status as p_status'                   ||
                ', :p_merchant_type as p_merchant_type'     ||
                ', :p_company_name as p_company_name'       ||
                ', :p_account_id as p_account_id'           ||
                ', :p_merchant_id as p_merchant_id'         ||
                ', :p_contract_id as p_contract_id'         ||
             ' from dual'                                   ||
         ') x '                                             ||
    'where ct.id  = m.contract_id'                          ||
     ' and mc.mcc = m.mcc'                                  ||
     ' and p.id   = ct.product_id'                          ||
     ' and cu.id = ct.customer_id ';
          
    l_sorting_source            com_api_type_pkg.t_text;
    l_ref_query                 com_api_type_pkg.t_text;

    function get_sorting_param(
        i_sorting_tab       in      com_param_map_tpt
    ) return com_api_type_pkg.t_name is
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
    
    -- !!! this function does NOT return an param value !!! it return string such as 'p_card_number'!!!
    function get_string(
        i_param_name        in     com_api_type_pkg.t_name
      , i_is_format         in     com_api_type_pkg.t_boolean      default com_api_type_pkg.TRUE
      , i_upper_reverse     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
    ) return com_api_type_pkg.t_name is
        l_result            com_api_type_pkg.t_name;
    begin
        if i_upper_reverse = com_api_type_pkg.TRUE then
            select
              case
                  when char_value is not null and substr(char_value, 1, 1) = '%' and instr(substr(char_value, 2), '%') = 0 then
                      ' and reverse('||lower(i_param_name)||') '||nvl(condition, 'like')||' reverse(upper(substr(p_'||lower(i_param_name)||',2)))||''%'''
                  when char_value is not null and instr(char_value, '%') != 0 then
                      ' and '||lower(i_param_name)||' '||nvl(condition, 'like')||' upper(p_'||lower(i_param_name)||')'
                  when char_value is not null then
                      ' and '||lower(i_param_name)||' '||nvl(condition, '=')||' upper(p_'||lower(i_param_name)||')'
                  else null
              end
              into l_result
              from table(cast(i_param_tab as com_param_map_tpt))
             where name = i_param_name;
          
        else
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

        end if;

        return l_result;
    exception
        when no_data_found then
            return null;
        when others then
            trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_ref_cur_base->get_string FAILED with i_param_name ['||i_param_name||']');
            raise;
    end;

    function get_char_value(
        i_param_name        in     com_api_type_pkg.t_name
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
            trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_ref_cur_base->get_char_value FAILED with i_param_name ['||i_param_name||']');
            raise;
    end;

    function get_date_value(
        i_param_name        in     com_api_type_pkg.t_name
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
            trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_ref_cur_base->get_date_value FAILED with i_param_name ['||i_param_name||']');
            raise;
    end;

    function get_number_value(
        i_param_name        in     com_api_type_pkg.t_name
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
            trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_ref_cur_base->get_number_value FAILED with i_param_name ['||i_param_name||']');
            raise;
    end;

begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || ', i_tab_name = "' || i_tab_name || '"');
    --utl_data_pkg.print_table(i_param_tab => i_param_tab); -- dumping collection, DEBUG logging level is required

    if i_tab_name = 'MERCHANT' then
        l_merchant_id := get_number_value('MERCHANT_ID');
        if l_merchant_id is not null then
            l_ref_source := l_ref_source || ' and m.id = '|| get_string('MERCHANT_ID', com_api_const_pkg.FALSE);
        end if;
        
        l_inst_id := get_number_value('INST_ID');
        if l_inst_id is not null then
            l_ref_source := l_ref_source || ' and m.inst_id = '|| get_string('INST_ID', com_api_const_pkg.FALSE);
        end if;
        
        l_merchant_number := get_string('MERCHANT_NUMBER');
        if l_merchant_number is not null then
            l_ref_source := l_ref_source || l_merchant_number;
        end if;
        
        l_customer_id := get_number_value('CUSTOMER_ID');
        if l_customer_id is not null then
            l_ref_source := l_ref_source || ' and cu.id = '|| get_string('CUSTOMER_ID', com_api_const_pkg.FALSE);
        end if;
        
        l_customer_number := get_string('CUSTOMER_NUMBER', i_upper_reverse => com_api_type_pkg.TRUE);
        if l_customer_number is not null then
            l_ref_source := l_ref_source || l_customer_number;
        end if;
        
        l_status := get_char_value('STATUS');
        if l_status is not null then
            l_ref_source := l_ref_source || ' and m.status = ' || get_string('STATUS', com_api_const_pkg.FALSE);
        end if;                

        l_merchant_type := get_char_value('MERCHANT_TYPE');
        if l_merchant_type is not null then
            l_ref_source := l_ref_source || ' and m.merchant_type = ' || get_string('MERCHANT_TYPE', com_api_const_pkg.FALSE);
        end if;                
        
        l_company_name := get_char_value('COMPANY_NAME');
        if l_company_name is not null then
            -- l_ref_source := l_ref_source || ' and lower(nvl(get_text(''com_company'', ''label'', cu.object_id, p_lang), ''%'')) like lower(p_company_name)';

            l_ref_source := l_ref_source || ' and cu.entity_type = ''' || com_api_const_pkg.ENTITY_TYPE_COMPANY || '''';
            l_ref_source := l_ref_source || ' and cu.object_id in (';
            l_ref_source := l_ref_source || '     select object_id';
            l_ref_source := l_ref_source || '       from com_i18n a';
            l_ref_source := l_ref_source || '      where table_name  = ''COM_COMPANY''';
            l_ref_source := l_ref_source || '        and column_name = ''LABEL''';
            l_ref_source := l_ref_source || '        and lower(nvl(text, ''%'')) like lower(x.p_company_name)';
            l_ref_source := l_ref_source || '        and (select min(ca.lang) keep (dense_rank first order by decode(ca.lang, x.p_lang, 1, ''LANGENG'', 2, 3))';
            l_ref_source := l_ref_source || '               from com_i18n ca';
            l_ref_source := l_ref_source || '              where ca.table_name  = a.table_name';
            l_ref_source := l_ref_source || '                and ca.column_name = a.column_name';
            l_ref_source := l_ref_source || '                and ca.object_id   = a.object_id';
            l_ref_source := l_ref_source || '            ) = a.lang';
            l_ref_source := l_ref_source || ' )';

        end if;
        
    elsif i_tab_name = 'ACCOUNT' then
        l_account_id := get_number_value('ACCOUNT_ID');
        if l_account_id is not null then
            l_ref_source := l_ref_source || ' and m.id in (select object_id from acc_account_object where entity_type = ''ENTTMRCH'' and  account_id = ' || get_string('ACCOUNT_ID', com_api_const_pkg.FALSE) || ') ';
        else
            com_api_error_pkg.raise_error(
                i_error => 'NOT_ENOUGH_DATA_TO_FIND_MERCHANTS'
            );                            
        end if;

    elsif i_tab_name = 'CUSTOMER' then
        l_customer_id := get_number_value('CUSTOMER_ID');
        if l_customer_id is not null then
            l_ref_source := l_ref_source || ' and cu.id = '|| get_string('CUSTOMER_ID', com_api_const_pkg.FALSE);
        else
            com_api_error_pkg.raise_error(
                i_error => 'NOT_ENOUGH_DATA_TO_FIND_MERCHANTS'
            );                            
        end if;

    elsif i_tab_name = 'CONTRACT' then
        l_contract_id := get_number_value('CONTRACT_ID');
        if l_contract_id is not null then
            l_ref_source := l_ref_source || ' and m.contract_id = '|| get_string('CONTRACT_ID', com_api_const_pkg.FALSE);
        else
            com_api_error_pkg.raise_error(
                i_error => 'NOT_ENOUGH_DATA_TO_FIND_MERCHANTS'
            );                            
        end if;

    else
        com_api_error_pkg.raise_error(
            i_error => 'INVALID_TAB_NAME'
        );                            
    end if;
    
    l_ref_source := l_ref_source || ' and m.inst_id in (select inst_id from acm_cu_inst_vw) ';    
    
    trc_log_pkg.debug('PRIVIL_LIMITATION: '|| get_char_value('PRIVIL_LIMITATION'));
    l_privil_limitation := ' and '|| nvl( get_char_value('PRIVIL_LIMITATION'), ' 1 = 1');
    l_ref_source := l_ref_source || l_privil_limitation;
    
    l_sorting_source := get_sorting_param(i_sorting_tab); 
    
    l_ref_query := 'select m.* '                                                                                              ||
                   ', get_text(''acq_merchant'', ''label'', m.id, m.lang) as label'                                           ||
                   ', get_text(''acq_merchant'', ''description'', m.id, m.lang) as description'                               ||    
                   ', get_text(''prd_product'', ''label'', m.product_id, m.lang) as product_name'                             ||
                   ', get_text(''ost_institution'', ''name'', m.inst_id, m.lang) as inst_name'                                ||
                   ', get_text(''com_mcc'', ''name'', m.mcc_id, m.lang) as mcc_name'                                          ||
                   ' from ('                                                                                                  ||
                           ' select * from( '                                                                                 || 
                                    ' select a.*, rownum rn '                                                                 || 
                                       'from ( '                                                                              ||
                                            ' select * from ('                                                                ||                                                          
                                                'select * from ('                                                             ||
                                                    COLUMN_LIST || l_ref_source                                               || 
                                                ') '                                                                          ||
                                            ') ' || l_sorting_source                                                          ||
                                    ') a '                                                                                    ||
                         ' ) where rn between :p_first_row and :p_last_row '                                                  ||
                   ') m'
                   ;
     
    if  i_is_first_call = com_api_const_pkg.TRUE then
        l_ref_source := 'select count(1) '|| l_ref_source;

        trc_log_pkg.debug(l_ref_source);

        execute immediate l_ref_source
        into o_row_count
        using
            get_char_value('LANG')
          , l_inst_id 
          , get_char_value('MERCHANT_NUMBER')
          , upper(get_char_value('CUSTOMER_NUMBER'))
          , l_customer_id 
          , l_status 
          , l_merchant_type 
          , l_company_name 
          , l_account_id 
          , l_merchant_id
          , l_contract_id
        ;
    else
        trc_log_pkg.debug(l_ref_query);

        open o_ref_cur for l_ref_query
        using
            get_char_value('LANG')
          , l_inst_id 
          , get_char_value('MERCHANT_NUMBER')
          , upper(get_char_value('CUSTOMER_NUMBER'))
          , l_customer_id 
          , l_status 
          , l_merchant_type 
          , l_company_name 
          , l_account_id 
          , l_merchant_id
          , l_contract_id
          , i_first_row
          , i_last_row;
    end if;

exception
    when others then
        trc_log_pkg.debug(
            i_text => lower($$PLSQL_UNIT) || '.get_ref_cur_base FAILED: i_tab_name ['||i_tab_name||']:' || CRLF
                   || 'i_is_first_call ['||i_is_first_call||']' || CRLF
                   || 'l_inst_id ['||l_inst_id||']' || CRLF
                   || 'l_customer_id ['||l_customer_id||']' || CRLF
                   || 'l_account_id ['||l_account_id||']' || CRLF
                   || 'l_merchant_id ['||l_merchant_id||']' || CRLF
                   || 'l_merchant_number ['||l_merchant_number||']' || CRLF
                   || 'l_customer_number ['||l_customer_number||']' || CRLF
                   || 'l_status ['||l_status||']' || CRLF
                   || 'l_merchant_type ['||l_merchant_type||']' || CRLF
                   || 'l_company_name ['||l_company_name||']' || CRLF
                   || 'l_contract_id ['||l_contract_id||']' || CRLF
                   || 'i_first_row ['||i_first_row||']' || CRLF
                   || 'i_last_row ['||i_last_row||'];' || CRLF
                   || 'dumping i_param_tab for debug...'
        );
        utl_data_pkg.print_table(i_param_tab => i_param_tab); -- dumping collection, DEBUG logging level is required
        raise;
end;

procedure get_ref_cur(
    o_ref_cur              out  com_api_type_pkg.t_ref_cur
  , i_row_count         in      com_api_type_pkg.t_medium_id  default null
  , i_first_row         in      com_api_type_pkg.t_tiny_id
  , i_last_row          in      com_api_type_pkg.t_tiny_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt             default null
) is
    l_row_count                 com_api_type_pkg.t_medium_id;
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
    o_row_count            out  com_api_type_pkg.t_medium_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
) is
    l_ref_cur                   com_api_type_pkg.t_ref_cur;
    l_sorting_tab               com_param_map_tpt;
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

end acq_ui_merchant_search_pkg;
/
