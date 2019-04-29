create table cup_fee
(
  id                           number(16),
  fee_type                     varchar2(3),
  acquirer_iin                 varchar2(255),
  forwarding_iin               varchar2(255),
  sys_trace_num                number(19),
  transmission_date_time       timestamp(6),
  pan                          varchar2(24),
  merchant_number              varchar2(255),
  auth_resp_code               varchar2(255),
  is_reversal                  number(1),
  trans_type_id                number(1),
  receiving_iin                varchar2(255),
  issuer_iin                   varchar2(255),
  sttl_currency                varchar2(3),
  sttl_sign                    number(1),
  sttl_amount                  number(22,4),
  interchange_fee_sign         number(1),
  interchange_fee_amount       number(22,4),
  reimbursement_fee_sign       number(1),
  reimbursement_fee_amount     number(22,4),
  service_fee_sign             number(1),
  service_fee_amount           number(22,4),
  file_id                      number(16),
  fin_msg_id                   number(16),
  match_status                 varchar2(8),
  inst_id                      number(4),
  reason_code                  number(4)
)
/

comment on column cup_fee.id is 'Primary key. Fee identifier'
/
comment on column cup_fee.fee_type is 'Fee type. 10 - Interchange Fee, 20 - Fee Collection, 30 - Fund Disbursement '
/
comment on column cup_fee.acquirer_iin is 'Acquiring Institution Identification Number'
/
comment on column cup_fee.forwarding_iin is 'Forwarding institution identification code'
/
comment on column cup_fee.sys_trace_num is 'System trace audit number'
/
comment on column cup_fee.transmission_date_time is 'Transmission date and time. Format is mmddhh24mmss'
/
comment on column cup_fee.pan is 'Primary Account Number'
/
comment on column cup_fee.merchant_number is 'Card acceptor identification code'
/
comment on column cup_fee.auth_resp_code is 'Authorization identification response'
/
comment on column cup_fee.is_reversal is 'Reversal indicator'
/
comment on column cup_fee.trans_type_id is 'Transaction Type Identification: 0 - Online Transaction, 1 - Batch File Transaction, 2 - Dispute and manual Transaction'
/
comment on column cup_fee.receiving_iin is 'Receiving institution identification code'
/
comment on column cup_fee.issuer_iin is 'Issuing institution identification code'
/
comment on column cup_fee.sttl_currency is 'Currency code, settlement'
/
comment on column cup_fee.sttl_sign is 'Sign of settlement amount. (1 = credit, -1 = debit)'
/
comment on column cup_fee.sttl_amount is 'Settlement amount'
/
comment on column cup_fee.interchange_fee_sign is 'Sign of interchange fee. (1 = credit, -1 = debit)'
/
comment on column cup_fee.interchange_fee_amount is 'Amount of interchange fee'
/
comment on column cup_fee.reimbursement_fee_sign is 'Sign of reimbursement fee. (1 = credit, -1 = debit)'
/
comment on column cup_fee.reimbursement_fee_amount is 'Amount of reimbursement fee'
/
comment on column cup_fee.service_fee_sign is 'Sign of service fee. (1 = credit, -1 = debit)'
/
comment on column cup_fee.service_fee_amount is 'Amount of service fee'
/
comment on column cup_fee.file_id is 'Reference to clearing file'
/
comment on column cup_fee.fin_msg_id is 'Financial message identifier'
/
comment on column cup_fee.match_status is 'Status of matching on this fee (MTST dictionary)'
/
comment on column cup_fee.inst_id is 'Institution identifier'
/
comment on column cup_fee.reason_code is 'Reason code of Fee collection/Funds disbursement'
/
alter table cup_fee add (sender_iin_level1 varchar2(11))
/
comment on column cup_fee.sender_iin_level1 is 'Level 1 Sender Institution Identification Number'
/
alter table cup_fee add (sender_iin_level2 varchar2(11))
/
comment on column cup_fee.sender_iin_level2 is 'Level 2 Sender Institution Identification Number'
/
alter table cup_fee add (receiving_iin_level2 varchar2(11))
/
comment on column cup_fee.receiving_iin_level2 is 'Level 2 Receiving Institution Identification Number'
/
comment on column cup_fee.fin_msg_id is 'Financial message or operation identifier'
/
