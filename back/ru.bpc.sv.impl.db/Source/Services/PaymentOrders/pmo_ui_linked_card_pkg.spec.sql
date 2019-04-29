create or replace package pmo_ui_linked_card_pkg as

procedure get_linked_cards(
    i_customer_number       in      com_api_type_pkg.t_name
  , i_account_number        in      com_api_type_pkg.t_account_number
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_status                in      com_api_type_pkg.t_dict_value       default null
  , o_linked_card_ref          out  com_api_type_pkg.t_ref_cur
);

procedure get_linked_card_data(
    i_linked_card_id        in      com_api_type_pkg.t_name
  , o_customer_id              out  com_api_type_pkg.t_medium_id
  , o_account_id               out  com_api_type_pkg.t_medium_id
  , o_account_number           out  com_api_type_pkg.t_account_number
  , o_card_network_id          out  com_api_type_pkg.t_tiny_id            
  , o_card_inst_id             out  com_api_type_pkg.t_inst_id            
  , o_iss_network_id           out  com_api_type_pkg.t_tiny_id            
  , o_iss_inst_id              out  com_api_type_pkg.t_inst_id            
);

procedure link_card(
    i_customer_id           in      com_api_type_pkg.t_medium_id
  , i_account_id            in      com_api_type_pkg.t_medium_id
  , i_external_customer_id  in      com_api_type_pkg.t_name
  , i_card_mask             in      com_api_type_pkg.t_card_number
  , i_cardholder_name       in      com_api_type_pkg.t_name
  , i_expiration_date       in      date
  , i_card_network_id       in      com_api_type_pkg.t_tiny_id
  , i_card_inst_id          in      com_api_type_pkg.t_inst_id
  , i_iss_network_id        in      com_api_type_pkg.t_tiny_id
  , i_iss_inst_id           in      com_api_type_pkg.t_inst_id
  , i_status                in      com_api_type_pkg.t_dict_value
);

procedure unlink_card(
    i_customer_number       in      com_api_type_pkg.t_name
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_linked_card_id        in      com_api_type_pkg.t_name
);

end;
/
