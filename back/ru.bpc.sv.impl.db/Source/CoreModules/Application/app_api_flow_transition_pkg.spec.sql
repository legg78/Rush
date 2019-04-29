create or replace package app_api_flow_transition_pkg as
/*********************************************************
 *  Flow transition application API  <br />
 *  Created by Gogolev I.(i.gogolev@bpcbt.com)  at 12.01.2018 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: app_api_flow_transition_pkg <br />
 *  @headcom
 **********************************************************/
function check_available_transition(
    i_appl_id               in            com_api_type_pkg.t_long_id
  , i_flow_id               in            com_api_type_pkg.t_tiny_id        default null
  , i_new_appl_status       in            com_api_type_pkg.t_dict_value     default null
  , i_new_reject_code       in            com_api_type_pkg.t_dict_value     default null
  , i_old_appl_status       in            com_api_type_pkg.t_dict_value     default null
  , i_old_reject_code       in            com_api_type_pkg.t_dict_value     default null
) return com_api_type_pkg.t_boolean;

procedure get_new_transition_data(
    i_flow_id               in            com_api_type_pkg.t_tiny_id
  , i_old_appl_status       in            com_api_type_pkg.t_dict_value
  , i_old_reject_code       in            com_api_type_pkg.t_dict_value     default null
  , i_reason_code           in            com_api_type_pkg.t_dict_value     default null
  , io_new_appl_status      in out        com_api_type_pkg.t_dict_value
  , io_new_reject_code      in out        com_api_type_pkg.t_dict_value
  , io_event_type           in out        com_api_type_pkg.t_dict_value
);

end app_api_flow_transition_pkg;
/
