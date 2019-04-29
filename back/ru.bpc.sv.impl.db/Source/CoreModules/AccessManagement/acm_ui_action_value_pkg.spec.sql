create or replace package acm_ui_action_value_pkg as
/*********************************************************
*  UI for menu action values  <br />
*  Created by Krukov E.(krukov@bpcsv.com)  at 15.06.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: ACM_UI_ACTION_VALUE_PKG <br />
*  @headcom
**********************************************************/

procedure add(
    o_id                   out  com_api_type_pkg.t_short_id
  , i_action_id         in      com_api_type_pkg.t_tiny_id
  , i_param_id          in      com_api_type_pkg.t_short_id
  , i_param_value       in      com_api_type_pkg.t_name
  , i_param_function    in      com_api_type_pkg.t_name
);

procedure modify(
    i_id                in      com_api_type_pkg.t_short_id
  , i_action_id         in      com_api_type_pkg.t_tiny_id
  , i_param_id          in      com_api_type_pkg.t_short_id
  , i_param_value       in      com_api_type_pkg.t_name
  , i_param_function    in      com_api_type_pkg.t_name
);

procedure remove(
    i_id                in      com_api_type_pkg.t_short_id
);

end acm_ui_action_value_pkg;
/
