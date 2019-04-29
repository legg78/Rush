create or replace package body ecm_ui_3ds_message_pkg as

procedure add_message(
    o_message_id            out com_api_type_pkg.t_long_id
    , i_message_type        in com_api_type_pkg.t_dict_value
    , i_message_date        in date
    , i_message_body        in clob
    , i_session_uuid        in com_api_type_pkg.t_uuid
    , i_message_uuid        in com_api_type_pkg.t_uuid
    , i_status              in com_api_type_pkg.t_dict_value := null
    , i_account_id          in com_api_type_pkg.t_name := null
    , i_card_id             in com_api_type_pkg.t_medium_id
    , i_version             in com_api_type_pkg.t_dict_value := null
    , i_message_originator  in com_api_type_pkg.t_module_code := null
) is
begin
    o_message_id := ecm_3ds_message_seq.nextval;
    
    insert into ecm_3ds_message(
        id
        , message_type
        , message_date
        , message_body
        , session_uuid
        , message_uuid
        , status
        , account_id
        , card_id
        , version
        , message_originator
    ) values (
        o_message_id
        , i_message_type
        , i_message_date
        , i_message_body
        , i_session_uuid
        , i_message_uuid
        , nvl2( i_status, ecm_api_const_pkg.DSEC_MESSAGE_STATUS || i_status, ecm_api_const_pkg.DSEC_MES_STATUS_UNABLE )
        , i_account_id
        , i_card_id
        , i_version
        , i_message_originator
    );
end;

function get_3ds_message_status (
    i_account_id            in com_api_type_pkg.t_name
) return com_api_type_pkg.t_dict_value is
    l_status                com_api_type_pkg.t_dict_value;
begin
    select
        min(status)
    into
        l_status
    from
        ecm_3ds_message
    where
        account_id = i_account_id;
    
    return l_status;
end;

end;
/
