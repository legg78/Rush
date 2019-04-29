create or replace package ecm_api_linked_card_pkg as

procedure add_linked_card (
      o_id                  out com_api_type_pkg.t_long_id
    , i_entity_type     in      com_api_type_pkg.t_dict_value
    , i_object_id       in      com_api_type_pkg.t_long_id
    , i_cardholder_name in      com_api_type_pkg.t_name
    , i_expiration_date in      date
    , i_card_network_id in      com_api_type_pkg.t_network_id
    , i_card_inst_id    in      com_api_type_pkg.t_inst_id
    , i_iss_network_id  in      com_api_type_pkg.t_network_id
    , i_iss_inst_id     in      com_api_type_pkg.t_inst_id
    , i_status          in      com_api_type_pkg.t_dict_value
    , i_card_number     in      com_api_type_pkg.t_card_number
    , i_cvv_cvc         in      com_api_type_pkg.t_tiny_id
    , i_auth_id         in      com_api_type_pkg.t_long_id := null
);

procedure remove_linked_card (
      i_id              in      com_api_type_pkg.t_long_id
);

procedure get_hold_amount (
      io_currency       in  out com_api_type_pkg.t_curr_code
    , o_amount              out com_api_type_pkg.t_money  
);

procedure modify_card_status (
      i_id              in      com_api_type_pkg.t_long_id
    , i_status          in      com_api_type_pkg.t_dict_value  
);

procedure get_linked_cards(
    i_customer_number       in      com_api_type_pkg.t_name
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_status                in      com_api_type_pkg.t_dict_value       default null
  , o_linked_card_ref          out  com_api_type_pkg.t_ref_cur
);

procedure get_linked_card_data(
    i_linked_card_id        in      com_api_type_pkg.t_name
  , o_customer_id              out  com_api_type_pkg.t_medium_id
  , o_account_id               out  com_api_type_pkg.t_name
  , o_account_number           out  com_api_type_pkg.t_account_number
  , o_card_network_id          out  com_api_type_pkg.t_tiny_id            
  , o_card_inst_id             out  com_api_type_pkg.t_inst_id            
  , o_iss_network_id           out  com_api_type_pkg.t_tiny_id            
  , o_iss_inst_id              out  com_api_type_pkg.t_inst_id            
);

end ecm_api_linked_card_pkg;
/
