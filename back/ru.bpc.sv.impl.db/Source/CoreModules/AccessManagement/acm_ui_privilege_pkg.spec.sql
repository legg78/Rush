create or replace package acm_ui_privilege_pkg as
/*************************************************************
 * Provides an interface for managing privileges. <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 30.09.2009 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate: 2009-10-27 17:52:33 +0300#$ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: ACM_UI_PRIVILEGE_PKG <br />
 * @headcom
 *************************************************************/

/*
 * Add privilege to role
 * @param o_id       return primary key
 * @param i_role_id  Role identifier
 * @param i_priv_id  Privilege identifier
 * @param i_limit_id Limit identifier
 */
procedure add_privilege_role(
    o_id                 out com_api_type_pkg.t_short_id
  , i_role_id         in     com_api_type_pkg.t_tiny_id
  , i_priv_id         in     com_api_type_pkg.t_short_id
  , i_limit_id        in     com_api_type_pkg.t_short_id
  , i_filter_limit_id in     com_api_type_pkg.t_short_id default null
);

/*
 * Remove privilege from role by identifier
 * @param i_privs_role_id Role-Privilege link identifier
 */
procedure remove_privilege_role(
    i_privs_role_id in com_api_type_pkg.t_short_id
);

/*
 * Remove privilege from role
 * @param i_role_id Role identifier
 * @param i_priv_id Privilege identifier
 */
procedure remove_privilege_role(
    i_role_id in     com_api_type_pkg.t_tiny_id
  , i_priv_id in     com_api_type_pkg.t_short_id
);


procedure set_limitation(
    i_role_id          in     com_api_type_pkg.t_tiny_id
  , i_priv_id          in     com_api_type_pkg.t_short_id
  , i_limit_id         in     com_api_type_pkg.t_short_id
  , i_filter_limit_id  in     com_api_type_pkg.t_short_id default null
);

/*
 * Add new privilege into system privileges
 * @param io_priv_id    Privilege identifier
 * @param i_name        Privilege system name
 * @param i_short_desc  Privilege description
 * @param i_full_desc   Privilege extended description
 * @param i_lang        Language of descriptions
 * @param i_module      Module code
 * @param is_active     Is active
 * @param i_section_id  Reference on section where action can be done
 */

procedure add_privilege(
    io_id               in out  com_api_type_pkg.t_short_id
  , i_name              in      com_api_type_pkg.t_name
  , i_short_desc        in      com_api_type_pkg.t_short_desc
  , i_full_desc         in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_module            in      com_api_type_pkg.t_module_code
  , i_is_active         in      com_api_type_pkg.t_boolean
  , i_section_id        in      com_api_type_pkg.t_short_id
);

/*
 * Remove privilege
 * @param i_priv_id Privilege identifier
 */
procedure remove_privilege(
    i_priv_id in     com_api_type_pkg.t_short_id
);


procedure get_priv_limitation(
    i_priv_name         in      com_api_type_pkg.t_name
  , o_limitation           out  com_api_type_pkg.t_text
);

procedure check_filter_limitation(
    i_priv_name         in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
);

end acm_ui_privilege_pkg;
/
