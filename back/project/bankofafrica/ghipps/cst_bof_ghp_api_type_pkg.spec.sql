create or replace package cst_bof_ghp_api_type_pkg as

type t_ghp_file_rec is record (
    id                 com_api_type_pkg.t_long_id
  , is_incoming        com_api_type_pkg.t_boolean
  , is_returned        com_api_type_pkg.t_boolean
  , network_id         com_api_type_pkg.t_tiny_id
  , proc_bin           varchar2(6)
  , proc_date          date
  , release_number     varchar2(15)
  , ghp_file_id        varchar2(3)
  , inst_id            com_api_type_pkg.t_inst_id
  , session_file_id    com_api_type_pkg.t_long_id
  , originator_bin     com_api_type_pkg.t_bin
  , file_status_ind    varchar2(1)
  , total_phys_records com_api_type_pkg.t_short_id
  , total_tc70         com_api_type_pkg.t_short_id
  , total_tc71         com_api_type_pkg.t_short_id
  , total_tc72         com_api_type_pkg.t_short_id
  , total_tc73         com_api_type_pkg.t_short_id
  , total_tc74_1       com_api_type_pkg.t_short_id
  , total_tc74_2       com_api_type_pkg.t_short_id
  , total_tc050607_1   com_api_type_pkg.t_short_id
  , total_tc050607_2   com_api_type_pkg.t_short_id
  , total_tc252627_1   com_api_type_pkg.t_short_id
  , total_tc050607_3   com_api_type_pkg.t_short_id
  , total_tc252627_2   com_api_type_pkg.t_short_id
  , total_tc151617_1   com_api_type_pkg.t_short_id
  , total_tc353637_1   com_api_type_pkg.t_short_id
  , total_tc151617_2   com_api_type_pkg.t_short_id
  , total_tc353637_2   com_api_type_pkg.t_short_id
  , total_tc10_1       com_api_type_pkg.t_short_id
  , total_tc10_2       com_api_type_pkg.t_short_id
  , total_tc20_1       com_api_type_pkg.t_short_id
  , total_tc20_2       com_api_type_pkg.t_short_id
  , total_tc40         com_api_type_pkg.t_short_id
  , total_tc48         com_api_type_pkg.t_short_id
  , total_tc49         com_api_type_pkg.t_short_id
  , total_tc50_1       com_api_type_pkg.t_short_id
  , total_tc50_2       com_api_type_pkg.t_short_id
  , total_tc51         com_api_type_pkg.t_short_id
  , total_tc52         com_api_type_pkg.t_short_id
  , total_tc53         com_api_type_pkg.t_short_id
  , total_tc82         com_api_type_pkg.t_short_id
  , total_tc46         com_api_type_pkg.t_short_id
  , total_tc60         com_api_type_pkg.t_short_id
  , total_tc61         com_api_type_pkg.t_short_id
  , total_tc62         com_api_type_pkg.t_short_id
  , total_tc63         com_api_type_pkg.t_short_id
  , total_tc64         com_api_type_pkg.t_short_id
);

type t_ghp_fin_mes_rec is record (
    id                       com_api_type_pkg.t_long_id
  , status                   com_api_type_pkg.t_dict_value
  , is_reversal              com_api_type_pkg.t_boolean
  , is_incoming              com_api_type_pkg.t_boolean
  , is_returned              com_api_type_pkg.t_boolean
  , is_invalid               com_api_type_pkg.t_boolean
  , inst_id                  com_api_type_pkg.t_inst_id
  , network_id               com_api_type_pkg.t_tiny_id
  , trans_code               com_api_type_pkg.t_byte_char
  , card_id                  com_api_type_pkg.t_medium_id
  , card_hash                com_api_type_pkg.t_medium_id
  , card_mask                com_api_type_pkg.t_card_number
  , card_number              com_api_type_pkg.t_card_number -- for local processing only, not for inserting in cst_bof_ghp_fin_msg
  , oper_date                date
  , oper_amount              com_api_type_pkg.t_money
  , oper_currency            com_api_type_pkg.t_curr_code
  , sttl_amount              com_api_type_pkg.t_money
  , sttl_currency            com_api_type_pkg.t_curr_code
  , dest_amount              com_api_type_pkg.t_money
  , dest_currency            com_api_type_pkg.t_curr_code
  , arn                      varchar2(23)
  , merchant_number          com_api_type_pkg.t_merchant_number
  , merchant_name            varchar2(25)
  , merchant_city            varchar2(13)
  , merchant_country         com_api_type_pkg.t_country_code
  , merchant_type            varchar2(1)
  , merchant_region          com_api_type_pkg.t_country_code
  , mcc                      com_api_type_pkg.t_mcc
  , terminal_number          com_api_type_pkg.t_terminal_number
  , terminal_country         com_api_type_pkg.t_country_code
  , terminal_profile         com_api_type_pkg.t_auth_code
  , terminal_type            varchar2(2)
  , usage_code               varchar2(1)
  , reason_code              varchar2(4)
  , auth_code                com_api_type_pkg.t_auth_code
  , crdh_id_method           varchar2(1)
  , chargeback_ref_num       com_api_type_pkg.t_auth_code
  , docum_ind                varchar2(1)
  , member_msg_text          varchar2(50)
  , spec_cond_ind            com_api_type_pkg.t_byte_char
  , electr_comm_ind          varchar2(1)
  , spec_chargeback_ind      varchar2(1)
  , account_selection        varchar2(2)
  , transaction_type         varchar2(2)
  , card_seq_number          com_api_type_pkg.t_module_code
  , card_expir_date          com_api_type_pkg.t_mcc
  , unpredict_number         com_api_type_pkg.t_dict_value
  , appl_trans_counter       com_api_type_pkg.t_mcc
  , appl_interch_profile     com_api_type_pkg.t_mcc
  , cryptogram               varchar2(16)
  , cryptogram_info_data     com_api_type_pkg.t_byte_char
  , cryptogram_amount        com_api_type_pkg.t_cmid
  , term_verif_result        com_api_type_pkg.t_postal_code
  , issuer_appl_data         varchar2(64)
  , issuer_script_result     com_api_type_pkg.t_postal_code
  , iss_reimb_fee            number(22,4)
  , iss_auth_data            varchar2(32)
  , transaction_type_tcr3    varchar2(2)
  , trans_status             varchar2(5)
  , trans_currency           com_api_type_pkg.t_curr_code
  , trans_code_header        varchar2(2)
  , trans_inter_proc_date    date
  , trans_date               date
  , trans_category_code      varchar2(1)
  , trans_seq_number         varchar2(8)
  , crdh_cardnum_cap_ind     varchar2(1)
  , crdh_billing_amount      com_api_type_pkg.t_money
  , crdh_verif_method        varchar2(6)
  , electronic_term_ind      varchar2(1)
  , reconciliation_ind       varchar2(3)
  , payment_product_ind      varchar2(1)
  , dispute_id               com_api_type_pkg.t_long_id
  , file_id                  com_api_type_pkg.t_long_id
  , record_number            com_api_type_pkg.t_short_id
  , rrn                      com_api_type_pkg.t_rrn
  , host_inst_id             com_api_type_pkg.t_inst_id
  , acq_inst_bin             com_api_type_pkg.t_rrn
  , proc_bin                 com_api_type_pkg.t_auth_code
  , auth_code_src_ind        varchar2(1)
  , forw_inst_id             varchar2(8)
  , void_ind                 varchar2(1)
  , receiv_inst_id           varchar2(8)
  , value_date               date
  , voucher_dep_bank_code    varchar2(2)
  , voucher_dep_branch_code  varchar2(4)
  , reconciliation_date      date
  , merch_serv_charge        com_api_type_pkg.t_money
  , acq_msc_revenue          com_api_type_pkg.t_money
  , cashback_amount          com_api_type_pkg.t_money
  , rate_dst_loc_currency    number(22,8)
  , rate_loc_dst_currency    number(22,8)
  , logical_file             com_api_type_pkg.t_byte_char
);
type t_ghp_fin_mes_tab is table of t_ghp_fin_mes_rec index by binary_integer;
type t_ghp_fin_cur is ref cursor return t_ghp_fin_mes_rec;

type t_retrieval_rec is record (
    id                           com_api_type_pkg.t_long_id
  , file_id                      com_api_type_pkg.t_long_id
  , iss_inst_id                  com_api_type_pkg.t_inst_id
  , acq_inst_id                  com_api_type_pkg.t_inst_id
  , document_type                varchar2(1)
  , card_iss_ref_num             varchar2(9)
  , cancellation_ind             varchar2(1)
  , potential_chback_reason_code varchar2(2)
  , response_type                varchar2(1)
);

type t_tc_buffer is table of com_api_type_pkg.t_text index by binary_integer;

type t_fee_rec is record (
    id                       com_api_type_pkg.t_long_id
  , file_id                  com_api_type_pkg.t_long_id
  , fee_type_ind             varchar2(1)
  , forw_inst_country_code   com_api_type_pkg.t_country_code
  , reason_code              varchar2(4)
  , collection_branch_code   varchar2(4)
  , trans_count              varchar2(8)
  , unit_fee                 varchar2(9)
  , event_date               date
  , source_amount_cfa        number(22,4)
  , control_number           varchar2(14)
  , message_text             varchar2(100)
);

type t_fraud_rec is record (
    id                             com_api_type_pkg.t_long_id
  , status                         com_api_type_pkg.t_dict_value
  , file_id                        com_api_type_pkg.t_long_id
  , record_number                  com_api_type_pkg.t_short_id
  , is_incoming                    com_api_type_pkg.t_boolean
  , is_invalid                     com_api_type_pkg.t_boolean
  , dispute_id                     com_api_type_pkg.t_long_id
  , network_id                     com_api_type_pkg.t_network_id
  , inst_id                        com_api_type_pkg.t_inst_id
  , host_inst_id                   com_api_type_pkg.t_inst_id
  , forw_inst_id                   varchar2(8)
  , receiv_inst_id                 varchar2(8)
  , arn                            varchar2(23)
  , oper_date                      date
  , card_id                        com_api_type_pkg.t_medium_id
  , card_hash                      com_api_type_pkg.t_medium_id
  , card_mask                      com_api_type_pkg.t_card_number
  , card_number                    com_api_type_pkg.t_card_number
  , merchant_name                  varchar2(25)
  , merchant_city                  varchar2(13)
  , merchant_country               com_api_type_pkg.t_country_code
  , merchant_region                com_api_type_pkg.t_country_code
  , mcc                            com_api_type_pkg.t_mcc
  , fraud_amount                   com_api_type_pkg.t_money
  , fraud_currency                 com_api_type_pkg.t_curr_code
  , vic_processing_date            date
  , notification_code              com_api_type_pkg.t_dict_value
  , account_seq_number             varchar2(4)
  , insurance_year                 varchar2(2)
  , fraud_type                     com_api_type_pkg.t_dict_value
  , card_expir_date                varchar2(4)
  , debit_credit_indicator         varchar2(1)
  , trans_generation_method        varchar2(1)
  , electr_comm_ind                varchar2(1)
  , logical_file                   com_api_type_pkg.t_byte_char
);

type t_logical_file_rec is record (
    logical_file_code              com_api_type_pkg.t_byte_char
  , total_phys_records             com_api_type_pkg.t_short_id
  , total_merchant_credit          com_api_type_pkg.t_short_id
  , total_cash_withdrawal_credit   com_api_type_pkg.t_short_id
  , total_cash_advance_credit      com_api_type_pkg.t_short_id
  , total_tc050607_1               com_api_type_pkg.t_short_id
  , total_tc05                     com_api_type_pkg.t_short_id
  , total_tc252627_1               com_api_type_pkg.t_short_id
  , total_tc050607_2               com_api_type_pkg.t_short_id
  , total_tc252627_2               com_api_type_pkg.t_short_id
  , total_tc151617_1               com_api_type_pkg.t_short_id
  , total_tc353637_1               com_api_type_pkg.t_short_id
  , total_tc151617_2               com_api_type_pkg.t_short_id
  , total_tc353637_2               com_api_type_pkg.t_short_id
  , total_tc10_1                   com_api_type_pkg.t_short_id
  , total_tc10_2                   com_api_type_pkg.t_short_id
  , total_tc20_1                   com_api_type_pkg.t_short_id
  , total_tc20_2                   com_api_type_pkg.t_short_id
  , total_tc40                     com_api_type_pkg.t_short_id
  , total_tc48                     com_api_type_pkg.t_short_id
  , total_tc49                     com_api_type_pkg.t_short_id
  , total_tc50_1                   com_api_type_pkg.t_short_id
  , total_tc50_2                   com_api_type_pkg.t_short_id
  , total_tc51                     com_api_type_pkg.t_short_id
  , total_tc52                     com_api_type_pkg.t_short_id
  , total_tc53                     com_api_type_pkg.t_short_id
  , total_tc82                     com_api_type_pkg.t_short_id
  , total_tc46                     com_api_type_pkg.t_short_id
  , total_purchase_credit          com_api_type_pkg.t_short_id
  , total_purchase_debit           com_api_type_pkg.t_short_id
  , total_payment_incident         com_api_type_pkg.t_short_id
  , total_personnalisation         com_api_type_pkg.t_short_id
  , total_card_stand_in_prm        com_api_type_pkg.t_short_id
  , total_account_stand_in_prm     com_api_type_pkg.t_short_id
  , total_card_pers_confirmation   com_api_type_pkg.t_short_id
  , total_renewal_advice           com_api_type_pkg.t_short_id
);

end;
/
