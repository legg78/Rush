create or replace package hsm_ui_lmk_pkg is

    procedure add_hsm_lmk (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_check_value             in com_api_type_pkg.t_name
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_full_desc
    );

    procedure modify_hsm_lmk (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_check_value             in com_api_type_pkg.t_name
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_full_desc
    );

    procedure remove_hsm_lmk (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );
    
end; 
/
