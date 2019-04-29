create or replace package cst_ap_api_report_pkg as
/**********************************************************
 * Reports for AP project <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 15.03.2019 <br />
 * Module: CST_AP_API_REPORT_PKG
 * @headcom
 **********************************************************/

procedure compare_tp_with_synt_file_type(
    o_xml                     out  clob
  , i_ap_session_id            in  com_api_type_pkg.t_long_id
  , i_synt_file_type           in  com_api_type_pkg.t_dict_value
  , i_usonthem_direct          in  com_api_type_pkg.t_dict_value
  , i_themonus_direct          in  com_api_type_pkg.t_dict_value
  , i_lang                     in  com_api_type_pkg.t_dict_value  default null
);

end cst_ap_api_report_pkg;
/
