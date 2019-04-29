create or replace package body cst_apc_prc_utl_data_pkg as

g_session_file_id           com_api_type_pkg.t_long_id;

type t_tab_column_tab is table of com_tab_column_tpr index by binary_integer;


procedure write_line (
    i_line           in     com_api_type_pkg.t_text
) is
begin
    if g_session_file_id is not null then
        prc_api_file_pkg.put_line(
            i_sess_file_id  => g_session_file_id
          , i_raw_data      => i_line
        );
    end if;
end write_line;


procedure add_mod_to_the_list (
    i_mod_id            in      com_api_type_pkg.t_tiny_id
  , io_mod_list         in out  com_api_type_pkg.t_tiny_tab
) is
    l_index         com_api_type_pkg.t_tiny_id;
    l_present       boolean := false;

    function get_index (
        i_mod_id   in      com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_tiny_id
    is
    begin
        return case
                   when i_mod_id < 0
                   then ceil(i_mod_id / rul_api_const_pkg.CAPACITY_OF_MOD_STATIC_PKG) - 1
                   else floor(i_mod_id / rul_api_const_pkg.CAPACITY_OF_MOD_STATIC_PKG) + 1
               end;
    end get_index;
begin
    l_index := get_index(i_mod_id);

    if io_mod_list.count > 0 then
        for i in io_mod_list.first .. io_mod_list.last loop
            if get_index(io_mod_list(i)) = l_index then
                l_present := true;
                exit;
            end if;
        end loop;
    end if;

    if not l_present then
        io_mod_list(io_mod_list.count + 1) := i_mod_id;
    end if;
end add_mod_to_the_list;


procedure create_mod_static_pkg (
    i_mod_list          in      com_api_type_pkg.t_tiny_tab
) is
begin
    if i_mod_list.count > 0 then
        write_line('begin');
        for i in i_mod_list.first .. i_mod_list.last loop
            write_line('    rul_mod_gen_pkg.generate_package(i_mod_id  => ' || i_mod_list(i) || ', i_is_modification => 1);');
        end loop;
        write_line('    rul_mod_gen_pkg.generate_package(i_mod_id  => ' || i_mod_list(i_mod_list.last) || ', i_is_modification => 0);');
        write_line('end;');
        write_line('/');
    end if;
end create_mod_static_pkg;


procedure data_from_table (
    i_owner             in      com_api_type_pkg.t_oracle_name
  , i_table_name        in      com_api_type_pkg.t_oracle_name
  , i_where_clause      in      com_api_type_pkg.t_full_desc        default null
  , i_order_clause      in      com_api_type_pkg.t_full_desc        default null
  , i_export_clob       in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , i_merge_commands    in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
) is
    l_tab_column_tab    t_tab_column_tab;
    l_row_count         pls_integer := 0;
    l_sql_source        com_api_type_pkg.t_sql_statement;
    l_cursor            integer;
    l_result            integer;
    l_field_value_v     com_api_type_pkg.t_text;
    l_field_value_c     com_api_type_pkg.t_text;
    l_field_value_n     number;
    l_field_value_d     date;
    l_field_value_t     timestamp;
    l_insert_source     com_api_type_pkg.t_sql_statement;
    l_update_source     com_api_type_pkg.t_sql_statement;
    l_merge_ins_source  com_api_type_pkg.t_sql_statement;
    l_values_source     com_api_type_pkg.t_sql_statement;
    l_format            com_api_type_pkg.t_text;
    l_stmt              com_api_type_pkg.t_sql_statement;
    l_order_clause      com_api_type_pkg.t_sql_statement;
    l_id                com_api_type_pkg.t_large_id;
begin
    trc_log_pkg.debug (
        i_text      => 'Request to extract data from table ' || i_owner || '.' || i_table_name
    );
    l_order_clause := i_order_clause;

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

    trc_log_pkg.debug (l_sql_source);

    l_cursor :=
        dbms_sql.open_cursor(
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
        if l_tab_column_tab(i).data_type = 'VARCHAR2' then
            dbms_sql.define_column(l_cursor, i, l_field_value_v, l_tab_column_tab(i).data_length);
        elsif i_export_clob = com_api_const_pkg.TRUE and l_tab_column_tab(i).data_type = 'CLOB' then
            dbms_sql.define_column(l_cursor, i, l_field_value_c, l_tab_column_tab(i).data_length);
        elsif l_tab_column_tab(i).data_type = 'NUMBER' then
            dbms_sql.define_column(l_cursor, i, l_field_value_n);
        elsif l_tab_column_tab(i).data_type = 'DATE' then
            dbms_sql.define_column(l_cursor, i, l_field_value_d);
        elsif l_tab_column_tab(i).data_type = 'TIMESTAMP(6)' then
            dbms_sql.define_column(l_cursor, i, l_field_value_t);
        end if;
    end loop;

    l_result := dbms_sql.execute(l_cursor);

    loop
        if dbms_sql.fetch_rows(l_cursor) > 0 then

            l_row_count := l_row_count + 1;
            l_insert_source := null;
            l_update_source := null;
            l_merge_ins_source := null;
            l_values_source := null;
            l_id := null;

            for i in 1..l_tab_column_tab.count loop

                if l_tab_column_tab(i).data_type = 'VARCHAR2' then
                    dbms_sql.column_value(l_cursor, i, l_field_value_v);
                    if l_field_value_v is not null then
                        l_field_value_v := replace(l_field_value_v, '&', ''' || ''&'' || ''');
                        l_field_value_v := ''''||replace(l_field_value_v, '''', '''''')||'''';
                    else
                        l_field_value_v := 'NULL';
                    end if;
                elsif i_export_clob = com_api_const_pkg.TRUE and l_tab_column_tab(i).data_type = 'CLOB' then
                    begin
                        dbms_sql.column_value(l_cursor, i, l_field_value_c);
                        if l_field_value_c is not null and length(l_field_value_c) < 4000 then
                            l_field_value_v := replace(to_char(l_field_value_c), '&', ''' || ''&'' || ''');
                            l_field_value_v := ''''||replace(l_field_value_v, '''', '''''')||'''';
                        else
                            l_field_value_v := 'NULL';
                        end if;
                    exception
                        when others then
                            l_field_value_v := 'NULL';
                    end;
                elsif l_tab_column_tab(i).data_type = 'NUMBER' then
                    dbms_sql.column_value(l_cursor, i, l_field_value_n);

                    if l_field_value_n is not null then
                        if l_tab_column_tab(i).data_precision is not null then
                            l_format := lpad('0', l_tab_column_tab(i).data_precision - l_tab_column_tab(i).data_scale, '9');
                            if l_tab_column_tab(i).data_scale > 0 then
                                l_format := l_format || 'D' || rpad('0', l_tab_column_tab(i).data_scale, '9');
                            end if;
                        else
                            l_format := 'FM' || lpad('0', l_tab_column_tab(i).data_length, '9') || 'D' || rpad('9', l_tab_column_tab(i).data_length, '9');
                        end if;
                        l_field_value_v := trim(to_char(l_field_value_n, l_format, 'NLS_NUMERIC_CHARACTERS = ''. '''));
                        l_field_value_v := rtrim(l_field_value_v, '.');
                    else
                        l_field_value_v := 'NULL';
                    end if;
                    if l_tab_column_tab(i).column_name = 'SEQNUM' then
                         l_field_value_v := '1';
                    end if;
                elsif l_tab_column_tab(i).data_type = 'DATE' then
                    dbms_sql.column_value(l_cursor, i, l_field_value_d);
                    if l_field_value_d is not null then
                        l_format := 'yyyy.mm.dd hh24:mi:ss';
                        l_field_value_v := 'to_date('''||to_char(l_field_value_d, l_format)||''', '''||l_format||''')';
                    else
                        l_field_value_v := 'NULL';
                    end if;
                elsif l_tab_column_tab(i).data_type = 'TIMESTAMP(6)' then
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

                if i_merge_commands = com_api_const_pkg.TRUE then
                    l_merge_ins_source := l_merge_ins_source || 't1.' || l_tab_column_tab(i).column_name || ', ';
                    if lower(l_tab_column_tab(i).column_name) = 'id' then
                        l_id := l_field_value_n;
                    else
                        l_update_source := l_update_source || 't1.' || lower(l_tab_column_tab(i).column_name) || '=' || l_field_value_v ||', ';
                    end if;
                end if;
                l_insert_source := l_insert_source || l_tab_column_tab(i).column_name || ', ';
                l_values_source := l_values_source || l_field_value_v || ', ';
            end loop;

            l_insert_source := lower(rtrim(l_insert_source, ', '));
            l_merge_ins_source := lower(rtrim(l_merge_ins_source, ', '));
            l_values_source := rtrim(l_values_source, ', ');
            l_update_source := rtrim(l_update_source, ', ');

            if i_merge_commands = com_api_const_pkg.TRUE and l_id is not null then
                l_stmt := 'merge into ' || lower(i_table_name) || ' t1' || chr(10)
                       || 'using (select ' || l_id || ' as id from dual) t2 on (t1.id = t2.id)' || chr(10)
                       || 'when matched then update set ' || l_update_source || chr(10)
                       || 'when not matched then insert (' || l_merge_ins_source || ') values (' || l_values_source || ')';
            else
                l_stmt := 'insert into ' || lower(i_table_name) || ' (' || l_insert_source || ') values (' || l_values_source || ')';
            end if;

            write_line(l_stmt);
            write_line('/');
        else
            exit;
        end if;
    end loop;

    trc_log_pkg.debug (i_text => 'Fetched rows: ' || l_row_count);

    dbms_sql.close_cursor(l_cursor);

    if upper(i_table_name) != 'COM_I18N' then
        data_from_table(
            i_owner          => i_owner
          , i_table_name     => 'COM_I18N'
          , i_where_clause   => 'where table_name = ''' || upper(i_table_name) || ''' and object_id in (select id from ' || upper(i_owner) || '.'
                             || upper(i_table_name) || ' ' || i_where_clause || ')'
          , i_order_clause   => 'order by lang, id'
          , i_merge_commands => i_merge_commands
        );

    end if;
exception
    when others then
        if  dbms_sql.is_open(l_cursor) then
            dbms_sql.close_cursor(l_cursor);
        end if;
        raise;
end data_from_table;


procedure cycle_type_upload(
    i_cycle_type     in com_api_type_pkg.t_dict_value
  , i_schema_name    in com_api_type_pkg.t_oracle_name
  , i_update_mode    in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) is
begin
    for rc in (select id, cycle_type from fcl_cycle_type where cycle_type = upper(i_cycle_type) and id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY) loop
        data_from_table (i_schema_name, 'FCL_CYCLE_TYPE', 'where id = ' || rc.id, null, 0, i_update_mode);
        data_from_table (i_schema_name, 'COM_DICTIONARY', 'where dict = ''' || substr(rc.cycle_type, 1, 4) || ''' and code = ''' || substr(rc.cycle_type, 5) || '''', null, 0, com_api_const_pkg.FALSE);
    end loop;
end cycle_type_upload;


procedure cycle_upload(
    i_cycle_id       in com_api_type_pkg.t_short_id
  , i_schema_name    in com_api_type_pkg.t_oracle_name
  , i_update_mode    in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) is
begin
    for rc in (select * from fcl_cycle where id = i_cycle_id) loop
        data_from_table (i_schema_name, 'FCL_CYCLE', 'where id = ' || rc.id, null, 0, i_update_mode);
        data_from_table (i_schema_name, 'FCL_CYCLE_SHIFT', 'where cycle_id = ' || rc.id, null, 0, i_update_mode);
        cycle_type_upload(
            i_cycle_type   => rc.cycle_type
          , i_schema_name  => i_schema_name
          , i_update_mode  => i_update_mode
        );
    end loop;
end cycle_upload;


procedure limit_type_upload(
    i_limit_type     in com_api_type_pkg.t_dict_value
  , i_schema_name    in com_api_type_pkg.t_oracle_name
  , i_update_mode    in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) is
begin
    for rc in (select id, limit_type from fcl_limit_type where limit_type = upper(i_limit_type) and id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY) loop
        data_from_table (i_schema_name, 'FCL_LIMIT_TYPE', 'where id = ' || rc.id, null, 0, i_update_mode);
        data_from_table (i_schema_name, 'COM_DICTIONARY', 'where dict = ''' || substr(rc.limit_type, 1, 4) || ''' and code = ''' || substr(rc.limit_type, 5) || '''', null, 0, com_api_const_pkg.FALSE);
    end loop;
end limit_type_upload;


procedure limit_upload(
    i_limit_id       in com_api_type_pkg.t_long_id
  , i_schema_name    in com_api_type_pkg.t_oracle_name
  , i_update_mode    in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) is
begin
    for rc_l in (
        select * from fcl_limit where id = i_limit_id
    ) loop
        data_from_table (i_schema_name, 'FCL_LIMIT', 'where id = ' || rc_l.id, null, 0, i_update_mode);

        cycle_upload(
            i_cycle_id    => rc_l.cycle_id
          , i_schema_name => i_schema_name
          , i_update_mode => i_update_mode
        );

        limit_type_upload(
            i_limit_type   => rc_l.limit_type
          , i_schema_name  => i_schema_name
          , i_update_mode  => i_update_mode
        );
    end loop;
end limit_upload;


procedure fee_type_upload(
    i_fee_type       in com_api_type_pkg.t_dict_value
  , i_schema_name    in com_api_type_pkg.t_oracle_name
  , i_update_mode    in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) is
begin
    for rc in (select id, fee_type from fcl_fee_type where fee_type = upper(i_fee_type) and id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY) loop
        data_from_table (i_schema_name, 'FCL_FEE_TYPE', 'where id = ' || rc.id, null, 0, i_update_mode);
        data_from_table (i_schema_name, 'COM_DICTIONARY', 'where dict = ''' || substr(rc.fee_type, 1, 4) || ''' and code = ''' || substr(rc.fee_type, 5) || '''', null, 0, com_api_const_pkg.FALSE);
    end loop;
end fee_type_upload;


procedure fee_upload(
    i_fee_id         in com_api_type_pkg.t_long_id
  , i_schema_name    in com_api_type_pkg.t_oracle_name
  , i_update_mode    in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) is
begin
    for rc_f in (
        select * from fcl_fee where id = i_fee_id
    ) loop
        data_from_table (i_schema_name, 'FCL_FEE', 'where id = ' || rc_f.id, null, 0, i_update_mode);
        data_from_table (i_schema_name, 'FCL_FEE_TIER', 'where fee_id = ' || rc_f.id, null, 0, i_update_mode);

        limit_upload(
            i_limit_id    => rc_f.limit_id
          , i_schema_name => i_schema_name
          , i_update_mode => i_update_mode
        );

        cycle_upload(
            i_cycle_id    => rc_f.cycle_id
          , i_schema_name => i_schema_name
          , i_update_mode => i_update_mode
        );

        fee_type_upload(
            i_fee_type     => rc_f.fee_type
          , i_schema_name  => i_schema_name
          , i_update_mode  => i_update_mode
        );
    end loop;
end fee_upload;


procedure limit_cycle_fee_upload (
    i_entity_type    in com_api_type_pkg.t_dict_value
  , i_object_id      in com_api_type_pkg.t_long_id
  , i_schema_name    in com_api_type_pkg.t_oracle_name
  , i_update_mode    in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
)
is
begin
    -- Unload limits
    if i_entity_type = fcl_api_const_pkg.ENTITY_TYPE_LIMIT then
        limit_upload(
            i_limit_id    => i_object_id
          , i_schema_name => i_schema_name
          , i_update_mode => i_update_mode
        );
    -- Unload cycles
    elsif i_entity_type = fcl_api_const_pkg.ENTITY_TYPE_CYCLE then
        cycle_upload(
            i_cycle_id    => i_object_id
          , i_schema_name => i_schema_name
          , i_update_mode => i_update_mode
        );
    -- Unload fees
    elsif i_entity_type = fcl_api_const_pkg.ENTITY_TYPE_FEE then
        fee_upload(
            i_fee_id      => i_object_id
          , i_schema_name => i_schema_name
          , i_update_mode => i_update_mode
        );
    end if;
end limit_cycle_fee_upload;


procedure rul_mod_param_upload (
    i_id             in com_api_type_pkg.t_short_id
  , i_schema_name    in com_api_type_pkg.t_oracle_name
  , i_update_mode    in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) is
begin
    if i_id is null then
        data_from_table (i_schema_name, 'RUL_MOD_PARAM', 'where id >= cst_apc_const_pkg.CUSTOM_ID_START_SHORT', null, 0, i_update_mode);
    else
        data_from_table (i_schema_name, 'RUL_MOD_PARAM', 'where id >= cst_apc_const_pkg.CUSTOM_ID_START_SHORT and id = ' || i_id, null, 0, i_update_mode);
    end if;
end rul_mod_param_upload;


procedure network_settings_upload (
    i_network_id     in com_api_type_pkg.t_tiny_id
  , i_schema_name    in com_api_type_pkg.t_oracle_name
  , i_update_mode    in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) is
    l_network_id      com_api_type_pkg.t_tiny_id := i_network_id;
    l_host_inst_id    com_api_type_pkg.t_inst_id;
    l_schema_name     com_api_type_pkg.t_oracle_name := upper(trim(i_schema_name)); 
    l_update_mode     com_api_type_pkg.t_boolean := i_update_mode; 
begin
    write_line('--------------------------------------------------------');
    write_line('-- Network settings for network id ' || l_network_id);
    write_line('--------------------------------------------------------');

    write_line('-- 1. Add/update network and host institution');
    select inst_id into l_host_inst_id from net_network where id = l_network_id;
    data_from_table (l_schema_name, 'NET_NETWORK', 'where id = ' || l_network_id, null, 0, l_update_mode);
    data_from_table (l_schema_name, 'OST_INSTITUTION', 'where id = ' || l_host_inst_id, null, 0, l_update_mode);
    write_line('--------------------------------------------------------');

    write_line('-- 2. Add network members and links');
    for rc in (
        select *
          from net_member
         where network_id = l_network_id
    ) loop
        data_from_table (l_schema_name, 'NET_MEMBER', 'where id = ' || rc.id, null, 0, l_update_mode);
        data_from_table (l_schema_name, 'NET_INTERFACE', 'where host_member_id = ' || rc.id, null, 0, l_update_mode);
        data_from_table (l_schema_name, 'NET_INTERFACE', 'where consumer_member_id = ' || rc.id, null, 0, l_update_mode);
    end loop;
    write_line('--------------------------------------------------------');

    write_line('-- 3. Add host-standard links');
    for rc in (
        select cso.id 
          from net_member nm
             , cmn_standard_object cso
         where nm.network_id = l_network_id
           and cso.object_id = nm.id
           and cso.entity_type = net_api_const_pkg.ENTITY_TYPE_HOST
           and cso.standard_type = cmn_api_const_pkg.STANDART_TYPE_NETW_CLEARING --'STDT0201'
    ) loop
        data_from_table (l_schema_name, 'CMN_STANDARD_OBJECT', 'where id = ' || rc.id, null, 0, l_update_mode);
    end loop;
    write_line('--------------------------------------------------------');

    write_line('-- 4. Add standards');
    for rc in (
        select distinct cso.standard_id
          from net_member nm
             , cmn_standard_object cso
         where nm.network_id = l_network_id
           and cso.object_id = nm.id
           and cso.entity_type = net_api_const_pkg.ENTITY_TYPE_HOST
           and cso.standard_type = cmn_api_const_pkg.STANDART_TYPE_NETW_CLEARING --'STDT0201'
    ) loop
        write_line('-- 4.1. Standard');
        if rc.standard_id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY then -- for custom standards
            data_from_table (l_schema_name, 'CMN_STANDARD', 'where id = ' || rc.standard_id, null, 0, l_update_mode);
        end if;

        write_line('-- 4.2. Standard parameters');
        for rc_param in (
            select prm.id as param_id
                 , val.id
                 , val.object_id
                 , val.entity_type
                 , val.mod_id
              from cmn_parameter prm
                 , cmn_parameter_value val
             where prm.standard_id = val.standard_id(+)
               and val.version_id is null
               and prm.id = val.param_id(+) 
               and prm.standard_id =  rc.standard_id 
        ) loop
            if rc_param.id is null then
                write_line('delete from cmn_parameter_value where standard_id = ' || rc.standard_id || ' and version_id is null and param_id = ' || rc_param.param_id);
                write_line('/');
            else
                data_from_table (l_schema_name, 'CMN_PARAMETER_VALUE', 'where id = ' || rc_param.id, null, 0, l_update_mode);
            end if;
        end loop;

        write_line('-- 4.3. Standard versions with objects and parameters');
        for rc_ver in (
            select id
              from cmn_standard_version
             where standard_id = rc.standard_id
        ) loop
            if rc_ver.id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY then -- for custom standard versions
                data_from_table (l_schema_name, 'CMN_STANDARD_VERSION', 'where id = ' || rc_ver.id, null, 0, l_update_mode);
            end if;
            data_from_table (l_schema_name, 'CMN_STANDARD_VERSION_OBJ', 'where entity_type = ''ENTTHOST'' and version_id = ' || rc_ver.id, null, 0, l_update_mode);

            for rc_param in (
                select prm.id as param_id
                     , val.id
                     , val.object_id
                     , val.entity_type
                     , val.mod_id
                  from cmn_parameter prm
                     , cmn_parameter_value val
                 where prm.standard_id = val.standard_id(+)
                   and rc_ver.id = val.version_id(+)
                   and prm.id = val.param_id(+) 
                   and prm.standard_id =  rc.standard_id 
            ) loop
                if rc_param.id is null then
                    write_line('delete from cmn_parameter_value where standard_id = ' || rc.standard_id || ' and version_id = ' || rc_ver.id || ' and param_id = ' || rc_param.param_id);
                    write_line('/');
                else
                    data_from_table (l_schema_name, 'CMN_PARAMETER_VALUE', 'where id = ' || rc_param.id, null, 0, l_update_mode);
                end if;
            end loop;
        end loop;
    end loop;  
end network_settings_upload;


procedure settlement_mapping_upload (
    i_schema_name    in com_api_type_pkg.t_oracle_name
  , i_update_mode    in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_delete_others  in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) is
    l_schema_name     com_api_type_pkg.t_oracle_name := upper(trim(i_schema_name)); 
    l_update_mode     com_api_type_pkg.t_boolean := i_update_mode; 
    l_delete_others   com_api_type_pkg.t_boolean := i_delete_others;
    l_sql             com_api_type_pkg.t_sql_statement;
begin
    write_line('--------------------------------------------------------');
    write_line('-- Settlement mapping');
    write_line('--------------------------------------------------------');
    data_from_table (l_schema_name, 'NET_STTL_MAP', null, null, 0, l_update_mode);
    if l_delete_others = com_api_const_pkg.TRUE then
        l_sql := 'delete from net_sttl_map where id not in (';
        for rc in (
            select id
              from net_sttl_map
        ) loop
            l_sql := l_sql || rc.id || ', ';
        end loop;
        l_sql := rtrim(l_sql, ', ') || ')';
        write_line(l_sql);
        write_line('/');
    end if;
end settlement_mapping_upload;


procedure rule_set_upload (
    i_rule_set_id    in com_api_type_pkg.t_tiny_id
  , i_schema_name    in com_api_type_pkg.t_oracle_name
  , i_update_mode    in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) is
    l_schema_name     com_api_type_pkg.t_oracle_name := upper(trim(i_schema_name)); 
    l_update_mode     com_api_type_pkg.t_boolean := i_update_mode; 
    l_rule_set_id     com_api_type_pkg.t_tiny_id := i_rule_set_id;
    l_sql             com_api_type_pkg.t_sql_statement;
    l_sql_rule        com_api_type_pkg.t_sql_statement;
begin
    write_line('--------------------------------------------------------');
    write_line('-- Rule set ' || l_rule_set_id);
    write_line('--------------------------------------------------------');

    data_from_table (l_schema_name, 'RUL_RULE_SET', 'where id = ' || l_rule_set_id, null, 0, l_update_mode);
    l_sql_rule :=  null;

    for rc in (
        select * from rul_rule where rule_set_id = l_rule_set_id
    ) loop
        data_from_table (l_schema_name, 'RUL_RULE', 'where id = ' || rc.id, null, 0, l_update_mode);
        l_sql := null;
        for rc_param in (
            select * from rul_ui_rule_param_value_vw where rule_id = rc.id
        ) loop
            if rc_param.id is null then
                null;
            else
                l_sql := l_sql || rc_param.id || ', ';
                data_from_table (l_schema_name, 'RUL_RULE_PARAM_VALUE', 'where id = ' || rc_param.id, null, 0, l_update_mode);
            end if;
        end loop;
        if l_sql is not null then
            write_line('delete from rul_rule_param_value where rule_id = ' || rc.id || ' and id not in (' || rtrim(l_sql, ', ') || ')');
            write_line('/');
        end if;
        l_sql_rule := l_sql_rule || rc.id || ', ';
    end loop;

    if l_sql_rule is not null then
        write_line('begin');
        write_line('    for rc in (select * from rul_rule where rule_set_id = ' || l_rule_set_id || ' and id not in (' || rtrim(l_sql_rule, ', ') || ')) loop');
        write_line('        delete from rul_rule_param_value where rule_id = rc.id;');
        write_line('        delete from rul_rule where id = rc.id;');
        write_line('    end loop;');
        write_line('end;');
        write_line('/');
    end if;

    write_line('begin');
    write_line('    rul_api_regen_pkg.gen_static_pkg;');
    write_line('end;');
    write_line('/');
end rule_set_upload;


procedure events_upload (
    i_event_type     in com_api_type_pkg.t_dict_value
  , i_schema_name    in com_api_type_pkg.t_oracle_name
  , i_update_mode    in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_combined_mode  in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE -- Uploads also rule sets if com_api_const_pkg.TRUE
) is
    l_schema_name     com_api_type_pkg.t_oracle_name := upper(trim(i_schema_name)); 
    l_update_mode     com_api_type_pkg.t_boolean := i_update_mode; 
    l_event_type      com_api_type_pkg.t_dict_value := upper(i_event_type);
    l_sql             com_api_type_pkg.t_sql_statement;
    l_mod_list        com_api_type_pkg.t_tiny_tab;
begin
    l_event_type := upper(l_event_type);
    write_line('--------------------------------------------------------');
    if i_combined_mode = com_api_const_pkg.TRUE then
        write_line('-- COMBINED script: Events for event type ' || l_event_type);
    else
        write_line('-- Events for event type ' || l_event_type);
    end if;
    write_line('--------------------------------------------------------');

    if i_combined_mode = com_api_const_pkg.TRUE then
        if substr(l_event_type, 1, 4) in ('EVNT', 'CYTP') then
            data_from_table (l_schema_name, 'COM_DICTIONARY', 'where dict = ''' || substr(l_event_type, 1, 4) || ''' and code = ''' || substr(l_event_type, 5) || '''', null, 0, com_api_const_pkg.FALSE);
        end if;
    end if;

    write_line('-- 1. Event type links for event type ' || l_event_type);
    data_from_table (l_schema_name, 'EVT_EVENT_TYPE', 'where event_type = ''' || l_event_type || ''' and id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY', null, 0, l_update_mode);

    write_line('-- 2. Event subscribers for event type ' || l_event_type);
    l_sql :=  null;
    for rc in (
        select * from evt_subscriber where event_type = l_event_type and id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY
    ) loop
        data_from_table (l_schema_name, 'EVT_SUBSCRIBER', 'where id = ' || rc.id, null, 0, l_update_mode);
        l_sql := l_sql || rc.id || ', ';
    end loop;
    if l_sql is not null then
        write_line('delete from evt_subscriber where event_type = ''' || l_event_type || ''' and id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY and id not in (' || rtrim(l_sql, ', ') || ')');
        write_line('/');
    end if;

    write_line('-- 3. Events for event type ' || l_event_type);
    for rc in (
        select * from evt_event where event_type = l_event_type
    ) loop
        write_line('-- 2.1. Event ' || rc.id);
        data_from_table (l_schema_name, 'EVT_EVENT', 'where id = ' || rc.id || ' and id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY', null, 0, l_update_mode);

        if rc.scale_id is not null then
            write_line('-- 2.2. Scales and modifiers for event ' || rc.id);
            data_from_table (l_schema_name, 'RUL_MOD_SCALE', 'where id = ' || rc.scale_id || ' and id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY', null, 0, l_update_mode);
            data_from_table (l_schema_name, 'RUL_MOD_SCALE_PARAM', 'where scale_id = ' || rc.scale_id || ' and id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY', null, 0, l_update_mode);
            data_from_table (l_schema_name, 'RUL_MOD', 'where scale_id = ' || rc.scale_id || ' and id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY', null, 0, l_update_mode);

            for rc_mod in (
                select id from rul_mod where scale_id = rc.scale_id
            ) loop
                add_mod_to_the_list(
                    i_mod_id     => rc_mod.id
                  , io_mod_list  => l_mod_list
                );
            end loop;
        end if;
        
        write_line('-- 2.3. Rules for event ' || rc.id);
        for rc_rs in (
            select * from evt_rule_set where event_id = rc.id
        ) loop
            data_from_table (l_schema_name, 'EVT_RULE_SET', 'where id = ' || rc_rs.id || ' and id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY', null, 0, l_update_mode);
            if rc_rs.mod_id is not null then
                data_from_table (l_schema_name, 'RUL_MOD', 'where id = ' || rc_rs.mod_id || ' and id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY', null, 0, l_update_mode);
                add_mod_to_the_list(
                    i_mod_id     => rc_rs.mod_id
                  , io_mod_list  => l_mod_list
                );
            end if;
        end loop;
        
        write_line('-- 2.4. Subscriptions for event ' || rc.id);
        l_sql := null;
        for rc_es in (
            select * from evt_subscription where event_id = rc.id
        ) loop
            if rc_es.id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY then
                l_sql := l_sql || rc_es.id || ', ';
            end if;
            data_from_table (l_schema_name, 'EVT_SUBSCRIPTION', 'where id = ' || rc_es.id || ' and id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY', null, 0, l_update_mode);
            if rc_es.mod_id is not null then
                data_from_table (l_schema_name, 'RUL_MOD', 'where id = ' || rc_es.mod_id || ' and id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY', null, 0, l_update_mode);
                add_mod_to_the_list(
                    i_mod_id     => rc_es.mod_id
                  , io_mod_list  => l_mod_list
                );
            end if;
        end loop;
        if l_sql is not null then
            write_line('delete from evt_subscription where event_id = ' || rc.id || ' and id >= ' || cst_apc_const_pkg.CUSTOM_ID_START_TINY || ' and id not in (' || rtrim(l_sql, ', ') || ')');
            write_line('/');
        end if;
    end loop;
    
    if i_combined_mode = com_api_const_pkg.TRUE then
        write_line('-- 3. Rule sets');
        for rc_rs in (
            select distinct ers.rule_set_id
              from evt_event ee
                 , evt_rule_set ers
             where ers.event_id = ee.id
               and ee.event_type = l_event_type
        ) loop
            rule_set_upload(
                i_rule_set_id  => rc_rs.rule_set_id
              , i_schema_name  => i_schema_name
              , i_update_mode  => i_update_mode
            );
        end loop;
    end if;

    create_mod_static_pkg(
        i_mod_list  => l_mod_list
    );
end events_upload;

procedure product_upload (
    i_product_id     in com_api_type_pkg.t_short_id
  , i_schema_name    in com_api_type_pkg.t_oracle_name
  , i_update_mode    in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) is
    l_schema_name     com_api_type_pkg.t_oracle_name := upper(trim(i_schema_name)); 
    l_update_mode     com_api_type_pkg.t_boolean := i_update_mode; 
    l_product_id      com_api_type_pkg.t_short_id := i_product_id;
    l_inst_id         com_api_type_pkg.t_inst_id;
    l_sql             com_api_type_pkg.t_sql_statement;
    l_sql3            com_api_type_pkg.t_sql_statement;
    l_entity_type     com_api_type_pkg.t_dict_value;
    l_contract_type   com_api_type_pkg.t_dict_value;
    l_mod_list        com_api_type_pkg.t_tiny_tab;
    l_limit_id        number;
    l_cycle_id        number;
begin
    write_line('--------------------------------------------------------');
    write_line('-- Product ID ' || l_product_id);
    write_line('--------------------------------------------------------');

    write_line('-- 1. Product info');
    write_line('-- WARNING. If you see an error with constraint PRD_PRODUCT_UK, then check if the same pair product number/inst id is already in use in the target table.');
    data_from_table (l_schema_name, 'PRD_PRODUCT', 'where id = ' || l_product_id, null, 0, l_update_mode);
    select inst_id
         , contract_type
      into l_inst_id
         , l_contract_type
      from prd_product 
     where id = l_product_id;
    
    write_line('-- 2. Contract type ' || l_contract_type);
    write_line('-- WARNING: scripts for com_dictionary can return error in case of code is already present');
    if substr(l_contract_type, 1, 4) = 'CNTP' then
        data_from_table (l_schema_name, 'COM_DICTIONARY', 'where dict = ''CNTP'' and code = ''' || substr(l_contract_type, 5) || '''', null, 0, com_api_const_pkg.FALSE);
    end if;
    for rc in (
        select * 
          from prd_contract_type
         where contract_type = l_contract_type
           and id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY
    ) loop
        data_from_table (l_schema_name, 'PRD_CONTRACT_TYPE', 'where id=' || rc.id, null, 0, l_update_mode);
        data_from_table (l_schema_name, 'COM_DICTIONARY', 'where dict = ''ENTT'' and code = ''' || substr(rc.customer_entity_type, 5) || '''', null, 0, com_api_const_pkg.FALSE);
    end loop;
    
    write_line('-- 3. Account types linked to product');
    l_sql := null;
    for rc in (
        select *
          from acc_product_account_type
         where product_id = l_product_id
    ) loop
        l_sql := l_sql || rc.id || ', ';
    end loop;
    if l_sql is not null then
        write_line('delete from acc_product_account_type where product_id = ' || l_product_id || ' and id >= ' || cst_apc_const_pkg.CUSTOM_ID_START_SHORT);
        write_line('and id not in (' || rtrim(l_sql, ', ') || ')');
        write_line('/');
    end if;
    
    for rc in (
        select *
          from acc_product_account_type
         where product_id = l_product_id
    ) loop
        write_line('-- 3.1. Account type related info for account type ' || rc.account_type);
        data_from_table (l_schema_name, 'ACC_PRODUCT_ACCOUNT_TYPE', 'where id = ' || rc.id, null, 0, l_update_mode);
        data_from_table (l_schema_name, 'ACC_ACCOUNT_TYPE', 'where account_type = ''' || rc.account_type || '''', null, 0, l_update_mode);
        data_from_table (l_schema_name, 'COM_DICTIONARY', 'where dict = ''ACTP'' and code = ''' || substr(rc.account_type, 5) || '''', null, 0, com_api_const_pkg.FALSE);

        l_sql := null;
        for rc_e in (
            select * from acc_account_type_entity where account_type = rc.account_type
        ) loop
            l_sql := l_sql || rc_e.id || ', ';
        end loop;
        if l_sql is not null then
            write_line('delete from acc_account_type_entity where account_type = ''' || rc.account_type || ''' and id >= ' || cst_apc_const_pkg.CUSTOM_ID_START_TINY);
            write_line('and id not in (' || rtrim(l_sql, ', ') || ')');
            write_line('/');
        end if;
        data_from_table (l_schema_name, 'ACC_ACCOUNT_TYPE_ENTITY', 'where account_type = ''' || rc.account_type || '''', null, 0, l_update_mode);

        l_sql := null;
        for rc_iso in (
            select * from acc_iso_account_type where account_type = rc.account_type
        ) loop
            l_sql := l_sql || rc_iso.id || ', ';
        end loop;
        if l_sql is not null then
            write_line('delete from acc_iso_account_type where account_type = ''' || rc.account_type || ''' and id >= ' || cst_apc_const_pkg.CUSTOM_ID_START_TINY);
            write_line('and id not in (' || rtrim(l_sql, ', ') || ')');
            write_line('/');
        end if;
        data_from_table (l_schema_name, 'ACC_ISO_ACCOUNT_TYPE', 'where account_type = ''' || rc.account_type || '''', null, 0, l_update_mode);

        l_sql := null;
        for rc_bt in (
            select * from acc_balance_type where account_type = rc.account_type
        ) loop
            l_sql := l_sql || rc_bt.id || ', ';
        end loop;
        if l_sql is not null then
            write_line('delete from acc_balance_type where account_type = ''' || rc.account_type || ''' and id >= ' || cst_apc_const_pkg.CUSTOM_ID_START_TINY);
            write_line('and id not in (' || rtrim(l_sql, ', ') || ')');
            write_line('/');
        end if;
        data_from_table (l_schema_name, 'ACC_BALANCE_TYPE', 'where account_type = ''' || rc.account_type || '''', null, 0, l_update_mode);

        for rc_at in (
            select * from acc_account_type where account_type = rc.account_type
        ) loop
            write_line('-- 3.2. Naming format, ID ' || rc_at.number_format_id);
            if rc_at.number_format_id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY then
                for rc_rnf in (
                    select *
                      from rul_name_format
                     where id = rc_at.number_format_id
                ) loop
                    data_from_table (l_schema_name, 'RUL_NAME_FORMAT', 'where id = ' || rc_rnf.id, null, 0, l_update_mode);
                    if rc_rnf.index_range_id is not null then
                        data_from_table (l_schema_name, 'RUL_NAME_INDEX_RANGE', 'where id = ' || rc_rnf.index_range_id, null, 0, l_update_mode);
                        data_from_table (l_schema_name, 'RUL_NAME_INDEX_POOL', 'where index_range_id = ' || rc_rnf.index_range_id, null, 0, l_update_mode);
                    end if;
                    data_from_table (l_schema_name, 'RUL_NAME_BASE_PARAM', 'where id >= cst_apc_const_pkg.CUSTOM_ID_START_SHORT and entity_type = ''' || rc_rnf.entity_type || '''', null, 0, l_update_mode);
                end loop;

                l_sql := null;
                for rc_rnp in (
                    select *
                      from rul_name_part
                     where format_id = rc_at.number_format_id
                       and id >= cst_apc_const_pkg.CUSTOM_ID_START_SHORT
                ) loop
                    l_sql := l_sql || rc_rnp.id || ', ';
                    data_from_table (l_schema_name, 'RUL_NAME_PART', 'where id = ' || rc_rnp.id, null, 0, l_update_mode);
                end loop;
                if l_sql is not null then
                    write_line('delete from rul_name_part where format_id = ' || rc_at.number_format_id || ' and id >= ' || cst_apc_const_pkg.CUSTOM_ID_START_SHORT);
                    write_line('and id not in (' || rtrim(l_sql, ', ') || ')');
                    write_line('/');
                end if;
            end if;
        end loop;
    end loop;

    write_line('-- 4. Authentication schemas linked to product');
    data_from_table (l_schema_name, 'AUP_SCHEME_OBJECT', 'where entity_type = ''ENTTPROD'' and object_id = ' || l_product_id, null, 0, l_update_mode);

    write_line('-- 5. Notes for product');
    data_from_table (l_schema_name, 'NTB_NOTE', 'where entity_type = ''ENTTPROD'' and object_id = ' || l_product_id, null, 0, l_update_mode);

    write_line('-- 6. Card types linked to product');
    for rc in (
        select *
          from iss_product_card_type
         where product_id = l_product_id
    ) loop
        write_line('-- 6.1. Card type ' || rc.card_type_id);
        if rc.card_type_id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY then
            data_from_table (l_schema_name, 'NET_CARD_TYPE', 'where id = ' || rc.card_type_id, null, 0, l_update_mode);
        end if;

        l_sql := null;
        for rc2 in (
            select *
              from net_card_type_feature
             where card_type_id = rc.card_type_id
               and id >= cst_apc_const_pkg.CUSTOM_ID_START_SHORT
        ) loop
            l_sql := l_sql || rc2.id || ', ';
            data_from_table (l_schema_name, 'NET_CARD_TYPE_FEATURE', 'where id = ' || rc2.id, null, 0, l_update_mode);
        end loop;
        if l_sql is not null then
            write_line('delete from net_card_type_feature where card_type_id = ' || rc.card_type_id || ' and id >= ' || cst_apc_const_pkg.CUSTOM_ID_START_SHORT);
            write_line('and id not in (' || rtrim(l_sql, ', ') || ')');
            write_line('/');
        end if;

        l_sql := null;
        for rc2 in (
            select *
              from net_card_type_map
             where card_type_id = rc.card_type_id
               and id >= cst_apc_const_pkg.CUSTOM_ID_START_SHORT
        ) loop
            l_sql := l_sql || rc2.id || ', ';
            data_from_table (l_schema_name, 'NET_CARD_TYPE_MAP', 'where id = ' || rc2.id, null, 0, l_update_mode);
        end loop;
        if l_sql is not null then
            write_line('delete from net_card_type_map where card_type_id = ' || rc.card_type_id || ' and id >= ' || cst_apc_const_pkg.CUSTOM_ID_START_SHORT);
            write_line('and id not in (' || rtrim(l_sql, ', ') || ')');
            write_line('/');
        end if;

        write_line('-- 6.2. BIN and index range');
        data_from_table (l_schema_name, 'ISS_BIN', 'where id = ' || rc.bin_id, null, 0, l_update_mode);
        data_from_table (l_schema_name, 'ISS_BIN_INDEX_RANGE', 'where bin_id = ' || rc.bin_id || ' and index_range_id = ' || rc.index_range_id, null, 0, l_update_mode);
        data_from_table (l_schema_name, 'RUL_NAME_INDEX_RANGE', 'where id = ' || rc.index_range_id, null, 0, l_update_mode);
        data_from_table (l_schema_name, 'rul_name_index_pool', 'where index_range_id = ' || rc.index_range_id, null, 0, l_update_mode);

        write_line('-- 6.3. Number format, ID ' || rc.number_format_id);
        if rc.number_format_id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY then
            for rc_rnf in (
                select *
                  from rul_name_format
                 where id = rc.number_format_id
            ) loop
                data_from_table (l_schema_name, 'RUL_NAME_FORMAT', 'where id = ' || rc_rnf.id, null, 0, l_update_mode);
                if rc_rnf.index_range_id is not null then
                    data_from_table (l_schema_name, 'RUL_NAME_INDEX_RANGE', 'where id = ' || rc_rnf.index_range_id, null, 0, l_update_mode);
                    data_from_table (l_schema_name, 'RUL_NAME_INDEX_POOL', 'where index_range_id = ' || rc_rnf.index_range_id, null, 0, l_update_mode);
                end if;
                data_from_table (l_schema_name, 'RUL_NAME_BASE_PARAM', 'where id >= cst_apc_const_pkg.CUSTOM_ID_START_SHORT and entity_type = ''' || rc_rnf.entity_type || '''', null, 0, l_update_mode);
            end loop;
        end if;

        l_sql := null;
        for rc2 in (
            select *
              from rul_name_part
             where format_id = rc.number_format_id
               and id >= cst_apc_const_pkg.CUSTOM_ID_START_SHORT
        ) loop
            l_sql := l_sql || rc2.id || ', ';
            data_from_table (l_schema_name, 'RUL_NAME_PART', 'where id = ' || rc2.id, null, 0, l_update_mode);
        end loop;
        if l_sql is not null then
            write_line('delete from rul_name_part where format_id = ' || rc.number_format_id || ' and id >= ' || cst_apc_const_pkg.CUSTOM_ID_START_SHORT);
            write_line('and id not in (' || rtrim(l_sql, ', ') || ')');
            write_line('/');
        end if;

        write_line('-- 6.4. Blank type');
        data_from_table (l_schema_name, 'PRS_BLANK_TYPE', 'where id = ' || rc.blank_type_id, null, 0, l_update_mode);

        write_line('-- 6.5. Link');
        data_from_table (l_schema_name, 'ISS_PRODUCT_CARD_TYPE', 'where id = ' || rc.id, null, 0, l_update_mode);
    end loop;

    write_line('-- 7. Modifiers custom parameters');
    rul_mod_param_upload(
        i_id          => null
      , i_schema_name => l_schema_name
      , i_update_mode => l_update_mode
    );

    write_line('-- 8. Attributes of services types for product');
    for rc in (
        select distinct ps.service_type_id
          from prd_product_service pps
             , prd_service ps
         where pps.product_id = l_product_id
           and pps.service_id = ps.id
    ) loop
        l_sql := null;
        for rc2 in (
            select *
              from prd_attribute
             where service_type_id = rc.service_type_id
        ) loop
            if rc2.id >= cst_apc_const_pkg.CUSTOM_ID_START_SHORT then
                l_sql := l_sql || rc2.id || ', ';
                data_from_table (l_schema_name, 'PRD_ATTRIBUTE', 'where id = ' || rc2.id, null, 0, l_update_mode);
            end if;
            if rc2.entity_type = fcl_api_const_pkg.ENTITY_TYPE_LIMIT and substr(rc2.object_type, 1, 4) = 'LMTP' then
                limit_type_upload(
                    i_limit_type   => rc2.object_type
                  , i_schema_name  => l_schema_name
                  , i_update_mode  => l_update_mode
                );
            elsif rc2.entity_type = fcl_api_const_pkg.ENTITY_TYPE_CYCLE and substr(rc2.object_type, 1, 4) = 'CYTP' then
                cycle_type_upload(
                    i_cycle_type   => rc2.object_type
                  , i_schema_name  => l_schema_name
                  , i_update_mode  => l_update_mode
                );
            elsif rc2.entity_type = fcl_api_const_pkg.ENTITY_TYPE_FEE and substr(rc2.object_type, 1, 4) = 'FETP' then
                fee_type_upload(
                    i_fee_type     => rc2.object_type
                  , i_schema_name  => l_schema_name
                  , i_update_mode  => l_update_mode
                );
            end if;

            l_sql3 := null;
            for rc3 in (
                select *
                  from prd_attribute_scale
                 where attr_id = rc2.id
                   and inst_id = l_inst_id
            ) loop
                l_sql3 := l_sql3 || rc3.id || ', ';
            end loop;
            if l_sql3 is not null then
                write_line('delete from prd_attribute_scale where attr_id = ' || rc2.id || ' and inst_id = ' || l_inst_id || ' and id >= ' || cst_apc_const_pkg.CUSTOM_ID_START_TINY);
                write_line('and id not in (' || rtrim(l_sql3, ', ') || ')');
                write_line('/');
            end if;
            for rc3 in (
                select *
                  from prd_attribute_scale
                 where attr_id = rc2.id
                   and inst_id = l_inst_id
            ) loop
                data_from_table (l_schema_name, 'PRD_ATTRIBUTE_SCALE', 'where id = ' || rc3.id, null, 0, l_update_mode);
                if rc3.scale_id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY then
                    data_from_table (l_schema_name, 'RUL_MOD_SCALE', 'where id = ' || rc3.scale_id, null, 0, l_update_mode);
                    data_from_table (l_schema_name, 'RUL_MOD_SCALE_PARAM', 'where scale_id = ' || rc3.scale_id, null, 0, l_update_mode);
                    data_from_table (l_schema_name, 'RUL_MOD', 'where scale_id = ' || rc3.scale_id, null, 0, l_update_mode);
                    for rc_mod in (
                        select id from rul_mod where scale_id = rc3.scale_id
                    ) loop
                        add_mod_to_the_list(
                            i_mod_id     => rc_mod.id
                          , io_mod_list  => l_mod_list
                        );
                    end loop;
                end if;
            end loop;
        end loop;

        if l_sql is not null then
            write_line('delete from prd_attribute where service_type_id = ' || rc.service_type_id || ' and id >= ' || cst_apc_const_pkg.CUSTOM_ID_START_SHORT);
            write_line('and id not in (' || rtrim(l_sql, ', ') || ')');
            write_line('/');
        end if;
    end loop;

    write_line('-- 9. Services for product');
    write_line('delete from prd_product_service where product_id = ' || l_product_id);
    write_line('/');
    for rc in (
        select *
          from prd_product_service
         where product_id = l_product_id
    ) loop
        write_line('-- Service ' || rc.service_id);
        data_from_table (l_schema_name, 'PRD_SERVICE', 'where id = ' || rc.service_id, null, 0, l_update_mode);

        l_sql := null;
        for rc2 in (
            select *
              from prd_service_attribute
             where service_id = rc.service_id
        ) loop
            l_sql := l_sql || rc2.attribute_id || ', ';
            if l_update_mode = com_api_const_pkg.FALSE then
                data_from_table (l_schema_name, 'PRD_SERVICE_ATTRIBUTE', 'where service_id = ' || rc.service_id || ' and attribute_id = ' || rc2.attribute_id, null, 0, com_api_const_pkg.FALSE);
            else -- it doesn't have ID column
                write_line('merge into prd_service_attribute t1');
                write_line('using (select ' || rc.service_id || ' as service_id, ' || rc2.attribute_id || ' as attribute_id from dual) t2 on (t1.service_id = t2.service_id and t1.attribute_id = t2.attribute_id)');
                write_line('when matched then update set t1.is_visible=' || rc2.is_visible);
                write_line('when not matched then insert (t1.service_id, t1.attribute_id, t1.is_visible) values (' || rc.service_id || ', ' || rc2.attribute_id || ', ' || rc2.is_visible || ')');
                write_line('/');
            end if;
        end loop;
        if l_sql is not null then
            write_line('delete from prd_service_attribute where service_id = ' || rc.service_id);
            write_line('and attribute_id not in (' || rtrim(l_sql, ', ') || ')');
            write_line('/');
        end if;
    end loop;
    data_from_table (l_schema_name, 'PRD_PRODUCT_SERVICE', 'where product_id = ' || l_product_id, null, 0, com_api_const_pkg.FALSE);

    write_line('-- 10. Attributes of product');
    for rc in (
        select av.id as attr_value_id
             , a.entity_type as attr_entity_type
             , case 
                   when a.data_type = 'DTTPNMBR' 
                    and a.entity_type in ( fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                                         , fcl_api_const_pkg.ENTITY_TYPE_CYCLE
                                         , fcl_api_const_pkg.ENTITY_TYPE_FEE
                                         )
                   then
                       get_number_value(a.data_type, av.attr_value)
                   else
                       to_number(null)
               end as object_id
          from prd_attribute_value av
             , prd_attribute a
         where av.entity_type = 'ENTTPROD'
           and av.object_id = l_product_id
           and av.attr_id = a.id
           and a.definition_level = 'SADLPRDT'
    ) loop
        data_from_table (l_schema_name, 'PRD_ATTRIBUTE_VALUE', 'where id = ' || rc.attr_value_id, null, 0, l_update_mode);
        limit_cycle_fee_upload (
            i_entity_type  => rc.attr_entity_type
          , i_object_id    => rc.object_id
          , i_schema_name  => l_schema_name
          , i_update_mode  => l_update_mode
        );
    end loop;

    create_mod_static_pkg(
        i_mod_list  => l_mod_list
    );
end product_upload;


procedure notifications_upload (
    i_scheme_id      in com_api_type_pkg.t_tiny_id
  , i_schema_name    in com_api_type_pkg.t_oracle_name
  , i_update_mode    in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) is
    l_schema_name     com_api_type_pkg.t_oracle_name := upper(trim(i_schema_name)); 
    l_update_mode     com_api_type_pkg.t_boolean := i_update_mode; 
    l_scheme_id       com_api_type_pkg.t_tiny_id := i_scheme_id;
    l_sql             com_api_type_pkg.t_sql_statement;
    l_entity_type     com_api_type_pkg.t_dict_value;
    l_mod_list        com_api_type_pkg.t_tiny_tab;
begin
    write_line('--------------------------------------------------------');
    write_line('-- Notifications for notifications scheme ' || l_scheme_id);
    write_line('--------------------------------------------------------');

    write_line('-- 1. Notification scheme ' || l_scheme_id);
    data_from_table (l_schema_name, 'NTF_SCHEME', 'where id = ' || l_scheme_id, null, 0, l_update_mode);

    write_line('-- 2. Scheme-event settings');
    write_line('-- 2.1. Delete existing settings');
    write_line('delete from ntf_scheme_event where scheme_id = ' || l_scheme_id || ' and id >= ' || cst_apc_const_pkg.CUSTOM_ID_START_SHORT);
    write_line('/');

    write_line('-- 2.2. Add settings');
    for rc in (
        select * from ntf_scheme_event where scheme_id = l_scheme_id
    ) loop
        write_line('-- 2.2.1. Custom scheme-event (if exists)');
        if rc.id >= cst_apc_const_pkg.CUSTOM_ID_START_SHORT then
            data_from_table (l_schema_name, 'NTF_SCHEME_EVENT', 'where id = ' || rc.id, null, 0, com_api_const_pkg.FALSE);
        end if;

        write_line('-- 2.2.2. Channel');
        data_from_table (l_schema_name, 'NTF_CHANNEL', 'where id = ' || rc.channel_id, null, 0, l_update_mode);

        write_line('-- 2.2.3. Delete all custom templates by channel_id and notif_id (because of unique key)');
        write_line('delete from ntf_template where channel_id = ' || rc.channel_id || ' and notif_id = ' || rc.notif_id || ' and id >= ' || cst_apc_const_pkg.CUSTOM_ID_START_SHORT);
        write_line('/');

        write_line('-- 2.2.4. Add custom templates by channel_id and notif_id');
        for rc2 in (
            select * from ntf_template where channel_id = rc.channel_id and notif_id = rc.notif_id
        ) loop
            write_line('-- 2.2.4.1. Custom notification template (if exists)');
            if rc2.id >= cst_apc_const_pkg.CUSTOM_ID_START_SHORT then
                data_from_table (l_schema_name, 'NTF_TEMPLATE', 'where id = ' || rc2.id, null, 0, l_update_mode);
            end if;

            write_line('-- 2.2.4.2. Report template (if exists)');
            if rc2.report_template_id is not null then

                for rc3 in (
                    select * from rpt_template where id = rc2.report_template_id
                ) loop
                    write_line('-- 2.2.4.2.1. Custom report template (if exists)');
                    if rc3.id >= cst_apc_const_pkg.CUSTOM_ID_START_SHORT then
                        data_from_table (l_schema_name, 'RPT_TEMPLATE', 'where id = ' || rc3.id, null, 0, l_update_mode);
                    end if;
                    
                    for rc4 in (
                        select * from rpt_report where id = rc3.report_id
                    ) loop
                        write_line('-- 2.2.4.2.1.1. Custom report (if exists)');
                        if rc4.id >= cst_apc_const_pkg.CUSTOM_ID_START_SHORT then
                            data_from_table (l_schema_name, 'RPT_REPORT', 'where id = ' || rc4.id, null, 0, l_update_mode);
                        end if;

                        write_line('-- 2.2.4.2.1.2. Report name format, ID ' || rc4.name_format_id);
                        if rc4.name_format_id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY then
                            data_from_table (l_schema_name, 'RUL_NAME_FORMAT', 'where id = ' || rc4.name_format_id, null, 0, l_update_mode);
                        end if;
                        if rc4.name_format_id is not null then
                            select entity_type
                              into l_entity_type
                              from rul_name_format
                             where id = rc4.name_format_id;
                        end if;

                        write_line('-- 2.2.4.2.1.3. Report name format parameters');
                        data_from_table (l_schema_name, 'RUL_NAME_BASE_PARAM', 'where id >= cst_apc_const_pkg.CUSTOM_ID_START_SHORT and entity_type = ''' || l_entity_type || '''', null, 0, l_update_mode);

                        write_line('-- 2.2.4.2.1.4. Report name parts');
                        l_sql := null;
                        for rc5 in (
                            select *
                              from rul_name_part
                             where format_id = rc4.name_format_id
                               and id >= cst_apc_const_pkg.CUSTOM_ID_START_SHORT
                        ) loop
                            l_sql := l_sql || rc2.id || ', ';
                            data_from_table (l_schema_name, 'RUL_NAME_PART', 'where id = ' || rc5.id, null, 0, l_update_mode);
                        end loop;
                        if l_sql is not null then
                            write_line('delete from rul_name_part where format_id = ' || rc4.name_format_id || ' and id >= ' || cst_apc_const_pkg.CUSTOM_ID_START_SHORT);
                            write_line('and id not in (' || rtrim(l_sql, ', ') || ')');
                            write_line('/');
                        end if;
                    end loop; -- rc4: report
                end loop; -- rc3: report template
            end if;
        end loop; -- rc2: notification template

        write_line('-- 2.2.5. Notifications by notif_id');
        for rc2 in (
            select * from ntf_notification where id = rc.notif_id
        ) loop
            write_line('-- 2.2.5.1. Custom notification (if exists)');
            if rc2.id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY then
                data_from_table (l_schema_name, 'NTF_NOTIFICATION', 'where id = ' || rc2.id, null, 0, l_update_mode);
            end if;

            if rc2.report_id is not null then
                write_line('-- 2.2.5.2. Notification report');
                for rc4 in (
                    select * from rpt_report where id = rc2.report_id
                ) loop
                    write_line('-- 2.2.5.2.1. Custom report (if exists)');
                    if rc4.id >= cst_apc_const_pkg.CUSTOM_ID_START_SHORT then
                        data_from_table (l_schema_name, 'rpt_report', 'where id = ' || rc4.id, null, 0, l_update_mode);
                    end if;

                    write_line('-- 2.2.5.2.2. Report name format, ID ' || rc4.name_format_id);
                    if rc4.name_format_id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY then
                        data_from_table (l_schema_name, 'rul_name_format', 'where id = ' || rc4.name_format_id, null, 0, l_update_mode);
                    end if;
                    if rc4.name_format_id is not null then
                        select entity_type
                          into l_entity_type
                          from rul_name_format
                         where id = rc4.name_format_id;
                    end if;

                    write_line('-- 2.2.5.2.3. Report name format parameters');
                    data_from_table (l_schema_name, 'RUL_NAME_BASE_PARAM', 'where id >= cst_apc_const_pkg.CUSTOM_ID_START_SHORT and entity_type = ''' || l_entity_type || '''', null, 0, l_update_mode);
                    write_line('-- 2.2.5.2.4. Report name parts');
                    l_sql := null;
                    for rc5 in (
                        select *
                          from rul_name_part
                         where format_id = rc4.name_format_id
                           and id >= cst_apc_const_pkg.CUSTOM_ID_START_SHORT
                    ) loop
                        l_sql := l_sql || rc2.id || ', ';
                        data_from_table (l_schema_name, 'rul_name_part', 'where id = ' || rc5.id, null, 0, l_update_mode);
                    end loop;
                    if l_sql is not null then
                        write_line('delete from rul_name_part where format_id = ' || rc4.name_format_id || ' and id >= ' || cst_apc_const_pkg.CUSTOM_ID_START_SHORT);
                        write_line('and id not in (' || rtrim(l_sql, ', ') || ')');
                        write_line('/');
                    end if;
                end loop; -- rc4
            end if;
        end loop; -- rc2: notification

        if rc.scale_id is not null then
            write_line('-- 2.2.6. Scale and modificators for scale ID ' || rc.scale_id);
            data_from_table (l_schema_name, 'RUL_MOD_SCALE', 'where id = ' || rc.scale_id || ' and id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY', null, 0, l_update_mode);
            data_from_table (l_schema_name, 'RUL_MOD_SCALE_PARAM', 'where scale_id = ' || rc.scale_id || ' and id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY', null, 0, l_update_mode);
            data_from_table (l_schema_name, 'RUL_MOD', 'where scale_id = ' || rc.scale_id || ' and id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY', null, 0, l_update_mode);
            for rc_mod in (
                select id from rul_mod where scale_id = rc.scale_id
            ) loop
                add_mod_to_the_list(
                    i_mod_id     => rc_mod.id
                  , io_mod_list  => l_mod_list
                );
            end loop;
        end if;
    end loop; --rc

    create_mod_static_pkg(
        i_mod_list  => l_mod_list
    );
end notifications_upload;


procedure macros_bunch_type_upload (
    i_macros_type_id in com_api_type_pkg.t_tiny_id
  , i_schema_name    in com_api_type_pkg.t_oracle_name
  , i_update_mode    in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) is
    l_schema_name     com_api_type_pkg.t_oracle_name := upper(trim(i_schema_name)); 
    l_update_mode     com_api_type_pkg.t_boolean := i_update_mode; 
    l_macros_type_id  com_api_type_pkg.t_tiny_id := i_macros_type_id;
begin
    write_line('--------------------------------------------------------');
    write_line('-- Macros type ID ' || l_macros_type_id);
    write_line('--------------------------------------------------------');
    for rc in (
        select * from acc_macros_type where id = l_macros_type_id
    ) loop
        data_from_table (l_schema_name, 'acc_macros_type', 'where id = ' || rc.id, null, 0, l_update_mode);
        data_from_table (l_schema_name, 'acc_bunch_type', 'where id = ' || rc.bunch_type_id, null, 0, l_update_mode);
        data_from_table (l_schema_name, 'acc_entry_tpl', 'where bunch_type_id = ' || rc.bunch_type_id, null, 0, l_update_mode);
    end loop;
end macros_bunch_type_upload;


procedure operation_template_upload (
    i_template_id    in com_api_type_pkg.t_short_id
  , i_schema_name    in com_api_type_pkg.t_oracle_name
  , i_update_mode    in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_combined_mode  in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE -- If you want to upload only templates with modificators, set it to com_api_const_pkg.FALSE
) is
    l_schema_name     com_api_type_pkg.t_oracle_name := upper(trim(i_schema_name)); 
    l_update_mode     com_api_type_pkg.t_boolean := i_update_mode; 
    l_template_id     com_api_type_pkg.t_short_id := i_template_id;
    l_sql             com_api_type_pkg.t_sql_statement;
    l_sql_rule        com_api_type_pkg.t_sql_statement;
    l_mod_list        com_api_type_pkg.t_tiny_tab;
begin
    write_line('--------------------------------------------------------');
    if i_combined_mode = com_api_const_pkg.TRUE then
        write_line('-- COMBINED script: Processing template ID ' || l_template_id);
    else
        write_line('-- Processing template ID ' || l_template_id);
    end if;
    write_line('--------------------------------------------------------');

    if i_combined_mode = com_api_const_pkg.TRUE then
        for rc in (
            select * from opr_rule_selection where id = l_template_id
        ) loop
            write_line('-- C1. Operation type ' || rc.oper_type);
            if substr(rc.oper_type, 1, 4) = 'OPTP' then
                data_from_table (l_schema_name, 'COM_DICTIONARY', 'where dict = ''OPTP'' and code = ''' || substr(rc.oper_type, 5) || '''', null, 0, com_api_const_pkg.FALSE);
            end if;
            l_sql := null;
            for rc2 in (
                select * from opr_participant_type where oper_type = rc.oper_type
            ) loop
                l_sql := l_sql || rc2.id || ', ';
                data_from_table (l_schema_name, 'OPR_PARTICIPANT_TYPE', 'where id = ' || rc2.id, null, 0, l_update_mode);
            end loop;
            if l_sql is not null then
                write_line('delete from opr_participant_type where oper_type = ''' || rc.oper_type || ''' ');
                write_line('and id not in (' || rtrim(l_sql, ', ') || ')');
                write_line('/');
            end if;
            write_line('-- C2. Operation template with modifiers');
            data_from_table (l_schema_name, 'OPR_RULE_SELECTION', 'where id = ' || rc.id, null, 0, l_update_mode);
            if rc.mod_id is not null then
                for rc_mod in (
                    select * from rul_mod where id = rc.mod_id
                ) loop
                    data_from_table (l_schema_name, 'RUL_MOD', 'where id = ' || rc_mod.id || ' and id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY', null, 0, l_update_mode);
                    data_from_table (l_schema_name, 'RUL_MOD_SCALE', 'where id = ' || rc_mod.scale_id || ' and id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY', null, 0, l_update_mode);
                    data_from_table (l_schema_name, 'RUL_MOD_SCALE_PARAM', 'where scale_id = ' || rc_mod.scale_id || ' and id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY', null, 0, l_update_mode);
                    add_mod_to_the_list(
                        i_mod_id     => rc_mod.id
                      , io_mod_list  => l_mod_list
                    );
                end loop;
            end if;

            write_line('-- C3. Rule set');
            if rc.rule_set_id is not null then
                rule_set_upload (
                    i_rule_set_id    => rc.rule_set_id
                  , i_schema_name    => i_schema_name
                  , i_update_mode    => i_update_mode
                );
            end if;

            write_line('-- C4. Macros-bunch type and transaction templates');
            for rc_m in (
                select distinct ppv.param_value as macros_type_id
                  from rul_rule_param_value ppv
                     , rul_proc_param pp
                     , rul_rule r
                 where pp.proc_id = r.proc_id
                   and pp.id = ppv.proc_param_id
                   and r.id = ppv.rule_id
                   and pp.param_id = 10000946 -- MACROS_TYPE
                   and r.rule_set_id = rc.rule_set_id
            ) loop
                macros_bunch_type_upload (
                    i_macros_type_id  => rc_m.macros_type_id
                  , i_schema_name     => i_schema_name
                  , i_update_mode     => i_update_mode
                );
                for rc_e in (
                    select distinct et.transaction_type
                      from acc_macros_type mt
                         , acc_entry_tpl et
                     where et.bunch_type_id = mt.bunch_type_id
                       and mt.id = rc_m.macros_type_id
                ) loop
                    if substr(rc_e.transaction_type, 1, 4) = 'TRNT' then
                        data_from_table (l_schema_name, 'COM_DICTIONARY', 'where dict = ''TRNT'' and code = ''' || substr(rc_e.transaction_type, 5) || '''', null, 0, com_api_const_pkg.FALSE);
                    end if;
                end loop;
            end loop;
        end loop;
    else

        for rc in (
            select * from opr_rule_selection where id = l_template_id
        ) loop
            data_from_table (l_schema_name, 'OPR_RULE_SELECTION', 'where id = ' || rc.id, null, 0, l_update_mode);
            if rc.mod_id is not null then
                for rc_mod in (
                    select * from rul_mod where id = rc.mod_id
                ) loop
                    data_from_table (l_schema_name, 'RUL_MOD', 'where id = ' || rc_mod.id || ' and id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY', null, 0, l_update_mode);
                    data_from_table (l_schema_name, 'RUL_MOD_SCALE', 'where id = ' || rc_mod.scale_id || ' and id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY', null, 0, l_update_mode);
                    data_from_table (l_schema_name, 'RUL_MOD_SCALE_PARAM', 'where scale_id = ' || rc_mod.scale_id || ' and id >= cst_apc_const_pkg.CUSTOM_ID_START_TINY', null, 0, l_update_mode);
                    add_mod_to_the_list(
                        i_mod_id     => rc_mod.id
                      , io_mod_list  => l_mod_list
                    );
                end loop;
            end if;
        end loop;
    end if;

    create_mod_static_pkg(
        i_mod_list  => l_mod_list
    );
end operation_template_upload;


procedure export_product (
    i_product_id         in     com_api_type_pkg.t_short_id
  , i_cst_update_mode    in     com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
)
is
    LOG_PREFIX            constant com_api_type_pkg.t_name         := lower($$PLSQL_UNIT) ||'.export_product: ';
    l_current_schema               com_api_type_pkg.t_oracle_name;
    l_session_file_id              com_api_type_pkg.t_long_id;
    l_sysdate                      date;
begin
    l_current_schema := sys_context('userenv', 'CURRENT_SCHEMA');
    trc_log_pkg.info(
        i_text        => LOG_PREFIX || 'i_product_id [#1], i_cst_update_mode [#2], schema [#3]'
      , i_env_param1  => i_product_id
      , i_env_param2  => i_cst_update_mode
      , i_env_param3  => l_current_schema
    );
    
    prc_api_stat_pkg.log_start;
    l_sysdate := com_api_sttl_day_pkg.get_sysdate;
    
    prc_api_file_pkg.open_file(
        o_sess_file_id  => g_session_file_id
    );
    
    product_upload (
        i_product_id   => i_product_id
      , i_schema_name  => l_current_schema
      , i_update_mode  => i_cst_update_mode
    );

    trc_log_pkg.info(
        i_text        => LOG_PREFIX || 'Process is finished.'
    );
    
    prc_api_file_pkg.close_file(
        i_sess_file_id  => g_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    prc_api_stat_pkg.log_end (
        i_result_code   => prc_api_const_pkg.PROCESS_RESULT_SUCCESS 
    );
    g_session_file_id := null;
    
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if g_session_file_id is not null then
            prc_api_file_pkg.close_file(
                i_sess_file_id  => g_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
            g_session_file_id := null;
        end if;        
        
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;
end export_product;


procedure export_network (
    i_network_id         in     com_api_type_pkg.t_tiny_id
  , i_cst_update_mode    in     com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
)
is
    LOG_PREFIX            constant com_api_type_pkg.t_name         := lower($$PLSQL_UNIT) ||'.export_network: ';
    l_current_schema               com_api_type_pkg.t_oracle_name;
    l_session_file_id              com_api_type_pkg.t_long_id;
    l_sysdate                      date;
begin
    l_current_schema := sys_context('userenv', 'CURRENT_SCHEMA');
    trc_log_pkg.info(
        i_text        => LOG_PREFIX || 'i_network_id [#1], i_cst_update_mode [#2], schema [#3]'
      , i_env_param1  => i_network_id
      , i_env_param2  => i_cst_update_mode
      , i_env_param3  => l_current_schema
    );
    
    prc_api_stat_pkg.log_start;
    l_sysdate := com_api_sttl_day_pkg.get_sysdate;
    
    prc_api_file_pkg.open_file(
        o_sess_file_id  => g_session_file_id
    );
    
    network_settings_upload (
        i_network_id   => i_network_id
      , i_schema_name  => l_current_schema
      , i_update_mode  => i_cst_update_mode
    );

    trc_log_pkg.info(
        i_text        => LOG_PREFIX || 'Process is finished.'
    );
    
    prc_api_file_pkg.close_file(
        i_sess_file_id  => g_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    prc_api_stat_pkg.log_end (
        i_result_code   => prc_api_const_pkg.PROCESS_RESULT_SUCCESS 
    );
    g_session_file_id := null;
    
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if g_session_file_id is not null then
            prc_api_file_pkg.close_file(
                i_sess_file_id  => g_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
            g_session_file_id := null;
        end if;        
        
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;
end export_network;


procedure export_settlement_mapping (
    i_cst_update_mode    in     com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
  , i_cst_delete_others  in     com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
)
is
    LOG_PREFIX            constant com_api_type_pkg.t_name         := lower($$PLSQL_UNIT) ||'.export_settlement_mapping: ';
    l_current_schema               com_api_type_pkg.t_oracle_name;
    l_session_file_id              com_api_type_pkg.t_long_id;
    l_sysdate                      date;
begin
    l_current_schema := sys_context('userenv', 'CURRENT_SCHEMA');
    trc_log_pkg.info(
        i_text        => LOG_PREFIX || 'i_cst_delete_others [#1], i_cst_update_mode [#2], schema [#3]'
      , i_env_param1  => i_cst_delete_others
      , i_env_param2  => i_cst_update_mode
      , i_env_param3  => l_current_schema
    );
    
    prc_api_stat_pkg.log_start;
    l_sysdate := com_api_sttl_day_pkg.get_sysdate;
    
    prc_api_file_pkg.open_file(
        o_sess_file_id  => g_session_file_id
    );
    
    settlement_mapping_upload (
        i_schema_name    => l_current_schema
      , i_update_mode    => i_cst_update_mode
      , i_delete_others  => i_cst_delete_others
    );

    trc_log_pkg.info(
        i_text        => LOG_PREFIX || 'Process is finished.'
    );
    
    prc_api_file_pkg.close_file(
        i_sess_file_id  => g_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    prc_api_stat_pkg.log_end (
        i_result_code   => prc_api_const_pkg.PROCESS_RESULT_SUCCESS 
    );
    g_session_file_id := null;
    
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if g_session_file_id is not null then
            prc_api_file_pkg.close_file(
                i_sess_file_id  => g_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
            g_session_file_id := null;
        end if;        
        
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;
end export_settlement_mapping;


procedure export_rule_set (
    i_cst_rule_set_id    in     com_api_type_pkg.t_tiny_id
  , i_cst_update_mode    in     com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
)
is
    LOG_PREFIX            constant com_api_type_pkg.t_name         := lower($$PLSQL_UNIT) ||'.export_rule_set: ';
    l_current_schema               com_api_type_pkg.t_oracle_name;
    l_session_file_id              com_api_type_pkg.t_long_id;
    l_sysdate                      date;
begin
    l_current_schema := sys_context('userenv', 'CURRENT_SCHEMA');
    trc_log_pkg.info(
        i_text        => LOG_PREFIX || 'i_cst_rule_set_id [#1], i_cst_update_mode [#2], schema [#3]'
      , i_env_param1  => i_cst_rule_set_id
      , i_env_param2  => i_cst_update_mode
      , i_env_param3  => l_current_schema
    );
    
    prc_api_stat_pkg.log_start;
    l_sysdate := com_api_sttl_day_pkg.get_sysdate;
    
    prc_api_file_pkg.open_file(
        o_sess_file_id  => g_session_file_id
    );
    
    rule_set_upload (
        i_rule_set_id    => i_cst_rule_set_id
      , i_schema_name    => l_current_schema
      , i_update_mode    => i_cst_update_mode
    );

    trc_log_pkg.info(
        i_text        => LOG_PREFIX || 'Process is finished.'
    );
    
    prc_api_file_pkg.close_file(
        i_sess_file_id  => g_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    prc_api_stat_pkg.log_end (
        i_result_code   => prc_api_const_pkg.PROCESS_RESULT_SUCCESS 
    );
    g_session_file_id := null;
    
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if g_session_file_id is not null then
            prc_api_file_pkg.close_file(
                i_sess_file_id  => g_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
            g_session_file_id := null;
        end if;        
        
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;
end export_rule_set;


procedure export_event (
    i_event_type         in     com_api_type_pkg.t_dict_value
  , i_cst_update_mode    in     com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
)
is
    LOG_PREFIX            constant com_api_type_pkg.t_name         := lower($$PLSQL_UNIT) ||'.export_event: ';
    l_current_schema               com_api_type_pkg.t_oracle_name;
    l_session_file_id              com_api_type_pkg.t_long_id;
    l_sysdate                      date;
begin
    l_current_schema := sys_context('userenv', 'CURRENT_SCHEMA');
    trc_log_pkg.info(
        i_text        => LOG_PREFIX || 'i_event_type [#1], i_cst_update_mode [#2], schema [#3]'
      , i_env_param1  => i_event_type
      , i_env_param2  => i_cst_update_mode
      , i_env_param3  => l_current_schema
    );
    
    prc_api_stat_pkg.log_start;
    l_sysdate := com_api_sttl_day_pkg.get_sysdate;
    
    prc_api_file_pkg.open_file(
        o_sess_file_id  => g_session_file_id
    );
    
    events_upload (
        i_event_type     => i_event_type
      , i_schema_name    => l_current_schema
      , i_update_mode    => i_cst_update_mode
      , i_combined_mode  => com_api_const_pkg.TRUE -- Uploads also rule sets
    );

    trc_log_pkg.info(
        i_text        => LOG_PREFIX || 'Process is finished.'
    );
    
    prc_api_file_pkg.close_file(
        i_sess_file_id  => g_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    prc_api_stat_pkg.log_end (
        i_result_code   => prc_api_const_pkg.PROCESS_RESULT_SUCCESS 
    );
    g_session_file_id := null;
    
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if g_session_file_id is not null then
            prc_api_file_pkg.close_file(
                i_sess_file_id  => g_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
            g_session_file_id := null;
        end if;        
        
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;
end export_event;


procedure export_notifications (
    i_cst_ntf_scheme_id  in     com_api_type_pkg.t_tiny_id
  , i_cst_update_mode    in     com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
)
is
    LOG_PREFIX            constant com_api_type_pkg.t_name         := lower($$PLSQL_UNIT) ||'.export_notifications: ';
    l_current_schema               com_api_type_pkg.t_oracle_name;
    l_session_file_id              com_api_type_pkg.t_long_id;
    l_sysdate                      date;
begin
    l_current_schema := sys_context('userenv', 'CURRENT_SCHEMA');
    trc_log_pkg.info(
        i_text        => LOG_PREFIX || 'i_cst_ntf_scheme_id [#1], i_cst_update_mode [#2], schema [#3]'
      , i_env_param1  => i_cst_ntf_scheme_id
      , i_env_param2  => i_cst_update_mode
      , i_env_param3  => l_current_schema
    );
    
    prc_api_stat_pkg.log_start;
    l_sysdate := com_api_sttl_day_pkg.get_sysdate;
    
    prc_api_file_pkg.open_file(
        o_sess_file_id  => g_session_file_id
    );
    
    notifications_upload (
        i_scheme_id      => i_cst_ntf_scheme_id
      , i_schema_name    => l_current_schema
      , i_update_mode    => i_cst_update_mode
    );

    trc_log_pkg.info(
        i_text        => LOG_PREFIX || 'Process is finished.'
    );
    
    prc_api_file_pkg.close_file(
        i_sess_file_id  => g_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    prc_api_stat_pkg.log_end (
        i_result_code   => prc_api_const_pkg.PROCESS_RESULT_SUCCESS 
    );
    g_session_file_id := null;
    
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if g_session_file_id is not null then
            prc_api_file_pkg.close_file(
                i_sess_file_id  => g_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
            g_session_file_id := null;
        end if;        
        
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;
end export_notifications;


procedure export_macros_bunch_type (
    i_cst_macros_type_id in     com_api_type_pkg.t_tiny_id
  , i_cst_update_mode    in     com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
)
is
    LOG_PREFIX            constant com_api_type_pkg.t_name         := lower($$PLSQL_UNIT) ||'.export_macros_bunch_type: ';
    l_current_schema               com_api_type_pkg.t_oracle_name;
    l_session_file_id              com_api_type_pkg.t_long_id;
    l_sysdate                      date;
begin
    l_current_schema := sys_context('userenv', 'CURRENT_SCHEMA');
    trc_log_pkg.info(
        i_text        => LOG_PREFIX || 'i_cst_macros_type_id [#1], i_cst_update_mode [#2], schema [#3]'
      , i_env_param1  => i_cst_macros_type_id
      , i_env_param2  => i_cst_update_mode
      , i_env_param3  => l_current_schema
    );
    
    prc_api_stat_pkg.log_start;
    l_sysdate := com_api_sttl_day_pkg.get_sysdate;
    
    prc_api_file_pkg.open_file(
        o_sess_file_id  => g_session_file_id
    );
    
    macros_bunch_type_upload (
        i_macros_type_id => i_cst_macros_type_id
      , i_schema_name    => l_current_schema
      , i_update_mode    => i_cst_update_mode
    );

    trc_log_pkg.info(
        i_text        => LOG_PREFIX || 'Process is finished.'
    );
    
    prc_api_file_pkg.close_file(
        i_sess_file_id  => g_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    prc_api_stat_pkg.log_end (
        i_result_code   => prc_api_const_pkg.PROCESS_RESULT_SUCCESS 
    );
    g_session_file_id := null;

exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if g_session_file_id is not null then
            prc_api_file_pkg.close_file(
                i_sess_file_id  => g_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
            g_session_file_id := null;
        end if;        
        
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;
end export_macros_bunch_type;


procedure export_operation_template (
    i_cst_oper_template_id  in     com_api_type_pkg.t_short_id
  , i_cst_update_mode       in     com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
)
is
    LOG_PREFIX            constant com_api_type_pkg.t_name         := lower($$PLSQL_UNIT) ||'.export_operation_template: ';
    l_current_schema               com_api_type_pkg.t_oracle_name;
    l_session_file_id              com_api_type_pkg.t_long_id;
    l_sysdate                      date;
begin
    l_current_schema := sys_context('userenv', 'CURRENT_SCHEMA');
    trc_log_pkg.info(
        i_text        => LOG_PREFIX || 'i_cst_oper_template_id [#1], i_cst_update_mode [#2], schema [#3]'
      , i_env_param1  => i_cst_oper_template_id
      , i_env_param2  => i_cst_update_mode
      , i_env_param3  => l_current_schema
    );
    
    prc_api_stat_pkg.log_start;
    l_sysdate := com_api_sttl_day_pkg.get_sysdate;
    
    prc_api_file_pkg.open_file(
        o_sess_file_id  => g_session_file_id
    );
    
    operation_template_upload (
        i_template_id    => i_cst_oper_template_id
      , i_schema_name    => l_current_schema
      , i_update_mode    => i_cst_update_mode
      , i_combined_mode  => com_api_const_pkg.TRUE
    );

    trc_log_pkg.info(
        i_text        => LOG_PREFIX || 'Process is finished.'
    );
    
    prc_api_file_pkg.close_file(
        i_sess_file_id  => g_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    prc_api_stat_pkg.log_end (
        i_result_code   => prc_api_const_pkg.PROCESS_RESULT_SUCCESS 
    );
    g_session_file_id := null;
    
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if g_session_file_id is not null then
            prc_api_file_pkg.close_file(
                i_sess_file_id  => g_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
            g_session_file_id := null;
        end if;        
        
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;
end export_operation_template;


end cst_apc_prc_utl_data_pkg;
/
