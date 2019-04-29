create or replace package ntf_ui_scheme_pkg is

    procedure add_scheme (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_scheme_type             in com_api_type_pkg.t_dict_value
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_description             in com_api_type_pkg.t_full_desc
    );

    procedure modify_scheme (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_scheme_type             in com_api_type_pkg.t_dict_value
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_description             in com_api_type_pkg.t_full_desc
    );

    procedure remove_scheme (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );

end; 
/
