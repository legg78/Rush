create or replace package opr_ui_check_pkg is

    procedure add_check (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_check_group_id          in com_api_type_pkg.t_tiny_id
        , i_check_type              in com_api_type_pkg.t_dict_value
        , i_exec_order              in com_api_type_pkg.t_tiny_id
    );

    procedure modify_check (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_check_group_id          in com_api_type_pkg.t_tiny_id
        , i_check_type              in com_api_type_pkg.t_dict_value
        , i_exec_order              in com_api_type_pkg.t_tiny_id
    );

    procedure remove_check (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );
    
    procedure add_check_group (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_description             in com_api_type_pkg.t_full_desc
    );

    procedure modify_check_group (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_description             in com_api_type_pkg.t_full_desc
    );

    procedure remove_check_group (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );
    
    procedure add_check_selection (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_oper_type               in com_api_type_pkg.t_dict_value
        , i_msg_type                in com_api_type_pkg.t_dict_value
        , i_party_type              in com_api_type_pkg.t_dict_value
        , i_inst_id                 in com_api_type_pkg.t_dict_value
        , i_network_id              in com_api_type_pkg.t_dict_value
        , i_check_group_id          in com_api_type_pkg.t_tiny_id
        , i_exec_order              in com_api_type_pkg.t_tiny_id
    );

    procedure modify_check_selection (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_oper_type               in com_api_type_pkg.t_dict_value
        , i_msg_type                in com_api_type_pkg.t_dict_value
        , i_party_type              in com_api_type_pkg.t_dict_value
        , i_inst_id                 in com_api_type_pkg.t_dict_value
        , i_network_id              in com_api_type_pkg.t_dict_value
        , i_check_group_id          in com_api_type_pkg.t_tiny_id
        , i_exec_order              in com_api_type_pkg.t_tiny_id
    );

    procedure remove_check_selection (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );
    
end;
/
