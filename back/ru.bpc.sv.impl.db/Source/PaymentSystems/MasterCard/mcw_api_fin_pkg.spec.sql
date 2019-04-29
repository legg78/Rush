create or replace package mcw_api_fin_pkg is
/*********************************************************
 *  API for MasterCard finance message <br />
 *  Created by Khougaev (khougaev@bpcbt.com)  at 05.11.2009 <br />
 *  Module: MCW_API_FIN_PKG <br />
 *  @headcom
 **********************************************************/

procedure get_ird(
    o_p0158_4                out com_api_type_pkg.t_byte_char
  , o_ird_trace              out com_api_type_pkg.t_full_desc
  , i_mti                 in     mcw_api_type_pkg.t_mti
  , i_de024               in     mcw_api_type_pkg.t_de024
  , i_acq_bin             in     mcw_api_type_pkg.t_de002
  , i_hpan                in     mcw_api_type_pkg.t_de002
  , io_de003_1            in out mcw_api_type_pkg.t_de003s
  , i_mcc                 in     com_api_type_pkg.t_mcc
  , i_p0043               in     mcw_api_type_pkg.t_p0043
  , i_p0052               in     mcw_api_type_pkg.t_p0052
  , i_p0023               in     mcw_api_type_pkg.t_p0023
  , i_de038               in     mcw_api_type_pkg.t_de038
  , i_de012               in     mcw_api_type_pkg.t_de012
  , i_de022_1             in     mcw_api_type_pkg.t_de022s
  , i_de022_2             in     mcw_api_type_pkg.t_de022s
  , i_de022_3             in     mcw_api_type_pkg.t_de022s
  , i_de022_4             in     mcw_api_type_pkg.t_de022s
  , i_de022_5             in     mcw_api_type_pkg.t_de022s
  , i_de022_6             in     mcw_api_type_pkg.t_de022s
  , i_de022_7             in     mcw_api_type_pkg.t_de022s
  , i_de022_8             in     mcw_api_type_pkg.t_de022s
  , i_de026               in     mcw_api_type_pkg.t_de026
  , i_de040               in     mcw_api_type_pkg.t_de040
  , i_de004               in     mcw_api_type_pkg.t_de004
  , i_emv_compliant       in     com_api_type_pkg.t_boolean
  , i_de004_rub           in     mcw_api_type_pkg.t_de004
  , i_de043_6             in     mcw_api_type_pkg.t_de043_6
  , i_standard_id         in     com_api_type_pkg.t_tiny_id    := null
  , i_host_id             in     com_api_type_pkg.t_tiny_id    := null
  , i_p0004_1             in     mcw_api_type_pkg.t_p0004_1
  , i_p0004_2             in     mcw_api_type_pkg.t_p0004_2
  , i_p0176               in     mcw_api_type_pkg.t_p0176
  , i_p0207               in     mcw_api_type_pkg.t_p0207
  , i_de042               in     mcw_api_type_pkg.t_de042
  , i_de043_1             in     mcw_api_type_pkg.t_de043_1
  , i_de043_2             in     mcw_api_type_pkg.t_de043_2
  , i_de043_3             in     mcw_api_type_pkg.t_de043_3
  , i_de043_4             in     mcw_api_type_pkg.t_de043_4
  , i_de043_5             in     mcw_api_type_pkg.t_de043_5
  , i_de049               in     mcw_api_type_pkg.t_de049
  , i_p0674               in     mcw_api_type_pkg.t_p0674
  , i_de063               in     mcw_api_type_pkg.t_de063
  , i_p0001_1             in     mcw_api_type_pkg.t_p0001_1
  , i_p0001_2             in     mcw_api_type_pkg.t_p0001_2
  , i_p0198               in     mcw_api_type_pkg.t_p0198
);

procedure modify_ird (
    i_id                  in     com_api_type_pkg.t_long_id
  , i_ird                 in     mcw_api_type_pkg.t_p0158_4
  , i_ird_trace           in     com_api_type_pkg.t_full_desc  := null
);

function get_ird_trace_desc(
    i_ird_trace           in     com_api_type_pkg.t_full_desc
) return com_api_type_pkg.t_text;

procedure get_processing_date (
    i_id                  in     com_api_type_pkg.t_long_id
  , i_is_fpd_matched      in     com_api_type_pkg.t_boolean
  , i_is_fsum_matched     in     com_api_type_pkg.t_boolean
  , i_file_id             in     com_api_type_pkg.t_short_id
  , o_p0025_2                out mcw_api_type_pkg.t_p0025_2
);

function estimate_messages_for_upload (
    i_network_id          in     com_api_type_pkg.t_tiny_id
  , i_cmid                in     mcw_api_type_pkg.t_de033
  , i_inst_code           in     com_api_type_pkg.t_dict_value := null
  , i_start_date          in     date                          := null
  , i_end_date            in     date                          := null
  , i_include_affiliate   in     com_api_type_pkg.t_boolean    := com_api_const_pkg.FALSE
  , i_inst_id             in     com_api_type_pkg.t_inst_id    := null
) return number;

procedure enum_messages_for_upload (
    o_fin_cur             in out sys_refcursor
  , i_network_id          in     com_api_type_pkg.t_tiny_id
  , i_cmid                in     mcw_api_type_pkg.t_de033
  , i_inst_code           in     com_api_type_pkg.t_dict_value := null
  , i_start_date          in     date                          := null
  , i_end_date            in     date                          := null
  , i_include_affiliate   in     com_api_type_pkg.t_boolean    := com_api_const_pkg.FALSE
  , i_inst_id             in     com_api_type_pkg.t_inst_id    := null
);

procedure get_fin (
    i_id                  in     com_api_type_pkg.t_long_id
  , o_fin_rec                out mcw_api_type_pkg.t_fin_rec
  , i_mask_error          in     com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
);

procedure get_fin (
    i_mti                 in     mcw_api_type_pkg.t_mti
  , i_de024               in     mcw_api_type_pkg.t_de024
  , i_is_reversal         in     com_api_type_pkg.t_boolean
  , i_dispute_id          in     com_api_type_pkg.t_long_id
  , o_fin_rec                out mcw_api_type_pkg.t_fin_rec
  , i_mask_error          in     com_api_type_pkg.t_boolean
);

procedure get_fin_message(
    i_id                  in     com_api_type_pkg.t_long_id
  , o_fin_fields             out com_api_type_pkg.t_param_tab
  , i_mask_error          in     com_api_type_pkg.t_boolean
);

procedure get_original_fin (
    i_mti                 in     mcw_api_type_pkg.t_mti
  , i_de002               in     mcw_api_type_pkg.t_de002
  , i_de024               in     mcw_api_type_pkg.t_de024
  , i_de031               in     mcw_api_type_pkg.t_de031
  , i_id                  in     com_api_type_pkg.t_long_id := null
  , o_fin_rec                out mcw_api_type_pkg.t_fin_rec
);

procedure get_original_fee (
    i_mti                 in     mcw_api_type_pkg.t_mti
  , i_de002               in     mcw_api_type_pkg.t_de002
  , i_de024               in     mcw_api_type_pkg.t_de024
  , i_de031               in     mcw_api_type_pkg.t_de031
  , i_de094               in     mcw_api_type_pkg.t_de094 := null
  , i_p0137               in     mcw_api_type_pkg.t_p0137 := null
  , o_fin_rec                out mcw_api_type_pkg.t_fin_rec
);

procedure pack_message(
    i_fin_rec               in     mcw_api_type_pkg.t_fin_rec
  , i_file_id               in     com_api_type_pkg.t_short_id
  , i_de071                 in     mcw_api_type_pkg.t_de071
  , i_charset               in     com_api_type_pkg.t_oracle_name
  , i_curr_standard_version in     com_api_type_pkg.t_tiny_id
  , o_raw_data                 out varchar2
);

procedure mark_ok_uploaded (
    i_rowid               in     com_api_type_pkg.t_rowid_tab
  , i_id                  in     com_api_type_pkg.t_number_tab
  , i_de071               in     com_api_type_pkg.t_number_tab
  , i_file_id             in     com_api_type_pkg.t_number_tab
);

procedure mark_error_uploaded (
    i_rowid               in     com_api_type_pkg.t_rowid_tab
);

procedure flush_job;

procedure cancel_job;

procedure create_operation_fraud(
    i_fin_rec             in     mcw_api_type_pkg.t_fin_rec
  , i_standard_id         in     com_api_type_pkg.t_tiny_id
  , i_host_id             in     com_api_type_pkg.t_tiny_id
  , i_original_fin_id     in     com_api_type_pkg.t_long_id   default null
);

procedure create_operation(
    i_fin_rec               in mcw_api_type_pkg.t_fin_rec
  , i_standard_id         in com_api_type_pkg.t_tiny_id
  , i_auth                in aut_api_type_pkg.t_auth_rec    :=          null
  , i_status              in com_api_type_pkg.t_dict_value  :=          null
  , i_incom_sess_file_id  in com_api_type_pkg.t_long_id     :=          null
  , i_host_id             in com_api_type_pkg.t_tiny_id     default     null
  , i_create_disp_case    in com_api_type_pkg.t_boolean     default     com_api_type_pkg.FALSE
);

procedure create_operation(
    i_fin_rec             in mcw_api_type_pkg.t_fin_rec
  , i_standard_id         in com_api_type_pkg.t_tiny_id
  , i_auth                in aut_api_type_pkg.t_auth_rec    :=          null
  , i_status              in com_api_type_pkg.t_dict_value  :=          null
  , i_incom_sess_file_id  in com_api_type_pkg.t_long_id     :=          null
  , i_host_id             in com_api_type_pkg.t_tiny_id     default     null
  , i_create_disp_case    in com_api_type_pkg.t_boolean     default     com_api_type_pkg.FALSE
  , o_msg_type           out com_api_type_pkg.t_dict_value
);

procedure put_message (
    i_fin_rec             in     mcw_api_type_pkg.t_fin_rec
);

function set_de054 (
    i_amount              in     com_api_type_pkg.t_money
  , i_currency            in     com_api_type_pkg.t_curr_code
  , i_type                in     com_api_type_pkg.t_dict_value
) return mcw_api_type_pkg.t_de054;

procedure create_from_auth (
    i_auth_rec            in     aut_api_type_pkg.t_auth_rec
  , i_id                  in     com_api_type_pkg.t_long_id
  , i_inst_id             in     com_api_type_pkg.t_inst_id    := null
  , i_network_id          in     com_api_type_pkg.t_tiny_id    := null
  , i_status              in     com_api_type_pkg.t_dict_value := null
  , i_collection_only     in     com_api_type_pkg.t_boolean    := null
);

procedure create_incoming_first_pres (
    i_mes_rec               in mcw_api_type_pkg.t_mes_rec
    , i_file_id             in com_api_type_pkg.t_short_id
    , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
    , o_fin_ref_id          out com_api_type_pkg.t_long_id
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_host_id             in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_local_message       in com_api_type_pkg.t_boolean
    , i_create_operation    in com_api_type_pkg.t_boolean := null
    , i_validate_record     in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_need_repeat         in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_create_disp_case    in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_create_rev_reject   in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
);

procedure create_incoming_second_pres (
    i_mes_rec               in mcw_api_type_pkg.t_mes_rec
    , i_file_id             in com_api_type_pkg.t_short_id
    , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
    , o_fin_ref_id          out com_api_type_pkg.t_long_id
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_host_id             in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_local_message       in com_api_type_pkg.t_boolean
    , i_create_operation    in com_api_type_pkg.t_boolean := null
    , i_validate_record     in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_need_repeat         in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_create_disp_case    in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_create_rev_reject   in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
);

procedure create_incoming_retrieval (
    i_mes_rec               in mcw_api_type_pkg.t_mes_rec
    , i_file_id             in com_api_type_pkg.t_short_id
    , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_host_id             in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_local_message       in com_api_type_pkg.t_boolean
    , i_create_operation    in com_api_type_pkg.t_boolean := null
    , i_need_repeat         in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_create_disp_case    in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
);

procedure create_incoming_req_acknowl (
    i_mes_rec               in mcw_api_type_pkg.t_mes_rec
    , i_file_id             in com_api_type_pkg.t_short_id
    , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_host_id             in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_local_message       in com_api_type_pkg.t_boolean
    , i_create_operation    in com_api_type_pkg.t_boolean
    , i_need_repeat         in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_create_disp_case    in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
);

procedure create_incoming_chargeback (
    i_mes_rec               in mcw_api_type_pkg.t_mes_rec
    , i_file_id             in com_api_type_pkg.t_short_id
    , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_host_id             in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_local_message       in com_api_type_pkg.t_boolean
    , i_create_operation    in com_api_type_pkg.t_boolean := null
    , i_validate_record     in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_need_repeat         in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_create_disp_case    in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_create_rev_reject   in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
);

procedure create_incoming_fee (
    i_mes_rec               in mcw_api_type_pkg.t_mes_rec
    , i_file_id             in com_api_type_pkg.t_short_id
    , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_host_id             in com_api_type_pkg.t_tiny_id
    , i_standard_id         in com_api_type_pkg.t_tiny_id
    , i_local_message       in com_api_type_pkg.t_boolean
    , i_create_operation    in com_api_type_pkg.t_boolean := null
    , i_need_repeat         in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    , i_create_disp_case    in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
);

procedure put_fraud(
    i_fraud_rec           in     mcw_api_type_pkg.t_fraud_rec
  , i_id                  in     com_api_type_pkg.t_long_id       default null
);

function is_collection_allow (
    i_card_num            in     com_api_type_pkg.t_card_number
  , i_network_id          in     com_api_type_pkg.t_tiny_id
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_card_type           in     com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_boolean;

procedure get_card_brand (
    i_card_number         in     com_api_type_pkg.t_card_number
  , o_brand                  out com_api_type_pkg.t_curr_code
);

function get_status(
    i_network_id          in     com_api_type_pkg.t_tiny_id
  , i_host_id             in     com_api_type_pkg.t_tiny_id
  , i_standard_id         in     com_api_type_pkg.t_tiny_id
  , i_inst_id             in     com_api_type_pkg.t_inst_id
) return  com_api_type_pkg.t_dict_value;

function get_acq_country (
    i_acq_bin             in     mcw_api_type_pkg.t_de031
) return com_api_type_pkg.t_curr_code;

function get_acq_member (
    i_acq_bin             in     mcw_api_type_pkg.t_de031
) return com_api_type_pkg.t_medium_id;

procedure init_no_original_id_tab;

procedure process_no_original_id_tab;

function is_mastercard (
    i_id                      in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean;

/*
 * Remove message and related operation
 */ 
procedure remove_message(
    i_id                      in     com_api_type_pkg.t_long_id
  , i_force                   in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
);

/*
 * Check if editable
 */ 
function is_editable(
    i_id                      in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean;

function is_doc_export_import_enabled(
    i_id              in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean;

end mcw_api_fin_pkg;
/
