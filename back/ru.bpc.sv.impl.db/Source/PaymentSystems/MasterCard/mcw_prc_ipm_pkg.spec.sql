create or replace package mcw_prc_ipm_pkg is

    function get_trim_bin
    return com_api_type_pkg.t_boolean;

    procedure upload (
        i_network_id              in com_api_type_pkg.t_tiny_id
      , i_inst_id                 in com_api_type_pkg.t_inst_id      default null
      , i_charset                 in com_api_type_pkg.t_oracle_name  default null
      , i_use_institution         in com_api_type_pkg.t_dict_value   default null
      , i_start_date              in date                            default null
      , i_end_date                in date                            default null
      , i_record_format           in com_api_type_pkg.t_dict_value   default null
      , i_include_affiliate       in com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
      , i_create_disp_case        in com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
    );

    procedure load (
        i_network_id              in com_api_type_pkg.t_tiny_id
      , i_charset                 in com_api_type_pkg.t_oracle_name  default null
      , i_record_format           in com_api_type_pkg.t_dict_value   default null
      , i_create_operation        in com_api_type_pkg.t_boolean      default null
      , i_validate_records        in com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
      , i_create_disp_case        in com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
      , i_register_loading_event  in com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
      , i_create_rev_reject       in com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
    );

end mcw_prc_ipm_pkg;
/
