create or replace package cst_oab_api_type_pkg is
/*********************************************************
*  OAB custom API type <br />
*  Created by Gogolev I. (i.gogolev@bpcbt.com) at 04.09.2018 <br />
*  Module: CST_OAB_API_TYPE_PKG <br />
*  @headcom
**********************************************************/

type t_omannet_file_in_rec is record(
    serial_number           com_api_type_pkg.t_medium_id
  , request_datetime        com_api_type_pkg.t_auth_date
  , action_code             com_api_type_pkg.t_byte_char
  , transaction_type        com_api_type_pkg.t_attr_name
  , currency_code           com_api_type_pkg.t_curr_code
  , transaction_amount_de4  com_api_type_pkg.t_attr_name
  , result_code             com_api_type_pkg.t_attr_name
  , response_code_de39      com_api_type_pkg.t_tag
  , merchant_track_id       com_api_type_pkg.t_full_desc
  , tran_id                 com_api_type_pkg.t_attr_name
  , tran_rfrn_tx_de37       com_api_type_pkg.t_rrn
  , auth_code_de38          com_api_type_pkg.t_auth_code
  , trn_src_ip_tx           com_api_type_pkg.t_remote_adr
  , merchant_id_de42        com_api_type_pkg.t_merchant_number
  , terminal_id_de41        com_api_type_pkg.t_terminal_number
  , merchant_name           com_api_type_pkg.t_name
  , mcc_code_de26           com_api_type_pkg.t_mcc
  , card_number_de2         com_api_type_pkg.t_card_number
  , expiry_date_de14        com_api_type_pkg.t_date_short
  , service_charge_amount   com_api_type_pkg.t_attr_name
  , net_amount              com_api_type_pkg.t_attr_name
  , auth_model              com_api_type_pkg.t_name
  , payment_id              com_api_type_pkg.t_attr_name
  , pos_code_de22           com_api_type_pkg.t_attr_name
  , user_dfnd_1_tx          com_api_type_pkg.t_full_desc
  , user_dfnd_2_tx          com_api_type_pkg.t_full_desc
  , user_dfnd_3_tx          com_api_type_pkg.t_full_desc
  , user_dfnd_4_tx          com_api_type_pkg.t_full_desc
  , user_dfnd_5_tx          com_api_type_pkg.t_full_desc
);

type t_oper_rec is record(
    oper_main_rec   opr_api_type_pkg.t_oper_rec
  , total_amount    com_api_type_pkg.t_money
  , fee_amount      com_api_type_pkg.t_money
  , fee_currency    com_api_type_pkg.t_curr_code
);

type t_terminal_rec is record(
    id                      com_api_type_pkg.t_short_id
  , seqnum                  com_api_type_pkg.t_seqnum
  , is_template             com_api_type_pkg.t_sign
  , terminal_number         com_api_type_pkg.t_terminal_number
  , terminal_type           com_api_type_pkg.t_dict_value
  , merchant_id             com_api_type_pkg.t_short_id
  , mcc                     com_api_type_pkg.t_mcc
  , plastic_number          com_api_type_pkg.t_attr_name
  , card_data_input_cap     com_api_type_pkg.t_dict_value
  , crdh_auth_cap           com_api_type_pkg.t_dict_value
  , card_capture_cap        com_api_type_pkg.t_dict_value
  , term_operating_env      com_api_type_pkg.t_dict_value
  , crdh_data_present       com_api_type_pkg.t_dict_value
  , card_data_present       com_api_type_pkg.t_dict_value
  , card_data_input_mode    com_api_type_pkg.t_dict_value
  , crdh_auth_method        com_api_type_pkg.t_dict_value
  , crdh_auth_entity        com_api_type_pkg.t_dict_value
  , card_data_output_cap    com_api_type_pkg.t_dict_value
  , term_data_output_cap    com_api_type_pkg.t_dict_value
  , pin_capture_cap         com_api_type_pkg.t_dict_value
  , cat_level               com_api_type_pkg.t_dict_value
  , gmt_offset              com_api_type_pkg.t_tiny_id
  , is_mac                  com_api_type_pkg.t_sign
  , device_id               com_api_type_pkg.t_short_id
  , status                  com_api_type_pkg.t_dict_value
  , contract_id             com_api_type_pkg.t_medium_id
  , inst_id                 com_api_type_pkg.t_inst_id
  , split_hash              com_api_type_pkg.t_tiny_id
  , cash_dispenser_present  com_api_type_pkg.t_sign
  , payment_possibility     com_api_type_pkg.t_sign
  , use_card_possibility    com_api_type_pkg.t_sign
  , cash_in_present         com_api_type_pkg.t_sign
  , available_network       com_api_type_pkg.t_short_id
  , available_operation     com_api_type_pkg.t_short_id
  , available_currency      com_api_type_pkg.t_short_id
);

end cst_oab_api_type_pkg;
/
