create or replace package rul_ui_rule_set_pkg is

    procedure add (
        o_id                  out com_api_type_pkg.t_tiny_id
        , o_seqnum            out com_api_type_pkg.t_seqnum
        , i_name              in com_api_type_pkg.t_name
        , i_category          in com_api_type_pkg.t_dict_value
        , i_lang              in com_api_type_pkg.t_dict_value := null
    );

    procedure modify (
        i_id                  in com_api_type_pkg.t_tiny_id
        , io_seqnum           in out com_api_type_pkg.t_seqnum
        , i_name              in com_api_type_pkg.t_name
        , i_category          in com_api_type_pkg.t_dict_value
        , i_lang              in com_api_type_pkg.t_dict_value := null
    );

    procedure remove (
        i_id                  in com_api_type_pkg.t_tiny_id
        , i_seqnum            in com_api_type_pkg.t_seqnum
    );

    procedure clone_rule_set ( 
        i_id                    in com_api_type_pkg.t_tiny_id
        , i_name                in com_api_type_pkg.t_name
        , i_lang                in com_api_type_pkg.t_dict_value := null
        , o_cloned_id           out com_api_type_pkg.t_tiny_id
    );

end;
/
