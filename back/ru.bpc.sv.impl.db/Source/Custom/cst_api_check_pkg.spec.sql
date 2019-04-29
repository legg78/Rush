create or replace package cst_api_check_pkg is

    function perform_check (
        i_oper_id               in      com_api_type_pkg.t_long_id
      , i_check_type            in      com_api_type_pkg.t_dict_value
      , i_msg_type              in      com_api_type_pkg.t_dict_value
      , i_oper_type             in      com_api_type_pkg.t_dict_value
      , i_oper_reason           in      com_api_type_pkg.t_dict_value
      , i_party_type            in      com_api_type_pkg.t_dict_value
      , i_host_date             in      date
      , io_network_id           in out  com_api_type_pkg.t_tiny_id
      , io_inst_id              in out  com_api_type_pkg.t_inst_id
      , io_client_id_type       in out  com_api_type_pkg.t_dict_value
      , io_client_id_value      in out  com_api_type_pkg.t_name
      , io_card_number          in out  com_api_type_pkg.t_card_number
      , io_card_inst_id         in out  com_api_type_pkg.t_inst_id
      , io_card_network_id      in out  com_api_type_pkg.t_network_id
      , io_card_id              in out  com_api_type_pkg.t_medium_id
      , io_card_instance_id     in out  com_api_type_pkg.t_medium_id
      , io_card_type_id         in out  com_api_type_pkg.t_tiny_id
      , io_card_mask            in out  com_api_type_pkg.t_card_number
      , io_card_hash            in out  com_api_type_pkg.t_medium_id
      , io_card_seq_number      in out  com_api_type_pkg.t_tiny_id
      , io_card_expir_date      in out  date
      , io_card_service_code    in out  com_api_type_pkg.t_country_code
      , io_card_country         in out  com_api_type_pkg.t_country_code
      , i_account_number        in      com_api_type_pkg.t_account_number
      , io_account_id           in out  com_api_type_pkg.t_medium_id
      , io_customer_id          in out  com_api_type_pkg.t_medium_id
      , i_merchant_number       in      com_api_type_pkg.t_merchant_number
      , io_merchant_id          in out  com_api_type_pkg.t_short_id
      , i_terminal_number       in      com_api_type_pkg.t_terminal_number
      , io_terminal_id          in out  com_api_type_pkg.t_short_id
      , io_split_hash           in out  com_api_type_pkg.t_tiny_id
      , i_external_auth_id      in      com_api_type_pkg.t_attr_name        default null
      , i_external_orig_id      in      com_api_type_pkg.t_attr_name        default null
      , i_trace_number          in      com_api_type_pkg.t_attr_name        default null
      , i_mask_error            in      com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
      , i_is_reversal           in      com_api_type_pkg.t_boolean          default null
    ) return com_api_type_pkg.t_boolean;

end;
/

