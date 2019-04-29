create or replace package cst_ow_pkg is

/**
*   BPCPC custom package dedicated to the generation of C and M files (an OpenWay format)
*/

procedure upload_m_batch_file(
    i_inst_id           in com_api_type_pkg.t_inst_id
  , i_masking_card      in com_api_type_pkg.t_boolean
);

procedure upload_c_file_ow(
    i_inst_id           in com_api_type_pkg.t_inst_id
);

function get_currency(
    i_cur               in com_api_type_pkg.t_curr_code
  , i_inst_id           in com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_curr_code;

function get_contra_entry_channel_ow(
    i_inst_id           in com_api_type_pkg.t_inst_id
  , i_sttl_type         in com_api_type_pkg.t_dict_value
  , i_oper_id           in com_api_type_pkg.t_long_id
  , i_network_id        in com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_byte_char;

function get_trans_type_ow(
    i_inst_id           in com_api_type_pkg.t_inst_id
  , i_oper_type         in com_api_type_pkg.t_dict_value
  , i_msgt_type         in com_api_type_pkg.t_dict_value
  , i_card_type_id      in com_api_type_pkg.t_inst_id
  , i_is_reversal       in com_api_type_pkg.t_boolean
  , i_terminal_type     in com_api_type_pkg.t_dict_value
  , i_sttl_type         in com_api_type_pkg.t_dict_value
  , i_id                in com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_dict_value;

function get_payment_purpose(
    i_tag_value         in varchar2
) return varchar2;

function mapping_inst_for_upload_abs(
    i_inst_id           in com_api_type_pkg.t_inst_id)
return com_api_type_pkg.t_inst_id;

procedure process_file_header(
    i_session_file_id   in com_api_type_pkg.t_long_id
  , i_file_header       in com_api_type_pkg.t_raw_data
  , i_end_symbol        in com_api_type_pkg.t_byte_char := chr(10)
);

procedure process_file_trailer(
    i_session_file_id   in com_api_type_pkg.t_long_id
  , i_file_trailer      in com_api_type_pkg.t_raw_data
  , i_end_symbol        in com_api_type_pkg.t_byte_char := chr(10)
);

procedure check_format_row_m_ow(
    i_row               in com_api_type_pkg.t_raw_data
);

procedure log_upload_oper(
    i_oper_id           in com_api_type_pkg.t_long_id
  , i_session_file_id   in com_api_type_pkg.t_long_id
  , i_upload_oper_id    in com_api_type_pkg.t_long_id
  , i_file_type         in com_api_type_pkg.t_dict_value
);

function get_inst_for_settings(
    i_inst_id           in com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_inst_id;

function check_to_upload_m_file(
    i_inst_id           in com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_boolean;

procedure check_format_row(
    i_row               in com_api_type_pkg.t_raw_data
);

function check_to_upload_c_file(
    i_inst_id           in com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_boolean;

end cst_ow_pkg;
/
