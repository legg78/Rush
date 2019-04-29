create or replace package acm_api_role_pkg as
/************************************************************
 * API for roles. <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 17.08.2009 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $<br />
 * Revision: $LastChangedRevision$ <br />
 * Module: ACM_API_ROLE_PKG <br />
 * @headcom
 *************************************************************/

-- Set role id
-- @param i_role_id  Role identifier
procedure set_role_id(
    i_role_id       in     com_api_type_pkg.t_tiny_id
);

-- Return role identifier
-- @return acm_role.id
  function get_role_id return com_api_type_pkg.t_tiny_id;

-- Return role name
-- @param i_role_id Role identifier
-- @return Name of role

function get_role_name(
    i_role_id       in     com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_name;

-- Check role to run process
-- @param i_prc_id Process identifier
-- @return 1/0  true/false
function check_user_role_prc (
    i_prc_id        in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean;

function get_role(
    i_role_id       in     com_api_type_pkg.t_tiny_id
  , i_role_name     in     com_api_type_pkg.t_name
  , i_mask_error    in     com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE
) return acm_api_type_pkg.t_role_rec;

function get_role_by_ext_name(
    i_role_ext_name in     com_api_type_pkg.t_name
  , i_mask_error    in     com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE
) return acm_api_type_pkg.t_role_rec;

end acm_api_role_pkg;
/
