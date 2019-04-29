create table nbf_fin_message(
    id                      number(16,0)
  , status                  varchar2(8)
  , file_id                 number(8,0)
  , is_incoming             number(1,0)
  , iss_account_id          number(12,0)
  , debit_bank_code         varchar2(10)
  , debit_account_number    varchar2(20)
  , credit_bank_code        varchar2(10)
  , credit_account_number   varchar2(20)
  , amount                  number(22,4)
  , currency                varchar2(3)
  , oper_date               date
  , rrn                     varchar2(36)
  , oper_id                 number(16)
)
/

comment on table nbf_fin_message is 'NBC Fast financial messages.'
/
comment on column nbf_fin_message.id is 'Primary key.'
/
comment on column nbf_fin_message.status is 'Fin message status.'
/
comment on column nbf_fin_message.file_id is 'File id.'
/
comment on column nbf_fin_message.is_incoming is 'Incoming flag.'
/
comment on column nbf_fin_message.iss_account_id is 'Issuer account.'
/
comment on column nbf_fin_message.debit_bank_code is 'Debit bank code.'
/
comment on column nbf_fin_message.debit_account_number is 'Debit account number.'
/
comment on column nbf_fin_message.credit_bank_code is 'Credit bank code.'
/
comment on column nbf_fin_message.credit_account_number is 'Credit account number.'
/
comment on column nbf_fin_message.rrn is 'Operation reference number.'
/
comment on column nbf_fin_message.oper_date is 'Operation date.'
/
comment on column nbf_fin_message.amount is 'Operation amount.'
/
comment on column nbf_fin_message.currency is 'Currency code.'
/
comment on column nbf_fin_message.oper_id is 'Matched operation id.'
/
alter table nbf_fin_message modify debit_bank_code varchar2(12)
/
alter table nbf_fin_message modify credit_bank_code varchar2(12)
/

