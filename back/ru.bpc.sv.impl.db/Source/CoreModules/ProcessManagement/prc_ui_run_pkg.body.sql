create or replace package body prc_ui_run_pkg as
/**************************************************************
 * API for run process <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 19.11.2009 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision:: $LastChangedRevision$ <br />
 * Module: PRC_API_RUN_PKG <br />
 * @headcom
 **************************************************************/

g_session_file_id                   com_api_type_pkg.t_long_id      := null;
g_param_tab                         com_param_map_tpt;

procedure run_container (
    i_process_id            in      com_api_type_pkg.t_short_id
  , i_eff_date              in      date                            default null
  , i_parent_id             in      com_api_type_pkg.t_long_id      default null
  , o_session_id               out  com_api_type_pkg.t_long_id
) is
    l_count                 com_api_type_pkg.t_count := 0;
    l_inst_id               com_api_type_pkg.t_inst_id;
begin

    com_api_sttl_day_pkg.set_sysdate(nvl(i_eff_date, get_sysdate));

    select min(b.inst_id)
      into l_inst_id
      from prc_process b
     where b.id = i_process_id;

    prc_api_session_pkg.start_session(
        i_process_id        => i_process_id
      , i_parent_session_id => i_parent_id
      , io_session_id       => o_session_id
      , i_inst_id           => l_inst_id
    );

    if i_parent_id is null and get_user_id is not null then
        begin
            select 1
              into l_count
              from acm_cu_process_vw
             where process_id = i_process_id
               and rownum     = 1;
        exception
            when no_data_found then
                prc_api_session_pkg.stop_session(
                    i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
                );
                
                com_api_error_pkg.raise_error(
                    i_error         => 'NO_PERMISSION_TO_RUN_PROCESS'
                  , i_env_param1    => i_process_id
                  , i_env_param2    => com_ui_user_env_pkg.get_user_name
                );
        end;
    end if;

end run_container;

procedure run_process (
    i_session_id            in      com_api_type_pkg.t_long_id
  , i_thread_number         in      com_api_type_pkg.t_tiny_id
  , i_container_id          in      com_api_type_pkg.t_short_id
  , i_session_file_id       in      com_api_type_pkg.t_long_id      default null
  , i_param_tab             in      com_param_map_tpt
  , i_eff_date              in      date                            default null
  , i_oracle_trace_level    in      com_api_type_pkg.t_tiny_id      default null
  , i_trace_thread_number   in      com_api_type_pkg.t_tiny_id      default null
) is

    l_run_sql com_api_type_pkg.t_text :=
'begin
    :PROCEDURE :PARAM;
exception when others then
    rollback;
    raise;
end;';

    l_param             com_api_type_pkg.t_param_value;
    l_cursor_handle     integer;
    l_result            integer;
    l_session_id        com_api_type_pkg.t_long_id := i_session_id;
    l_param_value       com_api_type_pkg.t_param_value;
    l_param_tab         com_api_type_pkg.t_param_tab;
    l_dupl_param_list   com_api_type_pkg.t_text;
    l_dupl_count        com_api_type_pkg.t_tiny_id := 0;
    l_process_id        com_api_type_pkg.t_short_id;
begin

    com_api_sttl_day_pkg.set_sysdate(nvl(i_eff_date, get_sysdate));

    prc_api_session_pkg.start_session(
        io_session_id       => l_session_id
      , i_thread_number     => i_thread_number
      , i_container_id      => i_container_id
    );

    trc_ora_trace_pkg.check_tracing_on_start(
        i_oracle_trace_level    => i_oracle_trace_level
      , i_thread_number         => i_thread_number
      , i_trace_thread_number   => i_trace_thread_number
    );

    if trc_config_pkg.is_debug = com_api_type_pkg.TRUE then
        trc_log_pkg.debug(
            i_text         => 'run_process: i_eff_date [#1], Release version [#2]'
          , i_env_param1   => to_char(get_sysdate, 'dd.mm.yyyy hh24:mi:ss')
          , i_env_param2   => com_ui_version_pkg.get_last_version
        );
    end if;

    l_process_id  := prc_api_session_pkg.get_process_id;

    -- check procedure type
    if prc_api_session_pkg.get_process_type = com_api_type_pkg.TRUE then
        com_api_error_pkg.raise_error(
            i_error         => 'PROCESS_IS_EXTERNAL'
          , i_env_param1    => l_process_id
        );
    end if;

    -- check if in progress
    prc_api_session_pkg.check_process_in_progress(
        i_process_id => l_process_id
      , i_session_id => l_session_id
    );

    prc_api_session_pkg.set_client_info(
        i_session_id        => l_session_id
      , i_thread_number     => i_thread_number
      , i_container_id      => i_container_id
      , i_process_id        => l_process_id
    );

    -- prepare sql script
    l_run_sql := 
        replace(
            srcstr  => l_run_sql
          , oldsub  => ':PROCEDURE'
          , newsub  => prc_api_session_pkg.get_procedure_name
        );

    trc_log_pkg.debug(
        i_text         => 'session_id [#1], process_id [#2], thread_number [#3]'
      , i_env_param1   => l_session_id
      , i_env_param2   => l_process_id
      , i_env_param3   => i_thread_number
    );

    utl_data_pkg.print_table(i_param_tab => i_param_tab);  -- dumping collection, DEBUG logging level is required

    g_param_tab := i_param_tab;

    -- prepare and bind parameters
    for r in (
        select b.param_name
             , b.data_type
             , a.param_value
             , b.id
             , c.is_format
             , nvl(d.char_value,                                             c.default_value) char_value
             , nvl(to_char(d.number_value, com_api_const_pkg.NUMBER_FORMAT), c.default_value) number_value
             , nvl(to_char(d.date_value,   com_api_const_pkg.DATE_FORMAT),   c.default_value) date_value
          from (select param_id
                     , param_value
                  from prc_parameter_value a
                 where container_id = i_container_id) a
             , prc_parameter b
             , prc_process_parameter c
             , table(cast(i_param_tab as com_param_map_tpt)) d
         where c.process_id  = l_process_id
           and c.param_id    = b.id
           and a.param_id(+) = c.param_id
           and d.name(+)     = b.param_name
    ) loop
        if l_param_tab.exists(r.param_name) then
            if l_dupl_param_list is null then
                l_dupl_param_list := r.param_name;
            else
                l_dupl_param_list := l_dupl_param_list || ', ' || r.param_name;
            end if;
            l_dupl_count := l_dupl_count + 1 ;
        else
            l_param_tab(r.param_name) := r.param_name;
        end if;

        if r.data_type = com_api_const_pkg.DATA_TYPE_DATE then
            l_param_value := nvl(r.param_value, r.date_value);
        elsif r.data_type = com_api_const_pkg.DATA_TYPE_NUMBER then
            l_param_value := nvl(r.param_value, r.number_value);
        else 
            l_param_value := nvl(r.param_value, r.char_value);
        end if;       

        -- Check access to specified inst_id and agent_id
        if l_param_value is not null then
            if upper(r.param_name)    = 'I_INST_ID'  then
                ost_api_institution_pkg.check_inst_id(
                    i_inst_id => to_number(l_param_value, com_api_const_pkg.NUMBER_FORMAT)
                );

            elsif upper(r.param_name) = 'I_AGENT_ID' then
                ost_api_agent_pkg.check_agent_id(
                    i_agent_id => to_number(l_param_value, com_api_const_pkg.NUMBER_FORMAT)
                );
            end if;
        end if;

        -- save param
        if i_thread_number in (-1, 1) then 
            prc_api_process_history_pkg.add(
                i_session_id  => l_session_id
              , i_param_id    => r.id
              , i_param_value => trim(both '''' from l_param_value)
            );
        end if;
        
        l_param := l_param || r.param_name || ' => ';

        if r.is_format = com_api_const_pkg.FALSE then
            l_param_value := nvl(nvl(r.char_value, r.param_value), 'NULL');
        elsif r.data_type = com_api_const_pkg.DATA_TYPE_DATE then
            if nvl(r.param_value, r.date_value) is null then
                l_param_value := 'NULL';
            else
                l_param_value := 'to_date(''' || nvl(r.param_value, r.date_value) || ''', '''|| com_api_const_pkg.DATE_FORMAT || ''')';
            end if;

        elsif r.data_type = com_api_const_pkg.DATA_TYPE_NUMBER then
            if nvl(r.param_value, r.number_value) is null then
                l_param_value := 'NULL';
            else
                l_param_value := 'to_number(''' || nvl(r.param_value, r.number_value) || ''', '''|| com_api_const_pkg.NUMBER_FORMAT || ''')';
            end if;
        else
            if nvl(r.param_value, r.char_value) is null then
                l_param_value := 'NULL';
            else
                l_param_value := '''' || nvl(r.param_value, r.char_value) || '''';
            end if;
        end if;

        l_param := l_param || l_param_value || ', ';

    end loop;

    if l_dupl_param_list is not null then
        com_api_error_pkg.raise_error(
            i_error       => 'DUPLICATE_PARAMETER_NAMES'
          , i_env_param1  => l_dupl_param_list
          , i_env_param2  => l_dupl_count
        );
    end if;

    if l_param is not null then
        l_param := '( ' || rtrim(l_param, ', ') || ' )';
    end if;

    l_run_sql := 
        replace(
            srcstr => l_run_sql
          , oldsub => ':PARAM'
          , newsub => l_param 
        );

    trc_log_pkg.debug (i_text => 'Run code: ' || l_run_sql);

    l_cursor_handle := dbms_sql.open_cursor(1);

    dbms_sql.parse(
        c             => l_cursor_handle
      , statement     => l_run_sql
      , language_flag => dbms_sql.native
    );

    trc_log_pkg.info(
        i_text          => 'PROCESS_STARTED'
      , i_env_param1    => get_text('prc_process', 'name', prc_api_session_pkg.get_process_id)
      , i_env_param2    => i_thread_number
    );

    --------------- Run process
    g_session_file_id := i_session_file_id;

    l_result := dbms_sql.execute(c => l_cursor_handle);
    
    dbms_sql.close_cursor(c => l_cursor_handle);

    g_session_file_id := null;

    acc_api_entry_pkg.flush_job;
    
    fcl_api_limit_pkg.flush_limit_buffer;

    trc_log_pkg.info(
        i_text          => 'PROCESS_FINISHED'
      , i_env_param1    => get_text('prc_process', 'name', prc_api_session_pkg.get_process_id)
      , i_env_param2    => i_thread_number
    );

    trc_ora_trace_pkg.disable_trace(
        i_trace_current_session  => com_api_type_pkg.TRUE
    );

    trc_log_pkg.debug('run_process: sys.dbms_support.mysid=' || sys.dbms_support.mysid);
    prc_api_session_pkg.reset_client_info;

exception
    when others then
        if l_cursor_handle is not null then
            dbms_sql.close_cursor(c => l_cursor_handle);
        end if;

        prc_api_file_pkg.generate_response_file;
        
        trc_log_pkg.fatal(
            i_text          => 'UNHANDLED_EXCEPTION'
          , i_env_param1    => sqlerrm
        );
        
        evt_api_event_pkg.cancel_events;

        -- Disable oracle tracing must be placed before "stop_session" method.
        trc_ora_trace_pkg.disable_trace(
            i_trace_current_session  => com_api_type_pkg.TRUE
        );

        prc_api_session_pkg.stop_session(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        raise;
end run_process;

procedure before_process (
    i_process_id            in      com_api_type_pkg.t_short_id
  , io_session_id           in out  com_api_type_pkg.t_long_id
  , i_thread_number         in      com_api_type_pkg.t_tiny_id      default 1
  , i_parent_session_id     in      com_api_type_pkg.t_long_id
  , i_eff_date              in      date                            default null
  , o_resp_code                out  com_api_type_pkg.t_boolean
  , o_error_desc               out  com_api_type_pkg.t_text
  , i_container_id          in      com_api_type_pkg.t_short_id     default null
) is
    l_result                pls_integer;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_stop_session_reason   com_api_type_pkg.t_dict_value;
begin
    o_resp_code := com_api_type_pkg.TRUE;
    com_api_sttl_day_pkg.set_sysdate(nvl(i_eff_date, get_sysdate));

    select min(b.inst_id)
      into l_inst_id
      from prc_session a
          , prc_process b
     where a.process_id = b.id
       and a.id = i_parent_session_id;

    prc_api_session_pkg.start_session(
        i_process_id        => i_process_id
      , io_session_id       => io_session_id
      , i_thread_number     => i_thread_number
      , i_parent_session_id => i_parent_session_id
      , i_container_id      => i_container_id
      , i_inst_id           => l_inst_id
    );

    -- This is the point when we reset trace count for the current oracle session.
    trc_log_pkg.reset_trace_count;

    -- The debug message must be placed after "start_session" call and initialization of "session_id" value.
    trc_log_pkg.debug(
        i_text => 'before_process: i_process_id=[#1], i_eff_date=[#2], io_session_id=[#3], i_parent_session_id=[#4], i_thread_number=[#5], i_container_id=[#6]'
      , i_env_param1  => i_process_id
      , i_env_param2  => to_char(get_sysdate, 'dd.mm.yyyy hh24:mi:ss')
      , i_env_param3  => io_session_id
      , i_env_param4  => i_parent_session_id
      , i_env_param5  => i_thread_number
      , i_env_param6  => i_container_id
    );

    -- need check semaphore
    trc_log_pkg.debug(
        i_text        => 'Check locking for process [#1]'
      , i_env_param1  => i_process_id
    );  
            
    for r in (
        select a.semaphore_name
          from prc_group a
             , prc_group_process b
         where b.process_id = i_process_id
           and a.id         = b.group_id
           and not exists (
                       select 1
                         from prc_semaphore s
                        where s.semaphore_name = a.semaphore_name
                          and s.session_id     = io_session_id
           )
    ) loop
        trc_log_pkg.debug(
            i_text => 'Request semaphore [#1] for process [#2]'
          , i_env_param1  => r.semaphore_name
          , i_env_param2  => i_process_id
        );

        -- request semaphore
        l_result := prc_api_lock_pkg.request_lock(
                        i_session_id      => io_session_id
                      , i_semaphore_name  => r.semaphore_name
                    );

        if l_result <> 0 then

            l_stop_session_reason := prc_api_const_pkg.PROCESS_RESULT_LOCKED;

            com_api_error_pkg.raise_error(
                i_error         => 'PROCESS_IS_LOCKED'
              , i_env_param1    => i_process_id
              , i_env_param2    => r.semaphore_name
            );

        end if;

    end loop;

    trc_log_pkg.debug(
        i_text => 'before_process: EXIT with i_process_id=[#1], i_eff_date=[#2], io_session_id=[#3]' 
      , i_env_param1  => i_process_id
      , i_env_param2  => to_char(get_sysdate, 'dd.mm.yyyy hh24:mi:ss')
      , i_env_param3  => io_session_id
    );
exception
    when others then

        o_resp_code  := com_api_type_pkg.FALSE;
        o_error_desc := coalesce(com_api_error_pkg.get_last_message, SQLERRM);

        if l_stop_session_reason is null then
            trc_log_pkg.fatal(
                i_text          => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
      
            prc_api_session_pkg.stop_session(
                i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

        else
            prc_api_session_pkg.stop_session(
                i_result_code   => l_stop_session_reason
            );

        end if;

end before_process;

procedure after_process (
    i_session_id            in      com_api_type_pkg.t_long_id
  , i_result_code           in      com_api_type_pkg.t_dict_value
  , o_resp_code                out  com_api_type_pkg.t_boolean
  , i_container_id          in      com_api_type_pkg.t_short_id     default null
) is
    l_result                pls_integer;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_process_id            com_api_type_pkg.t_short_id;
    l_is_container          com_api_type_pkg.t_boolean;
    l_is_external           com_api_type_pkg.t_boolean;
    l_processed             com_api_type_pkg.t_long_id;
    l_excepted              com_api_type_pkg.t_long_id;
    l_rejected              com_api_type_pkg.t_long_id;
    l_param_tab             com_api_type_pkg.t_param_tab;
    l_container_id          com_api_type_pkg.t_short_id  := i_container_id;
begin
    prc_api_session_pkg.set_container_id(
        i_container_id  => l_container_id
    );

    prc_api_session_pkg.set_session_id(
        i_session_id    => i_session_id
    );

    -- The debug messages must be placed after "set_session_id" and "set_container_id" methods.
    trc_log_pkg.debug(
        i_text       => 'after_process: i_session_id [#1], i_container_id [#2], i_result_code [#3]'
      , i_env_param1 => i_session_id
      , i_env_param2 => i_container_id
      , i_env_param3 => i_result_code
    );

    trc_log_pkg.debug('after_process: sys.dbms_support.mysid=' || sys.dbms_support.mysid);

    select s.inst_id
         , s.process_id
         , p.is_container
         , p.is_external
         , s.processed
         , s.excepted
         , s.rejected
      into l_inst_id
         , l_process_id
         , l_is_container
         , l_is_external
         , l_processed
         , l_excepted
         , l_rejected
      from prc_session s
         , prc_process p
     where s.id = i_session_id
       and p.id = s.process_id;

    prc_api_session_pkg.set_process_id(
        i_process_id => l_process_id
    );

    rul_api_param_pkg.set_param (
        io_params           => l_param_tab
      , i_name              => 'PROCESS_ID'
      , i_value             => l_process_id
    );

    rul_api_param_pkg.set_param (
        io_params           => l_param_tab
      , i_name              => 'PROCESS_IS_CONTAINER'
      , i_value             => l_is_container
    );

    rul_api_param_pkg.set_param (
        io_params           => l_param_tab
      , i_name              => 'PROCESS_IS_EXTERNAL'
      , i_value             => l_is_external
    );

    rul_api_param_pkg.set_param (
        io_params           => l_param_tab
      , i_name              => 'PROCESS_PROCESSED'
      , i_value             => l_processed
    );

    rul_api_param_pkg.set_param (
        io_params           => l_param_tab
      , i_name              => 'PROCESS_EXCEPTED'
      , i_value             => l_excepted
    );

    rul_api_param_pkg.set_param (
        io_params           => l_param_tab
      , i_name              => 'PROCESS_REJECTED'
      , i_value             => l_rejected
    );

    if i_result_code = prc_api_const_pkg.PROCESS_RESULT_SUCCESS then
        evt_api_event_pkg.register_event(
            i_event_type        => prc_api_const_pkg.EVENT_TYPE_PROCESS_SUCCESS
          , i_eff_date          => com_api_sttl_day_pkg.get_sysdate
          , i_entity_type       => prc_api_const_pkg.ENTITY_TYPE_SESSION
          , i_object_id         => i_session_id
          , i_inst_id           => l_inst_id
          , i_split_hash        => com_api_hash_pkg.get_split_hash(i_session_id)
          , i_param_tab         => l_param_tab
        );
    else
        evt_api_event_pkg.register_event(
            i_event_type        => prc_api_const_pkg.EVENT_TYPE_PROCESS_FAIL
          , i_eff_date          => com_api_sttl_day_pkg.get_sysdate
          , i_entity_type       => prc_api_const_pkg.ENTITY_TYPE_SESSION
          , i_object_id         => i_session_id
          , i_inst_id           => l_inst_id
          , i_split_hash        => com_api_hash_pkg.get_split_hash(i_session_id)
          , i_param_tab         => l_param_tab
        );
    end if;  
    
    if i_result_code != prc_api_const_pkg.PROCESS_RESULT_LOCKED or i_result_code is null then

        -- release all locked semaphores
        for r in (
            select s.semaphore_name
              from prc_group g
                 , prc_group_process b
                 , prc_semaphore s
             where g.id             = b.group_id
               and g.semaphore_name = s.semaphore_name 
               and b.process_id     = l_process_id             
               and s.session_id     = i_session_id
        ) loop

            -- semaphore
            trc_log_pkg.debug( 
                i_text => 'Release semaphore [#1] with SID [#2] for process [#3]'
              , i_env_param1 => r.semaphore_name
              , i_env_param2 => sys_context('userenv', 'sid')
              , i_env_param3 => l_process_id
            );

            l_result := prc_api_lock_pkg.release_lock(
                            i_session_id        => i_session_id
                          , i_semaphore_name  => r.semaphore_name
                        );
                    
            if l_result != 0 then
                trc_log_pkg.error (
                    i_text          => 'SEMAPHORE_NOT_RELEASED'
                  , i_env_param1    => r.semaphore_name
                );

                prc_api_session_pkg.stop_session(
                   i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
                );
                o_resp_code := com_api_type_pkg.FALSE;
                return;

            else
                trc_log_pkg.debug(
                    i_text => 'Semaphore is released successfuly.'
                );

            end if;

        end loop;

    end if;

    -- The debug message must be placed before "stop_session" call and reset of "session_id" value.
    -- The "o_resp_code" variable will be changed as last command of this process.
    trc_log_pkg.debug(
        i_text => 'after_process: EXIT with i_session_id [' || i_session_id
               || '], o_resp_code [' || com_api_type_pkg.TRUE || ']'
    );
    
    prc_api_session_pkg.stop_session(
        i_result_code   => nvl(i_result_code, prc_api_const_pkg.PROCESS_RESULT_SUCCESS)
    );
    o_resp_code := com_api_type_pkg.TRUE;

exception
    when com_api_error_pkg.e_application_error then
        prc_api_session_pkg.stop_session(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        o_resp_code := com_api_type_pkg.FALSE;
    when com_api_error_pkg.e_fatal_error then
        prc_api_session_pkg.stop_session(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        o_resp_code := com_api_type_pkg.FALSE;
    when no_data_found then
        prc_api_session_pkg.stop_session(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        o_resp_code := com_api_type_pkg.FALSE;
    when others then
        trc_log_pkg.fatal(
            i_text          => 'UNHANDLED_EXCEPTION'
          , i_env_param1    => sqlerrm
        );
        o_resp_code := com_api_type_pkg.FALSE;
 
        prc_api_session_pkg.stop_session(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        raise;
end after_process;

function get_session_file_id return com_api_type_pkg.t_long_id is
begin
    return g_session_file_id;
end get_session_file_id;

function get_param_tab return com_param_map_tpt is
begin
    return g_param_tab;
end get_param_tab;

end prc_ui_run_pkg;
/
