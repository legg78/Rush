create or replace package body aup_ui_card_status_resp_pkg is

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
    ) is
    begin
        o_id := aup_card_status_resp_seq.nextval;
        o_seqnum := 1;

        insert into aup_card_status_resp_vw (
            id
            , seqnum
            , inst_id
            , oper_type
            , card_state
            , card_status
            , pin_presence
            , resp_code
            , priority
            , msg_type
            , participant_type
        ) values (
            o_id
            , o_seqnum
            , i_inst_id
            , i_oper_type
            , i_card_state
            , i_card_status
            , i_pin_presence
            , i_resp_code
            , i_priority
            , i_msg_type
            , i_participant_type
        );

    end;

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
    ) is
    begin
        update
            aup_card_status_resp_vw
        set
            seqnum = io_seqnum
            , inst_id = i_inst_id
            , oper_type = i_oper_type
            , card_state = i_card_state
            , card_status = i_card_status
            , pin_presence = i_pin_presence
            , resp_code = i_resp_code
            , priority = i_priority
            , msg_type = i_msg_type
            , participant_type = i_participant_type
        where
            id = i_id;

        io_seqnum := io_seqnum + 1;

    end;

    procedure remove_card_status_resp (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
    begin
        update
            aup_card_status_resp_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;

        delete from
            aup_card_status_resp_vw
        where
            id = i_id;
    end;

end;
/
