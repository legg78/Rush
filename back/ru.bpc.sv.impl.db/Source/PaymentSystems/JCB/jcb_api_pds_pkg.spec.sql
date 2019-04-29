create or replace package jcb_api_pds_pkg is

    procedure extract_pds
    (   de048                   in jcb_api_type_pkg.t_de048
        , de062                 in jcb_api_type_pkg.t_de062
        , de123                 in jcb_api_type_pkg.t_de123
        , de124                 in jcb_api_type_pkg.t_de124
        , de125                 in jcb_api_type_pkg.t_de125
        , de126                 in jcb_api_type_pkg.t_de126
        , pds_tab               in out nocopy jcb_api_type_pkg.t_pds_tab
    );
    
    procedure format_pds
    (   pds_tab                 in jcb_api_type_pkg.t_pds_tab
        , de048                 out jcb_api_type_pkg.t_de048
        , de062                 out jcb_api_type_pkg.t_de062
        , de123                 out jcb_api_type_pkg.t_de123
        , de124                 out jcb_api_type_pkg.t_de124
        , de125                 out jcb_api_type_pkg.t_de125
        , de126                 out jcb_api_type_pkg.t_de126
    );
    
    function get_pds_body (
        i_pds_tab               in jcb_api_type_pkg.t_pds_tab
        , i_pds_tag             in jcb_api_type_pkg.t_pds_tag
    ) return jcb_api_type_pkg.t_pds_body;
    
    procedure set_pds_body (
        io_pds_tab              in out nocopy jcb_api_type_pkg.t_pds_tab
        , i_pds_tag             in jcb_api_type_pkg.t_pds_tag
        , i_pds_body            in jcb_api_type_pkg.t_pds_body
    );
    
    procedure read_pds (
        i_msg_id                in com_api_type_pkg.t_long_id
        , o_pds_tab             in out nocopy jcb_api_type_pkg.t_pds_tab
    );             

    procedure save_pds (
        i_msg_id                in com_api_type_pkg.t_long_id
        , i_pds_tab             in out nocopy jcb_api_type_pkg.t_pds_tab
        , i_clear               in com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE
    );
    
    procedure parse_p3901 (   
        i_p3901               in jcb_api_type_pkg.t_pds_body
        , o_p3901_1           out jcb_api_type_pkg.t_p3901_1
        , o_p3901_2           out jcb_api_type_pkg.t_p3901_2
        , o_p3901_3           out jcb_api_type_pkg.t_p3901_3
        , o_p3901_4           out jcb_api_type_pkg.t_p3901_4
    );

    procedure parse_p3005 (   
        i_p3005               in jcb_api_type_pkg.t_pds_body
        , i_fin_rec_id        in com_api_type_pkg.t_long_id
        , o_p3005_tab         in out nocopy jcb_api_type_pkg.t_p3005_tab
    );
    
    procedure parse_p3007 (
        i_p3007                 in jcb_api_type_pkg.t_pds_body
        , o_p3007_1             out jcb_api_type_pkg.t_p3007_1
        , o_p3007_2             out jcb_api_type_pkg.t_p3007_2
    );
    
    procedure parse_p3600 (
        i_p3600                 in jcb_api_type_pkg.t_pds_body
        , o_p3600_1             out jcb_api_type_pkg.t_p3600_1
        , o_p3600_2             out jcb_api_type_pkg.t_p3600_2
        , o_p3600_3             out jcb_api_type_pkg.t_p3600_3
    );
    
    procedure save_p3005 (
        i_msg_id                in com_api_type_pkg.t_long_id
        , i_p3005_tab           in jcb_api_type_pkg.t_p3005_tab
    );
    
    function format_p3007(
        i_p3007_1               in jcb_api_type_pkg.t_p3007_1
        , i_p3007_2             in jcb_api_type_pkg.t_p3007_2
    ) return jcb_api_type_pkg.t_pds_body;
    
end;
/
