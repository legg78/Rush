create table amx_atm_rcn_fin(
    id                            number(16) not null
  , status                        varchar2(8)
  , is_invalid                    number(1)
  , file_id                       number(16)
  , inst_id                       number(4)
  , record_type                   varchar2(1)
  , msg_seq_number                varchar2(5)
  , trans_date                    date
  , system_date                   date
  , sttl_date                     date
  , terminal_number               varchar2(8)
  , system_trace_audit_number     varchar2(6)
  , dispensed_currency            varchar2(3)
  , amount_requested              varchar2(15)
  , amount_ind                    varchar2(15)
  , sttl_rate                     varchar2(12)
  , sttl_currency                 varchar2(3)
  , sttl_amount_requested         varchar2(15)
  , sttl_amount_approved          varchar2(15)
  , sttl_amount_dispensed         varchar2(15)
  , sttl_network_fee              varchar2(11)
  , sttl_other_fee                varchar2(11)
  , terminal_country_code         varchar2(2)
  , merchant_country_code         varchar2(2)
  , card_billing_country_code     varchar2(2)
  , terminal_location             varchar2(40)
  , auth_status                   varchar2(1)
  , trans_indicator               varchar2(1)
  , orig_action_code              varchar2(3)
  , approval_code                 varchar2(6)
  , add_ref_number                varchar2(8)
  , trans_id                      varchar2(15)
)
/

comment on table amx_atm_rcn_fin is 'Amex ATM Reconciliation records'
/ 
comment on column amx_atm_rcn_fin.id is 'Primary key. Message identifier'
/
comment on column amx_atm_rcn_fin.file_id is 'Reference to clearing file'
/
comment on column amx_atm_rcn_fin.inst_id is 'Institution identifier'
/
comment on column amx_atm_rcn_fin.record_type is 'Record Type'
/
comment on column amx_atm_rcn_fin.msg_seq_number is 'Record Sequence Number'
/
comment on column amx_atm_rcn_fin.trans_date is 'Transaction Date and Time'
/
comment on column amx_atm_rcn_fin.system_date is 'System Date and Time'
/
comment on column amx_atm_rcn_fin.sttl_date is 'Settlement Date'
/
comment on column amx_atm_rcn_fin.terminal_number is 'Card Acceptor Terminal Identification'
/
comment on column amx_atm_rcn_fin.system_trace_audit_number is 'Systems Trace Audit Number'
/
comment on column amx_atm_rcn_fin.dispensed_currency is 'Dispensed Currency'
/
comment on column amx_atm_rcn_fin.amount_requested is 'Amount Requested'
/
comment on column amx_atm_rcn_fin.amount_ind is 'Amount Indicator'
/
comment on column amx_atm_rcn_fin.sttl_rate is 'Settlement Conversion Rate'
/
comment on column amx_atm_rcn_fin.sttl_currency is 'Settlement Currency Code'
/
comment on column amx_atm_rcn_fin.sttl_amount_requested is 'Settlement Amount Requested'
/
comment on column amx_atm_rcn_fin.sttl_amount_approved is 'Settlement Amount Approved'
/
comment on column amx_atm_rcn_fin.sttl_amount_dispensed is 'Settlement Amount Dispensed'
/
comment on column amx_atm_rcn_fin.sttl_network_fee is 'Settlement Network Fee'
/
comment on column amx_atm_rcn_fin.sttl_other_fee is 'Settlement Fee Other'
/
comment on column amx_atm_rcn_fin.terminal_country_code is 'Terminal Country Code'
/
comment on column amx_atm_rcn_fin.merchant_country_code is 'Card Acceptor Country Code'
/
comment on column amx_atm_rcn_fin.card_billing_country_code is 'Cardmember Billing Country Code'
/
comment on column amx_atm_rcn_fin.terminal_location is 'Terminal Location'
/
comment on column amx_atm_rcn_fin.auth_status is 'Authorization Status'
/
comment on column amx_atm_rcn_fin.trans_indicator is 'Transaction Indicator'
/
comment on column amx_atm_rcn_fin.orig_action_code is 'Original Action Code'
/
comment on column amx_atm_rcn_fin.approval_code is 'Approval Code'
/
comment on column amx_atm_rcn_fin.add_ref_number is 'Additional Reference Number'
/
comment on column amx_atm_rcn_fin.trans_id is 'Transaction Identifier (TID)'
/
