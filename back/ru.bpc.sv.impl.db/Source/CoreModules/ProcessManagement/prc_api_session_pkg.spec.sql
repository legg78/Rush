create or replace package prc_api_session_pkg
as
/*
 * API for processes sessions <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 06.10.2009 <br />
 * Module: PRC_API_SESSION_PKG <br />
 * @headcom
 */

/*
 * Start session
 * @param i_container_id     The process of container identifier
 * @param io_session_id      Session process identifier
 * @param i_thread_number    Number of thread
 * @param i_main_session_id  Main session identifier
 */
procedure start_session (
    io_session_id           in out  com_api_type_pkg.t_long_id
  , i_process_id            in      com_api_type_pkg.t_short_id    default null
  , i_thread_number         in      com_api_type_pkg.t_tiny_id     default null
  , i_parent_session_id     in      com_api_type_pkg.t_long_id     default null
  , i_ip_address            in      com_api_type_pkg.t_name        default null
  , i_container_id          in      com_api_type_pkg.t_short_id    default null
  , i_inst_id               in      com_api_type_pkg.t_inst_id     default null
  , i_user_id               in      com_api_type_pkg.t_short_id    default null
);

/*
 * Stop session
 * @param i_result_code
 * @param i_processed   Number of processed records.
 * @param i_rejected    Number of rejected records.
 * @param i_execepted   Number of excepted records.
 */
procedure stop_session(
    i_result_code           in      com_api_type_pkg.t_dict_value
);

/*
 * Set Id session
 * i_session_id Session identifier
 */
procedure set_session_id( i_session_id in com_api_type_pkg.t_long_id );

/*
 * Return current session identifier
 * @return Session identifier
 */
function get_session_id return com_api_type_pkg.t_long_id;

/*
 * Get institution identifier for process
 * @return Institution identifier
 */
function get_inst_id return com_api_type_pkg.t_inst_id;

/*
 * Get the system configuration parallelism - the number of threads
 * @return number of threads
 */
function get_parallel_degree return com_api_type_pkg.t_tiny_id;

/*
 * Set current number of thread for process
 * @param i_thread_number Number of thread
 */
procedure set_thread_number( i_thread_number in com_api_type_pkg.t_tiny_id );

/*
 * Get thread number
 * @return Number of thread
 */
function get_thread_number return com_api_type_pkg.t_tiny_id;

/*
 * Set process identifier
 * @param i_prc_id Process identifier
 */
procedure set_process_id (
    i_process_id            in      com_api_type_pkg.t_short_id
);

/*
 * Get process identifier
 * @return Process identifier
 */
function get_process_id return com_api_type_pkg.t_short_id;

/*
 * Set container (parent) session identifier
 * @param i_parent_session_id Reference to parent session
 */
procedure set_parent_session_id(
    i_parent_session_id     in      com_api_type_pkg.t_long_id
);

/*
 * Get container (parent) session identifier
 * @return Reference to parent session
 */
function get_parent_session_id return com_api_type_pkg.t_long_id;

/*
 * Set id of container
 * @param i_container_id Reference to process container
 */

procedure set_container_id(
    i_container_id      in      com_api_type_pkg.t_long_id
);

/*
 * Return id of container
 * @return reference to  container id
 */

function get_container_id return com_api_type_pkg.t_short_id;

/*
 * Return name of procedure
 * @param i_prc_id Process identifier
 * @return column procedure_name
 */
function get_procedure_name(
    i_process_id            in      com_api_type_pkg.t_short_id     default null
) return com_api_type_pkg.t_name;

/*
 * Return type of procedure
 * @param i_prc_id Process identifier
 * @return flag 1/0 external/internal
 */

function get_process_type(
    i_process_id            in      com_api_type_pkg.t_short_id     default null
) return com_api_type_pkg.t_boolean;

/*
 * Set last use session time
 */
procedure set_session_last_use;

/*
 * Set session context by session_id for Camel Standalone module.
 */
procedure set_session_context(
    i_session_id            in      com_api_type_pkg.t_long_id
);

/*
 * Set "client_info" value for the v$session record of the current Oracle session.
 */
procedure set_client_info(
    i_session_id            in      com_api_type_pkg.t_long_id
  , i_thread_number         in      com_api_type_pkg.t_tiny_id
  , i_container_id          in      com_api_type_pkg.t_short_id
  , i_process_id            in      com_api_type_pkg.t_short_id
);

/*
 * Reset "client_info" value for the v$session record of the current Oracle session.
 */
procedure reset_client_info;

/*
 * Show error message when "Process in progress" in some Oracle session.
 */
procedure check_process_in_progress(
    i_process_id            in      com_api_type_pkg.t_short_id
  , i_session_id            in      com_api_type_pkg.t_long_id
);

end prc_api_session_pkg;
/
