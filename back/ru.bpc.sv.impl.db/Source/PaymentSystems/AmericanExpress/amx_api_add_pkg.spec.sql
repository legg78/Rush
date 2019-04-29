create or replace package amx_api_add_pkg as

procedure create_incoming_addenda (
    i_tc_buffer              in com_api_type_pkg.t_raw_data
    , i_file_id              in com_api_type_pkg.t_long_id
    , i_fin_id               in com_api_type_pkg.t_long_id
);

procedure create_outgoing_addenda (
    i_fin_rec                in amx_api_type_pkg.t_amx_fin_mes_rec
    , i_auth_rec             in aut_api_type_pkg.t_auth_rec
    , i_addenda_type         in com_api_type_pkg.t_byte_char
    , i_collection_only      in com_api_type_pkg.t_boolean
    , i_message_seq_number   in com_api_type_pkg.t_tiny_id
);

procedure enum_messages_for_upload (
    i_fin_id                in            com_api_type_pkg.t_long_id
    , o_amx_add_tab         in out nocopy amx_api_type_pkg.t_amx_add_tab
);

procedure process_addenda (
    i_amx_add_rec           in out nocopy amx_api_type_pkg.t_amx_add_rec
    , i_file_id             in            com_api_type_pkg.t_long_id
    , i_rec_number          in            com_api_type_pkg.t_long_id
    , i_session_file_id     in            com_api_type_pkg.t_long_id
);

procedure get_chip_addenda(
    i_fin_id            in      com_api_type_pkg.t_long_id
  , o_add_chip_rec         out  amx_api_type_pkg.t_amx_add_chip_rec
);

function get_offset(
    i_addenda_type          in com_api_type_pkg.t_byte_char
) return pls_integer;

end;
/

