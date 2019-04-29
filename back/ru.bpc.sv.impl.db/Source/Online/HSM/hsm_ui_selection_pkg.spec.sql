create or replace package hsm_ui_selection_pkg is

    procedure add_hsm_selection (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_action                  in com_api_type_pkg.t_dict_value
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_mod_id                  in com_api_type_pkg.t_tiny_id
        , i_hsm_id                  in com_api_type_pkg.t_tiny_id
        , i_max_connection          in com_api_type_pkg.t_tiny_id
        , i_firmware                in com_api_type_pkg.t_dict_value
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_description             in com_api_type_pkg.t_full_desc
    );

    procedure modify_hsm_selection (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_action                  in com_api_type_pkg.t_dict_value
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_mod_id                  in com_api_type_pkg.t_tiny_id
        , i_hsm_id                  in com_api_type_pkg.t_tiny_id
        , i_max_connection          in com_api_type_pkg.t_tiny_id
        , i_firmware                in com_api_type_pkg.t_dict_value
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_description             in com_api_type_pkg.t_full_desc
    );

    procedure remove_hsm_selection (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );
    
    procedure get_hsm_lov (
        o_ref_cur                   out sys_refcursor
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_agent_id                in com_api_type_pkg.t_agent_id
        , i_action                  in com_api_type_pkg.t_dict_value
    );
    
end; 
/
