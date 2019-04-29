create or replace package prc_ui_run_pkg as
/**************************************************************
 * API for run process <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 19.11.2009 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision:: $LastChangedRevision$ <br />
 * Module: PRC_API_RUN_PKG <br />
 * @headcom
 **************************************************************/


/*
 * Preparations for the launch of the process
 * @param i_container_id     Process of containers identifier
 * @param i_session_id       Session identifier
 * @param i_thread_number    Number of thread
 * @param io_main_session_id Main container session identifier
 */
procedure before_process (
    i_process_id            in      com_api_type_pkg.t_short_id
  , io_session_id           in out  com_api_type_pkg.t_long_id
  , i_thread_number         in      com_api_type_pkg.t_tiny_id      default 1
  , i_parent_session_id     in      com_api_type_pkg.t_long_id
  , i_eff_date              in      date                            default null
  , o_resp_code                out  com_api_type_pkg.t_boolean
  , o_error_desc               out  com_api_type_pkg.t_text
  , i_container_id          in      com_api_type_pkg.t_short_id     default null
);

/*
 * Run container
 * @param i_container_prc_id References to container process identifier
 * @param o_main_session_id  Main session identifier
 */  
procedure run_container (
    i_process_id            in      com_api_type_pkg.t_short_id
  , i_eff_date              in      date                            default null
  , i_parent_id             in      com_api_type_pkg.t_long_id      default null
  , o_session_id               out  com_api_type_pkg.t_long_id
);

/*
 * Run process
 * @param i_session_id    Session identifier
 * @param i_thread_number Number of thread
*/  
procedure run_process (
    i_session_id            in      com_api_type_pkg.t_long_id
  , i_thread_number         in      com_api_type_pkg.t_tiny_id
  , i_container_id          in      com_api_type_pkg.t_short_id
  , i_session_file_id       in      com_api_type_pkg.t_long_id      default null
  , i_param_tab             in      com_param_map_tpt
  , i_eff_date              in      date                            default null
  , i_oracle_trace_level    in      com_api_type_pkg.t_tiny_id      default null
  , i_trace_thread_number   in      com_api_type_pkg.t_tiny_id      default null
);

/*
 * The final processing of the results
 * @param i_session _id Session identifier
 * @param i_result_code Return result code
 */  
procedure after_process (
    i_session_id            in      com_api_type_pkg.t_long_id
  , i_result_code           in      com_api_type_pkg.t_dict_value
  , o_resp_code                out  com_api_type_pkg.t_boolean
  , i_container_id          in      com_api_type_pkg.t_short_id     default null
);

/*
 * Function returns id of incoming file in case when process should process only one incoming file
 * @return  Session file identifier
 */  
function get_session_file_id return com_api_type_pkg.t_long_id;

/*
 * Function returns parameter list for current process
 * @return  Parameter list
 */  
function get_param_tab return com_param_map_tpt;

end prc_ui_run_pkg;
/
