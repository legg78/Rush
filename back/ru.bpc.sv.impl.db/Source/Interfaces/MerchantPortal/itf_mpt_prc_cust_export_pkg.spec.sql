create or replace package itf_mpt_prc_cust_export_pkg 
as

procedure process(
    i_mpt_version   in  com_api_type_pkg.t_name
  , i_inst_id       in  com_api_type_pkg.t_inst_id
  , i_full_export   in  com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , i_lang          in  com_api_type_pkg.t_dict_value   default null
);

end;
/
