create or replace package aup_ui_tag_pkg is

    procedure add_tag (
        o_id                        out com_api_type_pkg.t_short_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_tag                     in com_api_type_pkg.t_short_id
        , i_tag_type                in com_api_type_pkg.t_dict_value
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_description             in com_api_type_pkg.t_full_desc
        , i_reference               in com_api_type_pkg.t_name
        , i_db_stored               in com_api_type_pkg.t_boolean
    );

    procedure modify_tag (
        i_id                        in com_api_type_pkg.t_short_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_tag                     in com_api_type_pkg.t_short_id
        , i_tag_type                in com_api_type_pkg.t_dict_value
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_description             in com_api_type_pkg.t_full_desc
        , i_reference               in com_api_type_pkg.t_name
        , i_db_stored               in com_api_type_pkg.t_boolean
    );

    procedure remove_tag (
        i_id                        in com_api_type_pkg.t_short_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );
    
end; 
/
