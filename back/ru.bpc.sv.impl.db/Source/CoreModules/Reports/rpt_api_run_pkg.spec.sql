create or replace package rpt_api_run_pkg as
/*********************************************************
 *  API for reports running <br />
 *  Created by Fomichev A.(fomichev@bpc.ru)  at 21.09.2010 <br />
 *  Last changed by $Author: fomichev $ <br />
 *  $LastChangedDate:: 2010-09-27 11:31:00 +0400#$ <br />
 *  Module: rpt_api_run_pkg <br />
 *  @headcom 
 **********************************************************/

function get_g_report_id return com_api_type_pkg.t_short_id;

procedure set_g_report_id (i_g_report_id in com_api_type_pkg.t_short_id);

procedure process_report(
    i_report_id         in      com_api_type_pkg.t_short_id
  , i_template_id       in      com_api_type_pkg.t_short_id
  , i_parameters        in      com_api_type_pkg.t_param_tab
  , i_source_type       in      com_api_type_pkg.t_dict_value
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
  , io_data_source      in out nocopy clob
  , o_resultset            out  sys_refcursor
  , o_xml                  out  clob
);

procedure get_document_data(
    i_report_id         in      com_api_type_pkg.t_short_id
  , i_param_tab         in      com_api_type_pkg.t_param_tab
  , i_name_format_id    in      com_api_type_pkg.t_tiny_id      default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , o_file_name            out  com_api_type_pkg.t_name
  , o_save_path            out  com_api_type_pkg.t_name
  , o_run_hash             out  com_api_type_pkg.t_name
  , o_first_run_id         out  com_api_type_pkg.t_long_id
  , io_document_id      in out  com_api_type_pkg.t_long_id
  , i_content_type      in      com_api_type_pkg.t_dict_value
);

procedure register_report_run(
    o_run_id               out  com_api_type_pkg.t_long_id
  , i_report_id         in      com_api_type_pkg.t_short_id
  , i_param_tab         in      com_api_type_pkg.t_param_tab
  , i_run_hash          in      com_api_type_pkg.t_name         default null
  , i_document_id       in      com_api_type_pkg.t_long_id      default null
  , i_status            in      com_api_type_pkg.t_dict_value   default null
);


end;
/
