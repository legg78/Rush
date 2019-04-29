create or replace package body utl_data_pkg as
/*********************************************************
*  Unloading data <br />
*  Created by Filimonov A.(filimonov@bpc.ru)  at 09.10.2009 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: utl_data_pkg <br />
*  @headcom
**********************************************************/

type t_tab_column_tab is table of com_tab_column_tpr index by binary_integer;

procedure data_from_table (
    i_owner             in      com_api_type_pkg.t_oracle_name
  , i_table_name        in      com_api_type_pkg.t_oracle_name
  , i_where_clause      in      com_api_type_pkg.t_full_desc        default null
  , i_order_clause      in      com_api_type_pkg.t_full_desc        default null
  , i_clob_output       in      com_api_type_pkg.t_boolean          default null
  , i_export_clob       in      com_api_type_pkg.t_boolean
  , io_source           in out  nocopy clob
) is
    l_tab_column_tab    t_tab_column_tab;
    l_row_count         pls_integer := 0;
    --l_count             pls_integer := 0;
    l_sql_source        com_api_type_pkg.t_sql_statement;
    l_cursor            integer;
    l_result            integer;
    --l_col_desc_tab      dbms_sql.desc_tab;
    l_field_value_v     com_api_type_pkg.t_text;
    l_field_value_c     com_api_type_pkg.t_text;
    l_field_value_n     number;
    l_field_value_d     date;
    l_field_value_t     timestamp;
    l_insert_source     com_api_type_pkg.t_sql_statement;
    l_values_source     com_api_type_pkg.t_sql_statement;
    l_format            com_api_type_pkg.t_text;
    l_stmt              com_api_type_pkg.t_sql_statement;
    l_order_clause      com_api_type_pkg.t_sql_statement;
begin
    trc_log_pkg.debug (
        i_text      => 'Request to extract data from table ' || i_owner || '.' || i_table_name
    );
    l_order_clause := i_order_clause;
    dbms_output.enable(buffer_size => NULL);

    select com_tab_column_tpr(column_name, data_type, data_length, data_precision, data_scale)
      bulk collect into l_tab_column_tab
      from all_tab_columns
     where owner        = upper(i_owner)
       and table_name   = upper(i_table_name)
       and column_name != 'PART_KEY'
     order by column_id;

    if l_tab_column_tab.count = 0 then
        trc_log_pkg.debug (
            i_text      => ':( No columns found for table ' || i_owner || '.' || i_table_name
        );
        return;
    end if;

    for i in 1..l_tab_column_tab.count loop
        l_sql_source := l_sql_source || l_tab_column_tab(i).column_name || ', ';
        if upper(l_tab_column_tab(i).column_name) = 'ID' and l_order_clause is null then
            l_order_clause := 'order by id';
        end if;
    end loop;

    l_sql_source := rtrim(l_sql_source, ', ');

    l_sql_source := 'select '||l_sql_source||' from '||i_owner||'.'||i_table_name||' '||i_where_clause||' '||l_order_clause;

    trc_log_pkg.debug (l_sql_source );

    l_cursor := dbms_sql.open_cursor(
                    security_level => 1
                );

    begin
        dbms_sql.parse(l_cursor, l_sql_source, dbms_sql.NATIVE);
    exception
        when others then
            com_api_error_pkg.raise_error (
                i_error       => 'UNABLE_TO_PARSE_STATEMENT'
              , i_env_param1  => l_sql_source
              , i_env_param2  => sqlerrm
            );
    end;

    for i in 1..l_tab_column_tab.count loop
        if l_tab_column_tab(i).data_type = 'VARCHAR2' then --
            dbms_sql.define_column(l_cursor, i, l_field_value_v, l_tab_column_tab(i).data_length);
        elsif i_export_clob = com_api_const_pkg.TRUE and l_tab_column_tab(i).data_type = 'CLOB' then --
            dbms_sql.define_column(l_cursor, i, l_field_value_c, l_tab_column_tab(i).data_length);
        elsif l_tab_column_tab(i).data_type = 'NUMBER' then --
            dbms_sql.define_column(l_cursor, i, l_field_value_n);
        elsif l_tab_column_tab(i).data_type = 'DATE' then --
            dbms_sql.define_column(l_cursor, i, l_field_value_d);
        elsif l_tab_column_tab(i).data_type = 'TIMESTAMP(6)' then --
            dbms_sql.define_column(l_cursor, i, l_field_value_t);
        end if;
    end loop;
--    dbms_sql.describe_columns(l_cursor, l_count, l_col_desc_tab);

    l_result := dbms_sql.execute(l_cursor);

    loop
        if dbms_sql.fetch_rows(l_cursor) > 0 then

            l_row_count := l_row_count + 1;
            l_insert_source := null;
            l_values_source := null;

            for i in 1..l_tab_column_tab.count loop

                if l_tab_column_tab(i).data_type = 'VARCHAR2' then --
                    dbms_sql.column_value(l_cursor, i, l_field_value_v);
                    if l_field_value_v is not null then
                        l_field_value_v := ''''||replace(l_field_value_v, '''', '''''')||'''';
                    else
                        l_field_value_v := 'NULL';
                    end if;
                elsif i_export_clob = com_api_const_pkg.TRUE and l_tab_column_tab(i).data_type = 'CLOB' then --
                    begin
                        dbms_sql.column_value(l_cursor, i, l_field_value_c);
                        if l_field_value_c is not null and length(l_field_value_c) < 4000 then
                            l_field_value_v := ''''||replace(to_char(l_field_value_c), '''', '''''')||'''';
                        else
                            l_field_value_v := 'NULL';
                        end if;
                    exception
                        when others then
                            l_field_value_v := 'NULL';
                    end;
                elsif l_tab_column_tab(i).data_type = 'NUMBER' then --
--                    dbms_output.put_line(i||' '||l_tab_column_tab(i).column_name);
                    dbms_sql.column_value(l_cursor, i, l_field_value_n);

                    if l_field_value_n is not null then
                        if l_tab_column_tab(i).data_precision is not null then
                            l_format := lpad('0', l_tab_column_tab(i).data_precision - l_tab_column_tab(i).data_scale, '9');
                            if l_tab_column_tab(i).data_scale > 0 then
                                l_format := l_format||'D'||rpad('0', l_tab_column_tab(i).data_scale, '9');
                            end if;
                        else
                            l_format := 'FM'||lpad('0', l_tab_column_tab(i).data_length, '9')||'D'||rpad('9', l_tab_column_tab(i).data_length, '9');
                        end if;
                        l_field_value_v := trim(to_char(l_field_value_n, l_format, 'NLS_NUMERIC_CHARACTERS = ''. '''));
                        l_field_value_v := rtrim(l_field_value_v, '.');
                    else
                        l_field_value_v := 'NULL';
                    end if;
                    if l_tab_column_tab(i).column_name = 'SEQNUM' then
                         l_field_value_v := '1';
                    end if;
                elsif l_tab_column_tab(i).data_type = 'DATE' then --
                    dbms_sql.column_value(l_cursor, i, l_field_value_d);
                    if l_field_value_d is not null then
                        l_format := 'yyyy.mm.dd hh24:mi:ss';
                        l_field_value_v := 'to_date('''||to_char(l_field_value_d, l_format)||''', '''||l_format||''')';
                    else
                        l_field_value_v := 'NULL';
                    end if;
                elsif l_tab_column_tab(i).data_type = 'TIMESTAMP(6)' then --
                    dbms_sql.column_value(l_cursor, i, l_field_value_t);
                    if l_field_value_t is not null then
                        l_format :=  'dd.mm.yyyy hh24:mi:ss.ff';
                        l_field_value_v := 'to_timestamp('''||to_char(l_field_value_t, l_format)||''', '''||l_format||''')';
                    else
                        l_field_value_v := 'NULL';
                    end if;
                else
                    l_field_value_v := 'NULL';
                end if;

                l_insert_source := l_insert_source || l_tab_column_tab(i).column_name || ', ';
                l_values_source := l_values_source || l_field_value_v || ', ';
            end loop;

            l_insert_source := lower(rtrim(l_insert_source, ', '));
            l_values_source := rtrim(l_values_source, ', ');

            l_stmt := 'insert into '||lower(i_table_name)||' ('||l_insert_source||') values ('||l_values_source||')';

            if i_clob_output = com_api_const_pkg.TRUE then
                dbms_lob.writeappend(io_source, length(l_stmt||chr(10)), l_stmt||chr(10));
                dbms_lob.writeappend(io_source, length('/'||chr(10)), '/'||chr(10));
            else
                loop
                    exit when length(l_stmt) <= 255;
                    dbms_output.put(substr(l_stmt, 1, 255));
                    l_stmt := substr(l_stmt, 256);
                end loop;
                dbms_output.put_line(l_stmt);
                dbms_output.put_line('/');
            end if;
        else
            exit;
        end if;
    end loop;

    trc_log_pkg.debug ( i_text      => 'Fetched rows: ' || l_row_count );

    dbms_sql.close_cursor(l_cursor);

    if upper(i_table_name) != 'COM_I18N' and i_clob_output = com_api_const_pkg.FALSE then
        data_from_table(
            i_owner         => i_owner
          , i_table_name    => 'COM_I18N'
          , i_where_clause  => 'where table_name = '''||upper(i_table_name)||''' and object_id in (select id from '||upper(i_owner) || '.' ||upper(i_table_name)||' '||i_where_clause||')'
          , i_order_clause  => 'order by lang, id'
          , i_clob_output   => i_clob_output
          , i_export_clob   => i_export_clob
          , io_source       => io_source
        );

    end if;
/*exception
    when others then
        if cu_tab_columns%isopen then
            close cu_tab_columns;
        end if;

        if  dbms_sql.is_open(l_cursor) then
            dbms_sql.close_cursor(l_cursor);
        end if;

        raise;
*/
end data_from_table;

procedure data_from_table (
    i_owner             in      com_api_type_pkg.t_oracle_name
  , i_table_name        in      com_api_type_pkg.t_oracle_name
  , i_where_clause      in      com_api_type_pkg.t_full_desc        default null
  , i_order_clause      in      com_api_type_pkg.t_full_desc        default null
  , i_export_clob       in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
) is
    l_source            clob;
begin
    data_from_table (
        i_owner             => i_owner
      , i_table_name        => i_table_name
      , i_where_clause      => i_where_clause
      , i_order_clause      => i_order_clause
      , i_clob_output       => com_api_const_pkg.FALSE
      , i_export_clob       => i_export_clob
      , io_source           => l_source
    );
end data_from_table;

procedure data_from_table (
    i_owner             in      com_api_type_pkg.t_oracle_name
  , i_table_name        in      com_api_type_pkg.t_oracle_name
  , i_where_clause      in      com_api_type_pkg.t_full_desc        default null
  , i_order_clause      in      com_api_type_pkg.t_full_desc        default null
  , i_export_clob       in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , io_source           in out  nocopy clob
) is
begin
    data_from_table (
        i_owner             => i_owner
      , i_table_name        => i_table_name
      , i_where_clause      => i_where_clause
      , i_order_clause      => i_order_clause
      , i_clob_output       => com_api_const_pkg.TRUE
      , i_export_clob       => i_export_clob
      , io_source           => io_source
    );
end data_from_table;

procedure print_table (
    i_param_tab         in      com_param_map_tpt
) is
    l_param_type        com_api_type_pkg.t_oracle_name;
    l_param_value       com_api_type_pkg.t_param_value;
begin
    -- There is no sense to look through whole collection i_param_tab if logging level doesn't set to DEBUG
    if trc_config_pkg.is_debug = com_api_type_pkg.TRUE and i_param_tab is not null then
        trc_log_pkg.debug('****Start print parameter table****');
        begin
            trc_log_pkg.debug('Check parameter count: ' || i_param_tab.count );
            if i_param_tab.count > 0 then
                for i in i_param_tab.first .. i_param_tab.last loop
                    case
                        when i_param_tab(i).char_value is not null then 
                            l_param_type := 'char';
                            l_param_value := i_param_tab(i).char_value;

                        when i_param_tab(i).number_value is not null then
                            l_param_type := 'number';
                            l_param_value := to_char(i_param_tab(i).number_value, com_api_const_pkg.NUMBER_FORMAT);

                        when i_param_tab(i).date_value is not null then
                            l_param_type := 'date';
                            l_param_value := to_char(i_param_tab(i).date_value, com_api_const_pkg.DATE_FORMAT);

                        else
                            l_param_type := 'UNDEFINED';
                            l_param_value := null;
                    end case;
                    trc_log_pkg.debug(
                        i_text       => 'Param [#4] value #2 = #1, condition [#3]'
                      , i_env_param1 => case
                                            when i_param_tab(i).name like '%CARD_NUMBER%'
                                            then iss_api_card_pkg.get_card_mask(i_card_number => l_param_value)
                                            else l_param_value
                                        end 
                      , i_env_param2 => i_param_tab(i).name
                      , i_env_param3 => i_param_tab(i).condition
                      , i_env_param4 => l_param_type
                    );
                end loop;
            end if;
        exception
            when others then
                trc_log_pkg.warn(
                    i_text       => 'Printing failed with sqlerrm [#1]'
                  , i_env_param1 => sqlerrm
                );
        end;
        trc_log_pkg.debug('****End print parameter table****');
    end if;
end print_table;

end utl_data_pkg;
/
