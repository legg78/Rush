create or replace package app_api_error_pkg as
/*********************************************************
*  Application error <br />
*  Created by Filimonov A.(filimonov@bpc.ru)  at 09.09.2009 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                          $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: app_api_error_pkg <br />
*  @headcom
**********************************************************/

g_app_errors  app_api_type_pkg.t_app_error_tab;

procedure add_error_element(
    i_appl_id           in      com_api_type_pkg.t_long_id
  , i_error_code        in      com_api_type_pkg.t_name
  , i_error_message     in      com_api_type_pkg.t_full_desc
  , i_error_details     in      com_api_type_pkg.t_full_desc
  , i_error_element     in      com_api_type_pkg.t_name
);

procedure add_errors_to_app_data;

procedure intercept_error(
    i_appl_data_id      in      com_api_type_pkg.t_long_id
  , i_element_name      in      com_api_type_pkg.t_name
  , i_parent_id         in      com_api_type_pkg.t_long_id    default null
);

procedure raise_error(
    i_appl_data_id      in      com_api_type_pkg.t_long_id
  , i_error             in      com_api_type_pkg.t_name
  , i_env_param1        in      com_api_type_pkg.t_full_desc  default null
  , i_env_param2        in      com_api_type_pkg.t_name       default null
  , i_env_param3        in      com_api_type_pkg.t_name       default null
  , i_env_param4        in      com_api_type_pkg.t_name       default null
  , i_env_param5        in      com_api_type_pkg.t_name       default null
  , i_env_param6        in      com_api_type_pkg.t_name       default null
  , i_element_name      in      com_api_type_pkg.t_name       default null
  , i_appl_id           in      com_api_type_pkg.t_long_id    default null
  , i_parent_id         in      com_api_type_pkg.t_long_id    default null
);

procedure raise_fatal_error(
    i_appl_data_id      in      com_api_type_pkg.t_long_id
  , i_error             in      com_api_type_pkg.t_name
  , i_env_param1        in      com_api_type_pkg.t_full_desc  default null
  , i_env_param2        in      com_api_type_pkg.t_name       default null
  , i_env_param3        in      com_api_type_pkg.t_name       default null
  , i_env_param4        in      com_api_type_pkg.t_name       default null
  , i_env_param5        in      com_api_type_pkg.t_name       default null
  , i_env_param6        in      com_api_type_pkg.t_name       default null
  , i_element_name      in      com_api_type_pkg.t_name       default null
  , i_appl_id           in      com_api_type_pkg.t_long_id    default null
  , i_parent_id         in      com_api_type_pkg.t_long_id    default null
);

procedure add_error_element(
    i_appl_data_id      in      com_api_type_pkg.t_long_id
  , i_error_code        in      com_api_type_pkg.t_name
  , i_error_message     in      com_api_type_pkg.t_full_desc
  , i_error_details     in      com_api_type_pkg.t_full_desc
  , i_error_element     in      com_api_type_pkg.t_name
);

procedure remove_error_elements(
    i_appl_id           in      com_api_type_pkg.t_long_id
  , i_skip_saver_errors in      com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
);

end app_api_error_pkg;
/
