create or replace package itf_prc_account_export_pkg is

/*
 * Process for unloading data for DBAL.
 * @param i_export_clear_pan  - if it is FALSE then process unloads undecoded
 *     PANs (tokens) for case when Message Bus is capable to handle them.
 */
procedure process_unload_turnover(
    i_inst_id                   in     com_api_type_pkg.t_inst_id
  , i_full_export               in     com_api_type_pkg.t_boolean        default null
  , i_unload_limits             in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_count                     in     com_api_type_pkg.t_medium_id      default null
  , i_array_balance_type_id     in     com_api_type_pkg.t_medium_id      default null
  , i_include_service           in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_lang                      in     com_api_type_pkg.t_dict_value     default null
  , i_export_clear_pan          in     com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
  , i_array_account_type        in     com_api_type_pkg.t_dict_value     default null
  , i_unload_payments           in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_replace_inst_id_by_number in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_unload_acquiring_accounts in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
);

procedure unload_merchant_accounts(
    i_inst_id                   in     com_api_type_pkg.t_inst_id
  , i_full_export               in     com_api_type_pkg.t_boolean        default null
  , i_unload_limits             in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_count                     in     com_api_type_pkg.t_medium_id      default null
  , i_array_balance_type_id     in     com_api_type_pkg.t_medium_id      default null
  , i_include_service           in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_lang                      in     com_api_type_pkg.t_dict_value     default null
  , i_export_clear_pan          in     com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
  , i_array_account_type        in     com_api_type_pkg.t_dict_value     default null
  , i_replace_inst_id_by_number in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
);

end itf_prc_account_export_pkg;
/
