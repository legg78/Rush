create or replace package body opr_ui_entity_oper_type_pkg is

    procedure add_entity_oper_type (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_entity_type             in com_api_type_pkg.t_dict_value
        , i_oper_type               in com_api_type_pkg.t_dict_value
        , i_invoke_method           in com_api_type_pkg.t_dict_value
        , i_reason_lov_id           in com_api_type_pkg.t_tiny_id
        , i_object_type             in com_api_type_pkg.t_dict_value
        , i_wizard_id               in com_api_type_pkg.t_tiny_id
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_entity_object_type      in com_api_type_pkg.t_dict_value
    ) is
    begin
        o_id := opr_entity_oper_type_seq.nextval;
        o_seqnum := 1;
        
        insert into opr_entity_oper_type_vw (
            id
            , seqnum
            , inst_id
            , entity_type
            , oper_type
            , invoke_method
            , reason_lov_id
            , object_type
            , wizard_id
            , entity_object_type
        ) values (
            o_id
            , o_seqnum
            , i_inst_id
            , i_entity_type
            , i_oper_type
            , i_invoke_method
            , i_reason_lov_id
            , i_object_type
            , i_wizard_id
            , i_entity_object_type
        );
        
        com_api_i18n_pkg.add_text (
            i_table_name     => 'opr_entity_oper_type'
            , i_column_name  => 'name'
            , i_object_id    => o_id
            , i_lang         => i_lang
            , i_text         => i_name
        );
    end;

    procedure modify_entity_oper_type (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_entity_type             in com_api_type_pkg.t_dict_value
        , i_oper_type               in com_api_type_pkg.t_dict_value
        , i_invoke_method           in com_api_type_pkg.t_dict_value
        , i_reason_lov_id           in com_api_type_pkg.t_tiny_id
        , i_object_type             in com_api_type_pkg.t_dict_value
        , i_wizard_id               in com_api_type_pkg.t_tiny_id
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_entity_object_type      in com_api_type_pkg.t_dict_value
    ) is
    begin
        update
            opr_entity_oper_type_vw
        set
            seqnum = io_seqnum
            , inst_id = i_inst_id
            , entity_type = i_entity_type
            , oper_type = i_oper_type
            , invoke_method = i_invoke_method
            , reason_lov_id = i_reason_lov_id
            , object_type = i_object_type
            , wizard_id = i_wizard_id
            , entity_object_type = i_entity_object_type
        where
            id = i_id;
            
        io_seqnum := io_seqnum + 1;
        
        com_api_i18n_pkg.add_text (
            i_table_name     => 'opr_entity_oper_type'
            , i_column_name  => 'name'
            , i_object_id    => i_id
            , i_lang         => i_lang
            , i_text         => i_name
        );
    end;

    procedure remove_entity_oper_type (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
    begin
        update
            opr_entity_oper_type_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;

        delete from
            opr_entity_oper_type_vw
        where
            id = i_id;
    end;

end;
/
