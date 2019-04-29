create or replace package body trc_ora_trace_pkg as
/*********************************************************
 *  API for Oracle trace file <br />
 *  Created by Truschelev O.(truschelev@bpcbt.com)  at 20.02.2016 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: trc_ora_trace_pkg <br />
 *  @headcom
 **********************************************************/

TRACE_DISABLED        constant    com_api_type_pkg.t_name       := 'DISABLED';
TRACE_ENABLED         constant    com_api_type_pkg.t_name       := 'ENABLED';

NO_TRACE_LEVEL        constant    com_api_type_pkg.t_tiny_id    := 0;
SIMPLE_LEVEL          constant    com_api_type_pkg.t_tiny_id    := 2;
BIND_ONLY_LEVEL       constant    com_api_type_pkg.t_tiny_id    := 4;
WAIT_ONLY_LEVEL       constant    com_api_type_pkg.t_tiny_id    := 8;
BIND_AND_WAIT_LEVEL   constant    com_api_type_pkg.t_tiny_id    := 12;

TRACE_MESSAGE_LABEL    constant   com_api_type_pkg.t_name       := 'Oracle trace file';

g_oracle_user                     com_api_type_pkg.t_name;

-- Get cached value of Oracle function USER.
function get_oracle_user return com_api_type_pkg.t_name is
begin
    if g_oracle_user is null then
        g_oracle_user  := user;
    end if;

    return g_oracle_user;
end;

-- Get trace level for specified Oracle session.
function get_trace_level(
    i_sid            in    com_api_type_pkg.t_long_id
  , i_serial         in    com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_tiny_id is

    TRACE_TRUE   constant  com_api_type_pkg.t_name := 'TRUE';

    l_sql_trace_value      com_api_type_pkg.t_name;
    l_sql_trace_waits      com_api_type_pkg.t_name;
    l_sql_trace_binds      com_api_type_pkg.t_name;
    l_trace_level          com_api_type_pkg.t_tiny_id;
begin
    select sql_trace, sql_trace_waits, sql_trace_binds
      into l_sql_trace_value
         , l_sql_trace_waits
         , l_sql_trace_binds
      from v$session
     where sid     = i_sid
       and serial# = i_serial;

    if l_sql_trace_value = TRACE_DISABLED then
      l_trace_level := NO_TRACE_LEVEL;

    elsif l_sql_trace_value = TRACE_ENABLED then
        if l_sql_trace_waits = TRACE_TRUE and l_sql_trace_binds = TRACE_TRUE then
            l_trace_level := BIND_AND_WAIT_LEVEL;

        elsif l_sql_trace_waits = TRACE_TRUE then
            l_trace_level := WAIT_ONLY_LEVEL;

        elsif l_sql_trace_binds = TRACE_TRUE then
            l_trace_level := BIND_ONLY_LEVEL;
          
        else
            l_trace_level := SIMPLE_LEVEL;

        end if;
    end if;

    return l_trace_level;
exception
    when no_data_found then
        return null;
end;

-- Get trace information by "session_id" and "thread_number" values.
procedure get_trace_info(
    i_session_id     in    com_api_type_pkg.t_long_id
  , i_thread_number  in    com_api_type_pkg.t_tiny_id
  , o_sid           out    com_api_type_pkg.t_long_id
  , o_serial        out    com_api_type_pkg.t_long_id
  , o_trace_path    out    com_api_type_pkg.t_full_desc
  , o_trace_file    out    com_api_type_pkg.t_name
) is
    SID_LABEL    constant  com_api_type_pkg.t_name := 'SID=';
    SERIAL_LABEL constant  com_api_type_pkg.t_name := 'Serial=';
    PATH_LABEL   constant  com_api_type_pkg.t_name := 'Path=';
    FILE_LABEL   constant  com_api_type_pkg.t_name := 'File=';

    l_trace_text           com_api_type_pkg.t_text;

    function get_value(
        i_trace_text   in  com_api_type_pkg.t_text
      , i_label        in  com_api_type_pkg.t_name
    ) return com_api_type_pkg.t_text is
        l_result           com_api_type_pkg.t_full_desc;
    begin
        l_result := substr(i_trace_text, instr(i_trace_text, i_label));
        return substr(l_result, length(i_label) + 1, instr(l_result, ';') - length(i_label) - 1);
    end;
begin
    -- Get Oracle SID and Serial# from the special trc_log record for selected session id and selected thread.
    select trace_text
      into l_trace_text
      from trc_log
     where entity_type   = prc_api_const_pkg.ENTITY_TYPE_SESSION
       and object_id     = i_session_id
       and thread_number = i_thread_number
       and substr(trace_text, 1, length(TRACE_MESSAGE_LABEL)) = TRACE_MESSAGE_LABEL
       and rownum = 1;

    o_sid        := get_value(i_trace_text => l_trace_text, i_label => SID_LABEL);
    o_serial     := get_value(i_trace_text => l_trace_text, i_label => SERIAL_LABEL);
    o_trace_path := get_value(i_trace_text => l_trace_text, i_label => PATH_LABEL);
    o_trace_file := get_value(i_trace_text => l_trace_text, i_label => FILE_LABEL);

exception
    when no_data_found then
        o_sid        := null;
        o_serial     := null;
        o_trace_path := null;
        o_trace_file := null;
end;

-- Get last message for the oracle tracing actions.
function get_trace_message(
    i_session_id               in     com_api_type_pkg.t_long_id
  , i_thread_number            in     com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_full_desc is
    l_trace_text                      com_api_type_pkg.t_full_desc;
begin
    select trace_text
      into l_trace_text
      from (
        select trace_text
          from trc_log
         where entity_type   = prc_api_const_pkg.ENTITY_TYPE_SESSION
           and object_id     = i_session_id
           and thread_number = i_thread_number
           and substr(trace_text, 1, length(TRACE_MESSAGE_LABEL)) != TRACE_MESSAGE_LABEL
        order by trace_timestamp desc
       )
      where rownum = 1;

    return l_trace_text;
end;

-- Insert record into trc_log as "INFO" level.
procedure log_trace_info(
    i_message_text         in    com_api_type_pkg.t_full_desc
  , i_target_session_id    in    com_api_type_pkg.t_long_id   := null
) is
    l_trace_conf       trc_config_pkg.trace_conf;
    l_session_id       com_api_type_pkg.t_long_id;
    l_thread_number    com_api_type_pkg.t_tiny_id;
begin
    l_trace_conf.trace_level      := trc_config_pkg.INFO;
    l_trace_conf.use_table        := trc_config_pkg.DEFAULT_TABLE;
    l_trace_conf.use_session      := trc_config_pkg.DEFAULT_SESSION;
    l_trace_conf.use_dbms_output  := trc_config_pkg.DEFAULT_DBMS_OUTPUT;
    l_trace_conf.log_mode         := trc_config_pkg.DEFAULT_LOG_MODE;
    l_trace_conf.start_trace_size := null;
    l_trace_conf.error_trace_size := null;
  
    l_session_id                  := nvl(i_target_session_id, prc_api_session_pkg.get_session_id);
    l_thread_number               := prc_api_session_pkg.get_thread_number;

    trc_table_pkg.log(
        i_trace_conf    => l_trace_conf
      , i_timestamp     => systimestamp
      , i_level         => trc_config_pkg.g_codes(l_trace_conf.trace_level)
      , i_section       => null
      , i_user          => nvl(sys_context('USERENV', 'CLIENT_IDENTIFIER'), get_oracle_user)
      , i_text          => i_message_text
      , i_entity_type   => 'ENTTSESS'
      , i_object_id     => l_session_id
      , i_event_id      => null
      , i_label_id      => null
      , i_inst_id       => null
      , i_session_id    => l_session_id
      , i_thread_number => l_thread_number
      , i_who_called    => null
      , i_trace_count   => null
    );

end;

-- Save trace information into special record in trc_log for current "session_id" and "thread_number" values.
procedure save_trace_info is
    l_sid              com_api_type_pkg.t_long_id;
    l_serial           com_api_type_pkg.t_long_id;
    l_message_text     com_api_type_pkg.t_full_desc;
    l_trace_path       com_api_type_pkg.t_full_desc;
    l_trace_file       com_api_type_pkg.t_name;
    l_oracle_user      com_api_type_pkg.t_name;
begin

    -- get oracle user
    l_oracle_user := get_oracle_user;

    execute immediate 'begin'
                    ||'    :l_sid := sys.dbms_support.mysid;'
                    ||'end;'
        using out l_sid;

    -- Get path name and file name of the trace file.
    select vs.serial#
         , vp.tracefile
      into l_serial
         , l_trace_file
      from v$process vp
         , v$session vs
     where vs.username = l_oracle_user
       and vs.sid      = l_sid
       and vp.addr     = vs.paddr;

    l_trace_path := substr(l_trace_file, 1, instr(l_trace_file, '/', -1));
    l_trace_file := substr(l_trace_file, instr(l_trace_file, '/', -1) + 1);

    l_message_text := TRACE_MESSAGE_LABEL
                      || ': SID='    || l_sid
                      || '; Serial=' || l_serial
                      || '; Path='   || l_trace_path
                      || '; File='   || l_trace_file
                      || ';';

    log_trace_info(
        i_message_text => l_message_text
    );

end;

-- Insert message into trc_log with "INFO" level for the oracle tracing actions.
procedure save_trace_message(
    i_is_enabled           in    com_api_type_pkg.t_boolean
  , i_trace_path           in    com_api_type_pkg.t_full_desc
  , i_trace_file           in    com_api_type_pkg.t_name
  , i_target_session_id    in    com_api_type_pkg.t_long_id
  , i_trace_level          in    com_api_type_pkg.t_tiny_id
) is
    l_message_text    com_api_type_pkg.t_full_desc;
begin
    if i_is_enabled = com_api_type_pkg.TRUE then
        l_message_text := com_api_label_pkg.get_label_text('ORACLE_TRACING_WAS_ENABLED');
    else
        l_message_text := com_api_label_pkg.get_label_text('ORACLE_TRACING_WAS_DISABLED');
    end if;

    l_message_text := replace(l_message_text, '#1', nvl(to_char(i_trace_level), 'NULL'));
    l_message_text := replace(l_message_text, '#2', nvl(i_trace_path || i_trace_file, 'NULL'));
    l_message_text := replace(l_message_text, '#3', 'tkprof ' || i_trace_file || ' ' || i_trace_file || '.out sys=yes sort=fchela explain=' || get_oracle_user || '/password');

    log_trace_info(
        i_message_text      => l_message_text
      , i_target_session_id => i_target_session_id
    );
end;

-- Enable or disable the oracle tracing.
procedure set_trace(
    i_is_enabled               in     com_api_type_pkg.t_boolean
  , i_trace_level              in     com_api_type_pkg.t_tiny_id
  , i_trace_current_session    in     com_api_type_pkg.t_boolean
  , i_session_id               in     com_api_type_pkg.t_long_id
  , i_thread_number            in     com_api_type_pkg.t_tiny_id
) is
    l_session_id       com_api_type_pkg.t_long_id;
    l_thread_number    com_api_type_pkg.t_tiny_id;
    l_sid              com_api_type_pkg.t_long_id;
    l_serial           com_api_type_pkg.t_long_id;
    l_trace_path       com_api_type_pkg.t_full_desc;
    l_trace_file       com_api_type_pkg.t_name;
    l_waits            com_api_type_pkg.t_name;
    l_binds            com_api_type_pkg.t_name;
    l_old_trace_level  com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(
        i_text       => 'set_trace: i_is_enabled [#1] i_trace_level [#2] i_trace_current_session [#3] i_session_id [#4] i_thread_number [#5]'
      , i_env_param1 => i_is_enabled
      , i_env_param2 => i_trace_level
      , i_env_param3 => i_trace_current_session
      , i_env_param4 => i_session_id
      , i_env_param5 => i_thread_number
    );

    -- This method contains the "Info" message instead of the "Error" message
    -- therefore the oracle tracing error don't interrupt the main process.
    if i_trace_current_session = com_api_type_pkg.FALSE
       and i_session_id is null
    then
        log_trace_info(
            i_message_text => 'Session id is required for Oracle tracing'
        );
        return;
    end if;

    if i_trace_current_session = com_api_type_pkg.TRUE then
        l_session_id        := prc_api_session_pkg.get_session_id;
        l_thread_number     := prc_api_session_pkg.get_thread_number;
    else
        l_session_id        := i_session_id;
        l_thread_number     := i_thread_number;
    end if;

    get_trace_info(
        i_session_id    => l_session_id
      , i_thread_number => l_thread_number
      , o_sid           => l_sid
      , o_serial        => l_serial
      , o_trace_path    => l_trace_path
      , o_trace_file    => l_trace_file
    );

    if l_sid is null or l_serial is null then
        -- Oracle session is not found by l_session_id, l_thread_number.
        trc_log_pkg.debug(
            i_text       => 'set_trace: Oracle session is not found by l_session_id, l_thread_number.'
        );
        return;
    end if;

    -- Oracle trace levels:
    --    0 - No trace. Like switching sql_trace off.
    --    2 - The equivalent of regular sql_trace.
    --    4 - The same as 2, but with the addition of bind variable values.
    --    8 - The same as 2, but with the addition of wait events.
    --   12 - The same as 2, but with both bind variable values and wait events.

    if i_is_enabled = com_api_type_pkg.TRUE then
        if i_trace_level in (WAIT_ONLY_LEVEL, BIND_AND_WAIT_LEVEL) then
            l_waits := 'TRUE';
        else
            l_waits := 'FALSE';
        end if;

        if i_trace_level in (BIND_ONLY_LEVEL, BIND_AND_WAIT_LEVEL) then
            l_binds := 'TRUE';
        else
            l_binds := 'FALSE';
        end if;

    else
        l_old_trace_level := get_trace_level(
                                 i_sid    => l_sid
                               , i_serial => l_serial
                             );

        if l_old_trace_level = NO_TRACE_LEVEL then
            -- Oracle trace is disabled already.
            trc_log_pkg.debug(
                i_text       => 'set_trace: Oracle trace is disabled already.'
            );
            return;

        elsif l_old_trace_level is null then
            -- Oracle session closed or not found by l_session_id, l_thread_number.
            trc_log_pkg.debug(
                i_text       => 'set_trace: Oracle session closed or not found by l_session_id, l_thread_number.'
            );
            return;

        end if;

        trc_log_pkg.debug(
            i_text       => 'set_trace: l_old_trace_level [#1]'
          , i_env_param1 => l_old_trace_level
        );
    end if;

    begin
        if i_trace_current_session = com_api_type_pkg.TRUE then
            if i_is_enabled = com_api_type_pkg.TRUE and i_trace_level != NO_TRACE_LEVEL then
                execute immediate 'begin'
                                ||'    sys.dbms_support.start_trace('
                                ||'        waits => ' || l_waits
                                ||'      , binds => ' || l_binds
                                ||'    );'
                                ||'end;';

            else
                execute immediate 'begin'
                                ||'    sys.dbms_support.stop_trace;'
                                ||'end;';

            end if;

        elsif i_session_id is not null then
            if i_is_enabled = com_api_type_pkg.TRUE and i_trace_level != NO_TRACE_LEVEL then
                execute immediate 'begin'
                                ||'    sys.dbms_support.start_trace_in_session('
                                ||'        sid    => :l_sid'
                                ||'      , serial => :l_serial'
                                ||'      , waits  => ' || l_waits
                                ||'      , binds  => ' || l_binds
                                ||'    );'
                                ||'end;'
                    using l_sid, l_serial;

            else
                execute immediate 'begin'
                                ||'    sys.dbms_support.stop_trace_in_session('
                                ||'        sid    => :l_sid'
                                ||'      , serial => :l_serial'
                                ||'    );'
                                ||'end;'
                    using l_sid, l_serial;

            end if;

        end if;

        trc_log_pkg.debug(
            i_text       => 'set_trace: Finish'
        );
    exception
        when others then
            log_trace_info(
                i_message_text => 'Cannot execute the method of "sys.dbms_support" package'
            );
            return;
    end;

    save_trace_message(
        i_is_enabled        => i_is_enabled
      , i_trace_path        => l_trace_path
      , i_trace_file        => l_trace_file
      , i_target_session_id => l_session_id
      , i_trace_level       => i_trace_level
    );

end;

-- Enable the oracle tracing.
procedure enable_trace(
    i_trace_level              in     com_api_type_pkg.t_tiny_id
  , i_trace_current_session    in     com_api_type_pkg.t_boolean
  , i_session_id               in     com_api_type_pkg.t_long_id    := null
  , i_thread_number            in     com_api_type_pkg.t_tiny_id    := null
) is
begin
    set_trace(
        i_is_enabled            => com_api_type_pkg.TRUE
      , i_trace_level           => i_trace_level
      , i_trace_current_session => i_trace_current_session
      , i_session_id            => i_session_id
      , i_thread_number         => i_thread_number
    );
end;

-- Disable the oracle tracing.
procedure disable_trace(
    i_trace_current_session    in    com_api_type_pkg.t_boolean
  , i_session_id               in    com_api_type_pkg.t_long_id    := null
  , i_thread_number            in    com_api_type_pkg.t_tiny_id    := null
) is
    NO_TRACE_CODE        constant    com_api_type_pkg.t_tiny_id    := 0;
begin
    set_trace(
        i_is_enabled            => com_api_type_pkg.FALSE
      , i_trace_level           => NO_TRACE_CODE
      , i_trace_current_session => i_trace_current_session
      , i_session_id            => i_session_id
      , i_thread_number         => i_thread_number
    );
end;

-- Check and enable the oracle tracing during the process start.
procedure check_tracing_on_start(
    i_oracle_trace_level    in      com_api_type_pkg.t_tiny_id
  , i_thread_number         in      com_api_type_pkg.t_tiny_id
  , i_trace_thread_number   in      com_api_type_pkg.t_tiny_id
) is
begin
    trc_ora_trace_pkg.save_trace_info;

    if nvl(i_oracle_trace_level, trc_api_const_pkg.DEFAULT_ORACLE_TRACE_LABEL) != trc_api_const_pkg.DEFAULT_ORACLE_TRACE_LABEL
       and (
               i_trace_thread_number is null
               or i_trace_thread_number = i_thread_number
               or (i_trace_thread_number = -1 and i_thread_number = 1)
       )
    then
        trc_ora_trace_pkg.enable_trace(
            i_trace_level            => i_oracle_trace_level
          , i_trace_current_session  => com_api_type_pkg.TRUE
        );
    end if;
end;

-- Get trace level for specified SV session.
function get_session_trace_level(
    i_session_id     in    com_api_type_pkg.t_long_id
  , i_thread_number  in    com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_tiny_id is
    l_trace_level          com_api_type_pkg.t_tiny_id;
    l_sid                  com_api_type_pkg.t_long_id;
    l_serial               com_api_type_pkg.t_long_id;
    l_trace_path           com_api_type_pkg.t_full_desc;
    l_trace_file           com_api_type_pkg.t_name;
begin
    get_trace_info(
        i_session_id     => i_session_id
      , i_thread_number  => i_thread_number
      , o_sid            => l_sid
      , o_serial         => l_serial
      , o_trace_path     => l_trace_path
      , o_trace_file     => l_trace_file
    );

    l_trace_level := get_trace_level(
                         i_sid        => l_sid
                       , i_serial     => l_serial
                     );

    return l_trace_level;
end;

end trc_ora_trace_pkg;
/
