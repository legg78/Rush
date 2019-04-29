create or replace package cst_bsm_outgoing_pkg is

/**
*   Export information of cards and linked to them accounts to BASE 24
*   @param i_inst_id - Institution id
*   @param i_environment_code - Environment code from dictionary ENVT
*   @param i_issuer_code - Issuer H2H BASE 24 code, string, default 'MANT'
*   @param i_full_export - Full export flag.
*/
procedure export_caf(
    i_inst_id           in com_api_type_pkg.t_inst_id
  , i_environment_code  in com_api_type_pkg.t_dict_value
  , i_issuer_code       in com_api_type_pkg.t_dict_value
  , i_full_export       in com_api_type_pkg.t_boolean
);

procedure get_priority_criteria(
    i_application_id          in     com_api_type_pkg.t_long_id
  , o_ref_cursor                 out com_api_type_pkg.t_ref_cur);

procedure get_priority_products(
    i_application_id          in     com_api_type_pkg.t_long_id
  , o_ref_cursor                 out com_api_type_pkg.t_ref_cur);

end cst_bsm_outgoing_pkg;
/
