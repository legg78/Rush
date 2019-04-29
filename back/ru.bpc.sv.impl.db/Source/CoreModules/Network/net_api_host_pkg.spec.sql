create or replace package net_api_host_pkg as
/**********************************************************
*  API for hosts <br />
*  Created by Fomichev A.(fomichev@bpcbt.com)  at 04.07.2012 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: net_api_host_pkg  <br />
*  @headcom
***********************************************************/

procedure get_host_param_value(
    i_param_name      in     com_api_type_pkg.t_name
  , i_host_member_id  in     com_api_type_pkg.t_tiny_id
  , o_param_value        out varchar2
);

procedure get_host_param_value(
    i_param_name      in     com_api_type_pkg.t_name
  , i_host_member_id  in     com_api_type_pkg.t_tiny_id
  , o_param_value        out number
);

procedure get_host_param_value(
    i_param_name      in     com_api_type_pkg.t_name
  , i_host_member_id  in     com_api_type_pkg.t_tiny_id
  , o_param_value        out date
);

end;
/
