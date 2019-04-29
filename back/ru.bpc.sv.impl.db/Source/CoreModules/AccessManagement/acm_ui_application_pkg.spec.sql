create or replace package acm_ui_application_pkg as
/********************************************************* 
 *  User management applications User Interface  <br /> 
 *  Created by Truschelev O. (truschelev@bpcbt.com) at 06.04.2018 <br /> 
 *  Last changed by $Author: truschelev $ <br /> 
 *  $LastChangedDate:: 2018-04-06 18:00:00 +0300#$ <br /> 
 *  Revision: $LastChangedRevision: 1 $ <br /> 
 *  Module: ACM_UI_APPLICATION_PKG <br /> 
 *  @headcom 
 **********************************************************/ 

function check_change_user_via_appl
    return com_api_type_pkg.t_boolean;

procedure create_application(
    io_appl_id          in out com_api_type_pkg.t_long_id
  , i_user_id           in     com_api_type_pkg.t_short_id
  , i_inst_command      in     com_api_type_pkg.t_dict_value  default null
  , i_user_inst_id      in     com_api_type_pkg.t_inst_id     default null
  , i_is_entirely       in     com_api_type_pkg.t_boolean     default null
  , i_is_inst_default   in     com_api_type_pkg.t_boolean     default null
  , i_agent_command     in     com_api_type_pkg.t_dict_value  default null
  , i_user_agent_id     in     com_api_type_pkg.t_agent_id    default null
  , i_is_agent_default  in     com_api_type_pkg.t_boolean     default null
  , i_role_command      in     com_api_type_pkg.t_dict_value  default null
  , i_user_role_id      in     com_api_type_pkg.t_tiny_id     default null
);

end acm_ui_application_pkg;
/
