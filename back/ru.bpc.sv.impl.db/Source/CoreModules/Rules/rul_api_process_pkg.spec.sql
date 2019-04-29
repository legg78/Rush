create or replace package rul_api_process_pkg is
/********************************************************* 
 *  Acquiring application API  <br /> 
 *  Created by Khougaev A.(khougaev@bpcbt.com)  at 21.01.2010 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: rul_api_process_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 

type t_rule_rec is record (
    proc_name       com_api_type_pkg.t_name
  , rule_id         com_api_type_pkg.t_short_id
  , proc_id         com_api_type_pkg.t_tiny_id
  , param_name      com_api_type_pkg.t_name
  , param_value     com_api_type_pkg.t_name
  , is_mandatory    com_api_type_pkg.t_boolean
  , param_id        com_api_type_pkg.t_short_id
);
type t_rule_tab is table of t_rule_rec index by binary_integer;

procedure execute_rule_set (
    i_rule_set_id   in            com_api_type_pkg.t_tiny_id
  , o_rules_count      out        number
  , io_params       in out nocopy com_api_type_pkg.t_param_tab
);

function get_rule_tab(
    i_rule_set_id   in            com_api_type_pkg.t_tiny_id
) return t_rule_tab result_cache;

end;
/
