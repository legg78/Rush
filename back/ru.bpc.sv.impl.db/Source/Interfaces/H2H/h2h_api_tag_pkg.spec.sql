create or replace package h2h_api_tag_pkg as
/*********************************************************
 *  Host-to-host tag API <br />
 *  Created by Alalykin A.(alalykin@bpcbt.com) at 20.02.2019 <br />
 *  Module: H2H_API_TAG_PKG <br />
 *  @headcom
 **********************************************************/

procedure add_tag_value(
    io_tag_value_tab        in out nocopy  h2h_api_type_pkg.t_h2h_tag_value_tab
  , i_tag_id                in             com_api_type_pkg.t_short_id
  , i_tag_value             in             com_api_type_pkg.t_full_desc
);

procedure save_tag_value(
    i_fin_id                in            com_api_type_pkg.t_long_id
  , io_tag_value_tab        in out nocopy h2h_api_type_pkg.t_h2h_tag_value_tab
);

/*
 * Copy values of fin. message fields to tag collection in according to reference H2H_TAG and incoming IPS code.
 */
procedure collect_tags(
    i_fin_id                in            com_api_type_pkg.t_long_id
  , i_ips_fin_fields        in            com_api_type_pkg.t_param_tab
  , i_ips_code              in            com_api_type_pkg.t_module_code
  , o_tag_value_tab            out        h2h_api_type_pkg.t_h2h_tag_value_tab
);

/*
 * Save values of fin. message fields to tag values table in according to reference H2H_TAG and incoming IPS code.
 */
procedure save_tag_value(
    i_fin_id                in            com_api_type_pkg.t_long_id
  , i_ips_fin_fields        in            com_api_type_pkg.t_param_tab
  , i_ips_code              in            com_api_type_pkg.t_module_code
);

/*
 * Return collection of auth (FE) tag values by incoming collection of H2H tag values.
 */
procedure get_auth_tag_value(
    io_tag_value_tab        in out nocopy h2h_api_type_pkg.t_h2h_tag_value_tab
  , o_auth_tag_value_tab       out        aup_api_type_pkg.t_aup_tag_tab
);

end;
/
