create or replace package body acm_ui_action_value_pkg as
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
) is
begin
    o_id     := acm_action_value_seq.nextval;

    insert into acm_action_value_vw(
        id
      , action_id
      , param_id
      , param_value
      , param_function
    ) values (
        o_id
      , i_action_id
      , i_param_id
      , i_param_value
      , i_param_function
    );

end add;

procedure modify(
    i_id                in      com_api_type_pkg.t_short_id
  , i_action_id         in      com_api_type_pkg.t_tiny_id
  , i_param_id          in      com_api_type_pkg.t_short_id
  , i_param_value       in      com_api_type_pkg.t_name
  , i_param_function    in      com_api_type_pkg.t_name
) is
begin
    update
        acm_action_value_vw a
    set
        a.action_id = i_action_id
      , a.param_id = i_param_id
      , a.param_value = i_param_value
      , a.param_function = i_param_function
    where
        a.id = i_id;

end modify;

procedure remove(
    i_id                in      com_api_type_pkg.t_short_id
) is
begin

    delete from 
        acm_action_value_vw a
    where a.id = i_id;

end remove;

end acm_ui_action_value_pkg;
/
