create or replace package cst_smt_prc_cb_outgoing_pkg is
/************************************************************
 * Custom upload clearing file for CB of Tunisia
 ************************************************************/
 
    function get_tran_channal (
        i_terminal_type com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_one_char
    result_cache;
    
    function get_device_type (
        i_terminal_type com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_one_char
    result_cache;    
    
    function get_tran_code (
        i_oper_type                  com_api_type_pkg.t_dict_value
        , i_invoice                  com_api_type_pkg.t_name
        , i_is_domestic_file_type    com_api_type_pkg.t_boolean :=  com_api_const_pkg.TRUE  
    ) return com_api_type_pkg.t_byte_char
    result_cache;
    
    function get_merchant_type (
        i_terminal_type       com_api_type_pkg.t_dict_value
        , i_oper_type         com_api_type_pkg.t_dict_value
        , i_merchant_param    com_api_type_pkg.t_name
    ) return com_api_type_pkg.t_one_char
    result_cache;
 
    function get_convertation (
        i_array_type_id     in      com_api_type_pkg.t_tiny_id
        , i_array_id          in      com_api_type_pkg.t_short_id
        , i_elem_value        in      com_api_type_pkg.t_name
        , i_retun_def_value   in      com_api_type_pkg.t_name default null
    ) return com_api_type_pkg.t_name 
    result_cache; 
 
    procedure upload_domestic_clearing (
        i_inst_id          in com_api_type_pkg.t_inst_id := null
    );
    
    procedure upload_international_clearing (
        i_inst_id          in com_api_type_pkg.t_inst_id
    );

    procedure upload_settlement (
        i_sttl_date        in date := null
    );

end;
/
