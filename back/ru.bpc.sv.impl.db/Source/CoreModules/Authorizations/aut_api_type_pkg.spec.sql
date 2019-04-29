create or replace package aut_api_type_pkg is
/************************************************************
 * Authorizations types <br />
 * Created by Khougaev A.(khougaev@bpc.ru)  at 19.03.2010  <br />
 * Module: aut_api_type_pkg <br />
 * @headcom
 ************************************************************/

subtype t_pos_entry_mode         is varchar2(3);

type t_auth_rec is record (
    proc_stage                    com_api_type_pkg.t_dict_value
  , row_id                        rowid
  , id                            com_api_type_pkg.t_long_id
  , split_hash                    com_api_type_pkg.t_tiny_id
  , session_id                    com_api_type_pkg.t_long_id
  , is_reversal                   com_api_type_pkg.t_boolean
  , original_id                   com_api_type_pkg.t_long_id
  , parent_id                     com_api_type_pkg.t_long_id
  , oper_id                       com_api_type_pkg.t_long_id
  , msg_type                      com_api_type_pkg.t_dict_value
  , oper_type                     com_api_type_pkg.t_dict_value
  , oper_reason                   com_api_type_pkg.t_dict_value
  , resp_code                     com_api_type_pkg.t_dict_value
  , status                        com_api_type_pkg.t_dict_value
  , status_reason                 com_api_type_pkg.t_dict_value
  , proc_type                     com_api_type_pkg.t_dict_value
  , proc_mode                     com_api_type_pkg.t_dict_value
  , sttl_type                     com_api_type_pkg.t_dict_value
  , match_status                  com_api_type_pkg.t_dict_value
  , forced_processing             com_api_type_pkg.t_boolean
  , is_advice                     com_api_type_pkg.t_boolean
  , is_repeat                     com_api_type_pkg.t_boolean
  , is_completed                  com_api_type_pkg.t_dict_value
  , host_date                     date
  , sttl_date                     date
  , acq_sttl_date                 date
  , unhold_date                   date
  , oper_date                     date
  , oper_count                    com_api_type_pkg.t_long_id
  , oper_request_amount           com_api_type_pkg.t_money
  , oper_amount_algorithm         com_api_type_pkg.t_dict_value
  , oper_amount                   com_api_type_pkg.t_money
  , oper_currency                 com_api_type_pkg.t_curr_code
  , oper_cashback_amount          com_api_type_pkg.t_money
  , oper_replacement_amount       com_api_type_pkg.t_money
  , oper_surcharge_amount         com_api_type_pkg.t_money
  , client_id_type                com_api_type_pkg.t_dict_value
  , client_id_value               com_api_type_pkg.t_name
  , iss_inst_id                   com_api_type_pkg.t_inst_id
  , iss_network_id                com_api_type_pkg.t_tiny_id
  , iss_network_device_id         com_api_type_pkg.t_short_id
  , split_hash_iss                com_api_type_pkg.t_tiny_id
  , card_inst_id                  com_api_type_pkg.t_inst_id
  , card_network_id               com_api_type_pkg.t_tiny_id
  , card_number                   com_api_type_pkg.t_card_number
  , card_id                       com_api_type_pkg.t_medium_id
  , card_instance_id              com_api_type_pkg.t_medium_id
  , card_type_id                  com_api_type_pkg.t_tiny_id
  , card_mask                     com_api_type_pkg.t_card_number
  , card_hash                     com_api_type_pkg.t_medium_id
  , card_seq_number               com_api_type_pkg.t_tiny_id
  , card_expir_date               date
  , card_service_code             com_api_type_pkg.t_curr_code
  , card_country                  com_api_type_pkg.t_country_code
  , customer_id                   com_api_type_pkg.t_medium_id
  , account_id                    com_api_type_pkg.t_medium_id
  , account_type                  com_api_type_pkg.t_dict_value
  , account_number                com_api_type_pkg.t_account_number
  , account_amount                com_api_type_pkg.t_money
  , account_currency              com_api_type_pkg.t_curr_code
  , account_cnvt_rate             com_api_type_pkg.t_money
  , bin_amount                    com_api_type_pkg.t_money
  , bin_currency                  com_api_type_pkg.t_curr_code
  , bin_cnvt_rate                 com_api_type_pkg.t_money
  , network_amount                com_api_type_pkg.t_money
  , network_currency              com_api_type_pkg.t_curr_code
  , network_cnvt_date             date
  , network_cnvt_rate             com_api_type_pkg.t_money
  , addr_verif_result             com_api_type_pkg.t_dict_value
  , auth_code                     com_api_type_pkg.t_auth_code
  , dst_client_id_type            com_api_type_pkg.t_dict_value
  , dst_client_id_value           com_api_type_pkg.t_name
  , dst_inst_id                   com_api_type_pkg.t_inst_id
  , dst_network_id                com_api_type_pkg.t_tiny_id
  , dst_card_inst_id              com_api_type_pkg.t_inst_id
  , dst_card_network_id           com_api_type_pkg.t_tiny_id
  , dst_card_number               com_api_type_pkg.t_card_number
  , dst_card_id                   com_api_type_pkg.t_medium_id
  , dst_card_instance_id          com_api_type_pkg.t_medium_id
  , dst_card_type_id              com_api_type_pkg.t_tiny_id
  , dst_card_mask                 com_api_type_pkg.t_card_number
  , dst_card_hash                 com_api_type_pkg.t_medium_id
  , dst_card_seq_number           com_api_type_pkg.t_tiny_id
  , dst_card_expir_date           date
  , dst_card_service_code         com_api_type_pkg.t_curr_code
  , dst_card_country              com_api_type_pkg.t_country_code
  , dst_customer_id               com_api_type_pkg.t_medium_id
  , dst_account_id                com_api_type_pkg.t_medium_id
  , dst_account_type              com_api_type_pkg.t_dict_value
  , dst_account_number            com_api_type_pkg.t_account_number
  , dst_account_amount            com_api_type_pkg.t_money
  , dst_account_currency          com_api_type_pkg.t_curr_code
  , dst_auth_code                 com_api_type_pkg.t_auth_code
  , acq_device_id                 com_api_type_pkg.t_short_id
  , acq_resp_code                 com_api_type_pkg.t_dict_value
  , acq_device_proc_result        com_api_type_pkg.t_dict_value
  , acq_inst_bin                  com_api_type_pkg.t_rrn
  , forw_inst_bin                 com_api_type_pkg.t_rrn
  , acq_inst_id                   com_api_type_pkg.t_inst_id
  , acq_network_id                com_api_type_pkg.t_tiny_id
  , split_hash_acq                com_api_type_pkg.t_tiny_id
  , merchant_id                   com_api_type_pkg.t_short_id
  , merchant_number               com_api_type_pkg.t_merchant_number
  , terminal_type                 com_api_type_pkg.t_dict_value
  , terminal_number               com_api_type_pkg.t_terminal_number
  , terminal_id                   com_api_type_pkg.t_short_id
  , merchant_name                 com_api_type_pkg.t_name
  , merchant_street               com_api_type_pkg.t_name
  , merchant_city                 com_api_type_pkg.t_name
  , merchant_region               com_api_type_pkg.t_country_code
  , merchant_country              com_api_type_pkg.t_country_code
  , merchant_postcode             varchar2(10)
  , cat_level                     com_api_type_pkg.t_dict_value
  , mcc                           com_api_type_pkg.t_mcc
  , originator_refnum             com_api_type_pkg.t_rrn
  , network_refnum                com_api_type_pkg.t_rrn
  , card_data_input_cap           com_api_type_pkg.t_dict_value
  , crdh_auth_cap                 com_api_type_pkg.t_dict_value
  , card_capture_cap              com_api_type_pkg.t_dict_value
  , terminal_operating_env        com_api_type_pkg.t_dict_value
  , crdh_presence                 com_api_type_pkg.t_dict_value
  , card_presence                 com_api_type_pkg.t_dict_value
  , card_data_input_mode          com_api_type_pkg.t_dict_value
  , crdh_auth_method              com_api_type_pkg.t_dict_value
  , crdh_auth_entity              com_api_type_pkg.t_dict_value
  , card_data_output_cap          com_api_type_pkg.t_dict_value
  , terminal_output_cap           com_api_type_pkg.t_dict_value
  , pin_capture_cap               com_api_type_pkg.t_dict_value
  , pin_presence                  com_api_type_pkg.t_dict_value
  , cvv2_presence                 com_api_type_pkg.t_dict_value
  , cvc_indicator                 com_api_type_pkg.t_dict_value
  , pos_entry_mode                t_pos_entry_mode
  , pos_cond_code                 varchar2(2)
  , payment_order_id              com_api_type_pkg.t_long_id
  , payment_host_id               com_api_type_pkg.t_tiny_id
  , emv_data                      com_api_type_pkg.t_full_desc
  , atc                           com_api_type_pkg.t_dict_value
  , tvr                           com_api_type_pkg.t_name
  , cvr                           com_api_type_pkg.t_name
  , addl_data                     com_api_type_pkg.t_full_desc
  , service_code                  com_api_type_pkg.t_curr_code
  , device_date                   date
  , cvv2_result                   com_api_type_pkg.t_dict_value
  , certificate_method            com_api_type_pkg.t_dict_value
  , certificate_type              com_api_type_pkg.t_dict_value
  , merchant_certif               com_api_type_pkg.t_name
  , cardholder_certif             com_api_type_pkg.t_name
  , ucaf_indicator                com_api_type_pkg.t_dict_value
  , is_early_emv                  com_api_type_pkg.t_boolean
  , amounts                       com_api_type_pkg.t_raw_data
  , cavv_presence                 com_api_type_pkg.t_dict_value
  , aav_presence                  com_api_type_pkg.t_dict_value
  , transaction_id                com_api_type_pkg.t_auth_long_id
  , system_trace_audit_number     com_api_type_pkg.t_auth_code
  , external_auth_id              com_api_type_pkg.t_attr_name
  , external_orig_id              com_api_type_pkg.t_attr_name
  , agent_unique_id               varchar2(5)
  , native_resp_code              com_api_type_pkg.t_byte_char
  , trace_number                  com_api_type_pkg.t_attr_name
  , auth_purpose_id               com_api_type_pkg.t_long_id
  , is_incremental                com_api_type_pkg.t_boolean
);
type t_auth_tab is table of t_auth_rec index by binary_integer;

type aut_resp_code is record(
    resp_code                     com_api_type_pkg.t_dict_value
  , is_reversal                   com_api_type_pkg.t_boolean
  , proc_type                     com_api_type_pkg.t_dict_value
  , proc_mode                     com_api_type_pkg.t_dict_value
  , auth_status                   com_api_type_pkg.t_dict_value
  , status_reason                 com_api_type_pkg.t_dict_value
  , oper_type                     com_api_type_pkg.t_dict_value
  , msg_type                      com_api_type_pkg.t_dict_value
  , priority                      com_api_type_pkg.t_tiny_id
  , is_completed                  com_api_type_pkg.t_dict_value
);

type t_auth_tag_rec is record(
    tag_id                        com_api_type_pkg.t_short_id
  , tag_name                      com_api_type_pkg.t_name
  , tag_value                     com_api_type_pkg.t_param_value
  , seq_number                    com_api_type_pkg.t_tiny_id
);

type t_auth_tag_tab is table of t_auth_tag_rec index by binary_integer;

end;
/
