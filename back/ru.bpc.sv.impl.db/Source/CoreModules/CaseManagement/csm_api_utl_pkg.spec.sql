create or replace package csm_api_utl_pkg is
/*************************************************************
 * API for case utilities <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com)  at 17.01.2018
 * Module: CSM_API_UTL_PKG
 * @headcom
**************************************************************/
function get_case_comment(
    i_action            in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_text;

function is_mcom_enabled(
    i_network_id        in      com_api_type_pkg.t_tiny_id
  , i_inst_id           in      com_api_type_pkg.t_tiny_id
  , i_host_id           in      com_api_type_pkg.t_tiny_id       default null
  , i_standard_id       in      com_api_type_pkg.t_tiny_id       default null
) return com_api_type_pkg.t_boolean;

function is_mcom_enabled(
    i_oper_id           in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean;


end;
/
