create or replace package pmo_ui_purpose_formatter_pkg is

    procedure add_purpose_formatter (
        o_id                        out com_api_type_pkg.t_short_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_purpose_id              in com_api_type_pkg.t_short_id
        , i_standard_id             in com_api_type_pkg.t_tiny_id
        , i_version_id              in com_api_type_pkg.t_tiny_id
        , i_paym_aggr_msg_type      in com_api_type_pkg.t_dict_value
        , i_formatter               in clob
    );

    procedure modify_purpose_formatter (
        i_id                        in com_api_type_pkg.t_short_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_purpose_id              in com_api_type_pkg.t_short_id
        , i_standard_id             in com_api_type_pkg.t_tiny_id
        , i_version_id              in com_api_type_pkg.t_tiny_id
        , i_paym_aggr_msg_type      in com_api_type_pkg.t_dict_value
        , i_formatter               in clob
    );

    procedure remove_purpose_formatter (
        i_id                        in com_api_type_pkg.t_short_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );
    
end;
/
