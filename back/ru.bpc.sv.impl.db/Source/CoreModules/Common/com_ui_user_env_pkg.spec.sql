create or replace package com_ui_user_env_pkg as
/***********************************************************
 * User context
 * Created by Filimonov A.(filimonov@bpc.ru)  at 08.08.2009
 * Module: COM_UI_USER_ENV_PKG
 * @headcom
************************************************************/
--
-- Get user language
-- @return code of language
function get_user_lang return com_api_type_pkg.t_dict_value;
--
-- Get user default agent
-- @return Id agent
function get_user_agent return com_api_type_pkg.t_agent_id;
--
-- Get user default institution
-- @return Id institution
function get_user_inst return com_api_type_pkg.t_inst_id;
--
-- Get user name
-- @return User name
function get_user_name return com_api_type_pkg.t_name;
--
-- Get ID user
-- @return Id user
function get_user_id return com_api_type_pkg.t_short_id;
--
-- Get the current user ID Person
-- @return Id Person
function get_person_id return com_api_type_pkg.t_medium_id;
--
-- Get user default sandbox
-- @return Id sandbox
function get_user_sandbox return com_api_type_pkg.t_inst_id;

function get_user_ip_address return com_api_type_pkg.t_name;

--
-- Set user context parameters
-- @param i_user_name Name of user
-- @param io session_id  Session ID ( Null for create new session)
procedure set_user_context(
    i_user_name     in      com_api_type_pkg.t_name
  , io_session_id   in out  com_api_type_pkg.t_long_id
  , i_ip_address    in      com_api_type_pkg.t_name             default null
  , i_entity_type   in      com_api_type_pkg.t_dict_value       default null
  , i_object_id     in      com_api_type_pkg.t_long_id          default null
  , i_container_id  in      com_api_type_pkg.t_short_id         default null
);
--
-- Set user context parameters with privilege checking and status
-- @param i_user_name Name of user
-- @param io session_id  Session ID ( Null for create new session)
-- @param i_priv_name System privilege name
-- @param io_status Status of user action
-- @param i_param_map Login parameters
procedure set_user_context(
    i_user_name     in      com_api_type_pkg.t_name
  , io_session_id   in out  com_api_type_pkg.t_long_id
  , i_ip_address    in      com_api_type_pkg.t_name             default null
  , i_priv_name     in      com_api_type_pkg.t_name             default null
  , io_status       in out  com_api_type_pkg.t_dict_value
  , i_param_map     in      com_param_map_tpt                   default null
  , i_entity_type   in      com_api_type_pkg.t_dict_value       default null
  , i_object_id     in      com_api_type_pkg.t_long_id          default null
  , i_container_id  in      com_api_type_pkg.t_short_id         default null
);

function get_trail_id return com_api_type_pkg.t_long_id;

procedure drop_user_context;

procedure start_session(
    io_session_id           in out  com_api_type_pkg.t_long_id
  , i_ip_address            in      com_api_type_pkg.t_name        default null
);

-- Get user nls_numeric_characters
-- @return nls_numeric_characters
function get_nls_numeric_characters return com_api_type_pkg.t_name;

-- Get user number format_mask
-- @return user number format_mask
function get_format_mask return com_api_type_pkg.t_name;

end;
/
