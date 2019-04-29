create or replace package body trc_config_pkg is
/**
* Core Trace module is assigned to track user's actions in system
* and collect debuging information.
* Package trc_config_pkg consist procedures for configuring
* trace level in whole system or in single module.
* NOTE: methods set_trace_conf() and init_cache() are obsolete
* because of current realization of function get_trace_conf().
*
  Created by Filimonov A.(filimonov@bpc.ru)  at 02.07.2009 <br />
  Last changed by $Author$ <br />
  $LastChangedDate::                           $ <br />
  Revision: $LastChangedRevision$ <br />
  Module: TRC_CONFIG_PKG <br />
* @headcom
*/

g_trace_conf      trace_conf;
g_session_id      com_api_type_pkg.t_long_id;
g_container_id    com_api_type_pkg.t_short_id;

function get_trace_conf(
    i_container_id  com_api_type_pkg.t_short_id  default null
)
return trace_conf
is
    l_trace_level   com_api_type_pkg.t_tiny_id;
begin
    if nvl(g_session_id, -1)      !=  nvl(prc_api_session_pkg.get_session_id, -1)
       or nvl(g_container_id, -1) !=  nvl(i_container_id, -1)
    then
        if i_container_id is not null then
            select trace_level
                 , debug_writing_mode
                 , start_trace_size
                 , error_trace_size
              into l_trace_level
                 , g_trace_conf.log_mode
                 , g_trace_conf.start_trace_size
                 , g_trace_conf.error_trace_size
              from prc_container
              where id = i_container_id;
        end if;

        if l_trace_level is not null then
            g_trace_conf.trace_level      := l_trace_level;
            g_trace_conf.use_table        := DEFAULT_TABLE;
            g_trace_conf.use_session      := DEFAULT_SESSION;
            g_trace_conf.use_dbms_output  := DEFAULT_DBMS_OUTPUT;
            g_trace_conf.log_mode         := nvl(g_trace_conf.log_mode, DEFAULT_LOG_MODE);

            if g_trace_conf.log_mode != trc_config_pkg.LOG_MODE_ON_ERROR then
                g_trace_conf.error_trace_size := null;
            end if;
        else
            g_trace_conf.trace_level      := nvl(set_ui_value_pkg.get_user_param_n(i_param_name => 'TRACE_LEVEL'),       DEFAULT_LEVEL);
            g_trace_conf.use_table        := nvl(set_ui_value_pkg.get_user_param_n(i_param_name => 'TRACE_TABLE'),       DEFAULT_TABLE);
            g_trace_conf.use_session      := nvl(set_ui_value_pkg.get_user_param_n(i_param_name => 'TRACE_SESSION'),     DEFAULT_SESSION);
            g_trace_conf.use_dbms_output  := nvl(set_ui_value_pkg.get_user_param_n(i_param_name => 'TRACE_DBMS_OUTPUT'), DEFAULT_DBMS_OUTPUT);
            g_trace_conf.log_mode         := nvl(set_ui_value_pkg.get_user_param_v(i_param_name => 'LOG_MODE'),          DEFAULT_LOG_MODE);
            g_trace_conf.start_trace_size := null;
            g_trace_conf.error_trace_size := null;
        end if;

        g_session_id   := prc_api_session_pkg.get_session_id;
        g_container_id := i_container_id;
    end if;
    return g_trace_conf;
end;

/**
* Set trace configuration for named section.
* If section not defined create new record of configuration in cache
*
* It is OBSOLETE because of current realization of function get_trace_conf().
* Function get_trace_conf() always rewrites global package body's
* record g_trace_conf, so its modifying is purposeless.
*/
procedure set_trace_conf(
    io_trace_conf        in out  trace_conf
) is
begin
    g_trace_conf := io_trace_conf;
end;

/**
* Initialization of trace level settings and caching.
*
* It is OBSOLETE because of current realization of function get_trace_conf().
* Function get_trace_conf() always rewrites global package body's
* record g_trace_conf, so its modifying is purposeless.
*/
procedure init_cache is
begin
    if g_trace_conf.trace_level is null then
        g_trace_conf.trace_level     := nvl(set_ui_value_pkg.get_user_param_n(i_param_name => 'TRACE_LEVEL'),       DEFAULT_LEVEL);
    end if;
    if g_trace_conf.use_table is null then
        g_trace_conf.use_table       := nvl(set_ui_value_pkg.get_user_param_n(i_param_name => 'TRACE_TABLE'),       DEFAULT_TABLE);
    end if;
    if g_trace_conf.use_session is null then
        g_trace_conf.use_session     := nvl(set_ui_value_pkg.get_user_param_n(i_param_name => 'TRACE_SESSION'),     DEFAULT_SESSION);
    end if;
    if g_trace_conf.use_dbms_output is null then
        g_trace_conf.use_dbms_output := nvl(set_ui_value_pkg.get_user_param_n(i_param_name => 'TRACE_DBMS_OUTPUT'), DEFAULT_DBMS_OUTPUT);
    end if;
    if g_trace_conf.log_mode is null then
        g_trace_conf.log_mode        := nvl(set_ui_value_pkg.get_user_param_v(i_param_name => 'LOG_MODE'),          DEFAULT_LOG_MODE);
    end if;
end;

/**
* Check that the "Debug" mode is enabled.
*/
function is_debug return com_api_type_pkg.t_boolean
is
    l_container_id     com_api_type_pkg.t_short_id;
    l_trace_conf       trc_config_pkg.trace_conf;
begin
    l_container_id := prc_api_session_pkg.get_container_id;
    l_trace_conf   := trc_config_pkg.get_trace_conf(
                          i_container_id => l_container_id
                      );

    if l_trace_conf.trace_level = trc_config_pkg.DEBUG then
        return com_api_type_pkg.TRUE;
    end if;

    return com_api_type_pkg.FALSE;
end;

begin
    g_codes.delete;
    g_codes(OFF)      := 'OFF';
    g_codes(FATAL)    := trc_api_const_pkg.TRACE_LEVEL_FATAL;
    g_codes(ERROR)    := trc_api_const_pkg.TRACE_LEVEL_ERROR;
    g_codes(WARNING)  := trc_api_const_pkg.TRACE_LEVEL_WARNING;
    g_codes(INFO)     := trc_api_const_pkg.TRACE_LEVEL_INFO;
    g_codes(DEBUG)    := trc_api_const_pkg.TRACE_LEVEL_DEBUG;
    g_codes(ALL_MSG)  := 'ALL';

end;
/
