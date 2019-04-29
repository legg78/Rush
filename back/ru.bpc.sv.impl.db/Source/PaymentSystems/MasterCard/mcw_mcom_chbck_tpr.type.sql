create or replace type mcw_mcom_chbck_tpr as object(
    currency                 varchar2(3)
  , create_date              date
  , doc_needed               number(1)
  , message_text             varchar2(200)
  , amount                   number(22, 4)
  , reason_code              varchar2(4)
  , is_partial_chargeback    number(1)
  , chargeback_type          varchar2(20)
  , chargeback_id            varchar2(12)
  , claim_id                 varchar2(20)
  , reversed                 number(1)
  , reversal                 number(1)
)
/
alter type mcw_mcom_chbck_tpr add attribute ext_msg_status varchar2(12) invalidate
/
