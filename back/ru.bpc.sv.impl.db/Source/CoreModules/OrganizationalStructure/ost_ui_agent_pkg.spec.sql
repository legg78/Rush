create or replace package ost_ui_agent_pkg as
/*********************************************************
 * Provides an user interface for managing agents. <br>
 * Created by Filimonov A.(filimonov@bpc.ru)  at 21.09.2009  <br>
 * Last changed by $Author$ <br>
 * $LastChangedDate::                           $  <br>
 * Revision: $LastChangedRevision$ <br>
 * Module: OST_UI_AGENT_PKG <br>
 * @headcom
 **********************************************************/

procedure add_agent(
    o_agent_id             out  com_api_type_pkg.t_agent_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_agent_type        in      com_api_type_pkg.t_dict_value
  , i_name              in      com_api_type_pkg.t_short_desc
  , i_description       in      com_api_type_pkg.t_full_desc        default null
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
  , i_parent_agent_id   in      com_api_type_pkg.t_agent_id
  , i_is_default        in      com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE 
  , i_agent_number      in      com_api_type_pkg.t_name             default null
  , i_refresh_matview   in      com_api_type_pkg.t_boolean          default null
);

procedure modify_agent(
    i_agent_id          in      com_api_type_pkg.t_agent_id
  , i_name              in      com_api_type_pkg.t_short_desc       default null
  , i_description       in      com_api_type_pkg.t_full_desc        default null
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
  , i_parent_agent_id   in      com_api_type_pkg.t_agent_id
  , i_is_default        in      com_api_type_pkg.t_boolean          
  , i_seqnum            in      com_api_type_pkg.t_seqnum
  , i_agent_number      in      com_api_type_pkg.t_name             default null
  , i_refresh_matview   in      com_api_type_pkg.t_boolean          default null
);

procedure remove_agent(
    i_agent_id          in      com_api_type_pkg.t_agent_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

function get_agent_name(
    i_agent_id          in      com_api_type_pkg.t_agent_id
  , i_lang              in      com_api_type_pkg.t_dict_value       default null 
) return com_api_type_pkg.t_name
  result_cache;

function get_agent_number(
    i_agent_id          in      com_api_type_pkg.t_agent_id
) return com_api_type_pkg.t_name;

end;
/
