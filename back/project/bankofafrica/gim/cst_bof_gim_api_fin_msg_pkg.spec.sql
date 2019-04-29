create or replace package cst_bof_gim_api_fin_msg_pkg as

procedure get_fin_message(
    i_id                   in     com_api_type_pkg.t_long_id
  , o_fin_rec                 out cst_bof_gim_api_type_pkg.t_gim_fin_mes_rec
  , i_mask_error           in     com_api_type_pkg.t_boolean                    default com_api_const_pkg.FALSE
);

function estimate_messages_for_upload(
    i_inst_id              in     com_api_type_pkg.t_inst_id
  , i_start_date           in     date                                          default null
  , i_end_date             in     date                                          default null
) return number;

procedure enum_messages_for_upload(
    o_fin_cur              in out sys_refcursor
  , i_inst_id              in     com_api_type_pkg.t_inst_id
  , i_start_date           in     date default null
  , i_end_date             in     date default null
);

function get_original_id(
    i_fin_rec              in     cst_bof_gim_api_type_pkg.t_gim_fin_mes_rec
  , i_fee_rec              in     cst_bof_gim_api_type_pkg.t_fee_rec            default null
) return com_api_type_pkg.t_long_id;

procedure get_fee(
    i_id                   in     com_api_type_pkg.t_long_id
  , o_fee_rec                 out cst_bof_gim_api_type_pkg.t_fee_rec
);

procedure get_retrieval(
    i_id                   in     com_api_type_pkg.t_long_id
  , o_retrieval_rec           out cst_bof_gim_api_type_pkg.t_retrieval_rec
);

procedure get_fraud(
    i_id                   in     com_api_type_pkg.t_long_id
  , o_fraud_rec               out cst_bof_gim_api_type_pkg.t_fraud_rec
);

procedure process_auth(
    i_auth_rec             in     aut_api_type_pkg.t_auth_rec
  , i_inst_id              in     com_api_type_pkg.t_inst_id                    default null
  , i_network_id           in     com_api_type_pkg.t_network_id                 default null
  , i_status               in     com_api_type_pkg.t_dict_value                 default null
  , io_fin_mess_id         in out com_api_type_pkg.t_long_id
);

procedure create_operation(
    i_fin_rec              in     cst_bof_gim_api_type_pkg.t_gim_fin_mes_rec
  , i_standard_id          in     com_api_type_pkg.t_tiny_id
  , i_fee_rec              in     cst_bof_gim_api_type_pkg.t_fee_rec            default null
  , i_status               in     com_api_type_pkg.t_dict_value                 default null
  , i_create_disp_case     in     com_api_type_pkg.t_boolean                    default com_api_const_pkg.FALSE
  , i_incom_sess_file_id   in     com_api_type_pkg.t_long_id                    default null
);

function put_message(
    i_fin_rec              in     cst_bof_gim_api_type_pkg.t_gim_fin_mes_rec
) return com_api_type_pkg.t_long_id;

procedure put_retrieval(
    i_retrieval_rec        in     cst_bof_gim_api_type_pkg.t_retrieval_rec
);

procedure put_fee(
    i_fee_rec              in     cst_bof_gim_api_type_pkg.t_fee_rec
);

procedure put_fraud(
    i_fraud_rec            in     cst_bof_gim_api_type_pkg.t_fraud_rec
);

function get_original_id(
    i_fin_rec              in     cst_bof_gim_api_type_pkg.t_gim_fin_mes_rec
  , i_fee_rec              in     cst_bof_gim_api_type_pkg.t_fee_rec            default null
  , o_need_original_id        out com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_long_id;

/*
 * Function parses incoming value card_data_input_mode and returns POS entry mode.
 */
function get_pos_entry_mode(
    i_card_data_input_mode in     com_api_type_pkg.t_dict_value
) return aut_api_type_pkg.t_pos_entry_mode;

function get_spec_chargeback_ind(
    i_trans_code           in  com_api_type_pkg.t_byte_char
  , i_chargeback_amount    in  com_api_type_pkg.t_money
  , i_original_amount      in  com_api_type_pkg.t_money
) return com_api_type_pkg.t_byte_char;

end;
/
