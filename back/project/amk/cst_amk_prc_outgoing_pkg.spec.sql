create or replace package cst_amk_prc_outgoing_pkg as

procedure process_fees_to_t24_export(
    i_inst_id                  in  com_api_type_pkg.t_inst_id
  , i_full_export              in  com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
  , i_date_type                in  com_api_type_pkg.t_dict_value
  , i_start_date               in  date                                default null
  , i_end_date                 in  date                                default null
  , i_gl_accounts              in  com_api_type_pkg.t_boolean          default null
  , i_load_reversals           in  com_api_type_pkg.t_boolean          default null
  , i_array_balance_type_id    in  com_api_type_pkg.t_medium_id        default null
  , i_array_trans_type_id      in  com_api_type_pkg.t_medium_id        default null
  , i_separate_char            in  com_api_type_pkg.t_byte_char
);

procedure process_trans_export_to_telco(
    i_inst_id                   in  com_api_type_pkg.t_inst_id
  , i_full_export               in  com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
  , i_date_type                 in  com_api_type_pkg.t_dict_value
  , i_start_date                in  date                                default null
  , i_end_date                  in  date                                default null
  , i_service_provider_id       in  com_api_type_pkg.t_short_id         default null
  , i_load_reversals            in  com_api_type_pkg.t_boolean          default null
  , i_array_operations_type_id  in  com_api_type_pkg.t_medium_id        default null
  , i_separate_char             in  com_api_type_pkg.t_byte_char
);

procedure process_fees_to_t24_csv(
    i_inst_id                  in  com_api_type_pkg.t_inst_id
  , i_full_export              in  com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
  , i_date_type                in  com_api_type_pkg.t_dict_value
  , i_start_date               in  date                                default null
  , i_end_date                 in  date                                default null
  , i_separate_char            in  com_api_type_pkg.t_byte_char        default ','
);

end cst_amk_prc_outgoing_pkg;
/
