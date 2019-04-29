create or replace package cst_mpu_api_type_pkg as

type t_mpu_file_rec is record (
    id               com_api_type_pkg.t_long_id
  , inst_id          com_api_type_pkg.t_tiny_id
  , network_id       com_api_type_pkg.t_tiny_id
  , is_incoming      com_api_type_pkg.t_boolean
  , iin              com_api_type_pkg.t_region_code
  , trans_date       date
  , trans_total      number(9)
  , generator        varchar2(20)
  , file_date        date
  , session_file_id  com_api_type_pkg.t_long_id
  , file_type        com_api_type_pkg.t_one_char
  , file_number      number(2)
  , inst_role        com_api_type_pkg.t_one_char
  , data_type        com_api_type_pkg.t_one_char
  , proc_date        date
);
type t_mpu_file_cur is ref cursor return t_mpu_file_rec;
type t_mpu_file_tab is table of t_mpu_file_rec index by binary_integer;
    
type t_mpu_fin_mes_rec is record (
--    row_id                rowid
    id                    com_api_type_pkg.t_long_id
  , inst_id               com_api_type_pkg.t_tiny_id
  , network_id            com_api_type_pkg.t_tiny_id
  , is_incoming           com_api_type_pkg.t_boolean
  , is_reversal           com_api_type_pkg.t_boolean
  , is_matched            com_api_type_pkg.t_boolean
  , status                com_api_type_pkg.t_dict_value
  , file_id               com_api_type_pkg.t_long_id
  , dispute_id            com_api_type_pkg.t_long_id
  , original_id           com_api_type_pkg.t_long_id
  , message_number        com_api_type_pkg.t_short_id
  , record_type           com_api_type_pkg.t_module_code
  , card_number           varchar2(19)
  , proc_code             com_api_type_pkg.t_auth_code
  , trans_amount          com_api_type_pkg.t_medium_id
  , sttl_amount           com_api_type_pkg.t_medium_id
  , sttl_rate             com_api_type_pkg.t_short_id
  , sys_trace_num         com_api_type_pkg.t_tag
  , trans_date            date
  , sttl_date             com_api_type_pkg.t_mcc
  , mcc                   com_api_type_pkg.t_mcc
  , acq_inst_code         com_api_type_pkg.t_region_code
  , iss_bank_code         com_api_type_pkg.t_region_code
  , bnb_bank_code         com_api_type_pkg.t_region_code
  , forw_inst_code        com_api_type_pkg.t_region_code
  , receiv_inst_code      com_api_type_pkg.t_region_code
  , auth_number           com_api_type_pkg.t_auth_code
  , rrn                   com_api_type_pkg.t_cmid
  , terminal_number       com_api_type_pkg.t_dict_value
  , trans_currency        com_api_type_pkg.t_curr_code
  , sttl_currency         com_api_type_pkg.t_curr_code
  , acct_from             varchar2(28)
  , acct_to               varchar2(28)
  , mti                   com_api_type_pkg.t_mcc
  , trans_status          com_api_type_pkg.t_tiny_id
  , service_fee_receiv    com_api_type_pkg.t_medium_id
  , service_fee_pay       com_api_type_pkg.t_medium_id
  , service_fee_interchg  com_api_type_pkg.t_medium_id
  , pos_entry_mode        com_api_type_pkg.t_country_code
  , sys_trace_num_orig    com_api_type_pkg.t_auth_code
  , pos_cond_code         com_api_type_pkg.t_byte_char
  , merchant_number       com_api_type_pkg.t_merchant_number
  , merchant_name         varchar2(40)
  , accept_amount         com_api_type_pkg.t_medium_id
  , cardholder_trans_fee  com_api_type_pkg.t_medium_id
  , transmit_date         date
  , orig_trans_info       com_api_type_pkg.t_arn
  , trans_features        com_api_type_pkg.t_one_char
  , merchant_country      com_api_type_pkg.t_country_code
  , auth_type             com_api_type_pkg.t_country_code
  , reason_code           com_api_type_pkg.t_mcc
  , max_trans_date        date
);

type t_mpu_fin_mes_tab is table of t_mpu_fin_mes_rec index by binary_integer;
type t_mpu_fin_cur is ref cursor return t_mpu_fin_mes_rec;

type t_tc_buffer is table of com_api_type_pkg.t_text index by binary_integer;

type t_mpu_fund_sttl_rec is record (
    id                  com_api_type_pkg.t_long_id
  , inst_id             com_api_type_pkg.t_tiny_id
  , network_id          com_api_type_pkg.t_tiny_id
  , status              com_api_type_pkg.t_dict_value
  , file_id             com_api_type_pkg.t_long_id
  , record_type         com_api_type_pkg.t_country_code
  , member_inst_code    com_api_type_pkg.t_region_code
  , out_amount_sign     com_api_type_pkg.t_one_char
  , out_amount          com_api_type_pkg.t_long_id
  , out_fee_sign        com_api_type_pkg.t_one_char
  , out_fee_amount      com_api_type_pkg.t_long_id
  , in_amount_sign      com_api_type_pkg.t_one_char
  , in_amount           com_api_type_pkg.t_long_id
  , in_fee_sign         com_api_type_pkg.t_one_char
  , in_fee_amount       com_api_type_pkg.t_long_id
  , stf_amount_sign     com_api_type_pkg.t_one_char
  , stf_amount          com_api_type_pkg.t_long_id
  , stf_fee_sign        com_api_type_pkg.t_one_char
  , stf_fee_amount      com_api_type_pkg.t_long_id
  , out_summary         number(10)
  , in_summary          number(10)
  , sttl_currency       com_api_type_pkg.t_curr_code
);
type t_mpu_fund_sttl_tab is table of t_mpu_fund_sttl_rec index by binary_integer;
type t_mpu_fund_sttl_cur is ref cursor return t_mpu_fund_sttl_rec;

type t_mpu_volume_stat_rec is record (
    id                com_api_type_pkg.t_long_id
  , inst_id           com_api_type_pkg.t_tiny_id
  , network_id        com_api_type_pkg.t_tiny_id
  , status            com_api_type_pkg.t_dict_value
  , file_id           com_api_type_pkg.t_long_id
  , record_type       com_api_type_pkg.t_country_code
  , member_inst_code  com_api_type_pkg.t_region_code
  , sttl_currency     com_api_type_pkg.t_curr_code
  , stat_trans_code   com_api_type_pkg.t_curr_code
  , summary           number(10)
  , credit_amount     com_api_type_pkg.t_long_id
  , debit_amount      com_api_type_pkg.t_long_id
);

type t_mpu_volume_stat_tab is table of t_mpu_volume_stat_rec index by binary_integer;

type t_mpu_volume_stat_cur is ref cursor return t_mpu_volume_stat_rec;

type t_mpu_mrch_settlement_rec is record (
    id                      com_api_type_pkg.t_long_id
  , inst_id                 com_api_type_pkg.t_tiny_id
  , network_id              com_api_type_pkg.t_tiny_id
  , status                  com_api_type_pkg.t_dict_value
  , file_id                 com_api_type_pkg.t_long_id
  , record_type             com_api_type_pkg.t_country_code
  , member_inst_code        com_api_type_pkg.t_region_code
  , merchant_number         com_api_type_pkg.t_merchant_number
  , in_amount_sign          com_api_type_pkg.t_one_char
  , in_amount               com_api_type_pkg.t_long_id
  , in_fee_sign             com_api_type_pkg.t_one_char
  , in_fee_amount           com_api_type_pkg.t_long_id
  , total_sttl_amount_sign  com_api_type_pkg.t_one_char
  , total_sttl_amount       com_api_type_pkg.t_long_id
  , in_summary              number(10)
  , sttl_currency           com_api_type_pkg.t_curr_code
  , mrch_sttl_account       com_api_type_pkg.t_attr_name
);

type t_mpu_mrch_settlement_tab is table of t_mpu_mrch_settlement_rec index by binary_integer;

type t_mpu_mrch_settlement_cur is ref cursor return t_mpu_mrch_settlement_rec;

end cst_mpu_api_type_pkg;
/
