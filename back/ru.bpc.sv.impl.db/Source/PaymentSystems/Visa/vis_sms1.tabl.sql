create table vis_sms1(
    id                  number(16) not null
  , file_id             number(16)
  , record_number       number(6)
  , status              varchar2(8)
  , record_type         varchar2(6)
  , iss_acq             varchar2(1)
  , isa_ind             varchar2(1)
  , giv_flag            varchar2(1)
  , affiliate_bin       varchar2(10)
  , sttl_date           date
  , val_code            varchar2(4)
  , refnum              varchar2(12)
  , trace_num           varchar2(6)
  , req_msg_type        varchar2(4)
  , resp_code           varchar2(2)
  , proc_code           varchar2(6)
  , msg_reason_code     varchar2(4)
  , trxn_ind            varchar2(15)
  , sttl_curr_code      varchar2(3)
  , sttl_amount         number(12)
  , sttl_sign           varchar2(1)
  , reserved            varchar2(7)
  , spend_qualified_ind varchar2(1)
  , surcharge_amount    number(8)
  , surcharge_sign      varchar2(1)
  , inst_id             number(4)
)
/

comment on table vis_sms1 is 'Visa TC33 Multipurpose Messages of SMS Raw Data Version 2.3 (SMS Reports), for record type: Financial Transaction Record 1 (V23200). Contains key transaction detail information. Can be used for reconciliation purposes.'
/
comment on column vis_sms1.id                  is 'Primary key'
/
comment on column vis_sms1.file_id             is 'File ID'
/
comment on column vis_sms1.record_number       is 'Record number'
/
comment on column vis_sms1.status              is 'Status'
/
comment on column vis_sms1.record_type         is 'Record Type (V23200)'
/
comment on column vis_sms1.iss_acq             is 'Issuer-Acquirer Indicator'
/
comment on column vis_sms1.isa_ind             is 'ISA Indicator. Field 63.21'
/
comment on column vis_sms1.giv_flag            is 'GIV Flag. Header Field 9'
/
comment on column vis_sms1.affiliate_bin       is 'Affiliate BIN'
/
comment on column vis_sms1.sttl_date           is 'Settlement Date'
/
comment on column vis_sms1.val_code            is 'Validation Code. Field 62.3'
/
comment on column vis_sms1.refnum              is 'Retrieval Reference Number. Field 37'
/
comment on column vis_sms1.trace_num           is 'Trace Number. Field 11'
/
comment on column vis_sms1.req_msg_type        is 'Request Message Type'
/
comment on column vis_sms1.resp_code           is 'Response Code. Field 39'
/
comment on column vis_sms1.proc_code           is 'Processing Code. Field 3'
/
comment on column vis_sms1.msg_reason_code     is 'Message Reason Code. Field 63.3'
/
comment on column vis_sms1.trxn_ind            is 'Transaction Identifier.  Field 62.2'
/
comment on column vis_sms1.sttl_curr_code      is 'Currency Code Settlement Amount. Field 50'
/
comment on column vis_sms1.sttl_amount         is 'Settlement Amount. Field 5'
/
comment on column vis_sms1.sttl_sign           is 'Settlement Amount Debit/Credit Indicator (C - Credit, D - Debit)'
/
comment on column vis_sms1.reserved            is 'Reserved. This field was moved to V23210. Temporally filled with zeros until positions are reused.'
/
comment on column vis_sms1.spend_qualified_ind is 'Spend Qualified Indicator'
/
comment on column vis_sms1.surcharge_amount    is 'Surcharge_amount'
/
comment on column vis_sms1.surcharge_sign      is 'Surcharge Debit/Credit Indicator (C - Credit, D - Debit)'
/
comment on column vis_sms1.inst_id             is 'Institution ID'
/
