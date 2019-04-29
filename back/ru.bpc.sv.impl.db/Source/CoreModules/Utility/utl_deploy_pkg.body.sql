create or replace package body utl_deploy_pkg as
/**********************************************************
 * Deploy utilites<br/>
 * Created by Filimonov A.(filimonov@bpc.ru)  at 05.08.2010<br/>
 * Module: UTL_DEPLOY_PKG
 * @headcom
 **********************************************************/

SCRIPT_RUN_TYPE_BEFORE          constant    com_api_type_pkg.t_dict_value  := 'DSRTBEFR';
SCRIPT_RUN_TYPE_AFTER           constant    com_api_type_pkg.t_dict_value  := 'DSRTAFTR';
SCRIPT_APPL_TYPE_BUILD_PATCH    constant    com_api_type_pkg.t_dict_value  := 'DSATBLPT';
SCRIPT_MULT_LAUNCH_ONETIME      constant    com_api_type_pkg.t_dict_value  := 'DSMLONEL';
SCRIPT_MULT_LAUNCH_UNLIMITED    constant    com_api_type_pkg.t_dict_value  := 'DSMLUNLM';

LOG_STR_MAX_LENGTH              constant    com_api_type_pkg.t_count       := 4000;
LOG_STR_CRITICAL_LENGTH         constant    com_api_type_pkg.t_count       := 3700;

CRLF                            constant    com_api_type_pkg.t_name        := chr(13) || chr(10);

-- Session ID for logging errors are detected by checks
SESSION_ID_CHECKS               constant    com_api_type_pkg.t_long_id     := -1;

g_session_id                                com_api_type_pkg.t_long_id;

-- Package parameter is used in wrapper debug(): debugging output into TRC_LOG or DBMS_OUTPUT
g_use_dbms_output                           com_api_type_pkg.t_boolean;

cursor g_cur_pan_tables
is
select t.table_name, c.column_name
  from user_tab_cols c
  join utl_table       t on t.table_name = c.table_name
 where upper(c.column_name) like '%CARD_NUMBER%'
   and c.virtual_column = 'NO';


procedure enable_dbms_output
is
begin
    g_use_dbms_output := com_api_const_pkg.TRUE;
    -- Enable the buffer with unlimited size
    dbms_output.enable(buffer_size => NULL);
end;


procedure disable_dbms_output
is
    l_session_id                com_api_type_pkg.t_long_id;
begin
    g_use_dbms_output := com_api_const_pkg.FALSE;

    if com_ui_user_env_pkg.get_user_name() is null then
        com_ui_user_env_pkg.set_user_context(
            i_user_name   => 'ADMIN'
          , io_session_id => l_session_id
        );
    end if;
end;


/*
 * Set temporary session for logging into the table.
 */
procedure set_temporary_session(
    i_session_id        in      com_api_type_pkg.t_long_id
) is
begin
    if g_use_dbms_output = com_api_const_pkg.FALSE then
        g_session_id := prc_api_session_pkg.get_session_id();
        prc_api_session_pkg.set_session_id(i_session_id => i_session_id);
    end if;
end;


/*
 * Unset temporary session, restore main client session.
 */
procedure unset_temporary_session
is
begin
    if g_use_dbms_output = com_api_const_pkg.FALSE then
        prc_api_session_pkg.set_session_id(i_session_id => g_session_id);
        g_session_id := null;
    end if;
end;


/*
 * Debug wrapper.
 */
procedure debug(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
) is
    l_text                      com_api_type_pkg.t_text;
    l_label_id                  com_api_type_pkg.t_short_id;
    l_param_text                com_api_type_pkg.t_text;
begin
    if i_text is null then
        null;
    elsif g_use_dbms_output = com_api_const_pkg.TRUE then
        -- Try to format text message
        l_text := trim(i_text);
        if     i_env_param1 is not null
            or i_env_param2 is not null
            or i_env_param3 is not null
            or i_env_param4 is not null
            or i_env_param5 is not null
            or i_env_param6 is not null
        then
            begin
                trc_text_pkg.get_text(
                    i_level       => trc_config_pkg.DEBUG
                  , io_text       => l_text
                  , i_env_param1  => i_env_param1
                  , i_env_param2  => i_env_param2
                  , i_env_param3  => i_env_param3
                  , i_env_param4  => i_env_param4
                  , i_env_param5  => i_env_param5
                  , i_env_param6  => i_env_param6
                  , i_get_text    => com_api_const_pkg.TRUE
                  , o_label_id    => l_label_id
                  , o_param_text  => l_param_text
                );
            exception
                when others then
                    null;
            end;
        end if;
        dbms_output.put_line(l_text);
    else
        trc_log_pkg.debug(
            i_text       => trim(i_text)
          , i_env_param1 => i_env_param1
          , i_env_param2 => i_env_param2
          , i_env_param3 => i_env_param3
          , i_env_param4 => i_env_param4
          , i_env_param5 => i_env_param5
          , i_env_param6 => i_env_param6
        );
    end if;
end debug;


function get_entity_table(
    i_entity_type         in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_oracle_name
result_cache
relies_on (adt_entity)
is
    l_table_name                 com_api_type_pkg.t_oracle_name;
begin
    select table_name
      into l_table_name
      from adt_entity
     where entity_type = i_entity_type;

    return l_table_name;
exception
    when no_data_found then
        return null;
end;


function check_column(
    i_table_name          in     com_api_type_pkg.t_oracle_name
  , i_column_name         in     com_api_type_pkg.t_oracle_name := 'SPLIT_HASH'
) return com_api_type_pkg.t_tiny_id
result_cache
is
    l_count                      com_api_type_pkg.t_count := 0;
begin
    select count(1)
      into l_count
      from user_tab_columns
     where table_name  = upper(i_table_name)
       and column_name = upper(i_column_name);

    return l_count;
end check_column;


procedure create_audit_triggers is
begin
    adt_api_trigger_pkg.create_audit_trigger;
end;


procedure move_tablespaces is
    l_tablespace_index      com_api_type_pkg.t_oracle_name;
    l_sql                   com_api_type_pkg.t_text;
    l_count                 pls_integer := 0;
    l_error_cnt             pls_integer := 0;

    -- rebuild all invalid indexes for correct work of TRC_LOG.error procedure
    procedure rebuild_invalid_indexes is
    begin
        dbms_output.put_line('rebuild_invalid_indexes started');

        for r in (
            select i.index_name, p.partition_name, p.tablespace_name
              from user_indexes i
                 , user_ind_partitions p
             where i.status        != 'VALID'
               and p.index_name (+) = i.index_name
               and i.index_type(+) != 'LOB'
        ) loop
            begin
                l_sql := 'alter index '||r.index_name||' rebuild '
                            || case when r.partition_name is not null
                                   then ' partition '||r.partition_name||' tablespace '||r.tablespace_name
                                   end;

                dbms_output.put_line('execute immediate ' || l_sql);
                execute immediate l_sql;
            exception
                when others then
                    l_error_cnt := l_error_cnt + 1;
                    dbms_output.put_line('Error: ' ||l_sql);
                    dbms_output.put_line('Rebuild index '||r.index_name||': '||substr(SQLERRM, 1, 200));

            end;
        end loop;

        dbms_output.put_line('rebuild_invalid_indexes finished');
    end rebuild_invalid_indexes;

begin
    dbms_output.enable(buffer_size => NULL);
    rebuild_invalid_indexes;

    dbms_output.put_line('Move tablespaces started.');

    for r in (
        select a.table_name
             , a.tablespace_name
               tablespace_name_new
             , nvl(b.tablespace_name
                 , (select stragg(x.tablespace_name) from user_indexes x
                     where x.index_type = 'IOT - TOP' and x.table_name = b.table_name)
               ) tablespace_name_old
             , count(*) over() cnt
             , row_number() over( order by a.table_name) rn
             , b.iot_type
          from utl_table a
             , user_tables b
         where a.tablespace_name is not null
           and a.tablespace_name not in ('SYSTEM', 'SYSAUX')
           and a.tablespace_name in (select tablespace_name from user_tablespaces where contents = 'PERMANENT')
           and a.table_name       = b.table_name
         order by a.table_name
    ) loop
        l_count := r.cnt;
        l_tablespace_index := replace(r.tablespace_name_new, 'DATA', 'INDX');
        if r.iot_type = 'IOT'
        and r.tablespace_name_new != r.tablespace_name_old then
            begin
                l_sql := 'alter table '||r.table_name||' move tablespace '||l_tablespace_index;
                dbms_output.put_line('execute immediate ' || l_sql);
                execute immediate l_sql;
            exception
                when others then
                    l_error_cnt := l_error_cnt + 1;
                    dbms_output.put_line('Error' || l_sql);
                    dbms_output.put_line('Move IOT table '||r.table_name||': '||substr(SQLERRM, 1, 200));

            end;
        elsif r.tablespace_name_new != r.tablespace_name_old
          and r.tablespace_name_old is not null
        then
            begin
                l_sql := 'alter table '||r.table_name||' move tablespace '||r.tablespace_name_new;
                dbms_output.put_line('execute immediate ' || l_sql);
                execute immediate l_sql;
            exception
                when others then
                    l_error_cnt := l_error_cnt + 1;
                    dbms_output.put_line('Error: ' || l_sql);
                    dbms_output.put_line('Move table '||r.table_name||': '||substr(SQLERRM, 1, 200));

            end;
        end if;

        --
        dbms_output.put_line('Move SubPartitions for table ' || r.table_name || ' started.');

        for s in (
            select subpartition_name
              from user_tab_subpartitions b
             where b.table_name       = r.table_name
               and b.tablespace_name != r.tablespace_name_new
        ) loop
            begin
                l_sql := 'alter table '||r.table_name||' move subpartition '||s.subpartition_name||' tablespace '||r.tablespace_name_new;
                dbms_output.put_line('execute immediate ' || l_sql);
                execute immediate l_sql;
            exception
                when others then
                    l_error_cnt := l_error_cnt + 1;
                    dbms_output.put_line('Error: ' || l_sql);
                    dbms_output.put_line('Move subpartition '||r.table_name||'_'||s.subpartition_name||': '||substr(SQLERRM, 1, 200));

            end;
        end loop;
        dbms_output.put_line('Move SubPartitions for table ' || r.table_name || ' finished.');
        dbms_output.put_line('Move partitions for table ' || r.table_name || ' started.');
        for q in (
            select d.partition_name
                , (select count(1) from user_tab_subpartitions s
                    where s.table_name = r.table_name) sub_cnt
              from user_tab_partitions d
             where d.table_name       = r.table_name
               and d.tablespace_name != r.tablespace_name_new
        ) loop
            begin
                if q.sub_cnt > 0 then
                    l_sql := 'alter table '||r.table_name||' modify default attributes for partition '
                            ||q.partition_name||' tablespace '||r.tablespace_name_new;
                else
                   l_sql := 'alter table '||r.table_name||' move partition '||q.partition_name
                            ||' tablespace '||r.tablespace_name_new;
                end if;
                dbms_output.put_line('execute immediate ' || l_sql);
                execute immediate l_sql;
            exception
                when others then
                    l_error_cnt := l_error_cnt + 1;
                    dbms_output.put_line('Error: ' || l_sql);
                    dbms_output.put_line('Move partition '||r.table_name||'_'||q.partition_name ||': '||substr(SQLERRM, 1, 200));
            end;
        end loop;
        dbms_output.put_line('Move partitions for table ' || r.table_name || ' finished.');
        dbms_output.put_line('Rebuild tablespaces and move LOB columns for table ' || r.table_name || ' started.');
        for s in (
            select c.index_name
                 , c.index_type
              from user_indexes c
             where c.table_name       = r.table_name
               and index_type        != 'IOT - TOP'
               and c.tablespace_name != l_tablespace_index
        ) loop
            if s.index_type = 'LOB' then
                for q in (
                    select c.column_name
                      from user_tab_columns c
                      where c.table_name = r.table_name
                        and data_type like '%LOB'
                ) loop
                    begin
                        l_sql := 'alter table '||r.table_name||' move tablespace '||l_tablespace_index
                               ||' lob('||q.column_name||') store as (tablespace '||l_tablespace_index||')';
                        dbms_output.put_line('execute immediate ' || l_sql);
                        execute immediate l_sql;
                    exception
                        when others then
                            l_error_cnt := l_error_cnt + 1;
                            dbms_output.put_line('Error: ' || l_sql);
                            dbms_output.put_line('Move LOB index '||s.index_name||': '||substr(SQLERRM, 1, 200));
                    end;
                end loop;
            else
                begin
                    l_sql := 'alter index '||s.index_name||' rebuild tablespace '||l_tablespace_index||' online';
                    dbms_output.put_line('execute immediate ' || l_sql);
                    execute immediate l_sql;
                exception
                    when others then
                        l_error_cnt := l_error_cnt + 1;
                        dbms_output.put_line('Error: ' || l_sql);
                        dbms_output.put_line('Move index '||s.index_name||': '||substr(SQLERRM, 1, 200));
                end;
            end if;
        end loop;
        dbms_output.put_line('Rebuild tablespaces and move LOB columns for table ' || r.table_name || ' finished.');
    end loop;
    -- rebuild all invalid indexes after tablespace movement
    rebuild_invalid_indexes;
    --
    dbms_output.put_line('Move tablespaces finished. Total '||l_count||' tables processed, '||l_error_cnt||' errors.');

exception
    when others then
        dbms_output.put_line(dbms_utility.format_error_backtrace||dbms_utility.format_error_stack);
end move_tablespaces;


procedure refresh_mviews is
begin
    commit;
    for rec in (
        select object_name as str from user_objects where  object_type = 'MATERIALIZED VIEW'
    ) loop
        refresh_mviews(i_name => rec.str);
    end loop;
end refresh_mviews;


procedure refresh_mviews(
    i_name                in     com_api_type_pkg.t_oracle_name
) is
begin
    for rec in (
        select regexp_substr(i_name,'[^,]+', 1, level) as view_name from dual
            connect by regexp_substr(i_name, '[^,]+', 1, level) is not null)
    loop
        execute immediate 'alter materialized view ' || rec.view_name || ' compile';
    end loop;
    dbms_snapshot.refresh(
        list                 => i_name
      , push_deferred_rpc    => true
      , refresh_after_errors => false
      , purge_option         => 1
      , parallelism          => 0
      , atomic_refresh       => true
      , nested               => false
    );
end refresh_mviews;


/*
 * Synchronization of sequences in according to passed value of parameter i_instance_type.
 * INSTANCE_TYPE_CORE
 *     for all user tables in UTL_TABLE corresponding sequences are set to maximum
 *     value of ID (primary key field) but not greater than INSTANCE_TYPE_CUSTOM1
 * INSTANCE_TYPE_CUSTOM1 / INSTANCE_TYPE_CUSTOM2
 *     for all user tables in UTL_TABLE corresponding sequences are set to maximum
 *     value of ID from interval [INSTANCE_TYPE_CUSTOM1; INSTANCE_TYPE_PRODUCTION - 1].
 * INSTANCE_TYPE_PRODUCTION
 *     for all user tables in UTL_TABLE corresponding sequences are set to maximum
 *     value of ID without any restrictions
 * INSTANCE_TYPE_CORE_CUSTOM1 (a negative value)
 *     for all user tables in UTL_TABLE corresponding sequences are set to maximum
 *     value of ID from interval [INSTANCE_TYPE_CORE_CUSTOM2 - 1; INSTANCE_TYPE_CORE_CUSTOM1],
 *     and these sequences have negative(!) increment.
 * INSTANCE_TYPE_CORE_CUSTOM2 (a negative value)
 *     for all user tables in UTL_TABLE corresponding sequences are set to maximum
 *     value of ID from interval [-INSTANCE_TYPE_PRODUCTION + 1; INSTANCE_TYPE_CORE_CUSTOM2],
 *     and these sequences have negative(!) increment.
 */
procedure sync_sequences (
    i_instance_type       in     com_api_type_pkg.t_tiny_id    default INSTANCE_TYPE_PRODUCTION
  , i_soft                in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_debug_output        in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) is
    MIN_COM_LOV_ID               com_api_type_pkg.t_long_id := 1;
    l_id                         com_api_type_pkg.t_long_id;
    l_id_seq                     com_api_type_pkg.t_long_id;
    l_min_seq                    com_api_type_pkg.t_long_id;
    l_max_seq                    com_api_type_pkg.t_long_id;
    l_str                        com_api_type_pkg.t_text;
    l_count                      com_api_type_pkg.t_count   := 0;
    l_diff                       number;
    l_tmp_id                     com_api_type_pkg.t_long_id;
    l_is_negative_ids            com_api_type_pkg.t_boolean;

    procedure debug_text(
        i_text                in     com_api_type_pkg.t_text
    ) is
    begin
        if i_debug_output = com_api_const_pkg.TRUE then
            dbms_output.put_line(i_text);
        end if;
    end;

    procedure debug_param(
        i_param_name          in     com_api_type_pkg.t_text
      , i_param_value         in     com_api_type_pkg.t_text
      , i_indent              in     com_api_type_pkg.t_count    default 4
      , i_align_size          in     com_api_type_pkg.t_count    default 30
    ) is
    begin
        debug_text(
            i_text => lpad(' ', i_indent, ' ')
                   || rpad(i_param_name, i_align_size, ' ')
                   || '= '
                   || i_param_value
        );
    end;

begin
    --trc_config_pkg.init_cache;
    dbms_output.enable(buffer_size => NULL);
    debug_text('i_instance_type = ' || i_instance_type || CRLF || CRLF);

    if i_instance_type not in (INSTANCE_TYPE_CORE
                             , INSTANCE_TYPE_CUSTOM1
                             , INSTANCE_TYPE_CUSTOM2
                             , INSTANCE_TYPE_PRODUCTION
                             , INSTANCE_TYPE_CORE_CUSTOM1
                             , INSTANCE_TYPE_CORE_CUSTOM2)
    then
        com_api_error_pkg.raise_error(
            i_error      => 'INVALID_INSTANCE_TYPE_FOR_SYNC_SEQUENCES'
          , i_env_param1 => i_instance_type
        );
    end if;

    for r in (
        select x.table_name
             , x.sequence_name
             , x.min_value
             , x.max_value
             , x.max_length
             , x.cycle_flag
             , x.order_flag
             , x.cache_size
             , c.data_precision
             , x.user_table
             , x.is_config_table
          from (
              select case s.sequence_name
                         when 'COM_PARAMETER_SEQ'
                         then 'COM_PARAMETER_ID_VW'
                         else substr(s.sequence_name, 1, instr(s.sequence_name, '_SEQ') - 1)
                     end                                                                            as table_name
                   , s.sequence_name
                   , s.min_value                                                                    as min_value
                   , s.max_value                                                                    as max_value
                   , length(abs(s.max_value))                                                       as max_length
                   , decode(s.cycle_flag, 'N',    'NOCYCLE', 'CYCLE')                               as cycle_flag
                   , decode(s.order_flag, 'N',    'NOORDER', 'ORDER')                               as order_flag
                   , decode(s.cache_size,   0,    'NOCACHE', 'CACHE ' || s.cache_size)              as cache_size
                   , case when t.table_name is null then 0 else 1 end                               as user_table
                   , t.is_config_table
                from (select u.table_name
                           , u.is_config_table
                        from utl_table u
                       where is_split_seq = 1
                       union all
                      select 'COM_PARAMETER' as table_name
                           , 1
                        from dual
                     ) t
                   , user_sequences s
               where s.sequence_name = t.table_name(+) || '_SEQ'
               ) x
             , user_tab_columns c
         where c.table_name  = x.table_name
           and c.column_name = 'ID'
      order by decode(x.sequence_name, 'TRC_LOG_SEQ', 1, 2)
             , x.sequence_name
    ) loop
        begin
            debug_text(r.table_name || ' / ' || r.sequence_name);
            debug_param('min_value',       r.min_value);
            debug_param('max_value',       r.max_value);
            debug_param('max_length',      r.max_length);
            debug_param('cycle_flag',      r.cycle_flag);
            debug_param('order_flag',      r.order_flag);
            debug_param('cache_size',      r.cache_size);
            debug_param('data_precision',  r.data_precision);
            debug_param('user_table',      r.user_table);
            debug_param('is_config_table', r.is_config_table);

            l_is_negative_ids := case
                                     when r.user_table      = com_api_const_pkg.TRUE
                                      and r.is_config_table = com_api_const_pkg.TRUE
                                      and i_instance_type in (INSTANCE_TYPE_CORE_CUSTOM1
                                                            , INSTANCE_TYPE_CORE_CUSTOM2)
                                     then com_api_const_pkg.TRUE
                                     else com_api_const_pkg.FALSE
                                 end;
            debug_param('l_is_negative_ids [bool]', l_is_negative_ids);

            if i_instance_type = INSTANCE_TYPE_CORE then
                -- For some Core tables it is necessary to find not a last used value
                -- but the beginning of a "window" of unused IDs
                if upper(r.table_name) = 'COM_LOV' then
                    select min(id) keep(dense_rank first order by cnt desc nulls last) + 1
                      into l_id
                      from (
                          select a.id
                               , lead(a.id) over(order by id)           as next_id
                               , lead(a.id) over(order by id) - a.id    as cnt
                            from com_lov a
                           where id >= 0
                      );
                elsif upper(r.table_name) = 'COM_I18N' then
                    select min(id) keep(dense_rank first order by cnt desc nulls last) + 1
                      into l_id
                      from (
                          select a.id
                               , lead(a.id) over(order by id)           as next_id
                               , lead(a.id) over(order by id) - a.id    as cnt
                            from com_i18n a
                           where id >= 100000000000
                        order by cnt desc nulls last
                      );
                elsif upper(r.table_name) = 'COM_LABEL' then
                    select min(id) keep(dense_rank first order by cnt desc nulls last) + 1
                      into l_id
                      from (
                          select a.id
                               , lead(a.id) over(order by id)           as next_id
                               , lead(a.id) over(order by id) - a.id    as cnt
                            from com_label a
                           where id >= 0
                        order by cnt desc nulls last
                      );
                else
                    if r.max_length < nvl(r.data_precision, 0) then
                        -- This sequence is composite with date such as ddmmyy0010000001 and must be skipped
                        l_id := null;
                    else
                        if r.user_table = 0 then
                            l_str := 'select nvl(max(id)+1, 0) from ' || r.table_name
                                  || ' where id <= ' || r.max_value || '-10';
                        else
                            l_str := 'select nvl(max(id)+1, 0) from ' || r.table_name
                                  || ' where id < ' || rpad(INSTANCE_TYPE_CUSTOM1, r.max_length, '0');

                            if r.sequence_name != 'TRC_LOG_SEQ' then
                                select count(1)
                                  into l_count
                                  from user_objects a
                                 where a.object_name = r.table_name
                                   and a.object_type in ('TABLE', 'VIEW', 'MATERIALIZED VIEW');
                                if l_count = 0 then
                                    continue;
                                end if;
                            end if;
                        end if;

                        debug_text('[getting next ID after last used ID in table]: ' || l_str);
                        execute immediate l_str into l_id;
                    end if;
                end if;

            else -- Custom or production (i_instance_type != INSTANCE_TYPE_CORE)
                if r.max_length < nvl(r.data_precision, 0) then
                    -- This sequence is composite with date such as ddmmyy0010000001 and must be skipped
                    null;
                else
                    if r.user_table = com_api_const_pkg.FALSE then
                        l_str := ' where id <= ' || r.max_value || '-10';
                    else
                        l_str := case
                                     when i_instance_type = INSTANCE_TYPE_PRODUCTION then
                                         ' where id <= ' || r.max_value || '-10'
                                     -- Negative increment, negative IDs
                                     when l_is_negative_ids = com_api_const_pkg.TRUE then
                                         ' where id between '
                                         || rpad(INSTANCE_TYPE_CORE_CUSTOM2, r.max_length + 1, '9')
                                         || ' and '
                                         || rpad(INSTANCE_TYPE_CORE_CUSTOM1, r.max_length + 1, '0')
                                     -- INSTANCE_TYPE_(CORE_)CUSTOM1/2 with l_is_negative_ids = false
                                     else
                                         ' where id between '
                                         || rpad(INSTANCE_TYPE_CUSTOM1, r.max_length, '0')
                                         || ' and '
                                         || rpad(INSTANCE_TYPE_CUSTOM2, r.max_length, '9')
                                     --
                                 end;

                        -- Skip sequence if it is not used
                        if r.sequence_name != 'TRC_LOG_SEQ' then
                            select count(1)
                              into l_count
                              from user_objects a
                             where a.object_name = r.table_name
                               and a.object_type in ('TABLE', 'VIEW', 'MATERIALIZED VIEW');
                            if l_count = 0 then
                                continue;
                            end if;
                        end if;
                    end if;

                    l_str := 'select nvl('
                          || case
                                 when l_is_negative_ids = com_api_const_pkg.TRUE
                                 then 'min(id)-1' -- negative values
                                 else 'max(id)+1'
                             end
                          || ', 0) from '
                          || r.table_name
                          || l_str; -- where

                    debug_text('[getting next ID after last used ID in table]: ' || l_str);
                    execute immediate l_str into l_id;
                end if;
            end if;

            debug_param('l_id', l_id);

            if  -- This sequence is composite with date such as ddmmyy0010000001 and must be skipped
                r.max_length < nvl(r.data_precision, 0)
                or
                -- Do not need to update a sequence because table is empty
                r.user_table = com_api_const_pkg.FALSE and l_id = 0
            then
                debug_text('SKIPPED: no action is necessary');
            else
                case
                when r.table_name is null or r.user_table = com_api_const_pkg.FALSE then
                    l_min_seq := INSTANCE_TYPE_CORE;
                    l_max_seq := rpad('9', r.max_length, '9');
                    l_id_seq  := l_id;

                -- For COM_LOV id may be < 1000
                when upper(r.table_name) = 'COM_LOV'
                 and i_instance_type = INSTANCE_TYPE_CORE
                then
                    l_min_seq := MIN_COM_LOV_ID;
                    l_max_seq := rpad(INSTANCE_TYPE_CUSTOM1 - 1, r.max_length, '9'); -- 4999
                    l_id_seq  := l_id;

                -- Negative IDs, negative increment
                when l_is_negative_ids = com_api_const_pkg.TRUE then
                    l_min_seq := to_number(rpad(INSTANCE_TYPE_CORE_CUSTOM2, r.max_length + 1, '9')); -- -6999
                    l_max_seq := to_number(rpad(i_instance_type,            r.max_length + 1, '0')); -- -5001
                    l_id_seq  := least(l_id, l_max_seq - 1);

                -- INSTANCE_TYPE_CORE / INSTANCE_TYPE_CUSTOM1/2 / INSTANCE_TYPE_PRODUCTION
                -- or INSTANCE_TYPE_CORE_CUSTOM1/2 for not user/configurable table
                else
                    l_min_seq := to_number(rpad(
                                               case i_instance_type
                                                   when INSTANCE_TYPE_CORE_CUSTOM1 then INSTANCE_TYPE_CUSTOM1
                                                   when INSTANCE_TYPE_CORE_CUSTOM2 then INSTANCE_TYPE_CUSTOM2
                                                                                   else i_instance_type
                                               end
                                             , r.max_length
                                             , '0'
                                           ));
                    l_max_seq := to_number(rpad(
                                               case i_instance_type
                                                   when INSTANCE_TYPE_CORE       then INSTANCE_TYPE_CUSTOM1 - 1
                                                   when INSTANCE_TYPE_PRODUCTION then '9'
                                                                                 else INSTANCE_TYPE_CUSTOM2
                                               end
                                             , r.max_length
                                             , '9'
                                           ));
                    l_id_seq  := greatest(l_id, l_min_seq + 1);
                end case;

                debug_text('[new next value for the sequence]: l_id_seq = ' || l_id_seq);
                debug_text('[sequence minvalue/maxvalue]: l_min_seq = ' || l_min_seq || ' / l_max_seq = ' || l_max_seq);

                -- Check if l_id is already used
                l_str := 'select count(*) from ' || r.table_name || ' where id = ' || l_id_seq;
                execute immediate l_str into l_count;
                if l_count > 0 then
                    dbms_output.put_line('The range is full. Table ' || r.table_name || ' MAX id = ' || l_id_seq);
                end if;

                l_str := 'select ' || r.sequence_name || '.nextval from dual';
                execute immediate l_str into l_tmp_id;

                debug_param('l_tmp_id', l_tmp_id);

                l_diff := l_id_seq - l_tmp_id
                        + case when l_is_negative_ids = com_api_const_pkg.TRUE then 1 else -1 end;

                debug_param('l_diff', l_diff);

                if l_diff != 0 then
                    -- Use altering a sequence instead of its recreating to avoid objects' invalidation
                    l_str := 'alter sequence ' || r.sequence_name || ' increment by '|| l_diff
                          || ' minvalue -' || rpad('9', r.max_length, '9')
                          || ' maxvalue '  || rpad('9', r.max_length, '9');

                    if r.cache_size != 'NOCACHE' then
                        l_str := l_str || ' nocache';
                    end if;

                    debug_text('[altering the sequence for a SHIFT]: ' || l_str);
                    execute immediate l_str;

                    l_str := 'select ' || r.sequence_name || '.nextval from dual';
                    execute immediate l_str into l_tmp_id;
                    debug_param('l_tmp_id', l_tmp_id);
                end if;

                if  l_diff != 0
                    or
                    l_min_seq != nvl(r.min_value, 0) or l_max_seq != nvl(r.max_value, 0)
                then
                    l_str := 'alter sequence ' || r.sequence_name
                          || ' increment by '
                          || case when l_is_negative_ids = com_api_const_pkg.TRUE then '-1' else '1' end
                          || ' minvalue ' || l_min_seq
                          || ' maxvalue ' || l_max_seq
                          || ' ' || lower(r.cache_size);
                    debug_text('[altering the sequence AFTER shifting]: ' || l_str);
                    execute immediate l_str;
                end if;
            end if;

            debug_text(CRLF);
        exception
            when others then
                dbms_output.put_line(r.table_name || ' / ' || r.sequence_name);
                dbms_output.put_line(l_str);
                dbms_output.put_line('FAILED: ' || sqlerrm);
                dbms_output.put_line('l_min_seq = ' || l_min_seq || 'l_max_seq = ' || l_min_seq
                                     || ', l_diff = ' || l_diff
                                     || ', l_id_seq = ' || l_id_seq || ', l_id = ' || l_id);
                raise;
        end;
    end loop;
end sync_sequences;


procedure check_parameter_doubles is
    l_message   com_api_type_pkg.t_text := null;
begin
    for rec in (
        select id
             , stragg(table_name) tables
             , count(1) cnt
          from com_parameter_id_vw
         group by id
        having count(*)>1
    ) loop
        l_message := 'Double of parameter IDs found: id= '||rec.id||', tables= '||rec.tables;
        trc_log_pkg.error(l_message);
    end loop;
    if l_message is not null then
        com_api_error_pkg.raise_error(l_message);
    end if;
end;


procedure sync_superuser(
    i_is_active           in    com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) is
    o_id  number;
begin
    for r1 in (select a.id from acm_role a where a.name = 'GOD') loop
        for r2 in (
            select b.id
              from acm_privilege b
             where is_active = com_api_const_pkg.TRUE
                or i_is_active = com_api_const_pkg.FALSE
             minus
            select d.priv_id
              from acm_role_privilege d
             where d.role_id = r1.id
        ) loop
            acm_ui_privilege_pkg.add_privilege_role(
                o_id       => o_id
              , i_role_id  => r1.id
              , i_priv_id  => r2.id
              , i_limit_id => null
            );
        end loop;
    end loop;

    commit;

end sync_superuser;


procedure generate_static_packages is
begin
    rul_mod_gen_pkg.generate_package;

    rul_api_regen_pkg.gen_static_pkg;
end;


procedure after_deploy (
    i_instance_type       in    com_api_type_pkg.t_tiny_id default INSTANCE_TYPE_PRODUCTION
) is
    l_str com_api_type_pkg.t_full_desc;
begin
    -- recompile stragg function
    begin
        select stragg(dict||code) into l_str
          from (select dict, code from com_dictionary where rownum <= 3);
    exception
        when others then null;
    end;

  --  move_tablespaces;

    create_audit_triggers;

    refresh_mviews;

    check_parameter_doubles;

    generate_com_split_map;

  --  sync_sequences(i_instance_type);

    generate_static_packages;
end;


-- recompile invalid packages after sequences re-creation
procedure recompile_invalid_packages
is
    l_sql com_api_type_pkg.t_text;
begin
    for i in
        (select
            a.object_name
            , a.used_by_cnt
         from
             (select u.object_name
                     , (select count(ud.name) -- comile the most used packages first
                          from user_dependencies ud
                         where ud.referenced_name = u.object_name and ud.dependency_type = 'HARD' and type = 'PACKAGE') as used_by_cnt
                from user_objects u
               where lower(u.status) != 'valid'
                 and lower(u.object_name) != 'utl_deploy_pkg' -- exclude yourself
                 and lower(u.object_type) in ('package', 'package body')) a
         order by a.used_by_cnt desc -- comile the most used packages first
                , a.object_name)
    loop
        begin
            l_sql := 'alter package ' || i.object_name ||' compile package';
            trc_log_pkg.debug(i_text => 'execute immediate ' || l_sql);

            execute immediate l_sql;
        exception
            when others then
                trc_log_pkg.error(
                    i_text      => 'UNHANDLED_EXCEPTION'
                  , i_env_param1 => dbms_utility.format_error_backtrace||dbms_utility.format_error_stack--SQLERRM
                );
        end;
    end loop;
end recompile_invalid_packages;


procedure enum_pan_tables(
    o_table_name_tab     out com_api_type_pkg.t_oracle_name_tab
  , o_column_name_tab    out com_api_type_pkg.t_oracle_name_tab
) is
begin
    open g_cur_pan_tables;
    fetch g_cur_pan_tables bulk collect into o_table_name_tab, o_column_name_tab;
    close g_cur_pan_tables;
exception
    when others then
        if g_cur_pan_tables%isopen then
            close g_cur_pan_tables;
        end if;
        raise;
end enum_pan_tables;


procedure convert_card_numbers(
    i_encoding        in     com_api_type_pkg.t_boolean
) is
    LOG_PREFIX               com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.convert_card_numbers: ';
    l_table_name_tab         com_api_type_pkg.t_oracle_name_tab;
    l_column_name_tab        com_api_type_pkg.t_oracle_name_tab;
    l_count                  com_api_type_pkg.t_count := 0;
    l_error_index            pls_integer;
    l_direction              com_api_type_pkg.t_name;
begin
    l_direction := case when i_encoding = com_api_const_pkg.TRUE then 'encoding'
                                                                else 'decoding'
                   end;
    trc_log_pkg.debug(LOG_PREFIX || ' i_encoding [' || i_encoding || '], l_direction [' || l_direction || ']');

    iss_api_token_pkg.initialization();

    enum_pan_tables(
        o_table_name_tab  => l_table_name_tab
      , o_column_name_tab => l_column_name_tab
    );

    if iss_api_token_pkg.is_token_enabled = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_error(
            i_error      => 'IMPOSSIBLE_CONVERT_PANS_WITH_DISABLED_TOKENIZATION'
          , i_env_param1 => l_direction
        );
    end if;

    for i in l_table_name_tab.first .. l_table_name_tab.last loop
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || '#1 table [#2], column [#3] (#4 of #5)'
          , i_env_param1 => l_direction
          , i_env_param2 => l_table_name_tab(i)
          , i_env_param3 => l_column_name_tab(i)
          , i_env_param4 => i
          , i_env_param5 => l_table_name_tab.count()
        );

        -- Process only non-empty tables
        l_error_index := i;
        execute immediate
            'select count(*) from ' || l_table_name_tab(i) ||
            ' where ' || l_column_name_tab(i) || ' is not null'
        into l_count;

        if l_count > 0 then
            -- Check if all PANs are encoded (if we are decoding DB) or decoded (if we are encoding DB)
            execute immediate
                'select count(*) from ' || l_table_name_tab(i) ||
                ' where '
                    || case when i_encoding = com_api_const_pkg.TRUE then 'not ' else null end
                    || 'regexp_like(' || l_column_name_tab(i) || ', ''^[0-9]*$'')'
            into l_count;

            if l_count > 0 then
                com_api_error_pkg.raise_error(
                    i_error      => 'CANNOT_CONVERT_PAN_DATA'
                  , i_env_param1 => l_table_name_tab(i)
                  , i_env_param2 => l_column_name_tab(i)
                  , i_env_param3 => l_count
                  , i_env_param4 => l_direction
                );
            end if;

            execute immediate
                'update ' || l_table_name_tab(i) ||
                  ' set ' || l_column_name_tab(i) || ' = iss_api_token_pkg.'
                          || case when i_encoding = com_api_const_pkg.TRUE then 'encode' else 'decode' end
                          || '_card_number(i_card_number => ' || l_column_name_tab(i) || ')' ||
                ' where ' || l_column_name_tab(i) || ' is not null';

            trc_log_pkg.debug(LOG_PREFIX || 'updated ' || sql%rowcount || ' records');
        end if;
    end loop;

    -- Special processing is required for tables APP_DATA
    trc_log_pkg.debug(LOG_PREFIX || 'processing table APP_DATA...');

    update app_data d
       set d.element_value = case when i_encoding = com_api_const_pkg.TRUE
                                  then iss_api_token_pkg.encode_card_number(i_card_number => d.element_value)
                                  else iss_api_token_pkg.decode_card_number(i_card_number => d.element_value)
                             end
     where d.element_id in (select e.id from app_element e where upper(e.name) like '%CARD_NUMBER');

    trc_log_pkg.debug(LOG_PREFIX || 'updated ' || sql%rowcount || ' records');

    -- Also it is necessary to clean table SYS.DBMS_BLOCK_ALLOCATED (user block via functionality of package DBMS_BLOCK).
    -- There is the problem with privileges on update/delete SYS table.
--    begin
--        --delete from sys.dbms_lock_allocated
--        -- where regexp_like(name, '^ENTTCARD[0-9]{6}(.){8}[0-9]{4}$');
--        update sys.dbms_lock_allocated
--           set name = 'ENTTCARD'
--         where regexp_like(name, '^ENTTCARD[0-9]{6}(.){8}[0-9]{4}$');
--
--        trc_log_pkg.debug(LOG_PREFIX || sql%rowcount || ' records were deleted from SYS.DBMS_LOCK_ALLOCATED');
--
--    exception
--        when others then
--            trc_log_pkg.warn(LOG_PREFIX || 'FAILED cleaning SYS.DBMS_LOCK_ALLOCATED');
--    end;

    trc_log_pkg.debug(LOG_PREFIX || 'END');
exception
    when com_api_error_pkg.e_application_error then
        rollback;
        raise;
    when others then
        rollback;
        com_api_error_pkg.raise_error(
            i_error      => 'CONVERTING_PAN_DATA_FAILED'
          , i_env_param1 => l_table_name_tab(l_error_index)
          , i_env_param2 => l_column_name_tab(l_error_index)
          , i_env_param3 => l_direction
        );
        raise;
end convert_card_numbers;


-- Convert DB for usage encoded PANs (enable tokenization)
procedure encode_card_numbers
is
begin
    convert_card_numbers(i_encoding => com_api_const_pkg.TRUE);
end encode_card_numbers;


-- Convert DB for usage real PANs (disable tokenization)
procedure decode_card_numbers
is
begin
    convert_card_numbers(i_encoding => com_api_const_pkg.FALSE);
    -- After decoding all PANs it is usefull to disable tokenization
    set_ui_value_pkg.set_system_param_n('ENABLE_TOKENIZATION', com_api_const_pkg.FALSE);
    -- Re-initialization is required to disable tokenization for a current session
    iss_api_token_pkg.initialization();
end decode_card_numbers;


procedure generate_com_split_map is
    l_split_degree    com_api_type_pkg.t_tiny_id;
    l_parallel_degree com_api_type_pkg.t_tiny_id;
begin
    l_split_degree    := set_ui_value_pkg.get_user_param_n(i_param_name => 'SPLIT_DEGREE');
    l_parallel_degree := set_ui_value_pkg.get_user_param_n(i_param_name => 'PARALLEL_DEGREE');

    execute immediate 'truncate table com_split_map';

    if l_split_degree > 0 then

        insert /*+ append */ into com_split_map (
                   thread_number
                 , split_hash
            )
            select mod(rn, l_parallel_degree)+1
                 , rn
              from (select rownum as rn from user_objects)
             where rn <= l_split_degree;

    else
        insert /*+ append */ into com_split_map (
                thread_number
              , split_hash
            )
            values (
                prc_api_const_pkg.DEFAULT_THREAD
              , com_api_const_pkg.DEFAULT_SPLIT_HASH
            );

    end if;

    commit;

end generate_com_split_map;


/*
 * Procedure checks if there are records in table COM_I18N for table records that don't exist,
 * it based on anonymous block (file com_i18.chck.sql).
 * This version outputs full message with no restrictions via dbms_output/trc_log functionality
 * (instead of first 10 records via raise_application_error in com_i18.chck.sql)
 * @i_remove - if value is true then there is a need to delete garbage records from com_i18n
*/
procedure com_i18_chck(
    i_remove              in     com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) is
    l_count                      com_api_type_pkg.t_count := 0;
    l_found_per_table            com_api_type_pkg.t_count := 0;
    l_found_total                com_api_type_pkg.t_count := 0;
    l_id_list                    com_api_type_pkg.t_lob_data;
    l_is_found                   boolean                  := false;
begin
    -- If errors are detected they will be logged in a separate session with custom constant ID
    set_temporary_session(
        i_session_id => SESSION_ID_CHECKS
    );

    for rec in (
        select id
             , table_name
             , lead(table_name) over (order by table_name, object_id) as next_table_name
             , object_id
             , text
          from com_i18n
      order by table_name
             , object_id
    ) loop
        begin
            execute immediate 'select count(1) from ' || rec.table_name ||
                              ' where id = ' || to_char(rec.object_id)
            into l_count;

            if rec.table_name = 'APP_ELEMENT' and l_count = 0 then
                execute immediate 'select count(1) from com_flexible_field' ||
                                  ' where id = ' || to_char(rec.object_id)
                into l_count;
            end if;

            if l_count = 0 then
                l_found_per_table := l_found_per_table + 1;
                if nvl(lengthb(l_id_list), 0) < LOG_STR_MAX_LENGTH then
                    l_id_list := l_id_list
                              || to_char(rec.id, 'TM9') || ' ('||rec.table_name||'.'||to_char(rec.object_id)
                              || '-' || rec.text || ')' || chr(10);
                end if;
                if i_remove = com_api_const_pkg.TRUE then
                    delete from com_i18n where id = rec.id;
                end if;
            end if;
        exception
            when others then
                -- Table not found
                l_found_per_table := l_found_per_table + 1;
                if nvl(lengthb(l_id_list), 0) < LOG_STR_MAX_LENGTH then
                    l_id_list := l_id_list || to_char(rec.id, 'TM9') || ', ';
                end if;
        end;

        -- Log procedure entry point only if some problem records were found
        if not l_is_found and l_found_per_table >= 1 then
            debug(
                i_text       => lower($$PLSQL_UNIT) || '.com_i18_chck(i_remove => #1):' || chr(10)
              , i_env_param1 => case i_remove
                                    when com_api_const_pkg.FALSE then 'false'
                                    when com_api_const_pkg.TRUE  then 'true'
                                end
            );
            l_is_found := true;
        end if;

        -- Log problem IDs of current table in one debug record
        if  l_found_per_table > 0
            and
            (nvl(rec.next_table_name, '~') != rec.table_name or lengthb(l_id_list) >= LOG_STR_CRITICAL_LENGTH)
        then
            debug(
                i_text => to_char(l_found_per_table, 'TM9') || ' unused record(s) found in COM_I18N for table '
                       || rec.table_name || ':' || chr(10) || l_id_list || chr(10)
            );
            l_found_total     := l_found_total + l_found_per_table;
            l_found_per_table := 0;
            l_id_list         := null;
        end if;
    end loop;

    if l_found_total > 0 then
        if i_remove = com_api_const_pkg.TRUE then
            commit;
        end if;
        debug(to_char(l_found_total, 'TM9') || ' unused record(s) found in COM_I18N total' || chr(10));
    end if;

    unset_temporary_session();
end com_i18_chck;


/*
 * Procedure based on anonymous block (file adt_entity.chck.sql)
 * This version outputs full message with no restrictions via dbms_output functionality
 * (instead of raising error via raise_application_error in adt_entity.chck.sql)
*/
procedure adt_entity_chck
is
    LOG_PREFIX    constant com_api_type_pkg.t_name :=
        lower($$PLSQL_UNIT) || '.adt_entity_chck: ADT_ENTITY contains non-existent tables: ';
    l_table_list           com_api_type_pkg.t_text;
begin
    -- If errors are detected they will be logged in a separate session with custom constant ID
    set_temporary_session(
        i_session_id => SESSION_ID_CHECKS
    );

    for rec in (
        select * from adt_entity t
         where not exists (select 1 from user_tables x where x.table_name = t.table_name)
    ) loop
        l_table_list := l_table_list || ', ' || rec.table_name;

        if lengthb(l_table_list) >= LOG_STR_CRITICAL_LENGTH then
            debug(LOG_PREFIX || substr(l_table_list, 3));
            l_table_list := null;
        end if;
    end loop;

    if l_table_list is not null then
        debug(LOG_PREFIX || substr(l_table_list, 3));
    end if;

    unset_temporary_session();
end adt_entity_chck;


/*
 * Procedure based on anonymous block (file cmn_parameter_value.chck.sql)
 * This version outputs full message with no restrictions via dbms_output functionality
 * (instead of raising error via raise_application_error in cmn_parameter_value.chck.sql)
*/
procedure cmn_parameter_value_chck
is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.cmn_parameter_value_chck: ';
    l_count                com_api_type_pkg.t_count := 0;
    l_found_cnt            com_api_type_pkg.t_count := 0;
    l_str                  com_api_type_pkg.t_text;
    l_query                com_api_type_pkg.t_text;
begin
    -- If errors are detected they will be logged in a separate session with custom constant ID
    set_temporary_session(
        i_session_id => SESSION_ID_CHECKS
    );

    for rec in (
        select v.id
             , v.entity_type
             , v.object_id
             , e.table_name
          from cmn_parameter_value v
             , adt_entity e
         where v.entity_type = e.entity_type
      order by e.table_name
    ) loop
        l_query := 'select count(1) from ' || rec.table_name || ' where id = ' || rec.object_id;
        execute immediate  l_query into l_count;

        if l_count = 0 then
            if l_found_cnt <= 20 then
                l_str := ', ' || l_str || to_char(rec.id, 'TM9');
            end if;
            l_found_cnt := l_found_cnt + 1;
        end if;
    end loop;

    if l_found_cnt > 0 then
        debug(LOG_PREFIX || 'garbage records found in CMN_PARAMETER_VALUE; ID = ' || substr(l_str, 3) || chr(10));
    end if;

    unset_temporary_session();
end cmn_parameter_value_chck;


/*
 * Procedure based on anonymous block (file utl_table.chck.sql)
 * This version outputs full message with no restrictions via dbms_output functionality
 * (instead of raising error via raise_application_error in utl_table.chck.sql)
*/
procedure utl_table_chck
is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.utl_table_chck: ';
begin
    -- If errors are detected they will be logged in a separate session with custom constant ID
    set_temporary_session(
        i_session_id => SESSION_ID_CHECKS
    );

    com_api_const_pkg.set_separator(', ');

    for rec in (
        select stragg(table_name) s
          from utl_table t
         where not exists (select 1 from user_tables x where x.table_name = t.table_name)
           and rownum <= 10
    ) loop
        if nvl(length(rec.s), 0) > 0 then
            debug(LOG_PREFIX || 'tables from UTL_TABLE do not exist: ' || substr(rec.s, 1, LOG_STR_MAX_LENGTH));
        end if;
    end loop;

    for rec in (
        select stragg(table_name) s
          from user_tables
         where table_name not in (select table_name from utl_table)
           and table_name not in (select object_name from user_objects where object_type = 'MATERIALIZED VIEW')
           and table_name not like '%_RDF' and temporary = 'N'
      order by 1
    ) loop
        if nvl(length(rec.s), 0) > 0 then
            debug(LOG_PREFIX || 'tables from USER_TABLES do not exist in UTL_TABLE: ' || substr(rec.s, 1, LOG_STR_MAX_LENGTH));
        end if;
    end loop;

    unset_temporary_session();
end utl_table_chck;


/*
 * Procedure based on anonymous block (file app_dependence.chck.sql)
 * This version outputs full message with no restrictions via dbms_output functionality
 * (instead of raising error via raise_application_error in app_dependence.chck.sql)
*/
procedure app_dependence_chck
is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.app_dependence_chck: ';
begin
    -- If errors are detected they will be logged in a separate session with custom constant ID
    set_temporary_session(
        i_session_id => SESSION_ID_CHECKS
    );

    for rec in (
        select id
             , struct_id
          from app_dependence d
         where not exists (select 1 from app_structure s where s.id = d.struct_id)
     union all
        select id
             , depend_struct_id
          from app_dependence d
         where not exists (select 1 from app_structure s where s.id = d.depend_struct_id)
    ) loop
        debug(
            i_text       => LOG_PREFIX || 'APP_DEPENDENCE.id [#1] is related to removed record APP_STRUCTURE.id [#2]'
          , i_env_param1 => rec.id
          , i_env_param2 => rec.struct_id
        );
    end loop;

    for rec in (
        select d.id
             , s1.appl_type t1
             , s2.appl_type t2
          from app_dependence d
             , app_structure s1
             , app_structure s2
         where d.struct_id        = s1.id
           and d.depend_struct_id = s2.id
           and s1.appl_type      != s2.appl_type
    ) loop
        debug(
            i_text       => LOG_PREFIX || 'APP_DEPENDENCE.id [#1] is related 2 records of '
                                       || 'APP_STRUCTURE.id [#2][#3] at the same time'
          , i_env_param1 => rec.id
          , i_env_param2 => rec.t1
          , i_env_param3 => rec.t2
        );
    end loop;

    unset_temporary_session();
end app_dependence_chck;


/*
 * Procedure based on anonymous block (file app_structure.chck.sql)
 * This version outputs full message with no restrictions via dbms_output functionality
 * (instead of raising error via raise_application_error in app_structure.chck.sql)
*/
procedure app_structure_chck
is
begin
    -- If errors are detected they will be logged in a separate session with custom constant ID
    set_temporary_session(
        i_session_id => SESSION_ID_CHECKS
    );

    for rec in (
        select stragg(to_char(id, 'TM9')) as s
             , min(cnt) as cnt
          from (
              select id
                   , row_number() over (order by appl_type, id) as rn
                   , count(*) over() as cnt
                from app_structure s
               where not exists (select 1 from app_element_all_vw e where s.element_id = e.id)
          )
         where rn <= 5
    ) loop
        if nvl(rec.cnt, 0) > 0 then
            debug(
                i_text       => lower($$PLSQL_UNIT) || '.app_structure_chck: '
                             || '#1 APP_STRUCTURE records are linked to non-existent element(s) with IDs: #2'
              , i_env_param1 => to_char(rec.cnt,'TM9')
              , i_env_param2 => rec.s
            );
        end if;
    end loop;

    unset_temporary_session();
end app_structure_chck;


/*
 * Procedure based on anonymous block (file rul_mod_scale_param.chck.sql)
 * This version outputs full message with no restrictions via dbms_output functionality
 * (instead of raising error via raise_application_error in rul_mod_scale_param.chck.sql)
*/
procedure rul_mod_scale_param_chck is
begin
    -- If errors are detected they will be logged in a separate session with custom constant ID
    set_temporary_session(
        i_session_id => SESSION_ID_CHECKS
    );

    for rec in (
        select scale_id
             , param_id
             , count(*) as cnt
          from rul_mod_scale_param
      group by scale_id
             , param_id
        having count(*) > 1
    ) loop
        debug(
            i_text       => lower($$PLSQL_UNIT) || '.rul_mod_scale_param_chck: '
                         || 'table RUL_MOD_SCALE_PARAM contains #1 same records for scale [#2] and parameter [#3]'
          , i_env_param1 => rec.cnt
          , i_env_param2 => rec.scale_id
          , i_env_param3 => rec.param_id
        );
    end loop;

    unset_temporary_session();
end rul_mod_scale_param_chck;


/*
 * Procedure based on anonymous block (file rul_proc_param.chck.sql)
 * This version outputs full message with no restrictions via dbms_output functionality
 * (instead of raising error via raise_application_error in rul_proc_param.chck.sql)
*/
procedure rul_proc_param_chck
is
    l_param_name           com_api_type_pkg.t_name;
begin
    -- If errors are detected they will be logged in a separate session with custom constant ID
    set_temporary_session(
        i_session_id => SESSION_ID_CHECKS
    );

    select min(param_name)
      into l_param_name
      from rul_proc_param p
     where not exists (select 1 from rul_mod_param m where m.id = p.param_id);

    if l_param_name is not null then
        debug(
            i_text       => lower($$PLSQL_UNIT) || '.rul_proc_param_chck: '
                         || 'parameter [#1] from RUL_PROC_PARAM table is not related to RUL_MOD_PARAM'
          , i_env_param1 => l_param_name
        );
    end if;

    unset_temporary_session();
end rul_proc_param_chck;


/*
 * Procedure based on anonymous block (file com_label.chck.sql)
 * This version outputs full message with no restrictions via dbms_output functionality
 * (instead of raising error via raise_application_error in com_label.chck.sql)
*/
procedure com_label_chck
is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.com_label_chck: ';
begin
    -- If errors are detected they will be logged in a separate session with custom constant ID
    set_temporary_session(
        i_session_id => SESSION_ID_CHECKS
    );

    com_api_const_pkg.set_separator(',' || chr(10));

    for rec in (
        with x as (
            select name
                 , line
                 , text
                 , nvl(
                       substr(text, instr(text, '''', 1, 1)+1, instr(text, '''', 1, 2) - instr(text, '''', 1, 1)-1)
                     , substr(text, instr(text, '''', 1, 2)+1, instr(text, '''', 1, 3) - instr(text, '''', 1, 2)-1)
                   ) as s
              from user_source
             where type like 'PACKAGE BODY'
               and lower(replace(text, ' ')) like '%i_error=>%''%'
               and text not like '%\%i_err%=>\%%' escape '\' -- prevent the check is being matched with itself
        )
        select stragg(s) s, min(cnt) cnt
          from (
              select b.s
                   , count(*)
                   , row_number() over (order by count(*) desc) rn
                   , count(*) over() cnt
                from x b
               where not exists (select 1 from com_label l where l.name = b.s and l.label_type in ('ERROR', 'FATAL'))
            group by b.s
          )
    )
    loop
        if nvl(length(trim(rec.s)), 0) > 0 then
            debug(
                i_text       => LOG_PREFIX || '#1 error labels are missed: #2'
              , i_env_param1 => rec.cnt
              , i_env_param2 => chr(10) || rec.s
            );
        end if;
    end loop;

    for rec in (
        select min(cnt) cnt
             , stragg(name) s
          from (
              select name
                   , count(id) over() cnt
                   , row_number() over (order by name) rn
                from com_label a
               where label_type in('ERROR', 'FATAL')
                 and not exists (select 1 from com_i18n b where b.table_name = 'COM_LABEL' and b.object_id = a.id)
          )
    )
    loop
        if nvl(length(trim(rec.s)), 0) >0 then
            debug(
                i_text       => LOG_PREFIX || '#1 missed COM_I18N texts for labels: #2'
              , i_env_param1 => rec.cnt
              , i_env_param2 => chr(10) || rec.s
            );
        end if;
    end loop;

    for rec in (
        select stragg(name) s
             , min(cnt) cnt
          from (
              select name
                   , count(name) over() cnt
                from (
                    select l.name
                      from com_label l
                     where label_type not in ('CAPTION', 'LABEL', 'INFO')
                    minus
                    select l.name
                      from com_label l
                         , user_source u
                     where text like '%'''||l.name||'''%' and label_type not in ('CAPTION', 'LABEL', 'INFO')
                       and u.type in ('PACKAGE BODY', 'PROCEDURE', 'FUNCTION', 'TRIGGER')
                       and (lower(text) like '%i_error%=>%''%' or  lower(text) like '%i_text%=>%''%')
                )
          )
    ) loop
        if nvl(length(trim(rec.s)), 0) > 0 then
            debug(
                i_text       => LOG_PREFIX || '#1 unused error labels are found: #2'
              , i_env_param1 => rec.cnt
              , i_env_param2 => chr(10) || rec.s
            );
        end if;
    end loop;

    unset_temporary_session();
end com_label_chck;


/*
 * Procedure based on anonymous block (com_lov.chck.sql)
 * This version outputs full message with no restrictions via dbms_output functionality
 * (instead of raising error via raise_application_error in com_lov.chck.sql)
*/
procedure com_lov_chck
is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.com_lov_chck: ';
    c                      sys_refcursor;
begin
    -- If errors are detected they will be logged in a separate session with custom constant ID
    set_temporary_session(
        i_session_id => SESSION_ID_CHECKS
    );

    for r in (
        select l.*
             , get_text('com_lov', 'name', l.id, com_api_const_pkg.DEFAULT_LANGUAGE) as lov_name
          from com_lov l
         where lov_query is not null
    ) loop
        begin
            open c for r.lov_query;
            close c;
        exception
            when others then
                close c;
                debug(
                    i_text => LOG_PREFIX || 'LOV [' || r.id || '][' || r.lov_name
                                         || '] execution error [' || sqlerrm || ']' || chr(10)
                                         || 'LOV query is [' || r.lov_query || ']'
                );
        end;
    end loop;

    unset_temporary_session();
end com_lov_chck;


/*
 * Procedure based on anonymous block (com_parameter_duplicates.chck.sql)
 * This version outputs full message with no restrictions via dbms_output functionality
 * (instead of raising error via raise_application_error in com_parameter_duplicates.chck.sql)
*/
procedure com_parameter_duplicates_chck
is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.com_parameter_duplicates_chck: ';
    l_count                com_api_type_pkg.t_count := 0;
    l_message              com_api_type_pkg.t_text;
begin
    -- If errors are detected they will be logged in a separate session with custom constant ID
    set_temporary_session(
        i_session_id => SESSION_ID_CHECKS
    );

    com_api_const_pkg.set_separator(', ');

    for rec in (
        select * from (
            select id
                 , stragg(upper(table_name)) as tables
                 , count(*)           as cnt
                 , count(*) over()    as total_cnt
              from com_parameter_id_vw
          group by id
            having count(*) > 1
        ) where rownum <= 6
    ) loop
        l_message := l_message || 'id = ' || rec.id || ', tables [' || rec.tables || '];' || chr(10);
        l_count   := rec.total_cnt;
    end loop;

    if l_message is not null then
        debug(
            i_text       => LOG_PREFIX || '#2 duplicated parameter IDs (COM_PARAMETER) are found:#1'
          , i_env_param1 => chr(10) || l_message
          , i_env_param2 => l_count
        );
    end if;

    l_message := null;

    for rec in (
        select * from (
            select name
                 , stragg(upper(table_name)) as tables
                 , count(*)           as cnt
                 , count(*) over()    as total_cnt
              from com_parameter_id_vw
             where name is not null
          group by name
            having count(*) > 1
        ) where rownum <= 6
    ) loop
        l_message := l_message || ' name [' || rec.name || '], tables [' || rec.tables || '];' || chr(10);
        l_count   := rec.total_cnt;
    end loop;

    if l_message is not null then
        debug(
            i_text       => LOG_PREFIX || '#2 duplicated parameter names (COM_PARAMETER) are found:#1'
          , i_env_param1 => chr(10) || l_message
          , i_env_param2 => l_count
        );
    end if;

    unset_temporary_session();
end com_parameter_duplicates_chck;


/*
 * Print the sections from privileges which does not exist.
 * This version outputs full message with no restrictions via dbms_output functionality
 * (instead of raising error via raise_application_error in com_lov.chck.sql)
 */
procedure acm_section_chck
is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.acm_section_chck: ';
begin
    -- If errors are detected they will be logged in a separate session with custom constant ID
    set_temporary_session(
        i_session_id => SESSION_ID_CHECKS
    );

    for rec in (
        select p.id
             , p.name
             , p.section_id
             , p.module_code
             , p.is_active
          from acm_privilege p
         where p.section_id is not null
           and not exists (select s.id
                             from acm_section s
                            where s.id = p.section_id)
    ) loop
        debug(
            i_text       => LOG_PREFIX || 'section with ID [#1] does not exist in privilege with [#2][#3]'
          , i_env_param1 => rec.section_id
          , i_env_param2 => rec.id
          , i_env_param3 => rec.name
        );
    end loop;

    unset_temporary_session();
end acm_section_chck;


/*
 * Print the deploying scripts with empty body.
 * This version outputs full message with no restrictions via dbms_output functionality
 * (instead of raising error via raise_application_error in com_lov.chck.sql)
 */
procedure script_body_chck
is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.script_body_chck: ';
begin
    -- If errors are detected they will be logged in a separate session with custom constant ID
    set_temporary_session(
        i_session_id => SESSION_ID_CHECKS
    );

    for rec in (
        select s.id
             , s.script_name
          from utl_script s
         where s.script_body is null
    ) loop
        debug(
            i_text       => LOG_PREFIX || 'deploying script with ID [#1][#2] is empty'
          , i_env_param1 => rec.id
          , i_env_param2 => rec.script_name
        );
    end loop;

    unset_temporary_session();
end script_body_chck;


/*
 * Procedure to run all deployment checks
 */
procedure run_all_checks is
begin
    com_i18_chck;
    adt_entity_chck;
    cmn_parameter_value_chck;
    utl_table_chck;
    app_dependence_chck;
    app_structure_chck;
    rul_mod_scale_param_chck;
    rul_proc_param_chck;
    com_label_chck;
    com_lov_chck;
    com_parameter_duplicates_chck;
    --acm_section_chck;
    script_body_chck;
end run_all_checks;

/*
 * Launch deploying scripts for 'before_run' level.
 */
procedure run_deploying_scripts(
    i_run_type         com_api_type_pkg.t_dict_value
  , i_applying_type    com_api_type_pkg.t_dict_value
) is
    l_start_date       date;
    l_finish_date      date;

    cursor l_deploying_script is
        select id
             , script_body
          from utl_script
         where run_type = i_run_type
           and applying_type in (i_applying_type, SCRIPT_APPL_TYPE_BUILD_PATCH)
           and (
                   nvl(is_processed, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE
                   or
                   nvl(multiple_launch, SCRIPT_MULT_LAUNCH_ONETIME) = SCRIPT_MULT_LAUNCH_UNLIMITED
               )
         order by id;
begin
    -- Save changes because we will use "rollback" instead of "rollback to savepoint"
    -- which do not work when UTL script contains the "DDL command" or "commit".
    commit;

    for r in l_deploying_script loop
        begin
            l_start_date  := com_api_sttl_day_pkg.get_sysdate;
            if r.script_body is not null then
                execute immediate r.script_body;
            else
                trc_log_pkg.debug(
                    i_text => 'Nullable script ' || r.id
                );
            end if;
            l_finish_date := com_api_sttl_day_pkg.get_sysdate;

            update utl_script
               set is_processed     = com_api_const_pkg.TRUE
                 , last_start_date  = l_start_date
                 , last_finish_date = l_finish_date
             where id = r.id;

            commit;

        exception when others then
            rollback;
            raise;
        end;
    end loop;
end;


/*
 * Launch deploying scripts for 'before_run' level.
 */
procedure before_run(
    i_applying_type       in     com_api_type_pkg.t_dict_value
) is
begin
    run_deploying_scripts(
        i_run_type      => SCRIPT_RUN_TYPE_BEFORE
      , i_applying_type => i_applying_type
    );
end;


/*
 * Launch deploying scripts for 'after_run' level.
 */
procedure after_run(
    i_applying_type       in     com_api_type_pkg.t_dict_value
) is
begin
    run_deploying_scripts(
        i_run_type      => SCRIPT_RUN_TYPE_AFTER
      , i_applying_type => i_applying_type
    );
    recompile_invalid_packages;
end;


begin
    disable_dbms_output();
end utl_deploy_pkg;
/
