create or replace package prs_api_util_pkg is

    function is_byte_multiple (
        i_string                in com_api_type_pkg.t_lob_data
    ) return com_api_type_pkg.t_boolean;
    
    function pad_num (
        i_number                in com_api_type_pkg.t_tiny_id
        , i_length              in com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_lob_data;
        
    function hex2bin (
        i_hex_string            in com_api_type_pkg.t_lob_data
    ) return com_api_type_pkg.t_lob_data;
    
    function bin2hex (
        i_bin_string            in com_api_type_pkg.t_lob_data
    ) return com_api_type_pkg.t_lob_data;

    function bin2hex2 (
        i_bin_string            in com_api_type_pkg.t_text
    ) return com_api_type_pkg.t_lob_data;

    function dec2hex (
        i_dec_number            in number
    ) return com_api_type_pkg.t_lob_data;
    
    function hex2dec (
        i_hex_string            in com_api_type_pkg.t_lob_data
    ) return number;

    function ber_tlv_length (
        i_string                in com_api_type_pkg.t_lob_data
    ) return com_api_type_pkg.t_lob_data;

    function hex_shift_left_nocycle (
        i_hex_string            in com_api_type_pkg.t_lob_data
        , i_bits                in com_api_type_pkg.t_tiny_id := 1
    ) return com_api_type_pkg.t_lob_data;

    function convert_data (
        i_data                 in varchar2
        , i_charset            in com_api_type_pkg.t_oracle_name
    ) return varchar2;

end;
/
