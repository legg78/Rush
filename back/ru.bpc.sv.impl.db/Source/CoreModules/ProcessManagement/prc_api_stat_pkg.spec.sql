create or replace package prc_api_stat_pkg is
/****************************************************************
 * The API for statistics processes <br />
 * Created by Khougaev A.(khougaev@bpc.ru)  at 06.10.2009 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PRC_API_STAT_PKG <br />
 * @headcom
 ****************************************************************/

/* Start logging */
  procedure log_start;

/* Save estimation count record 
 * @param i_estimated_count Estimated count record
 */
  procedure log_estimation (
      i_estimated_count           in       com_api_type_pkg.t_long_id
    , i_measure                   in       com_api_type_pkg.t_dict_value := null
  );

/*
 * Save the current number of rows processed successfully.
 * @param i_current_row     Number of rows
 * @param i_excepted_count  Number of excepted records
 */  
  procedure log_current (
      i_current_count             in       com_api_type_pkg.t_long_id
    , i_excepted_count            in       com_api_type_pkg.t_long_id
  );

/*
 * Increase the current number of rows processed successfully
 * @param i_current_row Number of rows
 * @param i_excepted_count  Number of excepted records
 */  
  procedure increase_current (
      i_current_count             in       com_api_type_pkg.t_long_id
    , i_excepted_count            in       com_api_type_pkg.t_long_id
  );

  procedure log_end (
      i_processed_total           in       com_api_type_pkg.t_long_id := null
    , i_excepted_total            in       com_api_type_pkg.t_long_id := null
    , i_rejected_total            in       com_api_type_pkg.t_long_id := null
    , i_result_code               in       com_api_type_pkg.t_dict_value
  );

/*
 * Check result process.
 */  
  procedure check_error_limit;


  procedure change_thread_status (
      i_session_id               in       com_api_type_pkg.t_long_id
    , i_thread_number            in       com_api_type_pkg.t_tiny_id
    , i_result_code              in       com_api_type_pkg.t_dict_value
  );

  procedure increase_rejected_total (
      i_session_id               in       com_api_type_pkg.t_long_id
    , i_thread_number            in       com_api_type_pkg.t_tiny_id
    , i_rejected_total           in       com_api_type_pkg.t_long_id
  );
  
end prc_api_stat_pkg;
/
