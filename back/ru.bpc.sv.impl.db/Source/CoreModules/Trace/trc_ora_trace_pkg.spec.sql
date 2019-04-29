create or replace package trc_ora_trace_pkg as
/*********************************************************
 *  API for Oracle trace file <br />
 *  Created by Truschelev O.(truschelev@bpcbt.com)  at 20.02.2016 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: trc_ora_trace_pkg <br />
 *  @headcom
 **********************************************************/

-- Get cached value of Oracle function USER.
function get_oracle_user return com_api_type_pkg.t_name;

-- Get trace level for specified Oracle session.
function get_trace_level(
    i_sid            in    com_api_type_pkg.t_long_id
  , i_serial         in    com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_tiny_id;

-- Get trace information by "session_id" and "thread_number" values.
procedure get_trace_info(
    i_session_id     in    com_api_type_pkg.t_long_id
  , i_thread_number  in    com_api_type_pkg.t_tiny_id
  , o_sid           out    com_api_type_pkg.t_long_id
  , o_serial        out    com_api_type_pkg.t_long_id
  , o_trace_path    out    com_api_type_pkg.t_full_desc
  , o_trace_file    out    com_api_type_pkg.t_name
);

-- Get last message for the oracle tracing actions.
function get_trace_message(
    i_session_id               in     com_api_type_pkg.t_long_id
  , i_thread_number            in     com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_full_desc;

-- Save trace information into special record in trc_log for current "session_id" and "thread_number" values.
procedure save_trace_info;

-- Enable the oracle tracing.
procedure enable_trace(
    i_trace_level              in     com_api_type_pkg.t_tiny_id
  , i_trace_current_session    in     com_api_type_pkg.t_boolean
  , i_session_id               in     com_api_type_pkg.t_long_id    default null
  , i_thread_number            in     com_api_type_pkg.t_tiny_id    default null
);

-- Disable the oracle tracing.
procedure disable_trace(
    i_trace_current_session    in    com_api_type_pkg.t_boolean
  , i_session_id               in    com_api_type_pkg.t_long_id    default null
  , i_thread_number            in    com_api_type_pkg.t_tiny_id    default null
);

-- Check and enable the oracle tracing during the process start.
procedure check_tracing_on_start(
    i_oracle_trace_level    in      com_api_type_pkg.t_tiny_id
  , i_thread_number         in      com_api_type_pkg.t_tiny_id
  , i_trace_thread_number   in      com_api_type_pkg.t_tiny_id
);

-- Get trace level for specified SV session.
function get_session_trace_level(
    i_session_id     in    com_api_type_pkg.t_long_id
  , i_thread_number  in    com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_tiny_id;

end;
/
