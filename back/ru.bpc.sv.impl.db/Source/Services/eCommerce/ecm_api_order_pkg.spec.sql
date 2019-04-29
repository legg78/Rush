create or replace package ecm_api_order_pkg as

procedure add_order (
      o_id                  out com_api_type_pkg.t_long_id
    , i_merchant_id         in  com_api_type_pkg.t_short_id
    , i_order_number        in  com_api_type_pkg.t_name
    , i_order_details       in  com_api_type_pkg.t_full_desc    
    , i_customer_identifier in  com_api_type_pkg.t_name
    , i_customer_name       in  com_api_type_pkg.t_name
    , i_order_uuid          in  com_api_type_pkg.t_name
    , i_success_url         in  com_api_type_pkg.t_name
    , i_fail_url            in  com_api_type_pkg.t_name
    , i_customer_number     in  com_api_type_pkg.t_name
    , i_entity_type         in  com_api_type_pkg.t_dict_value
    , i_object_id           in  com_api_type_pkg.t_long_id
    , i_purpose_id          in  com_api_type_pkg.t_short_id
    , i_template_id         in  com_api_type_pkg.t_tiny_id
    , i_amount              in  com_api_type_pkg.t_money
    , i_currency            in  com_api_type_pkg.t_curr_code
    , i_event_date          in  date    
    , i_status              in  com_api_type_pkg.t_dict_value
    , i_inst_id             in  com_api_type_pkg.t_inst_id
);

procedure modify_order (
      i_id                  in  com_api_type_pkg.t_long_id
    , i_purpose_id          in  com_api_type_pkg.t_short_id     default null
    , i_status              in  com_api_type_pkg.t_dict_value 
);

procedure choose_host(
    i_purpose_id            in      com_api_type_pkg.t_short_id
  , i_network_id            in      com_api_type_pkg.t_tiny_id  default null
  , o_host_id                  out  com_api_type_pkg.t_tiny_id
);

end ecm_api_order_pkg;
/
