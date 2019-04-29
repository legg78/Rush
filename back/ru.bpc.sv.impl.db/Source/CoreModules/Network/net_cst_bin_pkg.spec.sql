create or replace package net_cst_bin_pkg is

    function bin_table_scan_priority (
        i_network_id            in com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_tiny_id;

    function extra_scan_priority (
        i_card_number           in com_api_type_pkg.t_card_number
        , i_network_id          in com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_tiny_id;

    function advances_scan_priority (
        i_card_number           in com_api_type_pkg.t_card_number
        , i_pan_low             in com_api_type_pkg.t_card_number
        , i_network_id          in com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_tiny_id ;

end;
/
