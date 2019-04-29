create or replace package body trc_log_pkg is
/*************************************************************
 * API for logging <br />
 * Created by Filimonov E.(filimonov@bpc.ru)  at 08.07.2009
 * Module: TRC_LOG_PKG
 * @headcom
**************************************************************/

ENV_PARAM_COUNT        constant pls_integer := 6;
SIZEOF_T_FULL_DESC     constant pls_integer := 2000; -- sizeof(com_api_type_pkg.t_full_desc)
SIZEOF_T_TEXT          constant pls_integer := 4000; -- sizeof(com_api_type_pkg.t_text)
DEFAULT_TRACE_COUNT    constant pls_integer := 1;

g_entity_type                   com_api_type_pkg.t_dict_value;
g_object_id                     com_api_type_pkg.t_long_id;
g_trace_count                   com_api_type_pkg.t_long_id     := DEFAULT_TRACE_COUNT;
g_oracle_user                   com_api_type_pkg.t_name;

procedure set_object(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
) is
begin
    g_entity_type := i_entity_type;
    g_object_id   := i_object_id;
end set_object;

procedure clear_object is
begin
    g_entity_type := null;
    g_object_id   := null;
end clear_object;

function who_called_me(
    i_level in      com_api_type_pkg.t_tiny_id default trc_config_pkg.DEFAULT_LEVEL
) return com_api_type_pkg.t_name
is
    l_call_stack    com_api_type_pkg.t_text;
    n               pls_integer;
    l_found_stack   com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE;
    l_line          com_api_type_pkg.t_text;
    l_cnt           com_api_type_pkg.t_tiny_id := 0;

    l_owner         com_api_type_pkg.t_text;
    l_name          com_api_type_pkg.t_name;
    l_lineno        pls_integer;
    l_caller_t      com_api_type_pkg.t_name;
    l_str           com_api_type_pkg.t_text;
begin
    l_call_stack := dbms_utility.format_call_stack;
    loop
        n := instr( l_call_stack, chr(10) );
        exit when  l_cnt = i_level or n is NULL or n = 0 ;

        l_line       := substr( l_call_stack, 1, n-1 );
        l_call_stack := substr( l_call_stack, n+1 );

        if l_found_stack = com_api_const_pkg.FALSE then
            if l_line like '%handle%number%name%' then
                l_found_stack := com_api_const_pkg.TRUE;
            end if;
        else
            l_cnt := l_cnt + 1;
            -- cnt = 1 is ME
            -- cnt = 2 is MY Caller
            -- cnt = 3 is Their Caller
            if l_cnt = i_level  then
                l_str := ltrim(substr(l_line, instr(l_line,'   ') ) );
                l_lineno :=
                    to_number(
                        substr(l_str, 1, instr(l_str,'  ') )
                    );
                l_line   := substr( l_line, 23 );

                if    l_line like 'pr%' then           n := length( 'procedure ' );
                elsif l_line like 'fun%' then          n := length( 'function ' );
                elsif l_line like 'package body%' then n := length( 'package body ' );
                elsif l_line like 'pack%' then         n := length( 'package ' );
                elsif l_line like 'anonymous%' then    n := length( 'anonymous block ' );
                else                                   n := null;
                end if;

                if n is not null then
                    l_caller_t := ltrim(rtrim(upper(substr( l_line, 1, n-1 ))));
                else
                    l_caller_t := 'TRIGGER';
                end if;

                l_line := substr( l_line, nvl(n,1) );
                n := instr( l_line, '.' );
                l_owner := ltrim(rtrim(substr( l_line, 1, n-1 )));
                l_name  := ltrim(rtrim(substr( l_line, n+1 )));
            end if;
        end if;
    end loop;
   return --l_caller_t || ' ' || l_owner ||'.'||
          l_name||'  '||l_lineno;
end who_called_me;

function get_error_stack return com_api_type_pkg.t_text
is
    -- Strings that delimit different parts of line in stack.
    C_NAME_DELIM   constant char(1) := '"';
    C_DOT_DELIM    constant char(1) := '.';
    C_LINE_DELIM   constant char(4) := 'line';
    C_EOL_DELIM    constant char(1) := chr (10);
    -- Lots of INSTRs to come; these variables keep track
    -- of the start and end points of various portions of the string.
    v_dot_loc          pls_integer;
    v_name_start_loc   pls_integer;
    v_name_end_loc     pls_integer;
    v_line_loc         pls_integer;
    v_eol_loc          pls_integer;
    v_error_stack      com_api_type_pkg.t_text;
    v_result           com_api_type_pkg.t_text;
begin
    v_error_stack    := dbms_utility.format_error_backtrace;
    -- Function dbms_utility.format_call_stack returns the call stack, up to 2000 bytes
    v_result         := substr(dbms_utility.format_call_stack, 82);
    v_name_start_loc := instr(v_error_stack, C_NAME_DELIM, 1, 1);
    v_dot_loc        := instr(v_error_stack, C_DOT_DELIM);
    v_name_end_loc   := instr(v_error_stack, C_NAME_DELIM, 1, 2);
    v_line_loc       := instr(v_error_stack, C_LINE_DELIM);
    v_eol_loc        := instr(v_error_stack, C_EOL_DELIM);
    begin
        v_result := v_result || 'Program owner = ' || substr( v_error_stack
                                                            , v_name_start_loc + 1
                                                            , v_dot_loc - v_name_start_loc - 1 ) || C_EOL_DELIM;
        v_result := v_result || 'Program name = ' || substr( v_error_stack
                                                           , v_dot_loc + 1
                                                           , v_name_end_loc - v_dot_loc - 1) || C_EOL_DELIM;
        v_result := v_result || 'Line number = ' ||  substr( v_error_stack
                                                           , v_line_loc + 5
                                                           , v_eol_loc - v_line_loc - 5) || C_EOL_DELIM;
    exception
        when com_api_error_pkg.e_value_error then
            null; -- string overflow shouldn't crash a process, to loose some logging information is acceptable
    end;
    return v_result;
end get_error_stack;

function get_text(
    i_label_id          in      com_api_type_pkg.t_short_id
  , i_trace_text        in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) return com_api_type_pkg.t_text
is
    l_result            com_api_type_pkg.t_lob_data; -- uses a longest available string type to escape variable's overflow
    l_env_param         com_api_type_pkg.t_full_desc;
    l_trace_text        com_api_type_pkg.t_full_desc := i_trace_text;
    l_pos               pls_integer;
    i                   com_api_type_pkg.t_count := 1;
begin
    if i_label_id is null then
        return i_trace_text;
    end if;

    l_result := com_api_i18n_pkg.get_text('com_label', 'name', i_label_id, i_lang);

    while i <= ENV_PARAM_COUNT
      and instr(l_result, '#') > 0
      and lengthb(l_result) < SIZEOF_T_TEXT
    loop
        l_pos := instr(l_trace_text, '";');
        if l_pos = 0 then
            l_env_param := trim(both '"' from l_trace_text);
            l_result := replace(l_result, '#'||i, nvl(com_api_dictionary_pkg.get_article_text(to_char(l_env_param)), 'UNDEFINED'));
            l_trace_text := null;
        else
            l_env_param := trim(both '"' from substr(l_trace_text, 1, l_pos));
            l_trace_text := substr(l_trace_text, l_pos + 3);
            l_result := replace(l_result, '#'||i, nvl(com_api_dictionary_pkg.get_article_text(to_char(l_env_param)), 'UNDEFINED'));
        end if;
        i := i + 1;
    end loop;

    return substrb(l_result, 1, SIZEOF_T_TEXT);
end get_text;

-- Base non-interface function for using by overloaded interface functions
function get_details(
    i_env_variable      in      com_api_type_pkg.t_name
  , i_trace_text        in      com_api_type_pkg.t_text
) return com_api_type_pkg.t_text
is
    l_result        com_api_type_pkg.t_text;
    l_env_variable  com_api_type_pkg.t_text;
    l_trace_text    com_api_type_pkg.t_text;
    l_pos_var       pls_integer;
    l_pos_value     pls_integer;
    l_env_var       com_api_type_pkg.t_text;
    l_env_value     com_api_type_pkg.t_text;

    function get_var_name(
        p_variable      in  com_api_type_pkg.t_name
    ) return com_api_type_pkg.t_name is
        l_var_name          com_api_type_pkg.t_name;
    begin
        select short_description
          into l_var_name
          from rul_ui_mod_param_vw
         where name = p_variable
           and lang = com_ui_user_env_pkg.get_user_lang;

        return l_var_name;
    exception
        when no_data_found then
            return p_variable;
    end get_var_name;

begin
    l_env_variable := i_env_variable;
    l_trace_text   := i_trace_text;

    for i in 1..ENV_PARAM_COUNT loop
        if l_env_variable is null and l_trace_text is null then
            exit;
        end if;

        l_pos_var   := instr(l_env_variable, ',');
        l_pos_value := instr(l_trace_text, '";');

        if l_pos_var = 0 then
            l_env_var      := get_var_name(trim(both ' ' from l_env_variable));
            l_env_variable := null;
        else
            l_env_var      := get_var_name(trim(both ' ' from substr(l_env_variable, 1, l_pos_var-1)));
            l_env_variable := substr(l_env_variable, l_pos_var + 1);
        end if;

        if l_pos_value = 0 then
            l_env_value  := trim(both '"' from l_trace_text);
            l_trace_text := null;
        else
            l_env_value  := trim(both '"' from substr(l_trace_text, 1, l_pos_value));
            l_trace_text := substr(l_trace_text, l_pos_value + 3);
        end if;

        if l_env_var is not null or l_env_value != 'NULL' then
            l_result := l_result || nvl(l_env_var, 'UNKNOWN') || ' = [';

            l_result := l_result
                     || case l_env_value when 'NULL' then 'UNDEFINED' else l_env_value end
                     || ']' || chr(10);
        end if;
    end loop;

    return l_result;
end get_details; -- base function

function get_details(
    i_label_id          in      com_api_type_pkg.t_short_id
  , i_trace_text        in      com_api_type_pkg.t_text
) return com_api_type_pkg.t_text
is
    l_env_variable  com_api_type_pkg.t_text;
begin
    select env_variable
      into l_env_variable
      from com_label
     where id = i_label_id;

    return get_details(
               i_env_variable => l_env_variable
             , i_trace_text   => i_trace_text
           );
exception
    when no_data_found then
        return null;
end get_details; -- 1st interface overloaded function

function get_details return com_api_type_pkg.t_text
is
    l_result        com_api_type_pkg.t_text;
    l_env_variable  com_api_type_pkg.t_text;
    l_trace_text    com_api_type_pkg.t_text;
begin
    if prc_api_session_pkg.get_session_id is not null then

        select b.env_variable
             , a.trace_text
          into l_env_variable
             , l_trace_text
          from trc_log a
             , com_label b
         where a.label_id = b.id
           and a.session_id  = prc_api_session_pkg.get_session_id
           and a.thread_number = prc_api_session_pkg.get_thread_number
           and a.trace_timestamp =
            (
             select max(c.trace_timestamp)
               from trc_log c
              where c.session_id  = prc_api_session_pkg.get_session_id
                and c.thread_number = prc_api_session_pkg.get_thread_number
                and c.trace_level in (trc_api_const_pkg.TRACE_LEVEL_ERROR, trc_api_const_pkg.TRACE_LEVEL_FATAL)
            );

         l_result := get_details(
                         i_env_variable => l_env_variable
                       , i_trace_text   => l_trace_text
                     );
    end if;

    return l_result;
exception
    when no_data_found then
        return null;
end get_details; -- 2st interface overloaded function

procedure log(
    i_trace_conf        in      trc_config_pkg.trace_conf
  , i_timestamp         in      timestamp
  , i_level             in      com_api_type_pkg.t_dict_value
  , i_section           in      com_api_type_pkg.t_full_desc
  , i_user              in      com_api_type_pkg.t_oracle_name
  , i_text              in      com_api_type_pkg.t_text
  , i_param_text        in      com_api_type_pkg.t_text
  , i_label_id          in      com_api_type_pkg.t_short_id         default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , i_who_called        in      com_api_type_pkg.t_name             --default null
  , i_trace_count       in      com_api_type_pkg.t_long_id          default null
  , i_level_code        in      com_api_type_pkg.t_tiny_id          default null
  , i_text_mode         in      com_api_type_pkg.t_boolean          default null
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
) is
    l_text       com_api_type_pkg.t_text;
begin
    if i_text is null then
        l_text := 'SQLCODE:' || sqlcode || ' SQLERRM:' || sqlerrm;
    else
        begin
            l_text := i_text;
        exception
            when com_api_error_pkg.e_value_error then
                l_text := substrb(i_text, 1, SIZEOF_T_TEXT);
            when others then
                fatal('SQLCODE:' || sqlcode || ' SQLERRM:' || sqlerrm);
        end;
    end if;

    trc_dbms_output_pkg.log(
        i_trace_conf    => i_trace_conf
      , i_timestamp     => i_timestamp
      , i_level         => i_level
      , i_section       => i_section
      , i_user          => i_user
      , i_text          => l_text
    );

    trc_session_pkg.log(
        i_trace_conf    => i_trace_conf
      , i_timestamp     => i_timestamp
      , i_level         => i_level
      , i_text          => l_text
    );

    trc_table_pkg.log(
        i_trace_conf    => i_trace_conf
      , i_timestamp     => i_timestamp
      , i_level         => i_level
      , i_section       => i_section
      , i_user          => i_user
      , i_text          => i_param_text
      , i_entity_type   => nvl(i_entity_type, g_entity_type)
      , i_object_id     => nvl(i_object_id, g_object_id)
      , i_event_id      => i_event_id
      , i_label_id      => i_label_id
      , i_inst_id       => i_inst_id
      , i_session_id    => prc_api_session_pkg.get_session_id
      , i_thread_number => prc_api_session_pkg.get_thread_number
      , i_who_called    => i_who_called
      , i_trace_count   => i_trace_count
      , i_level_code    => i_level_code
      , i_text_mode     => i_text_mode
      , i_env_param1    => i_env_param1
      , i_env_param2    => i_env_param2
      , i_env_param3    => i_env_param3
      , i_env_param4    => i_env_param4
      , i_env_param5    => i_env_param5
      , i_env_param6    => i_env_param6
    );
end log;

function get_desc(
    i_env_param         in     com_api_type_pkg.t_full_desc
) return com_api_type_pkg.t_full_desc
is
begin
    return trc_text_pkg.get_desc(
               i_env_param  =>  i_env_param
           );
end get_desc;

procedure log(
    i_level             in      com_api_type_pkg.t_tiny_id
  , i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , o_text                 out  com_api_type_pkg.t_text
  , i_get_text          in      com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
  , o_id                   out  com_api_type_pkg.t_long_id
  , i_container_id      in      com_api_type_pkg.t_short_id         default null  -- It can be filled in Java modules.
  , o_param_text           out  com_api_type_pkg.t_text
) is
    l_section          com_api_type_pkg.t_full_desc;
    l_trace_conf       trc_config_pkg.trace_conf;
    l_use_dbms_output  com_api_type_pkg.t_boolean;
    l_label_id         com_api_type_pkg.t_short_id;
    l_text             com_api_type_pkg.t_text;
    l_param_text       com_api_type_pkg.t_text;
    l_who_called_me    com_api_type_pkg.t_name;
    l_container_id     com_api_type_pkg.t_short_id;
    l_exit_flag        com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE;
    l_old_container_id com_api_type_pkg.t_short_id;

    l_env_param1       com_api_type_pkg.t_full_desc;
    l_env_param2       com_api_type_pkg.t_name;
    l_env_param3       com_api_type_pkg.t_name;
    l_env_param4       com_api_type_pkg.t_name;
    l_env_param5       com_api_type_pkg.t_name;
    l_env_param6       com_api_type_pkg.t_name;
begin
    if i_container_id is not null then
        l_old_container_id := prc_api_session_pkg.get_container_id;
        prc_api_session_pkg.set_container_id(i_container_id => i_container_id);
    end if;

    l_container_id := prc_api_session_pkg.get_container_id;
    l_trace_conf   := trc_config_pkg.get_trace_conf(
                          i_container_id => l_container_id
                      );

    if l_trace_conf.log_mode != trc_config_pkg.LOG_MODE_ON_ERROR then
        if l_container_id is null then
            if i_level > l_trace_conf.trace_level then
                l_exit_flag := com_api_type_pkg.TRUE;

            end if;
        else
            if i_level > l_trace_conf.trace_level then
                l_exit_flag := com_api_type_pkg.TRUE;

            elsif g_trace_count > l_trace_conf.start_trace_size
                  and not i_level in (trc_config_pkg.ERROR
                                    , trc_config_pkg.FATAL)
            then
                l_exit_flag := com_api_type_pkg.TRUE;

            end if;
        end if;

    elsif i_level = trc_config_pkg.WARNING then
        if i_level > l_trace_conf.trace_level then
            l_exit_flag := com_api_type_pkg.TRUE;

        end if;
    end if;

    if l_exit_flag = com_api_type_pkg.TRUE then
        -- the log level or log size is not big enough: cancel the log
        return;
    end if;

    -- Incoming string parameters aren't checked for length restrictions of
    -- their data types, so that explicit check is strongly required
    l_text := substrb(i_text, 1, SIZEOF_T_TEXT);

    if l_trace_conf.log_mode = trc_config_pkg.LOG_MODE_ON_ERROR
       and i_level in (trc_config_pkg.INFO, trc_config_pkg.DEBUG)
       and g_trace_count > nvl(l_trace_conf.start_trace_size, -1)
    then
        l_param_text := l_text;
        l_env_param1 := i_env_param1;
        l_env_param2 := i_env_param2;
        l_env_param3 := i_env_param3;
        l_env_param4 := i_env_param4;
        l_env_param5 := i_env_param5;
        l_env_param6 := i_env_param6;
    else
        trc_text_pkg.get_text(
            i_level       =>  i_level
          , io_text       =>  l_text
          , i_env_param1  =>  i_env_param1
          , i_env_param2  =>  i_env_param2
          , i_env_param3  =>  i_env_param3
          , i_env_param4  =>  i_env_param4
          , i_env_param5  =>  i_env_param5
          , i_env_param6  =>  i_env_param6
          , i_get_text    =>  i_get_text
          , o_label_id    =>  l_label_id
          , o_param_text  =>  l_param_text
        );
    end if;

    -- calculating caller only if log_level is WARNING or superiorly
    if i_level in (trc_config_pkg.ERROR
                 , trc_config_pkg.FATAL
                 , trc_config_pkg.WARNING)
    then
        l_who_called_me := who_called_me;
        l_section := substrb(get_error_stack || chr(10) || 'Oracle:' || sqlerrm, 1, SIZEOF_T_FULL_DESC);
    -- save trace always if log_mode = 'Immediate saving'
    elsif l_trace_conf.log_mode is null
       or l_trace_conf.log_mode = trc_config_pkg.LOG_MODE_IMMEDIATE
    then
        l_section := substrb(get_error_stack || chr(10) || 'Oracle:' || sqlerrm, 1, SIZEOF_T_FULL_DESC);
    end if;
    -- get oracle user
    if g_oracle_user is null then
        g_oracle_user := user;
    end if;
    -- call the main log function
    log(
        i_trace_conf    => l_trace_conf
      , i_timestamp     => systimestamp
      , i_level         => trc_config_pkg.g_codes(i_level)
      , i_section       => l_section
      , i_user          => nvl(sys_context('USERENV', 'CLIENT_IDENTIFIER'), g_oracle_user)
      , i_text          => l_text
      , i_param_text    => l_param_text
      , i_label_id      => l_label_id
      , i_entity_type   => i_entity_type
      , i_object_id     => i_object_id
      , i_event_id      => i_event_id
      , i_inst_id       => i_inst_id
      , i_who_called    => l_who_called_me
      , i_trace_count   => g_trace_count
      , i_level_code    => i_level
      , i_text_mode     => i_get_text
      , i_env_param1    => l_env_param1
      , i_env_param2    => l_env_param2
      , i_env_param3    => l_env_param3
      , i_env_param4    => l_env_param4
      , i_env_param5    => l_env_param5
      , i_env_param6    => l_env_param6
    );

    -- The user can increase the value of "start_trace_size" then debug again from last count value
    g_trace_count := g_trace_count + 1;
    --
    o_text       := l_text;
    o_param_text := l_param_text;

    if i_container_id is not null then
        prc_api_session_pkg.set_container_id(i_container_id => l_old_container_id);
    end if;
exception
    when others then
        if i_container_id is not null then
            prc_api_session_pkg.set_container_id(i_container_id => l_old_container_id);
        end if;
        -- When exception during saving into TRC_LOG it is impossible to call com_api_error_pkg.raise_error()
        -- due to possible recursion.
        -- It is also assumed that exceptions e_application_error/e_fatal error are not possible in this procedure.
        l_use_dbms_output := l_trace_conf.use_dbms_output;
        l_trace_conf.use_dbms_output := com_api_const_pkg.TRUE; -- Enable DBMS output locally
        trc_dbms_output_pkg.log(
            i_trace_conf    => l_trace_conf
          , i_timestamp     => systimestamp
          , i_level         => i_level
          , i_section       => get_error_stack()
          , i_user          => nvl(sys_context('USERENV', 'CLIENT_IDENTIFIER'), g_oracle_user)
          , i_text          => sqlerrm
        );
        l_trace_conf.use_dbms_output := l_use_dbms_output;
        raise;
end log;

-- interface log functions
procedure debug(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , i_container_id      in      com_api_type_pkg.t_short_id         default null
) is
    l_text              com_api_type_pkg.t_text;
    l_param_text        com_api_type_pkg.t_text;
    l_id                com_api_type_pkg.t_long_id;
begin
    log(
        i_level         => trc_config_pkg.DEBUG
      , i_text          => i_text
      , i_env_param1    => i_env_param1
      , i_env_param2    => i_env_param2
      , i_env_param3    => i_env_param3
      , i_env_param4    => i_env_param4
      , i_env_param5    => i_env_param5
      , i_env_param6    => i_env_param6
      , i_entity_type   => i_entity_type
      , i_object_id     => i_object_id
      , i_event_id      => i_event_id
      , i_inst_id       => i_inst_id
      , o_text          => l_text
      , o_id            => l_id
      , i_container_id  => i_container_id
      , o_param_text    => l_param_text
    );
end debug;

procedure info(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , i_container_id      in      com_api_type_pkg.t_short_id         default null
) is
    l_text              com_api_type_pkg.t_text;
    l_param_text        com_api_type_pkg.t_text;
    l_id                com_api_type_pkg.t_long_id;
begin
    log(
        i_level         => trc_config_pkg.INFO
      , i_text          => i_text
      , i_env_param1    => i_env_param1
      , i_env_param2    => i_env_param2
      , i_env_param3    => i_env_param3
      , i_env_param4    => i_env_param4
      , i_env_param5    => i_env_param5
      , i_env_param6    => i_env_param6
      , i_entity_type   => i_entity_type
      , i_object_id     => i_object_id
      , i_event_id      => i_event_id
      , i_inst_id       => i_inst_id
      , o_text          => l_text
      , o_id            => l_id
      , i_container_id  => i_container_id
      , o_param_text    => l_param_text
    );
end info;

procedure warn(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , o_text                 out  com_api_type_pkg.t_text
  , o_id                   out  com_api_type_pkg.t_long_id
  , i_container_id      in      com_api_type_pkg.t_short_id         default null
  , o_param_text           out  com_api_type_pkg.t_text
) is
begin
    log(
        i_level         => trc_config_pkg.WARNING
      , i_text          => i_text
      , i_env_param1    => i_env_param1
      , i_env_param2    => i_env_param2
      , i_env_param3    => i_env_param3
      , i_env_param4    => i_env_param4
      , i_env_param5    => i_env_param5
      , i_env_param6    => i_env_param6
      , i_entity_type   => i_entity_type
      , i_object_id     => i_object_id
      , i_event_id      => i_event_id
      , i_inst_id       => i_inst_id
      , o_text          => o_text
      , i_get_text      => com_api_type_pkg.TRUE
      , o_id            => o_id
      , i_container_id  => i_container_id
      , o_param_text    => o_param_text
    );
end warn;

procedure warn(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , o_text                 out  com_api_type_pkg.t_text
  , o_id                   out  com_api_type_pkg.t_long_id
  , i_container_id      in      com_api_type_pkg.t_short_id         default null
) is
    l_param_text        com_api_type_pkg.t_text;
begin
    log(
        i_level         => trc_config_pkg.WARNING
      , i_text          => i_text
      , i_env_param1    => i_env_param1
      , i_env_param2    => i_env_param2
      , i_env_param3    => i_env_param3
      , i_env_param4    => i_env_param4
      , i_env_param5    => i_env_param5
      , i_env_param6    => i_env_param6
      , i_entity_type   => i_entity_type
      , i_object_id     => i_object_id
      , i_event_id      => i_event_id
      , i_inst_id       => i_inst_id
      , o_text          => o_text
      , i_get_text      => com_api_type_pkg.TRUE
      , o_id            => o_id
      , i_container_id  => i_container_id
      , o_param_text    => l_param_text
    );
end warn;

procedure warn(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , o_text                 out  com_api_type_pkg.t_text
  , i_container_id      in      com_api_type_pkg.t_short_id         default null
) is
    l_param_text        com_api_type_pkg.t_text;
    l_id                com_api_type_pkg.t_long_id;
begin
    log(
        i_level         => trc_config_pkg.WARNING
      , i_text          => i_text
      , i_env_param1    => i_env_param1
      , i_env_param2    => i_env_param2
      , i_env_param3    => i_env_param3
      , i_env_param4    => i_env_param4
      , i_env_param5    => i_env_param5
      , i_env_param6    => i_env_param6
      , i_entity_type   => i_entity_type
      , i_object_id     => i_object_id
      , i_event_id      => i_event_id
      , i_inst_id       => i_inst_id
      , o_text          => o_text
      , i_get_text      => com_api_type_pkg.TRUE
      , o_id            => l_id
      , i_container_id  => i_container_id
      , o_param_text    => l_param_text
    );
end warn;

procedure warn(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , i_container_id      in      com_api_type_pkg.t_short_id         default null
) is
    l_text              com_api_type_pkg.t_full_desc;
    l_param_text        com_api_type_pkg.t_text;
    l_id                com_api_type_pkg.t_long_id;
begin
    log(
        i_level         => trc_config_pkg.WARNING
      , i_text          => i_text
      , i_env_param1    => i_env_param1
      , i_env_param2    => i_env_param2
      , i_env_param3    => i_env_param3
      , i_env_param4    => i_env_param4
      , i_env_param5    => i_env_param5
      , i_env_param6    => i_env_param6
      , i_entity_type   => i_entity_type
      , i_object_id     => i_object_id
      , i_event_id      => i_event_id
      , i_inst_id       => i_inst_id
      , o_text          => l_text
      , o_id            => l_id
      , i_container_id  => i_container_id
      , o_param_text    => l_param_text
    );
end warn;

procedure error(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , o_text                 out  com_api_type_pkg.t_text
  , o_id                   out  com_api_type_pkg.t_long_id
  , i_container_id      in      com_api_type_pkg.t_short_id         default null
  , o_param_text           out  com_api_type_pkg.t_text
) is
begin
    log(
        i_level         => trc_config_pkg.ERROR
      , i_text          => i_text
      , i_env_param1    => i_env_param1
      , i_env_param2    => i_env_param2
      , i_env_param3    => i_env_param3
      , i_env_param4    => i_env_param4
      , i_env_param5    => i_env_param5
      , i_env_param6    => i_env_param6
      , i_entity_type   => i_entity_type
      , i_object_id     => i_object_id
      , i_event_id      => i_event_id
      , i_inst_id       => i_inst_id
      , o_text          => o_text
      , i_get_text      => com_api_type_pkg.TRUE
      , o_id            => o_id
      , i_container_id  => i_container_id
      , o_param_text    => o_param_text
    );
end error;

procedure error(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , o_text                 out  com_api_type_pkg.t_text
  , o_id                   out  com_api_type_pkg.t_long_id
  , i_container_id      in      com_api_type_pkg.t_short_id         default null
) is
    l_param_text        com_api_type_pkg.t_text;
begin
    log(
        i_level         => trc_config_pkg.ERROR
      , i_text          => i_text
      , i_env_param1    => i_env_param1
      , i_env_param2    => i_env_param2
      , i_env_param3    => i_env_param3
      , i_env_param4    => i_env_param4
      , i_env_param5    => i_env_param5
      , i_env_param6    => i_env_param6
      , i_entity_type   => i_entity_type
      , i_object_id     => i_object_id
      , i_event_id      => i_event_id
      , i_inst_id       => i_inst_id
      , o_text          => o_text
      , i_get_text      => com_api_type_pkg.TRUE
      , o_id            => o_id
      , i_container_id  => i_container_id
      , o_param_text    => l_param_text
    );
end error;

procedure error(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , o_text                 out  com_api_type_pkg.t_text
  , i_container_id      in      com_api_type_pkg.t_short_id         default null
) is
    l_param_text        com_api_type_pkg.t_text;
    l_id                com_api_type_pkg.t_long_id;
begin
    log(
        i_level         => trc_config_pkg.ERROR
      , i_text          => i_text
      , i_env_param1    => i_env_param1
      , i_env_param2    => i_env_param2
      , i_env_param3    => i_env_param3
      , i_env_param4    => i_env_param4
      , i_env_param5    => i_env_param5
      , i_env_param6    => i_env_param6
      , i_entity_type   => i_entity_type
      , i_object_id     => i_object_id
      , i_event_id      => i_event_id
      , i_inst_id       => i_inst_id
      , o_text          => o_text
      , i_get_text      => com_api_type_pkg.TRUE
      , o_id            => l_id
      , i_container_id  => i_container_id
      , o_param_text    => l_param_text
    );
end error;

procedure error(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , i_container_id      in      com_api_type_pkg.t_short_id         default null
) is
    l_text              com_api_type_pkg.t_text;
    l_param_text        com_api_type_pkg.t_text;
    l_id                com_api_type_pkg.t_long_id;
begin
    log(
        i_level         => trc_config_pkg.ERROR
      , i_text          => i_text
      , i_env_param1    => i_env_param1
      , i_env_param2    => i_env_param2
      , i_env_param3    => i_env_param3
      , i_env_param4    => i_env_param4
      , i_env_param5    => i_env_param5
      , i_env_param6    => i_env_param6
      , i_entity_type   => i_entity_type
      , i_object_id     => i_object_id
      , i_event_id      => i_event_id
      , i_inst_id       => i_inst_id
      , o_text          => l_text
      , o_id            => l_id
      , i_container_id  => i_container_id
      , o_param_text    => l_param_text
    );
end error;

procedure fatal(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , o_text                 out  com_api_type_pkg.t_text
  , i_container_id      in      com_api_type_pkg.t_short_id         default null
  , o_param_text           out  com_api_type_pkg.t_text
) is
    l_id                com_api_type_pkg.t_long_id;
begin
    log(
        i_level         => trc_config_pkg.FATAL
      , i_text          => i_text
      , i_env_param1    => i_env_param1
      , i_env_param2    => i_env_param2
      , i_env_param3    => i_env_param3
      , i_env_param4    => i_env_param4
      , i_env_param5    => i_env_param5
      , i_env_param6    => i_env_param6
      , i_entity_type   => i_entity_type
      , i_object_id     => i_object_id
      , i_event_id      => i_event_id
      , i_inst_id       => i_inst_id
      , o_text          => o_text
      , i_get_text      => com_api_type_pkg.TRUE
      , o_id            => l_id
      , i_container_id  => i_container_id
      , o_param_text    => o_param_text
    );
end fatal;

procedure fatal(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , o_text                 out  com_api_type_pkg.t_text
  , i_container_id      in      com_api_type_pkg.t_short_id         default null
) is
    l_param_text        com_api_type_pkg.t_text;
    l_id                com_api_type_pkg.t_long_id;
begin
    log(
        i_level         => trc_config_pkg.FATAL
      , i_text          => i_text
      , i_env_param1    => i_env_param1
      , i_env_param2    => i_env_param2
      , i_env_param3    => i_env_param3
      , i_env_param4    => i_env_param4
      , i_env_param5    => i_env_param5
      , i_env_param6    => i_env_param6
      , i_entity_type   => i_entity_type
      , i_object_id     => i_object_id
      , i_event_id      => i_event_id
      , i_inst_id       => i_inst_id
      , o_text          => o_text
      , i_get_text      => com_api_type_pkg.TRUE
      , o_id            => l_id
      , i_container_id  => i_container_id
      , o_param_text    => l_param_text
    );
end fatal;

procedure fatal(
    i_text              in      com_api_type_pkg.t_text
  , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
  , i_env_param2        in      com_api_type_pkg.t_name             default null
  , i_env_param3        in      com_api_type_pkg.t_name             default null
  , i_env_param4        in      com_api_type_pkg.t_name             default null
  , i_env_param5        in      com_api_type_pkg.t_name             default null
  , i_env_param6        in      com_api_type_pkg.t_name             default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
  , i_object_id         in      com_api_type_pkg.t_long_id          default null
  , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_tiny_id          default null
  , i_container_id      in      com_api_type_pkg.t_short_id         default null
) is
    l_text              com_api_type_pkg.t_full_desc;
    l_param_text        com_api_type_pkg.t_text;
    l_id                com_api_type_pkg.t_long_id;
begin
    log(
        i_level         => trc_config_pkg.FATAL
      , i_text          => i_text
      , i_env_param1    => i_env_param1
      , i_env_param2    => i_env_param2
      , i_env_param3    => i_env_param3
      , i_env_param4    => i_env_param4
      , i_env_param5    => i_env_param5
      , i_env_param6    => i_env_param6
      , i_entity_type   => i_entity_type
      , i_object_id     => i_object_id
      , i_event_id      => i_event_id
      , i_inst_id       => i_inst_id
      , o_text          => l_text
      , o_id            => l_id
      , i_container_id  => i_container_id
      , o_param_text    => l_param_text
    );
end fatal;

procedure wipe_by_level(
    i_level             in      com_api_type_pkg.t_tiny_id          default trc_config_pkg.DEBUG
) is
    l_level             com_api_type_pkg.t_dict_value;
begin
    if i_level > trc_config_pkg.OFF and i_level < trc_config_pkg.ALL_MSG then
        l_level :=
            case i_level
                when trc_config_pkg.DEBUG       then trc_api_const_pkg.TRACE_LEVEL_DEBUG
                when trc_config_pkg.INFO        then trc_api_const_pkg.TRACE_LEVEL_INFO
                when trc_config_pkg.WARNING     then trc_api_const_pkg.TRACE_LEVEL_WARNING
                when trc_config_pkg.ERROR       then trc_api_const_pkg.TRACE_LEVEL_ERROR
                when trc_config_pkg.FATAL       then trc_api_const_pkg.TRACE_LEVEL_FATAL
            end;

        delete /*+ first_rows parallel */ trc_log
         where trace_level = l_level;
        commit;
    else
        execute immediate 'truncate table trc_log';
    end if;
end wipe_by_level;

procedure reset_trace_count is
begin
    g_trace_count := DEFAULT_TRACE_COUNT;
end reset_trace_count;

end trc_log_pkg;
/
