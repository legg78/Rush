create or replace package mcw_utl_pkg is

    function bitor(x in binary_integer, y in binary_integer) return binary_integer;

    function pad_number (
        i_data              in varchar2
        , i_min_length      in integer
        , i_max_length      in integer
    ) return varchar2;
    
    function pad_char (
        i_data              in varchar2
        , i_min_length      in integer
        , i_max_length      in integer
    ) return varchar2;
    
    procedure get_ipm_transaction_type (
        i_oper_type         in com_api_type_pkg.t_dict_value
        , i_mcc             in com_api_type_pkg.t_mcc
        , o_de003_1         out mcw_api_type_pkg.t_de003s
        , o_p0043           out mcw_api_type_pkg.t_p0043
    );

    function get_message_impact (
        i_mti               in mcw_api_type_pkg.t_mti
        , i_de024           in mcw_api_type_pkg.t_de024
        , i_de003_1         in mcw_api_type_pkg.t_de003s
        , i_is_reversal     in com_api_type_pkg.t_boolean
        , i_is_incoming     in com_api_type_pkg.t_boolean
    ) return com_api_type_pkg.t_sign 
        result_cache;
    
    function build_nrn (
        i_netw_refnum           in varchar2
        , i_netw_date           in date
    ) return mcw_api_type_pkg.t_de063;
    
    function build_irn return mcw_api_type_pkg.t_de095;

    procedure add_curr_exp (
        io_p0148                in out mcw_api_type_pkg.t_p0148
        , i_curr_code           in com_api_type_pkg.t_curr_code
    );

    function get_acq_cmid (
        i_iss_inst_id           in com_api_type_pkg.t_inst_id
      , i_iss_network_id        in com_api_type_pkg.t_tiny_id
      , i_inst_id               in com_api_type_pkg.t_inst_id
    ) return com_api_type_pkg.t_cmid;

    function get_iss_cmid (
        i_card_number           in com_api_type_pkg.t_card_number
    ) return com_api_type_pkg.t_cmid;

    function get_iss_product (
        i_card_number           in com_api_type_pkg.t_card_number
    ) return com_api_type_pkg.t_curr_code;

    function get_usd_rate (
        i_impact                in com_api_type_pkg.t_sign
        , i_curr_code           in com_api_type_pkg.t_curr_code
    ) return number;
    
    procedure get_bin_range_data(
        i_card_number           in     com_api_type_pkg.t_card_number
      , i_card_type_id          in     com_api_type_pkg.t_tiny_id
      , o_product_id               out com_api_type_pkg.t_dict_value
      , o_brand                    out com_api_type_pkg.t_dict_value
      , o_region                   out com_api_type_pkg.t_dict_value
      , o_product_type             out com_api_type_pkg.t_dict_value
    );

end;
/
