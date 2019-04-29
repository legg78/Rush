create or replace package app_api_dispute_pkg as
/**************************************************
 *  Dispute application API <br />
 *  Created by Alalykin A.(alalykin@bpcbt.com) at 15.11.2016 <br />
 *  Module: APP_API_DISPUTE_PKG <br />
 *  @headcom
 ***************************************************/

procedure determine_user(
    i_flow_id                  in     com_api_type_pkg.t_tiny_id
  , i_appl_status              in     com_api_type_pkg.t_dict_value
  , i_reject_code              in     com_api_type_pkg.t_dict_value
  , o_user_id                     out com_api_type_pkg.t_short_id
);

/*
 * Find element DUE_DATE in the specified application and update its value with a new one,
 * add new element if it doesn't exist
 */
procedure set_due_date(
    i_appl_id                  in     com_api_type_pkg.t_long_id
  , i_due_date                 in     date
);

end;
/
