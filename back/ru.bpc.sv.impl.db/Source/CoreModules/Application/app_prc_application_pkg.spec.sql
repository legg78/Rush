create or replace package app_prc_application_pkg as
/*********************************************************
 *  API for processes of application files <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 14.12.2011 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: app_prc_application_pkg  <br />
 *  @headcom
 **********************************************************/
procedure process(
    i_inst_id             in      com_api_type_pkg.t_inst_id      default null
  , i_agent_id            in      com_api_type_pkg.t_short_id     default null
  , i_session_files_only  in      com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
  , i_execution_mode      in      com_api_type_pkg.t_dict_value   default null
  , i_validate_xml_file   in      com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
);

procedure parallel_process(
    i_inst_id             in      com_api_type_pkg.t_inst_id      default null
  , i_agent_id            in      com_api_type_pkg.t_short_id     default null
  , i_session_files_only  in      com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
  , i_validate_xml_file   in      com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
);

procedure process_migrate(
    i_inst_id             in      com_api_type_pkg.t_inst_id      default null
  , i_agent_id            in      com_api_type_pkg.t_short_id     default null
  , i_count               in      com_api_type_pkg.t_short_id     default 0
  , i_application_type    in      com_api_type_pkg.t_dict_value   default null
  , i_validate_xml_file   in      com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
);

end app_prc_application_pkg;
/
