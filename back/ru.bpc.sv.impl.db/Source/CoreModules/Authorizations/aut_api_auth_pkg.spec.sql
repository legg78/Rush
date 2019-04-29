create or replace package aut_api_auth_pkg is
/*********************************************************
 *  Authorization API <br />
 *  Created by Shalnov N. (shalnov@bpcbt.com) at 10.09.2018 <br />
 *  Module: aut_api_auth_pkg <br />
 *  @headcom
 **********************************************************/

function get_auth(
    i_id                    in     com_api_type_pkg.t_long_id
  , i_mask_error            in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
) return aut_api_type_pkg.t_auth_rec;

procedure save_auth(
    i_auth                  in     aut_api_type_pkg.t_auth_rec
);

procedure save_auth(
    i_auth_tab              in     auth_data_tpt
);

end;
/
