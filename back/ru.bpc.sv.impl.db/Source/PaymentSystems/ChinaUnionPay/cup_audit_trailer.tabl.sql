create table cup_audit_trailer
(
    id                           number(16)
  , acquirer_iin                 varchar2(11)
  , forwarding_iin               varchar2(11)
  , sys_trace_num                varchar2(6)
  , transmission_date_time       timestamp(6)
  , trans_amount                 number(22,4)
  , message_type                 varchar2(4)
  , proc_func_code               varchar2(6)
  , mcc                          varchar2(4)
  , terminal_number              varchar2(8)
  , merchant_number              varchar2(15)
  , merchant_name                varchar2(100)
  , rrn                          varchar2(12)
  , pos_cond_code                varchar2(2)
  , auth_resp_code               varchar2(6)
  , receiving_iin                varchar2(11)
  , orig_sys_trace_num           varchar2(6)
  , trans_resp_code              varchar2(2)
  , trans_currency               varchar2(3)
  , pos_entry_mode               varchar2(3)
  , sttl_currency                varchar2(3)
  , sttl_amount                  number(22,4)
  , sttl_exch_rate               varchar2(8)
  , sttl_date                    date
  , exchange_date                date
  , cardholder_acc_currency      varchar2(3)
  , cardholder_bill_amount       number(22,4)
  , cardholder_exch_rate         varchar2(8)
  , receivable_fee               number(22,4)
  , payable_fee                  number(22,4)
  , billing_currency             varchar2(3)
  , billing_exch_rate            varchar2(8)
  , file_id                      number(16)
  , inst_id                      number(4)
  , match_status                 varchar2(8)
  , fin_msg_id                   number(16)
)
/
comment on table cup_audit_trailer is 'UnionPay audit trailer.'
/
comment on column cup_audit_trailer.id is 'Primary key. Audit trailer identifier'
/
comment on column cup_audit_trailer.acquirer_iin is 'Acquiring Institution Identification Number'
/
comment on column cup_audit_trailer.forwarding_iin is 'Forwarding institution identification code'
/
comment on column cup_audit_trailer.sys_trace_num is 'System trace audit number'
/
comment on column cup_audit_trailer.transmission_date_time is 'Transmission date and time. Format is mmddhh24mmss'
/
comment on column cup_audit_trailer.trans_amount is 'Transaction amount'
/
comment on column cup_audit_trailer.message_type is 'Message Type'
/
comment on column cup_audit_trailer.proc_func_code is 'Processing code'
/
comment on column cup_audit_trailer.mcc is 'Merchant''s Type'
/
comment on column cup_audit_trailer.terminal_number is 'Card acceptor terminal identification'
/
comment on column cup_audit_trailer.merchant_number is 'Card acceptor identification code'
/
comment on column cup_audit_trailer.merchant_name is 'Card acceptor name/location'
/
comment on column cup_audit_trailer.rrn is 'Retrieval Reference Number'
/
comment on column cup_audit_trailer.pos_cond_code is 'Point of service condition code'
/
comment on column cup_audit_trailer.auth_resp_code is 'Authorization identification response'
/
comment on column cup_audit_trailer.receiving_iin is 'Receiving institution identification code'
/
comment on column cup_audit_trailer.orig_sys_trace_num is 'System trace audit number of Original Transaction'
/
comment on column cup_audit_trailer.trans_resp_code is 'Response Code'
/
comment on column cup_audit_trailer.trans_currency is 'Currency code, transaction'
/
comment on column cup_audit_trailer.pos_entry_mode is 'Point Of Service Entry Mode'
/
comment on column cup_audit_trailer.sttl_currency is 'Currency code, settlement'
/
comment on column cup_audit_trailer.sttl_amount is 'Amount, settlement'
/
comment on column cup_audit_trailer.sttl_exch_rate is 'Conversion rate, settlement'
/
comment on column cup_audit_trailer.sttl_date is 'Settlement Date'
/
comment on column cup_audit_trailer.exchange_date is 'Exchange Date'
/
comment on column cup_audit_trailer.cardholder_acc_currency is 'Cardholder Account Currency'
/
comment on column cup_audit_trailer.cardholder_bill_amount is 'Cardholder Billing Amount'
/
comment on column cup_audit_trailer.cardholder_exch_rate is 'Cardholder Billing Exchange Rate'
/
comment on column cup_audit_trailer.receivable_fee is 'Commission Receivable (Settlement Currency)'
/
comment on column cup_audit_trailer.payable_fee is 'Commission Payable (Settlement Currency)'
/
comment on column cup_audit_trailer.billing_currency is 'RF Billing Currency'
/
comment on column cup_audit_trailer.billing_exch_rate is 'Exchange Rate from RF Billing Currency to Settlement Currency'
/
comment on column cup_audit_trailer.file_id is 'Reference to clearing file'
/
comment on column cup_audit_trailer.match_status is 'Status of matching on this fee (MTST dictionary)'
/
comment on column cup_audit_trailer.inst_id is 'Institution identifier'
/
comment on column cup_audit_trailer.fin_msg_id is 'Financial message identifier'
/
