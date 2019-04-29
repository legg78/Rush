create or replace package acm_ui_component_state_pkg as
/********************************************************* 
 *  Interface for component states <br /> 
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 21.10.2011 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: acm_ui_component_state_pkg <br /> 
 *  @headcom 
 **********************************************************/ 
procedure add_state(
    i_user_id      in     com_api_type_pkg.t_short_id
  , i_component_id in     com_api_type_pkg.t_name
  , i_state        in     com_api_type_pkg.t_full_desc
);

procedure remove_state(
    i_user_id       in     com_api_type_pkg.t_short_id
  , i_component_id  in     com_api_type_pkg.t_name
);


end;
/
