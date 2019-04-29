create or replace package cst_sat_prc_acs_enrollment_pkg
is

procedure export_card_info(
    i_inst_id   in  com_api_type_pkg.t_inst_id    default ost_api_const_pkg.DEFAULT_INST
  , i_lang      in  com_api_type_pkg.t_dict_value default null
);

end cst_sat_prc_acs_enrollment_pkg;
/
