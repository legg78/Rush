create or replace package iss_prc_import_pkg as

procedure import_cards_status(
    i_unload_file           in      com_api_type_pkg.t_boolean default null
  , i_masking_card          in      com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
);

procedure import_card_black_list(
    i_downloading_type  in     com_api_type_pkg.t_dict_value
);

/*
* Load cards' security data in according with svxp_card_secure.xsd specification.
* @param i_card_state - new card instance state which will be used for all processing instances 
*/
procedure import_cards_security_data(
    i_card_state        in     com_api_type_pkg.t_dict_value default null
);

end;
/
