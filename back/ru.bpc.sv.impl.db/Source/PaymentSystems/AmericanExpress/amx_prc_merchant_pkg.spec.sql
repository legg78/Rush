create or replace package amx_prc_merchant_pkg as

procedure process(
    i_inst_id          in com_api_type_pkg.t_inst_id      default ost_api_const_pkg.DEFAULT_INST
  , i_full_export      in com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_amx_action_code  in com_api_type_pkg.t_module_code  default null 
  , i_lang             in com_api_type_pkg.t_dict_value   default null
);

end amx_prc_merchant_pkg;
/
