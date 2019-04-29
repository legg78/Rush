create or replace package ecm_ui_3ds_message_pkg as

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
);

function get_3ds_message_status (
    i_account_id            in com_api_type_pkg.t_name
) return com_api_type_pkg.t_dict_value;

end;
/
