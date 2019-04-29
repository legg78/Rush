create or replace package mcw_api_currency_pkg is

    procedure put_message (
        i_cur_update_rec        in mcw_api_type_pkg.t_cur_update_rec
    );
    
    procedure put_currency_rate (
        i_msg_id                in com_api_type_pkg.t_long_id
        , i_cur_rate_tab        in mcw_api_type_pkg.t_cur_rate_tab
    );

    procedure create_incoming_currency (
        i_mes_rec               in mcw_api_type_pkg.t_mes_rec
        , i_file_id             in com_api_type_pkg.t_short_id
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_host_id             in com_api_type_pkg.t_tiny_id
        , i_standard_id         in com_api_type_pkg.t_tiny_id
    );

end; 
/
