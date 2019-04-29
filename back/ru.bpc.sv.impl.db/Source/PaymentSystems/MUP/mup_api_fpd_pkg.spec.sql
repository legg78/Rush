create or replace package mup_api_fpd_pkg is

    procedure create_incoming_fpd (
        i_mes_rec               in mup_api_type_pkg.t_mes_rec
        , i_file_id             in com_api_type_pkg.t_short_id
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_host_id             in com_api_type_pkg.t_tiny_id
        , i_standard_id         in com_api_type_pkg.t_tiny_id
    );
       
    procedure create_incoming_fsum (
        i_mes_rec               in mup_api_type_pkg.t_mes_rec
        , i_file_id             in com_api_type_pkg.t_short_id
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_host_id             in com_api_type_pkg.t_tiny_id
        , i_standard_id         in com_api_type_pkg.t_tiny_id
    );

end; 
/
