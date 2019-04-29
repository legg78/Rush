create or replace package opr_ui_entity_oper_type_pkg is

    procedure add_entity_oper_type (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_entity_type             in com_api_type_pkg.t_dict_value
        , i_oper_type               in com_api_type_pkg.t_dict_value
        , i_invoke_method           in com_api_type_pkg.t_dict_value
        , i_reason_lov_id           in com_api_type_pkg.t_tiny_id
        , i_object_type             in com_api_type_pkg.t_dict_value := null
        , i_wizard_id               in com_api_type_pkg.t_tiny_id := null
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_entity_object_type      in com_api_type_pkg.t_dict_value
    );

    procedure modify_entity_oper_type (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_entity_type             in com_api_type_pkg.t_dict_value
        , i_oper_type               in com_api_type_pkg.t_dict_value
        , i_invoke_method           in com_api_type_pkg.t_dict_value
        , i_reason_lov_id           in com_api_type_pkg.t_tiny_id
        , i_object_type             in com_api_type_pkg.t_dict_value := null
        , i_wizard_id               in com_api_type_pkg.t_tiny_id := null
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_entity_object_type      in com_api_type_pkg.t_dict_value
    );

    procedure remove_entity_oper_type (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );
    
end;
/
