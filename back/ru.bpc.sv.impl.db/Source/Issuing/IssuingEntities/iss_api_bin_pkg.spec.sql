create or replace package iss_api_bin_pkg is

    procedure get_bin_info(
        i_card_number          in com_api_type_pkg.t_card_number
      , i_oper_type            in com_api_type_pkg.t_dict_value     default null
      , i_terminal_type        in com_api_type_pkg.t_dict_value     default null
      , i_acq_inst_id          in com_api_type_pkg.t_inst_id        default null
      , i_acq_network_id       in com_api_type_pkg.t_inst_id        default null
      , i_msg_type             in com_api_type_pkg.t_dict_value     default null
      , i_oper_reason          in com_api_type_pkg.t_dict_value     default null
      , i_oper_currency        in com_api_type_pkg.t_curr_code      default null
      , i_merchant_id          in com_api_type_pkg.t_short_id       default null
      , i_terminal_id          in com_api_type_pkg.t_short_id       default null   
      , o_iss_inst_id         out com_api_type_pkg.t_inst_id
      , o_iss_network_id      out com_api_type_pkg.t_tiny_id
      , o_iss_host_id         out com_api_type_pkg.t_tiny_id
      , o_card_type_id        out com_api_type_pkg.t_tiny_id
      , o_card_country        out com_api_type_pkg.t_curr_code
      , o_card_inst_id        out com_api_type_pkg.t_inst_id
      , o_card_network_id     out com_api_type_pkg.t_tiny_id
      , o_pan_length          out com_api_type_pkg.t_tiny_id
      , i_raise_error          in com_api_type_pkg.t_boolean        := com_api_const_pkg.TRUE
    );

    procedure get_bin_info(
        i_card_number          in com_api_type_pkg.t_card_number
      , o_iss_inst_id         out com_api_type_pkg.t_inst_id
      , o_iss_network_id      out com_api_type_pkg.t_tiny_id
      , o_card_inst_id        out com_api_type_pkg.t_inst_id
      , o_card_network_id     out com_api_type_pkg.t_tiny_id
      , o_card_type           out com_api_type_pkg.t_tiny_id
      , o_card_country        out com_api_type_pkg.t_country_code
      , o_bin_currency        out com_api_type_pkg.t_curr_code
      , o_sttl_currency       out com_api_type_pkg.t_curr_code
      , i_raise_error          in  com_api_type_pkg.t_boolean       := com_api_const_pkg.FALSE
    );
    
    procedure get_bin_info(
        i_card_number          in com_api_type_pkg.t_card_number
      , o_card_inst_id        out com_api_type_pkg.t_inst_id
      , o_card_network_id     out com_api_type_pkg.t_tiny_id
      , o_card_type           out com_api_type_pkg.t_tiny_id
      , o_card_country        out com_api_type_pkg.t_curr_code
      , i_raise_error          in com_api_type_pkg.t_boolean        := com_api_const_pkg.TRUE
    );
    
    function get_bin(
        i_bin_id               in com_api_type_pkg.t_short_id
    ) return iss_api_type_pkg.t_bin_rec;
    
    function get_bin(
        i_bin                  in com_api_type_pkg.t_bin
      , i_mask_error           in com_api_type_pkg.t_boolean        := com_api_type_pkg.FALSE
    ) return iss_api_type_pkg.t_bin_rec;
    
    function get_bin(
        i_card_number        in com_api_type_pkg.t_card_number
      , i_inst_id            in    com_api_type_pkg.t_inst_id       := ost_api_const_pkg.DEFAULT_INST
    ) return iss_api_type_pkg.t_bin_rec;

    function get_bin_number(
        i_bin_id               in com_api_type_pkg.t_short_id
    ) return com_api_type_pkg.t_bin;

    function is_bin_ok(
        i_card_number          in com_api_type_pkg.t_card_number
      , i_card_type_id         in com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_boolean;
    
end;
/
