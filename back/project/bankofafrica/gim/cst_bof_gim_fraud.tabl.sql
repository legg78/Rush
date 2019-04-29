create table cst_bof_gim_fraud(
    id                             number(16)
  , fraud_amount                   number(12)
  , fraud_currency                 varchar2(3)
  , vic_processing_date            date
  , notification_code              varchar2(8)
  , account_seq_number             varchar2(4)
  , insurance_year                 varchar2(2)
  , fraud_type                     varchar2(8)
  , card_expir_date                varchar2(4)
  , debit_credit_indicator         varchar2(1)
  , trans_generation_method        varchar2(1)
)
/
comment on table cst_bof_gim_fraud is 'GIM-UEMOA Fraud reporting (TC40) table. It is the addition to table with main financial messages.'
/
comment on column cst_bof_gim_fraud.id is 'Primary Key'
/
comment on column cst_bof_gim_fraud.notification_code is 'Dictionary VFNC'
/
comment on column cst_bof_gim_fraud.fraud_type is 'Dictionary VFTP'
/
comment on column cst_bof_gim_fraud.insurance_year is 'Insurance year in format YY'
/
comment on column cst_bof_gim_fraud.debit_credit_indicator is 'Debit/Credit indicator. D = debit account impacted by the fraud, C = credit account impacted by the fraud'
/
comment on column cst_bof_gim_fraud.trans_generation_method is 'Authorization indicator. P = not authorised, manual authorisation or undefined, K = request captured at the keyboard of the terminal, M = magnetic read'
/
