create or replace package body app_ui_dispute_pkg as
/**************************************************
 *  Dispute application UI API <br />
 *  Created by Alalykin A.(alalykin@bpcbt.com) at 15.11.2016 <br />
 *  Module: APP_UI_DISPUTE_PKG <br />
 *  @headcom
 ***************************************************/

procedure determine_user(
    i_appl_id                  in     com_api_type_pkg.t_long_id
  , o_user_id                     out com_api_type_pkg.t_short_id
) is
    l_application                     app_api_type_pkg.t_application_rec;
begin
    l_application := app_api_application_pkg.get_application(i_appl_id => i_appl_id);

    if l_application.id is not null then
        app_api_dispute_pkg.determine_user(
            i_flow_id      => l_application.flow_id
          , i_appl_status  => l_application.appl_status
          , i_reject_code  => l_application.reject_code
          , o_user_id      => o_user_id
        );
    end if;
end determine_user;

procedure change_visibility(
    i_appl_id                  in     com_api_type_pkg.t_long_id
  , i_is_visible               in     com_api_type_pkg.t_boolean
) is
begin
    update app_application_vw
       set is_visible          = i_is_visible
     where id                  = i_appl_id
       and nvl(is_visible, 2) != nvl(i_is_visible, 3);

end change_visibility;

end;
/
