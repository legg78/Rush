create or replace package iss_api_virtual_card_pkg is

    function issue_virtual_card (
        i_id                        in com_api_type_pkg.t_long_id default null
        , i_source_card_instance_id   in com_api_type_pkg.t_medium_id
        , i_card_type_id            in com_api_type_pkg.t_tiny_id
        , io_expir_date             in out date
        , i_limit_type              in  com_api_type_pkg.t_dict_value default null
        , i_usage_limit_count       in com_api_type_pkg.t_long_id
        , i_usage_limit_amount      in com_api_type_pkg.t_money
        , i_usage_limit_currency    in com_api_type_pkg.t_curr_code
        , i_account_id              in com_api_type_pkg.t_account_id := null
        , o_card_number             out com_api_type_pkg.t_card_number
        , o_card_id                 out com_api_type_pkg.t_medium_id
        , o_card_instance_id        out com_api_type_pkg.t_medium_id
        , o_pin_verify_method       out com_api_type_pkg.t_dict_value
        , o_cvv_required            out com_api_type_pkg.t_boolean
        , o_icvv_required           out com_api_type_pkg.t_boolean
        , o_pvk_index               out com_api_type_pkg.t_tiny_id
        , o_service_code            out com_api_type_pkg.t_dict_value
    )  return com_api_type_pkg.t_dict_value;

    function get_virtual_card_types (
        i_source_card_id            in com_api_type_pkg.t_medium_id
        , i_lang                    in com_api_type_pkg.t_dict_value
        , o_card_types              out com_api_type_pkg.t_card_type_tab
    )  return com_api_type_pkg.t_dict_value;
    
    procedure get_connected_virtual_cards (
        i_card_number       in  com_api_type_pkg.t_card_number
        , i_card_status     in  com_api_type_pkg.t_dict_value   default null
        , o_card_numbers    out com_api_type_pkg.t_card_number_tab
    );

    procedure issue_virtual_card (
        i_card_instance_id          in      com_api_type_pkg.t_medium_id
      , i_card_type_id              in      com_api_type_pkg.t_tiny_id      default null
      , i_expir_date                in      date                            default null
      , i_limit_type                in      com_api_type_pkg.t_dict_value   default null
      , i_usage_limit_count         in      com_api_type_pkg.t_long_id      default null
      , i_usage_limit_amount        in      com_api_type_pkg.t_money        
      , i_usage_limit_currency      in      com_api_type_pkg.t_curr_code    default null
      , i_card_number               in      com_api_type_pkg.t_card_number  default null
      , i_account_id                in      com_api_type_pkg.t_medium_id    default null
    );

    procedure reconnect_virtual_card (
        i_card_id                   in      com_api_type_pkg.t_long_id
      , i_parent_card_id            in      com_api_type_pkg.t_medium_id
      , i_customer_id               in      com_api_type_pkg.t_medium_id
      , i_contract_id               in      com_api_type_pkg.t_long_id
      , i_cardholder_id             in      com_api_type_pkg.t_long_id
      , i_expir_date                in      date                            default null
      , i_split_hash                in      com_api_type_pkg.t_tiny_id
      , i_card_type_id              in      com_api_type_pkg.t_tiny_id
      , i_inst_id                   in      com_api_type_pkg.t_tiny_id
      , i_limit_type                in      com_api_type_pkg.t_dict_value   default null
      , i_usage_limit_count         in      com_api_type_pkg.t_long_id      default null
      , i_usage_limit_amount        in      com_api_type_pkg.t_money        
      , i_usage_limit_currency      in      com_api_type_pkg.t_curr_code    default null
      , i_card_number               in      com_api_type_pkg.t_card_number  default null
      , i_account_id                in      com_api_type_pkg.t_medium_id    default null
    );


end;
/
