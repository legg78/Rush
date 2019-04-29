create or replace package acm_api_user_pkg as
/************************************************************
 * API for user management <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 02.10.2009  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: ACM_API_USER_PKG <br />
 * @headcom
 ************************************************************/

-- Set ID user
-- @param i_user_id User identifier
procedure set_user_id(
    i_user_id        in            com_api_type_pkg.t_short_id
);

-- Get user identifier
-- @return User identifier
function get_user_id return com_api_type_pkg.t_short_id;

-- Search user by ID if it isn't null; otherwise, search user by name 
function get_user(
    i_user_id        in            com_api_type_pkg.t_short_id
  , i_user_name      in            com_api_type_pkg.t_name
  , i_mask_error     in            com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE
) return acm_api_type_pkg.t_user_rec;

-- Set username
-- @param i_user_name Username
  procedure set_user_name(
    i_user_name      in            com_api_type_pkg.t_name
);

-- Return user name
-- @return acm_user.name
function get_user_name return com_api_type_pkg.t_name;

function get_user_name(
    i_user_id        in            com_api_type_pkg.t_short_id
  , i_mask_error     in            com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE
) return com_api_type_pkg.t_name;

-- Get user is_active (blocked/unblocked) <br />
-- If user not found raise error
-- @param i_user_name  User name
-- @return 1/0 true/false
function get_user_is_active(
    i_user_name      in            com_api_type_pkg.t_name
) return com_api_type_pkg.t_boolean;

-- Get person identifier from user name  <br />
-- If user not found raise error
-- @param  i_user_name  User name
-- @return Person identifier
function get_person_id(
    i_user_name      in            com_api_type_pkg.t_name
) return com_api_type_pkg.t_medium_id result_cache;

-- Get user active status
-- @return constant 'User status active'
function user_active_status return com_api_type_pkg.t_dict_value result_cache;

-- Get user noactive status
-- @return constant 'User status noactive'
function user_noactive_status return com_api_type_pkg.t_dict_value
    result_cache;

-- Set user default institution
-- @param i_user_id User identifier
procedure set_user_inst(
    i_user_id        in            com_api_type_pkg.t_short_id
);

-- Get user default institution and change context
-- @param i_user_id User identifier
-- @return Institution identifier
function get_user_inst(
    i_user_id        in            com_api_type_pkg.t_short_id        default null
) return com_api_type_pkg.t_inst_id;

-- Set user default agent
-- @param i_user_id User identifier
procedure set_user_agent(
    i_user_id        in            com_api_type_pkg.t_short_id
);

-- Get user default agent and change context
-- @param i_user_id User identifier
-- @return Agent identifier
function get_user_agent(
    i_user_id        in            com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_agent_id;

function get_user_sandbox(
    i_user_id        in            com_api_type_pkg.t_short_id        default null
) return com_api_type_pkg.t_inst_id;

procedure create_user(
    io_user_rec      in out nocopy acm_api_type_pkg.t_user_rec
);

/*
 * Update user data, user ID (id) and institution (inst_id) are used to search a user that should be updated.
 * @param i_check_password    it allows to skip check of password's hash for matching with previous hashes
 */
procedure update_user(
    i_user_rec          in      acm_api_type_pkg.t_user_rec
  , i_check_password    in      com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
);

procedure add_role_to_user(
    i_role_id        in            com_api_type_pkg.t_tiny_id
  , i_user_id        in            com_api_type_pkg.t_short_id
  , o_id                out        com_api_type_pkg.t_short_id
  , i_mask_error     in            com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE
);

procedure remove_role_from_user(
    i_role_id        in            com_api_type_pkg.t_tiny_id
  , i_user_id        in            com_api_type_pkg.t_short_id
  , i_mask_error     in            com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE
);

procedure add_inst_to_user(
    i_user_id        in            com_api_type_pkg.t_short_id
  , i_inst_id        in            com_api_type_pkg.t_inst_id
  , i_is_entirely    in            com_api_type_pkg.t_boolean
  , i_is_default     in            com_api_type_pkg.t_boolean
  , o_id                out        com_api_type_pkg.t_short_id
);

procedure remove_inst_from_user(
    i_user_id        in            com_api_type_pkg.t_short_id
  , i_inst_id        in            com_api_type_pkg.t_inst_id
);

procedure clean_agents;

/*
 * It returns true if agent <i_agent_id> belongs to default  institution of user <i_user_id>.  
 */
function agent_of_default_institution(
    i_user_id        in            com_api_type_pkg.t_short_id
  , i_agent_id       in            com_api_type_pkg.t_agent_id
) return com_api_type_pkg.t_boolean;

procedure add_agent_to_user(
    i_user_id        in            com_api_type_pkg.t_short_id
  , i_agent_id       in            com_api_type_pkg.t_agent_id
  , i_is_default     in            com_api_type_pkg.t_boolean
  , o_id                out        com_api_type_pkg.t_short_id
);

procedure remove_agent_from_user(
    i_user_id        in            com_api_type_pkg.t_short_id
  , i_agent_id       in            com_api_type_pkg.t_agent_id
  , i_check_default  in            com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
);

procedure refresh_mview;

-- Get user default institution for current context
-- @param i_user_id User identifier
-- @return Institution identifier
function get_user_inst_id(
    i_user_id in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_inst_id;

-- Get user default agent for current context
-- @param i_user_id User identifier
-- @param i_inst_id User institution identifier
-- @return Agent identifier
function get_user_agent_id (
    i_user_id in     com_api_type_pkg.t_short_id
  , i_inst_id in     com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_agent_id;

-- Get user default agent for current context
-- @param i_user_name User name
-- @return Agent identifier
function get_user_agent_id (
    i_user_name     in    com_api_type_pkg.t_name
) return com_api_type_pkg.t_agent_id;

-- Get role list for required user
-- @param i_user_id User id
-- @return Role list
function get_user_role_list(
    i_user_id        in            com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_full_desc;

function get_user_role_tab(
    i_user_id        in            com_api_type_pkg.t_short_id
) return com_text_trans_tpt;

end acm_api_user_pkg;
/
