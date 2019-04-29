create table cst_bof_gim_fin_msg(
    id                      number(16)
  , status                  varchar2(8)
  , file_id                 number(16)  
  , record_number           number(8)
  , is_reversal             number(1)
  , is_incoming             number(1)
  , is_returned             number(1)
  , is_invalid              number(1)
  , dispute_id              number(16)
  , rrn                     varchar2(36)
  , inst_id                 number(4)
  , network_id              number(4)
  , trans_code              varchar2(2)
  , card_id                 number(12)
  , card_mask               varchar2(24)
  , card_hash               number(12)
  , oper_amount             number(22,4)
  , oper_currency           varchar2(3)
  , oper_date               date
  , sttl_amount             number(22,4)
  , sttl_currency           varchar2(3)
  , arn                     varchar2(23)
  , merchant_name           varchar2(25)
  , merchant_city           varchar2(13)
  , merchant_country        varchar2(3)
  , merchant_province_code  varchar2(3)
  , merchant_type           varchar2(1)
  , mcc                     varchar2(4)
  , usage_code              varchar2(1)
  , reason_code             varchar2(4)
  , auth_code               varchar2(6)
  , crdh_id_method          varchar2(1)
  , chargeback_ref_num      varchar2(6)
  , docum_ind               varchar2(1)
  , member_msg_text         varchar2(50)
  , spec_cond_ind           varchar2(2)
  , terminal_number         varchar2(8)
  , electr_comm_ind         varchar2(1)
  , spec_chargeback_ind     varchar2(1)
  , account_selection       varchar2(2)
  , transaction_type        varchar2(2)
  , card_seq_number         varchar2(3)
  , terminal_profile        varchar2(6)
  , unpredict_number        varchar2(8)
  , appl_trans_counter      varchar2(4)
  , appl_interch_profile    varchar2(4)
  , cryptogram              varchar2(16)
  , term_verif_result       varchar2(10)
  , cryptogram_amount       varchar2(12)
  , issuer_appl_data        varchar2(64)
  , issuer_script_result    varchar2(10)
  , card_expir_date         varchar2(4)
  , cryptogram_info_data    varchar2(2)
  , acq_inst_bin            varchar2(12)
  , host_inst_id            number(4)
  , proc_bin                varchar2(6)
  , terminal_country        varchar2(3)

  , electronic_term_ind     varchar2(1)
  , reconciliation_ind      varchar2(3)
  , payment_product_ind     varchar2(1)
  , crdh_cardnum_cap_ind    varchar2(1)
  , trans_status            varchar2(5)
  , trans_code_header       varchar2(2)
  , auth_code_src_ind       varchar2(1)
  , forw_inst_id            varchar2(8)
  , void_ind                varchar2(1)
  , receiv_inst_id          varchar2(8)
  , dest_amount             number(22,4)
  , dest_currency           varchar2(3)
  , iss_reimb_fee           number(22,4)
  , value_date              date
  , trans_inter_proc_date   date
  , voucher_dep_bank_code   varchar2(2)
  , voucher_dep_branch_code varchar2(4)
  , reconciliation_date     date
  , merch_serv_charge       number(22,4)
  , acq_msc_revenue         number(22,4)
  , crdh_billing_amount     number(22,4)
  , trans_date              date
  , trans_curr_code         varchar2(3)
  , cashback_amount         number(22,4)
  , crdh_verif_method       varchar2(6)
  , terminal_type           varchar2(2)
  , trans_category_code     varchar2(1)
  , trans_seq_number        varchar2(8)
  , iss_auth_data           varchar2(32)
  , rate_dst_loc_currency   number(22,8)
  , rate_loc_dst_currency   number(22,8)
  , trans_currency          varchar2(3)
  , logical_file            varchar2(2)
)
/

alter table cst_bof_gim_fin_msg drop column merchant_province_code
/
alter table cst_bof_gim_fin_msg add merchant_region varchar2(3)
/
comment on column cst_bof_gim_fin_msg.merchant_region is 'Merchant region code (Merchant state/province code)'
/
alter table cst_bof_gim_fin_msg add merchant_number varchar2(15)
/
comment on column cst_bof_gim_fin_msg.merchant_number is 'Merchant number (Merchant establishment number)'
/
alter table cst_bof_gim_fin_msg drop column trans_curr_code
/
comment on column cst_bof_gim_fin_msg.transaction_type is 'Transaction type in TCR 0 (TC x5, x6, x7)'
/
alter table cst_bof_gim_fin_msg add transaction_type_tcr3 varchar2(2)
/
comment on column cst_bof_gim_fin_msg.transaction_type_tcr3 is 'Transaction type in TCR 3 (TC x5, x6, x7)'
/
alter table cst_bof_gim_fin_msg add remittance_number varchar2(6)
/
comment on column cst_bof_gim_fin_msg.remittance_number is 'Remittance number'
/
alter table cst_bof_gim_fin_msg add card_indicator varchar2(1)
/
comment on column cst_bof_gim_fin_msg.card_indicator is 'Card indicator'
/
alter table cst_bof_gim_fin_msg add voucher_number varchar2(8)
/
comment on column cst_bof_gim_fin_msg.voucher_number is 'Voucher number'
/
alter table cst_bof_gim_fin_msg add int_fee_amount number(22,4)
/
comment on column cst_bof_gim_fin_msg.int_fee_amount is 'Interchange fee amount'
/
alter table cst_bof_gim_fin_msg add int_fee_currency varchar2(3)
/
comment on column cst_bof_gim_fin_msg.int_fee_currency is 'Interchange fee currency'
/
alter table cst_bof_gim_fin_msg add int_fee_sign varchar2(1)
/
comment on column cst_bof_gim_fin_msg.int_fee_sign is 'Interchange fee sign (C - Credit, D - Debit)'
/
