create or replace package cst_ap_api_process_pkg is
/************************************************************
 * API for various processing AP <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com)  at 10.03.2019 <br />
 * Last changed by $Author: Gogolev I. $ <br />
 * $LastChangedDate:: #$ <br />
 * Revision: $LastChangedRevision:  $ <br />
 * Module: cst_ap_api_process_pkg <br />
 * @headcom
 ***********************************************************/
FORMAT_DATE_DTGEN       constant    com_api_type_pkg.t_attr_name    := 'ddmmyyyy';
FORMAT_ADD_TIME_DEF     constant    com_api_type_pkg.t_attr_name    := 'hh24:mi:ss';
VALUE_ADD_TIME_DEF      constant    com_api_type_pkg.t_attr_name    := '10:00:00';

procedure insert_into_ap_synt_tab(
    i_ap_synt_tab         in  cst_ap_api_type_pkg.t_synt_file_tab
);

procedure insert_into_ap_session_tab(
    i_date_text         in  com_api_type_pkg.t_attr_name
  , i_format_date       in  com_api_type_pkg.t_attr_name    default FORMAT_DATE_DTGEN
  , i_add_time_text     in  com_api_type_pkg.t_attr_name    default VALUE_ADD_TIME_DEF
  , i_format_time       in  com_api_type_pkg.t_attr_name    default FORMAT_ADD_TIME_DEF
  , i_session_file_id   in  com_api_type_pkg.t_long_id
);

function get_ap_session_id(
    i_ap_session_status in  com_api_type_pkg.t_sign
  , i_eff_date          in  date
  , i_mask_error        in  com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_short_id;

procedure get_ap_session_date(
    i_ap_session_id     in  com_api_type_pkg.t_long_id
  , o_start_date       out  date
  , o_end_date         out  date
  , i_end_date_def      in  date    default null
);

function convert_oper_type_sv_to_tp(
    i_oper_type     in  com_api_type_pkg.t_dict_value
  , i_term_type     in  com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_byte_id;

end;
/
