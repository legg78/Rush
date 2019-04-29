create or replace type rcn_host_recon_msg_tpr as object (
    oper_type                           varchar2(8)
  , msg_type                            varchar2(8)
  , sttl_type                           varchar2(8)
  , host_date                           date
  , oper_date                           date
  , oper_amount                         number(22, 4)
  , oper_currency                       varchar2(3)
  , oper_request_amount                 number(22, 4)
  , oper_request_currency               varchar2(3)
  , oper_surcharge_amount               number(22, 4)
  , oper_surcharge_currency             varchar2(3)
  , originator_refnum                   varchar2(36)
  , network_refnum                      varchar2(36)
  , acq_inst_bin                        varchar2(36)
  , status                              varchar2(8)
  , is_reversal                         number(1)
  , mcc                                 varchar2(4)
  , merchant_number                     varchar2(15)
  , merchant_name                       varchar2(200)
  , merchant_street                     varchar2(200)
  , merchant_city                       varchar2(200)
  , merchant_region                     varchar2(200)
  , merchant_country                    varchar2(3)
  , merchant_postcode                   varchar2(200)
  , terminal_type                       varchar2(8)
  , terminal_number                     varchar2(16)
  , card_number                         varchar2(24)
  , card_seq_number                     number(4)
  , card_expir_date                     date
  , card_country                        varchar2(3)
  , acq_inst_id                         number(4)
  , iss_inst_id                         number(4)
  , auth_code                           varchar2(6)
)
/
alter type rcn_host_recon_msg_tpr drop attribute sttl_type invalidate
/
alter type rcn_host_recon_msg_tpr drop attribute oper_request_amount invalidate
/
alter type rcn_host_recon_msg_tpr drop attribute oper_request_currency invalidate
/
alter type rcn_host_recon_msg_tpr drop attribute originator_refnum invalidate
/
alter type rcn_host_recon_msg_tpr drop attribute network_refnum invalidate
/
alter type rcn_host_recon_msg_tpr drop attribute acq_inst_bin invalidate
/
alter type rcn_host_recon_msg_tpr drop attribute card_country invalidate
/
alter type rcn_host_recon_msg_tpr drop attribute iss_inst_id invalidate
/
alter type rcn_host_recon_msg_tpr drop attribute auth_code invalidate
/
alter type rcn_host_recon_msg_tpr add attribute oper_cashback_amount number(22, 4) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute oper_cashback_currency varchar2(3) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute service_code varchar2(12) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute approval_code varchar2(24) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute rrn varchar2(48) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute trn varchar2(64) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute original_id varchar2(120) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_5f2a number(22, 4) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_5f34 number(22, 4) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_71 varchar2(64) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_72 varchar2(64) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_82 varchar2(32) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_84 varchar2(128) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_8a varchar2(128) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_91 varchar2(128) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_95 varchar2(40) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_9a number(22, 6) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_9c number(22, 2) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_9f02 number(22, 12) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_9f03 number(22, 12) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_9f06 varchar2(256) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_9f09 varchar2(16) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_9f10 varchar2(256) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_9f18 varchar2(32) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_9f1a number(22, 4) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_9f1e varchar2(64) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_9f26 varchar2(64) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_9f27 varchar2(8) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_9f28 varchar2(64) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_9f29 varchar2(64) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_9f33 varchar2(24) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_9f34 varchar2(24) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_9f35 number(22, 2) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_9f36 varchar2(128) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_9f37 varchar2(128) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_9f41 number(22, 8) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute emv_9f53 varchar2(128) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute pdc_1 varchar2(32) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute pdc_2 varchar2(32) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute pdc_3 varchar2(32) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute pdc_4 varchar2(32) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute pdc_5 varchar2(32) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute pdc_6 varchar2(32) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute pdc_7 varchar2(32) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute pdc_8 varchar2(32) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute pdc_9 varchar2(32) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute pdc_10 varchar2(32) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute pdc_11 varchar2(32) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute pdc_12 varchar2(32) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute forw_inst_code varchar2(44) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute receiv_inst_code varchar2(44) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute sttl_date date invalidate
/
alter type rcn_host_recon_msg_tpr add attribute oper_reason varchar2(8) invalidate
/
alter type rcn_host_recon_msg_tpr add attribute arn varchar2(36) invalidate
/
