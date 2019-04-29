create or replace package net_ui_host_substitution_pkg is

procedure add(
        o_id                        out     com_api_type_pkg.t_medium_id
      , o_seqnum                    out     com_api_type_pkg.t_inst_id
      , i_oper_type                 in      com_api_type_pkg.t_dict_value
      , i_terminal_type             in      com_api_type_pkg.t_dict_value
      , i_pan_low                   in      com_api_type_pkg.t_bin
      , i_pan_high                  in      com_api_type_pkg.t_bin
      , i_acq_inst_id               in      com_api_type_pkg.t_mcc
      , i_acq_network_id            in      com_api_type_pkg.t_mcc
      , i_card_inst_id              in      com_api_type_pkg.t_mcc
      , i_card_network_id           in      com_api_type_pkg.t_mcc
      , i_iss_inst_id               in      com_api_type_pkg.t_mcc
      , i_iss_network_id            in      com_api_type_pkg.t_mcc
      , i_priority                  in      com_api_type_pkg.t_inst_id
      , i_substitution_inst_id      in      com_api_type_pkg.t_mcc
      , i_substitution_network_id   in      com_api_type_pkg.t_mcc
      , i_msg_type                  in      com_api_type_pkg.t_dict_value
      , i_oper_reason               in      com_api_type_pkg.t_dict_value
      , i_oper_currency             in      com_api_type_pkg.t_curr_code
      , i_merchant_array_id         in      com_api_type_pkg.t_dict_value
      , i_terminal_array_id         in      com_api_type_pkg.t_dict_value    
      , i_card_country              in      com_api_type_pkg.t_country_code  default null
);

procedure modify(
        i_id                        in      com_api_type_pkg.t_medium_id
      , io_seqnum                   in out  com_api_type_pkg.t_inst_id
      , i_oper_type                 in      com_api_type_pkg.t_dict_value
      , i_terminal_type             in      com_api_type_pkg.t_dict_value
      , i_pan_low                   in      com_api_type_pkg.t_bin
      , i_pan_high                  in      com_api_type_pkg.t_bin
      , i_acq_inst_id               in      com_api_type_pkg.t_mcc
      , i_acq_network_id            in      com_api_type_pkg.t_mcc
      , i_card_inst_id              in      com_api_type_pkg.t_mcc
      , i_card_network_id           in      com_api_type_pkg.t_mcc
      , i_iss_inst_id               in      com_api_type_pkg.t_mcc
      , i_iss_network_id            in      com_api_type_pkg.t_mcc
      , i_priority                  in      com_api_type_pkg.t_inst_id
      , i_substitution_inst_id      in      com_api_type_pkg.t_mcc
      , i_substitution_network_id   in      com_api_type_pkg.t_mcc
      , i_msg_type                  in      com_api_type_pkg.t_dict_value
      , i_oper_reason               in      com_api_type_pkg.t_dict_value
      , i_oper_currency             in      com_api_type_pkg.t_curr_code
      , i_merchant_array_id         in      com_api_type_pkg.t_dict_value
      , i_terminal_array_id         in      com_api_type_pkg.t_dict_value
      , i_card_country              in      com_api_type_pkg.t_country_code    default null  
);

procedure remove (
    i_id                            in com_api_type_pkg.t_medium_id
    , i_seqnum                      in com_api_type_pkg.t_inst_id
);

end;
/