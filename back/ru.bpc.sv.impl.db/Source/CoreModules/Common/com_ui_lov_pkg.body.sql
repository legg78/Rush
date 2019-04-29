create or replace package body com_ui_lov_pkg as
/*********************************************************
 *  UI for LOVs <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 01.10.2009 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: com_ui_lov_pkg   <br />
 *  @headcom
 **********************************************************/

type t_context_param_tab is table of com_param_map_tpr index by com_api_type_pkg.t_name;

g_param_tab  t_context_param_tab;

function get_char_param(
    i_param_name        in      com_api_type_pkg.t_name
) return com_api_type_pkg.t_param_value
is
    l_result  com_api_type_pkg.t_param_value;
begin
    if i_param_name is not null then
        l_result := g_param_tab(i_param_name).char_value;
    end if;
    return l_result;
end get_char_param;

function get_number_param(
    i_param_name        in      com_api_type_pkg.t_name
) return com_api_type_pkg.t_long_id
is
    l_result  com_api_type_pkg.t_long_id;
begin
    if i_param_name is not null then
        l_result := g_param_tab(i_param_name).number_value;
    end if;
    return l_result;
end get_number_param;

function get_date_param(
    i_param_name        in      com_api_type_pkg.t_name
) return date
is
    l_result  date;
begin
    if i_param_name is not null then
        l_result := g_param_tab(i_param_name).date_value;
    end if;
    return l_result;
end get_date_param;

procedure get_lov_sql_statement(
    o_sql_statement        out  com_api_type_pkg.t_text
  , i_lov_id            in      com_api_type_pkg.t_tiny_id
  , i_param_map         in      com_param_map_tpt
  , i_add_where         in      com_api_type_pkg.t_text
  , i_appearance        in      com_api_type_pkg.t_dict_value    default null
) is
    --LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_lov_sql_statement';
    l_where_clause              com_api_type_pkg.t_full_desc;
    l_order_by                  com_api_type_pkg.t_full_desc;
    l_order_by_pos              com_api_type_pkg.t_short_id;
    l_connect_by_pos            com_api_type_pkg.t_short_id;
    l_appearance                com_api_type_pkg.t_dict_value;
    l_sort_mode                 com_api_type_pkg.t_dict_value;
    l_distinct                  com_api_type_pkg.t_oracle_name; -- use or not distinct in select-query from LOV
    l_is_depended               com_api_type_pkg.t_boolean;
begin
    g_param_tab.delete;

    begin
        select nvl2(
                   dict
                 , 'select dict||code code, name from com_ui_dictionary_vw where dict = ''' || dict
                   || ''' and lang = com_ui_user_env_pkg.get_user_lang'
                 , nvl(lov_query, 'select to_char(null) code, to_char(null) name from dual where 1=0')
               )
             , lov_query -- for order by clause
             , instr(lov_query, 'order by', instr(lov_query, 'from', -1 ))
             , instr(lov_query, 'connect by' )
             , sort_mode
             , coalesce(i_appearance, appearance) appearance
             , is_depended
          into o_sql_statement
             , l_order_by
             , l_order_by_pos
             , l_connect_by_pos
             , l_sort_mode
             , l_appearance
             , l_is_depended
          from com_lov_vw
         where id = i_lov_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error       => 'LOV_NOT_FOUND'
              , i_env_param1  => i_lov_id
            );
    end;

--    trc_log_pkg.debug(
--        i_text       => LOG_PREFIX || ' << i_lov_id [#2], l_sort_mode [#3], l_order_by_pos [#4], '
--                                   || 'l_connect_by_pos [#5], l_appearance [#6], o_sql_statement [#1]'
--      , i_env_param1 => o_sql_statement
--      , i_env_param2 => i_lov_id
--      , i_env_param3 => l_sort_mode
--      , i_env_param4 => l_order_by_pos
--      , i_env_param5 => l_connect_by_pos
--      , i_env_param6 => l_appearance
--    );

    if i_param_map is not null then
        for i in 1..i_param_map.count loop

            if l_is_depended = com_api_type_pkg.TRUE then
                g_param_tab(i_param_map(i).name) := i_param_map(i);

            else
                l_where_clause := l_where_clause || ' and ';

                if i_param_map(i).char_value is not null then
                    l_where_clause := l_where_clause
                                   || i_param_map(i).name || ' '
                                   || nvl(i_param_map(i).condition, ' = ')
                                   || '''' || i_param_map(i).char_value || '''';

                elsif i_param_map(i).number_value is not null then
                    if upper(i_param_map(i).name) = 'INSTITUTION_ID' then
                        l_where_clause := l_where_clause
                                       || i_param_map(i).name || ' '
                                       || nvl(i_param_map(i).condition, ' in ')
                                       || ' (9999, to_number('''
                                       || to_char(i_param_map(i).number_value, com_api_const_pkg.NUMBER_FORMAT)
                                       || ''', ''' || com_api_const_pkg.NUMBER_FORMAT|| '''))';
                        -- It is necessary to use <distinct> to prevent doubling parameters
                        -- that are defined in both the default institution and <INSTITUTION_ID>
                        l_distinct := 'distinct';
                    else
                        l_where_clause := l_where_clause
                                       || i_param_map(i).name || ' '
                                       || nvl(i_param_map(i).condition, ' = ')
                                       || ' to_number('''
                                       || to_char(i_param_map(i).number_value, com_api_const_pkg.NUMBER_FORMAT)
                                       || ''', ''' || com_api_const_pkg.NUMBER_FORMAT || ''')';
                    end if;

                elsif i_param_map(i).date_value is not null then
                    l_where_clause := l_where_clause
                                   || i_param_map(i).name || ' '
                                   || nvl(i_param_map(i).condition, ' = ')
                                   || ' to_date('''
                                   || to_char(i_param_map(i).date_value, com_api_const_pkg.DATE_FORMAT)
                                   || ''', ''' || com_api_const_pkg.DATE_FORMAT || ''')';
                else
                    l_where_clause := l_where_clause || '1=1';
                end if;

            end if;

        end loop;
    end if;
    --trc_log_pkg.debug('l_where_clause [' || l_where_clause || ']');

    if l_order_by_pos > 0 then
        -- Restriction for using distinct with special order-by clause is necessary to prevent ORA-01791
        l_distinct := null;
        l_order_by := substr(l_order_by, l_order_by_pos);

    elsif l_connect_by_pos > 0 then
        l_distinct := null;
        l_order_by := null;

    else
        l_order_by := 
            case nvl(l_sort_mode, com_api_const_pkg.LOV_SORT_DEFAULT)
                when com_api_const_pkg.LOV_SORT_NAME      then ' order by name, code'
                when com_api_const_pkg.LOV_SORT_CODE      then ' order by code nulls first, name'
                when com_api_const_pkg.LOV_SORT_NAME_DESC then ' order by name desc, code desc'
                when com_api_const_pkg.LOV_SORT_CODE_DESC then ' order by code desc, name desc'
                                                          else ' order by nvl(name, code)'
            end;
    end if;

    o_sql_statement := 'select ' || l_distinct
                    || case nvl(l_appearance, com_api_const_pkg.LOV_APPEARANCE_DEFAULT)
                           when com_api_const_pkg.LOV_APPEARANCE_NAME      then ' code, name'
                           when com_api_const_pkg.LOV_APPEARANCE_CODE      then ' code, code as name'
                           when com_api_const_pkg.LOV_APPEARANCE_CODE_NAME then ' code, code || '' - '' || name as name'
                           when com_api_const_pkg.LOV_APPEARANCE_NAME_CODE then ' code, name || '' - '' || code as name'
                       end
                    || ' from (' || o_sql_statement || ') i where 1=1';

    o_sql_statement := o_sql_statement
                    || l_where_clause
                    || case when i_add_where is not null then ' and ' || i_add_where end
                    || ' ' || l_order_by;

    --trc_log_pkg.debug(LOG_PREFIX || ' >> o_sql_statement [' || o_sql_statement || ']');
end get_lov_sql_statement;

procedure get_lov(
    o_ref_cur              out  sys_refcursor
  , i_lov_id            in      com_api_type_pkg.t_tiny_id
  , i_param_map         in      com_param_map_tpt                   default null
  , i_add_where         in      com_api_type_pkg.t_text             default null
  , i_appearance        in      com_api_type_pkg.t_dict_value       default null
) is
    l_sql_statement             com_api_type_pkg.t_text;
begin
    get_lov_sql_statement(
        o_sql_statement  => l_sql_statement
      , i_lov_id         => i_lov_id
      , i_param_map      => i_param_map
      , i_add_where      => trim(i_add_where)
      , i_appearance     => i_appearance
    );

    begin
        open o_ref_cur for l_sql_statement;
    exception
        when others then
            utl_data_pkg.print_table(
                i_param_tab   => i_param_map
            );
            com_api_error_pkg.raise_error(
                i_error       => 'EXEC_LOV_QUERY_ERROR'
              , i_env_param1  => substr(l_sql_statement, 1, 2000)
              , i_env_param2  => substr(sqlerrm, 1, 200)
            );
    end;
end get_lov;

procedure get_lov_codes(
    o_code_tab             out  com_api_type_pkg.t_name_tab
  , i_lov_id            in      com_api_type_pkg.t_tiny_id
  , i_param_map         in      com_param_map_tpt                   default null
  , i_add_where         in      com_api_type_pkg.t_text             default null
) is
    l_sql_statement             com_api_type_pkg.t_text;
    l_cursor                    sys_refcursor;
    l_name_tab                  com_api_type_pkg.t_desc_tab;
begin
    get_lov_sql_statement(
        o_sql_statement  => l_sql_statement
      , i_lov_id         => i_lov_id
      , i_param_map      => i_param_map
      , i_add_where      => trim(i_add_where)
    );

    begin
        open  l_cursor for l_sql_statement;
        fetch l_cursor bulk collect into o_code_tab, l_name_tab;
        close l_cursor;
    exception
        when others then
            if l_cursor%isopen then
                close l_cursor;
            end if;
            utl_data_pkg.print_table(
                i_param_tab   => i_param_map
            );
            com_api_error_pkg.raise_error(
                i_error       => 'EXEC_LOV_QUERY_ERROR'
              , i_env_param1  => substr(l_sql_statement, 1, 2000)
              , i_env_param2  => substr(sqlerrm, 1, 200)
            );
    end;
end get_lov_codes;

function get_name(
    i_lov_id            in      com_api_type_pkg.t_tiny_id
  , i_code              in      varchar2
  , i_param_map         in      com_param_map_tpt               default null
) return varchar2 is
    l_sql_source    com_api_type_pkg.t_text;
    l_where_clause  com_api_type_pkg.t_full_desc;
    l_orderby       com_api_type_pkg.t_full_desc := ' order by nvl(name, code)';
    l_pos           com_api_type_pkg.t_short_id;
    l_appearance    com_api_type_pkg.t_dict_value;
    l_sort_mode     com_api_type_pkg.t_dict_value;
    l_result        com_api_type_pkg.t_text;
begin
    begin
        select nvl2(
                  dict
                , 'select distinct dict||code code, get_text(''com_dictionary'', ''name'', id ) name from com_dictionary where dict = '''||dict||''''
                , nvl(lov_query, 'select to_char(null) code, to_char(null) name from dual where 1=0')
               )
          into l_sql_source
          from com_lov_vw
         where id = i_lov_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error       => 'LOV_NOT_FOUND'
              , i_env_param1  => i_lov_id
            );
    end;

    if i_param_map is not null then
        for i in 1..i_param_map.count loop
            l_where_clause := l_where_clause || ' and ';

            if i_param_map(i).char_value is not null then

                l_where_clause := l_where_clause || i_param_map(i).name || ' = ''' ||
                    i_param_map(i).char_value || '''';

            elsif i_param_map(i).number_value is not null then

                l_where_clause := l_where_clause || i_param_map(i).name || ' = to_number(''' ||
                    to_char(i_param_map(i).number_value, com_api_const_pkg.NUMBER_FORMAT) || ''', ''' ||
                    com_api_const_pkg.NUMBER_FORMAT || ''')';

            elsif i_param_map(i).date_value is not null then

                l_where_clause := l_where_clause || i_param_map(i).name || ' = to_date(''' ||
                    to_char(i_param_map(i).date_value, com_api_const_pkg.DATE_FORMAT) || ''', ''' ||
                    com_api_const_pkg.DATE_FORMAT || ''')';
            else
                l_where_clause := l_where_clause || '1=1';
            end if;
        end loop;
    end if;

    select instr(lov_query, 'order by' ) s
         , sort_mode
         , appearance
      into l_pos
         , l_sort_mode
         , l_appearance
      from com_lov_vw
     where id = i_lov_id;

    if l_pos > 0 then
        select substr(lov_query, l_pos)
          into l_orderby
          from com_lov_vw
         where id = i_lov_id;
    else
        case nvl(l_sort_mode, com_api_const_pkg.LOV_SORT_DEFAULT)
            when com_api_const_pkg.LOV_SORT_NAME then l_orderby := ' order by i.name, i.code';
            when com_api_const_pkg.LOV_SORT_CODE then l_orderby := ' order by i.code, i.name';
            when com_api_const_pkg.LOV_SORT_NAME_DESC then l_orderby := ' order by i.name desc, i.code desc';
            when com_api_const_pkg.LOV_SORT_CODE_DESC then l_orderby := ' order by i.code desc, i.name desc';
        end case;
    end if;

    case nvl(l_appearance, com_api_const_pkg.LOV_APPEARANCE_DEFAULT)
        when com_api_const_pkg.LOV_APPEARANCE_NAME then l_sql_source := 'select name from (' || l_sql_source || ') i where 1=1';
        when com_api_const_pkg.LOV_APPEARANCE_CODE then l_sql_source := 'select code name from (' || l_sql_source || ') i where 1=1';
        when com_api_const_pkg.LOV_APPEARANCE_CODE_NAME then l_sql_source := 'select code || '' - '' || name name from (' || l_sql_source || ') i where 1=1';
        when com_api_const_pkg.LOV_APPEARANCE_NAME_CODE then l_sql_source := 'select name || '' - '' || code name from (' || l_sql_source || ') i where 1=1';
    end case;

    l_sql_source :=  l_sql_source || l_where_clause || ' and i.code=''' || i_code || ''' and rownum = 1';

    begin
        execute immediate l_sql_source into l_result;

        return l_result;
    exception
        when no_data_found then
            return null;
        when others then
            com_api_error_pkg.raise_error(
                i_error       => 'EXEC_LOV_QUERY_ERROR'
              , i_env_param1  => substr(l_sql_source, 1, 2000)
              , i_env_param2  => substr(sqlerrm, 1, 200)
            );
    end;
end get_name;


procedure add_lov(
    o_lov_id               out  com_api_type_pkg.t_tiny_id
  , i_dict              in      com_api_type_pkg.t_dict_value       default null
  , i_lov_query         in      com_api_type_pkg.t_full_desc        default null
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
  , i_short_desc        in      com_api_type_pkg.t_short_desc       default null
  , i_full_desc         in      com_api_type_pkg.t_full_desc        default null
  , i_module_code       in      com_api_type_pkg.t_module_code      default null
  , i_sort_mode         in      com_api_type_pkg.t_dict_value       default com_api_const_pkg.LOV_SORT_DEFAULT
  , i_appearance        in      com_api_type_pkg.t_dict_value       default com_api_const_pkg.LOV_APPEARANCE_DEFAULT
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
  , i_is_parametrized   in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
) is
    cu_ref_cursor       sys_refcursor;
    l_count             com_api_type_pkg.t_count := 0;
begin
    if i_dict is not null then

        begin
            select count(id)
              into l_count
              from com_dictionary
             where dict = 'DICT'
               and code = upper(i_dict);
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error       => 'DICTIONARY_NOT_EXISTS'
                  , i_env_param1  => upper(i_dict)
                );
        end;
    elsif i_lov_query is not null then
        begin
            open cu_ref_cursor for i_lov_query;
            close cu_ref_cursor;
        exception
            when others then
                com_api_error_pkg.raise_error(
                    i_error       => 'EXEC_LOV_QUERY_ERROR'
                  , i_env_param1  => substr(i_lov_query, 1, 2000)
                  , i_env_param2  => substr(sqlerrm, 1, 200)
                );
        end;

    else
        return;
    end if;

    select com_lov_seq.nextval into o_lov_id from dual;

    insert into com_lov_vw(
        id
      , dict
      , lov_query
      , module_code
      , sort_mode
      , appearance
      , data_type
      , is_parametrized
    ) values (
        o_lov_id
      , i_dict
      , i_lov_query
      , i_module_code
      , i_sort_mode
      , i_appearance
      , i_data_type
      , i_is_parametrized
    );

    if i_short_desc is not null then
        com_api_i18n_pkg.add_text(
            i_table_name   => 'com_lov'
          , i_column_name  => 'name'
          , i_object_id    => o_lov_id
          , i_lang         => i_lang
          , i_text         => i_short_desc
        );
    end if;

    if i_full_desc is not null then
        com_api_i18n_pkg.add_text(
            i_table_name   => 'com_lov'
          , i_column_name  => 'description'
          , i_object_id    => o_lov_id
          , i_lang         => i_lang
          , i_text         => i_full_desc
        );
    end if;

end add_lov;

procedure modify(
    i_lov_id            in      com_api_type_pkg.t_tiny_id
  , i_dict              in      com_api_type_pkg.t_dict_value
  , i_lov_query         in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_short_desc        in      com_api_type_pkg.t_short_desc
  , i_full_desc         in      com_api_type_pkg.t_full_desc
  , i_sort_mode         in      com_api_type_pkg.t_dict_value
  , i_appearance        in      com_api_type_pkg.t_dict_value
  , i_data_type         in      com_api_type_pkg.t_dict_value
  , i_is_parametrized   in      com_api_type_pkg.t_boolean
  , i_module_code       in      com_api_type_pkg.t_module_code      default null
) is
    cu_ref_cursor       sys_refcursor;
begin

    if i_lov_query is not null then
        begin
            open cu_ref_cursor for i_lov_query;
            close cu_ref_cursor;
        exception
            when others then
                com_api_error_pkg.raise_error(
                    i_error       => 'EXEC_LOV_QUERY_ERROR'
                  , i_env_param1  => substr(i_lov_query, 1, 2000)
                  , i_env_param2  => substr(sqlerrm, 1, 200)
                );
        end;
    end if;

    update com_lov_vw
       set dict            = i_dict
         , lov_query       = i_lov_query
         , sort_mode       = i_sort_mode
         , appearance      = i_appearance
         , data_type       = i_data_type
         , is_parametrized = i_is_parametrized
         , module_code     = nvl(i_module_code, module_code)
     where id              = i_lov_id;

    if i_short_desc is not null then
        com_api_i18n_pkg.add_text(
            i_table_name   => 'com_lov'
          , i_column_name  => 'name'
          , i_object_id    => i_lov_id
          , i_lang         => i_lang
          , i_text         => i_short_desc
        );
    end if;

    if i_full_desc is not null then
        com_api_i18n_pkg.add_text(
            i_table_name   => 'com_lov'
          , i_column_name  => 'description'
          , i_object_id    => i_lov_id
          , i_lang         => i_lang
          , i_text         => i_full_desc
        );
    end if;
end modify;

function check_lov_value(
    i_lov_id            in      com_api_type_pkg.t_tiny_id
  , i_value             in      com_api_type_pkg.t_text
) return com_api_type_pkg.t_boolean
is
    l_dict       com_api_type_pkg.t_dict_value;
    l_lov_query  com_api_type_pkg.t_full_desc;
    l_data_type  com_api_type_pkg.t_dict_value;
    l_lov_value  com_api_type_pkg.t_text;
    l_result     com_api_type_pkg.t_boolean := com_api_type_pkg.false;
begin
    select trim(dict)
         , lov_query
         , data_type
      into l_dict
         , l_lov_query
         , l_data_type
      from com_lov
     where id = i_lov_id;
    
    -- dict article or dynamic query
    if l_dict is not null then
        l_result := com_api_dictionary_pkg.check_article(
            i_dict    => l_dict
            , i_code  => i_value
        );
    else
        begin
            case l_data_type
                when com_api_const_pkg.DATA_TYPE_CHAR then
                    l_lov_query := 'select to_char(x.code) from (' || l_lov_query || ') x where x.code = to_char(:i_value)';
                when com_api_const_pkg.DATA_TYPE_NUMBER then
                    l_lov_query := 'select to_char(x.code) from (' || l_lov_query || ') x where x.code = :i_value';
            end case;
            --
            execute immediate l_lov_query into l_lov_value using i_value;
            --
            if l_lov_value is not null then 
                l_result := com_api_type_pkg.true;
            else
                l_result := com_api_type_pkg.false;
            end if;
        exception
            when others then
                trc_log_pkg.error(
                    i_text       => 'EXEC_LOV_QUERY_ERROR'
                  , i_env_param1  => substr(l_lov_query, 1, 2000)
                  , i_env_param2  => substr(sqlerrm, 1, 200)
                );
                l_result := com_api_type_pkg.false;
        end;
    end if;
    ---
    return l_result;
exception 
    when no_data_found then
        trc_log_pkg.error(
            i_text        => 'LOV_NOT_FOUND'
          , i_env_param1  => i_lov_id
        );
        return com_api_type_pkg.false;
    when others then
        trc_log_pkg.error(
            i_text        => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => SQLERRM
        );
        return com_api_type_pkg.false;
end check_lov_value;

function is_editable_lov(
    i_lov_id                  in     com_api_type_pkg.t_long_id
  , i_mask_error              in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_boolean
is
    l_res       com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
begin
    select nvl(l.is_editable, com_api_const_pkg.FALSE)
      into l_res
      from com_lov l
     where l.id = i_lov_id;

    return l_res;

exception 
    when no_data_found then
        if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error       => 'LOV_NOT_FOUND'
              , i_env_param1  => i_lov_id
            );
        else
            trc_log_pkg.debug(
                i_text       => 'List of values [#1] not found.'
              , i_env_param1 => i_lov_id
            );
            return com_api_const_pkg.FALSE;
        end if;
end is_editable_lov;

end com_ui_lov_pkg;
/
