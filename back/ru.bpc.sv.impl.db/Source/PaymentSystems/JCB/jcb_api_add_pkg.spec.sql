create or replace package jcb_api_add_pkg is

    procedure enum_messages_for_upload (
        i_fin_id                in            com_api_type_pkg.t_long_id
        , o_add_tab             in out nocopy jcb_api_type_pkg.t_add_tab
    );

    function pack_message (
        i_add_rec               in jcb_api_type_pkg.t_add_rec
        , i_file_id             in com_api_type_pkg.t_short_id
        , i_de071               in jcb_api_type_pkg.t_de071
        , i_fin_de071           in jcb_api_type_pkg.t_de071
        , i_add_seqnum          in jcb_api_type_pkg.t_de071
        , i_with_rdw            in com_api_type_pkg.t_boolean     := null
    ) return blob;

    procedure mark_uploaded (
        i_rowid                 in com_api_type_pkg.t_rowid_tab
        , i_file_id             in com_api_type_pkg.t_number_tab 
        , i_de071               in com_api_type_pkg.t_number_tab
        , i_fin_de071           in com_api_type_pkg.t_number_tab
        , i_add_seqnum          in com_api_type_pkg.t_number_tab
    );

    procedure create_incoming_addendum (
        i_mes_rec               in jcb_api_type_pkg.t_mes_rec
        , i_file_id             in com_api_type_pkg.t_short_id
        , i_fin_id              in com_api_type_pkg.t_long_id
        , i_network_id          in com_api_type_pkg.t_tiny_id
    );

    procedure create_outgoing_addendum (
        i_fin_rec               in jcb_api_type_pkg.t_fin_rec
    );

end;
/
