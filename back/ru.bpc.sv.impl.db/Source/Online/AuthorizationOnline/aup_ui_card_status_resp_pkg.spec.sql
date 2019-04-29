create or replace package aup_ui_card_status_resp_pkg is

    procedure add_card_status_resp (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_inst_id                 in com_api_type_pkg.t_dict_value
        , i_oper_type               in com_api_type_pkg.t_dict_value
        , i_card_state              in com_api_type_pkg.t_dict_value
        , i_card_status             in com_api_type_pkg.t_dict_value
        , i_pin_presence            in com_api_type_pkg.t_dict_value
        , i_resp_code               in com_api_type_pkg.t_dict_value
        , i_priority                in com_api_type_pkg.t_tiny_id
        , i_msg_type                in com_api_type_pkg.t_dict_value
        , i_participant_type        in com_api_type_pkg.t_dict_value
    );

    procedure modify_card_status_resp (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_inst_id                 in com_api_type_pkg.t_dict_value
        , i_oper_type               in com_api_type_pkg.t_dict_value
        , i_card_state              in com_api_type_pkg.t_dict_value
        , i_card_status             in com_api_type_pkg.t_dict_value
        , i_pin_presence            in com_api_type_pkg.t_dict_value
        , i_resp_code               in com_api_type_pkg.t_dict_value
        , i_priority                in com_api_type_pkg.t_tiny_id
        , i_msg_type                in com_api_type_pkg.t_dict_value
        , i_participant_type        in com_api_type_pkg.t_dict_value
    );

    procedure remove_card_status_resp (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );

end;
/
