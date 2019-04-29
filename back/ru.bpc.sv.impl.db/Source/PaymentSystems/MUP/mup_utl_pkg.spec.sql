create or replace package mup_utl_pkg is

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
        i_oper_type       in     com_api_type_pkg.t_dict_value
      , i_mcc             in     com_api_type_pkg.t_mcc
      , i_de022_5         in     mup_api_type_pkg.t_de022s
      , i_current_version in     com_api_type_pkg.t_tiny_id
      , o_de003_1            out mup_api_type_pkg.t_de003s
    );
    
    function get_message_impact (
        i_mti               in mup_api_type_pkg.t_mti
        , i_de024           in mup_api_type_pkg.t_de024
        , i_de003_1         in mup_api_type_pkg.t_de003s
        , i_is_reversal     in com_api_type_pkg.t_boolean
        , i_is_incoming     in com_api_type_pkg.t_boolean
    ) return com_api_type_pkg.t_sign 
        result_cache;
    
    function build_nrn (
        i_netw_refnum           in varchar2
    ) return mup_api_type_pkg.t_de063;
    
    function build_irn return mup_api_type_pkg.t_de095;

    procedure add_curr_exp (
        io_p0148                in out mup_api_type_pkg.t_p0148
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

    function get_p2158_1(
        i_iss_network_id        in com_api_type_pkg.t_tiny_id
    ) return mup_api_type_pkg.t_p2158_1;
    
    procedure redefine_iss_networkd_id(
        io_network_id         in out com_api_type_pkg.t_tiny_id
      , i_emv_data            in     com_api_type_pkg.t_text
    );

end;
/
