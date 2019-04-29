create or replace package nps_api_type_pkg as

type t_napas_file_rec is record (
    id                        com_api_type_pkg.t_long_id
  , is_incoming               com_api_type_pkg.t_boolean
  , is_returned               com_api_type_pkg.t_boolean
  , network_id                com_api_type_pkg.t_tiny_id
  , proc_bin                  varchar2(8)
  , proc_date                 date
  , inst_id                   com_api_type_pkg.t_inst_id
  , session_file_id           com_api_type_pkg.t_long_id
  , total_records             com_api_type_pkg.t_long_id
  , participant_type          varchar2(3)
);

type t_napas_fin_mes_rec is record (
    id                        com_api_type_pkg.t_long_id
  , mti                       com_api_type_pkg.t_mcc
  , card_number               com_api_type_pkg.t_card_number
  , trans_code                com_api_type_pkg.t_auth_code
  , service_code              varchar2(10)
  , channel_code              com_api_type_pkg.t_byte_char
  , oper_amount               com_api_type_pkg.t_money
  , real_amount               com_api_type_pkg.t_money
  , oper_currency             com_api_type_pkg.t_curr_code
  , sttl_amount               com_api_type_pkg.t_money
  , sttl_currency             com_api_type_pkg.t_curr_code
  , sttl_exchange_rate        number(16, 8)
  , bill_amount               com_api_type_pkg.t_money
  , bill_real_amount          com_api_type_pkg.t_money
  , bill_currency             com_api_type_pkg.t_curr_code
  , bill_exchange_rate        number(16, 8)
  , sys_trace_number          number(6)
  , trans_date                date
  , sttl_date                 date
  , mcc                       com_api_type_pkg.t_mcc
  , pos_entry_mode            number(3)
  , pos_condition_code        number(2)
  , terminal_number           com_api_type_pkg.t_terminal_number
  , acq_inst_bin              com_api_type_pkg.t_dict_value
  , iss_inst_bin              com_api_type_pkg.t_dict_value
  , merchant_number           com_api_type_pkg.t_merchant_number
  , bnb_inst_bin              com_api_type_pkg.t_dict_value
  , src_account_number        varchar2(28)
  , dst_account_number        varchar2(28)
  , iss_fee_napas             com_api_type_pkg.t_money
  , iss_fee_acq               com_api_type_pkg.t_money
  , iss_fee_bnb               com_api_type_pkg.t_money
  , acq_fee_napas             com_api_type_pkg.t_money
  , acq_fee_iss               com_api_type_pkg.t_money
  , acq_fee_bnb               com_api_type_pkg.t_money
  , bnb_fee_napas             com_api_type_pkg.t_money
  , bnb_fee_acq               com_api_type_pkg.t_money
  , bnb_fee_iss               com_api_type_pkg.t_money
  , rrn                       com_api_type_pkg.t_rrn
  , auth_code                 com_api_type_pkg.t_auth_code
  , transaction_id            varchar2(16)
  , resp_code                 com_api_type_pkg.t_tiny_id
  , is_dispute                com_api_type_pkg.t_boolean
  , status                    com_api_type_pkg.t_dict_value
  , file_id                   com_api_type_pkg.t_long_id
  , record_number             com_api_type_pkg.t_short_id
  , dispute_id                com_api_type_pkg.t_long_id
  , inst_id                   com_api_type_pkg.t_inst_id
  , network_id                com_api_type_pkg.t_network_id
  , is_reversal               com_api_type_pkg.t_boolean
);
type t_napas_fin_mes_tab is table of t_napas_fin_mes_rec index by binary_integer;
type t_napas_fin_cur is ref cursor return t_napas_fin_mes_rec;

type t_tc_buffer is table of com_api_type_pkg.t_text index by binary_integer;

end nps_api_type_pkg;
/
