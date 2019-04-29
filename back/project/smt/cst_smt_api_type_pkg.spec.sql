create or replace package cst_smt_api_type_pkg is

/*********************************************************
*  SMT custom API type <br />
*  Created by Vasilyeva Y. (vasilieva@bpcbt.com) at 24.09.2018 <br />
*  Module: CST_SATM_API_TYPE_PKG <br />
*  @headcom
**********************************************************/
subtype t_varchar_tiny_id        is varchar2(1);

subtype t_record_type            is varchar2(4);
subtype t_inst_name              is varchar2(4);
subtype t_batch_id               is varchar2(5);
subtype t_batch_number           is varchar2(6);

type t_perso_rec is record(
    header_rec                   t_record_type
  , card_number                  com_api_type_pkg.t_card_number
  , update_code                  t_varchar_tiny_id
  , product_type                 com_api_type_pkg.t_name
  , cardholder_name              com_api_type_pkg.t_name
  , corporate_name               com_api_type_pkg.t_name
  , cardholder_address1          com_api_type_pkg.t_name
  , cardholder_address2          com_api_type_pkg.t_name
  , cardholder_address3          com_api_type_pkg.t_name
  , postal_code                  com_api_type_pkg.t_postal_code
  , correspondent_city           com_api_type_pkg.t_name
  , bank_account_numer1          com_api_type_pkg.t_account_number
  , bank_account_numer2          com_api_type_pkg.t_account_number
  , branch_code                  com_api_type_pkg.t_agent_id
  , card_begin_date              date
  , card_expiry_date             date
  , card_process_indicator       t_varchar_tiny_id
  , territiory_code              t_varchar_tiny_id
  , debit_periodicity_code       t_varchar_tiny_id
  , manual_auth_call_code        t_varchar_tiny_id
  , process_date                 date
  , bank_id                      com_api_type_pkg.t_inst_id
  , cardholder_birth_date        date
  , country_code                 com_api_type_pkg.t_country_code
  , city_code                    com_api_type_pkg.t_name
  , renew_option                 com_api_type_pkg.t_tiny_id
  , cardholder_source_code       t_varchar_tiny_id
  , primary_card_code            t_varchar_tiny_id
  , curr_code                    com_api_type_pkg.t_curr_code
  , card_pki_code_ind            t_varchar_tiny_id
  , acs_code_ind                 t_varchar_tiny_id
  , id_code                      com_api_type_pkg.t_attr_name
  , cardholder_phone_num         com_api_type_pkg.t_attr_name
  , email                        com_api_type_pkg.t_name
  , sms_notify                   t_varchar_tiny_id
  , email_notify                 t_varchar_tiny_id
);

type t_domestic_clearing_rec is record(
  merchant_id                 com_api_type_pkg.t_merchant_number  
  , batch_num                 com_api_type_pkg.t_name
  , invoce                    com_api_type_pkg.t_name
  , pan                       com_api_type_pkg.t_card_number
  , merchant_sector           com_api_type_pkg.t_name
  , transaction_channal       com_api_type_pkg.t_one_char
  , oper_code                 com_api_type_pkg.t_one_char
  , transaction_code          com_api_type_pkg.t_byte_char
  , trnasaction_amount        com_api_type_pkg.t_money
  , card_expire_date          date
  , processing_date           date
  , transaction_date          date
  , auth_code                 com_api_type_pkg.t_auth_code
  , remittance_date           date
  , mcc                       com_api_type_pkg.t_mcc
  , acquirer_id               com_api_type_pkg.t_inst_id
  , local_card_system         com_api_type_pkg.t_one_char
  , issuer_id                 com_api_type_pkg.t_inst_id
  , acquirer_refnum           com_api_type_pkg.t_arn
  , usage_code                com_api_type_pkg.t_byte_char
  , tran_reference_id         com_api_type_pkg.t_cmid
  , merchant_name             com_api_type_pkg.t_name
  , sttl_amount               com_api_type_pkg.t_money
);

type    t_domestic_clearing_tab          is table of t_domestic_clearing_rec index by binary_integer;

type t_bnqtrnx_rec is record(
   id                         com_api_type_pkg.t_long_id
  , record_type               cst_smt_api_type_pkg.t_record_type
  , batch_id                  cst_smt_api_type_pkg.t_batch_id
  , remittance_seq            com_api_type_pkg.t_seqnum
  , merchant_id               com_api_type_pkg.t_merchant_number
  , batch_number              cst_smt_api_type_pkg.t_batch_number
  , amount                    com_api_type_pkg.t_money        
  , currency                  com_api_type_pkg.t_curr_code
  , terminal_id               com_api_type_pkg.t_terminal_number
  , tran_count                com_api_type_pkg.t_short_id
  , batch_date                date         
  , operation_code            com_api_type_pkg.t_one_char
  , sttl_amount               com_api_type_pkg.t_money
  , operation_source          com_api_type_pkg.t_one_char
  , merchant_name             com_api_type_pkg.t_name
  , card_number               com_api_type_pkg.t_card_number
  , card_exp_date             date       
  , tran_date                 date  
  , appr_code                 com_api_type_pkg.t_auth_code
  , issuer_inst               cst_smt_api_type_pkg.t_inst_name
  , acquirer_inst             cst_smt_api_type_pkg.t_inst_name
  , pos_batch_sequence        com_api_type_pkg.t_seqnum
  , tran_originator           com_api_type_pkg.t_one_char
  , status                    com_api_type_pkg.t_dict_value
  , split_hash                com_api_type_pkg.t_tiny_id
  , session_file_id           com_api_type_pkg.t_long_id
  , oper_id                   com_api_type_pkg.t_long_id  
);

type    t_bnqtrnx_tab          is table of t_bnqtrnx_rec index by binary_integer;

type t_msstrxn_map_field_rec is record(
    card_number         com_api_type_pkg.t_card_number
  , oper_amount         com_api_type_pkg.t_money
  , iss_auth_code       com_api_type_pkg.t_dict_value
  , trans_date          com_api_type_pkg.t_date_short
  , trans_time          com_api_type_pkg.t_date_short
  , external_auth_id    com_api_type_pkg.t_attr_name
);

type t_msstrxn_map_field_tab is table of t_msstrxn_map_field_rec index by binary_integer;

end cst_smt_api_type_pkg;
/
