create or replace package jcb_utl_pkg is

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
    
    procedure get_jcb_transaction_type (
        i_oper_type          in com_api_type_pkg.t_dict_value
        , i_mcc              in com_api_type_pkg.t_mcc
        , o_de003_1          out jcb_api_type_pkg.t_de003s
        , i_standard_version in com_api_type_pkg.t_tiny_id default null
    );
    
    function get_message_impact (
        i_mti               in jcb_api_type_pkg.t_mti
        , i_de024           in jcb_api_type_pkg.t_de024
        , i_de003_1         in jcb_api_type_pkg.t_de003s
        , i_is_reversal     in com_api_type_pkg.t_boolean
        , i_is_incoming     in com_api_type_pkg.t_boolean
    ) return com_api_type_pkg.t_sign 
        result_cache;
        
    procedure add_curr_exp (
        io_p3002                in out jcb_api_type_pkg.t_p3002
        , i_curr_code           in com_api_type_pkg.t_curr_code
    );
    
    function get_arn(
        i_prefix            in      varchar2        default '7'
      , i_acquirer_bin      in      varchar2
      , i_proc_date         in      date            default null
    ) return varchar2;

end;
/
