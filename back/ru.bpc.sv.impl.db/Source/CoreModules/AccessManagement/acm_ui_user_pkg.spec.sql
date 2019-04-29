create or replace package acm_ui_user_pkg as
/***********************************************************
 * Provides an interface for managing users. <br>
 * Created by Kryukov E.(krukov@bpc.ru)  at 17.08.2009  <br>
 * Last changed by $Author$ <br>
 * $LastChangedDate::                           $  <br>
 * Revision: $LastChangedRevision$ <br>
 * Module: ACM_UI_USER_PKG <br>
 * @headcom
 **********************************************************/

/*
 * Get default agent for user
 * @param i_user_id User ID
 * @param i_inst_id Institution identifier
 */
function get_default_agent(
    i_user_id  in     com_api_type_pkg.t_short_id default get_user_id
  , i_inst_id  in     com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_short_id;

/*
 * Add new user
 * @param i_user_name Username
 * @param io_user_id  User identifier
 * @param i_person_id Person identifier
 * @param i_inst_id Institution identifier
 */
procedure add_new_user (
    i_user_name                 in      com_api_type_pkg.t_name
  , io_user_id              in out      com_api_type_pkg.t_short_id
  , i_person_id                 in      com_api_type_pkg.t_medium_id
  , i_inst_id                   in      com_api_type_pkg.t_inst_id
  , i_password_hash             in      com_api_type_pkg.t_hash_value   default null
  , i_password_change_needed    in      com_api_type_pkg.t_boolean      default null
  , i_auth_scheme               in      com_api_type_pkg.t_dict_value   default null
);

/*
 * Purpose of the role of the user
 * @param i_role_id Role identifier
 * @param i_user_id User identifier
 * @param io_id Record identifier
 */
procedure add_role_to_user (
    i_role_id in     com_api_type_pkg.t_tiny_id
  , i_user_id in     com_api_type_pkg.t_short_id
  , io_id        out com_api_type_pkg.t_short_id
);

/*
 * Block user
 * @param i_user_id User identifier
 */
procedure block_user (
    i_user_id in     com_api_type_pkg.t_short_id
);

/*
 * Unblock user
 * @param i_user_id User identifier
 */
procedure unblock_user (
    i_user_id in     com_api_type_pkg.t_short_id
);

/*
 * Removal of user role
 * @param i_role_id Role identifier
 * @param i_user_id Id user
 */
procedure remove_role_from_user (
    i_role_id in     com_api_type_pkg.t_tiny_id
  , i_user_id in     com_api_type_pkg.t_short_id
);

/*
 * Purpose of the institute user
 * @param i_user_id User identifier
 * @param i_inst_id Institution identifier
 * @param i_is_ent  All of agents
 * @param io_id     Record identifier
 * @param i_force   Need update
 */
procedure add_inst_to_user (
    i_user_id      in     com_api_type_pkg.t_short_id
  , i_inst_id      in     com_api_type_pkg.t_inst_id
  , i_is_ent       in     com_api_type_pkg.t_boolean
  , io_id          in out com_api_type_pkg.t_short_id
  , i_force        in     com_api_type_pkg.t_boolean   default com_api_type_pkg.FALSE
  , i_set_def      in     com_api_type_pkg.t_boolean   default com_api_type_pkg.FALSE
  , i_need_refresh in     com_api_type_pkg.t_boolean   default com_api_type_pkg.TRUE
);

/*
 * Set default institution
 * @param i_inst_id Institution identifier
 * @param i_user_id User identifier
 */
procedure set_def_inst (
    i_inst_id      in       com_api_type_pkg.t_inst_id
  , i_user_id      in       com_api_type_pkg.t_short_id
  , i_need_refresh in       com_api_type_pkg.t_boolean   default com_api_type_pkg.TRUE
);

/*
 * Remove institution from user
 * @param i_user_id User identifier
 * @param i_inst_id Institution identifier
 */
procedure remove_inst_from_user (
    i_user_id      in     com_api_type_pkg.t_short_id
  , i_inst_id      in     com_api_type_pkg.t_inst_id
  , i_need_refresh in     com_api_type_pkg.t_boolean   default com_api_type_pkg.TRUE
);

/*
 * Purpose of the agent user
 * @param i_user_id  User identifier
 * @param i_agent_id Agent identifier
 * @param i_is_def   Default agent
 * @param io_id      Record identifier
 * @param i_force    Need update
 */
procedure add_agent_to_user (
    i_user_id       in     com_api_type_pkg.t_short_id
  , i_agent_id      in     com_api_type_pkg.t_agent_id
  , i_is_def        in     com_api_type_pkg.t_boolean
  , io_id           in out com_api_type_pkg.t_short_id
  , i_force         in     com_api_type_pkg.t_boolean  default com_api_type_pkg.FALSE
  , i_need_refresh  in     com_api_type_pkg.t_boolean  default com_api_type_pkg.TRUE
);

/*
 * Remove institution from user
 * @param i_user_id  User identifier
 * @param i_agent_id Agent identifier
 */
procedure remove_agent_from_user (
    i_user_id       in      com_api_type_pkg.t_short_id
  , i_agent_id      in      com_api_type_pkg.t_agent_id
  , i_check_default in      com_api_type_pkg.t_boolean   default com_api_type_pkg.TRUE
  , i_need_refresh  in      com_api_type_pkg.t_boolean   default com_api_type_pkg.TRUE
);

/*
 * Set user ID <br />
 * @param i_user_id User identifier
*/
procedure set_user_id(
    i_user_id       in     com_api_type_pkg.t_short_id
);

procedure refresh_mview(
    i_change_user_via_appl  in  com_api_type_pkg.t_boolean  default com_api_type_pkg.FALSE
  , i_need_refresh          in  com_api_type_pkg.t_boolean  default com_api_type_pkg.TRUE
);

function get_user_full_name(
    i_user_id       in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_name;

function get_user_id_by_name(
    i_user_name     in      com_api_type_pkg.t_name
  , i_mask_error    in      com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE 
) return com_api_type_pkg.t_short_id;

procedure avoid_expire_date(
    i_user_name     in      com_api_type_pkg.t_name
);

procedure change_user_auth_scheme (
    i_user_id       in      com_api_type_pkg.t_short_id,
    i_auth_scheme   in      com_api_type_pkg.t_dict_value       
);

procedure modify_user_data(
    i_tab_name      in      com_api_type_pkg.t_name
  , i_user_data     in      acm_user_data_tpt
);

procedure reset_lockout(
    i_user_id       in      com_api_type_pkg.t_short_id
);

function get_lockout_date(
    i_user_id       in      com_api_type_pkg.t_short_id
) return date;

procedure user_login(
    i_user_id       in      com_api_type_pkg.t_short_id
  , io_status       in out  com_api_type_pkg.t_dict_value
  , io_session_id   in out  com_api_type_pkg.t_long_id
  , i_ip_address    in      com_api_type_pkg.t_name
);

function get_person_name_by_user(
    i_user_id       in      com_api_type_pkg.t_short_id
  , i_user_name     in      com_api_type_pkg.t_name       default null
  , i_lang          in      com_api_type_pkg.t_dict_value default null
) return com_api_type_pkg.t_name;

procedure set_user_role(
    i_user_id            in com_api_type_pkg.t_short_id
  , i_ext_role_name_tab  in raw_data_tpt
);

end acm_ui_user_pkg;
/
