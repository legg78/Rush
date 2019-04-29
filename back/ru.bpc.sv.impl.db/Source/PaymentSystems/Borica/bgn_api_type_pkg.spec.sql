create or replace package bgn_api_type_pkg as

type t_bgn_file_rec is record (
    id                          com_api_type_pkg.t_long_id
  , file_type                   com_api_type_pkg.t_dict_value  
  , file_label                  varchar2(10)
  , sender_code                 varchar2(5)
  , receiver_code               varchar2(5)
  , file_number                 number(3)
  , test_option                 varchar2(1)
  , creation_date               date
  , gmt_offset                  number(1)
  , bgn_sttl_type               varchar(4)
  , sttl_currency               com_api_type_pkg.t_curr_code
  , interface_version           varchar2(2)
  , journal_period              com_api_type_pkg.t_tiny_id
  , debit_total                 number(6)
  , credit_total                number(6)
  , debit_amount                com_api_type_pkg.t_money
  , credit_amount               com_api_type_pkg.t_money
  , debit_fee_amount            com_api_type_pkg.t_money
  , credit_fee_amount           com_api_type_pkg.t_money
  , net_amount                  com_api_type_pkg.t_money
  , sttl_date                   date
  , package_total               number(6)
  , control_amount              number(13) 
  , is_incoming                 number(1)
  , error_total                 number(6)
  , inst_id                     com_api_type_pkg.t_inst_id
  , network_id                  com_api_type_pkg.t_network_id
  , borica_sttl_date            date
);

type t_bgn_package_rec is record (
    id                          com_api_type_pkg.t_medium_id
  , file_id                     com_api_type_pkg.t_long_id  
  , sender_code                 varchar2(5)
  , receiver_code               varchar2(5)
  , creation_date               date
  , package_type                varchar2(3)
  , record_total                number(6)
  , control_amount              number(13)
  , package_number              number(6)
);

type t_bgn_fin_rec is record (  
    id                          com_api_type_pkg.t_long_id
  , file_id                     com_api_type_pkg.t_long_id
  , status                      com_api_type_pkg.t_dict_value
  , is_reversal                 com_api_type_pkg.t_boolean
  , dispute_id                  com_api_type_pkg.t_long_id
  , inst_id                     com_api_type_pkg.t_inst_id
  , host_inst_id                com_api_type_pkg.t_inst_id
  , network_id                  com_api_type_pkg.t_network_id
  , is_incoming                 com_api_type_pkg.t_boolean
  , package_id                  com_api_type_pkg.t_medium_id
  , record_type                 varchar2(3)
  , record_number               number(6)
  , transaction_date            date
  , transaction_type            number(2)
  , is_reject                   varchar2(1)
  , is_finance                  number(1)
  , card_id                     com_api_type_pkg.t_long_id
  , card_number                 com_api_type_pkg.t_card_number -- not for inserting into bgn_fin
  , card_mask                   com_api_type_pkg.t_card_number
  , card_seq_number             number(3)
  , card_expire_date            number(4)
  , card_type                   varchar2(3)
  , acquirer_amount             number(18)
  , acquirer_currency           com_api_type_pkg.t_curr_code
  , network_amount              number(18)
  , network_currency            com_api_type_pkg.t_curr_code
  , card_amount                 number(18)
  , card_currency               com_api_type_pkg.t_curr_code
  , auth_code                   varchar2(6)
  , trace_number                number(6)
  , retrieval_refnum            varchar2(12)
  , merchant_number             com_api_type_pkg.t_merchant_number
  , merchant_name               varchar2(25)
  , merchant_city               varchar2(13)
  , mcc                         com_api_type_pkg.t_mcc
  , terminal_number             com_api_type_pkg.t_terminal_number
  , pos_entry_mode              com_api_type_pkg.t_tiny_id
  , ain                         number(11)
  , auth_indicator              varchar2(1)
  , transaction_number          varchar2(20)
  , validation_code             varchar2(4)
  , market_data_id              varchar2(1)
  , add_response_data           number(1)
  , reject_code                 varchar2(4)
  , response_code               varchar2(2)
  , reject_text                 varchar2(52)
  , is_offline                  com_api_type_pkg.t_boolean
  , pos_text                    varchar2(40)
  , result_code                 varchar2(1)
  , terminal_cap                varchar2(6)
  , terminal_result             varchar2(10)
  , unpred_number               varchar2(8)
  , terminal_seq_number         varchar2(8)
  , derivation_key_index        varchar2(2)
  , crypto_version              varchar2(2)
  , card_result                 varchar2(6)
  , app_crypto                  varchar2(16)
  , app_trans_counter           varchar2(4)
  , app_interchange_profile     varchar2(4)
  , iss_script1_result          varchar2(10)
  , iss_script2_result          varchar2(10)
  , terminal_country            com_api_type_pkg.t_country_code
  , terminal_date               number(6)
  , auth_response_code          varchar2(2)
  , other_amount                number(12)
  , trans_type_1                number(2)
  , terminal_type               varchar2(2)
  , trans_category              varchar2(1)
  , trans_seq_counter           com_api_type_pkg.t_short_id
  , crypto_info_data            varchar2(2)
  , dedicated_filename          varchar2(32)
  , iss_app_data                varchar2(64)
  , cvm_result                  varchar2(6)
  , terminal_app_version        varchar2(4)
  , sttl_date                   number(4)
  , network_data                varchar2(50)
  , cashback_acq_amount         number(18)
  , cashback_acq_currency       com_api_type_pkg.t_curr_code
  , cashback_net_amount         number(18)
  , cashback_net_currency       com_api_type_pkg.t_curr_code
  , cashback_card_amount        number(18)
  , cashback_card_currency      com_api_type_pkg.t_curr_code
  , term_type                   varchar2(2)
  , terminal_subtype            varchar2(2)
  , trans_type_2                varchar2(2)
  , cashm_refnum                varchar2(22)
  , sttl_amount                 number(18)
  , interbank_fee_amount        number(18)
  , bank_card_id                number(5)
  , ecommerce                   number(3)
  , transaction_amount          number(18)
  , transaction_currency        number(3)
  , original_trans_number       varchar2(20)
  , account_number              varchar2(22)
  , report_period               number(4)
  , withdrawal_number           number(5)
  , period_amount               number(12)
  , card_subtype                number(2)
  , issuer_code                 number(5)
  , card_acc_number             varchar2(22)
  , add_acc_number              varchar2(22)
  , atm_bank_code               varchar2(3)
  , deposit_number              varchar2(22)
  , loaded_amount_atm           number(9)
  , is_fullload                 number(1)
  , total_amount_atm            number(9)
  , total_amount_tandem         number(9)
  , withdrawal_count            number(5)
  , receipt_count               number(5)
  , message_type                varchar2(6)
  , stan                        varchar2(6)
  , incident_cause              number(4)
  , file_record_number          com_api_type_pkg.t_short_id
  , is_invalid                  com_api_type_pkg.t_boolean
  , oper_id                     com_api_type_pkg.t_long_id
);

type t_bgn_retrieval_rec is record (
    id                      com_api_type_pkg.t_long_id
  , file_id                 com_api_type_pkg.t_long_id
  , record_type             varchar2(2)
  , record_number           number(6)
  , sender_code             varchar2(5)
  , receiver_code           varchar2(5)
  , file_number             number(3)
  , test_option             varchar2(1)
  , creation_date           date
  , original_file_id        com_api_type_pkg.t_long_id
  , transaction_number      number(20)
  , original_fin_id         com_api_type_pkg.t_long_id
  , sttl_amount             number(18)
  , interbank_fee_amount    number(18)
  , bank_card_id            number(5)
  , error_code              number(3)
  , is_invalid              com_api_type_pkg.t_boolean
);

type            t_bgn_fin_cur is ref cursor return t_bgn_fin_rec;
type            t_bgn_fin_tab is table of t_bgn_fin_rec index by binary_integer;

end bgn_api_type_pkg;
/
 