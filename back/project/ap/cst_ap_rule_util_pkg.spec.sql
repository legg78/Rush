create or replace package cst_ap_rule_util_pkg is
/*********************************************************
*  Custom tags parsing  <br />
*  Created by Vasilyeva Y.(vasilieva@bpcsv.com)  at 21.06.2016 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: cst_sat_recon_upload <br />
*  @headcom
**********************************************************/

function get_auth_addl_data(
    i_addl_data_str             com_api_type_pkg.t_param_value
  , i_addl_data_tag             com_api_type_pkg.t_postal_code
  , i_addl_data_string_length   com_api_type_pkg.t_long_id    default null
)  return varchar2;
        
end cst_ap_rule_util_pkg;
/
