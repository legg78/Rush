create or replace package iss_ui_bin_index_range_pkg is

    procedure add_iss_bin_index_range (
        o_id                        out com_api_type_pkg.t_short_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_bin_id                  in com_api_type_pkg.t_short_id
        , i_index_range_id          in com_api_type_pkg.t_short_id
    );

    procedure modify_iss_bin_index_range (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_bin_id                  in com_api_type_pkg.t_short_id
        , i_index_range_id          in com_api_type_pkg.t_short_id
    );

    procedure remove_iss_bin_index_range (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );

end; 
/
