create or replace package app_ui_dispute_pkg as
/**************************************************
 *  Dispute application UI API <br />
 *  Created by Alalykin A.(alalykin@bpcbt.com) at 15.11.2016 <br />
 *  Module: APP_UI_DISPUTE_PKG <br />
 *  @headcom
 ***************************************************/

procedure determine_user(
    i_appl_id                  in     com_api_type_pkg.t_long_id
  , o_user_id                     out com_api_type_pkg.t_short_id
);

procedure change_visibility(
    i_appl_id                  in     com_api_type_pkg.t_long_id
  , i_is_visible               in     com_api_type_pkg.t_boolean
);

end;
/
