create or replace package mcw_api_add_pkg is

    procedure enum_messages_for_upload (
        i_fin_id                in            com_api_type_pkg.t_long_id
        , o_add_tab             in out nocopy mcw_api_type_pkg.t_add_tab
    );

    procedure pack_message (
        i_add_rec               in mcw_api_type_pkg.t_add_rec
        , i_file_id             in com_api_type_pkg.t_short_id
        , i_de071               in mcw_api_type_pkg.t_de071
        , i_fin_de071           in mcw_api_type_pkg.t_de071
        , o_raw_data            out varchar2
        , i_charset             in com_api_type_pkg.t_oracle_name := null
    );

    procedure mark_uploaded (
        i_rowid                 in com_api_type_pkg.t_rowid_tab
        , i_file_id             in com_api_type_pkg.t_number_tab 
        , i_de071               in com_api_type_pkg.t_number_tab
        , i_fin_de071           in com_api_type_pkg.t_number_tab
    );

    procedure create_incoming_addendum (
        i_mes_rec               in mcw_api_type_pkg.t_mes_rec
        , i_file_id             in com_api_type_pkg.t_short_id
        , i_fin_id              in com_api_type_pkg.t_long_id
        , i_network_id          in com_api_type_pkg.t_tiny_id
    );

    procedure create_outgoing_addendum (
        i_fin_rec               in mcw_api_type_pkg.t_fin_rec
    );

end;
/
 