create or replace package net_api_bin_pkg is

    BIN_INDEX_LENGTH               constant number := 5;

    procedure get_bin_info (
        i_card_number              in     com_api_type_pkg.t_card_number
        , i_oper_type              in     com_api_type_pkg.t_dict_value   default null
        , i_terminal_type          in     com_api_type_pkg.t_dict_value   default null
        , i_acq_inst_id            in     com_api_type_pkg.t_inst_id      default null
        , i_acq_network_id         in     com_api_type_pkg.t_inst_id      default null
        , i_msg_type               in     com_api_type_pkg.t_dict_value   default null
        , i_oper_reason            in     com_api_type_pkg.t_dict_value   default null
        , i_oper_currency          in     com_api_type_pkg.t_curr_code    default null
        , i_merchant_id            in     com_api_type_pkg.t_short_id     default null
        , i_terminal_id            in     com_api_type_pkg.t_short_id     default null           
        , io_iss_inst_id           in out com_api_type_pkg.t_inst_id
        , o_iss_network_id            out com_api_type_pkg.t_tiny_id
        , o_iss_host_id               out com_api_type_pkg.t_tiny_id
        , o_card_type_id              out com_api_type_pkg.t_tiny_id
        , o_card_country              out com_api_type_pkg.t_curr_code
        , o_card_inst_id              out com_api_type_pkg.t_inst_id
        , o_card_network_id           out com_api_type_pkg.t_tiny_id
        , o_pan_length                out com_api_type_pkg.t_tiny_id
        , i_raise_error            in     com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
    );

    procedure get_bin_info (
        i_card_number              in     com_api_type_pkg.t_card_number
        , i_oper_type              in     com_api_type_pkg.t_dict_value   default null
        , i_terminal_type          in     com_api_type_pkg.t_dict_value   default null
        , i_acq_inst_id            in     com_api_type_pkg.t_inst_id      default null
        , i_acq_network_id         in     com_api_type_pkg.t_inst_id      default null
        , i_msg_type               in     com_api_type_pkg.t_dict_value   default null
        , i_oper_reason            in     com_api_type_pkg.t_dict_value   default null
        , i_oper_currency          in     com_api_type_pkg.t_curr_code    default null
        , i_merchant_id            in     com_api_type_pkg.t_short_id     default null
        , i_terminal_id            in     com_api_type_pkg.t_short_id     default null           
        , o_iss_inst_id               out com_api_type_pkg.t_inst_id
        , o_iss_network_id            out com_api_type_pkg.t_tiny_id
        , o_iss_host_id               out com_api_type_pkg.t_tiny_id
        , o_card_type_id              out com_api_type_pkg.t_tiny_id
        , o_card_country              out com_api_type_pkg.t_curr_code
        , o_card_inst_id              out com_api_type_pkg.t_inst_id
        , o_card_network_id           out com_api_type_pkg.t_tiny_id
        , o_pan_length                out com_api_type_pkg.t_tiny_id
        , i_raise_error            in     com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
    );

    procedure get_bin_info (
        i_card_number              in     com_api_type_pkg.t_card_number
        , i_network_id             in     com_api_type_pkg.t_tiny_id
        , o_iss_inst_id               out com_api_type_pkg.t_inst_id
        , o_iss_host_id               out com_api_type_pkg.t_tiny_id
        , o_card_type_id              out com_api_type_pkg.t_tiny_id
        , o_card_country              out com_api_type_pkg.t_curr_code
        , o_card_inst_id              out com_api_type_pkg.t_inst_id
        , o_card_network_id           out com_api_type_pkg.t_tiny_id
        , o_pan_length                out com_api_type_pkg.t_tiny_id
        , i_raise_error            in     com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
    );

    procedure add_bin_range(
        i_pan_low                  in     com_api_type_pkg.t_card_number
        , i_pan_high               in     com_api_type_pkg.t_card_number        
        , i_country                in     com_api_type_pkg.t_curr_name
        , i_network_id             in     com_api_type_pkg.t_tiny_id
        , i_inst_id                in     com_api_type_pkg.t_inst_id
        , i_pan_length             in     com_api_type_pkg.t_tiny_id
        , i_network_card_type      in     com_api_type_pkg.t_dict_value
        , i_card_network_id        in     com_api_type_pkg.t_network_id   default null
        , i_card_inst_id           in     com_api_type_pkg.t_inst_id      default null
        , i_module_code            in     com_api_type_pkg.t_module_code  default null
        , i_priority               in     com_api_type_pkg.t_tiny_id      default 1
        , i_activation_date        in     date                            default null
        , i_card_type_id           in     com_api_type_pkg.t_tiny_id      default null
    );
    
    procedure sync_local_bins;

    procedure rebuild_bin_index;

    procedure get_substitution_host (
        i_card_number              in     com_api_type_pkg.t_card_number
        , i_oper_type              in     com_api_type_pkg.t_dict_value   default null
        , i_terminal_type          in     com_api_type_pkg.t_dict_value   default null
        , i_acq_inst_id            in     com_api_type_pkg.t_inst_id      default null
        , i_acq_network_id         in     com_api_type_pkg.t_inst_id      default null
        , i_msg_type               in     com_api_type_pkg.t_dict_value   default null
        , i_oper_reason            in     com_api_type_pkg.t_dict_value   default null
        , i_oper_currency          in     com_api_type_pkg.t_curr_code    default null
        , i_merchant_id            in     com_api_type_pkg.t_short_id     default null
        , i_terminal_id            in     com_api_type_pkg.t_short_id     default null   
        , i_card_inst_id           in     com_api_type_pkg.t_inst_id      default null
        , i_card_network_id        in     com_api_type_pkg.t_inst_id      default null
        , i_iss_inst_id            in     com_api_type_pkg.t_inst_id      default null
        , i_iss_network_id         in     com_api_type_pkg.t_tiny_id      default null
        , i_iss_host_id            in     com_api_type_pkg.t_tiny_id      default null
        , o_substitution_inst_id      out com_api_type_pkg.t_inst_id     
        , o_substitution_network_id   out com_api_type_pkg.t_inst_id    
        , o_substitution_host_id      out com_api_type_pkg.t_inst_id
        , i_card_country           in     com_api_type_pkg.t_country_code default null
    );

    /*
     * It checks network BIN ranges' collection and raises an error if some check is failed.
     */
    procedure check_bin_range(
        i_bin_range_tab            in     net_api_type_pkg.t_net_bin_range_tab
    );
    
    procedure cleanup_network_bins(
        i_network_id                in     com_api_type_pkg.t_tiny_id
    );

end;
/
