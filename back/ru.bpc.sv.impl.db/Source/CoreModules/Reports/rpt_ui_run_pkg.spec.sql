create or replace package rpt_ui_run_pkg as
/*********************************************************
 *  User interface for reports running  <br />
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 21.09.2010 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate:: 2010-09-27 11:31:00 +0400#$ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: RPT_UI_RUN_PKG <br />
 *  @headcom 
 **********************************************************/

procedure report_start(
    i_report_id         in      com_api_type_pkg.t_short_id
  , i_parameters        in      com_param_map_tpt
  , i_template_id       in      com_api_type_pkg.t_short_id
  , i_document_id       in      com_api_type_pkg.t_long_id      default null
  , i_content_type      in      com_api_type_pkg.t_dict_value   default null
  , o_run_id               out  com_api_type_pkg.t_long_id
  , o_is_deterministic     out  com_api_type_pkg.t_boolean
  , o_is_first_run         out  com_api_type_pkg.t_boolean
  , o_file_name            out  com_api_type_pkg.t_name
  , o_save_path            out  com_api_type_pkg.t_name
  , o_resultset            out  sys_refcursor
  , o_xml                  out  clob
);

procedure set_report_status(
    i_run_id            in      com_api_type_pkg.t_long_id
  , i_status            in      com_api_type_pkg.t_dict_value
);

end;
/
