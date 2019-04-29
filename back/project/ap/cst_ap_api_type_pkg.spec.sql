create or replace package cst_ap_api_type_pkg is
/************************************************************
 * Processes for loading TP files <br />
 * Created by Vasilyeva Y.(vasilieva@bpcbt.com)  at 25.02.2019 <br />
 * Last changed by $Author: Vasilyeva Y. $ <br />
 * $LastChangedDate:: #$ <br />
 * Revision: $LastChangedRevision:  $ <br />
 * Module: cst_smt_prc_incoming_pkg <br />
 * @headcom
 **********************************************************/

type t_tp_rec is record(
    ch_cr_dr                 com_api_type_pkg.t_curr_code
  , bin                      com_api_type_pkg.t_bin
  , iss_bank_code            com_api_type_pkg.t_curr_code
  , acch_acc_number          com_api_type_pkg.t_account_number
  , acch_card_number         com_api_type_pkg.t_account_number
  , mrc_cr_dr                com_api_type_pkg.t_curr_code
  , mrc_acc_number           com_api_type_pkg.t_account_number
  , acq_bin                  com_api_type_pkg.t_bin
  , bank_acq_code            com_api_type_pkg.t_curr_code
  , code_trading_merch       com_api_type_pkg.t_port
  , terminal_number          com_api_type_pkg.t_merchant_number
  , merchant_number          com_api_type_pkg.t_merchant_number
  , transaction_type         com_api_type_pkg.t_curr_code
  , transaction_date         com_api_type_pkg.t_dict_value
  , transaction_time         com_api_type_pkg.t_dict_value
  , transaction_amount       com_api_type_pkg.t_merchant_number
  , invoice_number           com_api_type_pkg.t_terminal_number
  , issuer_invoice           com_api_type_pkg.t_card_number
  , client_id                com_api_type_pkg.t_card_number
  , tran_ref_number          com_api_type_pkg.t_merchant_number
  , auth_number              com_api_type_pkg.t_auth_long_id
  , cr_dr_ch_fee             com_api_type_pkg.t_curr_code
  , acch_fee                 com_api_type_pkg.t_money
  , cr_dr_mrc_fee            com_api_type_pkg.t_curr_code
  , mrc_fee                  com_api_type_pkg.t_money
  , inter_fee                com_api_type_pkg.t_money
  , tech_fee                 com_api_type_pkg.t_money
  , l_emv_9f26_qarqc         com_api_type_pkg.t_auth_long_id
  , l_emv_9F27_crypto        com_api_type_pkg.t_byte_char
  , l_emv_9F36_trn_count     com_api_type_pkg.t_mcc
  , l_emv_95_term_verif      com_api_type_pkg.t_auth_medium_id
  , merchant_name            com_api_type_pkg.t_name
  , ruf_emv                  com_api_type_pkg.t_name
  , refnum                   com_api_type_pkg.t_merchant_number
  , udf1                     com_api_type_pkg.t_oracle_name
  , ruf_acq                  com_api_type_pkg.t_oracle_name
  , refnum_refund            com_api_type_pkg.t_merchant_number
  , track_id                 com_api_type_pkg.t_auth_medium_id
  , tran_num_purch_internet  com_api_type_pkg.t_oracle_name
  , ruf_ecom                 com_api_type_pkg.t_oracle_name
  , atm_loc                  com_api_type_pkg.t_oracle_name
  , atm_connex               com_api_type_pkg.t_auth_medium_id
  , ruf_atm                  com_api_type_pkg.t_oracle_name
);

type t_opr_card_rec is record(
    oper_id                  com_api_type_pkg.t_long_id
  , part_key                 com_api_type_pkg.t_dict_value
  , participant_type         com_api_type_pkg.t_dict_value
  , card_number              com_api_type_pkg.t_card_number
  , split_hash               com_api_type_pkg.t_tiny_id
);

type t_aup_tag_rec is record(
    tag_id                   com_api_type_pkg.t_short_id
  , tag_value                com_api_type_pkg.t_full_desc
  , seq_number               com_api_type_pkg.t_tiny_id
);
type t_aup_tag_tab is table of t_aup_tag_rec index by binary_integer;

type t_cro_rec is record(
    oper_code                com_api_type_pkg.t_byte_char
  , transaction_num          com_api_type_pkg.t_card_number
);

type t_file_header_rec is record(
    sign                    varchar2(1)
  , compensation_code       varchar2(2)
  , iss_currency_code       varchar2(2)
  , date_of_generation      varchar2(8)
  , time_of_generation      varchar2(6)
  , operation_code          varchar2(2)
  , participant_code        varchar2(3)
  , presentation_date       varchar2(8)
  , presentation_date_appl  varchar2(8)
  , number_of_delivery      varchar2(4)
  , registration_code       varchar2(2)
  , currency_code           varchar2(3)
  , total_amount            varchar2(15)
  , number_of_operation     varchar2(10)
  , source_identification   varchar2(3)
  , filler                  varchar2(573)
);

type t_file_atm_rec is record(
    sign                        varchar2(1)
  , compensation_code           varchar2(2)
  , iss_currency_code           varchar2(2)
  , date_of_generation          varchar2(8)
  , time_of_generation          varchar2(6)
  , operation_code              varchar2(2)
  , participant_code            varchar2(3)
  , presentation_date           varchar2(8)
  , presentation_date_appl      varchar2(8)
  , number_of_delivery          varchar2(4)
  , registration_code           varchar2(2)
  , currency_code               varchar2(3)
  , amount_of_operation         varchar2(15)
  , transaction_number          varchar2(12)
  , authorization_number        varchar2(20)
  , type_of_operation           varchar2(3)
  , code_of_dest_participant    varchar2(3)
  , destination_currency        varchar2(2)
  , rib_of_the_creditor         varchar2(20)
  , card_number                 varchar2(16)
  , point_number                varchar2(10)
  , terminal_number             varchar2(10)
  , merchant_number             varchar2(11)
  , date_of_regulation          varchar2(8)
  , reson_for_reject            varchar2(8)
  , reference_of_operation      varchar2(18)
  , rio_of_operation            varchar2(38)
  , destination_agency_code     varchar2(5)
  , withdrawal_amount           varchar2(15)
  , sign_of_commission          varchar2(1)
  , amount_of_commision         varchar2(7)
  , date_of_withdrawal          varchar2(8)
  , time_of_withdrawal          varchar2(6)
  , processing_mode             varchar2(1)
  , authentication_mode         varchar2(1)
  , start_date_of_valid_card    varchar2(8)
  , end_date_of_valid_card      varchar2(8)
  , criptogram_information      varchar2(1)
  , atc                         varchar2(2)
  , tvr                         varchar2(5)
  , remitting_agency_code       varchar2(5)
  , filler                      varchar2(334)
);

type t_file_pos_rec is record(
    sign                        varchar2(1)
  , compensation_code           varchar2(2)
  , iss_currency_code           varchar2(2)
  , date_of_generation          varchar2(8)
  , time_of_generation          varchar2(6)
  , operation_code              varchar2(2)
  , participant_code            varchar2(3)
  , presentation_date           varchar2(8)
  , presentation_date_appl      varchar2(8)
  , number_of_delivery          varchar2(4)
  , registration_code           varchar2(2)
  , currency_code               varchar2(3)
  , amount_of_operation         varchar2(15)
  , transaction_number          varchar2(12)
  , authorization_number        varchar2(20)
  , type_of_operation           varchar2(3)
  , code_of_dest_participant    varchar2(3)
  , destination_currency        varchar2(2)
  , rib_of_the_creditor         varchar2(20)
  , card_number                 varchar2(16)
  , point_number                varchar2(10)
  , terminal_number             varchar2(10)
  , merchant_number             varchar2(11)
  , date_of_regulation          varchar2(8)
  , reson_for_reject            varchar2(8)
  , reference_of_operation      varchar2(18)
  , rio_of_operation            varchar2(38)
  , payment_type                varchar2(2)
  , amount                      varchar2(15)
  , sign_of_operation           varchar2(1)
  , sign_of_commission          varchar2(1)
  , amount_of_commision         varchar2(7)
  , date_of_payment             varchar2(8)
  , time_of_payment             varchar2(6)
  , processing_mode             varchar2(1)
  , authentication_mode         varchar2(1)
  , start_date_of_valid_card    varchar2(8)
  , end_date_of_valid_card      varchar2(8)
  , criptogram_information      varchar2(1)
  , atc                         varchar2(2)
  , tvr                         varchar2(5)
  , acceptor_customer_discount  varchar2(310)
  , presence_indicator_rib_iban varchar2(1)
  , prefix_iban                 varchar2(4)
  , merchant_name               varchar2(50)
  , address_of_merchant         varchar2(70)
  , telephone_of_merchant       varchar2(10)
  , acceptor_contract_number    varchar2(15)
  , acceptor_activity_code      varchar2(6)
  , remitting_agency_code       varchar2(5)
  , filler                      varchar2(172)
);

type t_file_rec is record(
    sign                        varchar2(1)
  , compensation_code           varchar2(2)
  , iss_currency_code           varchar2(2)
  , date_of_generation          varchar2(8)
  , time_of_generation          varchar2(6)
  , operation_code              varchar2(2)
  , participant_code            varchar2(3)
  , presentation_date           varchar2(8)
  , presentation_date_appl      varchar2(8)
  , number_of_delivery          varchar2(4)
  , registration_code           varchar2(2)
  , currency_code               varchar2(3)
  , amount_of_operation         varchar2(15)
  , transaction_number          varchar2(12)
  , authorization_number        varchar2(20)
  , type_of_operation           varchar2(3)
  , code_of_dest_participant    varchar2(3)
  , destination_currency        varchar2(2)
  , rib_of_the_creditor         varchar2(20)
  , card_number                 varchar2(16)
  , point_number                varchar2(10)
  , terminal_number             varchar2(10)
  , merchant_number             varchar2(11)
  , date_of_regulation          varchar2(8)
  , reson_for_reject            varchar2(8)
  , reference_of_operation      varchar2(18)
  , rio_of_operation            varchar2(38)
  , destination_agency_code     varchar2(5)
  , withdrawal_amount           varchar2(15)
  , sign_of_commission          varchar2(1)
  , amount_of_commision         varchar2(7)
  , date_of_withdrawal          varchar2(8)
  , time_of_withdrawal          varchar2(6)
  , processing_mode             varchar2(1)
  , authentication_mode         varchar2(1)

  , payment_type                varchar2(2)
  , amount                      varchar2(15)
  , sign_of_operation           varchar2(1)

  , date_of_payment             varchar2(8)
  , time_of_payment             varchar2(6)

  , acceptor_customer_discount  varchar2(310)
  , presence_indicator_rib_iban varchar2(1)
  , prefix_iban                 varchar2(4)
  , merchant_name               varchar2(50)
  , address_of_merchant         varchar2(70)
  , telephone_of_merchant       varchar2(10)
  , acceptor_contract_number    varchar2(15)
  , acceptor_activity_code      varchar2(6)


  , start_date_of_valid_card    varchar2(8)
  , end_date_of_valid_card      varchar2(8)
  , criptogram_information      varchar2(1)
  , atc                         varchar2(2)
  , tvr                         varchar2(5)
  , remitting_agency_code       varchar2(5)
  , filler                      varchar2(334)

);

type t_synt_file_rec is record(
    id                 com_api_type_pkg.t_long_id
  , session_file_id    com_api_type_pkg.t_long_id
  , file_type          com_api_type_pkg.t_tag
  , session_day        date
  , opr_type           com_api_type_pkg.t_byte_id
  , bank_id            com_api_type_pkg.t_tag
  , oper_cnt           com_api_type_pkg.t_long_id
  , oper_amount        com_api_type_pkg.t_long_id
  , balance_impact     com_api_type_pkg.t_sign
);

type t_synt_file_tab is table of t_synt_file_rec index by binary_integer;

end cst_ap_api_type_pkg;
/
