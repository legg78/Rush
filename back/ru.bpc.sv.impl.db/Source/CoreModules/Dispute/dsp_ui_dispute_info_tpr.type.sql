create or replace type dsp_ui_dispute_info_tpr as object (
    oper_id                     number(16)
  , session_id                  number(16)
  , is_reversal                 number(1)
  , original_id                 number(16)
  , oper_type                   varchar2(8)
  , oper_reason                 varchar2(8)
  , msg_type                    varchar2(8)
  , status                      varchar2(8)
  , status_reason               varchar2(8)
  , sttl_type                   varchar2(8)
  , sttl_amount                 number(22,4)
  , sttl_currency               varchar2(3)
  , acq_inst_bin                varchar2(12)
  , forw_inst_bin               varchar2(12)
  , terminal_number             varchar2(16)
  , merchant_number             varchar2(15)
  , merchant_name               varchar2(200)
  , merchant_street             varchar2(200)
  , merchant_city               varchar2(200)
  , merchant_region             varchar2(3)
  , merchant_country            varchar2(3)
  , merchant_postcode           varchar2(10)
  , mcc                         varchar2(4)
  , originator_refnum           varchar2(36)
  , network_refnum              varchar2(36)
  , oper_count                  number(16)
  , oper_request_amount         number(22,4)
  , oper_amount_algorithm       varchar2(8)
  , oper_amount                 number(22,4)
  , oper_currency               varchar2(3)
  , oper_cashback_amount        number(22,4)
  , oper_replacement_amount     number(22,4)
  , oper_surcharge_amount       number(22,4)
  , oper_date                   date
  , host_date                   date
  , unhold_date                 date
  , match_status                varchar2(8)
  , match_id                    number(16)
  , dispute_id                  number(16)
  , payment_order_id            number(16)
  , payment_host_id             number(4)
  , forced_processing           number(1)
  , rn                          number(12)
  , mcc_name                    varchar2(200)
  , payment_host_name           varchar2(200)
  , op_level                    number(4)
  , is_dispute_allowed          number(1)
)
/

alter type dsp_ui_dispute_info_tpr add attribute hierarchical_path varchar2(2000) invalidate
/

alter type dsp_ui_dispute_info_tpr add attribute fin_message_type varchar2(10) invalidate
/
alter type dsp_ui_dispute_info_tpr add attribute fin_in_flag varchar2(1) invalidate
/
alter type dsp_ui_dispute_info_tpr add attribute fin_reason_code varchar2(4) invalidate
/
alter type dsp_ui_dispute_info_tpr add attribute fin_member_text varchar2(999) invalidate
/
alter type dsp_ui_dispute_info_tpr add attribute fin_doc_flag varchar2(1) invalidate
/
alter type dsp_ui_dispute_info_tpr add attribute fin_fraud_type varchar2(2) invalidate
/
alter type dsp_ui_dispute_info_tpr add attribute fin_rejected varchar2(1) invalidate
/
alter type dsp_ui_dispute_info_tpr add attribute fin_reversal varchar2(1) invalidate
/
alter type dsp_ui_dispute_info_tpr add attribute created_by varchar2(60) invalidate
/
alter type dsp_ui_dispute_info_tpr add attribute fin_status varchar2(30) invalidate
/
alter type dsp_ui_dispute_info_tpr modify attribute fin_reason_code varchar2(200) invalidate
/
alter type dsp_ui_dispute_info_tpr modify attribute fin_fraud_type varchar2(200) invalidate
/
alter type dsp_ui_dispute_info_tpr modify attribute fin_doc_flag varchar2(200) invalidate
/
alter type dsp_ui_dispute_info_tpr add attribute inst_id number(4) invalidate
/
alter type dsp_ui_dispute_info_tpr add attribute network_id number(4) invalidate
/
alter type dsp_ui_dispute_info_tpr add attribute ext_claim_id varchar2(20) invalidate
/
alter type dsp_ui_dispute_info_tpr add attribute ext_message_id varchar2(12) invalidate
/
