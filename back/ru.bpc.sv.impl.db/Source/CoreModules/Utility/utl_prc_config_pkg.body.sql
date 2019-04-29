CREATE OR REPLACE package body utl_prc_config_pkg as
/*********************************************************
*  Utility config process <br />
*  Created by Filimonov A.(filimonov@bpc.ru)  at 21.06.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: UTL_PRC_CONFIG_PKG <br />
*  @headcom
**********************************************************/

BULK_LIMIT             constant binary_integer := 400;
ACTION_INSERT          constant com_api_type_pkg.t_name := 'INSERT';
ACTION_UPDATE          constant com_api_type_pkg.t_name := 'UPDATE';
ACTION_DELETE          constant com_api_type_pkg.t_name := 'DELETE';

g_sess_file_name                com_api_type_pkg.t_name_tab;

procedure extract_config(
    i_config    in      com_api_type_pkg.t_dict_value
    , i_add_clear_statement in    com_api_type_pkg.t_boolean    default   com_api_const_pkg.FALSE
) is

    l_session_file_id   com_api_type_pkg.t_long_id;
    l_table_data        clob;
    l_clob_data         clob;
    l_count             pls_integer;
    l_cursor            sys_refcursor;
    l_id                com_api_type_pkg.t_long_id;
    l_statement         com_api_type_pkg.t_text;
    l_cnt               com_api_type_pkg.t_long_id;
begin

    prc_api_stat_pkg.log_start;

    select count(id)
      into l_count
      from utl_table_config
     where config = i_config;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count     => l_count
    );

    dbms_lob.createtemporary(l_table_data, TRUE);

    for r in (
        select table_name
             , nvl(config_condition, '1=1') config_condition
          from utl_table_config
         where config = i_config
    ) loop
        trc_log_pkg.debug('extract_config: table_name='||r.table_name||' condition='||r.config_condition);

--        trc_log_pkg.debug('extract_config: open file');
        prc_api_file_pkg.open_file(
            o_sess_file_id   => l_session_file_id
          , i_file_name      => lower(r.table_name)||'.data.sql'
        );

--        trc_log_pkg.debug('extract_config: trim clob');
        dbms_lob.trim(l_table_data, 0);

        select count(1)
          into l_count
          from user_tab_columns
         where table_name  = r.table_name
           and data_type   = 'NUMBER'
           and column_name = 'ID';

--        trc_log_pkg.debug('extract_config: extract data from table');

        if i_add_clear_statement = com_api_const_pkg.TRUE then
            l_cnt := 0;
            l_statement := 
                'select case when exists (select 1 from ' ||SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')|| '.' || r.table_name || 
                ' where ' || r.config_condition ||') then 1 else 0 end from dual';
            execute immediate l_statement into l_cnt;
            
            if l_cnt > 0 then
                if r.config_condition = '1=1' then
                    l_statement := 'truncate table ' || lower(r.table_name) || ' drop storage';
                else
                    l_statement := 'delete from ' || r.table_name || ' where ' || r.config_condition;
                end if;
                dbms_lob.writeappend(l_table_data, length(l_statement||chr(10)), l_statement||chr(10));
                dbms_lob.writeappend(l_table_data, length('/'||chr(10)), '/'||chr(10));
            end if;
        end if;

        utl_data_pkg.data_from_table (
            i_owner         => SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
          , i_table_name    => r.table_name
          , i_where_clause  => 'where '||r.config_condition
          , i_order_clause  => case when l_count >0 then 'ORDER BY ID' else null end
          , io_source       => l_table_data
        );

        prc_api_file_pkg.put_file(
            i_sess_file_id          => l_session_file_id
          , i_clob_content          => l_table_data
          , i_add_to                => com_api_const_pkg.FALSE
        );

--        trc_log_pkg.debug('extract_config: close file');
        prc_api_file_pkg.close_file(
            i_sess_file_id      => l_session_file_id
          , i_status            => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );

        -- CLOB
        for p in (
            select column_name
              from user_tab_columns
             where table_name = r.table_name
               and data_type  = 'CLOB'
        ) loop
            if l_count != 0 then

                trc_log_pkg.debug('extract_config: open clob cursor column_name='||p.column_name);
                open l_cursor for 'select id, '||p.column_name||' from '||r.table_name||' where '||r.config_condition;

                loop
    --                trc_log_pkg.debug('extract_config: fetch from cursor');
                    fetch l_cursor into l_id, l_clob_data;

                    exit when l_cursor%notfound;

                    prc_api_file_pkg.open_file(
                        o_sess_file_id   => l_session_file_id
                      , i_file_name      => lower(r.table_name)||'.'||lower(p.column_name)||'.'||l_id||'.xml'
                    );

                    prc_api_file_pkg.put_file(
                        i_sess_file_id          => l_session_file_id
                      , i_clob_content          => l_clob_data
                      , i_add_to                => com_api_const_pkg.FALSE
                    );

                    prc_api_file_pkg.close_file(
                        i_sess_file_id      => l_session_file_id
                      , i_status            => prc_api_const_pkg.FILE_STATUS_ACCEPTED
                    );

                end loop;

                close l_cursor;
            else
                trc_log_pkg.debug('Table ' || r.table_name || ' without id - skip');
            end if;
        end loop;

        prc_api_stat_pkg.increase_current(
            i_current_count     => 1
          , i_excepted_count    => 0
        );

    end loop;

    dbms_lob.freetemporary(l_table_data);

    prc_api_stat_pkg.log_end(
        i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then

        if l_cursor%isopen then
            close l_cursor;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => SQLERRM
            );
        end if;

        raise;
end;

function check_table_exists (
    i_table_name   in           com_api_type_pkg.t_name
) return com_api_type_pkg.t_boolean is
begin
    for r in (
        select table_name
          from user_tables
         where table_name = upper(i_table_name)
    ) loop
        return com_api_type_pkg.TRUE;
    end loop;

    trc_log_pkg.error('Load_config: table ['||i_table_name||'] does not exists.');
    return com_api_type_pkg.FALSE;
end;

procedure run_sql(
    i_content  in clob
) is
    l_cursor_handle  integer;
    l_clob           clob;
    l_processed      integer;
begin
    l_cursor_handle := dbms_sql.open_cursor(
                           security_level => 1
                       );
    l_clob :=  'begin ' || regexp_replace(i_content, '[/]$', ';', 1, 0, 'm') || ' end;';

    dbms_sql.parse (
        c              => l_cursor_handle
      , statement      => l_clob
      , language_flag  => dbms_sql.native
    );
    l_processed := dbms_sql.execute(l_cursor_handle);

    dbms_sql.close_cursor(c => l_cursor_handle);
  --   trc_log_pkg.debug(substr(to_char(l_clob), 1, 200));

exception
    when others then
--        trc_log_pkg.error(substr(sqlerrm,1,600));
--        trc_log_pkg.debug(substr(to_char(l_clob), 1, 200));
        if l_cursor_handle is not null then
            dbms_sql.close_cursor(l_cursor_handle);
        end if;
        raise;
end;

procedure process_script (
    i_content  in    clob
) as
    l_fields_list    com_api_type_pkg.t_lob_data;
    l_table_name     com_api_type_pkg.t_lob_data;
begin

    if nvl(dbms_lob.getlength(i_content), 0) = 0 then
        return;
    end if;

    l_fields_list :=
        dbms_lob.substr(i_content,
            dbms_lob.instr( i_content, ')') - dbms_lob.instr( i_content, '(') -1
          , dbms_lob.instr( i_content, '(')+1
        );
    l_table_name  :=
        dbms_lob.substr(i_content,
           dbms_lob.instr( i_content, '(') - dbms_lob.instr( i_content, 'insert into') -13
         , dbms_lob.instr( i_content, 'insert into')+12
        );
--    trc_log_pkg.debug(l_table_name ||': ['||l_fields_list||']');

    run_sql(i_content);

exception
    when others then
        trc_log_pkg.error(l_table_name||': '||sqlerrm);
        raise;
end;

procedure load_config is
    l_filename_tab            com_api_type_pkg.t_name_tab;
    l_content_tab             com_api_type_pkg.t_clob_tab;
    l_rownum_tab              com_api_type_pkg.t_number_tab;

    l_line                    com_api_type_pkg.t_name;
    l_table_name              com_api_type_pkg.t_name;
    l_column_name             com_api_type_pkg.t_name;
    l_id                      com_api_type_pkg.t_name;
    l_pos                     pls_integer;

    l_estimated_count         com_api_type_pkg.t_long_id := 0;
    l_excepted_count          com_api_type_pkg.t_long_id := 0;
    l_processed_count         com_api_type_pkg.t_long_id := 0;

    cursor l_session_file_cur is
    select s.file_name
         , s.file_contents
         , row_number() over(order by decode(lower(substr(file_name, -3)), 'sql', 1, 2), id) rn
--         , count(1) over() cnt
      from prc_session_file s
     where s.session_id = prc_api_session_pkg.get_session_id
     order by decode(lower(substr(file_name, -3)), 'sql', 1, 2), id;

    procedure update_row (
        i_table_name     in      com_api_type_pkg.t_name
      , i_column_name    in      com_api_type_pkg.t_name
      , i_id             in      com_api_type_pkg.t_name
      , i_content        in      clob
    ) is
        l_check_id               com_api_type_pkg.t_long_id;
        l_cursor_stmt            com_api_type_pkg.t_full_desc;
        l_cursor_handle          integer;
        l_processed              integer;
    begin
        begin
            l_cursor_stmt := 'select id from ' || i_table_name || ' where id = :id for update nowait';
            execute immediate l_cursor_stmt into l_check_id using i_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error       => 'TABLE_RECORD_NOT_FOUND'
                  , i_env_param1  => i_table_name
                  , i_env_param2  => i_id
                );
            when com_api_error_pkg.e_resource_busy then
                com_api_error_pkg.raise_error (
                    i_error       => 'TABLE_IS_BLOCKED'
                  , i_env_param1  => i_table_name
                  , i_env_param2  => i_id
                );
        end;

        begin
            l_cursor_stmt := 'update ' || i_table_name || ' set '|| i_column_name || ' = :column_value where id = :id';

            l_cursor_handle := dbms_sql.open_cursor(
                                   security_level => 1
                               );

            dbms_sql.parse (
                c              => l_cursor_handle
              , statement      => l_cursor_stmt
              , language_flag  => dbms_sql.native
            );

            dbms_sql.bind_variable(l_cursor_handle, 'column_value', i_content);
            dbms_sql.bind_variable(l_cursor_handle, 'id', i_id);

            l_processed := dbms_sql.execute(l_cursor_handle);

            dbms_sql.close_cursor(c => l_cursor_handle);
        exception
            when others then
                if l_cursor_handle is not null then
                    dbms_sql.close_cursor(l_cursor_handle);
                end if;
                com_api_error_pkg.raise_error (
                    i_error       => 'ERROR_UPDATE_TABLE'
                  , i_env_param1  => i_table_name
                  , i_env_param2  => i_column_name
                  , i_env_param3  => i_id
                  , i_env_param4  => substr(sqlerrm, 1, 200)
                );
        end;
    end;
begin
    prc_api_stat_pkg.log_start;

    select count(1)
      into l_estimated_count
      from prc_session_file s
     where s.session_id = prc_api_session_pkg.get_session_id;

    trc_log_pkg.info('Load config: '||l_estimated_count||' incoming files found.');

    prc_api_stat_pkg.log_estimation ( i_estimated_count  => l_estimated_count );

    if l_estimated_count > 0 then
        open l_session_file_cur;
        loop
            fetch l_session_file_cur
            bulk collect into
                  l_filename_tab
                , l_content_tab
                , l_rownum_tab
            limit BULK_LIMIT;

            for i in 1..l_content_tab.count loop
                begin
                trc_log_pkg.info (
                    i_text        => 'Process file '||l_rownum_tab(i)||' of '||l_estimated_count||' [#1] [#2 bytes]'
                  , i_env_param1  => l_filename_tab(i)
                  , i_env_param2  => dbms_lob.getlength(l_content_tab(i))
                );

                if regexp_like(l_filename_tab(i), '^(\w){1,30}\.data\.sql$') then

                    l_table_name := substr(l_filename_tab(i), 1, instr(l_filename_tab(i), '.') - 1 );

                    if check_table_exists ( i_table_name  => l_table_name) = com_api_const_pkg.TRUE then
                        process_script (i_content  => l_content_tab(i));
                    end if;

                elsif regexp_like(l_filename_tab(i), '^(\w){1,30}\.(\w){1,30}\.(\d){1,}\.(txt|xml|jrxml|xslt|xsd)$') then

                    l_line := l_filename_tab(i);

                    l_pos := instr(l_line, '.');
                    l_table_name := substr(l_line, 1, l_pos-1 );
                    l_line := substr(l_line, l_pos+1 );

                    l_pos := instr(l_line, '.');
                    l_column_name := substr(l_line, 1, l_pos-1 );
                    l_line := substr(l_line, l_pos+1 );

                    l_pos := instr(l_line, '.');
                    l_id := substr(l_line, 1, l_pos-1 );

                    if check_table_exists (i_table_name  => l_table_name) = com_api_const_pkg.TRUE then
                        update_row (
                            i_table_name   => l_table_name
                          , i_column_name  => l_column_name
                          , i_id           => l_id
                          , i_content      => l_content_tab(i)
                        );
                    end if;
                else
                    com_api_error_pkg.raise_error (
                        i_error         => 'UNSUPPORTED_FILENAME'
                        , i_env_param1  => l_filename_tab(i)
                    );

                end if;

---                trc_log_pkg.debug (i_text  => 'File processed');

                l_processed_count := l_processed_count + 1;
            exception
                when others then
                    l_excepted_count := l_excepted_count + 1;
            end;
            end loop;

            prc_api_stat_pkg.log_current(
                        i_current_count   => l_processed_count
                      , i_excepted_count  => l_excepted_count
            );

            exit when l_session_file_cur%notfound;
        end loop;
        close l_session_file_cur;
    end if;

    prc_api_stat_pkg.log_end(
        i_excepted_total   => l_excepted_count
      , i_processed_total  => l_processed_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    -- sync seq
    if l_estimated_count > 0 and l_processed_count > 0 then
        utl_deploy_pkg.sync_sequences;
        commit;
        begin
            trc_log_pkg.debug('generating mod static package - start');
            rul_mod_gen_pkg.generate_package;
            trc_log_pkg.debug('generating mod static package - finished');
        exception
            when others then
                trc_log_pkg.error(sqlerrm);
        end;
    else
        trc_log_pkg.info('No files loaded - sync sequences skipped.');
    end if;

    -- refresh matview
    utl_deploy_pkg.refresh_mviews;
    trc_log_pkg.info('Load configuration finished.');
exception
    when others then
        if l_session_file_cur%isopen then
            close l_session_file_cur;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;
end;

function format_value(
    i_value                   in  com_api_type_pkg.t_name
    , i_data_format           in  com_api_type_pkg.t_name
    , i_data_type             in  com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_name is
    l_result com_api_type_pkg.t_name;
begin
    if i_data_type in (com_api_const_pkg.DATA_TYPE_CHAR, com_api_const_pkg.DATA_TYPE_CLOB) then
        l_result := '''' || i_value || '''';

    elsif i_data_type = com_api_const_pkg.DATA_TYPE_DATE then
        l_result := 'to_date(''' || to_char(to_date(i_value, i_data_format), 'yyyy.mm.dd hh24:mi:ss') || ''', ''yyyy.mm.dd hh24:mi:ss'')';

    elsif i_data_type = com_api_const_pkg.DATA_TYPE_NUMBER then
        l_result := to_char(to_number(i_value, i_data_format));

    else
        l_result := i_value;
    end if;

    return l_result;
end;

function get_seqnum(
    i_table_name              in  com_api_type_pkg.t_name
    , i_object_id             in  com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_tiny_id is
    l_seqnum_sql              com_api_type_pkg.t_name;
    l_seqnum                  com_api_type_pkg.t_tiny_id;
begin
    l_seqnum_sql := 'select seqnum from ' || i_table_name || ' where id = ' || i_object_id;
    execute immediate l_seqnum_sql into l_seqnum;
    return l_seqnum;
exception
    when others then
        return null;
end;

procedure upload_incremental_config(
    i_user_session_id         com_api_type_pkg.t_long_id
) is
    l_cnt                     pls_integer;
    l_count                   pls_integer;
    l_table_name              com_api_type_pkg.t_name;
    l_action_type             com_api_type_pkg.t_name;
    l_session_file_id         com_api_type_pkg.t_long_id;
    l_object_id               com_api_type_pkg.t_long_id;
    l_processed_count         com_api_type_pkg.t_long_id := 0;
    l_cursor                  sys_refcursor;
    l_insert_sql_str          com_api_type_pkg.t_full_desc;
    l_update_sql_str          com_api_type_pkg.t_full_desc;
    l_sql_str                 com_api_type_pkg.t_full_desc;
    l_values                  com_api_type_pkg.t_full_desc;
    l_fields                  com_api_type_pkg.t_full_desc;
    l_clob_sql                com_api_type_pkg.t_full_desc;
    l_clob_data               clob;
    l_session_clob_id         com_api_type_pkg.t_long_id;
    l_seqnum                  com_api_type_pkg.t_tiny_id;
    l_cur_val                 com_api_type_pkg.t_name;
    l_main_str                com_api_type_pkg.t_full_desc;
    l_file_name               com_api_type_pkg.t_name;
    l_scheme_name             com_api_type_pkg.t_name;
    l_com_name                com_api_type_pkg.t_name;
    l_com_id                  com_api_type_pkg.t_long_id;
    l_clob                    clob;
    l_tmp_sql                 com_api_type_pkg.t_full_desc;
    l_counter                 pls_integer;
    l_session_com_id          com_api_type_pkg.t_long_id;
    l_file_exists             com_api_type_pkg.t_boolean;
    l_trail_id                com_api_type_pkg.t_long_id;
    l_last_action             com_api_type_pkg.t_name;

begin
    trc_log_pkg.debug('upload_incremental_config START');

    prc_api_stat_pkg.log_start;

    select count(1)
      into l_count
      from adt_entity e
         , adt_trail t
     where t.session_id  = i_user_session_id
       and t.entity_type = e.entity_type;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count     => l_count
    );
    trc_log_pkg.debug('l_count = ' || l_count);
    trc_log_pkg.debug('get_session_id = ' || prc_api_session_pkg.get_session_id);

    g_sess_file_name.delete();

    for r in (
        select e.table_name
             , e.entity_type
             , t.object_id
             , t.action_type
             , d.trail_id
             , count(*) column_count
          from adt_entity e
             , adt_trail t
             , adt_detail d
         where t.session_id  = i_user_session_id
           and t.entity_type = e.entity_type
           and d.trail_id    = t.id
           and e.is_active  != -1
           and upper(e.table_name) not in ('APP_APPLICATION')
         group by e.table_name
             , e.entity_type
             , t.object_id
             , t.action_type
             , d.trail_id
      order by e.table_name
             , d.trail_id
    )
    loop
        -- close previous file and open new file for new table
        if l_table_name is null or l_table_name != r.table_name then
            if l_session_file_id is not null then
                trc_log_pkg.debug('close previous file = ' || l_session_file_id);
                prc_api_file_pkg.put_file(
                    i_sess_file_id    => l_session_file_id
                  , i_clob_content    => l_main_str
                  , i_add_to          => com_api_const_pkg.FALSE
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id   => l_session_file_id
                  , i_status         => prc_api_const_pkg.FILE_STATUS_ACCEPTED
                );
            end if;

            l_main_str := '';
            l_file_name := lower(r.table_name)||'.data.sql';
            prc_api_file_pkg.open_file(
                o_sess_file_id   => l_session_file_id
              , i_file_name      => l_file_name
            );
            trc_log_pkg.debug('open new file = ' || l_session_file_id);
        end if;

        l_table_name  := r.table_name;
        l_action_type := r.action_type;
        l_object_id   := r.object_id;
        trc_log_pkg.debug('l_table_name = ' || l_table_name || ' l_action_type = ' || l_action_type ||
                          ' l_object_id = ' || l_object_id || ' r.trail_id = ' || r.trail_id);

        if upper(l_action_type) = ACTION_DELETE then
            l_sql_str := lower(l_action_type) || ' ' || lower(l_table_name) || ' where id = ' || l_object_id;
        else
            -- get detail for sql
            l_fields         := null;
            l_values         := null;
            l_sql_str        := null;
            l_insert_sql_str := 'insert into <t> (id, <fields>) values(' || l_object_id || ', <values>)';
            l_update_sql_str := 'update <t> set <fields> where id = <id>';
            l_seqnum         := null;

            for dt in (
                select d.column_name
                     , d.data_type
                     , d.data_format
                     , d.old_value
                     , d.new_value
                  from adt_detail d
                 where trail_id = r.trail_id
            ) loop
                select count(1)
                  into l_cnt
                  from user_tab_columns
                 where column_name = dt.column_name
                   and table_name = l_table_name;
                -- com_i18n
                if l_cnt = 0 then
                    if l_clob is null then
                        l_com_name := 'com_i18n' || '.data.sql';
                        prc_api_file_pkg.open_file(
                            o_sess_file_id   => l_session_com_id
                          , i_file_name      => l_com_name
                        );
                        dbms_lob.createtemporary(l_clob, TRUE, dbms_lob.session);
                    end if;
                    -- get id
                    select id
                      into l_com_id
                      from com_i18n_vw
                     where table_name  = upper(l_table_name)
                       and column_name = upper(dt.column_name)
                       and object_id   = l_object_id
                       and lang        = dt.data_format;

                    if upper(l_action_type) = ACTION_INSERT then
                        select user into l_scheme_name from dual;
                        trc_config_pkg.init_cache;
                        utl_data_pkg.data_from_table(i_owner          => l_scheme_name
                                                     , i_table_name   => 'COM_I18N'
                                                     , i_where_clause => 'where id = ' || l_com_id
                                                     , i_order_clause => null
                                                     , io_source      => l_clob
                        );
                    -- update
                    else
                        l_tmp_sql := 'update com_i18n set ' || lower(dt.column_name) || ' = ''' || dt.new_value || ''' where id = ' || l_com_id;
                        dbms_lob.writeappend(l_clob, length(l_tmp_sql||chr(10)), l_tmp_sql||chr(10));
                        dbms_lob.writeappend(l_clob, length('/'||chr(10)), '/'||chr(10));
                    end if;

                -- not com_i18n
                else
                    trc_log_pkg.debug('dt.data_type= ' || dt.data_type);
                    if dt.data_type = com_api_const_pkg.DATA_TYPE_CLOB then

                        if lower(dt.column_name) != 'base64' then
                            l_file_name   := lower(l_table_name)||'.'||lower(dt.column_name)||'.'||l_object_id||'.xml';
                            -- check if clob already save
                            l_file_exists := com_api_type_pkg.FALSE;
                            l_counter     := g_sess_file_name.first;
                            while l_counter is not null
                            loop
                                if g_sess_file_name(l_counter) = l_file_name then
                                    trc_log_pkg.debug('find double name, set name = ' || l_file_name);
                                    l_file_exists := com_api_type_pkg.TRUE;
                                    exit;
                                end if;
                                l_counter := g_sess_file_name.next(l_counter);
                            end loop;

                            if l_file_exists = com_api_type_pkg.TRUE then
                                continue;
                            end if;

                            -- get last changes
                            select id, action_type into l_trail_id, l_last_action
                            from (
                                select t.id
                                     , t.action_type
                                  from adt_entity e
                                     , adt_trail t
                                     , adt_detail d
                                 where t.session_id  = i_user_session_id
                                   and t.entity_type = e.entity_type
                                   and d.trail_id    = t.id
                                   and e.table_name  = l_table_name
                                   and d.column_name = dt.column_name
                                   and t.object_id   = l_object_id
                              order by d.trail_id desc
                              ) t where rownum = 1;

                            trc_log_pkg.debug('l_trail_id = ' || l_trail_id || ' l_last_action= ' || l_last_action);

                            -- if delete - not upload
                            if l_last_action != ACTION_DELETE then
                                l_clob_sql := 'select ' || dt.column_name || ' from ' || l_table_name || ' where id = ' || l_object_id;
                                trc_log_pkg.debug('l_clob_sql = ' || l_clob_sql);
                                open l_cursor for l_clob_sql;
                                fetch l_cursor into l_clob_data;
                                close l_cursor;

                                prc_api_file_pkg.open_file(
                                    o_sess_file_id    => l_session_clob_id
                                  , i_file_name       => l_file_name
                                );
                                prc_api_file_pkg.put_file(
                                    i_sess_file_id    => l_session_clob_id
                                  , i_clob_content    => l_clob_data
                                  , i_add_to          => com_api_const_pkg.FALSE
                                );

                                --trc_log_pkg.debug('extract_config: close clob file');
                                prc_api_file_pkg.close_file(
                                    i_sess_file_id    => l_session_clob_id
                                  , i_status          => prc_api_const_pkg.FILE_STATUS_ACCEPTED
                                );
                                g_sess_file_name(nvl(g_sess_file_name.last, 0) + 1) := l_file_name;
                            end if;
                        end if;

                    else --not clob
                        l_cur_val := format_value(
                            i_value             => dt.new_value
                            , i_data_format     => dt.data_format
                            , i_data_type       => dt.data_type
                        );

                        if upper(l_action_type) = ACTION_INSERT then
                            l_fields := l_fields || lower(dt.column_name) || ', ';
                            l_values := l_values || l_cur_val   || ', ';
                        else --update
                            l_fields := l_fields || lower(dt.column_name) || ' = ' || l_cur_val || ', ';
                        end if;
                    end if;

                end if;

            end loop;

            if l_fields is not null then
                if upper(l_action_type) = ACTION_INSERT then
                    l_seqnum := get_seqnum(
                        i_table_name         => l_table_name
                        , i_object_id        => l_object_id
                    );
                    if l_seqnum is not null then
                        l_fields := l_fields || 'seqnum, ';
                        l_values := l_values || l_seqnum   || ', ';
                    end if;
                    l_fields         := substr(l_fields, 1, length(l_fields) - 2);
                    l_values         := substr(l_values, 1, length(l_values) - 2);
                    l_insert_sql_str := replace(l_insert_sql_str, '<t>', lower(l_table_name));
                    l_insert_sql_str := replace(l_insert_sql_str, '<fields>', l_fields);
                    l_insert_sql_str := replace(l_insert_sql_str, '<values>', l_values);
                    l_sql_str        := l_insert_sql_str;
                else --update

                    l_fields         := substr(l_fields, 1, length(l_fields) - 2);
                    l_update_sql_str := replace(l_update_sql_str, '<t>', lower(l_table_name));
                    l_update_sql_str := replace(l_update_sql_str, '<fields>', l_fields);
                    l_update_sql_str := replace(l_update_sql_str, '<id>', l_object_id);
                    l_sql_str        := l_update_sql_str;
                end if;
            end if;
        end if;

        trc_log_pkg.debug('l_sql_str = ' || l_sql_str);

        if l_sql_str is not null then
            l_main_str := l_main_str || l_sql_str;
            l_main_str := l_main_str || chr(10) || '/' || chr(10);
            --trc_log_pkg.debug('l_main_str = ' || l_main_str);
        end if;

        l_processed_count := l_processed_count + 1;

        prc_api_stat_pkg.log_current (
            i_current_count     => l_processed_count
            , i_excepted_count  => 0
        );
    end loop;

    if l_session_file_id is not null then
        trc_log_pkg.debug('close previous file = ' || l_session_file_id);
        prc_api_file_pkg.put_file(
            i_sess_file_id    => l_session_file_id
          , i_clob_content    => l_main_str
          , i_add_to          => com_api_const_pkg.FALSE
        );

        prc_api_file_pkg.close_file(
            i_sess_file_id     => l_session_file_id
          , i_status           => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    end if;

    -- close com_i18n
    if l_session_com_id is not null then
        trc_log_pkg.debug('close com_i18n = ' || l_session_com_id);
        prc_api_file_pkg.put_file(
            i_sess_file_id    => l_session_com_id
          , i_clob_content    => l_clob
          , i_add_to          => com_api_const_pkg.FALSE
        );

        prc_api_file_pkg.close_file(
            i_sess_file_id     => l_session_com_id
          , i_status           => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug('upload_incremental_config END');
exception
    when others then
        if l_cursor%isopen then
            close l_cursor;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;
end;

end;
/