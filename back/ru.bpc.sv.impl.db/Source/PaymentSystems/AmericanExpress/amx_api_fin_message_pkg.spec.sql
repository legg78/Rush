create or replace package amx_api_fin_message_pkg as

procedure find_original_fin (
    i_fin_rec               in     amx_api_type_pkg.t_amx_fin_mes_rec
  , o_fin_rec                  out amx_api_type_pkg.t_amx_fin_mes_rec
);

procedure get_fin (
    i_id                    in     com_api_type_pkg.t_long_id
  , o_fin_rec                  out amx_api_type_pkg.t_amx_fin_mes_rec
  , i_mask_error            in     com_api_type_pkg.t_boolean         := com_api_type_pkg.FALSE
);

procedure get_fin (
    i_mtid                  in     com_api_type_pkg.t_mcc
  , i_func_code             in     com_api_type_pkg.t_curr_code
  , i_is_reversal           in     com_api_type_pkg.t_boolean
  , i_dispute_id            in     com_api_type_pkg.t_long_id
  , o_fin_rec                  out amx_api_type_pkg.t_amx_fin_mes_rec
  , i_mask_error            in     com_api_type_pkg.t_boolean
);

function put_message (
    i_fin_rec               in     amx_api_type_pkg.t_amx_fin_mes_rec
) return com_api_type_pkg.t_long_id;

procedure create_operation(
    i_fin_rec               in     amx_api_type_pkg.t_amx_fin_mes_rec
  , i_standard_id           in     com_api_type_pkg.t_tiny_id
  , i_auth                  in     aut_api_type_pkg.t_auth_rec        := null
  , i_status                in     com_api_type_pkg.t_dict_value      := null
  , i_incom_sess_file_id    in     com_api_type_pkg.t_long_id         := null
  , i_host_id               in     com_api_type_pkg.t_tiny_id         default null
);

procedure load_fin_message (
    i_fin_id                in     com_api_type_pkg.t_long_id
  , o_fin_rec                  out amx_api_type_pkg.t_amx_fin_mes_rec
  , i_mask_error            in     com_api_type_pkg.t_boolean         default com_api_type_pkg.FALSE
);

function get_original_id (
    i_fin_rec               in     amx_api_type_pkg.t_amx_fin_mes_rec
) return com_api_type_pkg.t_long_id;

function estimate_messages_for_upload (
    i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_collection_only       in     com_api_type_pkg.t_boolean 
  , i_start_date            in     date                               default null
  , i_end_date              in     date                               default null
  , i_include_affiliate     in     com_api_type_pkg.t_boolean         default com_api_const_pkg.FALSE
  , i_apn                   in     com_api_type_pkg.t_cmid            default null
) return number;

procedure enum_messages_for_upload (
    o_fin_cur                  out sys_refcursor
  , i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_collection_only       in     com_api_type_pkg.t_boolean 
  , i_start_date            in     date                               default null
  , i_end_date              in     date                               default null
  , i_include_affiliate     in     com_api_type_pkg.t_boolean         default com_api_const_pkg.FALSE
  , i_apn                   in     com_api_type_pkg.t_cmid            default null
);

procedure process_auth (
    i_auth_rec              in     aut_api_type_pkg.t_auth_rec
  , i_id                    in     com_api_type_pkg.t_long_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id         := null
  , i_network_id            in     com_api_type_pkg.t_tiny_id         := null
  , i_status                in     com_api_type_pkg.t_dict_value      := null
  , i_collection_only       in     com_api_type_pkg.t_boolean         := null
);

procedure check_dispute_status(
    i_id                    in     com_api_type_pkg.t_long_id
);

function is_amex (
    i_id                    in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean;

function is_editable (
    i_id                    in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean;

procedure remove_message (
    i_id                    in     com_api_type_pkg.t_long_id
);

procedure put_atm_rcn_message(
    i_atm_rcn_rec           in     amx_api_type_pkg.t_amx_atm_rcn_rec
);

procedure create_addendums (
    i_fin_rec               in     amx_api_type_pkg.t_amx_fin_mes_rec
  , i_auth_rec              in     aut_api_type_pkg.t_auth_rec
  , i_collection_only       in     com_api_type_pkg.t_boolean
  , io_message_seq_number   in out com_api_type_pkg.t_tiny_id
);

function get_merchant_amex (
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_merchant_number       in     com_api_type_pkg.t_merchant_number
) return com_api_type_pkg.t_merchant_number;

function get_merchant_sv (
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_merchant_number       in     com_api_type_pkg.t_merchant_number
) return com_api_type_pkg.t_merchant_number;

end;
/

