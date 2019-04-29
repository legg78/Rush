create or replace package trc_config_pkg is
/**
* Core Trace module is assigned to track user's actions in system
* and collect debuging information.
* Package trc_config_pkg consist procedures for configuring
* trace level in whole system or in single module.
*
  Created by Filimonov A.(filimonov@bpc.ru)  at 02.07.2009 <br />
  Last changed by $Author$ <br />
  $LastChangedDate::                           $ <br />
  Revision: $LastChangedRevision$ <br />
  Module: TRC_CONFIG_PKG <br />
* @headcom
*/


/**
* Constant described level with no tracing
*/
OFF                           constant pls_integer      := 1;

/**
* Constant described level with tracing only fatal errors
*/
FATAL                         constant pls_integer      := 2;

/**
* Constant described level with tracing errors and fatal errors
*/
ERROR                         constant pls_integer      := 3;

/**
* Constant described level with tracing warning and lower levels messages
*/
WARNING                       constant pls_integer      := 4;

/**
* Constant described level with tracing info messages and lower levels messages
*/
INFO                          constant pls_integer      := 5;

/**
* Constant described level with tracing debug messages and lower levels messages
*/
DEBUG                         constant pls_integer      := 6;

/**
* Constant described level with tracing all levels messages
*/
ALL_MSG                       constant pls_integer      := 7;

/**
* Default trace level
*/
DEFAULT_LEVEL                 constant com_api_type_pkg.t_tiny_id := trc_config_pkg.ERROR;

/**
* True default value for logging in table
*/
DEFAULT_TABLE                 constant com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE;

/**
* If default_dbms_output is true the log is sent in standard output (dbms_output.put_line)
*/
DEFAULT_DBMS_OUTPUT           constant com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;

/**
* If default_session is true the log is written in the view v$session
*/
DEFAULT_SESSION               constant com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;

/**
* Logging modes
*/
LOG_MODE_IMMEDIATE            constant com_api_type_pkg.t_dict_value := 'LGMDIMDT';
LOG_MODE_ON_ERROR             constant com_api_type_pkg.t_dict_value := 'LGMDNRRR';
LOG_MODE_SUSPENDED            constant com_api_type_pkg.t_dict_value := 'LGMDSSPD';

/**
* True default value for logging mode = "On Error"
*/
DEFAULT_LOG_MODE              constant com_api_type_pkg.t_dict_value := LOG_MODE_IMMEDIATE;
/**
* True default size of log buffer for LOG_MODE = "Suspend recording"
*/
LOG_BUFFER_SIZE               constant com_api_type_pkg.t_byte_id    := 100;

/**
* Use for build a string section
*/
DEFAULT_SECTION_SEP           constant varchar2(10)   := '.';

/**
* Formats output sent to dbms_output to this width.
*/
DEFAULT_DBMS_OUTPUT_WRAP      constant number         := 100;

/**
* Trace log record type
*/
type trace_conf is record (
    trace_level         com_api_type_pkg.t_tiny_id
  , use_table           com_api_type_pkg.t_boolean
  , use_dbms_output     com_api_type_pkg.t_boolean
  , use_session         com_api_type_pkg.t_boolean
  , dbms_output_wrap    pls_integer
  , log_mode            com_api_type_pkg.t_dict_value
  , start_trace_size    com_api_type_pkg.t_short_id
  , error_trace_size    com_api_type_pkg.t_short_id
);

/**
* Type of descriptions list of trace levels
*/
type t_code_table is table of com_api_type_pkg.t_dict_value index by binary_integer;

/**
* Descriptions list of trace levels
*/
g_codes t_code_table;

/**
* Initialization of trace level settings and caching.
*
* It is OBSOLETE because of current realization of function get_trace_conf().
* Function get_trace_conf() always rewrites global package body's
* record g_trace_conf, so its modifying is purposeless.
*/
procedure init_cache;

/**
* Get trace configuration in current module if not exists return ROOT
* configuration settings
*
* @param p_log_name Name of trace section if null get section from call stack
* @return record of configuration structure
*/
function get_trace_conf(
    i_container_id  com_api_type_pkg.t_short_id  default null
) return trace_conf;

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
);

/**
* Check that the "Debug" mode is enabled.
*/
function is_debug return com_api_type_pkg.t_boolean;

end;
/
