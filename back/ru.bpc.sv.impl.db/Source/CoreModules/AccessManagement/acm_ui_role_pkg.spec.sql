create or replace package acm_ui_role_pkg
as
/************************************************************
 * Provides an interface for managing roles. <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 17.08.2009 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: ACM_UI_ROLE_PKG <br />
 * @headcom
 ************************************************************/

/*
 * Add new roles.
 * @param i_role_name        Name of role
 * @param i_role_short_desc Short description
 * @param i_role_full_desc  Full description
 * @param i_role_lang link  Language identifier
 * @param io_role_id in out Role identifier
*/
procedure add_role(
    i_role_name        in     com_api_type_pkg.t_name
  , i_role_short_desc  in     com_api_type_pkg.t_short_desc
  , i_role_full_desc   in     com_api_type_pkg.t_full_desc
  , i_role_lang        in     com_api_type_pkg.t_dict_value
  , i_notif_scheme_id  in     com_api_type_pkg.t_tiny_id
  , i_ext_name         in     com_api_type_pkg.t_name       := null
  , io_role_id         in out com_api_type_pkg.t_tiny_id
);

/*
 * Add role inside role.
 * @param i_role_child         Name of role
 * @param i_role_i_role_parent Link name of role
 * @param o_id                 Record identifier
*/
procedure add_role_in_role(
    i_role_child      in     com_api_type_pkg.t_tiny_id
  , i_role_parent     in     com_api_type_pkg.t_tiny_id
  , o_id                 out com_api_type_pkg.t_short_id
);

/*
 * Removal role from role by id.
 * @param i_id  Record identifier
 */
procedure remove_role_from_role(
    i_id              in     com_api_type_pkg.t_short_id
);

/*
 * Removal role from role.
 * @param i_role_child         Child role identifier
 * @param i_role_i_role_parent Parent role identifier
 */
procedure remove_role_from_role(
    i_role_child      in     com_api_type_pkg.t_tiny_id
  , i_role_parent     in     com_api_type_pkg.t_tiny_id
);

/*
 * Remove role
 * @param i_role Role identifier
*/
procedure remove_role(
    i_role_id         in     com_api_type_pkg.t_tiny_id
);

/*
 * Add process role
 * @param o_id      Record identifier
 * @param i_role_id Role identifier
 * @param i_prc_id  Process identifier
 */
procedure add_role_prc(
    i_role_id         in     com_api_type_pkg.t_tiny_id
  , i_prc_id          in     com_api_type_pkg.t_long_id
  , o_id                 out com_api_type_pkg.t_short_id
);

/*
 * Remove role process
 * @param i_id Record identifier
*/
procedure remove_role_prc(
    i_id              in     com_api_type_pkg.t_long_id
);

/*
 * Add report role
 * @param o_id      Record identifier
 * @param i_role_id Role identifier
 * @param i_rpt_id  Report identifier
 */
procedure add_role_rpt(
    i_role_id         in     com_api_type_pkg.t_tiny_id
  , i_rpt_id          in     com_api_type_pkg.t_long_id
  , o_id                 out com_api_type_pkg.t_short_id
);

/*
 * Remove role report
 * @param i_id Record identifier
*/
procedure remove_role_rpt(
    i_id              in     com_api_type_pkg.t_long_id
);

/*
 * Add entity object to a role.
 * @param o_id         New role identifier
 * @param i_role_id    Role identifier
 * @param i_object_id  Entity object identifier
 */
procedure add_role_object(
    i_role_id        in     com_api_type_pkg.t_tiny_id
  , i_entity_type    in     com_api_type_pkg.t_dict_value
  , i_object_id      in     com_api_type_pkg.t_long_id
  , o_id                out com_api_type_pkg.t_short_id
);

/*
 * Remove entity object from a role.
 * @param i_id    Record identifier
*/
procedure remove_role_object(
    i_id             in     com_api_type_pkg.t_long_id
);

end acm_ui_role_pkg;
/
